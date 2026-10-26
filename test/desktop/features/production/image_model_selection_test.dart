// 职责: 验证制片图片编辑器允许选择未登记型号，并保留模型原名和基础配置校验。
// 关联文件:
//   lib/desktop/features/production/image_composer.dart
//   lib/desktop/features/production/image_submit.dart
//   lib/shared/models/production/image_request.dart
//   lib/shared/services/production/canvas_service.dart
//   lib/shared/localization/locale_keys.dart
//   assets/translations/en/production.json
//   assets/translations/zh-CN/production.json
//   assets/translations/en/screenplay.json
//   assets/translations/zh-CN/screenplay.json
// 遵循的 Rules:
//   .agents/rules/testing.md
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reveric/desktop/features/production/edit_session.dart';
import 'package:reveric/desktop/features/production/image_composer.dart';
import 'package:reveric/desktop/features/production/image_submit.dart';
import 'package:reveric/shared/components/reveric_select.dart';
import 'package:reveric/shared/database/app_database.dart' as app;
import 'package:reveric/shared/database/novel_content_database.dart';
import 'package:reveric/shared/models/ai_provider.dart';
import 'package:reveric/shared/providers/novel_providers.dart';
import 'package:reveric/shared/providers/production_images.dart';
import 'package:reveric/shared/services/image_library_service.dart';
import 'package:reveric/shared/services/novel_actions.dart';
import 'package:reveric/shared/services/novel_content.dart';
import 'package:reveric/shared/services/production/canvas_service.dart';
import 'package:reveric/shared/services/production/ffmpeg_runner.dart';
import 'package:reveric/shared/services/production/image_service.dart';
import 'package:reveric/shared/services/production/library_service.dart';
import 'package:reveric/shared/services/production/media_service.dart';
import 'package:reveric/shared/services/screenplay_service.dart';
import 'package:reveric/shared/services/storyboard/service.dart';
import 'package:reveric/shared/services/working_overlay.dart';
import '../../director/harness.dart';

void main() {
  setUpAll(initializeDirectorTest);
  setUp(() => rootBundle.clear());

  testWidgets(
    'configured unknown image model can be selected and saved',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final main = app.AppDatabase.forTest(NativeDatabase.memory());
      final db = NovelContentDatabase.forTest(NativeDatabase.memory());
      final service = ProductionCanvasService(
        StoryboardService(db),
        MediaLibraryService(
          main,
          MediaService(FfmpegRunner()),
          Directory.systemTemp,
        ),
        'work',
      );
      final overlay = WorkingOverlayService(
        db,
        NovelContentService(db),
        novelActionsService: NovelActionsService(main),
      );
      final jobs = ImageTaskService(
        database: main,
        images: buildImageLibraryService(main),
        invoke: (_, _, _) => throw StateError('This test must not generate'),
        beforeCreate: (_, _, _) async {},
        beforeSubmit: (_) async {},
        recoverSources: () async {},
      );
      const path = 'image_model_selection_test';
      var provider = aiProviderBuiltinById('openai')!.copyWith(
        id: 'images',
        type: 'openai_compatible',
        enabled: true,
        baseUrl: 'http://127.0.0.1:8000/v1',
        imageModels: ['gpt-image-2', 'gpt-image-2.5', 'local/flux-dev'],
      );
      try {
        await main.aiProviderDao.upsert(provider);
        await main.aiProviderDao.upsert(
          provider.copyWith(
            id: 'disabled',
            enabled: false,
            imageModels: ['disabled-image'],
          ),
        );
        await main.aiProviderDao.upsert(
          provider.copyWith(
            id: 'text-only',
            type: 'anthropic',
            imageModels: ['text-only-image'],
          ),
        );
        final episode = (await ScreenplayService(
          db,
        ).createInitialStructure()).episodeId;
        final node = await service.addImage(
          (await service.ensureCanvas(episode)).id,
        );
        final session = ProductionEditSession();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              workingOverlayServiceProvider(path).overrideWithValue(overlay),
              imageTaskServiceProvider.overrideWithValue(jobs),
            ],
            child: directorTestApp(
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: 850,
                  child: ProductionImageComposer(
                    service: service,
                    node: node,
                    path: path,
                    session: session,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final selector = find.byType(RevericSelect<(String, String)>);
        RevericSelect<(String, String)> current() => tester.widget(selector);
        expect(current().items.map((item) => item.value), [
          ('images', 'gpt-image-2'),
          ('images', 'gpt-image-2.5'),
          ('images', 'local/flux-dev'),
        ]);
        for (final model in ['gpt-image-2.5', 'local/flux-dev']) {
          await tester.tap(selector);
          await tester.pumpAndSettle();
          await tester.tap(find.text(model).last);
          await tester.pumpAndSettle();
          expect(current().value, ('images', model));
          expect(
            tester
                .widget<ProductionImageSubmit>(
                  find.byType(ProductionImageSubmit),
                )
                .blockedReason,
            isNull,
          );
          expect(await session.close(), isTrue);
          final saved = (await service.shots.getShot(node.clipId!))!;
          expect(saved.providerId, 'images');
          expect(saved.modelId, model);
          expect(saved.ratio, 'auto');
          expect(saved.resolution, 'auto');
        }

        provider = provider.copyWith(enabled: false);
        await main.aiProviderDao.upsert(provider);
        await tester.pumpAndSettle();
        expect(current().items, isEmpty);
        expect(
          tester
              .widget<ProductionImageSubmit>(find.byType(ProductionImageSubmit))
              .blockedReason,
          isNotNull,
        );
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        await jobs.shutdown();
        await db.close();
        await main.close();
      }
    },
    variant: TargetPlatformVariant({
      TargetPlatform.windows,
      TargetPlatform.macOS,
      TargetPlatform.linux,
    }),
  );
}
