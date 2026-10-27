# 其他 UI → AI 助手任务入口核对（R5，只读）

## 结论与证据边界
- **新增一个明确的交接字段缺陷**：桌面大纲节拍卡的“生成章纲”丢失所点击的 beat 身份；这是源码可证的目标歧义，不是已复现的模型故障。另记录两项静态/需求不确定性；既有角色照片风险仍以 `entry-audit.md` 为准。
- 重点是用户点击后的任务契约，不以“自然语言”“没有硬编码 Run 命令”判错。正文创作、地图设计、导演台搭建确实需要应用操作；总结、讨论、候选文字则不天然要求写库。
- **物品照片外观虽是“生成”，实际是 autoSend 助手交接，不是专用图片 API 直调。** 本轮不重复图片调查、不扩大已批准三文件实施；正常制作生图不改。
- `python3 ./.trellis/scripts/task.py current --source` 返回无当前任务；按派发指定任务归档，未新建/启动任务。只新增此报告，未修改产品/测试/manifest/spec，未运行 Flutter、应用模型、业务数据写入或委派/commit。

## 搜索覆盖与入口枚举方法
- 入口枚举以 `lib/desktop`、`lib/mobile` 为根，跟到 `lib/shared/{models,hooks,widgets,providers,services}` 中直接相关的目标契约；搜索 `AiChatHandoffDraft(`、`AiChatShortcutDraft(`、`PendingChatHandoff(`、`onContinueWriting`、`onRunShortcutAction`、`onAsk/ask`、`onOpenAssistant`、`workspaceAction/TaskPromptAction`、`chatCompletion/Detached` 等。
- 主搜索仅取手写 Dart；排除 `.g.dart`、`.freezed.dart`、`.drift.dart`，不查 `docs/`、build、生成目录或第三方实现。个别文件名列表/宽 glob 返回了生成/third 路径，未据此深读实现或纳入结论。模板仅查相关 `assets/prompts`、bundled/official skill；测试仅查相应入口和工具契约。
- 清单是**有限的源码可发现入口类别**：桌面快捷菜单、选区、继续写作、快速开书、发布整理、场次/分镜、导演台识图、地图助手、四种创作模式交接、下一步建议，以及额外发现的命名/封面轻量文本调用。不是运行时逐页遍历，也不枚举用户自定义快捷方式正文。
- 共享 handoff 消费 → ChatSessionController → ChatTurnRunner 的工具开放、错误与重试由主会话另查。本报告以“进入共享 Agent 聊天”为执行方式，不重复该 runtime 审计；仅定位入口目标、专用 prompt、实际业务工具 handler 与结果边界。

## 入口矩阵
“符合用途”仅表示当前源码没有此类误路由证据，不是模型/设备端到端通过；autoSend=false 表示先给用户编辑/确认，不是未执行 bug。

| 类别 / 点击入口（file:line） | 输入、目标与执行方式 / autoSend | 结果边界、结论与已有测试 |
| --- | --- | --- |
| 桌面章节“总结本章”、润色、设定扩写等快捷菜单：`lib/desktop/widgets/workspace/novel_workspace_panel.dart:1605–1630`；默认任务 `lib/shared/models/ai_shortcut_action.dart:142–191` | `novel_editor.dart:2891–2966` 取当前资源真实 ID/section 引用，原样传 `action.prompt`，autoSend 取用户配置；内置默认 false（模型 `:110`）。走共享 Agent 聊天，不是旧 workspace_action 直调。 | **总体符合用途**：章节/条目定位存在；用户可改草稿。总结/兑现方案/创作规划未必需要写库，不因没有命令判错。正文/设定修改的写入规则见下文。节拍特殊缺陷另列 F1。未找到覆盖“点击快捷任务→完整目标”的专门测试。 |
| 旧“工作区总结/扩写/改写”模板：`lib/shared/services/ai/prompts/use_cases/task_prompt_use_case.dart:18–36`；`assets/prompts/task/workspace_action.md:9–26`；shortcut 三模板注册 `prompt_registry.dart:220–240` | 模板输入 title/meta/content，要求直接输出处理后文字；**本次在手写 lib 与 test 搜索没有找到 workspaceAction/TaskPromptAction 的外部调用方**，shortcut 三 ID 也仅命中定义/注册。 | **非当前可证 UI 执行链**；不可把这些“只输出文本”模板当作现有所有按钮的 prompt，更不能据此批量迁 Agent。若用户指的是旧版 UI，需要实际版本/入口补证。 |
| 桌面节拍卡“生成章纲”：`outline_timeline_strip.dart:706–735`、`outline_architecture_view.dart:694–721`（均在 `lib/desktop/widgets/workspace/`） | 默认 prompt “当前选中的节拍和所属大纲”（`ai_shortcut_action.dart:137–140`），却只回传 action；宿主只附整条 outline 引用。autoSend 默认 false。 | **明确字段缺陷 F1**：同一大纲不同 beat 发出的任务不能区分点击对象。Read 已能按 beat 路径读取，不是工具缺能力。无点击目标回归判据，详下。 |
| 桌面正文选区“加入聊天”：`novel_editor.dart:2969–2990`，UI `chapter_editor.dart:1146` | `AiContextReference.selection` 带选区文字快照、章节标题及唯一标识；空文本 draft，autoSend 默认 false。 | **符合用途**：只是附上下文，未承诺改写或写入；不应强加 Run 或自动发送。章节正文仍由后续明确任务/工具修改。 |
| 桌面/移动概览“继续写第 N 章 / 开始第一章”：`desktop/widgets/workspace/hero.dart:143,183` → `desktop/pages/novel_editor.dart:4535–4545`；`mobile/widgets/overview_panel.dart:485–489,559` → `mobile/pages/novel_editor_page.dart:816–830` | 传按钮包含章号的文本，当前作品作用域；两端 autoSend=true，新聊天目标。不是现成正文生成 API。 | **符合当前用途**：是创作任务，Agent 需 Read 定位章节/大纲再写；并非只求总结。数字章号不等于 UUID，但可用现有章节查询定位；不能单凭未带 UUID 宣判错章。特殊/重复章号是否需要澄清需运行证据。 |
| 移动概览“续写/剧情/设定”提示 chip：`mobile/widgets/overview_panel.dart:500–504,572–575` → `novel_editor_page.dart:837–851` | 作品级草稿、自然语言 prompt，PendingChatHandoff 默认 autoSend=false。 | **符合用途**：先编辑，不保证点击即写库；没有对象时可由用户补充。移动快捷方式管理页存在，但 `AiShortcutActionDefinition`/enabled location provider 搜索未发现桌面同款菜单的移动执行调用。 |
| 快速开书/创作向导：`desktop/pages/home.dart:352–375`；移动 `library_page.dart:304–330`、`novel_create_page.dart:335–366` | 用户先确认故事想法 → 创建草稿作品 → `shared/widgets/quick_start_idea.dart:27–30` 明确使用“创作向导”、保留已给信息 → 桌面 `novel_editor.dart:3720–3748` / 移动 `novel_editor_page.dart:205–231` autoSend=true。 | **符合用途**：目标作品已建立，向导不是一次性摘要；skill 有 Read/profile、Run rules/skills 与确认后 Write/加入书架契约（下文）。已有 `test/shared/widgets/quick_start_idea_test.dart:29–78` 验证双端确认/取消；桌面/移动 quick_start 页面测试存在，未在本轮运行。 |
| 发布章节并调用编年史者：桌面 `novel_editor.dart:965–1015`；移动 `chapter_editor_page.dart:1001–1050` | 先发布（移动先 flush），带真实 chapter 引用；移动另有 chapterId/number。`assets/translations/zh-CN/chapter.json:6` 要求委派、Read 正文、工具保存、不改正文；autoSend=true。 | **符合用途**：不是“只写摘要”。`assets/prompts/agent/chronicler.md:1–5` → 连续性 skill 的 Read/Create/Write/Remove；已有 `chronicler_character_contract_test.dart:26–140` 有 prompt 边界与工具写入判据，不代表模型真实委派成功。 |
| 桌面场次/剧本普通助手；移动剧本底栏 AI 助手：`desktop/pages/novel_editor_ai_area.dart:106–119`；`mobile/features/screenplay/assistant_bar.dart:146–153` → `editor_page.dart:148–178` | 桌面传 workspace section/item 与季/集；移动先 flush 文档/工作区，再传季/集、多季标志打开聊天，**不预置任务、不 autoSend**。 | **符合用途**：移动这是打开助手而非“自动处理当前场次”，未带 sceneId 不能单独判错。桌面场次列表的 add/openScript 是本地创建/导航（`features/screenplay/scenes.dart:72–95`），不是假 AI。写场由 Agent 任务定位并写 elements（下文）。 |
| 桌面分镜“AI 拆分镜”：`desktop/features/storyboard/region.dart:389–405` → `production/region.dart:181–184` → `novel_editor.dart:4548–4560` | prompt 固定真实 `/scenes/id` 与 `/elements`、角色/地点、当前集旧分镜，要求生产/操作 skill、写本场草稿且回读，明确“不自动生成媒体”。无文件分支 autoSend=false，用户确认才发。 | **符合用途且明确要求应用写入**：不是只返回分镜文字；Create/Write `/clips` 有执行器。`test/desktop/features/storyboard/region_test.dart:165–260` 断言两个场次各自真实路径、点击不写库、技能/回读/不生媒体边界。没跑测试，不保证模型遵循。 |
| 桌面导演台“AI 识图”：`production/region.dart:123–152`；prompt `production/scene_recognition.dart:52–57`；宿主 `novel_editor.dart:4561–4573` | 用户选图与插入/覆盖 → 真实图片 XFile 附件 → 新 Agent 聊天 autoSend=true；任务要求在当前导演台还原空间、道具、人物与机位，不是生成图片。 | **符合操作用途，依赖当前导演上下文**：`shared/widgets/screenplay/director_workspace.dart:72–77` 上报 binding.stagingId，经 `shared/hooks/use_production_subpage.dart:14–36` 发布；实际写入是 Run stagings，不是文字采用。覆盖先清空并 flush，但可撤销（`:152–168`）；`test/desktop/director/workspace_test.dart:363–383` 明确测试此边界。附图/目标在实际发出时是否仍一致需主会话 runtime/日志验证，不能声称已验证。 |
| 双端地图“让 Agent 设计”：桌面 `features/map/map_cartographer_panel.dart:130–149` → `novel_editor.dart:456–485`；移动 `features/map/studio_page.dart:321–349` | 真实地点 ID、`/locations/id` 引用、当前风格、子图尺度；共享 `models/map_agent.dart:10–35` 指向 Read → 适用 AgentSkill → Run help map → 提交草案，两端 autoSend=true。 | **符合用途**：不是漏了即时图片调用。Run map draft 只交制图参数；用户应用草案、点生成才走专用图片服务。`map_agent_contract_test.dart:83–117,146–165` 与 `tools_run_test.dart:1464–1497` 有契约/无出图断言；移动 `draft_navigation_test.dart:17–118` 检查本轮结束再返回目标。 |
| 小剧场“切写作/写成正文”：桌面 `features/theater/panel.dart:80–108`；移动 `features/theater/page.dart:182–205` | `use_theater_run.dart:434–480` 先保存来源，带完整剧场 transcript 与场景约束；有写成正文 instruction 时 autoSend=true，否则仅交接。目标 orchestrator。 | **符合用途**：对话素材交给创作任务，不应直接把剧场对白当已保存正文。`handoff_service.dart:165–202` 保留来源会话引用；正文需要 Agent 写章节/场次。已有 `handoff_service_test.dart:47–96` 测格式，非 UI/真实模型 E2E。 |
| 角色扮演/独白/圆桌切写作：桌面 `features/{roleplay,monologue}/panel.dart:83–105`、`council/panel.dart:98–123`；移动对应 page `:155–166/:167–179/:204–215` | `shared/hooks/use_{roleplay,monologue,council}_run.dart:365–417/:346–398/:447–499` 保存来源，交 transcript 或总结+决定/约束/未决问题；桌面草稿默认不发，移动创建目标会话并保存 handoff 用户消息，不触发模型发送。 | **内容交接符合用途**：圆桌摘要是上下文而非代替写库，原始来源可追溯。角色扮演/独白的目标 provider/model 在桌面草稿分支丢失，列静态策略风险 S1（不能推成必然调用错误模型）。 |
| 双端建议/空态/“新会话继续”：桌面 `widgets/ai/chat/panel.dart:1250–1305`；移动 `novel_chat_page.dart:1116–1172`；共用目录 `shared/heuristic/chat_next_action.dart:239–280` | 提示类填 composer；continue_in_new_chat 携来源 session/work、当前引用、模型/推理配置；默认不自动发送。功能跳转白名单为圆桌/剧场/角色扮演/封面，seed 作预填。 | **符合用途**：用户可编辑任务不需硬编码操作命令；新会话与延续会话语义有区分。`test/shared/services/ai/handoff_service_test.dart:13–44` 明确断言保留来源/模型、autoSend=false；`test/shared/heuristic/chat_next_action_test.dart` 有白名单/形状判据（只检索，未逐例深读）。 |
| 额外发现：双端共用起名助手 `shared/widgets/name_assistant_button.dart:184,205–221` → `services/name_generator_service.dart:369–406` | type/作品/实体描述/批次数 → chatCompletionDetached，返回名字列表，用户选中并确认才回调字段；不是工具执行任务。 | **符合轻量文本用途**，不应强迁 Agent。未深验每个宿主传入实体描述是否齐全，未跑模型。 |
| 额外发现：双端封面“读稿档案” `desktop/features/cover_studio/studio_page.dart:134–167`、移动对应 `:161–195` | 进入未有档案时一次自动读稿，或手动重读；`shared/services/ai/cover_brief_service.dart:143–231` 用开头三章摘录+书名/简介 → 单次 chatCompletion JSON → 服务校验并保存 novel_state 档案。 | **符合用途**：模型只抽文本、应用服务负责落档，并非让聊天模型画封面。失败保留旧档/复位 reading；`test/shared/services/cover_brief_service_test.dart` 已有对应测试，未跑。封面实际制图不在此轮深查。 |

## 追到实际执行的关键契约（不重做技能加载实现）
1. **创作/改稿**：`assets/prompts/agent/orchestrator.md:32–37,43–48,67–71,103–111,127–135` 已区分写正文必须先写入、剧本结构先加载工具 skill、纯讨论不擅自写库、局部改稿限定目标字段。`writer.md:13–18,48–49,65–75` 要求真目标/真引用、结构化 elements、失败/预览不得冒充已保存。
   - 章节已有 `lib/shared/services/ai/tools_create.dart:475`、Write handler；剧本场次/元素 `tools_screenplay.dart:282–385,388–442` 真正按 scene/element ID 读取和创建。不是“所有写作入口最终都只要求文字”。工具可用性/权限是否在当前 turn 正确注入由主会话检查。
2. **快速开书**：`assets/bundled_skills/setup/SKILL.md:29–43,87–120` 明确先 Read profile/规则/技能/资料，确认后写 profile 与 AgentRules，加入书架须 AskUser。入口已提供想法和准确技能名称；无需另造开书专用生成 API，也不应绕过确认自动覆盖元数据。
3. **发布整理**：`assets/prompts/agent/chronicler.md:3–5` → `assets/bundled_skills/story-continuity/references/novel.md:11–16,62–69`，读取证据并使用 Create/Write/Remove 保存事实、brief/story_state；outline 只读、不改正文。现有 chronicler 测试含直接工具写入示例，其中 outline 写入示例不能当成当前 skill 允许改 outline 的证明，更不能当成发布入口已成功自动整理的证据。
4. **分镜草稿**：`assets/bundled_skills/screenplay-tools/SKILL.md:14–40` 与 `references/clips.md:7–20` 规定 `/clips`、scene_id、排序和真实输入；`lib/shared/services/ai/tools_storyboard.dart:102–144,229–248` 实际调用 StoryboardEditOrchestrator create/moveOrSave。只有后续明确生成才走 `Run production generate-*`，不能把“拆分草稿”升级为付费媒体生成。
5. **导演台识图**：`screenplay-tools/references/stagings.md:1–5,21–42` 已给出 `Run stagings read/apply/write` 和真实 staging_id；`lib/shared/services/ai/stagings_run_command_handler.dart:27–41,59–110,178–202,283–333` 校验 ID/选项、查询文档、原子调用 `service.save`，返回保存版本/命令结果。入口虽未写死命令，但宿主有真实 staging 上下文，Agent 有现成操作说明，不能据自然语言认定“只做识图摘要”。
6. **地图的三段边界**：`tools_run.dart:1122–1234` 的 map draft 校验 location/prompt/style 等，调用草案 callback，不生成图片；`shared/widgets/map/map_generate_fields.dart:122–130` 用户“应用草案”只填表；`shared/hooks/use_map_generate_form.dart:102,218` 转请求/应用表单；用户点生成后 `map_studio_controller.dart:157–237` → `generate_map_orchestrator.dart:203–247` → `map_studio_providers.dart:76–86` 专用图片服务。
   - **不能把地图成图说成总是手工采用**：当前 controller 生成后 `await adopt()`（`:237`），保存地图/识别在 `:261–334`。但 Agent 提交设计草案本身不会生成/采用成图。
   - 成图地名回读是 `map_place_name_reader.dart:60–104` 的带图 chatCompletionDetached 结构化识别，不是要求该 chat 生图或操作地图工具。

## 新发现与不确定性（按价值排序，未擅自修复）
### F1 — 明确交接字段缺陷：节拍卡点击目标丢失
- **具体输入**：同一 outline 有 beat A、beat B；分别在两张卡片菜单点内置“生成章纲”。默认 prompt 固定说“当前选中的节拍”。
- **调用证据**：两种卡片菜单只调用 `onRunShortcutAction(shortcut)`（timeline `:735`、architecture `:721`），不传 beat.id/index/标题/章节范围。父层原样转发该回调（`outline_editor.dart:294`）；`novel_editor.dart:2891–2915,2952–2966` 只按全局 selection 取 outline.documentId、标题引用及固定 action.prompt。
- **缺失证据**：`currentAiWorkspaceContent()` 对 outlines 返回整条 `toDocumentContent()`（`:3193–3194`），meta 也无 beat（`:3218–3234`）。它能给全大纲，不能编码用户点击了 A 还是 B；两次 draft 的任务/引用相同，差异只有时间戳 ID。
- **下游能力存在**：`tools_read.dart:1150–1185` 已返回 beats 的真实 ID/path，并支持单 beat 读取。问题是入口没指定哪一条，不能靠“多 Read 一遍整大纲”恢复用户的点击意图。
- **影响/限定**：用户手工补明目标可规避；默认 autoSend=false，点击本身不误写库。可证的是交接目标丢失，尚无实际模型错写日志。现有 outline global/golden 测试主要验证布局，未找到 beat 点击目标断言。
- **后续如要修**：先向主会话确认扩大范围；最窄方向是让卡片 handoff 带被点击 beat 身份/路径和必要范围，不必修改工具 description/schema 或重写技能。

### S1 — 静态风险：独白/角色扮演的目标模型跨端交接不一致
- `use_monologue_run.dart:365–373`、`use_roleplay_run.dart:384–392` 的 `AiHandoffTarget` 含来源 providerId/model；移动走 `handoff_service.dart:229–243` 创建目标，会传入这两个字段。
- 桌面 `features/{monologue,roleplay}/panel.dart:86–97` 使用不创建目标会话的 draft 分支，只填 id/label/content/title，未复制 target.providerId/model；`novel_editor_agent_mode_area.dart:35–39` 原样转交。`toMessageContent()`（handoff_service `:165–202`）也不序列化 provider/model。
- **证实的是字段在此分支未传递**，不是已证错误模型调用：切回写作是否本来就应使用当前写作模型，需求尚未明确。需要确认跨模式继承策略，并对照真实新会话模型选择日志；暂不改模型配置或 handoff 通用 runtime。

### U1 — 需求不确定：文字草稿的“采用/落库”不能由按钮名推定
- 总结本章、规划、设定扩写默认是用户可改的聊天任务。`orchestrator.md:69,129–130` 同时要求未授权不改库、正式改稿与讨论稿分开；不能假定每次“总结”都应该 Write brief，也不能反过来把用户明确要求保存的任务只交付文字。
- 另有 `novel_editor.dart:3238–3275` 的 applyAiWorkspaceContent 及面板 `onApplyGeneratedContent` 参数，但当前 `message_renderer.dart:45–100` 未将它交给消息视图；全手写 lib 搜索只见声明/传参，无调用消费点。**不能把这个残存回调当作当前普通文字一键采用已经可用的证据**。
- 没有已确认的“某个总结按钮承诺自动保存/一键采用”的需求或失败输入，故不列必修缺陷。若用户期待落库，应先明确目标字段、覆盖/追加规则、确认方式，再核对具体任务与运行工具日志，不全局替换 prompt 或迁 Agent。

## 当前不应误报的边界
- 大头照、角色照片、四视图、物品照片及制作图片的细分结论沿用 `entry-audit.md`。角色资料照片仅有既有静态风险，不升级成第二个已发生故障；物品修复仍由实施代理负责。
- 导演台覆盖模式在交接前清空是现有明确可撤销行为，有测试，不应仅因先写空文档就声称数据永久丢失；但不能由静态测试承诺真实识图一定完成。
- 地图、导演台、正文任务有现成工具执行链，普通总结/名字候选有合理纯文字用途；两者不能混同。已有 chatCompletion **不建议统一迁 Agent**，任何迁移须另说明理由/范围并先确认。

## 未覆盖与验证限制
- 未运行 Flutter/单测/静态分析、未启动 UI、未调用模型/图片接口、未查真实供应商日志；报告中的测试均为**阅读到的现有判据，不是本轮通过记录**。不能声称“所有 AI 都正确”或“其他入口已跑通”。
- 未深读用户自定义快捷 prompt、每个起名宿主、封面实际制图、画布/全局浮动助手、后台记忆提取/梦境、所有 slash/技能注册加载实现、所有权限/工具注册/重试；这些不在有限 UI handoff 契约审计深查范围。
- 移动未发现桌面制作/分镜/导演台识图对应自动入口；移动剧本助手只有导航/季集上下文，本轮没有证明可自动针对当前场次。移动图片相关范围以原报告为准。
- 入口请求到执行之间的上下文实时变化、任务排队、远端模型是否遵循技能、是否真正调用工具和回读结果，需要共享 runtime 调查与实际日志。本报告不把“有 prompt/handler”当成运行成功。

## 本次是否扩大改动
**不扩大。本次只报告。** F1 可提交主会话作为后续最窄修复候选；S1/U1 先确认目标模型继承及保存期望。任何新增产品/测试文件、工具 description/schema、技能或正常媒体链改动，必须由主会话先与用户确认，不混进已批准的物品照片三文件修复。
