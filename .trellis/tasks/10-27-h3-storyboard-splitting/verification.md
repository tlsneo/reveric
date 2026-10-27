# 验收记录

## 规划与授权

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

不运行实际 H3 生成、付费调用、用户业务库或部署工作流；自动测试只能验证按钮交接的请求与点击不写分镜，不能证明生成质量、精确帧数或目标设备运行表现。移动端无对应入口，不新增功能。既有用户数据与 Skill 资源/安装快照不在变更范围。
