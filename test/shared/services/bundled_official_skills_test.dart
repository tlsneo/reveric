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
