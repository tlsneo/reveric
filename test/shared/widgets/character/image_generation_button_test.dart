// 职责: 验证生图按钮读取未保存外观、阻止重复提交，并在离开角色后不回写旧界面。
// 关联文件:
//   lib/shared/widgets/character/image_generation_button.dart
//   lib/shared/providers/character_image.dart
//   lib/shared/localization/locale_keys.dart
//   assets/translations/en/workspace.json
//   assets/translations/zh-CN/workspace.json
// 遵循的 Rules:
//   .agents/rules/testing.md

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reveric/shared/components/reveric_button.dart';
import 'package:reveric/shared/database/novel_content_database.dart';
import 'package:reveric/shared/localization/merging_asset_loader.dart';
import 'package:reveric/shared/providers/character_image.dart';
import 'package:reveric/shared/services/character/image_orchestrator.dart';
import 'package:reveric/shared/theme/theme.dart';
import 'package:reveric/shared/widgets/character/image_generation_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _target = (databasePath: 'work.db', characterId: 'character');

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });
  setUp(() => rootBundle.clear());

  testWidgets('uses current draft, prevents duplicate submit and returns photos', (
    tester,
  ) async {
    final appearance = TextEditingController(text: 'Saved look');
    addTearDown(appearance.dispose);
    final generation = _Generation(_target);
    List<SubjectPhoto>? received;
    await tester.pumpWidget(_wrap(
      generation,
      CharacterImageGenerationButton(
        databasePath: _target.databasePath,
        characterId: _target.characterId,
        appearanceController: appearance,
        onGenerated: (photos) => received = photos,
      ),
    ));
    await tester.pumpAndSettle();

    appearance.text = 'Unsaved current hairstyle and outfit';
    await tester.tap(find.byType(RevericButton));
    await tester.pump();
    expect(generation.appearances, [appearance.text]);
    final busy = tester.widget<RevericButton>(find.byType(RevericButton));
    expect(busy.loading, isTrue);
    expect(busy.onPressed, isNull);
    await tester.tap(find.byType(RevericButton));
    expect(generation.appearances, hasLength(1));

    const photos = [SubjectPhoto(assetId: 'generated')];
    generation.pending.complete(photos);
    await tester.pumpAndSettle();
    expect(received, photos);
    expect(appearance.text, 'Unsaved current hairstyle and outfit');
    expect(find.textContaining('Image added to'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('leaving the character does not cancel or call the old UI callback', (
    tester,
  ) async {
    final appearance = TextEditingController(text: 'Current appearance');
    final visible = ValueNotifier(true);
    addTearDown(appearance.dispose);
    addTearDown(visible.dispose);
    final generation = _Generation(_target);
    var callbacks = 0;
    await tester.pumpWidget(_wrap(
      generation,
      ValueListenableBuilder<bool>(
        valueListenable: visible,
        builder: (context, show, _) => show
            ? CharacterImageGenerationButton(
                databasePath: _target.databasePath,
                characterId: _target.characterId,
                appearanceController: appearance,
                onGenerated: (_) => callbacks++,
              )
            : const SizedBox.shrink(),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(RevericButton));
    await tester.pump();
    visible.value = false;
    await tester.pump();
    generation.pending.complete(const [SubjectPhoto(assetId: 'generated')]);
    await tester.pumpAndSettle();
    expect(generation.finished, isTrue);
    expect(callbacks, 0);
    expect(find.byType(SnackBar), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}

class _Generation extends CharacterImageController {
  _Generation(super.target);

  final pending = Completer<List<SubjectPhoto>>();
  final appearances = <String>[];
  bool finished = false;

  @override
  Future<List<SubjectPhoto>> run(String appearance) async {
    appearances.add(appearance);
    state = CharacterImageStage.generating;
    final result = await pending.future;
    finished = true;
    return result;
  }
}

Widget _wrap(_Generation generation, Widget child) => ProviderScope(
  overrides: [characterImageProvider(_target).overrideWith(() => generation)],
  child: EasyLocalization(
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    assetLoader: const MergingAssetLoader(),
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    child: Builder(
      builder: (context) => MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: RevericThemeData.reveric.toThemeData(),
        home: RevericTheme(
          data: RevericThemeData.reveric,
          child: Scaffold(body: child),
        ),
      ),
    ),
  ),
);
