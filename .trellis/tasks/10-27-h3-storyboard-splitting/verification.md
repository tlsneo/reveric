# 验收记录

前部为已随 `0cb0c8a` 交付的第一轮入口请求修复；第二轮 H3 中文化和第三轮可拍分镜记录依次见后文。历史轮次的范围不覆盖用户后来单独批准的新范围。

## 第一轮规划与授权

- 用户确认仅修改 AI 拆分镜；最新确认未选模型默认 H3 提示词格式，已选其他模型保留其格式；不新增选择器，不自动选供应商/生成。
- 主会话核对了实际入口、现有 widget 夹具、H3 能力目录、输出参数与整秒限制；证据分散在两份 research 文档中。
- `task.py validate`：implement.jsonl 7 个真实条目、check.jsonl 7 个真实条目，通过。
- `task.py start`：已进入 in_progress，记录当前 unstable 分支。CLI 提示当前分支也是 base_branch；本任务不擅自建分支、创建 PR 或归档，后续若归档需要单独处理此既存工作流限制。

## 根因与同形入口检查

已确认的入口缺陷是 `StoryboardRegion` 拆分请求无条件要求通用 Shot 格式，覆盖了预期专用格式路由；这不等于已证明每次真实模型输出错误都由此造成。修复只针对入口契约。

主会话对 `lib/desktop`、`lib/mobile`、`lib/shared/services/ai`、`assets/prompts` 的 Dart/Markdown 执行了以下只读搜索：

```text
按其中的 Shot 格式|按.*Shot.*格式|将这一场拆成界面中的分镜
```

只命中本次 `lib/desktop/features/storyboard/region.dart` 入口。此为限定文字模式扫描，不声称覆盖所有语义类似的 Agent 行为；已有通用视频格式附件本身合法，不删除。

## 实施验证

实施子代理 `6cbfed54-bba6-4b5`，所有派发/续跑均显式 `gpt-6.1-sol`。主会话已核对两个产品文件的实际 diff 和下列日志结尾；完整命令及各轮失败见 `research/implementation-result.md`。

| 验证 | 结果 | 日志 |
| --- | --- | --- |
| 旧请求＋新回归 RED | exit 1，0 通过/1 失败，缺少完整 `/elements` 路径 | `/tmp/reveric-h3-split-red.log` |
| 修复后的 widget 整文件 | exit 0，1 通过/0 失败，覆盖两场按钮及原有刷新/删除检查 | `/tmp/reveric-h3-split-green.log` |
| 两个 Dart 文件 CLI analyze | exit 0，No issues found | `/tmp/reveric-h3-split-analyze.log` |
| 固定 SDK 格式检查 | exit 0，2 files、0 changed | `/tmp/reveric-h3-split-format.log` |
| 产品 diff 格式检查 | exit 0，无诊断 | `/tmp/reveric-h3-split-diff-check.log` |
| 两文件 LSP | 无 Dart server，不算通过；使用上述 CLI 验证 | 工具返回 `No LSP server configured for file type` |

### 验证中失败、根因与处理

1. 测试 matcher 参数数量错误：当前 `allOf` 超过位置参数上限，改为传 iterable；属于新增测试写法错误，未改生产逻辑。
2. 测试比较同值 Drift 行失败：行内 inputs 列表按身份比较；改为完整 `toJson()` 快照深比较，保留全部字段的无写入检查。
3. 新夹具在原 620px 场景出现 9px 溢出：新增 callback 使原先没有的拆分按钮参与布局。未改产品布局、扩大宽度、移除断言或吞异常；先在 1100px 验证真实按钮和请求，再通过局部 notifier 恢复原 `sceneActions:null` 配置，断言按钮消失且行快照不变，然后完整执行原窄窗口/删除回归。**带拆分按钮的 620px 页头仍有已知 9px 溢出，未修复，不声称该组合通过**。失败日志保存为 `/tmp/reveric-h3-split-green-failed-action-enabled-620.log`。

## 独立检查

独立 `gpt-6.1-sol` check 子代理 `d9c7bdd8-bc93-487` 已完成，范围内无剩余阻断项；主会话再次核对其实际 diff、报告与完整日志结尾。

- 修正一处表达歧义：未选模型的默认分支也明确要求加载 `minimax-h3-prompts.md`，不只说默认 H3；回归断言把条件、附件和默认格式绑定到一起。
- 独立认可夹具隔离：1100px 检查真实拆分按钮，随后恢复原无操作回调的 620px 场景；不代表带按钮的 620px 布局已修复。
- 最终串行复验：widget **1 通过/0 失败**；两个文件 analyze 无问题；format **2 files/0 changed**；diff 检查为空，均 exit 0。日志为 `/tmp/reveric-h3-split-check-{test,analyze,format,diff}.log`。
- 审查修改后首轮 format 检查曾 exit 1（新增断言换行）；按 pinned formatter 修正后，整套 test/analyze/format/diff 再跑通过。首次格式日志保留于 `/tmp/reveric-h3-split-check-format-first.log`。
- 最终仅两个批准的 Dart 产品文件变更；无 Skill、API、数据库、布局或移动端入口改动。详情见 `research/check-result.md`。

## 验收闭环

| 判据 | 实际证据与结论 |
| --- | --- |
| A1 | 两个真实按钮输出对应场次及 `/elements` 路径；默认分支显式加载 H3 附件；请求保留非 H3 格式选择，测试通过 |
| A2 | 请求含约 5 秒偏好、合法时长、对白/动作/连续性优先及合理拆分边界，测试通过 |
| A3 | 已知输出 fps/帧数规则才换算，未知不猜且保留整秒/API 边界，测试通过；未声称真实帧数控制 |
| A4 | 每次点击后所有 clip 完整 JSON 快照不变；原刷新/取消删除/软删除/资产保留检查通过；调用链仍为 autoSend:false |
| A5 | 独立复验与窄范围分析、格式、diff 检查均通过，主会话核对；实际生成/设备验收与已知窄屏布局不包含在此通过结论中 |

按用户预授权，只提交本任务的两个产品文件与任务记录；不 push、不 amend、不混入其他任务。提交哈希由最终 Git 结果和用户汇报记录，任务归档单独处理。

## Spec review

已阅读 `trellis-update-spec`、frontend index/quality guidelines 与现有 `.agents/rules/agent-skills.md`、`ai-calling.md`、`testing.md`。本次未改变函数/工具/API/schema/运行配置或跨层 payload 契约，不触发基础设施/公共契约的七节规格要求。格式由现有 Skill 拥有、入口只表达任务偏好、测试不冒充生成验收等约束已有真源，不再建立重复的长期 spec。默认 H3 是本次产品行为，记录于本任务 PRD/design 与可执行回归测试；新增夹具细节及未修布局范围保留在本记录，不升级为全仓库约定。

## 验证范围

不运行实际 H3 生成、付费调用、用户业务库或部署工作流；自动测试只能验证按钮交接的请求与点击不写分镜，不能证明生成质量、精确帧数或目标设备运行表现。移动端无对应入口，不新增功能。第一轮未修改既有用户数据、Skill 资源或安装快照。

## 第二轮：H3 中文描述正文

### 授权与范围

用户明确接受本轮只做中文可读性，保留 H3 固定字段与标记，暂不实施此前讨论的素材绑定、关键帧和连续生成。获知本地没有正式 tag、不能核实 v1 发布状态以及升级仅比较版本后，用户回复“行”，批准“剧本制片”v1→v2。没有沿用剧本写作任务的版本例外，也不把未知发布状态写入源码注释。

本轮仅三份产品／测试文件：H3 附件、官方技能注册表中的“剧本制片”元数据、现有官方加载测试。第一轮入口和测试、其他模型附件、同步逻辑、生成协议、工具描述、用户分镜与数据库不改。共享 H3 附件供桌面和移动端调用，无新增页面或平台分支。

### 实施证据

显式 `gpt-6.1-sol` 实施子代理 `626bf46f-d07a-490` 已完成；主会话读取实际三文件 diff 和 `research/chinese-implementation-result.md`，并核对以下 GREEN 日志结尾：

| 验证 | 实施结果 | 日志 |
| --- | --- | --- |
| 旧附件＋新回归 RED | 15 通过／2 失败；首个明确命中强制英文正文，第二个缺少六字段示例 | `/tmp/reveric-h3-chinese-red.log` |
| 官方技能加载整文件 | 17/17 通过，含真实打包、链接、整包 hash 守卫 | `/tmp/reveric-h3-chinese-official.log` |
| 既有官方同步整文件 | 15/15 通过；模拟失败与重试日志属于预期 | `/tmp/reveric-h3-chinese-sync.log` |
| 两文件 CLI analyze | No issues found | `/tmp/reveric-h3-chinese-analyze.log` |
| 格式 | 2 files／0 changed | `/tmp/reveric-h3-chinese-format.log` |
| Dart LSP | 无 server；主会话亦实际调用确认，不算通过 | `No LSP server configured` |

新增测试第二个 RED 最初为缺失六字段示例导致 `Bad state: No element`，随后将诊断改成明确数量断言，未削弱预期。补强多行正文检查后已整文件 GREEN；没有生产 fallback、override 链或关闭 hash 守卫。

### 独立检查

独立显式 `gpt-6.1-sol` check 子代理 `279eedd5-4015-468` 已完成，无剩余阻断项。主会话已读取最终附件、两份 Dart 文件的实际 diff、完整审查报告和日志结尾，不以子代理意图代替实际结果。

- 修正房间参考的关系标记为 `fully_preserved`：景别裁切不等于丢弃该参考已定义的空间、材质与光源用途。
- 在中文全参考示例明确连接 `<Subject 2>`、说话人 `(S1)` 和原台词；相应精确守卫加入现有第二个测试，没有新增第三个测试或 helper。
- 两处示例修正后重新计算整包指纹与日期，独立串行复验 **17 个官方加载＋15 个既有同步＝32 项通过**；不把实施和复验相加成 64 项不同测试。
- 两文件 analyze 无问题，format 为 2 files／0 changed，diff 检查为空；日志为 `/tmp/reveric-h3-chinese-check-{official,sync,analyze,format,diff}.log`，均 exit 0。
- 检查范围的独立脚本确认：原 15 个加载测试及资源／链接／hash 守卫保持；其他技能、loader、同步实现及其测试不改；第一轮两个文件与 `0cb0c8a` 相同。详情见 `research/chinese-check-result.md`。
- 检查期间尝试读取不存在的 `.fvm/flutter_sdk` Git 路径返回 128，随后改用实际 `fvm flutter --version --machine` 成功确认框架 revision 与 `.fvmrc` 一致；没有修改工具链配置。
- 主会话收尾发现自身编辑的 task.json 描述和 notes 行漏了 JSON 分隔逗号，导致任务状态暂时解析失败；补回两个逗号后，`python3 -m json.tool`、`task.py current --source` 和 9/9 manifest 验证通过。未新建任务、改变已批准状态或修改应用代码。

最终“剧本制片”元数据：version=**2**，contentHash=`8434ab211ab6446d793543b3db73c3ca37db33cf669ed01c9a926e2ae4f5688c`，updatedAt=`2026-10-28T05:19:06+00:00`。实施报告中的旧 hash/date 为检查前快照，以本最终值和注册表为准。

| 第二轮判据 | 最终结论 |
| --- | --- |
| A6 | 默认中文规则、三段／六段中文正文示例、原话保护、固定字段／时间／引用等标记守卫通过；旧英文强制与词数配额已移除 |
| A7 | v2/hash/date 与真实打包附件一致，17＋15 项独立复验通过；不改用户安装语义，不冒充设备升级完成 |

### 第二轮 Spec review

已加载 `trellis-update-spec`，阅读 backend/frontend index、backend quality 与现有 agent-skills、ai-calling、testing 规则。本轮没有新增函数、命令、API、schema 或跨层 payload；语言适配归 H3 附件，版本与用户安装保护已有 AGENTS/agent-skills 真源。中文可读性的产品决定及官方来源保留在附件、测试与任务记录，不再复制为长期 spec；本次用户单独确认 v1→v2 不推广为“无 tag 就升版”的通用规则。

### 生效与未验证范围

源码已确认启动会执行既有官方升级机制：更新应用并重新启动后，官方安装可从 v1 升到 v2，再发起新的拆分／改写请求。未读取或写入用户设备、Debug/Release 安装数据库，不声称安装快照已升级；自定义或已删除的技能保留既有选择。已有英文分镜不会自动翻译。

未运行真实 Agent、H3 或媒体调用，未验证中文成片质量、远程遵从或三端实机表现。独立检查和主会话复核已完成；按用户预授权执行本轮 scoped commit，成功与哈希以最终 Git 回执记录，不 push/amend，不擅自归档。

## 第三轮：H3 可拍分镜与全参考成稿

### 授权与实施

用户明确要求直接改现有 Skill、按 H3 格式拆得更好，已批准五文件范围和本轮独立的 v2→v3 决定。仍无本地正式 tag，不能认定 v2 已发布或未发布；不新增发布状态源码注释或运行时兼容层。

实施子代理 `fe597620-7601-408` 使用显式 `gpt-6.1-sol`，未递归委派或提交。首次派发在任何工具调用前遇到上游 503（auth_unavailable/server_is_overloaded），未改产品文件；用户要求继续后用同一指定模型重新派发，未改应用供应商/模型配置。

- 主入口和 production 将原文覆盖、可拍计划、目标格式、逐 Shot 检查及保存回读串起来，补充机位/画内动作/明确切镜或运镜/合法时长/可见终点要求。
- 约 5 秒仍是软偏好，一条分镜可含多个 Shot；不强迫逐秒表或统一 8 秒，不缩减原对白或事件。
- 明确全参考的正式稿依真实绑定图写六字段；没绑定只交草稿，缺口在 prompt 外说明，不伪造 ID 或自动改为纯文生最终稿。
- 原四个镜头配方保留，新增屏幕→键盘→屏幕的六字段中文教学例；8 秒和三张参考都是教学设定，不是默认时长、用户素材观察或可直接提交的绑定。
- 仅更新剧本制片 v3/hash/date 和原 loader 测试；H3 格式真源、其他模型附件、拆分 UI、同步/生成链路及业务数据不改。

主会话已读取实际五文件 diff 与实施日志结尾。完整报告见 `research/shot-quality-implementation-result.md`。

| 验证 | 实施结果 | 日志 |
| --- | --- | --- |
| 旧文案＋3项新回归 RED | 17通过／3失败，分别命中可拍流程、全参考边界及第五配方缺失，非仅版本差异 | `/tmp/reveric-h3-shot-quality-red.log` |
| 官方加载整文件 | 20/20通过，保留原打包、链接、hash、中文和固定标记守卫 | `/tmp/reveric-h3-shot-quality-official.log` |
| 未修改的同步整文件 | 15/15通过，模拟失败/重试日志为预期 | `/tmp/reveric-h3-shot-quality-sync.log` |
| 两文件 CLI analyze | No issues found | `/tmp/reveric-h3-shot-quality-analyze.log` |
| 两文件 format | 2 files／0 changed | `/tmp/reveric-h3-shot-quality-format.log` |
| Dart LSP | 主会话实际尝试，无 server，不算通过；以上述 CLI 为静态验证 | `No LSP server configured` |

### 独立检查及主会话最终复核

独立显式 `gpt-6.1-sol` check 子代理 `7562e6c2-3c8c-409` 完成，报告为 `research/shot-quality-check-result.md`，无未解决阻断项。检查中补强同一个新例子回归先得到19通过／1失败，再修正两处实质问题：

1. 恢复原事件“母巢被炮火吞没”的可见过程，以炮火逐渐遮没母巢轮廓表达，不把开火摘要当完整覆盖，也不擅加摧毁、爆炸或胜利；去掉原文没有的“战列”限定。计划、摘要、首镜及验收同步，仍不加 Enter/发送或人物对白。
2. 房间参考只定义桌面关系、光线与可见材质；这些用途没有因景别裁切而丢弃，因此 Subject 3 改为 `fully_preserved`。游戏状态实际变化，Subject 2 保留 `partially_preserved`，不改 H3 格式真源。

修正后重新计算 production hash/date，并串行复验：官方加载20/20、既有同步15/15，共 **35项不同测试通过**；不把实施与复验相加成70项。两文件 analyze 无问题、format 2 files／0 changed、diff无诊断，范围/旧例/旧测试/链接/hash审计通过。完整日志 `/tmp/reveric-h3-shot-quality-check-{red,official,sync,analyze,format,diff,scope}.log`；其中 red 是预期失败，其余最终检查通过。

主会话已读最终例子、注册表、实际测试补强、独立报告与各日志结尾；另执行只读独立审计 `/tmp/reveric-h3-shot-quality-main-audit.log`：确认仅五个批准产品文件，frontmatter与原四例字节保留，原17测试仅版本期待变化、恰好新增3项，其他注册内容/同步/UI/H3真源不变，相对链接有效；按15个完整路径排序和NUL分隔独立重算hash一致。

最终元数据：version=**3**，contentHash=`f6ce8132a48aafead8d21cb8438adeea02b05c595e1196a6fa3805411593a8d8`，updatedAt=`2026-10-28T09:43:18+00:00`。实施报告中的旧hash/date是审查前快照，以本最终值和注册表为准。

| 第三轮判据 | 最终结论 |
| --- | --- |
| A8 | 真实loader覆盖可拍计划→模型编写→逐Shot核对→回读，内容决定合法时长，不混通用外壳，保留其他模型/模式 |
| A9 | 完整六段中文教学例、原事件和可见终点、3/6秒切点、实际/教学参考边界通过；原四例保留 |
| A10 | 只升剧本制片v3/hash/date，未知发布状态的用户独立批准已记录；35项独立复验和主会话审计通过 |

本轮scoped commit门禁满足：仅五个产品文件和本任务十份记录；无关远程模型目录规划排除。依用户预授权提交，实际成功及哈希以Git回执为准；不push/amend，不擅自归档。

### 第三轮 Spec review

主会话已完整读取 `trellis-update-spec`。本轮无函数、工具、API、schema、基础设施或跨层 payload 改动，不触发七节 code-spec；可拍方法与 H3 格式的真源是现有 Skill 及其附件，不复制成另一份长期规格。版本/安装保护沿用 AGENTS 和 agent-skills 规则；本轮用户批准的未知发布状态升版不推广为通用规则。

### 生效及未验证边界

本轮是 Skill 工作要求，不是运行时自动质量校验器。共享资源可供桌面/移动端原有调用使用，未新增平台分支或声称三端设备验收。未运行应用内真实分镜 Agent 或调用付费视频模型、操作用户或 Debug/Release 数据库、绑定素材、重写已有分镜或校验设备安装。源码和静态测试不能保证模型遵守、精确游戏图像/计数/文字或实际成片质量；使用更新后的官方 Skill 重新发起拆分才会应用新指引。
