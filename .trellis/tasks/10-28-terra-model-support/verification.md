# Terra 临时登记验证

## 实际改动

仅两个 Dart 路径：在现有 Astra/Sol 条目增加 terra 精确与后缀通配别名，并补已有目录测试。没有新增独立能力表、扩大 GPT 家族通配、改 Matcher/协议/presets、改真实供应商配置或实施远程目录。

## 实施验证

实施代理：`ee3cfbcd-05ee-464`，显式 gpt-6.1-sol；主会话读取实际 diff 和完整日志尾部核对。

- RED：目录测试 31 通过、1 失败，失败项是新 Terra 回归。
- GREEN：`timeout 180 fvm flutter test --no-pub --concurrency=1 test/shared/models/models_catalog_test.dart`，32 通过。
- 紧接串行运行同命令的 `test/shared/models/ai_provider_test.dart`，11 通过。
- 两文件 `fvm flutter analyze --no-pub` 无问题；`fvm dart format --output=none --set-exit-if-changed` 为 0 changed；`git diff --check` 通过。
- 日志：`/tmp/reveric-terra-{red,catalog,provider,analyze,format}.log`。

独立复核代理 `d22118a9-034b-4e6`（显式 gpt-6.1-sol）未再改文件，串行复跑目录 32/32、Provider 11/11，并复核 analyze、format 和 diff check 通过；日志 `/tmp/reveric-terra-check-{catalog,provider}.log`。共 43 项独立测试，不把两次运行重复计算为 86 项。主会话再次核对实际日志与 diff。

## 验证边界与 Spec 判断

主会话尝试 LSP，返回未配置对应 Dart server；静态验证依据实际 CLI analyze，不称 LSP 通过。未运行真实渠道调用、付费探测、设备构建/启动或业务数据库操作。

Terra 暂沿用 Sol 的 low/medium/high/xhigh/max 档位、560K/128K 限制和图片输入声明，这是本地登记假设，不是已验证的服务端能力。共享目录覆盖桌面与移动端。已运行的开发 App 应大写 R hot restart 或重启后重新选模型/新建会话，避免旧 matcher/Agent 缓存。

这是既有匹配机制下的数据条目补充，没有新 API、schema、infra 或通用模式；复用现有规则/回归测试即可，不新增永久 spec。远程目录规划继续独立搁置，不纳入本修复提交。
