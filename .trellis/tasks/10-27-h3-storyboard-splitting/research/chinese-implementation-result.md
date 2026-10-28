# 第二轮 H3 中文正文：实施结果

## 范围与元数据

仅修改三份产品／测试文件：

1. `assets/official_skills/screenplay-production/references/minimax-h3-prompts.md`：默认中文正文，清除英文正文要求及英文词数配额；保留固定英文模板、三／六字段顺序与 H3 标记，提供 I2VA 三字段和 Ref2VA 六字段中文示例，补充官方来源及中文适配／质量证据边界。参考占位符与真实输入明确区分。
2. `lib/shared/services/bundled_official_skills.dart`：仅“剧本制片”的 version、contentHash、updatedAt 三项变化。
3. `test/shared/services/bundled_official_skills_test.dart`：增加两个真实 loader 回归测试，检查中文规则／示例、字段顺序、固定模板和标记。现有资源、相对链接、hash 与目录守卫未改。

另新增本报告；父会话原有规划文件和研究记录均未修改。第一轮 UI、剧本写作 v3、其他模型附件、同步逻辑及同步测试均未修改。

- 剧本制片 version：`1 → 2`，依据用户明确批准，不推断 v1 发布状态。
- contentHash：`8a87428872b0e5be2b0b7d17d92435772c495c3d5f975d684cf4289a2d299fbb`。
- updatedAt：`2026-10-28T01:13:41-04:00`。
- 指纹计算：主文件原始字节 + 按完整资源路径排序的 15 份附件；每份附件追加 NUL、UTF-8 完整路径、NUL、附件原始字节，与现有 hash 测试一致。

## RED → GREEN

先只增加测试，再运行 RED，完整日志 `/tmp/reveric-h3-chinese-red.log`，退出码 1：15 个原有测试通过，2 个新增测试失败。首个失败明确命中旧语言规则 `正文、字段名和镜头标记全部写英文`，不是语法或 matcher 错误；第二个失败因旧附件不存在六字段示例，查找产生 `Bad state: No element`。随后把示例缺失诊断改为明确的数量断言，没有削弱预期。

修复真源附件的语言冲突，新增六字段示例并更新整包元数据后，官方加载整文件 GREEN：17/17 通过。格式化后补强多行字段正文检查，再次整文件通过。没有关闭或放宽原 hash／资源守卫，没有新增 provider override 或运行时 fallback。

## 实际验证命令

全部 Flutter 测试串行，命令结束后才检查完整日志；使用 `.fvmrc` 固定的 SDK，没有并发测试进程。

```bash
timeout 240 fvm flutter test --no-pub --concurrency=1 test/shared/services/bundled_official_skills_test.dart > /tmp/reveric-h3-chinese-red.log 2>&1
# RED exit 1，15 passed / 2 failed。
fvm dart format lib/shared/services/bundled_official_skills.dart test/shared/services/bundled_official_skills_test.dart > /tmp/reveric-h3-chinese-format-apply.log 2>&1
# exit 0，仅测试文件有格式调整。
timeout 240 fvm flutter test --no-pub --concurrency=1 test/shared/services/bundled_official_skills_test.dart > /tmp/reveric-h3-chinese-official.log 2>&1
# 最终 GREEN exit 0，17/17 passed。
timeout 240 fvm flutter test --no-pub --concurrency=1 test/shared/services/official_skill_sync_test.dart > /tmp/reveric-h3-chinese-sync.log 2>&1
# exit 0，15/15 passed，既有失败重试用例的模拟异常日志为预期。
timeout 240 fvm flutter analyze --no-pub lib/shared/services/bundled_official_skills.dart test/shared/services/bundled_official_skills_test.dart > /tmp/reveric-h3-chinese-analyze.log 2>&1
# exit 0，No issues found。
fvm dart format --output=none --set-exit-if-changed lib/shared/services/bundled_official_skills.dart test/shared/services/bundled_official_skills_test.dart > /tmp/reveric-h3-chinese-format.log 2>&1
# exit 0，2 files / 0 changed。
git diff --check
# exit 0。
```

尝试两个 Dart 文件的 LSP diagnostics 均返回 `No LSP server configured`；静态验证依据 pinned FVM CLI analyze。除预期 RED 外没有遇到需扩大范围的验证失败。Flutter 输出有 root 用户运行警告，不影响上述退出码与结果。

## 未验证与安全边界

未调用真实 Agent、provider 或媒体服务；未读写业务、Debug 或 Release 数据库；未安装依赖、pub、codegen、clean、stash；未提交、推送、amend、归档或切换当前任务。共享 H3 附件供桌面／移动端使用，不涉及 UI 修改。

测试只证明资源文本、加载、结构、内容指纹及既有同步行为，不证明 Agent 实际遵循中文规则、中文／英文成片质量等价或用户设备安装快照已升级。没有运行时／设备验收，也没有用户设备快照更新声明。
