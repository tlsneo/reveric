# Quality Guidelines

> Code quality standards for backend development.

---

## Overview

<!--
Document your project's quality standards here.

Questions to answer:
- What patterns are forbidden?
- What linting rules do you enforce?
- What are your testing requirements?
- What code review standards apply?
-->

(To be filled by the team)

---

## Forbidden Patterns

<!-- Patterns that should never be used and why -->

(To be filled by the team)

---

## Required Patterns

<!-- Patterns that must always be used -->

(To be filled by the team)

---

## Testing Requirements

<!-- What level of testing is expected -->

(To be filled by the team)

---

## Code Review Checklist

<!-- What reviewers should check -->

(To be filled by the team)

---

## Native Codemode Build Contract

### 1. Scope / Trigger

Applies to changes in `tools/build_codemode_runtime.sh`,
`tools/codemode_artifact.py`, and the vendored FJS CargoKit / XCFramework tools.
Local macOS development must not build iOS or the other Mac architecture.

### 2. Signatures

- `bash tools/build_codemode_runtime.sh`: build for the current Mac architecture.
- The same entry supports `--key`, `--verify`, and `--verify-app APP`.
- `build_fjs_xcframework.sh --macos-arch arm64|x86_64`: host-only package;
  omitting the option retains the full five-target Apple package.
- `build-precompiled-generation --no-composites --target TARGET`: retain the
  requested target without requiring the complete upstream composite group.
  Composite building remains enabled by default.

### 3. Contracts

- ARM Macs select only `aarch64-apple-darwin`; Intel Macs select only
  `x86_64-apple-darwin`. Windows / Android build entry points are unchanged.
- Build, assembly, artifact checking, cache keys, and app verification must agree
  on the architecture. Do not remove target arguments in isolation.
- The local XCFramework contains exactly `macos-arm64` or `macos-x86_64`.
- Source hashes, Rust version, Xcode version, macOS SDK, and target identity bind
  the cache. Do not query the iOS SDK for a macOS-only build.
- Keep the existing checksum, Mach-O symbol / deployment-target checks, FRB
  binding hash check, SwiftPM resolution check, and packaged binary UUID check.

### 4. Validation & Error Matrix

| Condition | Required behavior |
| --- | --- |
| Unsupported Mac architecture | Fail before native compilation |
| Missing or mismatched cached artifact | Rebuild; never silently adopt it |
| Wrong platform or architecture in local archive | Reject |
| Duplicate, unknown, or unpinned CargoKit target | Reject even with composites disabled |
| Partial composite request with default options | Reject |

### 5. Good / Base / Bad Cases

Good: ARM host builds one retained target and packages one macOS slice.
Base: the vendored wrapper without `--macos-arch` still builds its full package.
Bad: local startup installs `aarch64-apple-ios` or requires its SDK.

### 6. Required Tests

- `python3 -m unittest discover -s test/tools -p 'test_codemode_artifact.py' -v`
- From `third/fjs/cargokit/build_tool`: `fvm dart test --concurrency=1
  test/composite_artifacts_test.dart test/precompiled_publisher_test.dart`.
- Run shell syntax checks and the affected standalone Dart analyzer.
- Script / fixture tests on Linux do not prove a native Mac build. On Mac, run
  the local build entry, verify its artifact, and launch with
  `fvm flutter run -d macos` before claiming runtime acceptance.

### 7. Wrong vs Correct

Wrong: delete the iOS `--target` arguments but leave full-composite enforcement,
archive validation, or `macos-arm64_x86_64` lookup unchanged.

Correct: explicitly build the one retained target, assemble and validate its
single-architecture package, and use the same target in cache / app checks.
