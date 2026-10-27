# AI 助手共享执行链核对

本报告响应用户补充：多数错误发生在需要助手执行工具的入口，直接生成通常正常。它是有限源码调查，不是所有接口/供应商的运行时审计。主会话只读核查共享交接与 runtime；独立报告 `assistant-entry-audit.md` 核查各业务入口，不与其重复。

## 核对范围与结论

已读桌面 handoff 消费、ChatSessionController 发送/拼接、ChatPromptBuilder 引用、ChatTurnRunner 工具列表/技能/Agent、ChatAgentToolDispatcher、Agent 工具执行与重试、图片工具错误处理；定位现有测试。未修改这些共享文件、未调用应用模型或用户业务库；测试执行结果另记 verification.md。

**不能从“多数是助手入口出错”推出所有接口有同一根因。** 应区分：任务未指向正确操作、工具不可用/技能未加载、实际工具失败、上游响应内容丢失、后续显示/采用。物品日志中 Read/Skill 成功，足以排除本轮“所有工具都不可用”。图片命令没发生和 chat images 丢失是两个不同层次的问题。

## 交接和工具链证据

| 环节 | 当前实现/源码 | 判断 |
| --- | --- | --- |
| 按钮→新助手会话 | `lib/desktop/widgets/ai/chat/panel.dart:1014–1147` 校验目标激活，保留 references/files/content/initialText，新建 orchestrator 的 chat 模式，等会话 loaded 才 autoSend | 不是直接媒体 API。没有发现本次完整 prompt 被截断/替换的静态证据；异步时序未在用户设备复现，不能保证无竞态。 |
| handoff 与正文拼装 | `chat_session_controller.dart:889–915,2228–2256` 将正文/引用与未包含的 handoff 合并，再准备附件；只有已完整包含时去重 | 完整物品任务可以经现有链路抵达 Agent，不必重写页面。去重不是删除指令。 |
| 上下文引用 | `chat_prompt_builder.dart:243–290` 对实体发 Read 路径提醒，对文件/选段嵌原文；实体引用并不自动附整份正文或图片字节 | “附了人物/物品引用”不等于“已传头像/完整剧本”。依赖真实 Read/附件，不能以名字证明媒体输入。 |
| Agent 构造 | `chat_turn_runner.dart:1434–1514,1648–1687` 构造原有通用 Agent，恢复历史、技能摘要，注入 dispatcher | 普通助手不是轻量无工具 chatCompletion。 |
| 工具可用列表 | `chat_turn_runner.dart:283–307` 从 dispatcher 的真实 allToolNames 按模式过滤，`:1961–1964` 运行前刷新；`ai_session_mode.dart:40–57` chat 可用全部，剧场/扮演/独白/会议仅限只读工具 | 未发现按当前页面把 Run 隐藏的逻辑；专用模式限制是现有边界，不是要放开写权限的 bug。 |
| Run 透传 | `chat_agent_tool_dispatcher.dart:78–91` 普通工具含 Run 透传 inner.executeTool；只特判 Codemode/子助手 | 未发现 Run 被这层吞掉。不能把图像工具未调用说成工具不可用，用户日志也列了 Run。 |
| 工具失败交回模型 | `tools.dart:4689–4710` 归一化并返回 map，抛出异常记录后传播；`agent.dart:1424–1455,1546–1574,1624–1667` 执行/归一化，将异常诊断或原结果 JSON 加回模型历史，只有 `_metadata` 被剥离；`tool_error_normalize.dart:123–181` 补 ok/error_code，保留字段 | 常规通路并非只在 UI 展示失败、不让 Agent 知道，也不是统一剥除所有诊断。特定 handler 可能提前丢详情，见下。 |
| 图片结果与采用 | `chat_turn_runner.dart:243–267` 对 Run 的 image 命令建立图片块，同时保留 tool block 给模型历史 | 有意不删除工具历史，否则模型可能以为没调用过。通用聊天 images 没有这套命令 metadata，不能冒充相同采用链。 |

## 已证结构性缺口及尚未发生的条件风险

### F1 — 已知 chat 图片内容丢失（已由用户日志复现，本次不修共享协议）

- `third/ai_clients_dart/packages/openai_dart/lib/src/models/streaming/chat_stream_event.dart:234–315` 不解析 delta.images，`lib/shared/agent/client/openai_client.dart:560–640` 不转发。
- `client.dart` / `round_assembler.dart` 的通用输出没有图片事件，`agent.dart:868–909,1823–1834` 将无文字/思考/工具的 round 视为空并有限重试。这解释物品日志，但不能解释所有其他助手错误。
- 不得只放宽空校验、生成一段替代文字当成功，或无权限自动补发图片生成。本次只改已证失败的入口任务，仍须披露此缺口。

### F2 — 图片工具失败返回给 Agent 的诊断不足（源码可确定，非本轮未调用命令的原因）

- `tools_image.dart:71–88,143–155` 捕获异常，只返回用户友好的 error 和固定 internal；AiImageGenerationException 的 `code` / `debugMessage` 不回传。
- `image.dart:111–135` 已定义这些诊断字段；`:350–421` 对连接/供应商错误保留 debugMessage 并写日志。因此不是完全没有服务日志。userMessage 本身可能已经区分部分鉴权/额度/参数等问题，不能说 Agent 完全没有诊断；确定丢失的是机器可读的原分类和可选底层 debug 详情，影响精确判断与处理。
- Avatar 虽另记 aiTrace，异常 toString 也只返回 userMessage，不能代替给 Agent 的结构化详情；photo handler 的 catch 自身没有对应错误 trace。外层已收到失败 map，不会再进入捕获原异常的诊断路径。
- 违反项目“UI 安全文案与 Agent 技术诊断分开”的现有约定；若授权修复，应保留 UI 安全说明，同时给工具结果加脱敏的真实分类/底层详情，不能仅增加日志。当前三文件修复不改此接口。

### R1 — 已安装技能读取失败会退成空技能上下文（条件风险，未在当前日志发生）

- `chat_turn_runner.dart:728–734` 首次读取 installedAgentSkillsProvider 抛错时，记录错误后直接返回 `_ChatSkillContext.empty`；后面的 bundled fallback 构建不会执行。
- 正常的同名禁用/blocked 覆盖是设计行为，`:740–804` 明确保持，不应移除。需要区分“用户禁用技能”与“技能存储读取失败后继续空技能执行”。
- 用户本次日志 Skill 成功，所以这不是物品本轮根因。若其他失败日志出现 Failed to load skills，才有证据进入该分支；不为可能性添加运行时 fallback 或绕过用户选择。

## 对重试的判断

`agent.dart:1789–1897` 分别处理取消、空/不完整回复、上下文长度、HTTP 5xx、SDK/网络错误，有限重试且取消后检查。工具调用在拿到完整 round 后执行，round 空回复重试不等于图片命令自动重提；但若聊天上游在每次回答中内部生图，应用无法感知其副作用，重发会让上游反复生成。不能通过延长超时/增加重试解决本问题，也没有证据说明其他助手报错都是同类。

## 既有回归定位与验证界限

- `test/shared/services/ai/chat_session_controller_handoff_test.dart`：首次物化、来源隔离、失败后同目标会话重试。
- `test/shared/services/ai/chat_session_controller_workspace_context_test.dart`：上下文与工作区提醒。
- `test/shared/services/ai/chat_prompt_builder_test.dart`：引用路径/实体/选段文本。
- `test/shared/services/ai/chat_turn_runner_characterization_test.dart`：工具/技能作用域、流中断重试、UI/持久化、子任务回执归属。
- `test/shared/services/ai/chat_agent_tool_dispatcher_test.dart`：普通工具透传/子助手边界。

上述是定位，不代表本报告写成时已跑过。后续串行运行可验证本地现有链路，不能证明远端模型正确选工具、已装自定义技能内容、真实设备时序或供应商接口无故障。

## 本次改动建议

继续完成用户已批准的三文件物品入口修复。其他入口报告和本报告的 F2/R1 作为证据分开的后续项，不偷渡进制作或 SDK 改动。下一次助手失败，优先对照实际工具名/参数/结果和 wire 响应确定处于哪一层，而不是把每个入口都补成长提示词。
