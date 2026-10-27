# 实施与验收计划

## 用户已确认的范围

只改以下 3 个文件（另可维护本任务记录）：

- `lib/desktop/widgets/workspace/workspace_item_editor.dart`：只改 `_handleGeneratePhoto` 发出的任务字符串，明确真实物品、Read 与现有图片命令。无布局/状态/回调/API改动。
- `test/desktop/widgets/workspace/workspace_entry_editor_test.dart`：在已有 fixture 增加真实按钮和风格交互回归，保留滚动测试和资源隔离。
- `test/shared/services/ai/tools_run_test.dart`：扩展既有本机 HTTP＋真实 image callback 回归，证明物品命令使用所选图片模型且不自动写照片。

大头照/人物照片/制作/四视图/地图/移动源码不改；共用 SDK、Agent、chat retry、工具描述和数据库不改。任何超出上述范围的实际需要须回规划并确认，不在实现时顺手扩展。

## 顺序

- [x] 创建独立任务，记录日志、用户收紧边界与最小物品链路调查。
- [x] 完成其他入口只读核查并审阅 `research/entry-audit.md`；大头照/制作/四视图保留，角色资料照片仅静态风险，移动无同按钮。
- [x] 主会话收敛 PRD、设计、执行计划与 implement/check manifests；验证任务路径及 JSON。
- [x] 向用户展示最终三文件方案、测试与通用聊天图片残余风险；用户已明确同意实施。
- [x] 同期只读核对其他 AI 助手入口与共享执行链，结果写入 `research/assistant-entry-audit.md`、`research/shared-runtime-audit.md`；主会话核实节拍目标缺失与图片工具诊断损失等发现，只报告、不扩大产品改动。入口调查在 turn limit 收尾，有限覆盖/未覆盖项已明确。
- [x] 已 `task.py start` 并派发显式 `gpt-6.1-sol` trellis-implement（ae663be4-ac4e-459）；读取 manifests → PRD → design → implement。不递归委派，不提交。
- [x] 先补 widget 真实按钮回归并运行旧请求 RED：2 pass / 1 fail，原因是缺 Run JSON；初次 fixture 叶子依赖隔离问题已定点修复后重跑，不混作有效 RED。
- [x] 最小替换原请求，补现有物品真实图片 callback 回归；仅三文件，无新模板注册/服务或正常生图改动。
- [x] LSP 无 Dart server 已记录；实施阶段串行 GREEN 为 widget 3 pass + Run 56 pass，三文件 analyze/format/diff 通过。测试编译非空断言及冗余 import 问题已修后重跑；完整日志与回执见 research/implementation-result.md。
- [x] 独立 `gpt-6.1-sol` trellis-check（29aa28c6-5b16-438）完成全范围审阅，未再改产品/测试；串行 widget 3 + Run 56 + 共享runtime 84，共143项通过，analyze/format/diff通过。
- [x] 主会话核对真实diff、完整检查回执及最终日志，完成 trellis-update-spec 判断与 verification.md；没有新公共契约，复用现有规则，不复制永久spec。三文件修复和本任务记录进入同一 scoped commit 批次，不push/amend；提交哈希与未验证项由完成回执报告。

## 测试内容

### Widget

- 真实已保存物品的生成按钮 → 选择已有风格并填写补充要求 → 确认，只调用一次 callback；真实物品ID、Read路径与 item generate-photo JSON 正确。
- 保留风格/补充原文、标题与目标身份；数据区不能改写路由。
- 请求明确配置图片模型、禁止聊天内置生图/切模型/擅自重提、等待工具结果、用户手动采用。
- 取消风格对话框不产生 handoff；空选项保持原禁用行为。
- 点击不修改原标题/正文/照片输入，不调用增删照片回调；原紧凑滚动回归仍在。
- 沿用 rootBundle.clear、真实 localization/theme。按实际 fixture 资源管理 controller/focus；拆树、settle，不叠 provider override。

### 图片命令

- 在已有 loopback 测试中让 `item generate-photo` 使用 `imageGenerationCallbackProvider` 的真实 callback；捕获本机生成 HTTP 请求，断言配置的图片 model（非聊天 model）和完整 prompt。
- 一次命令对应一次生成；真实图片资产/文件、item_id 与 metadata、业务照片不自动更改。
- 缺少图片配置/目标不存在/权限拒绝按现有失败机制回归，不新增 fallback；已有角色 avatar/photo 测试保留。

## 命令（Flutter 严格串行）

```bash
timeout 240 fvm flutter test --no-pub --concurrency=1 test/desktop/widgets/workspace/workspace_entry_editor_test.dart > /tmp/reveric-item-photo-red-widget.log 2>&1
# 只在最小请求修复后执行，独立完整日志：
timeout 240 fvm flutter test --no-pub --concurrency=1 test/desktop/widgets/workspace/workspace_entry_editor_test.dart > /tmp/reveric-item-photo-green-widget.log 2>&1
timeout 300 fvm flutter test --no-pub --concurrency=1 test/shared/services/ai/tools_run_test.dart > /tmp/reveric-item-photo-green-run.log 2>&1
timeout 240 fvm flutter analyze --no-pub lib/desktop/widgets/workspace/workspace_item_editor.dart test/desktop/widgets/workspace/workspace_entry_editor_test.dart test/shared/services/ai/tools_run_test.dart > /tmp/reveric-item-photo-analyze.log 2>&1
fvm dart format --output=none --set-exit-if-changed lib/desktop/widgets/workspace/workspace_item_editor.dart test/desktop/widgets/workspace/workspace_entry_editor_test.dart test/shared/services/ai/tools_run_test.dart > /tmp/reveric-item-photo-format.log 2>&1
git diff --check
```

独立 check 使用 `/tmp/reveric-item-photo-check-*.log`。用户追加共享助手链核查后，独立 check 在物品测试结束后串行运行以下现有回归（不改这些测试文件）：

```bash
timeout 360 fvm flutter test --no-pub --concurrency=1 test/shared/services/ai/chat_prompt_builder_test.dart test/shared/services/ai/chat_session_controller_handoff_test.dart test/shared/services/ai/chat_turn_runner_characterization_test.dart test/shared/services/ai/chat_agent_tool_dispatcher_test.dart > /tmp/reveric-item-photo-check-runtime.log 2>&1
```

这些回归验证当前本地交接/上下文、工具与重试通路，不证明远端模型对所有入口正确执行。新发现节拍点击目标缺失、图片工具诊断损失、技能读取空降级等仅做源码核实，不增加未经确认的修复。

不把活跃测试 pipe 给 grep、不 pub/codegen/clean/stash，不运行付费模型或业务数据库。最窄测试范围不包括未修改的制作生图整个测试集；如独立审查证明需要扩大测试，可串行增加但如实列出。

## 验收边界

测试证明真实入口任务契约与现有命令到配置图片回调，不证明用户远端模型一定服从，也不证明模型出图质量。通用聊天 `delta.images` 丢失和空回复重试仍未修；不以此小补丁冒充共享接图完成。用户设备后续验证应检查是否真的出现 `Run item generate-photo` 以及图片 provider/model 请求，再手动采用一张结果。
