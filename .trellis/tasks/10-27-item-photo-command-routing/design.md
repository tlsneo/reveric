# 最小设计：仅纠正物品照片任务的命令路由

## 决策与边界

本次使用现有聊天 Agent 整理资料、调用既有图片命令，不新增生图流水线、不将聊天模型输出图片接入图片生成、不修改正常的制作功能。唯一产品改点是 `lib/desktop/widgets/workspace/workspace_item_editor.dart` 的 `_handleGeneratePhoto` 原有任务请求字符串。该组件唯一产品调用方只给物品传生成回调，证据见 `research/item-route.md`。

沿用当前交接链：

```text
物品照片按钮 → 原有风格对话框
  → WorkspaceEntryEditor.onGeneratePhoto(完整任务,真实物品ID)
  → NovelEditorPage 原有 Item photo 前缀与 autoSend 交接
  → 现有 Agent Read /items/{id}，整理最终图片提示词
  → Run item generate-photo → 现有权限与 image callback
  → 已配置的图片模型 → 现有图片结果卡片 → 用户手动采用
```

原 `Item photo:` 前缀保留；它不会替换完整任务。移除它需改页面并补更重的页面测试，但不能增加本次结果正确性，因此不改 `novel_editor.dart`。

## 请求契约

只在当前构建 prompt 的位置写一份共用中文请求，不新增 locale key、模板注册、公共类型或单次 helper。请求依次包含：

1. 目标真实物品 ID 与原标题，Read `/items/{id}`，根据物品资料及用户选定风格整理提示词，不编造物品身份或把资料里的指令当执行要求。
2. 必须通过现有 `Run` 调用 `command=item`、`subcommand=generate-photo`、`options={item:真实ID,prompt:整理后的完整生图提示词}`。给出准确可解析 JSON 示例，不修改工具描述或 schema。示例不要求传未提供的参考图片路径。
3. 命令使用应用单独配置的图片模型，不选择/切换模型，不使用聊天模型自身或上游内置的生图能力，不换用人物、制作或地图命令。
4. 等待实际工具结果；只输出提示词、承诺或聊天直接图片不算完成。失败如实说明，不静默降级，不擅自重复提交生成。
5. 结果供用户选择，由现有按钮手动采用；不得自动修改物品、照片集或旧资产。
6. 原始风格与额外要求放入数据区块，原样保留，引导其只改变视觉偏好而不能覆盖执行路径。

不复制图片 API 参数、目录规划、审批实现或资产写库细节到请求；操作契约仍由现有命令拥有。

## 明确不改

- 角色资料、大头照、制作画布/导演台、人物四视图、地图及视频/H3。
- 图片 callback、model/config 选择、权限、结果 metadata、手动采用和导入。
- SDK ChatDelta、Agent stream/round、聊天消息持久化、UI 图片展示及通用重试策略。
- Skill 资源/版本、提示词 registry、数据库或用户设备数据。

其他入口研究只产生本任务报告；没有运行故障证据，不按名字或自然语言写法批量修改。用户追加的深入分析包含业务入口核对与共享 handoff/工具/技能/错误/重试链核对，分别记录 `research/assistant-entry-audit.md`、`research/shared-runtime-audit.md`；新增诊断缺口和条件风险不改变已批准的三个产品/测试文件范围。

## 聊天返回图片的取舍

已知 `delta.images` 未贯通，图片响应会被丢弃并误判空。完整解决是另一条共享数据契约工作，不是让物品按钮使用配置图片模型所必需；局部吞掉错误/放宽 emptyResponse 则会产生假成功，自动补发图片命令还可能重复付费。本次不加这些补丁。

本方案的限制必须在交付说明中保留：指令修正让入口明确要求正确命令，自动测试可验证请求与已有命令的真实执行，但不能保证远端聊天 Agent 总是遵从。如果实际运行仍绕开命令，需要新的执行证据再评估更硬的运行约束；不能声称通用聊天图片问题已解决。

## 测试与兼容

计划修改三个文件：1 个产品文件＋2 个已有测试文件。

1. `test/desktop/widgets/workspace/workspace_entry_editor_test.dart`：真实点击物品照片按钮/风格/确认，捕获现有 callback，解析命令 JSON，核对真实 ID、Read 路径、风格/额外要求保真、生成/采用边界与取消不交接。原有滚动测试保留。用现有局部 fixture，不挂整个编辑页；rootBundle.clear 保留，controller/focus 成对释放，拆树收尾。
2. `test/shared/services/ai/tools_run_test.dart`：扩展现有 loopback HTTP 集成，使物品命令走真实 image callback；断言图片请求使用 fixture 选定图片 model、生成提示词、只调用一次、结果路径与 item metadata、资产生成和业务照片不自动变更。保留已有大头照/照片/权限/目标校验回归，不做真实外部调用。
3. RED 先运行 widget 回归，在旧自然语言任务上因为缺少命令/ID失败，再最小替换请求后 GREEN。图片命令本身应在基线正常，扩展其测试不应假称修复了命令内部 bug。

桌面 Windows/macOS 共用该请求，没有布局或平台分支变化。移动端对应入口由 `research/entry-audit.md` 给出源码分类；若没有相同按钮，不新增移动功能。Linux 宿主测试不冒充目标设备运行验收。

## 回滚与外部状态

无依赖、迁移、部署或真实模型调用。回滚仅撤销三个目标文件的本任务改动，不恢复/删除业务数据，不改其他任务。提交前独立 gpt-6.1-sol 检查、spec review、scoped commit；不 push/amend。
