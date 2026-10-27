# Independent check — item photo command routing

## Verdict and scope

**PASS for the approved three-file local change. No in-scope issue remains after review.** This check did not change product code or tests, relax assertions, dispatch another agent, or commit. The only repository file written by this check is this report. Existing product/test diff remains exactly:

| File | Diff against HEAD | Review conclusion |
| --- | --- | --- |
| `lib/desktop/widgets/workspace/workspace_item_editor.dart` | +17 / -1 | Only the existing `_handleGeneratePhoto` request string changes. No layout, state, callback, dialog, model-selection or API change. |
| `test/desktop/widgets/workspace/workspace_entry_editor_test.dart` | +193 / -13 | Keeps compact scrolling/material-reading assertions; adds actual photo-button/style/confirm/cancel interactions, request JSON and unchanged-input assertions, and fixture cleanup. |
| `test/shared/services/ai/tools_run_test.dart` | +73 / -11 | Extends the existing real image-callback loopback test to include item generation, actual HTTP routing/model/prompt, durable assets and unchanged item photos. Existing permission/target/path assertions remain. |

Total: 283 insertions / 25 deletions, three tracked files. `git diff --name-only HEAD`, full diff, and connected source were inspected; no staged diff was present. Task records are separately untracked and are maintained by the parent session. No SDK/Agent/tool description/schema, application Skill, model/configuration, database schema, production, character-photo/avatar/four-view, map or mobile product change is included.

Context was read in the requested order: every `check.jsonl` file entry, then current PRD, design and implementation plan, then `research/implementation-result.md`. Frontend/backend spec indexes and quality files are largely placeholders; the concrete `.agents/rules` contracts, root AGENTS, tools-path and state/lifecycle guidance were also checked. No new convention or shared contract was introduced; existing testing/error/tool-path rules already cover the relevant lessons. Any parent-session spec decision is outside this check's allowed write scope.

## Actual request and connected execution chain

1. `workspace_item_editor.dart:491–540`: the existing button/configuration gate and style dialog are unchanged. The resulting request binds the actual `selectedItemId` and title, requests `Read /items/{id}`, and provides parseable `Run` JSON with `command=item`, `subcommand=generate-photo`, and `options.item/prompt`. It explicitly requires the separately configured image model, actual tool result, no chat-native image substitute/model switching/repeated submission, and manual adoption. Style/extra text is appended as visual-preference data and expressly cannot change the execution route. These are instructions, **not a hard enforcement mechanism against remote-model disobedience or prompt injection**.
2. `novel_workspace_panel.dart:723–770` passes the generation callback only for `NovelWorkspaceSection.items`. `novel_editor.dart:2871–2893,4698` still receives the full prompt and actual item ID, adds only `Item photo: `, preserves it in both `content` and `initialText`, supplies an item reference, and sets `autoSend:true`. No truncated/replaced request was found in this direct chain.
3. `desktop/widgets/ai/chat/panel.dart:1014–1147` preserves handoff content/references, seeds the composer, creates the orchestrator chat and schedules sending after loading. Its identical-body deduplication is not instruction deletion. `chat_session_controller.dart:889–915,2228–2256` builds the reference-aware text and appends a noncontained handoff; `chat_prompt_builder.dart:243–290` adds entity Read reminders without replacing the request. A reference is not automatic full item/media content.
4. `tools_run.dart:343–346,1710–1829` already registers the item subcommand, accepts exactly the existing subject/prompt/optional local path contract, verifies the item exists and has type `item`, requires operation context, gates through `generation.image`, rechecks the target, and invokes the existing photo handler. No command/schema change is needed.
5. `tools_image.dart:104–155` calls generation with `864x1536` unless an explicit local edit source exists. `chat_turn_runner.dart:1159–1160,1421–1422` supplies the existing image callbacks. `ai_providers.dart:2452–2520` resolves the image-kind option and imports generated assets; it is not a chat-model fallback.
6. `chat_turn_runner.dart:243–267` preserves the Run tool-history block while creating the image block with item identity. `chat_message_view.dart:521–561` offers an adoption callback only for a successful image and valid target/path. `widgets/ai/tools/character_image_tool_card.dart:306–343` invokes that callback on user click. `novel_editor.dart:2840–2869,3026–3036,4504` then appends to the intended item's existing photos. No automatic photo write was added.

## Test quality and isolation review

- The widget regression pumps the real `WorkspaceEntryEditor` with an actual item fixture ID, real Chinese localization and Reveric theme at the original 700×360 fixture size. It clicks the actual generate button, verifies confirmation is disabled before style selection, selects illustration, enters multiline extra requirements, confirms, captures exactly one callback and parses its JSON. It also checks title/content/category/empty photos and add/remove callback counts stay unchanged. Cancellation is a separate actual dialog interaction and emits no request. These are callback-level behavioral tests, not source-text searches.
- Existing compact-scroll and metadata-hidden assertions are preserved; no production/fixture size was enlarged to hide overflow. `rootBundle.clear()` remains per-test. Fixture controllers/focus nodes are released only after dismantling and settling the widget tree, including both editor instances used by the original scrolling test. No exception swallowing was added.
- The sole new leaf override, `editorFontColorProvider.overrideWithValue(null)`, is justified: `RevericMarkdownEditor.build:270` unconditionally watches that provider, which otherwise reads `editorFontColorHexProvider → appSettingsNotifierProvider → settings DB`. The previous four font/layout leaf overrides were already present. This isolates an unrelated theme setting and does not suppress the photo callback or add a DB/provider override chain. The final widget log contains no settings-database initialization/drift duplicate-instance warning.
- The Run test retains the real `imageGenerationCallbackProvider` and edit callback with explicit subscriptions and cleanup. It uses in-memory `AppDatabase`/`NovelContentDatabase`, temporary file roots, and a loopback `HttpServer`; no business DB or real provider is used.
- The fixture deliberately exposes `chat-only`, plus image models `image-default` and `image-advance`, while selecting `image-advance`. Assertions inspect **received HTTP**, not just asset metadata: three POSTs total, generation/edit/generation endpoints, the same loopback origin, and the item request's exact model, full Chinese prompt, size and `n=1`. The item contributes one request after the two preserved character requests. Unique response bytes, result files, imported asset content/model/purpose/work, and absence of `.part` files are checked.
- A pre-existing named item photo is added before generation, and the entire item JSON is compared afterward. This protects nonempty photo history, its label and all item fields—not merely an initially empty photo array. Original avatar/photo routing, local-source validation, denied approval, missing/wrong target, removed command and mixed-command checks are unchanged and were rerun.
- The two test layers intentionally do not run a real model between the UI request and Run. They verify the task contract and existing command execution independently, as approved. Missing-model/remote-failure behavior in unchanged handlers was source-reviewed, not newly exercised by this loopback success fixture.

## Independent verification commands and actual results

All Flutter commands were **serial**, FVM-pinned, `--no-pub`, and tests used `--concurrency=1`. Every command wrote its complete output before inspection; the runtime log was read in contiguous chunks through its final line. No live output was piped to grep. No pub/codegen/clean/stash, real model call, or business-database write was performed.

### 1. Entire widget file — exit 0, 3 passed

```bash
timeout 240 fvm flutter test --no-pub --concurrency=1 test/desktop/widgets/workspace/workspace_entry_editor_test.dart > /tmp/reveric-item-photo-check-widget.log 2>&1
```

52 lines / 2,927 bytes. Ends `00:04 +3: All tests passed!`. Original scrolling test plus both photo interactions pass.

### 2. Entire Run file — exit 0, 56 passed

```bash
timeout 300 fvm flutter test --no-pub --concurrency=1 test/shared/services/ai/tools_run_test.dart > /tmp/reveric-item-photo-check-run.log 2>&1
```

325 lines / 28,461 bytes. Ends `00:03 +56: All tests passed!`. Wire trace for this run shows item generation at `http://127.0.0.1:37225/v1/images/generations` with `model=image-advance`, prompt `古剑，保留缺口与铭文。插画风格，冷色柔光。`, `size=864x1536`, `n=1`. The preceding avatar and edit requests are distinct. File-unavailable error traces are expected rejected-path cases and do not indicate a failing test.

### 3. Three-file analyze — exit 0, no issues

```bash
timeout 240 fvm flutter analyze --no-pub lib/desktop/widgets/workspace/workspace_item_editor.dart test/desktop/widgets/workspace/workspace_entry_editor_test.dart test/shared/services/ai/tools_run_test.dart > /tmp/reveric-item-photo-check-analyze.log 2>&1
```

`No issues found! (ran in 3.2s)`. Parent-session Dart LSP had no configured server; this is actual CLI validation, not an LSP-pass claim.

### 4. Nonwriting format check — exit 0, 3 files / 0 changed

```bash
fvm dart format --output=none --set-exit-if-changed lib/desktop/widgets/workspace/workspace_item_editor.dart test/desktop/widgets/workspace/workspace_entry_editor_test.dart test/shared/services/ai/tools_run_test.dart > /tmp/reveric-item-photo-check-format.log 2>&1
```

`Formatted 3 files (0 changed) in 0.19 seconds.`

### 5. Whitespace/diff check — exit 0

```bash
git diff --check > /tmp/reveric-item-photo-check-diff.log 2>&1
```

Empty log, no errors.

### 6. Requested unchanged shared-runtime suite — exit 0, 84 passed

```bash
timeout 360 fvm flutter test --no-pub --concurrency=1 test/shared/services/ai/chat_prompt_builder_test.dart test/shared/services/ai/chat_session_controller_handoff_test.dart test/shared/services/ai/chat_turn_runner_characterization_test.dart test/shared/services/ai/chat_agent_tool_dispatcher_test.dart > /tmp/reveric-item-photo-check-runtime.log 2>&1
```

2,078 lines / 219,474 bytes. Ends `00:23 +84: All tests passed!`. Per-file counts from the cumulative boundaries: prompt builder 18; controller handoff 3; turn runner 44; dispatcher 19. Total independent tests: **3 + 56 + 84 = 143 passed**.

This covers local reference context, handoff materialization/isolation/retry, tool history/lifecycle/dispatch, permission/skill scoping, cancellation and stream recovery. It does not establish remote-model compliance.

The runtime log is not warning-free: untranslated fixture localization keys and unavailable desktop-notification plugin warnings occur; tests inject adoption/provider/persistence/startup failures and intentionally exhaust incomplete-response retries. Four existing skill-scope cases intentionally use `_FlakyStreamClient(const [])`, documented at `chat_turn_runner_characterization_test.dart:2664–2665`, so they log `RangeError` after loader setup and assert loader behavior rather than successful model output. Their source was checked against the log; they are not failing tests or evidence of real provider errors. None of these cases was weakened or edited to pass. In the visible progress message an interim runtime count was mistakenly stated as 58 and immediately corrected; the complete log and final authoritative count are **84**.

### 7. Pinned SDK — exit 0

```bash
fvm flutter --version --machine > /tmp/reveric-item-photo-check-sdk.log 2>&1
```

Reports framework revision `0b771a584214b44aa1f94f9707f2756207356f41`, matching `.fvmrc`, and actual root `/root/fvm/versions/0b771a584214b44aa1f94f9707f2756207356f41`. An auxiliary attempt to inspect `.fvm/flutter_sdk` failed because this checkout has no such link; the FVM machine output resolves the SDK without creating one. Flutter emits its standard root-user warning; it does not block these commands.

## Implementation-phase RED/GREEN and fixes independently checked

Historical exit statuses were not independently recaptured; the following conclusions come from the preserved actual logs plus current source/diff, not merely the implementation receipt. This check did not temporarily revert the product file or replay the old code.

- `/tmp/reveric-item-photo-red-widget.log`: **2 pass / 1 fail**, failure is specifically `Expected: not null / Actual: <null> / 任务必须包含可执行的 Run 命令 JSON` in the real photo-confirmation callback assertion. `git show HEAD:.../workspace_item_editor.dart` confirms the old request was only `请为物品「...」生成照片或插画。` plus style, without Run JSON. Thus this is a valid routing-contract RED, not a compilation/setup failure or a reproduced remote-service bug.
- `/tmp/reveric-item-photo-red-widget-initial.log`: also includes unintended settings initialization and drift multiple-database warnings. Its stack reaches `editorFontColorProvider → editorFontColorHexProvider → AppSettingsNotifier`. The retained isolated RED and current GREEN no longer show these warnings. The initial log's final test failure is still the missing JSON assertion; do not claim the DB warning itself caused that assertion failure.
- `/tmp/reveric-item-photo-green-widget.log`: actual full-file **3 passed** after the request change. `/tmp/reveric-item-photo-green-run.log`: actual full-file **56 passed**, including real loopback item HTTP. Both were read and match the independent reruns.
- `/tmp/reveric-item-photo-green-run-compile-failure.log`: compile failure passes `String?` from `library.resolve(itemAsset.path)` to `File(String)`. The current success-asset assertion uses `!`; if resolution is unexpectedly null it still fails rather than skipping the assertion. Current analyze and full Run rerun pass.
- `/tmp/reveric-item-photo-analyze-initial.log`: the reported issue is `unnecessary_import` of `app_database.dart`, because `novel_content_database.dart` already exports the used symbol. It is redundant rather than literally two identical import lines. Current source removes it; historical final analyze and this check both report no issues.
- Historical `/tmp/reveric-item-photo-format.log` shows 3 / 0 changed, `/tmp/reveric-item-photo-diff-check.log` is empty, and `/tmp/reveric-item-photo-sdk.log` matches the independently checked revision. No new product/test repair was necessary in this check.

## Independent read-only verification of the three assistant-audit claims

### A. Outline beat “生成章纲” drops clicked beat identity — confirmed source defect, not reproduced wrong write

- Both menu callbacks send only the same `AiShortcutActionDefinition`: `outline_timeline_strip.dart:706–735`, `outline_architecture_view.dart:692–721`.
- Card construction passes `onRunShortcutAction` unchanged, despite having `beat`/index for rendering and edit/delete. Parent `outline_editor.dart:104–125,275–294` forwards it unchanged. No clicked beat selection/identity is added along that route.
- `ai_shortcut_action.dart:135–140` gives the fixed built-in prompt about “当前选中的节拍”. `novel_editor.dart:2891–2915,2952–2966` uses global workspace selection and only attaches the whole outline reference. `currentAiWorkspaceContent:3193–3194` serializes the whole outline; meta contains no beat identity. Same-outline beat A and B clicks therefore do not distinguish their target in the draft (aside from timestamp IDs).
- `tools_read.dart:1150–1185` can return/read actual beat IDs and paths, so downstream read capability cannot reconstruct which menu the user clicked. Default `autoSend=false` and possible user clarification are important limits: this is a source-proven information loss, **not evidence that a model actually wrote the wrong chapters**. No audit source was modified.

### B. Image catches discard structured exception diagnostics — confirmed, with a qualification

- `tools_image.dart:71–88,143–155` catches `AiImageGenerationException`, retains its `userMessage`, and returns fixed `error_code=internal`; it does not preserve `code` or `debugMessage` in the Agent result. Avatar traces use `e.toString()`, which `image.dart:110–111` defines as userMessage, not debugMessage. The photo catch has no corresponding error trace.
- `image.dart:97–111,350–421` defines these fields and logs detailed service errors; `image/client.dart:612–647` derives HTTP/message classification. Therefore “there are no service logs” would be false. The normal outer tool normalization preserves fields it receives but cannot recover discarded exception fields after a returned failure map.
- **Qualification to broad wording in the audit:** userMessage can already distinguish some auth/credit/size/moderation/rate-limit/parameter failures (`image/client.dart:578–586`). The Agent is not wholly without any causal clue. The proven loss is the machine-readable original classification and underlying debug detail, not necessarily all human-readable differentiation. Also debugMessage is optional and does not universally contain a complete raw server body.
- This was not the reported item's current root cause, because the image command was not called in that incident. No synthetic failing-image run was added and no shared handler/interface was changed. Any follow-up must retain safe UI copy and add redacted Agent diagnostics, not merely logs.

### C. Initial installed-skills read failure returns empty before bundled fallback — confirmed conditional risk

- `chat_turn_runner.dart:724–759` awaits `installedAgentSkillsProvider.future`, catches an error, logs `Failed to load skills`, and returns `_ChatSkillContext.empty` **before** constructing bundledFallback.
- `_ChatSkillContext.empty:452–456` has empty summaries/content and `loader:null`; `getOrCreateChatAgent:1475–1503` assigns this loader and supplies these empty summaries. The provider itself (`novel_agent_skill_providers.dart:133–148,761–765`) reads installed rows/references, with no bundled construction there to counter the early return.
- “Initial failure” here means that initial awaited read ultimately throws to this catch; it does not assert that every transient low-level DB failure immediately bypasses any Riverpod retry behavior. Later loader reads and deliberately disabled/blocked same-name overrides are different paths and remain valid boundaries.
- The user's incident is documented as successfully reading Skill; this check did not independently replay or receive the original raw incident log, and found no counterevidence in the supplied task evidence. Thus this conditional branch is **not established as this incident's cause**, nor does it imply all tools disappear. The passing runtime skill-scope tests exercise normal installed/bundled/disabled behavior, not this provider-error branch.

## Explicit noncoverage / residual risks

- No live remote chat/image model, paid request, user business DB, Windows/macOS/Android device launch, image quality or real permission/adoption dialog was exercised. Linux-host widget and in-memory/loopback tests are not cross-platform device acceptance.
- Prompt routing is explicit but cannot force every Agent/provider to obey. User-device acceptance still needs a trace containing the actual `Run item generate-photo`, the configured image provider/model HTTP request, a real result and user-triggered adoption. No claim of hard runtime execution enforcement is made.
- Generic chat `delta.images` parsing/event/storage/rendering/adoption and associated empty-response retries are **not fixed**. The limited audit findings are not a complete interface audit or an explanation for every assistant error.
- Production generation, character-photo/avatar/four-view, map and mobile entry audits were read to preserve boundaries, not dynamically revalidated. The three independently verified assistant findings remain separate follow-up work requiring authorization, not blockers smuggled into this approved three-file patch.
