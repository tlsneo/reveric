# 第三轮实施结果：可拍分镜与 H3 全参考成稿

## 范围

仅修改获准的五份产品／测试文件，另新增本报告；前两轮已提交内容不重做，远程模型目录规划与原有任务规划改动保持不动。未递归委派、提交、切换模型或供应商。

1. `assets/official_skills/screenplay-production/SKILL.md`：将原文事项→可拍计划→目标模型格式→逐 Shot 核对→保存回读接入现有路径，并路由屏幕／设备操作配方；frontmatter 原始内容不变。
2. `assets/official_skills/screenplay-production/references/production.md`：在原拆分步骤和写后核对中落实观众所见变化、景别机位与画内主体、动作起止与可见过程、切镜／具体运镜、声音和合法总时长。约 5 秒为软偏好；计划不是新资源或最终 prompt 外壳。明确 H3 六字段／实际输入及全参考未绑定时的完整草稿与 prompt 外状态说明，保留其他模型和正常输入模式。
3. `assets/official_skills/screenplay-production/references/shot-recipes.md`：原四配方全文按字节保留，只追加第五例。反例→可拍计划→H3 六字段中文教学成稿→验收；教学输入与省略号引用明确不是实际绑定。示例总长 8 秒，03.000 切手部键盘、06.000 回到可读屏幕，保留十二艘人类战列巡洋舰／虫族母巢／G、H、B 间 TrackPoint／输入 GG／游戏结束状态，不新增发送或人声，不保证 UI、计数与文字保真。
4. `lib/shared/services/bundled_official_skills.dart`：只改剧本制片的 version、contentHash、updatedAt，其余注册信息和代码不变。
5. `test/shared/services/bundled_official_skills_test.dart`：在真实 loader 边界新增 3 项回归，检查流程与时长／取景要求、全参考就绪边界、真实例子的字段／主体／切点／画内结尾／原配方保留。原 17 项仅将剧本制片 version 期待由 2 改为 3，其余全文不变。

## TDD 与实际验证

先写三项新回归并运行整文件 RED，之后才改 Skill 文案与注册元数据；不是由版本差异制造失败。

| 验证 | 结果 | 完整日志 |
|---|---|---|
| 官方加载 RED | exit 1；原 17 通过、新 3 失败 | `/tmp/reveric-h3-shot-quality-red.log` |
| 官方加载 GREEN | exit 0；20/20 通过 | `/tmp/reveric-h3-shot-quality-official.log` |
| 原同步测试（未修改） | exit 0；15/15 通过 | `/tmp/reveric-h3-shot-quality-sync.log` |
| 窄范围 analyze | exit 0；2 files，No issues found | `/tmp/reveric-h3-shot-quality-analyze.log` |
| 窄范围 format 检查 | exit 0；2 files，0 changed | `/tmp/reveric-h3-shot-quality-format.log` |
| `git diff --check` | exit 0 | 命令直接执行，无输出 |

三项 RED 的首个失败分别是：主文没有完整必经路径；production 尚无 H3 专属格式／明确全参考目标的交付分支；配方目录只有四例，缺少可检查的第五个屏幕操作例。根因是已有镜头原则没有接入每次拆分和保存回读的具体交付要求；没有据此归因运行时接口、技能是否加载或安装版本。

实际串行命令：

```bash
timeout 240 fvm flutter test --no-pub --concurrency=1 test/shared/services/bundled_official_skills_test.dart > /tmp/reveric-h3-shot-quality-red.log 2>&1
# 文案与元数据修改后：
timeout 240 fvm flutter test --no-pub --concurrency=1 test/shared/services/bundled_official_skills_test.dart > /tmp/reveric-h3-shot-quality-official.log 2>&1
timeout 240 fvm flutter test --no-pub --concurrency=1 test/shared/services/official_skill_sync_test.dart > /tmp/reveric-h3-shot-quality-sync.log 2>&1
timeout 240 fvm flutter analyze --no-pub lib/shared/services/bundled_official_skills.dart test/shared/services/bundled_official_skills_test.dart > /tmp/reveric-h3-shot-quality-analyze.log 2>&1
fvm dart format --output=none --set-exit-if-changed lib/shared/services/bundled_official_skills.dart test/shared/services/bundled_official_skills_test.dart > /tmp/reveric-h3-shot-quality-format.log 2>&1
git diff --check
```

GREEN 之前另用 `fvm dart format` 格式化同两份 Dart 文件，只改变新增测试排版，registry 无格式变化；最终 format 日志为无改动检查。无 Flutter 测试并行，无 live grep 管道。

## 元数据与独立核对

- 剧本制片：v2 → **v3**，按用户已披露发布未知后的独立授权处理。
- `contentHash`：`fb84be685c4fa1f5874e514c54089a2310e1cd157947d0e617698e18645c1be1`。
- `updatedAt`：`2026-10-28T05:33:23-04:00`（实际执行环境时间，等价 UTC 09:33:23）。
- 再次 `git tag --list` 为空；publication **UNKNOWN**，不把空标签判断为未发布。
- Python 从实际 references 目录独立枚举排序 15 个文件，按主文原始字节 + 每附件 NUL/完整路径/NUL/原始字节重算 SHA-256，与 registry 一致。
- 与 HEAD 比较：主文 frontmatter 不变；shot-recipes 原四例逐字节不变；registry 除剧本制片三个元数据字段外逐字不变；旧 17 测试除 version 期待外逐字不变。只有获准的五份产品／测试路径有 diff。原打包、链接、目录、中文、H3 标记和 hash 守卫全部通过。
- Spec-review 建议：现有 agent-skills、testing 与复用／跨层规则已覆盖本次资源归属、元数据、真实 loader 和诚实验证边界，没有新增运行时契约或新编码模式；不扩大本轮范围编辑 spec。独立 check 及最终集成由主会话后续执行，本实施代理未冒充独立检查者。

## 限制

静态测试只验证资源文本、装包、格式结构、时间码及既有升级逻辑，不能证明真实 Agent 遵循、视频质量、精确计数／屏幕文字／切点或设备上的已安装快照已升级。

未调用付费模型、网络或实际媒体生成，未 pub／codegen／clean／stash，未访问或修改业务与技能安装数据库，未改已有分镜、引用、H3 格式附件、工具描述／schema、UI／API、其他 Skill 或远程模型目录。没有新增运行时质量校验器、自动素材绑定或生成流程。
