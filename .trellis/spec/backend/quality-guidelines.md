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

---

## Official Skill Extraction Contract

### 1. Scope / Trigger

Applies when separating an app business capability into an independent official
Skill, including the `AI 拆分镜` extraction. Move the actual method, not only its
entry name; keep operation contracts in their existing bundled owner.

### 2. Signatures

- `BundledOfficialSkillsLoader.get(AssetBundle bundle, String listingId)` loads
  the installable snapshot; its `listingId` is the registered Skill name.
- `AgentSkill` takes `{"name":"AI 拆分镜"}` for the splitting method. Reference
  requests use that owner's name and its installed-relative reference path.
- The desktop split callback in `lib/desktop/features/storyboard/region.dart`
  supplies a chat draft; it does not itself invoke `AgentSkill` or send the chat.

### 3. Contracts

- `AI 拆分镜` owns the splitting method and video-prompt formats under
  `assets/official_skills/storyboard-splitting/`; `剧本制片` retains visual assets,
  previsualization, generation and result repair. `剧本写作` owns screenplay text.
- Every registered reference must be inside its Skill asset root. Maintain a
  single physical owner, local Markdown links within the installed snapshot,
  and named, optional handoffs for other Skills. Do not create mutual full-load
  prerequisites or make image generation a prerequisite for splitting.
- Update callers, handoffs, registry, nested Flutter asset declarations and
  content hashes together. Evaluate release/version handling for every changed
  official package, including a package whose only change is a handoff name.
- A new official identity has independent installation/enabled state. Upgrading
  the former owner preserves its ID, display name, enabled state and order;
  do not overwrite local conversions, same-name local Skills or deletion choices.

### 4. Validation & Error Matrix

| Condition | Required behavior |
| --- | --- |
| Reference registered outside its Skill root | Loader throws `StateError`; no partial snapshot |
| Missing registered reference | Detail loading fails rather than omitting it |
| Unknown official listing name | Loader throws `ArgumentError` |
| Named Skill disabled or absent at runtime | Report unavailable; no hidden official-asset fallback |
| New identity previously handled/deleted or occupied by a local Skill | Preserve the existing sync/user-choice semantics |

### 5. Good / Base / Bad Cases

Good: the new splitter loads all its own method/format references even when
production is disabled; the old production identity and user preferences survive.
Base: writing and authorized generation still use their respective existing owners.
Bad: a new name merely redirects to the old method, or both packages retain
competing copies of that method.

### 6. Required Tests

- `test/desktop/features/storyboard/region_test.dart`: click the real split button;
  inspect the new owner/path in its request and verify no clip writes on click.
- `test/shared/services/bundled_official_skills_test.dart`: load actual new/old
  packages, check method ownership, paths, asset coverage, links and hashes.
- `test/shared/services/bundled_control_skills_test.dart`: update authoring handoffs
  while retaining the existing operation contracts and lack of official fallback.
- `test/shared/providers/official_skill_sync_providers_test.dart` and
  `test/shared/services/official_skill_sync_test.dart`: cover packaged old-owner
  upgrade plus independent installation, disabled/deleted and local choices.
- Include untracked new asset roots in content and whitespace review. After
  staging only owned paths, run `git diff --cached --check`; an unstaged diff
  check alone does not inspect previously untracked additions.
- Run Flutter tests serially. Request/loader/installation tests are not evidence
  that a live model consumed the new content or produced good storyboards.

### 7. Wrong vs Correct

Wrong: register `screenplay-production/references/minimax-h3-prompts.md` under
`storyboard-splitting/SKILL.md`, or copy it to both packages to avoid fixing links.

Correct: move the single source into the new owner's root, update its registry
and asset declarations, and route any remaining consumers to that owner by name.
