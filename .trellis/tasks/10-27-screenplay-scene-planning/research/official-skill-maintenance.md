# 剧本写作官方技能维护核查

## v3 跟进维护决定

本轮再次执行 `git tag --list --sort=-version:refname`，本地仍无正式发布 tag；当前注册值为 v2、hash `b659aadf6388121b99a1aecc363ddd4e3262945655853499552603f7472feb81`。v2 已提交不构成正式发布证据，发布状态仍未知。

用户在获知本次建议升 v3、改进范围及现有地点关联能力后回复“那可以，你可以这么做”，批准本次 v2 → v3 维护例外与实施。按 v3 更新内容指纹及 updatedAt，沿用现有升级机制，不修改业务数据/Debug 安装快照/Release 数据库，不覆盖用户自定义或停用语义。下方 v1/v2 条目均为历史核查记录，不是本轮版本目标。

## 历史 v2 已批准决定

用户针对“将剧本写作 v1 升为 v2 并开始实施”的明确问题回复“同意啊”。本次按该例外递增版本、更新 contentHash/updatedAt，沿用现有官方升级机制，不覆盖本地自定义、不改同步代码，不手改 Debug/Release 数据库。下方是调查时的证据与历史阻塞；版本例外现已解决，发布状态仍未知。

## 发布证据
- `AGENTS.md:45-48` 要求只核对最新正式发布 tag；修改技能内容时，已发布版本递增 `version`，未发布则保持版本，均更新 `contentHash`/`updatedAt`；保留版本必须同步 Debug 安装快照，不能改 Release DB。
- 本地 `git tag --list`、`git show-ref --tags` 均为空；仓库非 shallow（`git rev-parse --is-shallow-repository=false`），仅有 `refs/remotes/origin/unstable` 与 `origin/HEAD`。`git ls-remote --tags --refs origin` 返回 0 行且 exit 0，远端可达但没有可见 tags。结论：没有稳定 release tag 证据，不能决定递增版本；不得伪造版本判断、fetch 或写 refs。

## 剧本写作条目与指纹
- `lib/shared/services/bundled_official_skills.dart:156-184`：`剧本写作`，主文件 `assets/official_skills/screenplay-writing/SKILL.md`，15 个 `references/` 附件，当前 `version: 1`、登记 hash `e29a3e0d...272425b9a`、`updatedAt: 2026-10-23T12:29:42+08:00`。
- `test/shared/services/bundled_official_skills_test.dart:188-220` 是 hash 守卫：主文件字节后按附件路径排序追加 `NUL + 完整 asset path + NUL + 附件字节`，SHA-256 小写 hex。现场按同算法计算得到完整 hash `e29a3e0daea8c29c742ee7560a45f2d06ab0003c48445a7a8cb263e272425b9a`，与登记一致。测试还覆盖 asset 包装、附件、相对链接、目录/规格漂移和排序唯一性（`:103-252`）。
- `bundled_control_skills.dart` 只负责 bundled 控制技能及其 Run 映射；剧本写作是 official，不应加入该表。其测试 `test/shared/services/bundled_control_skills_test.dart` 覆盖控制技能加载、fallback 映射、附件和资源登记。

## 加载、覆盖与同步语义
- `chat_turn_runner.dart:724-820`：读取全局已安装技能；可执行项进入摘要。对 bundled 控制技能仅在没有同名已安装记录时 fallback；同名 NovelAgentSkill（包括 disabled/blocked）会阻止 fallback。AgentSkill loader 对 disabled/blocked 返回 not found；因此用户停用/覆盖语义必须保留。
- `official_skill_sync.dart:36-164`：官方安装按 `name` 身份；已安装官方快照仅在目录 `version` 更高时升级；本地/市场来源保留，目录外官方来源卸载。`novel_agent_skill_providers.dart:526-575` 升级保留安装 id/name/enabled/sortOrder 等，并更新完整 prompt/references；内容历史 hash 在 `:648-677` 以 `NovelAgentSkill.contentHash` 判断。
- 官方目录加载为本地 asset：`agent_skill_catalog_service.dart` 委托 `BundledOfficialSkillsLoader`，不联网。

## 实施时验证与阻塞
- Flutter 测试必须串行（`.agents/rules/testing.md`）。最窄顺序建议：`fvm flutter test test/shared/services/bundled_official_skills_test.dart`，再 `fvm flutter test test/shared/services/bundled_control_skills_test.dart`；若改同步逻辑，再串行跑 `fvm flutter test test/shared/services/official_skill_sync_test.dart`，必要时补 `test/shared/providers/official_skill_sync_providers_test.dart`。当前研究未运行测试。
- Debug 安装快照更新只在“核实版本未发布且保持 version=1、且存在该 official 安装记录”时实施；需通过 SQLite skill 查询并更新该快照及附件/内容指纹，保留 id、启用状态、排序、历史，不碰 Release DB。当前 Linux 环境未发现/未浏览 Mac Debug DB，故不能声称已同步；若无记录则无需更新。
- 当前可安全得出的维护结论：只能继续规划；修改剧本写作主文件或附件前，必须先取得可用 release tag 证据，或获得用户对无 tag 情况下版本策略的明确例外确认。不能由当前分支、现有 `version: 1` 或 hash 一致性推断发布状态。
