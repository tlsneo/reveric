# Implementation result — split-shortcut request

## Status

**Implementation complete; final whole-file GREEN and static checks pass.** Independent review and commit remain with the main session. The approved request-only product change is implemented. Both scenes' real-button request assertions and unchanged clip-row snapshots pass at the original 1100px size. After the main session explicitly approved fixture isolation, a local `ValueNotifier<ProductionSceneActions?>` and `ValueListenableBuilder` restore `sceneActions: null` before the original screenshot, 620px, and delete regressions. The test verifies the buttons disappear and full clip state stays unchanged. No product layout changes, exception suppression, or wider viewport workaround were applied. Action-enabled 620px still has a known 9px header overflow outside this patch; its repair needs separate approval.

## Exact scope

- `lib/desktop/features/storyboard/region.dart`: replaced only the string passed by `_SceneHeader.onSplit` to `sceneActions.ask`, using adjacent strings at the existing location. Callback, layout and state are unchanged. The request covers complete `/scenes/{id}/elements`, actual resources/current-episode clips, existing production/model/video/operation methods, H3 and known channel-alias routing, no-model default H3 draft without configuration, explicit non-H3 respect, actual bound inputs, approximately five-second legal-duration preference, full dialogue/action/continuity, evidence-based frame planning and integer-second/API limitations, source/reference reuse and readback, and no automatic media generation.
- `test/desktop/features/storyboard/region_test.dart`: extended the existing fixture with a request collector/no-op director; tapped both scenes' actual split buttons; compared all clip rows through JSON snapshots after each click; added grouped contract assertions; updated responsibility header and test name. A local nullable-actions notifier (disposed through `addTearDown`) wraps only `StoryboardRegion` in a `ValueListenableBuilder`. After both scene requests are verified, actions are set to null and pumped; disappearing buttons and unchanged full clip snapshots are asserted. Original refresh, screenshot, 620px layout, delete/cancel, soft-delete/media-retention and cleanup code remains and is reached successfully by final GREEN.
- This record is the only task artifact written by the implementation agent. No planning artifacts, Skills, model capabilities, tool protocols, translations or other product files were changed. No subagents, commits, task lifecycle commands, business database access, media generation, dependency operations or model/network calls were used.

## Actual test commands and outcomes (serial)

All test invocations used:

```bash
timeout 240 fvm flutter test --no-pub --concurrency=1 test/desktop/features/storyboard/region_test.dart
```

Complete output was redirected before reading; none timed out.

1. Initial RED attempt: **exit 1**, test loading failed (0 passed / 1 load failure). `allOf` accepts at most seven positional matchers in the pinned matcher version. Fixed the two oversized groups to pass an iterable; no production change. Preserved log: `/tmp/reveric-h3-split-red-compile.log`.
2. Second RED attempt: **exit 1**, **0 passed / 1 failed**. Comparing Drift `ProductionClipRow` instances failed despite identical values: generated equality compares `inputs` lists by identity. Fixed the test to compare complete `row.toJson()` snapshots through deep matcher equality; did not weaken the no-write check to row counts or a few fields. Preserved log: `/tmp/reveric-h3-split-red-row-equality.log`.
3. Confirmed behavioral RED with the old product request: **exit 1**, **0 passed / 1 failed**. Both button clicks and unchanged-row assertions completed; request assertion failed because the old request omitted `/scenes/{id}/elements`. Final RED log: `/tmp/reveric-h3-split-red.log`. Product source was still unchanged for this run.
4. First post-product-edit GREEN attempt: **exit 1**, **0 passed / 1 failed**. All request groups for both scenes, no-write checks and external-refresh assertions completed; the subsequent unchanged 620px resize yielded two `RenderFlex overflowed by 9.0 pixels on the right` errors. Source: the inner scene-header Row at `region.dart:525`; available width 164px. The original fixture did not supply `sceneActions`, whereas this extension now renders the split button. Log: `/tmp/reveric-h3-split-green-first.log`.
5. Repeated against the final shorter test name (avoids formatter reindenting the whole fixture): **exit 1**, **0 passed / 1 failed**, same 9px overflow at the original narrow-layout assertion (then `region_test.dart:275`). No assertion failures preceded the resize. Before final GREEN, this failed log was preserved as `/tmp/reveric-h3-split-green-failed-action-enabled-620.log`.
6. Final GREEN after the main-session-approved test-only fixture isolation: **exit 0**, **1 passed / 0 failed**, `All tests passed!` in approximately four seconds. Final log: `/tmp/reveric-h3-split-green.log`. Both scene request/no-write checks, action-removal/no-write checks, external refresh, screenshot, unchanged 620px exception assertion, delete cancellation/confirmation, clip and canvas-node soft deletion, retained media ID, widget teardown and DB cleanup completed. This pass does not establish action-enabled 620px layout correctness.

## Static checks

```bash
timeout 240 fvm flutter analyze --no-pub lib/desktop/features/storyboard/region.dart test/desktop/features/storyboard/region_test.dart > /tmp/reveric-h3-split-analyze.log 2>&1
```

**Exit 0** on the initial check and again after final GREEN with fixture isolation. Final output: `No issues found! (ran in 4.5s)`.

```bash
fvm dart format lib/desktop/features/storyboard/region.dart test/desktop/features/storyboard/region_test.dart > /tmp/reveric-h3-split-format-apply.log 2>&1
fvm dart format --output=none --set-exit-if-changed lib/desktop/features/storyboard/region.dart test/desktop/features/storyboard/region_test.dart > /tmp/reveric-h3-split-format.log 2>&1
```

Both initially **exit 0**, `Formatted 2 files (0 changed)`. After fixture isolation and final GREEN/analyze, the format-check command was rerun serially: **exit 0**, `Formatted 2 files (0 changed) in 0.09 seconds.` SDK pinned by the repository's `.fvmrc`; no PATH Flutter/Dart substitution.

```bash
git diff --check > /tmp/reveric-h3-split-diff-check.log 2>&1
```

**Exit 0**, empty diagnostic log, including the final rerun after GREEN/analyze/format. Final product diff: two files, 132 insertions / 4 deletions. The final sequence was full-file test → CLI analyze → pinned format check → diff check, all serial; no source changes followed these checks. Main session reported its Dart LSP attempt returned `No LSP server configured for file type`; implementation used CLI analysis and does not claim LSP success.

## Observed layout limitation and fixture-isolation decision

The request-only product fix does not change layout; the extra split button comes from the new callback injection in the existing test. The narrow fixture previously tested a no-split-action configuration. The first GREEN attempts unintentionally changed that configuration and exposed a 9px overflow in the unchanged header Row. This was not a new prompt regression.

The main session explicitly approved restoring the original no-action fixture after the split-request assertions. The minimal notifier/builder change implements that decision without duplicating the fixture, changing product layout, weakening the 620px size or exception assertions, or suppressing errors. A passing final full-file test verifies both action-enabled wide behavior and the original action-disabled narrow behavior.

**Known limitation:** action-enabled 620px still overflowed by 9px in the preserved failed runs. This patch does not fix or claim to pass that configuration. Any header layout repair requires separate approval and is outside this request-only task. Independent checker should review the fixture-isolation boundary separately.

## Verification limits

These local tests observe the outgoing request and in-memory fixture behavior; they do not establish real-model H3 compliance, exact clip length, generated output fps/frame counts, remote-channel availability or Windows/macOS device behavior. No real generation was run. Final GREEN reached and passed the unchanged delete/menu/media-retention assertions and cleanup. Action-enabled 620px remains the separately documented layout limitation. Independent review and final scoped commit remain with the main session.
