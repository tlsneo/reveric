// 职责: 验证制片按角色选择现有图片并保存为真实生成输入，不复制图片或自动加入资产库。
// 关联文件:
//   lib/desktop/features/production/character_image_picker.dart
//   lib/desktop/features/production/upload.dart
//   lib/desktop/features/production/image_composer.dart
//   lib/desktop/features/production/composer.dart
//   lib/shared/services/production/generate_orchestrator.dart
// 遵循的 Rules:
//   .agents/rules/testing.md
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reveric/desktop/features/production/character_image_picker.dart';
import 'package:reveric/desktop/features/production/composer.dart';
import 'package:reveric/desktop/features/production/edit_session.dart';
import 'package:reveric/desktop/features/production/image_composer.dart';
import 'package:reveric/desktop/features/production/input_preview.dart';
import 'package:reveric/desktop/features/production/popover.dart';
import 'package:reveric/desktop/features/production/support.dart';
import 'package:reveric/desktop/features/production/upload.dart';
import 'package:reveric/shared/database/app_database.dart' as app;
import 'package:reveric/shared/database/novel_content_database.dart';
import 'package:reveric/shared/models/production/asset_content.dart';
import 'package:reveric/shared/models/production/media.dart';
import 'package:reveric/shared/models/video/request.dart';
import 'package:reveric/shared/providers/novel_providers.dart';
import 'package:reveric/shared/providers/production_images.dart';
import 'package:reveric/shared/services/image_library_service.dart';
import 'package:reveric/shared/services/novel_actions.dart';
import 'package:reveric/shared/services/novel_content.dart';
import 'package:reveric/shared/services/production/canvas_service.dart';
import 'package:reveric/shared/services/production/ffmpeg_runner.dart';
import 'package:reveric/shared/services/production/generate_orchestrator.dart';
import 'package:reveric/shared/services/production/image_generate_orchestrator.dart';
import 'package:reveric/shared/services/production/image_service.dart';
import 'package:reveric/shared/services/production/library_service.dart';
import 'package:reveric/shared/services/production/media_service.dart';
import 'package:reveric/shared/services/screenplay_service.dart';
import 'package:reveric/shared/services/storyboard/service.dart';
import 'package:reveric/shared/services/working_overlay.dart';
import 'package:reveric/shared/theme/theme.dart';
import '../../director/harness.dart';

const _path = 'character_reference_test';
final _platforms = TargetPlatformVariant({
  TargetPlatform.windows,
  TargetPlatform.macOS,
  TargetPlatform.linux,
});

Finder _tool(String icon) =>
    find.byWidgetPredicate((w) => w is ProductionToolButton && w.icon == icon);

Future<void> _settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 30)),
  );
  await tester.pumpAndSettle();
}

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  // 文件校验依次等待 open / length / close，需交替推进真实 IO 与 FakeAsync。
  for (var i = 0; i < 20 && finder.evaluate().isEmpty; i++) {
    await _settle(tester);
  }
  expect(finder, findsWidgets);
}

Future<void> _chooseHero(WidgetTester tester) async {
  await _settle(tester);
  await tester.tap(find.byKey(const ValueKey('hero')));
  await _settle(tester);
}

void main() {
  setUpAll(initializeDirectorTest);
  setUp(() => rootBundle.clear());

  testWidgets('picker searches characters, deduplicates images and cancels', (
    tester,
  ) async {
    final f = (await tester.runAsync(_Fixture.create))!;
    app.AssetRow? picked;
    var completed = 0;
    try {
      await tester.pumpWidget(
        f.wrap(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => productionRun(context, () async {
                picked = await pickProductionCharacterImage(context, f.service);
                completed++;
              }),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await _settle(tester);
      await tester.tap(find.text('Open'));
      await _settle(tester);
      expect(find.byKey(const ValueKey('deleted')), findsNothing);
      await tester.enterText(find.byType(TextField), 'alias');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await _settle(tester);
      expect(find.byKey(const ValueKey('hero')), findsOneWidget);
      expect(find.byKey(const ValueKey('other')), findsNothing);
      await tester.tap(find.text('Cancel'));
      await _settle(tester);
      expect(completed, 1);
      expect(picked, isNull);

      await tester.tap(find.text('Open'));
      await _chooseHero(tester);
      expect(
        find.byKey(const ValueKey('character-image-avatar')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('character-image-four-view')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('character-image-other-photo')),
        findsNothing,
      );
      expect(find.text('Four views'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await _settle(tester);
      expect(completed, 2);
      expect(picked, isNull);
      await f.expectUnchanged();
      expect(tester.takeException(), isNull);
    } finally {
      await f.dispose(tester);
    }
  }, variant: _platforms);

  testWidgets(
    'open photo list refreshes and handles empty or deleted character',
    (tester) async {
      final f = (await tester.runAsync(_Fixture.create))!;
      try {
        await tester.pumpWidget(
          f.wrap(
            Builder(
              builder: (context) => TextButton(
                onPressed: () =>
                    pickProductionCharacterImage(context, f.service),
                child: const Text('Open'),
              ),
            ),
          ),
        );
        await _settle(tester);
        await tester.tap(find.text('Open'));
        await _settle(tester);
        await tester.tap(find.byKey(const ValueKey('empty')));
        await _settle(tester);
        expect(
          find.text('No photos yet. Import or generate an image.'),
          findsOneWidget,
        );
        await (f.db.update(
          f.db.characterProfiles,
        )..where((t) => t.id.equals('empty'))).write(
          const CharacterProfilesCompanion(avatarAssetId: Value('avatar')),
        );
        await _settle(tester);
        expect(
          find.byKey(const ValueKey('character-image-avatar')),
          findsOneWidget,
        );
        expect(find.text('Avatar'), findsOneWidget);
        await (f.db.update(
          f.db.characterProfiles,
        )..where((t) => t.id.equals('empty'))).write(
          CharacterProfilesCompanion(deletedAt: Value(DateTime.now())),
        );
        await _settle(tester);
        expect(
          find.byKey(const ValueKey('character-image-avatar')),
          findsNothing,
        );
        expect(find.byType(GridView), findsNothing);
        await tester.tap(find.text('Cancel'));
        await _settle(tester);
        expect(tester.takeException(), isNull);
      } finally {
        await f.dispose(tester);
      }
    },
  );

  testWidgets('missing image is not returned as a reference', (tester) async {
    final f = (await tester.runAsync(_Fixture.create))!;
    app.AssetRow? picked;
    try {
      await tester.runAsync(
        () =>
            File('${f.root.path}/file_workspaces/work/four-view.png').delete(),
      );
      await tester.pumpWidget(
        f.wrap(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => productionRun(context, () async {
                picked = await pickProductionCharacterImage(context, f.service);
              }),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await _settle(tester);
      await tester.tap(find.text('Open'));
      await _chooseHero(tester);
      await tester.tap(find.byKey(const ValueKey('character-image-four-view')));
      await _settle(tester);
      expect(picked, isNull);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      await f.dispose(tester);
    }
  });

  testWidgets('audio-only input menu does not offer character images', (
    tester,
  ) async {
    final f = (await tester.runAsync(_Fixture.create))!;
    try {
      await tester.pumpWidget(
        f.wrap(
          Center(
            child: ProductionAddInputButton(
              service: f.service,
              types: const {'audio'},
              onPicked: (_) async => fail('Must not pick an image'),
            ),
          ),
        ),
      );
      await _settle(tester);
      await tester.tap(_tool(RevericIcons.add));
      await tester.pumpAndSettle();
      expect(find.text('Choose from character'), findsNothing);
      expect(find.text('Import'), findsOneWidget);
    } finally {
      await f.dispose(tester);
    }
  });

  for (final video in [false, true]) {
    for (final mention in [false, true]) {
      testWidgets(
        '${video ? 'video' : 'image'} ${mention ? '@' : '+'} attaches character asset to generation request',
        (tester) async {
          tester.view.physicalSize = const Size(1200, 900);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final f = (await tester.runAsync(_Fixture.create))!;
          final session = ProductionEditSession();
          try {
            final canvas = await f.service.ensureCanvas(f.episode);
            final node = video
                ? await f.service.addFree(canvas.id, overlay: f.overlay)
                : await f.service.addImage(canvas.id);
            final clip = (await f.service.shots.getShot(node.clipId!))!;
            await f.service.shots.apply(clip.id, {
              ...f.service.shots.snapshot(clip),
              'prompt': 'A person walking',
              'provider_id': video ? 'video' : 'image',
              'model_id': video
                  ? 'doubao-seedance-2-0-260128'
                  : 'local/image-model',
              'reference_mode': 'reference',
              'ratio': '16:9',
              'resolution': video ? '720p' : 'auto',
              'duration_ms': 5000,
            });
            await tester.pumpWidget(
              f.wrap(
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: 850,
                    child: video
                        ? ProductionComposer(
                            service: f.service,
                            node: node,
                            session: session,
                            path: _path,
                          )
                        : ProductionImageComposer(
                            service: f.service,
                            node: node,
                            session: session,
                            path: _path,
                          ),
                  ),
                ),
              ),
            );
            await _settle(tester);
            final assetId = mention ? 'avatar' : 'four-view';
            await tester.tap(
              _tool(mention ? RevericIcons.at : RevericIcons.add),
            );
            await _settle(tester);
            await tester.tap(find.text('Choose from character'));
            await _chooseHero(tester);
            await tester.tap(find.byKey(ValueKey('character-image-$assetId')));
            if (video) {
              await _waitFor(tester, find.text('Reference image'));
              await tester.tap(find.text('Reference image').last);
              await _settle(tester);
            } else {
              await _waitFor(tester, find.byType(ProductionInputTile));
            }
            expect(find.byType(ProductionInputTile), findsOneWidget);
            bool? saved;
            session.close().then((value) => saved = value);
            for (var i = 0; i < 20 && saved == null; i++) {
              await _settle(tester);
            }
            expect(saved, isTrue);
            final inputs = await f.service.draftInputs(node.id);
            expect(inputs, hasLength(1));
            expect(inputs.single.refType, ProductionInputType.asset);
            expect(inputs.single.refId, assetId);
            expect(inputs.single.role, VideoInputRole.reference_image);
            expect(inputs.single.sourceNodeId, isNull);
            await tester.runAsync(() async {
              if (video) {
                final preview = await ProductionGenerateOrchestrator().preview(
                  f.service,
                  node.id,
                );
                expect(preview.inputs.single.assetId, assetId);
                expect(
                  preview.inputs.single.file.path,
                  '${f.root.path}/file_workspaces/work/$assetId.png',
                );
                expect(preview.request.referenceSlots.single.assetId, assetId);
                if (mention) {
                  expect(preview.request.originalPrompt, contains('<ref'));
                }
              } else {
                final preview = await ProductionImageGenerateOrchestrator()
                    .preview(f.service, node.id);
                expect(preview.request.references.single.assetId, assetId);
                if (mention) {
                  expect(preview.request.originalPrompt, contains('<ref'));
                }
              }
            });
            expect(
              (await f.db.canvasDao.getNodesByCanvas(canvas.id)),
              hasLength(1),
            );
            expect(
              (await f.service.shots.getShot(node.clipId!))!.adoptedAssetId,
              isNull,
            );
            await f.expectUnchanged();
            expect(tester.takeException(), isNull);
          } finally {
            await f.dispose(tester);
          }
        },
        variant: _platforms,
      );
    }
  }
}

class _Fixture {
  _Fixture(this.root);
  final Directory root;
  final main = app.AppDatabase.forTest(NativeDatabase.memory());
  final db = NovelContentDatabase.forTest(NativeDatabase.memory());
  late final service = ProductionCanvasService(
    StoryboardService(db),
    MediaLibraryService(main, _ImageMedia(), root),
    'work',
  );
  late final overlay = WorkingOverlayService(
    db,
    NovelContentService(db),
    novelActionsService: NovelActionsService(main),
  );
  late final jobs = ImageTaskService(
    database: main,
    images: buildImageLibraryService(main),
    invoke: (_, _, _) => throw StateError('Must not call provider'),
    beforeCreate: (_, _, _) async {},
    beforeSubmit: (_) async {},
    recoverSources: () async {},
  );
  late final String episode;

  static Future<_Fixture> create() async {
    final f = _Fixture(
      await Directory.systemTemp.createTemp('character-reference-'),
    );
    await Directory(
      '${f.root.path}/file_workspaces/work',
    ).create(recursive: true);
    for (final id in ['avatar', 'four-view', 'other-photo']) {
      await File('${f.root.path}/file_workspaces/work/$id.png').writeAsBytes(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
        ),
      );
      await f.main.assetDao.insertAsset(
        app.AssetsCompanion.insert(
          id: id,
          type: 'image',
          name: Value(id),
          novelId: const Value('work'),
          purpose: 'photo',
          path: Value('file_workspaces/work/$id.png'),
          content: const Value(ImageAssetContent(mimeType: 'image/png')),
        ),
      );
    }
    await f.db
        .into(f.db.characterProfiles)
        .insert(
          CharacterProfilesCompanion.insert(
            id: 'hero',
            name: 'Hero',
            aliases: const Value(['alias']),
            avatarAssetId: const Value('avatar'),
            photos: const Value([
              SubjectPhoto(assetId: 'four-view', name: 'Four views'),
              SubjectPhoto(assetId: 'avatar', name: 'Headshot'),
            ]),
          ),
        );
    await f.db
        .into(f.db.characterProfiles)
        .insert(
          CharacterProfilesCompanion.insert(
            id: 'other',
            name: 'Other',
            photos: const Value([SubjectPhoto(assetId: 'other-photo')]),
          ),
        );
    await f.db
        .into(f.db.characterProfiles)
        .insert(CharacterProfilesCompanion.insert(id: 'empty', name: 'Empty'));
    await f.db
        .into(f.db.characterProfiles)
        .insert(
          CharacterProfilesCompanion.insert(
            id: 'deleted',
            name: 'Deleted',
            deletedAt: Value(DateTime.now()),
          ),
        );
    await f.main
        .into(f.main.aiProviders)
        .insert(
          app.AiProvidersCompanion.insert(
            id: 'image',
            name: 'Images',
            type: 'openai_compatible',
            enabled: const Value(true),
            apiKey: const Value('test'),
            imageModels: const Value(['local/image-model']),
          ),
        );
    await f.main
        .into(f.main.aiProviders)
        .insert(
          app.AiProvidersCompanion.insert(
            id: 'video',
            name: 'Videos',
            type: 'doubao',
            enabled: const Value(true),
            apiKey: const Value('test'),
            videoModels: const Value(['doubao-seedance-2-0-260128']),
          ),
        );
    f.episode = (await ScreenplayService(
      f.db,
    ).createInitialStructure()).episodeId;
    return f;
  }

  Widget wrap(Widget child) => ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(main),
      workingOverlayServiceProvider(_path).overrideWithValue(overlay),
      imageTaskServiceProvider.overrideWithValue(jobs),
    ],
    child: directorTestApp(child),
  );

  Future<void> expectUnchanged() async {
    final hero = (await db.characterProfileDao.getById('hero'))!;
    expect(hero.avatarAssetId, 'avatar');
    expect(hero.photos!.map((p) => p.assetId), ['four-view', 'avatar']);
    final assets = await main.select(main.assets).get();
    expect(assets, hasLength(3));
    expect(assets.where((a) => a.inLibrary), isEmpty);
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await jobs.shutdown();
    await db.close();
    await main.close();
    await tester.runAsync(() => root.delete(recursive: true));
  }
}

class _ImageMedia extends MediaService {
  _ImageMedia() : super(FfmpegRunner());
  @override
  Future<MediaInfo> probe(
    String path, {
    MediaCancellation? cancellation,
  }) async => const MediaInfo(
    duration: Duration.zero,
    width: 1024,
    height: 1024,
    frameRate: 0,
    hasVideo: true,
    hasAudio: false,
  );
}
