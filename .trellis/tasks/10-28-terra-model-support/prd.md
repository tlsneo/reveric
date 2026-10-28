# 临时补齐 Terra 模型识别

## 授权与范围

用户在远程能力目录最终方案后明确要求：先只在当前项目添加 `gpt-6.1-terra`，急用；不实施远程目录方案。本次是用户明确缩小并要求立即执行的两文件修复，不是批准 `.trellis/tasks/10-28-model-capability-catalog` 的完整方案。

局部假设已向用户说明：暂按现有 `gpt-6.1-sol` 的能力配置登记 terra，提供 low/medium/high/xhigh/max；这不等于已验证真实渠道支持或思考输出。无付费探测、配置/数据库改写。

## 根因与最小改动

`lib/shared/models/models_catalog.dart` 的 gpt-6-astra 条目已含 sol 别名，但没有 terra，因而其 reasoningEfforts=null，UI/会话解析不展示或选择思考档位。

仅修改两个产品/测试文件：
- `lib/shared/models/models_catalog.dart`：该现有条目的 matches 添加 `gpt-6.1-terra` 和 `gpt-6.1-terra-*`，不增加全家族宽泛匹配、不改 Matcher、协议、客户端或 presets。
- `test/shared/models/models_catalog_test.dart`：覆盖裸 ID、openai/devin 命名空间及变体的五个明确档位、medium 默认、既有长度/图片输入配置和原始 option.model ID 保留；sol 保持原样。

现有去命名空间匹配已能支持上述 exact aliases。共用模型层使桌面/移动端同时生效，无需平台专属改动。

## 验收与执行

- 新增回归先 RED，再修改别名后 GREEN；整文件以及 `test/shared/models/ai_provider_test.dart` 串行通过。
- 仅对两个 Dart 文件 analyze/format 与 diff check；尝试 LSP，不可用如实报告。
- 无新依赖、代码生成、远程 JSON、缓存/刷新 UI、Claude 预算修正、SDK/工具描述修改、真实模型调用。
- 完成必要验证后按既有授权只提交本修复与本任务记录，不提交尚未实施的远程目录规划，不 push、不 amend。
- 用户运行 App 需要 hot restart（大写 R）或重启，并重新选择 terra/开启新会话以重建此前缓存配置。真实服务端支持未做验证。
