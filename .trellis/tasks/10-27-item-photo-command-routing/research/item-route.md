# 物品入口与最小修复证据

本报告是只读规划调查，尚未修改产品代码或运行测试，不访问用户数据库或模型。

## 已核实调用链

```text
WorkspaceEntryEditor._handleGeneratePhoto
  → onGeneratePhoto(prompt, selectedItemId)
  → NovelWorkspacePanel.onGenerateItemPhoto
  → NovelEditorPage.generateItemPhoto
  → AiChatHandoffDraft(autoSend:true, item context reference)
  → 现有聊天/Agent
```

- `lib/desktop/widgets/workspace/workspace_item_editor.dart:493–521` 负责弹出风格对话框；目前生成一句“请为物品「标题」生成照片或插画”＋风格。此处尚未写明 Read 路径、目标 ID 或图片命令。
- 同文件 `:104–260` 的对话框只收集风格与补充要求，确认返回共用中文任务文本；不应修改布局、字段生命周期或文案翻译。
- `lib/desktop/widgets/workspace/novel_workspace_panel.dart:723–770` 是 `WorkspaceEntryEditor` 唯一产品调用方；只有 `selection.section == NovelWorkspaceSection.items` 才传图片生成回调。势力/技能/生物共享照片展示不等于共享生成入口。
- `lib/desktop/pages/novel_editor.dart:2871–2893` 仅加 `Item photo:` 前缀，创建 autoSend 聊天交接并附物品引用。请求中的 ID 依赖引用，未明确要求 `Run item generate-photo`。保留该交接即可；前缀不会改变完整任务要求，不需要为去掉前缀而修改整个页面或重建其测试隔离。

## 现有图片命令，不需新增服务

- `lib/shared/services/ai/tools_run.dart:343–346` 注册 `item generate-photo`，已有参数格式 `options={item,prompt,path?}`。
- 同文件 `:1710–1814` 的 `_runSubjectImageCommand` 核实物品真实存在且类型为 item，取得 operation host，按 `generation.image` 权限运行，调用 `_handleGeneratePhoto`，返回 `local_path/item_id` 和 UI metadata。不是写物品照片的命令。
- `lib/shared/services/ai/tools_image.dart:103–175` 检查图片 callback 和提示词，使用已有 `imageGenerationCallback(prompt,size:864x1536)`；path 非空才走 edit callback。失败不应伪装为图片生成成功。
- `lib/shared/services/ai/chat_turn_runner.dart:1159–1160,1421–1422` 两条现有工具宿主均注入图片 generation/edit callback。
- `lib/shared/providers/ai_providers.dart:2478–2520` 的 callback 读取 `imageGenerationConfigProvider` 和当前作品的 `AiModelKind.image` 选项，通过 `AiImageGenerationService` 生成、导入 ai_chat_generated 资产并返回结果。它不读取聊天选项作为默认图片模型。
- `lib/desktop/pages/novel_editor.dart:2840–2869,3024–3036` 保留现有用户采用后追加到目标物品照片的路径。任务请求不应指挥 Agent 自行写照片或覆盖原数据。

## 故障证据与边界

用户日志显示在上述交接之后，Agent 读取物品/技能，但未调用应用图片命令，chat/completions 直接返回 delta.images，随后 emptyResponse 重试。这证明本次实际执行未走配置的图片命令；“自然语言请求必然出错”不是结论。

另一个真实缺口是聊天输出图片丢失：`third/ai_clients_dart/packages/openai_dart/lib/src/models/streaming/chat_stream_event.dart:234–315` 的 ChatDelta 未解析 images；`lib/shared/agent/client/openai_client.dart:560–640` 只转发文字、思考与工具。`lib/shared/agent/client.dart` / `round_assembler.dart` 也没有输出图片事件。完整接图涉及共同响应类型、round/Agent、会话保存与展示；单纯放宽 emptyResponse 会产生不可见的假成功。停止重试的保护同样需要正确定义异常分类与用户提示，不能在本任务中暗改为成功或自动换命令补发。

**推荐本次仅修已证失败的物品入口请求，不改 SDK/Agent 聊天链路。** 通用聊天图片问题保留为明确后续风险，非声称已经修复；此任务也不能靠提示词测试保证所有真实 Agent 一定遵循。

## 最小产品改点

仅在 `WorkspaceEntryEditor._handleGeneratePhoto` 原有字符串处写完整任务：真实物品 ID 与 `/items/{id}`、整理资料和风格、必须调用现有 `Run item generate-photo` 的准确 JSON 示例、不调用聊天内置生图、不切模型、不擅自重复、等待实际工具结果、用户手动采用不写照片。风格/补充要求原样放数据块，不能覆盖执行路径。无需新 prompt registry、helper、服务或 UI。

## 测试真源与改点

- `test/desktop/widgets/workspace/workspace_entry_editor_test.dart` 已有真实 WorkspaceEntryEditor、中文 localization/theme 与窄尺寸滚动测试。扩展现有 helper 参数，增加真实按钮→风格→确认收集回调的用例，断言实际请求与 ID；保持原滚动用例，不挂整个 NovelEditorPage 或 mock 一长串 provider。
- widget 测试含真实翻译资源：已有 `setUp(() => rootBundle.clear())`，保留。测试自己创建的 controller/focus 要释放，结束拆树。
- `test/shared/services/ai/tools_run_test.dart:954–1081` 已有 loopback HTTP＋真实图片 callback 的生成/编辑/资产集成用例；`:1106–1122` 已有物品命令回调覆盖。扩展 loopback 用例使 `item generate-photo` 也走实际配置的 image callback，捕获图片请求目标、model、prompt，并断言真实资产/metadata及业务照片未自动变更，不调用真实外部接口。
- `:1203–1222` 现有权限拒绝不生图，`:1224–1247` 未知目标与类型校验可以串行回归；不为已有正常逻辑新增产品补丁。

预计产品文件 1 个＋现有测试文件 2 个，合计 3 个；其他变化仅本任务规划/研究记录。确需超过该范围时回到规划，不自行扩展。全部本地 Flutter 测试按 pinned FVM、no-pub、concurrency=1 串行、完整落日志运行。
