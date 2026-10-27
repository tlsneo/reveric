# 小说改编创建入口与当前执行边界

> 适用性更正：用户最新明确，材料直接粘贴进入剧本相关界面，可能是小说、故事草稿或已有剧本，不需要选择小说作品。本记录仅保留已有可选“从小说改编”入口的源码事实，不代表本任务输入流程；下方原有入口建议已被最新 PRD 的直接粘贴需求替代。

## 已核实的创建路径

- 桌面：`lib/desktop/pages/home.dart:573–584` 的 `adaptNovel` 通过 `NovelFormPrefill.adaptationOf` 打开创建表单；保存后 `createNovel` 调用 `NovelActionsService.createNovel`（约 `259–292`），随后进入 `WorkspaceEditorPage`（约 `300–313`）。`openChatOnEntry` 仅对小说为 true，剧本不是创建后自动打开聊天。
- 移动：`lib/mobile/pages/library_page.dart:77–92` 的 `_openAdapt` 进入 `MobileNovelCreatePage`；保存后创建目标作品并导航到 `MobileWorkspaceEditorPage`（`lib/mobile/pages/novel_create_page.dart:282–309`），其 `openChatOnEntry` 同样只对小说为 true。
- 共享预填：`lib/shared/models/novel_form_prefill.dart:25–38` 将 `contentKind` 设为 screenplay、类型设为 adaptation，并记录 `sourceNovelId`；沿用原著作者、简介、分类、标签，但不预填封面。
- `lib/shared/services/novel_actions.dart:124–168` 保存来源关系并初始化内容库；`178–202` 对剧本调用 `ScreenplayService.createInitialStructure`。
- `lib/shared/services/screenplay_service.dart:93–160` 的初始结构创建 screenplay、第一季、第一集及关联剪辑工程，不读取原著章节，也不提取人物、道具、地点或场次正文。

结论：这条“添加/改编”保存路径当前创建的是带来源关系的剧本工作区，不是一次已执行的小说改编任务。不能把用户在创建表单选定来源当作已完成提取/写场的证据。

## 可以复用的上下文与能力

- `lib/shared/models/ai_chat_models.dart:319–415` 保留来源作品上下文；`lib/shared/services/ai/prompts/prompt_fragments.dart:108–145` 可以向 Agent 提供目标剧本和原著的独立工作路径。
- 跨作品工具具备读取来源作品的能力；这种可用能力与实际任务执行需要区分。目标剧本的实体引用仍必须使用目标作品内的真实 ID。
- 「剧本写作」现有 adaptation/source-analysis/adaptation-decisions/episode-planning/scene-writing 附件覆盖原文分析、取舍、分集和写场；人物、地点、道具提取/目标条目复用目前没有在创建保存链路中形成完整任务交接。
- `lib/shared/services/ai/tools.dart` 已有 `characters`、`locations` 和 `items` 资源，`items` 对应物品。不能仅因用户叫“道具”就新造 props 表或未存在的场次字段。
- 已有剧本编辑器可由用户主动打开 AI 助手；移动示例位于 `lib/mobile/features/screenplay/editor_page.dart:148`。
- `SuggestNextAction` 的 feature 白名单只列 council/theater/roleplay/cover studio（`lib/shared/heuristic/chat_next_action.dart:18–23`）。这仅说明未见专门改编 feature，不能据此否认通用 prompt/chat 发起能力。

## 产品决定与未验证项

- 是否增加创建后的“整理为剧本”明确操作、复用聊天发起，或在创建时提供显式的执行选项，是用户产品决定，不是从当前代码推导出的授权。
- 不建议把普通保存静默扩大成读取整本原著、收费 AI 调用和目标库批量写入；应明确本次材料范围和启动动作。
- 应保留已有原著和目标角色图片/资料，提取结果不等于自动生成媒体。
- 未运行测试、模型请求或业务数据库操作；未获得用户原文与实际失败/质量样本。

本记录由主会话复核创建/初始化链路后整理；没有从项目私有本地背景文件复制内容。
