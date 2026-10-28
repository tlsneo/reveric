# 独立「AI 拆分镜」实施结果

按已批准第五轮完成；未委派子代理、未提交或推送。父会话维护的规划文件、task.json、verification.md 与 specs 未由本实施代理改写。本报告是实施阶段快照，后续独立检查及暂存门禁修正后的最终指纹／日期以research/independent-storyboard-check-result.md和注册表为准。

## 内容与范围

- 新增 `assets/official_skills/storyboard-splitting/SKILL.md`（「AI 拆分镜」v1），独立拥有拆分与视频提示词方法，不是转发制片的 wrapper。新增 `references/splitting.md`、`references/storyboard.md`，保留理解→镜头／表演预算→独立生成分组→格式→逐镜／跨段核对→授权保存回读，以及整集计划时长核对。
- 同 basename 移动九附件到新根：`video-prompts.md`、`minimax-h3-prompts.md`、`seedance-prompts.md`、`kling-prompts.md`、`veo-prompts.md`、`wan-prompts.md`、`model-capabilities.md`、`shot-recipes.md`、`scene-example.md`。五份字节不变；另四份仅改归属链接、未选模型中文 H3 默认或可选图片教学边界。全部 fenced 示例逐字保留；没有旧根副本或跨根注册。
- 清理 `screenplay-production/SKILL.md`、`references/production.md` 的重复拆分触发／方法；旧 `references/storyboard.md` 保留完整占位图／导演预演，修复 `image-references.md` 的模型能力交接。人物、图片配方、结果诊断附件未改；制作依赖、并发／串行、实际结果检查返修保留。
- `screenplay-writing/SKILL.md` 仅改末尾交接；`assets/bundled_skills/screenplay-tools/SKILL.md` 和 `references/clips.md` 仅改创作格式归属，操作契约不变；`.agents/rules/agent-skills.md` 仅改 Shot 归属示例。
- `lib/desktop/features/storyboard/region.dart` 仅改点名新技能及 `references/splitting.md`，其余安全／来源／模型／时长／fps 文案、UI、回调和人工发送行为不变。`pubspec.yaml` 增加嵌套资源；`lib/shared/services/bundled_official_skills.dart` 新增身份、重新分配附件及维护三个包的版本／hash／date：新拆分 v1、制片 v5、写作 v4。
- 修改四测试：`test/desktop/features/storyboard/region_test.dart`、`test/shared/services/bundled_official_skills_test.dart`、`test/shared/services/bundled_control_skills_test.dart`、`test/shared/providers/official_skill_sync_providers_test.dart`。原方法／中文格式／完整案例的预算、切点、原话及动作归属守卫迁到新 owner，增加独立加载、旧制片职责及操作边界检查。打包安装测试覆盖旧制片 v4→v5 的 ID／名称／停用／顺序／历史保留、新拆分独立启用、停用与删除不重装、本地定制与同名本地冲突保留。

## 失败与修复

1. 先加独立 loader 与真实按钮新路由回归，对旧产品执行 RED：**23 通过、2 失败**。失败分别是目录没有「AI 拆分镜」、按钮仍要求「剧本制片」，不是版本／hash 噪音。日志：`/tmp/reveric-independent-storyboard-red.log`。
2. 首次 provider 整文件 **10 通过、1 失败**：原有合并目录回归硬编码写作 `sourceVersion == '1'`，真实目录为本轮批准的 v4。仅将该期待改成 `'4'`，新安装场景当时已通过。原日志：`/tmp/reveric-independent-storyboard-provider-first.log`。
3. 最终审计首次发现旧预演附件末尾新增空行，`git diff --check` 失败。仅移除 EOF 空行并重算制片 hash；随后重新串行通过官方加载、provider 测试及六文件 analyze／format。原审计日志：`/tmp/reveric-independent-storyboard-audit-first.log`。
4. 审计脚本随后把父会话同期维护的 `.trellis/spec/backend/quality-guidelines.md` 误计入产品范围而失败；将明确由父会话负责的 task/spec 路径单列排除，没有改动该文件或放宽产品文件 allowlist。记录：`/tmp/reveric-independent-storyboard-audit-parent-scope.log`。

## 最终验证

Flutter 全程串行，测试命令均为 `timeout 240 fvm flutter test --no-pub --concurrency=1 <file>`；先落完整日志再读取。

| 测试文件 | 最终结果 | 完整日志（`/tmp/reveric-independent-storyboard-` 前缀） |
|---|---:|---|
| `test/desktop/features/storyboard/region_test.dart` | 1/1 | `region.log` |
| `test/shared/services/bundled_official_skills_test.dart` | 26/26 | `official.log` |
| `test/shared/services/bundled_control_skills_test.dart` | 26/26 | `control.log` |
| `test/shared/providers/official_skill_sync_providers_test.dart` | 11/11 | `provider.log` |
| `test/shared/services/official_skill_sync_test.dart`（未改） | 15/15 | `sync.log` |

合计 **79/79，最终无失败**。六个受影响 Dart 文件按 implement.md 执行 `timeout 240 fvm flutter analyze --no-pub ...`：**No issues found**（`analyze.log`）。最终 `fvm dart format --output=none --set-exit-if-changed ...`：**6 文件、0 改动**（`format.log`）。已调用 LSP diagnostics，但工具返回 **No LSP server configured**；不计为 LSP 通过，以 CLI 实际结果为准。

独立审计 `/tmp/reveric-independent-storyboard-audit.py` 与完整输出 `audit.log` 通过：按父会话只读 baseline JSON 复核九移动文件、全部完整示例、原九阶段方法与写后检查、保留的预演／返修内容；99 个相对链接可在所属安装根内解析；所有官方资源逐一唯一注册、嵌套资源声明齐全；三个包独立重算指纹一致。范围为 **24 个已跟踪产品修改／删除路径＋新根 12 个文件**（其中九个对应移动源），另本报告。`git diff --check` 通过。无运行时／provider 实现／工具描述／schema／API／业务数据改动，无 pub／codegen／clean／stash；预存两份 fragmentation 诊断及 model-capability-catalog 任务未改。

### 实施阶段 SHA-256（后续最终值见独立检查报告）

| 包 | 版本 | contentHash |
|---|---:|---|
| AI 拆分镜 | 1 | `cc7c044c3e984e0ccbfd8734b9d668bd7a75a6e4ac1e161ad3a48d6f9d4daad8` |
| 剧本制片 | 5 | `e91a8be9583ed1d2e05fa0cc51a96b75b9e0eb0054a27f0a33d1744217f34d7d` |
| 剧本写作 | 4 | `e047a5636426bd9209861234ea72df3af811e274310b1d9f34d166682b06fc64` |

## 验证边界

源码、资源包加载与隔离安装／升级语义已验；未读写用户 Skill 快照或业务库，未实际刷新用户安装或历史会话，未运行真实 Agent／模型／媒体调用、视频／显存或 Windows／macOS／Android 设备验收。请求断言、mock 安装测试和手写完整案例不能证明真实 Agent 已加载新技能、创作质量改善或视频效果；未宣称这些已完成。
