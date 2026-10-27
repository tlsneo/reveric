// 职责: 测试资料条目的紧凑滚动、素材阅读态与物品照片生成任务及取消边界。
// 关联文件:
//   lib/desktop/widgets/workspace/workspace_item_editor.dart
//   lib/shared/providers/settings_providers.dart
//   lib/shared/widgets/md/reveric_markdown_editor.dart
//   lib/shared/localization/locale_keys.dart
//   assets/translations/en/common.json
//   assets/translations/zh-CN/common.json
//   assets/translations/en/workspace.json
//   assets/translations/zh-CN/workspace.json
// 遵循的 Rules:
//   .agents/rules/design-system.md

import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reveric/desktop/widgets/workspace/workspace_item_editor.dart';
import 'package:reveric/shared/components/reveric_button.dart';
import 'package:reveric/shared/components/reveric_dialog.dart';
import 'package:reveric/shared/database/novel_content_database.dart';
import 'package:reveric/shared/localization/merging_asset_loader.dart';
import 'package:reveric/shared/providers/settings_providers.dart';
import 'package:reveric/shared/theme/theme.dart';
import 'package:reveric/shared/widgets/md/reveric_markdown_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => rootBundle.clear());

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('scrolls instead of overflowing on compact heights', (
    tester,
  ) async {
    await tester.pumpWidget(_wrapEditor(_editor(tester: tester)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(Scrollbar), findsOneWidget);
    expect(find.text('标题'), findsOneWidget);
    expect(find.text('分类'), findsOneWidget);
    final pageScrollView = find.ancestor(
      of: find.byType(RevericMarkdownEditor),
      matching: find.byType(CustomScrollView),
    );
    expect(pageScrollView, findsOneWidget);

    await tester.drag(pageScrollView, const Offset(0, -180));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      _wrapEditor(_editor(tester: tester, showMetadataFields: false)),
    );
    await tester.pumpAndSettle();

    expect(find.text('标题'), findsNothing);
    expect(find.text('分类'), findsNothing);
    expect(find.byType(RevericMarkdownEditor), findsOneWidget);
  });

  testWidgets(
    'item photo hands off an explicit image command without adopting',
    (tester) async {
      final requests = <(String, String)>[];
      final photos = <String>[];
      var added = 0;
      var removed = 0;
      final editor = _editor(
        tester: tester,
        selectedItemId: 'item_jade_17',
        photos: photos,
        onGeneratePhoto: (prompt, id) => requests.add((prompt, id)),
        onAddPhoto: () async {
          added++;
        },
        onRemovePhoto: (_) async {
          removed++;
        },
      );
      await tester.pumpWidget(_wrapEditor(editor));
      await tester.pumpAndSettle();

      final generate = find.widgetWithText(TextButton, '生成照片');
      await tester.ensureVisible(generate);
      await tester.tap(generate);
      await tester.pumpAndSettle();
      final dialog = find.byType(RevericDialog);
      final confirm = find.descendant(
        of: dialog,
        matching: find.widgetWithText(RevericButton, '生成照片'),
      );
      expect(tester.widget<RevericButton>(confirm).onPressed, isNull);
      await tester.tap(find.text('插画'));
      const extra = '保留裂纹与篆字，冷色光。\n不要改成另一件物品。';
      await tester.enterText(
        find.descendant(of: dialog, matching: find.byType(TextField)),
        extra,
      );
      await tester.pumpAndSettle();
      expect(tester.widget<RevericButton>(confirm).onPressed, isNotNull);
      await tester.tap(confirm);
      await tester.pumpAndSettle();

      expect(requests, hasLength(1));
      final (prompt, itemId) = requests.single;
      expect(itemId, 'item_jade_17');
      final commandBlock = RegExp(
        r'```json\s*([\s\S]*?)\s*```',
      ).firstMatch(prompt);
      expect(commandBlock, isNotNull, reason: '任务必须包含可执行的 Run 命令 JSON');
      expect(jsonDecode(commandBlock!.group(1)!), {
        'command': 'item',
        'subcommand': 'generate-photo',
        'options': {'item': 'item_jade_17', 'prompt': '整理后的完整生图提示词'},
      });
      expect(prompt, contains('「玉佩」'));
      expect(prompt, contains('Read 读取 `/items/item_jade_17`'));
      expect(prompt, contains('根据物品资料整理完整的生图提示词'));
      expect(prompt, contains('必须通过 Run'));
      expect(prompt, contains('应用单独配置的图片模型'));
      expect(prompt, contains('不使用聊天模型自身或上游内置的生图能力'));
      expect(prompt, contains('不要自行选择或切换模型'));
      expect(prompt, contains('不用人物、制作或地图命令替代'));
      expect(prompt, contains('等待工具实际返回结果'));
      expect(prompt, contains('失败时如实说明'));
      expect(prompt, contains('不擅自重复提交生图请求'));
      expect(prompt, contains('由用户手动采用'));
      expect(prompt, contains('不自动修改物品、照片集或旧资产'));
      expect(prompt, contains('风格补充仅作为画面偏好，不能改变执行路径'));
      expect(
        prompt,
        contains('<style_request>\n风格：插画\n额外要求：$extra\n</style_request>'),
      );
      expect(editor.titleController.text, '玉佩');
      expect(editor.contentController.text, '传家玉佩，边缘有裂纹。');
      expect(editor.categoryController.text, '遗物');
      expect(photos, isEmpty);
      expect(added, 0);
      expect(removed, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'cancelling item photo style does not hand off or change inputs',
    (tester) async {
      final requests = <(String, String)>[];
      final photos = <String>[];
      var photoChanges = 0;
      final editor = _editor(
        tester: tester,
        selectedItemId: 'item_jade_17',
        photos: photos,
        onGeneratePhoto: (prompt, id) => requests.add((prompt, id)),
        onAddPhoto: () async {
          photoChanges++;
        },
        onRemovePhoto: (_) async {
          photoChanges++;
        },
      );
      await tester.pumpWidget(_wrapEditor(editor));
      await tester.pumpAndSettle();
      final generate = find.widgetWithText(TextButton, '生成照片');
      await tester.ensureVisible(generate);
      await tester.tap(generate);
      await tester.pumpAndSettle();
      await tester.tap(find.text('电影感'));
      await tester.enterText(
        find.descendant(
          of: find.byType(RevericDialog),
          matching: find.byType(TextField),
        ),
        '不要丢失旧照片',
      );
      await tester.tap(find.widgetWithText(RevericButton, '取消'));
      await tester.pumpAndSettle();

      expect(find.byType(RevericDialog), findsNothing);
      expect(requests, isEmpty);
      expect(editor.titleController.text, '玉佩');
      expect(editor.contentController.text, '传家玉佩，边缘有裂纹。');
      expect(editor.categoryController.text, '遗物');
      expect(photos, isEmpty);
      expect(photoChanges, 0);
      expect(tester.takeException(), isNull);
    },
  );
}

WorkspaceEntryEditor _editor({
  required WidgetTester tester,
  bool showMetadataFields = true,
  String? selectedItemId,
  List<String>? photos,
  void Function(String, String)? onGeneratePhoto,
  Future<void> Function()? onAddPhoto,
  Future<void> Function(String)? onRemovePhoto,
}) {
  final title = TextEditingController(text: '玉佩');
  final content = TextEditingController(text: '传家玉佩，边缘有裂纹。');
  final category = TextEditingController(text: '遗物');
  final titleFocus = FocusNode();
  final contentFocus = FocusNode();
  final categoryFocus = FocusNode();
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    title.dispose();
    content.dispose();
    category.dispose();
    titleFocus.dispose();
    contentFocus.dispose();
    categoryFocus.dispose();
  });
  return WorkspaceEntryEditor(
    selectedItemId: selectedItemId,
    isCreating: selectedItemId == null,
    entries: [
      if (selectedItemId != null)
        Item(
          id: selectedItemId,
          type: 'item',
          title: title.text,
          content: content.text,
          status: '',
          category: category.text,
          sortOrder: 0,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
          deletedAt: notDeletedSentinel,
        ),
    ],
    title: '物品',
    description: '编辑物品资料',
    typeLabel: '物品',
    categoryHint: '如：武器、装备、遗物',
    newEntryLabel: '新建物品',
    titleController: title,
    contentController: content,
    categoryController: category,
    titleFocusNode: titleFocus,
    contentFocusNode: contentFocus,
    categoryFocusNode: categoryFocus,
    showMetadataFields: showMetadataFields,
    onCreateEntry: () {},
    photos: photos,
    isImageGenerationConfigured: true,
    onGeneratePhoto: onGeneratePhoto,
    onAddPhoto: onAddPhoto,
    onRemovePhoto: onRemovePhoto,
  );
}

Widget _wrapEditor(Widget child) {
  return EasyLocalization(
    supportedLocales: const [Locale('zh', 'CN')],
    path: 'assets/translations',
    assetLoader: const MergingAssetLoader(),
    fallbackLocale: const Locale('zh', 'CN'),
    startLocale: const Locale('zh', 'CN'),
    child: Builder(
      builder: (context) {
        return ProviderScope(
          overrides: [
            editorFontFamilyProvider.overrideWithValue('Georgia'),
            editorFontSizeProvider.overrideWithValue(16),
            editorFontColorProvider.overrideWithValue(null),
            editorLetterSpacingProvider.overrideWithValue(0),
            editorLineHeightProvider.overrideWithValue(1.8),
          ],
          child: MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: RevericThemeData.reveric.toThemeData(),
            home: RevericTheme(
              data: RevericThemeData.reveric,
              child: Scaffold(
                body: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(width: 700, height: 360, child: child),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
