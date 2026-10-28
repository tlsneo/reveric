# H3 中文正文后续：证据与最小边界

## 用户最新要求

用户接受全参考模式把首尾帧作为普通参考的现状，明确要求先把 H3 提示词改成可直接阅读、编辑的中文。本轮不实施此前讨论的自动素材绑定、关键帧准备或连续生成流程。

## 官方证据与表述边界

- 官方云 API：https://platform.minimaxi.com/docs/api-reference/video-generation-v2-create 。`POST /v2/video_generation` 的 `content` 包含非空 `text`；官方请求示例直接使用中文“一个男孩在海边打篮球”。这证明中文是合法输入，不证明中文与英文成片质量相同。
- 官方结构化改写 Skill：https://github.com/MiniMax-AI/MiniMax-H3/tree/main/skills/h3-prompt-writing 。官方改写要求英文正文、原语言对白/歌词/画面文字；基础模式使用三段，全参考使用六段。
- 官方基础指南：https://huggingface.co/MiniMaxAI/MiniMax-H3/blob/main/docs/VIDEO_PROMPT_WRITING_GUIDE_base_en.md 。保留字段、首尾帧对齐、Shot、切点、说话人与台词标签。
- 官方全参考指南：https://huggingface.co/MiniMaxAI/MiniMax-H3/blob/main/docs/VIDEO_PROMPT_WRITING_GUIDE_ref_en.md 。保留六段顺序、参考标签与关系标记；正文中文是用户选择的项目适配，不声称原样遵循官方英文改写要求。
- 不新增 Context-IR 调用，不使用社区 ComfyUI 的模型名称、帧数或运行记录推断官方云 API 效果。

## 源码真源（实施前核查）

- `assets/official_skills/screenplay-production/references/minimax-h3-prompts.md`：开头强制所有正文英文，summary/detailed_description 再次要求英文，并使用 350–500 英文词建议；示例为英文正文。这是本轮语言差异的直接来源。
- 同目录 `video-prompts.md` 已负责实际模型路由、真实 ref 标签和用户语言偏好，无需复制 H3 模板或改其他模型附件。
- `lib/desktop/features/storyboard/region.dart` 已要求加载现有 H3 附件；本轮不改入口、模型选择或人工发送边界。
- `lib/shared/services/bundled_official_skills.dart` 中“剧本制片”当前 version=1，附件已登记；修改附件必须更新 contentHash/updatedAt。
- `lib/shared/services/official_skill_sync.dart` 仅当目录版本大于已安装 sourceVersion 才升级。保持 version=1 不会自动更新已有官方安装；不新增运行时 hash 比较或兼容层。
- `test/shared/services/bundled_official_skills_test.dart` 已覆盖附件完整加载、Flutter 资源打包、相对链接和整包 hash，可在原文件增加语言与格式守卫。
- `test/shared/services/official_skill_sync_test.dart` 已覆盖已有身份升级、同名本地内容及用户删除选择；只复跑，不改同步逻辑。
- H3 附件是桌面和移动端共用技能内容；不新增移动端按钮，也不改变非 H3 模型的语言规范。

## 发布状态与用户明确授权

本次执行 `git tag --list --sort=-version:refname` 没有输出，`git rev-parse --is-shallow-repository` 为 false。没有可供核对的本地正式发布 tag，因此不能把“没有 tag”解释为 version=1 尚未发布；也不能使用此前剧本写作的版本例外。

已向用户建议将“剧本制片”由 version=1 更新为 version=2，配合内容指纹和更新时间，使既有官方安装可走原有升级流程。用户在审阅该最小方案和发布状态不确定性后回复“行”，明确批准本次 v1→v2 和实施。这是对发布状态无法核实的显式处理，不是对 version=1 已发布的事实判断；不得在源码注释中写临时发布状态。

本轮不直接操作 Debug/Release 数据库，不覆盖本地化、自定义、停用或删除选择；不能声称用户设备的已安装快照已经更新。

生效链路已只读核对：`lib/main.dart:655` 在启动时 watch `officialSkillSyncProvider`；`lib/shared/providers/official_skill_sync_providers.dart` 读取官方目录并调用既有升级方法。`novel_agent_skill_providers.dart:526–600` 的 `upgradeNovelAgentSkill` 只升级 official 来源，用完整目录详情替换 prompt/references，并保留 id/name/enabled/sort_order 和本地 agentScopes；marketplace/novelLocal 返回不可追溯。用户需更新应用并重新启动，让现有同步流程执行，再发起新的拆分或改写请求；已保存的英文分镜不会自动翻译。这是源码行为确认，不是用户设备已执行成功的证据。

## 最小实施范围（已批准）

1. H3 附件：正文默认中文（不随 UI locale 切换），字段与固定格式标记保留；对白、歌词、画面文字保持原文。去除互相矛盾的英文正文要求和英文词数配额；三段和六段各提供可读的中文内容示例。对齐句、切点模板、ref/Subject/speaker/dialogue 等系统语法不翻译或删除。补充官方来源和中文适配边界，不抄入接口完整 schema。
2. 官方技能注册表：仅更新“剧本制片”的 version=2、contentHash、updatedAt；其他技能与列表身份不改。
3. 现有官方技能加载测试：验证三段/六段结构、关键标记、中文正文规则及示例、旧英文强制规则不存在、加载/打包/hash/链接保持一致。

不改生成 API、工具 description/schema、素材输入、参考模式、已有分镜或全局聊天提示词；不新增设置、服务、翻译资源或文件级 prompt 复制。

## 验证

- 先增加针对旧语言规则失败的定点回归，再修改附件和元数据；不移除 hash 守卫换通过。
- 串行执行官方技能加载整文件测试与已有同步整文件测试，使用固定 FVM 和 --no-pub --concurrency=1，完整日志先落文件。
- 对两个 Dart 文件执行窄范围 analyze/format，以及 git diff --check；检查只有三份产品/测试文件和本任务记录变化。
- 独立 gpt-6.1-sol 子代理复核已批准范围及静态证据。不调用真实 Agent/图片/视频服务；测试不能证明模型一定输出中文或成片质量。
