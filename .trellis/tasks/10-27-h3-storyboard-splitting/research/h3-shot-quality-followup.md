# 第三轮：H3 可拍分镜与全参考成稿

## 最新授权与边界

用户已审阅五文件最小方案及版本不确定性，并明确回复“你去改吧”“按 h3 的格式拆得好一点”。这是第三轮实施授权，不是批准远程模型目录、另装整套官方 Skill 或视频接口改造。前两轮均为历史已交付范围；本轮仅执行下述五文件。

保留中文正文、原对白/画面文字、H3 固定字段与标记、既有模式/其他模型支持、当前 ID/资产/用户覆盖语义。约 5 秒是软偏好，不能改成统一 8 秒或强制逐秒表。开发期间不重写已有业务分镜、不自动绑定素材、不真实调用模型/生成视频、不访问 Debug/Release 数据库。

## 官方核查与当前不足

本轮从用户给的官方 GitHub 仓库只读获取：
- https://github.com/MiniMax-AI/MiniMax-H3/blob/main/skills/README.md
- https://github.com/MiniMax-AI/MiniMax-H3/blob/main/skills/h3-prompt-writing/SKILL.md
- https://github.com/MiniMax-AI/MiniMax-H3/blob/main/skills/h3-prompt-writing/references/base-en.txt
- https://github.com/MiniMax-AI/MiniMax-H3/blob/main/skills/h3-prompt-writing/references/ref-en.txt

官方核心要求包括：先识别实际输入、Ref2VA 六段、稳定引用、每镜构图/位置/动作/摄影机/声音/参考作用、切点在总时长内，以及不要写成 plot summary。它不是收费生成工具，没有统一每段 5 秒规则；其他专用动画或游戏菜单 Skill 的固定风格/逐秒模板不直接移植。

已读项目主 SKILL.md、production.md、storyboard.md、shot-recipes.md、video-prompts.md 和现有 H3 附件。原有附件已有拍法/视域原则，不能谎称完全没有规则；但主流程和回读检查没有把它们收敛为每次拆分都要落实的可拍交付标准。用户样例证明这次输出欠具体，不足以证明该轮未加载附件、安装版本错误或底层视频接口错误。

样例：卧室电脑游戏，十二艘巡洋舰集火母巢，然后“画面转向键盘”，手操作红点并输入 GG，结尾屏幕保持游戏结束。问题是转向未确定为切镜/连续运镜、手部取景与屏幕结尾未衔接、设备指点杆位置不准、5 秒没有动作与切镜预算。不能靠再套字段名解决。

## 五个允许的产品/测试路径

1. `assets/official_skills/screenplay-production/SKILL.md`：入口明确“原文事项 → 可拍镜头计划 → 按目标模型编写 → 逐 Shot 核对 → 保存回读”。局部任务不重跑整集；按需读附件，不全量预读；主文件保持短而可执行，不复制六段模板或工具 schema。
2. `assets/official_skills/screenplay-production/references/production.md`：在原有拆分/写后核对中落实镜头计划与门槛：观众看到什么变化，画内范围/景别机位，主体起点动作终点，固定/明确切镜/有方向与停点的运镜，声音和自然对白的时长，可见结束画面。计划是编排核对依据，不是另一个保存资源或要塞进最终 prompt 的格式。
3. `assets/official_skills/screenplay-production/references/shot-recipes.md`：保留原四个配方，追加屏幕/设备操作的反例→可拍计划→H3 全参考六段中文教学成稿→验收。例子按原事件顺序保留十二艘、母巢、指点杆和输入 GG；不擅加发送/人物念 GG 或新剧情。输入只是教学假设，真实 ref 占位符必须替换，不能冒充实际素材。
4. `lib/shared/services/bundled_official_skills.dart`：仅剧本制片由 v2 升 v3、更新 contentHash/updatedAt，不改其他 Skill/loader/路径/同步器。
5. `test/shared/services/bundled_official_skills_test.dart`：真实 loader 新增少量有业务意义的回归，旧中文/字段/标记/打包/链接/hash/目录守卫不减弱；production version 期待更新到 3。

H3 格式真源 `references/minimax-h3-prompts.md` 已完整保留官方结构与中文适配，本轮不重复重写它，也不改 UI 的拆分请求。新教学例子引用该附件定义，不建立另一份格式标准。

## 内容合同

- H3 或明确 H3 目标按现有对应附件编写；H3 正式 prompt 不混入通用 Shot 的头部/【起止s】/首帧/结束状态壳，也不把计划表、验收记录或待办混进正文。
- 用户明确全参考且已有实际绑定图时，交付 subject_definitions → summary → retention_analysis → detailed_description → overall_soundscape → non_diegetic_music；每张图按实际可见信息说明用途，不凭标题猜图。真实 ref 必须来自已有输入。
- 用户明确全参考但素材尚未实际绑定时，可先存完整可拍草稿/计划，并在交付说明标“参考待绑定”；不伪造 input_id/占位标签，不自动换成纯文生视频最终稿，不声称已具备全参考生成条件。其他正常 T2VA/帧模式保留，不全局禁用。
- 写清第一镜取景/机位/可见主体及起点；必要切镜为递增且位于总时长内的 H3 时间码；运镜写从哪里到哪里、方向、幅度/速度/停点中有意义的部分。固定镜头合法，不堆无意义焦段或强制切镜。
- 动作阶段和自然对白先于片段时长；按渠道可接受整秒配置，约 5 秒仅偏好。不能强行加速、删戏或用同一时长填满所有条目。示例可选 8 秒但不能替代为新默认；一条视频条目可含多个 Shot，不把每 Shot 另建条目。
- 每镜结束状态必须在它的取景中看得见；屏幕/文字/软件状态需屏幕可读机位或返回屏幕，手部特写不能凭空证明屏幕结果。屏幕内游戏不变成卧室里的实体太空战；精确游戏内容/舰船计数/文字只作为要求，不承诺文字生成保真。
- ThinkPad TrackPoint 教学设定应在 G/H/B 之间；不靠泛称“键盘上方红点”让模型猜设备。GG 是输入文字不是人物对白；若原文仅说输入，不新增按 Enter 发送。
- 教学例子先说明假设与非真实绑定，最终生产成稿前须读取实际素材并替换；不把例子当用户作品事实，不发起任何生成。
- 拍法模糊、动作/时长不自洽、结尾在画外或要求的真实引用缺失时，修正或交付草稿/缺口，不报正式成稿完成。这个门槛是 Skill 的工作要求，不宣称新增了运行时自动质量校验器。

## 版本与升级

本次重新核对本地最新正式 tag：不存在，不能据此认定当前 v2 已发布或未发布。此前向用户明确建议本轮 v2→v3，以让已有官方安装使用现有版本比较升级，用户随后明确批准实施。以本轮独立授权维护 v3/hash/日期，不泛化先前 v1→v2 例外；不写临时发布状态源码注释，不新增 hash fallback，不直接改安装库。

## 验证与诚实边界

先新增真实附件加载回归 RED，再改三份文案和 production 元数据 GREEN。串行跑 `bundled_official_skills_test.dart` 和未改的 `official_skill_sync_test.dart`，窄范围 analyze/format、hash 独立重算、diff/相对链接/范围检查。所有 Flutter 用 FVM、--no-pub --concurrency=1、timeout 和完整日志，禁止并行。

回归至少覆盖流程顺序、非固定 5 秒、H3 专用格式不混通用外壳、全参考真实输入与未就绪边界，以及六段示例的字段顺序/时间码/可见结尾。不要只对新加口号做逐字断言；用教学样例作为可检查的交付证据。

静态测试仅证明 Skill 文本、资源和既有升级机制，不能保证真实 Agent 遵守、用户安装已更新或 H3 成片质量。主会话必须看实际 diff/日志，随后独立 gpt-6.1-sol check；按用户授权自动 scoped commit，不 push/amend。远程模型目录规划保持独立未提交。
