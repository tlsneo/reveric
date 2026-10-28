# 实施与验收

> 第五轮完整方案及新v1／制片v5／写作v4已获用户明确“同意”，进入实施。第一至第四轮均为历史，本轮以第五轮批准范围为准。

## 第五轮规划与实施门禁

- [x] 用户明确要求独立「AI 拆分镜」Skill，制作按钮明确指定，分镜与剧本职责分开；沿用当前任务，已将需求写入PRD并回到planning。
- [x] 确认本地正式tag列表为空，旧v4发布状态未知；不凭源码版本或此前v3→v4批准擅自决定新一轮版本。
- [x] 派发显式gpt-6.1-sol只读研究fa153928-66ee-405，核对拆分方法归属、所有调用与链接、注册资源、安装兼容和测试，不派发产品实施。
- [x] 主会话审阅研究报告并核对实际按钮、旧写作/制片/操作技能、注册根目录限制、同步语义及资源声明；design明确独立official技能、九附件迁移和两个方法附件提取、旧制片/写作交接清理、注册资源及四测试修改。
- [x] 本地正式tag缺失，两旧版本发布状态未知已披露；用户本轮单独批准新拆分v1、制片v4→v5、写作v3→v4。
- [x] PRD完成第五轮收敛，旧轮保留为历史；重写implement/check manifests并加入新研究，验证真实条目及文件存在。
- [x] 已向用户给出最终范围、验收、版本决定与实际效果风险；用户后续明确回复“同意”，本轮实施已获授权。
- [x] 批准后两份manifests各12项验证通过，task.py start切换为in_progress；已派发显式gpt-6.1-sol implement 86aa536c-5075-4d9，限定第五轮范围、不递归委派、不提交，先运行按钮／新技能回归RED。
- [x] 完成独立新技能及11附件（九份移动＋两份提取）、旧制片清理、写作/工具操作交接、按钮路由、注册和pubspec资源；主会话已逐项检查实际差异及完整新方法，未发现重复方法或循环加载前置条件。
- [x] 实施串行测试79/79（region1、official26、control26、provider11、sync15），六Dart文件analyze无问题、format零改动、hash/99链接/迁移和范围审计通过；主会话已核对完整报告与实际日志结尾并独立重算全部14包指纹。LSP无server不计通过。
- [x] 独立gpt-6.1-sol check 6b2d0b65-fc8b-410完成，串行独立79项通过，六文件分析/格式、14包指纹/99链接/原完整案例及迁移/范围检查通过。最终暂存检查发现新方法文件EOF多一空行，check移除一个LF并维护新技能hash/date；相关26＋11项、注册表分析/格式重跑通过，主会话重新运行全量审计通过。无范围内遗留问题，实际报告/diff/日志已核对；最终暂存副本刷新及cached diff检查作为提交前门禁。
- [x] 完成spec判断并补齐既有backend质量文档七节抽取契约，独立审查确认一致；本任务scoped commit门禁满足，按预授权提交，成功及哈希以Git回执为准。不推送、不混入三项无关WIP、不改用户数据或安装库、不执行收费模型／媒体调用。

### 第五轮验证命令（实施与独立检查均已执行）

实施完成后已逐条串行执行，完整输出落`/tmp/reveric-independent-storyboard-*.log`，独立检查加`check-`。如遇失败定位根因，不降低断言或以编排假回复宣称创作改善。

```bash
timeout 240 fvm flutter test --no-pub --concurrency=1 test/desktop/features/storyboard/region_test.dart
timeout 240 fvm flutter test --no-pub --concurrency=1 test/shared/services/bundled_official_skills_test.dart
timeout 240 fvm flutter test --no-pub --concurrency=1 test/shared/services/bundled_control_skills_test.dart
timeout 240 fvm flutter test --no-pub --concurrency=1 test/shared/providers/official_skill_sync_providers_test.dart
timeout 240 fvm flutter test --no-pub --concurrency=1 test/shared/services/official_skill_sync_test.dart
timeout 240 fvm flutter analyze --no-pub lib/desktop/features/storyboard/region.dart lib/shared/services/bundled_official_skills.dart test/desktop/features/storyboard/region_test.dart test/shared/services/bundled_official_skills_test.dart test/shared/services/bundled_control_skills_test.dart test/shared/providers/official_skill_sync_providers_test.dart
fvm dart format --output=none --set-exit-if-changed lib/desktop/features/storyboard/region.dart lib/shared/services/bundled_official_skills.dart test/desktop/features/storyboard/region_test.dart test/shared/services/bundled_official_skills_test.dart test/shared/services/bundled_control_skills_test.dart test/shared/providers/official_skill_sync_providers_test.dart
git diff --check
```

另外沿用现有hash算法和loader链接守卫，独立重算三份官方内容包指纹；核对pubspec新嵌套资源、九个移动文件及所有相对链接。没有生成源改动，不pub/codegen/clean/stash。实际模型请求、用户安装状态、视频成片、显存与设备验收未授权也未执行，必须明确报告。

## 历史第四轮实施清单

- [x] 对照官方与第三方实际技能／代码／案例，确认用户短片段软偏好及H3输出边界；完整运行证据另存，不将旧上下文推断为当前安装版本。
- [x] 用户在明确目标和软约5秒、不可空洞的约束后要求实施；收敛到design.md列出的五文件，入口已有完整短时长软偏好，保持不动。
- [x] 用户在获知正式tag缺失、v3发布未知后明确回复“同意”，独立批准本轮v3→v4；本会话沿用现有任务。
- [x] 更新implement/check manifests各9条并验证通过，激活现有任务；派发显式gpt-6.1-sol implement `3ec38cc4-9149-4ff`，限定五文件、不递归委派或提交。
- [x] 原loader新增3项回归并实际运行RED：19通过／4失败，命中旧工作链、过早分配片段和缺少真实H3整场例子，非元数据差异；主会话已核对日志。
- [x] 五文件实施完成：镜头／完整表演预算先于分组，动作唯一归属与相邻分组理由；原创整场例子改为8／6／5秒的H3草稿，各段预算有据且允许重估，不设统一时长或字速，无新runtime／框架。
- [x] 实施阶段串行加载23／23、既有同步15／15，analyze无问题、format零改动、hash／links／diff／五文件审计通过；主会话已核对实际diff、报告及日志，LSP无server未冒充通过。
- [x] 主会话逐句审查完整例子：原四句对白顺序各一次；压盖、移掌推接、开盖揭示、抬眼后最后一句、合盖后抱盒各有唯一执行处；A与B、B与C的边界有据，无靠冻结凑五秒。家庭对话不按句机械建条目／传达室比划不重演作为人工反例原则对照，未运行这些场次的新Agent输出或媒体。
- [x] 独立gpt-6.1-sol check `52405a49-e1fd-40d` 完成，无新增产品修正；独立串行23＋15项通过，analyze／format／diff／hash／62链接／五文件审计通过。主会话已核对完整报告、最终diff与日志，并独立重算hash及核对原文／图片准备／旧例保留。
- [x] 完成spec判断并在既有cross-layer guide补充指令交付与真实效果分界检查；本轮scoped commit门禁已满足，仅五产品文件、当前任务记录及该guide。按预授权自动提交，成功及哈希以Git回执为准，不push/amend，不纳入两份先前untracked诊断和远程模型目录。未做真实模型／视频／设备／显存及用户安装升级验证。

验证命令（逐条串行、完整日志，前缀`/tmp/reveric-h3-content-budget-`）：

```bash
timeout 240 fvm flutter test --no-pub --concurrency=1 test/shared/services/bundled_official_skills_test.dart
timeout 240 fvm flutter test --no-pub --concurrency=1 test/shared/services/official_skill_sync_test.dart
timeout 240 fvm flutter analyze --no-pub lib/shared/services/bundled_official_skills.dart test/shared/services/bundled_official_skills_test.dart
fvm dart format --output=none --set-exit-if-changed lib/shared/services/bundled_official_skills.dart test/shared/services/bundled_official_skills_test.dart
git diff --check
```

## 历史实施记录

## 第一轮已批准并完成的范围

用户已批准：只改 AI 拆分镜；未选模型时默认 H3 提示词格式，已明确选其他型号时保留对应格式；约 5 秒片段；已知 fps 才校核；不新增选择器、不自动配置或生成。只允许改 `lib/desktop/features/storyboard/region.dart` 与 `test/desktop/features/storyboard/region_test.dart` 两个产品文件，另可更新本任务记录。

## 实施顺序

- [x] 完成源码调查、PRD 收敛、设计与用户确认；`gpt-6.1-sol` 研究记录已保存。
- [x] 两份 context manifests 各 7 个条目通过验证，已 `task.py start`；派发 `gpt-6.1-sol` implement 子代理，不递归委派。
- [x] 在现有 widget 用例注入 `ProductionSceneActions` 的请求收集回调和 no-op director 回调，点击真实拆分按钮。断言目标场次与完整正文路径、既有方法路由、默认 H3/保留非 H3、约 5 秒与内容保护、已知 fps/整秒/不假冒帧控制、原文保护与回读边界。记录点击前后分镜，确认点击本身无数据写入；保留原刷新、取消删除、软删除与资产保留检查。
- [x] 先运行目标整文件测试得到针对旧请求的 RED。保留完整日志，不降低断言换通过。
- [x] 仅替换 `onSplit` 请求文字，沿用现有相邻字符串表达，不抽取单次 helper、不新建 prompt 文件、不加 UI 或格式模板；方法细节仍加载已有附件。
- [x] 跑 GREEN、窄范围 analyze、format 检查和 diff 检查；失败定位根因后修复，若超出两个产品文件或改变设计先退回规划。
- [x] 独立 `gpt-6.1-sol` check 子代理复核实际 diff 与 PRD，补强默认分支的 H3 附件加载，并串行复跑测试和分析通过。
- [x] 主会话审查实际差异和日志，完成 spec-review 判断，更新本任务验收记录；验收记录随本任务 scoped commit 入库，不 push/amend。

## 验证命令

所有 Flutter 命令串行，完整输出重定向，命令结束后查看日志；不 pub/codegen/clean/stash。

```bash
timeout 240 fvm flutter test --no-pub --concurrency=1 test/desktop/features/storyboard/region_test.dart > /tmp/reveric-h3-split-red.log 2>&1
# 修改请求后独立重跑，写 /tmp/reveric-h3-split-green.log。
timeout 240 fvm flutter analyze --no-pub lib/desktop/features/storyboard/region.dart test/desktop/features/storyboard/region_test.dart > /tmp/reveric-h3-split-analyze.log 2>&1
fvm dart format --output=none --set-exit-if-changed lib/desktop/features/storyboard/region.dart test/desktop/features/storyboard/region_test.dart > /tmp/reveric-h3-split-format.log 2>&1
git diff --check
```

主会话按工具可用性尝试 Dart LSP；无 server 不冒充通过，以 pinned Flutter CLI 分析为实际静态验证。check 阶段日志用 `/tmp/reveric-h3-split-check-*.log`，不得同时跑 Flutter 进程。

## 第一轮回归与交付边界

- 请求测试证明入口交接，不证明 H3 模型遵循、声音/对白质量、切点/精确帧数或远程渠道可用。
- 桌面共用同一入口，不涉及布局分支；宿主 Linux widget 测试不冒充 Windows/macOS 设备验收。移动端没有同按钮，不新增移动功能。
- 不运行真实生成或操作业务数据库；不修改已存 Skill，不需要版本例外、内容 hash 或 Debug 安装快照更新。
- 任务目录中的规划/研究文件一并提交；此前剧本写作任务、无关变更不提交，不归档其他任务。
- 第一轮如果必须扩大到 Skill、后端、UI、工具或数据库，先停止并向用户说明；不在第一轮授权下扩展。

## 第二轮：H3 中文正文（实施与独立验收完成）

用户已要求先改中文，暂不实施素材／关键帧流程，并在审阅最小方案和发布状态不确定性后回复“行”，批准仅修改 H3 附件、官方注册元数据、原有官方技能加载测试三份产品文件及“剧本制片”v1→v2。

- [x] 核对官方云 API 中文示例、官方英文改写规范及当前 H3 附件语言真源，记录 `research/chinese-prompt-followup.md`。
- [x] 核对本地正式 tag 为空、非 shallow；不把缺 tag 解释为未发布。查明现有升级只比较 version。
- [x] 收窄三份产品文件与共享双平台影响，更新 PRD 和设计；保留已交付入口不动。
- [x] 用户确认版本处理及本轮计划；更新 implement/check manifests，使第二轮边界明确取代旧 manifest 的“不得修改 Skill”。
- [x] 激活本 H3 任务，9/9 context manifest 验证通过；派发显式 `gpt-6.1-sol` implement 子代理 `626bf46f-d07a-490`，未递归委派或提交。
- [x] 在原官方加载测试增加针对中文规则、三段／六段及语法保留的 RED：原有 15 通过、新增 2 失败，首个明确命中强制英文；完整日志已保留，原 hash 守卫未改。
- [x] 修改 H3 附件的正文规则和示例，清除英文强制与词数冲突；“剧本制片”v2/hash/updatedAt 已维护，其他技能不改。
- [x] 实施阶段串行执行官方加载 17/17、既有同步 15/15，两个 Dart 文件 analyze/format 与 diff 通过；实际 diff 仅三份产品文件及任务记录。未 pub/codegen/clean、读写业务或安装数据库、调用真实媒体服务。
- [x] 独立 `gpt-6.1-sol` check 子代理 `279eedd5-4015-468` 完成；修正示例参考保留关系与说话主体标记，独立串行复验官方加载 17/17、同步 15/15，analyze/format/diff 通过。主会话已审查最终实际文件、报告和日志，完成 spec-review 与验收记录。
- [x] 本轮 scoped commit 门禁已满足：仅三份产品文件及本任务记录，按用户预授权自动提交；成功与哈希以最终 Git 回执为准，不 push/amend 或擅自归档。

第二轮实施阶段实际验证命令：

```bash
timeout 240 fvm flutter test --no-pub --concurrency=1 test/shared/services/bundled_official_skills_test.dart > /tmp/reveric-h3-chinese-official.log 2>&1
timeout 240 fvm flutter test --no-pub --concurrency=1 test/shared/services/official_skill_sync_test.dart > /tmp/reveric-h3-chinese-sync.log 2>&1
timeout 240 fvm flutter analyze --no-pub lib/shared/services/bundled_official_skills.dart test/shared/services/bundled_official_skills_test.dart > /tmp/reveric-h3-chinese-analyze.log 2>&1
fvm dart format --output=none --set-exit-if-changed lib/shared/services/bundled_official_skills.dart test/shared/services/bundled_official_skills_test.dart > /tmp/reveric-h3-chinese-format.log 2>&1
git diff --check
```

以上命令已由实施子代理串行执行；独立检查使用 `/tmp/reveric-h3-chinese-check-{official,sync,analyze,format,diff}.log` 再次串行通过，主会话已核对最终三文件 diff、报告和日志。验收详情见 `verification.md` 第二轮与 `research/chinese-check-result.md`。测试只能验证打包文本、加载、内容指纹和已有升级行为，不能证明远程 Agent 一定输出中文、中文成片质量或用户设备上的实际安装状态。

## 第三轮：可拍分镜与全参考成稿（当前实施）

具体合同与五文件范围见 `research/h3-shot-quality-followup.md`。遵循：先补原 loader 回归 RED → 三份 Skill 文案最小修改 → 仅剧本制片 v3/hash/date → GREEN → 独立检查 → spec-review/scoped commit。显式使用 gpt-6.1-sol，子代理不递归委派、不提交。

- [x] 主文将镜头计划和逐 Shot 检查接入当前拆分路径，按需读现有附件；不另装官方独立 Skill 或修改描述/触发/工具契约。
- [x] production 落实可拍计划、内容决定合法时长、H3不混通用外壳、明确全参考未绑定时的草稿状态，以及取景/切点/动作/可见终点的写后核对。
- [x] shot-recipes 保留旧四例，追加屏幕/键盘反例和 H3 六段中文教学例子，校验实际切点/时长和视域，不把示例输入当真绑定或剧情事实。
- [x] 在现有 `bundled_official_skills_test.dart` 添加3项 loader 回归；原17项通过、新3项因旧流程/例子缺失得到 RED，再完成文案与版本期待修改后20项 GREEN，未削弱旧守卫。
- [x] 只改 registry 中剧本制片 v3/hash/updatedAt，按主文件原始字节+排序后15个附件的NUL/路径/字节计算；其他技能和生成源不动，无 codegen/pub。
- [x] 实施子代理串行跑官方加载20/20、未改同步15/15、两文件 analyze/format、diff 和hash/范围核对；主会话已检查实际五文件 diff 与日志结尾。
- [x] 独立 gpt-6.1-sol check修正炮火吞没事件遗漏和场景参考保留标记，重新串行35项通过；主会话核对最终diff/输出并独立重算hash，完成spec判断和scoped commit门禁。仅本轮五文件及十份任务记录纳入自动提交，成功以Git回执为准；远程目录untracked规划排除，不push/amend，不归档他人任务。

本轮命令（顺序执行，日志 `/tmp/reveric-h3-shot-quality-*.log`；独立检查加 `check-`）：

```bash
timeout 240 fvm flutter test --no-pub --concurrency=1 test/shared/services/bundled_official_skills_test.dart
timeout 240 fvm flutter test --no-pub --concurrency=1 test/shared/services/official_skill_sync_test.dart
timeout 240 fvm flutter analyze --no-pub lib/shared/services/bundled_official_skills.dart test/shared/services/bundled_official_skills_test.dart
fvm dart format --output=none --set-exit-if-changed lib/shared/services/bundled_official_skills.dart test/shared/services/bundled_official_skills_test.dart
git diff --check
```

本地无正式 tag 的发布未知和用户本轮独立版本批准已记录。静态测试不证明实际 Agent 输出或视频质量，不调用付费模型/生成、不改用户分镜或安装快照。
