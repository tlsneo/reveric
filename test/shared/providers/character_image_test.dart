// 职责: 验证人物生图命令在无监听调用时保活、合并重复请求并在结束后释放。
// 关联文件:
//   lib/shared/providers/character_image.dart
//   lib/shared/services/character/image_orchestrator.dart
//   lib/shared/database/novel_content_database.dart
// 遵循的 Rules:
//   .agents/rules/state-management.md
//   .agents/rules/testing.md

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reveric/shared/database/novel_content_database.dart';
import 'package:reveric/shared/providers/character_image.dart';
import 'package:reveric/shared/services/character/image_orchestrator.dart';

void main() {
  const target = (databasePath: 'work.db', characterId: 'character');
  final provider = characterImageProvider(target);
  late ProviderContainer container;
  late _ControlledGeneration controller;

  setUp(() {
    controller = _ControlledGeneration(target);
    container = ProviderContainer(
      overrides: [provider.overrideWith(() => controller)],
    );
    addTearDown(container.dispose);
  });

  test('read-only invocation survives awaits and disposes after completion',
      () async {
    final operation = container.read(provider.notifier).generate('Current look');

    await container.pump();
    expect(container.exists(provider), isTrue);
    expect(controller.disposed, isFalse);
    expect(controller.appearances, ['Current look']);

    const photos = [SubjectPhoto(assetId: 'generated', name: 'Four views')];
    controller.pending.complete(photos);
    expect(await operation, photos);

    await container.pump();
    expect(controller.disposed, isTrue);
    expect(container.exists(provider), isFalse);
  });

  test('duplicate calls share one generation and the original appearance',
      () async {
    final first = container.read(provider.notifier).generate('First appearance');
    await container.pump();
    final second = container.read(provider.notifier).generate('Later edit');

    expect(second, same(first));
    expect(controller.appearances, ['First appearance']);
    const photos = [SubjectPhoto(assetId: 'one-paid-result')];
    controller.pending.complete(photos);
    expect(await first, photos);
    expect(await second, photos);

    await container.pump();
    expect(controller.disposed, isTrue);
    expect(container.exists(provider), isFalse);
  });

  test('failed generation propagates the error and releases keepAlive', () async {
    final operation = container.read(provider.notifier).generate('Current look');
    final failure = StateError('Image service failed');
    final rejected = expectLater(operation, throwsA(same(failure)));

    await container.pump();
    expect(container.exists(provider), isTrue);
    expect(controller.disposed, isFalse);
    controller.pending.completeError(failure);
    await rejected;

    await container.pump();
    expect(controller.disposed, isTrue);
    expect(container.exists(provider), isFalse);
  });
}

class _ControlledGeneration extends CharacterImageController {
  _ControlledGeneration(super.target);

  final pending = Completer<List<SubjectPhoto>>();
  final appearances = <String>[];
  bool disposed = false;

  @override
  Future<List<SubjectPhoto>> run(String appearance) async {
    ref.onDispose(() => disposed = true);
    appearances.add(appearance);
    final photos = await pending.future;
    // 跨 await 后仍须能更新进度；不能靠测试端监听替命令保活。
    state = CharacterImageStage.saving;
    return photos;
  }
}
