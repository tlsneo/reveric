# 实施与验收

## 已批准范围

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

## 回归与交付边界

- 请求测试证明入口交接，不证明 H3 模型遵循、声音/对白质量、切点/精确帧数或远程渠道可用。
- 桌面共用同一入口，不涉及布局分支；宿主 Linux widget 测试不冒充 Windows/macOS 设备验收。移动端没有同按钮，不新增移动功能。
- 不运行真实生成或操作业务数据库；不修改已存 Skill，不需要版本例外、内容 hash 或 Debug 安装快照更新。
- 任务目录中的规划/研究文件一并提交；此前剧本写作任务、无关变更不提交，不归档其他任务。
- 如果必须扩大到 Skill、后端、UI、工具或数据库，先停止并向用户说明；不在当前授权下扩展。
