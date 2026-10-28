// 职责: 测试 BundledOfficialSkillsLoader — 验证官方目录从 asset 加载、按 name
//   取详情与附件、资源打包、未知 name 错误及整包内容与规格表不漂移。
// 关联文件:
//   lib/shared/services/bundled_official_skills.dart
//   lib/shared/services/agent_skill_import_parser.dart
//   assets/official_skills/
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:reveric/shared/services/bundled_official_skills.dart';

class _FileAssetBundle extends AssetBundle {
  _FileAssetBundle({this.missingAsset});

  final String? missingAsset;
  final loadedPaths = <String>[];

  @override
  Future<ByteData> load(String key) async {
    loadedPaths.add(key);
    if (key == missingAsset) {
      throw StateError('Missing test asset: $key');
    }
    final bytes = await File(key).readAsBytes();
    return ByteData.sublistView(bytes);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const loader = BundledOfficialSkillsLoader();
  late AssetBundle bundle;

  setUp(() {
    bundle = _FileAssetBundle();
  });

  test('list returns all official skills in sort_order', () async {
    final result = await loader.list(bundle);
    expect(result.agentSkills, hasLength(13));
    expect(
      result.agentSkills
          .where((skill) => skill.category == '剧本')
          .map((skill) => skill.name),
      ['剧本写作', '剧本制片'],
    );
    expect(result.agentSkills.map((skill) => skill.listingId).toList(), [
      for (final skill in result.agentSkills) skill.name,
    ]);
    expect(
      result.agentSkills.map((skill) => skill.version).toList(),
      bundledOfficialSkillSpecs.map((spec) => spec.version).toList(),
    );
  });

  test(
    'detail contains skill-relative references with their full content',
    () async {
      for (final spec in bundledOfficialSkillSpecs) {
        final detail = await loader.get(bundle, spec.name);
        final root = spec.assetPath.substring(
          0,
          spec.assetPath.lastIndexOf('/') + 1,
        );
        expect(detail.references, hasLength(spec.referenceAssetPaths.length));
        for (final reference in detail.references) {
          expect(reference.path, startsWith('references/'));
          final assetPath = '$root${reference.path}';
          expect(spec.referenceAssetPaths, contains(assetPath));
          expect(reference.content, await File(assetPath).readAsString());
        }
      }
    },
  );

  test('catalog summaries do not load reference bodies', () async {
    final trackingBundle = _FileAssetBundle();
    await loader.list(trackingBundle);
    expect(
      trackingBundle.loadedPaths,
      bundledOfficialSkillSpecs.map((spec) => spec.assetPath).toList(),
    );
  });

  test(
    'missing reference fails detail loading instead of returning a partial skill',
    () async {
      final spec = bundledOfficialSkillSpecs.firstWhere(
        (spec) => spec.referenceAssetPaths.isNotEmpty,
      );
      final missing = spec.referenceAssetPaths.last;
      await expectLater(
        loader.get(_FileAssetBundle(missingAsset: missing), spec.name),
        throwsA(isA<StateError>()),
      );
    },
  );

  test(
    'all official skill files are included in the Flutter asset bundle',
    () async {
      for (final spec in bundledOfficialSkillSpecs) {
        final packaged = await loader.get(rootBundle, spec.name);
        final onDisk = await loader.get(bundle, spec.name);
        expect(packaged.prompt, onDisk.prompt);
        expect(
          packaged.references.map((file) => (file.path, file.content)).toList(),
          onDisk.references.map((file) => (file.path, file.content)).toList(),
        );
      }
    },
  );

  test(
    'relative Markdown reference links resolve inside each installed skill',
    () async {
      final links = RegExp(r'\]\(([^)#]+)(?:#[^)]*)?\)');
      for (final spec in bundledOfficialSkillSpecs) {
        final detail = await loader.get(bundle, spec.name);
        final files = {
          'SKILL.md': detail.prompt,
          for (final reference in detail.references)
            reference.path: reference.content,
        };
        for (final file in files.entries) {
          for (final match in links.allMatches(file.value)) {
            final target = Uri.parse(match.group(1)!);
            if (target.hasScheme) {
              continue;
            }
            final resolved = Uri.parse(file.key).resolveUri(target).path;
            expect(
              files.keys,
              contains(resolved),
              reason: '${spec.name}: ${file.key} -> $target',
            );
          }
        }
      }
    },
  );

  test('get returns prompt and uses name as listing id', () async {
    final detail = await loader.get(bundle, '黄金三章');
    expect(detail.listingId, '黄金三章');
    expect(detail.name, '黄金三章');
    expect(detail.whenToUse, isNotEmpty);
    expect(detail.prompt, isNotEmpty);
    expect(detail.sortOrder, 5);
    // spec 上的 badge 要透传到详情，UI 才拿得到角标。
    expect(detail.badge, '推荐');
  });

  test(
    'screenplay skill exposes the pasted-material route and real write handoff',
    () async {
      final detail = await loader.get(bundle, '剧本写作');
      final references = {
        for (final reference in detail.references)
          reference.path: reference.content,
      };

      expect(detail.version, 3);
      expect(detail.whenToUse, contains('混合草稿'));
      expect(detail.prompt, contains('用户粘贴内容'));
      expect(detail.prompt, contains('不要求用户先分类'));
      expect(
        detail.prompt,
        contains('| 安排、拆分或合并场次 | [自然分场](references/episode-planning.md)'),
      );
      final adaptation = references['references/adaptation.md']!;
      expect(adaptation, contains('纯对白不凭空给台词配说话人'));
      expect(adaptation, contains('[改编决策](adaptation-decisions.md)'));
      expect(adaptation, contains('3. **写前检验因果**'));
      expect(adaptation, contains('4. **交付本次范围**'));
      expect(adaptation, contains('5. **写后回读**'));
      expect(
        references['references/source-analysis.md'],
        contains('尚未写入的事件仍是来源材料'),
      );
      expect(
        references['references/episode-planning.md'],
        contains('固定秒数不是机械切场依据'),
      );
      expect(
        references['references/episode-planning.md'],
        contains('时间、地点、参与人物、主要行动、进入与离开时的状态'),
      );
      expect(references['references/scene-writing.md'], contains('完整正文元素'));
      expect(references['references/scene-writing.md'], contains('写入责任'));
      expect(
        references['references/scene-writing.md'],
        contains('不因要求写正文就默认授权修改资料'),
      );
    },
  );

  test(
    'scene writing routes long exchanges and preserves source functions',
    () async {
      final detail = await loader.get(bundle, '剧本写作');
      final scene = detail.references
          .singleWhere((ref) => ref.path == 'references/scene-writing.md')
          .content;
      expect(scene, contains('人物辨识度与能力、选择动机、情绪积累和观众获知时机'));
      expect(scene, contains('[改编取舍](adaptation-decisions.md)'));
      expect(scene, contains('长对话、屏幕聊天占主体或同功能问答反复时'));
      expect(
        scene,
        contains('读取 [场景手艺](scene-craft.md) 和 [对白修订](dialogue.md)'),
      );
      expect(scene, contains('按信息、策略、关系或行动机会的变化组织交流'));
      expect(scene, contains('关键措辞、发送顺序、时间戳和误读依据'));
      expect(scene, contains('不默认改成现场口述或画外音'));
      expect(scene, contains('有功能的慢场和有效长消息'));
      expect(scene, contains('意外空正文或重复正文'));
      expect(scene, contains('相对日期'));
      expect(scene, contains('新增且需追踪的重要人物、地点和物件'));
      expect(scene, contains('实际场次路径交调用方'));
      expect(scene, contains('不因此扩大写手权限'));
      expect(scene, contains('不因要求写正文就默认授权修改资料'));
      expect(scene, contains('不硬造对手'));
      expect(scene, contains('保留未改元素 ID'));
      expect(scene, contains('区分发声、独占动作与可重叠部分'));
    },
  );

  test(
    'prop selection follows function rather than a closed evidence list',
    () async {
      final detail = await loader.get(bundle, '剧本写作');
      for (final path in ['source-analysis.md', 'adaptation-decisions.md']) {
        final content = detail.references
            .singleWhere((ref) => ref.path == 'references/$path')
            .content;
        expect(content, contains('重要行动、关键操作、信息呈现或传递、人物能力或选择'));
        expect(content, contains('需要识别、复用或连续追踪'));
        expect(content, contains('普通物件不因日常而排除'));
        expect(content, contains('不把所有名词建档'));
        expect(content, contains('计划或提及的候选不证明已持有或使用'));
        expect(content, isNot(contains('只有承担证据')));
        expect(content, isNot(contains('道具只追踪')));
      }
    },
  );

  test('H3 defaults to Chinese prose without changing its fixed syntax', () async {
    final detail = await loader.get(bundle, '剧本制片');
    final h3 = detail.references
        .singleWhere((ref) => ref.path == 'references/minimax-h3-prompts.md')
        .content;

    expect(
      h3,
      isNot(contains('正文、字段名和镜头标记全部写英文')),
      reason:
          'H3 prose must be readable/editable in Chinese, not forced English.',
    );
    expect(h3, contains('正文默认使用中文'));
    expect(h3, contains('对白、歌词和画面中可见的文字逐字保留原文'));
    for (final obsolete in ['一段英文', '句英文', '英文词', '350–500']) {
      expect(h3, isNot(contains(obsolete)), reason: obsolete);
    }
    expect(detail.version, 3);
    expect(h3, contains('中文适配'));
    expect(h3, contains('不代表中文与英文的成片质量等价'));
    expect(h3, contains('`summary`：用中文'));
    expect(h3, contains('`detailed_description`：先用中文'));
    for (final source in [
      'https://platform.minimaxi.com/docs/api-reference/video-generation-v2-create',
      'https://github.com/MiniMax-AI/MiniMax-H3/tree/main/skills/h3-prompt-writing',
      'VIDEO_PROMPT_WRITING_GUIDE_base_en.md',
      'VIDEO_PROMPT_WRITING_GUIDE_ref_en.md',
    ]) {
      expect(h3, contains(source));
    }
    for (final syntax in [
      'For the target video, at 0.00 seconds into the target video,',
      '(from [Shot 1]) is fully referenced.',
      'How the reference pictures align with the target video —',
      '(from Shot 1) aligns with the 0.00-second mark of the target video;',
      '(from Shot N) aligns with the S.SS-second mark of the target video.',
      '[Shot N] At MM:SS.mmm, the camera cuts to',
      '切点严格递增，且落在生成时长内',
      '<Subject N>',
      '(S1)',
      '<d>[Chinese]',
      '<scenetrans>',
      '<cutoff>',
      '[reference generation]',
      '[keyframe completion + reference generation]',
      'fully_preserved',
      'partially_preserved',
      'attribute_transfer',
      'weak_reference',
      'fully_copy',
      'partially_copy',
      'reference',
      'N/A',
    ]) {
      expect(h3, contains(syntax), reason: syntax);
    }
    expect(h3, contains('模式按实际绑定的输入判断，不按计划判断'));
    expect(h3, contains('不代表实际已绑定'));
  });

  test(
    'H3 keyframe and full-reference examples keep Chinese field bodies',
    () async {
      final detail = await loader.get(bundle, '剧本制片');
      final h3 = detail.references
          .singleWhere((ref) => ref.path == 'references/minimax-h3-prompts.md')
          .content;
      final blocks = RegExp(
        r'```text\n([\s\S]*?)\n```',
      ).allMatches(h3).map((match) => match.group(1)!).toList();
      final keyframe = blocks.singleWhere(
        (block) => block.startsWith('For the target video,'),
      );
      final fullReferenceBlocks = blocks.where(
        (block) => block.startsWith('subject_definitions:'),
      );
      expect(
        fullReferenceBlocks,
        hasLength(1),
        reason: 'Full-reference mode needs a readable six-field example.',
      );
      final fullReference = fullReferenceBlocks.single;
      final expectedFields = [
        [
          'integrated_multimodal_description',
          'overall_soundscape',
          'non_diegetic_music',
        ],
        [
          'subject_definitions',
          'summary',
          'retention_analysis',
          'detailed_description',
          'overall_soundscape',
          'non_diegetic_music',
        ],
      ];
      final examples = [keyframe, fullReference];
      for (var i = 0; i < examples.length; i++) {
        final fields = RegExp(
          r'^([a-z_]+): ',
          multiLine: true,
        ).allMatches(examples[i]).toList();
        expect(fields.map((field) => field.group(1)), expectedFields[i]);
        for (var j = 0; j < fields.length; j++) {
          final field = fields[j];
          final end = j + 1 < fields.length
              ? fields[j + 1].start
              : examples[i].length;
          final body = examples[i]
              .substring(field.end, end)
              .trim()
              .replaceAll(RegExp(r'<ref [^>]+/>'), '')
              .replaceAll(RegExp(r'<d>.*?</d>'), '');
          expect(
            body == 'N/A' || RegExp(r'[\u4e00-\u9fff]').hasMatch(body),
            isTrue,
            reason:
                '${field.group(1)} needs Chinese prose beyond labels/dialogue.',
          );
          final narrative = body.replaceAll(
            RegExp(r'At \d{2}:\d{2}\.\d{3}, the camera cuts to '),
            '',
          );
          expect(
            RegExp(r'[A-Za-z]+(?:[ ,\n]+[A-Za-z]+){7,}').hasMatch(narrative),
            isFalse,
            reason: '${field.group(1)} must not retain long English narration.',
          );
        }
        expect(examples[i], contains('右手食指'));
        expect(examples[i], contains('钥匙留在原处'));
        expect(examples[i], contains('<d>[Chinese] 你真的要走？</d>'));
        expect(examples[i], contains('[Shot 1]'));
        expect(
          examples[i],
          contains('[Shot 2] At 00:04.000, the camera cuts to '),
        );
        expect(
          examples[i],
          contains('[Shot 3] At 00:06.500, the camera cuts to '),
        );
        expect(
          examples[i],
          contains(RegExp(r'<ref input_id="[^"]+" label="[^"]+" />')),
        );
      }
      expect(fullReference, contains('<Subject 1>'));
      expect(fullReference, contains('[reference generation]'));
      expect(
        fullReference,
        contains(
          '画内的 <Subject 2> 是三十多岁男子，声音低沉疲惫 (S1)，'
          '放慢语速问：<d>[Chinese] 你真的要走？</d>',
        ),
      );
      expect(
        fullReference,
        contains('<Subject 3> — [Shot 1]、[Shot 2]、[Shot 3]，fully_preserved'),
        reason: 'Shot crops do not discard the defined room-reference role.',
      );
    },
  );

  test(
    'production requires a shootable plan before writing and readback',
    () async {
      final detail = await loader.get(bundle, '剧本制片');
      final production = detail.references
          .singleWhere((ref) => ref.path == 'references/production.md')
          .content;
      expect(
        detail.prompt,
        contains('原文事项 → 可拍镜头计划 → 按目标模型编写 → 逐 Shot 核对 → 保存回读'),
      );
      final split = production
          .split('## 从场次拆分镜')
          .last
          .split('## 先把制作依赖排清楚')
          .first;
      var previous = -1;
      for (final stage in ['可拍镜头计划', '按目标模型编写', '逐 Shot 核对', '回读']) {
        final position = split.indexOf(stage);
        expect(
          position,
          greaterThan(previous),
          reason: 'Missing/out-of-order $stage',
        );
        previous = position;
      }
      for (final requirement in [
        '观众',
        '景别',
        '机位',
        '画内',
        '起点',
        '可见过程',
        '停点',
        '声音',
        '约 5 秒',
        '软偏好',
        '合法整秒',
        '逐字对白',
        '已有同内容片段时原地修订',
      ]) {
        expect(split, contains(requirement), reason: requirement);
      }
      final review = production.split('## 写后核对').last.split('## 看结果再返修').first;
      expect(review, contains('逐 Shot'));
      expect(review, contains('画内'));
      expect(review, contains('屏幕'));
      expect(review, contains('duration_ms'));
      expect(review, contains('草稿'));
    },
  );

  test(
    'explicit H3 full-reference target stays a draft until inputs are bound',
    () async {
      final detail = await loader.get(bundle, '剧本制片');
      final production = detail.references
          .singleWhere((ref) => ref.path == 'references/production.md')
          .content;
      expect(production, contains('[MiniMax H3 提示词](minimax-h3-prompts.md)'));
      expect(production, contains('用户明确要求 H3 全参考'));
      expect(production, contains('实际绑定'));
      expect(production, contains('六字段'));
      expect(production, contains('参考待绑定'));
      expect(production, contains('完整可拍草稿'));
      expect(production, contains('不伪造 input_id'));
      expect(production, contains('不自动改成纯文生最终稿'));
      expect(production, contains('交付说明'));
      expect(production, contains('其他模型'));
      expect(production, contains('正常的无参考、首帧和首尾帧模式'));
      expect(production, contains('Shot N（…）'));
      expect(production, contains('【0-5s】'));
      expect(production, contains('不混入'));
    },
  );

  test(
    'screen-operation recipe has a timed six-field H3 prompt and visible ending',
    () async {
      final detail = await loader.get(bundle, '剧本制片');
      final recipes = detail.references
          .singleWhere((ref) => ref.path == 'references/shot-recipes.md')
          .content;
      expect(
        RegExp(
          r'^## [一二三四五]、(.+)$',
          multiLine: true,
        ).allMatches(recipes).map((match) => match.group(1)),
        ['两人对白与跨切声音', '交接物件与持有关系', '遮挡揭示与运镜参考', '按实际尾部状态续拍', '屏幕与设备操作'],
      );
      final recipe = recipes.split('## 五、屏幕与设备操作').last;
      expect(recipe, contains('反例'));
      expect(recipe, contains('可拍计划'));
      expect(recipe, contains('教学假设'));
      expect(recipe, contains('不代表实际已绑定'));
      expect(recipe, contains('替换'));
      expect(recipe, contains('验收'));
      final plan = recipe.split('### 可拍计划').last.split('### H3 全参考').first;
      final acceptance = recipe.split('### 验收').last;
      for (final section in [plan, acceptance]) {
        expect(section, contains('母巢轮廓被炮火逐渐遮没'));
        expect(section, contains('不另加母巢被摧毁'));
      }
      final total = RegExp(r'总长 (\d+) 秒').firstMatch(recipe);
      expect(total, isNotNull);
      final totalSeconds = int.parse(total!.group(1)!);
      expect(totalSeconds, 8);
      final prompt = RegExp(
        r'```text\n(subject_definitions:[\s\S]*?)\n```',
      ).firstMatch(recipe)?.group(1);
      expect(
        prompt,
        isNotNull,
        reason: 'Needs a complete H3 example, not a plot summary.',
      );
      final fields = RegExp(
        r'^([a-z_]+): ',
        multiLine: true,
      ).allMatches(prompt!).toList();
      expect(fields.map((field) => field.group(1)), [
        'subject_definitions',
        'summary',
        'retention_analysis',
        'detailed_description',
        'overall_soundscape',
        'non_diegetic_music',
      ]);
      for (var i = 0; i < fields.length; i++) {
        final end = i + 1 < fields.length ? fields[i + 1].start : prompt.length;
        final body = prompt.substring(fields[i].end, end).trim();
        expect(
          body == 'N/A' || RegExp(r'[\u4e00-\u9fff]').hasMatch(body),
          isTrue,
        );
      }
      final summary = prompt.substring(fields[1].end, fields[2].start);
      expect(summary, contains('母巢轮廓被炮火逐渐遮没'));
      final definitions = prompt.substring(fields[0].end, fields[1].start);
      final defined = RegExp(
        r'<Subject \d+>',
      ).allMatches(definitions).map((match) => match.group(0)).toSet();
      expect(defined, {'<Subject 1>', '<Subject 2>', '<Subject 3>'});
      expect(
        RegExp(
          r'<Subject \d+>',
        ).allMatches(prompt).map((match) => match.group(0)).toSet(),
        defined,
      );
      expect(
        RegExp(r'<ref input_id="…" label="[^"]+" />').allMatches(definitions),
        hasLength(3),
      );
      final retention = prompt.substring(fields[2].end, fields[3].start);
      expect(
        retention,
        contains('<Subject 3> — [Shot 1]、[Shot 2]、[Shot 3]，fully_preserved'),
        reason:
            'Cropping does not discard the defined desk/light/material role.',
      );
      expect(
        retention,
        contains('<Subject 2> — [Shot 1]、[Shot 3]，partially_preserved'),
        reason: 'The game state changes rather than freezing its reference.',
      );
      final description = prompt.substring(fields[3].end, fields[4].start);
      final cuts = RegExp(
        r'\[Shot (\d+)\] At (\d{2}):(\d{2})\.(\d{3}), the camera cuts to ',
      ).allMatches(description).toList();
      expect(cuts.map((cut) => cut.group(1)), ['2', '3']);
      final times = cuts
          .map(
            (cut) =>
                int.parse(cut.group(2)!) * 60 +
                int.parse(cut.group(3)!) +
                int.parse(cut.group(4)!) / 1000,
          )
          .toList();
      expect(times, [3.0, 6.0]);
      var previous = 0.0;
      for (final time in times) {
        expect(time, greaterThan(previous));
        expect(time, lessThan(totalSeconds));
        previous = time;
      }
      final shots = [
        description.substring(0, cuts[0].start),
        description.substring(cuts[0].end, cuts[1].start),
        description.substring(cuts[1].end),
      ];
      expect(shots[0], contains('[Shot 1]'));
      for (final visible in ['屏幕', '特写', '边框', '显示区域', '十二艘人类巡洋舰', '虫族母巢']) {
        expect(shots[0], contains(visible));
      }
      final barrage = shots[0].indexOf('持续集火');
      final obscuredBase = shots[0].indexOf('母巢轮廓被炮火逐渐遮没');
      expect(barrage, greaterThanOrEqualTo(0));
      expect(obscuredBase, greaterThan(barrage));
      for (final operation in [
        '手部',
        '键盘',
        'TrackPoint',
        'G、H、B',
        '输入',
        '"GG"',
      ]) {
        expect(shots[1], contains(operation));
      }
      for (final ending in ['屏幕', '可读', '"GG"', '游戏结束', '保持']) {
        expect(shots[2], contains(ending));
      }
      for (final forbidden in [
        'Shot 1（',
        '【0-5s】',
        '首帧：',
        '结束状态：',
        '可拍计划',
        '验收',
        '待绑定',
        'Enter',
        '<d>',
        '(S1)',
      ]) {
        expect(prompt, isNot(contains(forbidden)), reason: forbidden);
      }
      expect(recipe, contains('精确'));
      expect(recipe, contains('不保证'));
    },
  );

  test('badge from the spec table reaches the summary list', () async {
    final result = await loader.list(bundle);
    final badged = {
      for (final skill in result.agentSkills)
        if (skill.badge != null && skill.badge!.isNotEmpty)
          skill.name: skill.badge,
    };
    expect(badged, {
      for (final spec in bundledOfficialSkillSpecs)
        if (spec.badge != null && spec.badge!.isNotEmpty) spec.name: spec.badge,
    });
  });

  test('get rejects an unknown bundled skill name', () async {
    await expectLater(
      loader.get(bundle, '不存在的技能'),
      throwsA(
        isA<ArgumentError>()
            .having((e) => e.name, 'name', 'listingId')
            .having((e) => e.invalidValue, 'invalidValue', '不存在的技能'),
      ),
    );
  });

  // ── 规格表守卫 ──────────────────────────────────────────────────────────
  //
  // hash 守卫校验内容指纹，目录守卫检查资源登记；它们不判断发布状态。
  // 按 AGENTS.md 核实当前技能版本是否发布，再决定递增还是合并开发修改。
  // 保留版本号不会触发自动升级，须同步 Debug 数据库中已有的官方安装快照。

  test('asset content matches the hash registered in the spec table', () async {
    final drifted = <String>[];
    for (final spec in bundledOfficialSkillSpecs) {
      final bytes = BytesBuilder()
        ..add(await File(spec.assetPath).readAsBytes());
      final references = [...spec.referenceAssetPaths]..sort();
      for (final assetPath in references) {
        bytes.add(utf8.encode('\u0000$assetPath\u0000'));
        bytes.add(await File(assetPath).readAsBytes());
      }
      final actual = sha256.convert(bytes.takeBytes()).toString();
      if (actual != spec.contentHash) {
        drifted.add(
          '${spec.name}: spec=${spec.contentHash} actual=$actual '
          '(current version=${spec.version})',
        );
      }
    }

    expect(
      drifted,
      isEmpty,
      reason:
          '以下打包技能的内容与规格表登记的 hash 不一致：\n${drifted.join('\n')}\n\n'
          '如果你确实改了技能内容，请在 lib/shared/services/bundled_official_skills.dart '
          '中按 AGENTS.md 的发布状态规则处理：\n'
          '  1. 核对实际发布记录和标签代码；当前版本已发布才递增 version，'
          '未发布则保持版本号\n'
          '  2. 把 contentHash 更新为上面的 actual 值，并更新 updatedAt\n'
          '  3. 保持版本号时，用 SQLite skill 同步 Debug 数据库中已有的官方安装'
          '快照、附件和相关内容指纹，并查询验证；未安装则无需更新\n'
          'hash 覆盖主文件和按路径排序的所有附件；测试不能代替发布状态核查。',
    );
  });

  test('spec table and asset directory do not drift', () async {
    final onDisk = Directory(bundledOfficialSkillsAssetDir)
        .listSync(recursive: true)
        .whereType<File>()
        .map((file) => file.path)
        .toSet();
    final inSpec = {
      for (final spec in bundledOfficialSkillSpecs) spec.assetPath,
      for (final spec in bundledOfficialSkillSpecs) ...spec.referenceAssetPaths,
    };
    // 技能内容都必须进入规格表。
    expect(
      onDisk.difference(inSpec),
      isEmpty,
      reason: '这些文件在 assets/official_skills/ 下但未登记主文件或附件。',
    );
    // 规格表有、目录里没有 → 运行时 loadString 会抛错。
    expect(inSpec.difference(onDisk), isEmpty, reason: '这些技能资源已登记但文件不存在。');
  });

  test('spec table sort_order and names are unique and contiguous', () {
    expect(
      bundledOfficialSkillSpecs.map((spec) => spec.sortOrder).toList(),
      List.generate(bundledOfficialSkillSpecs.length, (index) => index),
      reason: 'sortOrder 必须从 0 连续递增，且与规格表顺序一致。',
    );
    expect(
      bundledOfficialSkillSpecs.map((spec) => spec.name).toSet(),
      hasLength(bundledOfficialSkillSpecs.length),
      reason: 'name 是官方技能的稳定身份，不能重复。',
    );
  });
}
