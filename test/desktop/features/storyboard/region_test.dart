// 职责: 验证 AI 拆分镜请求与点击不写入，以及列表刷新、删除确认和片段及画布节点的软删除。
// 关联文件:
//   lib/desktop/features/storyboard/region.dart
//   lib/shared/providers/storyboard.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:reveric/shared/components/reveric_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reveric/desktop/features/production/edit_session.dart';
import 'package:reveric/desktop/features/storyboard/region.dart';
import 'package:reveric/shared/database/app_database.dart';
import 'package:reveric/shared/database/novel_content_database.dart';
import 'package:reveric/shared/localization/merging_asset_loader.dart';
import 'package:reveric/shared/providers/novel_providers.dart';
import 'package:reveric/shared/providers/storyboard.dart';
import 'package:reveric/shared/services/novel_actions.dart';
import 'package:reveric/shared/services/novel_content.dart';
import 'package:reveric/shared/services/screenplay_service.dart';
import 'package:reveric/shared/services/storyboard/service.dart';
import 'package:reveric/shared/services/working_overlay.dart';
import 'package:reveric/shared/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => rootBundle.clear());
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    for (final family in ['Roboto', 'Georgia', 'Menlo', 'Ahem']) {
      await (FontLoader(family)
            ..addFont(rootBundle.load('assets/fonts/LXGWWenKai-Regular.ttf')))
          .load();
    }
  });
  testWidgets('AI split preserves clips; grouped shots refresh and delete', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1100, 800);
    addTearDown(tester.view.reset);
    final db = NovelContentDatabase.forTest(NativeDatabase.memory());
    final app = AppDatabase.forTest(NativeDatabase.memory());
    final screenplay = ScreenplayService(db);
    final initial = await screenplay.createInitialStructure();
    final root = (await db.screenplayDao.getRoot())!.id;
    final first = await screenplay.createScene(
      screenplayId: root,
      episodeId: initial.episodeId,
      title: '旧宅门外 · 雨夜',
    );
    final second = await screenplay.createScene(
      screenplayId: root,
      episodeId: initial.episodeId,
      title: '客厅 · 深夜',
    );
    final service = StoryboardService(db);
    final shot = await service.create(
      first,
      values: {
        'title': '门口的灯',
        'prompt': '夜雨落在青石阶上，女子停在门口。缓慢推进，保持人物正面中景。',
        'duration_ms': 5000,
      },
    );
    await service.create(
      first,
      values: {
        'title': '回望',
        'prompt':
            '参考 <ref input_id="media/portrait.png" label="白衣女子" /> 的形象。她转身望向街道，雨水从伞沿滴落。',
        'duration_ms': 4000,
      },
    );
    await service.create(
      second,
      values: {
        'title': '来信',
        'prompt': '镜头从桌上的信封抬起，男子在昏暗灯光下低声说：“你终于回来了。”',
        'duration_ms': 6000,
      },
    );
    final overlay = WorkingOverlayService(
      db,
      NovelContentService(db),
      novelActionsService: NovelActionsService(app),
    );
    final now = DateTime(2026);
    final novel = Novel(
      id: 'work',
      title: '雨夜归人',
      authorName: '',
      description: '',
      status: 'in_progress',
      type: 'original',
      contentKind: 'screenplay',
      contentDatabasePath: 'test',
      wordCount: 0,
      draft: false,
      category: '',
      tags: const [],
      createdAt: now,
      updatedAt: now,
      deletedAt: notDeletedSentinel,
    );
    final boundary = GlobalKey();
    final requests = <String>[];
    final sceneActions = ValueNotifier<ProductionSceneActions?>(
      ProductionSceneActions(
        ask: requests.add,
        openDirector: (_, {canvas}) async {},
      ),
    );
    addTearDown(sceneActions.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(app),
          novelContentDatabaseProvider('test').overrideWithValue(db),
          storyboardServiceProvider('test').overrideWithValue(service),
          workingOverlayServiceProvider('test').overrideWithValue(overlay),
        ],
        child: EasyLocalization(
          supportedLocales: const [Locale('en')],
          path: 'assets/translations',
          assetLoader: const MergingAssetLoader(),
          startLocale: const Locale('en'),
          fallbackLocale: const Locale('en'),
          child: Builder(
            builder: (context) => RevericTheme(
              data: RevericThemeData.reveric,
              child: MaterialApp(
                theme: RevericThemeData.reveric.toThemeData(
                  fontFamily: 'Roboto',
                ),
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                home: Scaffold(
                  body: RepaintBoundary(
                    key: boundary,
                    child: ColoredBox(
                      color: RevericThemeData.reveric.colors.canvas,
                      child: ValueListenableBuilder<ProductionSceneActions?>(
                        valueListenable: sceneActions,
                        builder: (_, actions, _) => StoryboardRegion(
                          novel: novel,
                          sceneActions: actions,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('门口的灯'), findsOneWidget);
    final clipsBeforeSplit = (await db.select(db.productionClips).get())
        .map((row) => row.toJson())
        .toList();
    final splitButtons = find.widgetWithText(RevericButton, 'Split with AI');
    expect(splitButtons, findsNWidgets(2));
    expect(requests, isEmpty);
    for (var i = 0; i < 2; i++) {
      await tester.ensureVisible(splitButtons.at(i));
      await tester.tap(splitButtons.at(i));
      await tester.pumpAndSettle();
      expect(requests, hasLength(i + 1));
      expect(
        (await db.select(db.productionClips).get()).map((row) => row.toJson()),
        clipsBeforeSplit,
      );
    }
    for (var i = 0; i < requests.length; i++) {
      final request = requests[i];
      final sceneId = [first, second][i];
      expect(
        request,
        allOf(
          contains('/scenes/$sceneId'),
          contains('/scenes/$sceneId/elements'),
          contains('完整正文'),
          contains('真实角色、地点'),
          contains('当前集已有分镜'),
        ),
        reason: 'Split scope must include the full scene and real resources',
      );
      expect(
        request,
        allOf(
          contains('「AI 拆分镜」'),
          contains('references/splitting.md'),
          contains('分镜指南、模型能力、视频提示词'),
          isNot(contains('「剧本制片」')),
          contains('剧本工具使用规范'),
          contains('分镜与媒体节点附件'),
          contains('查询实际型号与渠道能力'),
        ),
        reason:
            'Use the independent splitting method and existing operation contracts',
      );
      expect(
        request,
        allOf([
          contains('H3'),
          contains('已识别的渠道别名'),
          contains('minimax-h3-prompts.md'),
          contains('实际绑定输入'),
          contains('未选模型且未指定目标时，也加载 minimax-h3-prompts.md，默认按 H3 格式写草稿'),
          contains('不自动填写供应商或模型'),
          contains('不声称配置就绪'),
          matches(r'已选或明确指定的非 H3 模型.*对应格式.*不擅自切换'),
          isNot(contains('按其中的 Shot 格式逐镜头编写')),
        ]),
        reason: 'Default only the draft format, never override another model',
      );
      expect(
        request,
        allOf(
          contains('每个可独立生成的视频片段优先约 5 秒'),
          contains('不是场次或每行对白的硬性配额'),
          contains('合法时长'),
          contains('逐字对白、完整动作阶段和前后连续性'),
          contains('合理切点拆开或说明延长原因'),
          contains('不加速、删戏、重演动作或机械逐行切分'),
        ),
        reason: 'Short clips remain subordinate to complete dramatic content',
      );
      expect(
        request,
        allOf([
          matches(r'真实输出 fps.*帧数约束.*已知时'),
          matches(r'换算帧数与时间.*切点.*计划总长'),
          contains('未知标明未校准'),
          contains('输入或时间轴 fps 不等于输出 fps'),
          contains('不猜固定帧率、帧数或步长'),
          contains('合法整秒提交'),
          matches(r'不兼容时说明差异.*不写不受支持的小数秒'),
          matches(r'不声称 API.*传递帧数或控制精确帧'),
        ]),
        reason: 'Frame arithmetic is evidence-based planning, not API control',
      );
      expect(
        request,
        allOf(
          contains('保留原剧本文本和未改内容'),
          contains('复用已有同内容条目及真实引用，不重复新增'),
          contains('关联本场'),
          contains('回读核对场次归属、顺序、计划时长和相邻起止状态'),
          contains('只做拆分草稿，不自动生成媒体'),
        ),
        reason: 'Protect source material and read back only the scoped drafts',
      );
    }
    await tester.ensureVisible(splitButtons.first);
    // Restore the original no-action fixture for its narrow-layout regression.
    sceneActions.value = null;
    await tester.pumpAndSettle();
    expect(splitButtons, findsNothing);
    expect(
      (await db.select(db.productionClips).get()).map((row) => row.toJson()),
      clipsBeforeSplit,
    );
    await service.apply(shot.id, {...service.snapshot(shot), 'title': '雨中的门灯'});
    await tester.pumpAndSettle();
    expect(find.text('雨中的门灯'), findsOneWidget);
    expect(find.text('门口的灯'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.runAsync(() async {
      final image =
          await (boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary)
              .toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(
        '/tmp/reveric-storyboard-region.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
    tester.view.physicalSize = const Size(620, 800);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await (db.update(
      db.productionClips,
    )..where((t) => t.id.equals(shot.id))).write(
      const ProductionClipsCompanion(
        adoptedAssetId: Value('media/retained.mp4'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('More actions').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Media files and generation history will be kept.'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(RevericButton, 'Cancel'));
    await tester.pumpAndSettle();
    expect(await service.getShot(shot.id), isNotNull);
    expect(find.text('雨中的门灯'), findsOneWidget);

    await tester.tap(find.byTooltip('More actions').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(RevericButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.text('雨中的门灯'), findsNothing);
    expect(find.text('回望'), findsOneWidget);
    expect(await service.getShot(shot.id), isNull);
    final deleted = await (db.select(
      db.productionClips,
    )..where((t) => t.id.equals(shot.id))).getSingle();
    expect(deleted.deletedAt, isNot(notDeletedSentinel));
    expect(deleted.adoptedAssetId, 'media/retained.mp4');
    final nodes = await (db.select(
      db.canvasNodes,
    )..where((t) => t.refId.equals(shot.id))).get();
    expect(nodes, isNotEmpty);
    expect(nodes.every((node) => node.deletedAt != notDeletedSentinel), isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await db.close();
    await app.close();
  }, timeout: const Timeout(Duration(minutes: 2)));
}
