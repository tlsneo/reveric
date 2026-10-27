# 现有制片方法与本次最小边界

## 已完整阅读的真源

- `assets/official_skills/screenplay-production/SKILL.md`
- `references/production.md`、`storyboard.md`、`model-capabilities.md`、`video-prompts.md`、`minimax-h3-prompts.md`（均位于上述技能目录）
- `.agents/rules/agent-skills.md`、`.agents/rules/ai-calling.md`、`.agents/rules/testing.md`

## 已有能力，不应重写或重复建设

1. 主 Skill 已区分剧本场次、界面分镜条目、提示词内 Shot，路由到制作流程、镜头方法、模型能力及专用格式。
2. `production.md` 已要求完整正文与现有片段、覆盖原动作及逐字对白、优先连续性边界、按模型容量定长、写入 `/clips` 后回读。不得把当前问题归因于完全没有拆分方法。
3. `storyboard.md` 已要求按叙事目的选镜头、保留动作阶段和完整语义，不机械一句一镜、不加速对白，跨片段核对起止状态。
4. `video-prompts.md` 已把 `MiniMax-H3`、`hailuo-3-max` 路由到 `minimax-h3-prompts.md`，明确专用结构取代通用 Shot 模板。
5. H3 附件已有 T2VA/I2VA/FL2VA 三核心字段、Ref2VA 六字段、英文描述＋原语言对白、`[Shot N]` 切点及真实 ref 规则；不能在 UI 再复制一套格式。H3 示例为 8 秒，不代表强制所有 H3 分镜 8 秒。
6. `model-capabilities.md` 明确当前生成要求整秒，未选或未知模型允许暂定草稿，不能声称校验完成；实际能力应查询，不能从型号猜测。

## 最小方案候选

本次用户明确只改 AI 拆分镜，因此优先只修改已有拆分按钮的聊天请求及其回归测试：

- 把无条件“使用通用 Shot 格式”替换为先读现有制片流程/镜头方法、查询模型、再加载适用专用格式。
- 在请求中表达本次产品目标：约 5 秒的生成片段、正文覆盖与连续性优先、帧率和合法帧数规则已知才换算、未知不猜。
- 不改 Skill 格式正文，不新增长期框架或确定性 splitter，不改变 API、模型目录、时长验证或生成流程。
- 技术可行性与桌面/移动端覆盖由 `runtime-constraints.md` 提供证据；最终由主会话确认最小方案及用户决策。

## 发布与维护边界

本次执行 `git tag --list --sort=-version:refname` 和 `git show-ref --tags` 无本地 tag 输出；仓库不是 shallow。不能据此断言任何 Skill 未发布。

当前 `lib/shared/services/bundled_official_skills.dart` 的“剧本制片”为 version 1、hash `660c839e1d7106154d59563fa5b61b1429cccd802562cc39e775592c37fd17db`、updatedAt `2026-10-23T19:55:49+08:00`。若仅修改调用请求与测试，不改 Skill 资源或元数据，就不需要猜测发布状态、申请版本例外或写 Debug 安装快照。若后续发现必须修改 Skill，应退回规划，重新明确版本维护授权，不能复用“剧本写作”v2/v3 的历史例外。

## 验证边界

入口回调测试可证明发给聊天的请求包含任务范围、格式路由、短片段偏好及证据边界；不能证明真实模型遵循、产物精确 5 秒、H3 后端可用或已安装自定义 Skill 已更新。本任务不运行真实生成、不写业务数据库。
