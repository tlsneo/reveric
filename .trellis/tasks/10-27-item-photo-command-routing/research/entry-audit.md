# 图片入口边界调查（只读，规划阶段）

## 范围与证据等级
- 已读本任务 `prd.md`、根 `AGENTS.md`、`.agents/rules/ai-calling.md`、`tools_path.md`，及 hunt / ponytail 约束；不扩展修复范围。
- `python3 ./.trellis/scripts/task.py current --source` 返回 `Current task: (none); Source: none`（退出 1）；按派发指定任务保存本报告，未激活或创建任务。
- 实查：桌面角色编辑/novel_editor、共享角色按钮/provider/orchestrator、Run 图片 handler、图片回调与卡片采用；制作图片提交/衍生视图、导演台导出/识图；移动角色/图鉴编辑与聊天采用。
- 在 `lib/desktop`、`lib/mobile`、相关 `lib/shared/{widgets,providers,services}` 搜索 handoff 构造、characterAvatar、图片生成命令/按钮及制作/导演台符号；模板仅查 `assets/prompts/task/character_{avatar,image}.md` 及注册/渲染代码。
- 未读/搜索 docs、设计稿、无关任务；无产品/测试/配置/业务数据修改，无 Flutter 测试、外部模型调用或递归委派。
- 以下“安全保留”表示没有本次误路由的源码依据，不等于真实设备/供应商调用已验证成功；“不确定”不能自动升级为必改。

## 1. 大头照：仍是已有专用 prompt → character generate-avatar；未证故障
1. 角色编辑大头照按钮：`lib/desktop/widgets/workspace/character_profile_editor.dart:1269–1278` → `_handleGenerateAvatar:699–719`，先检查图片配置、选风格，再以真实 `selectedItemId` 渲染 `task.characterAvatar`。
2. 渲染：`lib/shared/services/ai/prompts/use_cases/task_prompt_use_case.dart:39–46` → `PromptId.taskCharacterAvatar`（注册于 `prompt_registry.dart:165`）。
3. `assets/prompts/task/character_avatar.md:4–11` 已要求 Read `/characters/<id>`、Run `character generate-avatar`（明确 JSON 参数）、应用独立图片模型、禁止聊天/上游内置生图、实际结果与手工采用；不是缺失路由模板。
4. 宿主接线 `lib/desktop/pages/novel_editor.dart:4462`；`generateCharacterAvatar:3048–3075` 将完整模板原样放入 `content/initialText`，携带角色引用并 `autoSend:true`，不是改成普通“给我画图”。
5. Agent 真正执行 Run 后：`lib/shared/services/ai/tools_run.dart:1710–1820` 校验角色、权限/操作上下文 → `_handleGenerateAvatar`；`tools_image.dart:13–49` 无模型明确失败，有源图走 edit，否则图片 callback（1024×1024）。
6. 聊天注入回调：`lib/shared/services/ai/chat_turn_runner.dart:1159–1160`；`lib/shared/providers/ai_providers.dart:2452–2466,2478–2519` 按 `AiModelKind.image` 解析配置 → `AiImageGenerationService.generateImage` → 图片库入库，非聊天模型自动生图。
7. Run UI 映射：`lib/shared/services/ai/run_command_parser.dart:60`；`chat_turn_runner.dart:247–258` 创建 `GenerateAvatar` 图片块，并保留角色 ID。
8. 手工采用：`lib/shared/widgets/ai/chat/chat_message_view.dart:521–549` 仅对成功、有效本地路径与角色 ID 提供设头像回调 → `character_image_tool_card.dart:316–343` 用户点击才执行 → `novel_editor.dart:4503,2994–3003,2726–2745` 导入资产并更新角色头像。
- **分类：安全保留 / 未证故障。** 已有命令模板和下游执行、采用链路均可定位；没有大头照失败日志/复现证明其走错调用。提示词不保证任何模型必然遵循，但这种一般不确定性不是本次故障证据。

## 2. 角色资料“生成照片”、四视图、制作、导演台不是一条链
### A. 角色照片按钮：聊天 handoff，只有静态风险
- `character_profile_editor.dart:723–740` 拼角色名、参考头像要求、用户风格；`:1452–1487` 要求已有头像才启用。
- 接线 `novel_editor.dart:4463` → `generateCharacterPhoto:3078–3101`；`:3038` 加 `Character photo:`，引用真实角色 ID，自动交给聊天；该文本没有像大头照模板那样明确 Run 命令。
- 如 Agent 正确调用 `character generate-photo`：`tools_run.dart:1710–1820` → `tools_image.dart:104–147` → 应用图片 callback → 成功图片卡；`novel_editor.dart:4504,3026–3035,3006–3023` 是手工追加照片链，不自动覆盖头像。
- **分类：不确定 / 静态路由风险。** 与物品入口形状相近，但无该按钮运行日志，不能证明模型未调用命令；现有工具/技能仍可能正确选择。不能因自然语言就宣判同 bug，也不能当作用户确认正常的“制作人物生图”。
- 此回调携带的是角色引用；它是否最终提供头像字节，需继续查引用/Read/模型实际调用，不能从“已提供”四字证明，也不能凭这里未附文件证明必然缺图。

### B. 四视图“一键生图”：双平台共享直接编排，安全保留
- 桌面 `character_profile_editor.dart:2480–2491`、移动 `lib/mobile/pages/character_editor_page.dart:644–650` → `lib/shared/widgets/character/image_generation_button.dart:78–88` → `characterImageProvider.generate(appearance)`。
- `lib/shared/providers/character_image.dart:71–114` 分别解析 chat/image 配置；chat 只整理提示词，image 构造 `AiImageGenerationService`，不创建聊天 handoff、不让 Agent 决定是否调用图片命令。
- `lib/shared/services/character/image_orchestrator.dart:94–124` 预读可选头像字节、用 `characterImage` 模板整理文本；`:134–146` 直接 `image.generateImage` / `editImages`，16:9、2K。
- `assets/prompts/task/character_image.md:24–32` 明确是一张横向四视图，仅输出提示词；这和大头照模板的单人头肩构图不同。
- `image_orchestrator.dart:148–179` 导入生成图并追加角色照片；这是该既有一键流程的自动保存行为，不应移植到大头照/物品手工采用链。
- **分类：安全保留。** 使用独立图片配置，文字模型只做文本整理；没有“期待图片命令、实际交给 chat 自行画图”的同类路由证据。

### C. 制作图片/衍生视图：明确模型与任务服务，安全保留
- `lib/desktop/features/production/image_submit.dart:85–102` 保存草稿 → `ProductionImageGenerateOrchestrator.preview` → `imageTaskServiceProvider.submit`。
- `lib/shared/services/production/image_generate_orchestrator.dart:57–64,103–122` 从片段读取实际 `providerId/modelId`，校验能力，组装图片请求。
- `lib/shared/providers/production_images.dart:17–46` 用请求 `modelId` 构造图片服务，按参考图有无直接 `generateImage/editImages`；无聊天 handoff。
- 制作视图动作 `lib/desktop/features/production/view/actions.dart:90–104` 可只创建草稿，不能误说每次点击立即生图；实际衍生生成 `lib/shared/services/production/view_derive_orchestrator.dart:192–204` 仍 preview → jobs.submit，复用上述图片执行器。
- **分类：安全保留。** 自然语言 prompt 是图片 API 输入，不代表它被交给 chat；且用户已明确制作人物生图正常，不能纳入改动。

### D. 导演台：必须再分本地导出与聊天识图
- 本地图片/视频导出：`lib/shared/widgets/screenplay/director_export.dart:56–74,88–96` → 导出对话框；`lib/shared/services/production/director_output_orchestrator.dart:32–65,105–114` 将渲染帧复制为 PNG 或编码视频并登记导演台资产。它不是“走图片配置的 AI 生图”，更不是本次 chat 生图。
- 识图：`lib/desktop/features/production/region.dart:123–152` 选择图片 → `sceneRecognitionPrompt` + 图片文件 → `novel_editor.dart:4562–4572` 自动聊天交接。
- `lib/desktop/features/production/scene_recognition.dart:52–56` 的目标是还原空间、道具、人物站位和机位，不是生成角色照片；因此缺 `character generate-photo` 是正确边界，不能补图片路由。
- **分类：安全保留。** 导演台相邻制作图片节点才走 C 的应用图片配置；不能把导演台全部操作笼统归为该 API。

## 3. 移动端对应入口及不存在的可核查范围
- 移动角色形象一键按钮见 B；不是桌面“生成照片”的 handoff。头像点击 `character_editor_page.dart:1397–1399` → `pickAvatar:331–354` 为相册导入；照片 `:365–393` 为导入，`:415–420` 可手工设为头像。
- 移动物品/图鉴 `lib/mobile/pages/entry_editor_page.dart:186–191` → `lib/mobile/widgets/compendium_photos.dart`；后者 `:73–85,118–141` 只有相册添加、改名、移除，没有生成按钮或聊天交接。
- 全量 `lib/mobile/**/*.dart`（排除生成 `.g.dart`）检索 `characterAvatar(`、`generate-avatar`、`generate-photo`、`AiChatHandoffDraft(`、`CharacterImageGenerationButton(`：只命中角色四视图按钮 `character_editor_page.dart:644`，未发现桌面大头照/角色照片/物品照片的同名专用生成入口。
- 同范围搜索 `features/production`、`widgets/screenplay/director`、`ProductionRegion`、`ProductionImageSubmit`、`ScreenplayDirectorShell`、`director_workspace`、`production_images` 无匹配；未找到移动制作画布/导演台对应生图入口。该结论限当前源码/搜索符号，不是运行时页面遍历。
- 移动聊天仍有共享工具与采用能力：`lib/mobile/pages/novel_chat_page.dart:1691–1707`、`chat_session_page.dart:128–138` → `lib/mobile/widgets/chat_image_actions.dart:26–73` 手工设头像/追加角色或物品照片。这不等于编辑页有自动生成入口，也不支持任意聊天 `delta.images` 的采用。

## 4. 其他 handoff 扫描分类
| 入口与源码 | 实际目的/调用链 | 分类及理由 |
| --- | --- | --- |
| 物品 `novel_editor.dart:2871–2893` | Item photo → 自动聊天 | 已报告同 bug 基准；日志由主会话核对，本研究不重复设计其修复。 |
| 大头照 `novel_editor.dart:3048–3075` | 已有专用模板 → Run → 图片卡 → 手工设头像 | 安全保留，未证故障，详 §1。 |
| 角色照片 `novel_editor.dart:3078–3101` | 通用照片文本 + 角色引用 → 自动聊天 | 不确定/静态风险，不能列为已证同 bug。 |
| 地图 `novel_editor.dart:456–485`；移动 `lib/mobile/features/map/studio_page.dart:321–335` | `lib/shared/models/map_agent.dart:10–35,55` 明确 Read/AgentSkill/Run help map，提交制图草案，不立即生成/采用 | 安全保留，不是遗漏照片命令；未深验地图最终生图。 |
| 导演台识图 `novel_editor.dart:4564–4572` | 带图识别 → 搭建站位参考 | 安全保留，输入图不代表输出照片需求。 |
| 制作问 AI `novel_editor.dart:4548–4559` | 无文件时仅 `AiChatShortcutDraft(autoSend:false)` | 安全保留，是可编辑聊天草稿，不是图片提交。 |
| 编年史/快速开书/续写 `novel_editor.dart:998,3737,4537` | 章节整理/创作开场/文本续写 | 安全保留；同为自然语言 handoff 不能推成图片错误。 |
| 剧场/角色扮演/独白/会议 `lib/desktop/features/{theater,roleplay,monologue,council}/panel.dart:89/91/91/106` | `run.handoff` 把对话/剧本上下文交给写作会话 | 安全保留；非专用生图入口。 |
| 下一步新会话 `lib/desktop/widgets/ai/chat/panel.dart:1278–1293`；移动 `novel_chat_page.dart:1138–1149` | 用户建议 prompt/模型选择进入新会话 | 通用入口自身安全保留；内容任意，未验证具体建议执行，不能静态判生图故障。 |

## 未验证项 / 给主会话的边界结论
- 独立源码调查未发现第二个可确定“已发生同 bug”的入口；唯一近似风险是桌面角色资料“生成照片”，应保留为调查结果而非默认修复项。
- 无真实模型遵循、HTTP 调用、设备 UI、权限弹窗、失败重试或最终采用的运行时验证；本报告不是端到端通过证明。
- 未深验所有地图/封面/SDK 流式图片处理，不扩展聊天直接图片完整支持；本次结论不要求修改制作、导演台、四视图、工具描述或技能。
