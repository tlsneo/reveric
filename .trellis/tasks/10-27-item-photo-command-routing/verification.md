# 物品照片路由修复验收

## 范围与实际变更

产品/测试仅三个路径：

1. `lib/desktop/widgets/workspace/workspace_item_editor.dart`：只替换物品照片任务请求。
2. `test/desktop/widgets/workspace/workspace_entry_editor_test.dart`：真实按钮请求和取消/不采用回归，保留原滚动测试与本地化缓存隔离。
3. `test/shared/services/ai/tools_run_test.dart`：扩展既有 loopback 图片命令回归，保留角色/权限/目标等用例。

其余仅本任务规划、研究和验证记录。未修改制作、导演台、角色照片/大头照、四视图、地图、H3、移动代码、Skill、工具 description/schema、SDK/Agent、模型配置或数据库 schema。未调用外部应用模型或操作用户业务数据。

## A1 / A3 — 入口与数据边界

- 实际点击已保存物品的生成照片按钮，选风格、填补充、确认；callback 恰一次，真实物品 ID/Read 路径/Run JSON 正确，风格原样保留。
- 明确应用图片模型、禁止聊天内置生图/切模型/换命令/擅自重提、等待真实结果、用户手动采用。
- 标题/内容/分类/照片输入不变，无增删照片 callback；取消不产生请求。
- 原紧凑滚动与隐藏 metadata 回归保留。

## A2 — 命令执行证据

本机回环 HTTP 测试通过真实 imageGenerationCallbackProvider 执行物品命令，捕获的是实际 HTTP 请求而不是模型字段回填：

- POST `/v1/images/generations`，所选图片 `image-advance`，不是存在的 chat-only 或另一图片默认值。
- 完整 prompt、既有 864x1536、n=1；一次物品命令只增加一次生成请求。
- 生成文件字节、图片资产、work归属、item_id/metadata 正确；已有命名照片和物品整行数据保持。
- 原角色生成/编辑、权限拒绝、类型/目标校验同文件回归保留。

这些是内存库/fixture/loopback 的真实本地执行，不是远端供应商验收。

## A4 / A6 — 同类和其他助手核查

源码证据报告：

- `research/item-route.md`：物品入口、现有图片命令、采用边界与已知 chat 图片丢失。
- `research/entry-audit.md`：大头照、角色资料照片、双端四视图、制作/导演台、地图/其他 handoff 分类。
- `research/assistant-entry-audit.md`：有限业务入口矩阵（总结/改稿/选区/续写/开书/发布整理/场次/分镜/导演识图/地图/模式交接/下一步/轻量文本）。研究代理达到 turn limit 收尾，明确未深查全局浮动助手/后台记忆等，不声称全仓穷尽。
- `research/shared-runtime-audit.md`：handoff消费/拼接、上下文引用、工具列表与模式、Run透传、技能、工具结果及重试。

新发现均未扩改：节拍卡生成章纲未携所点击beat（具体交接缺陷，未运行错写复现）；图片工具丢失给Agent的底层诊断（服务日志另有保留）；技能首次读取失败退空（条件风险，本次成功加载日志不支持它是当前原因）。模型继承差异/文字保存期望只列不确定，不代用户决定需求。

## A5 — 实施阶段检查（主会话已复核日志）

| 命令 | 实际结果 | 日志 |
| --- | --- | --- |
| `timeout 240 fvm flutter test --no-pub --concurrency=1 test/desktop/widgets/workspace/workspace_entry_editor_test.dart`（旧请求） | RED：2 pass / 1 fail，缺 Run JSON | `/tmp/reveric-item-photo-red-widget.log` |
| 同命令（新请求） | 3 pass | `/tmp/reveric-item-photo-green-widget.log` |
| `timeout 300 fvm flutter test --no-pub --concurrency=1 test/shared/services/ai/tools_run_test.dart` | 56 pass | `/tmp/reveric-item-photo-green-run.log` |
| `timeout 240 fvm flutter analyze --no-pub`＋三个修改 Dart 路径 | No issues found | `/tmp/reveric-item-photo-analyze.log` |
| `fvm dart format --output=none --set-exit-if-changed`＋三个路径 | 3 files / 0 changed | `/tmp/reveric-item-photo-format.log` |
| `git diff --check` | pass | `/tmp/reveric-item-photo-diff-check.log` |

测试/分析严格串行，SDK revision 与 .fvmrc 一致。Dart LSP 无server，主/子会话已尝试，不把缺环境称为通过。失败、根因与修复逐项见 `research/implementation-result.md`：fixture 字体颜色叶子依赖隔离、测试可空资产路径、冗余 import 均已修后重跑。任务文本自检首次还发现 task.py 生成的 task.json 缺末尾换行，已补后通过 JSON/路径/空白检查。

## 独立检查

gpt-6.1-sol `29aa28c6-5b16-438` 已完成独立审查，无范围内遗留问题，未修改产品/测试。主会话已阅读其完整 research/check-result.md、实际差异和最终日志，核实以下结果：

| 独立命令 | 结果 | 日志 |
| --- | --- | --- |
| widget 整文件（与上列相同命令） | 3 pass，exit 0 | `/tmp/reveric-item-photo-check-widget.log` |
| Run 整文件（与上列相同命令） | 56 pass，exit 0 | `/tmp/reveric-item-photo-check-run.log` |
| 三文件 analyze | No issues found，exit 0 | `/tmp/reveric-item-photo-check-analyze.log` |
| 三文件 format 检查 | 3 files / 0 changed，exit 0 | `/tmp/reveric-item-photo-check-format.log` |
| diff 检查 | pass，exit 0 | `/tmp/reveric-item-photo-check-diff.log` |
| 4 个既有共享助手回归（完整命令见 implement.md） | 84 pass，exit 0：prompt builder 18、handoff 3、turn runner 44、dispatcher 19 | `/tmp/reveric-item-photo-check-runtime.log` |

独立合计 **143 项通过**，非把实施阶段的59项重复累计。runtime 日志包含已有 fixture 故意模拟失败/重试/空响应的诊断，以及未安装桌面通知插件/fixture缺翻译键等 warning；check 对照了用例断言，未修改或压制它们，不能将“测试通过”描述为“日志无警告”或真实供应商成功。

三条审计结论由 check 独立核实：节拍点击目标信息丢失；图片工具丢机器分类和可选debug详情（userMessage可能已有部分区分，并非完全无诊断/服务日志）；首次技能读取最终失败退空。后两项及节拍实际错写均未作为用户本次故障的已复现根因。

## 复发分析与 spec review

- 类别：入口任务与执行能力之间的隐含契约（B/E），并伴随跨层图片响应丢失（B，另范围）。之前大头照修的是那个入口的命令约束，不等于所有生图入口或通用聊天接图都已修。
- 当前防回归：真实 UI 回调必须携 Run item generate-photo；在旧任务上实际失败。真实 loopback 验证应用图片配置/请求与不自动采用，避免仅文本断言或资产字段自证。
- 已完整阅读 trellis-update-spec 并审阅 frontend/backend质量及跨层/复用指南：本次不新增命令、公共API、schema或共享约定；AI调用选择、UI/Agent错误分离、真实回归与串行隔离已有 `.agents/rules/ai-calling.md`、`error-handling.md`、`testing.md` 维护。具体物品契约留在源请求/测试/任务记录，不另复制永久 spec 或工具schema。
- 审计发现是后续工作证据，不借 spec-review 偷渡运行时行为、Skill或用户配置修改。

## 实际验收限制

- 指令更明确不是运行时强制，测试不证明所有远端Agent必然正确选工具，亦不证明质量、额度、网络、供应商或用户设备时序。
- 通用聊天 `delta.images` 丢失及误空回复重试未修；不能称共享接图成功。
- Windows/macOS 共用请求，Linux宿主测试不是这两端设备验收；移动无同入口，未新增或运行移动功能。
- 用户设备后续验证：从物品生成照片，确认日志有 `Run item generate-photo`，随后是已配置图片provider/model的图片请求；结果由用户手动采用。不要仅看聊天中出现图片就视为命令成功。

## 提交与行政收尾

独立验收已完成，按 AGENTS.md 的任务范围自动提交本批次三文件修复及任务记录，不 push/amend；此前任务不改不归档。当前任务分支和 base 均为 unstable，start 有同分支警告，不擅造分支/目标或归档绕过限制。
