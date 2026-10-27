# Implementation verification

## v3 follow-up — implementation and independent verification complete

User approved v3 and the scoped follow-up after the existing location association was verified in storage, AI create/update/read tools and the shared desktop/mobile scene-properties form. Implementation agent `0e124703-ea19-4ca` used explicit `gpt-6.1-sol`; independent review agent `cd39f57b-31ab-452` uses the same explicitly selected model. Prior v2 test totals below do not count as v3 acceptance.

Current scope: five existing references, official metadata and two existing test files. No business data, app-model call, tool schema/description, UI, runtime or sync implementation change. Source-supported changes concern two closed prop criteria, craft-method reachability, same-pass saved-body reconciliation and verifiable resource delivery. The user's actual missing-resource execution cause remains unverified.

### v3 RED → GREEN evidence

Parent inspected the actual eight-file product diff and complete-log result/failure excerpts. All Flutter commands ran serially with `timeout 240 fvm flutter test --no-pub --concurrency=1 <file>`, redirecting full output before inspection.

| Stage / test file under `test/shared/services/` | Result | Log under `/tmp/` |
| --- | --- | --- |
| RED `bundled_official_skills_test.dart` | exit 1; 12 passed, 3 failed | `reveric-screenplay-v3-red-official.log` |
| RED `bundled_control_skills_test.dart` | exit 1; 23 passed, 2 failed | `reveric-screenplay-v3-red-control.log` |
| GREEN `bundled_official_skills_test.dart` | exit 0; 15 passed | `reveric-screenplay-v3-green-official.log` |
| GREEN `bundled_control_skills_test.dart` | exit 0; 25 passed | `reveric-screenplay-v3-green-control.log` |
| GREEN `official_skill_sync_test.dart` | exit 0; 15 passed | `reveric-screenplay-v3-green-sync.log` |
| GREEN `ai/prompt_tool_guidelines_test.dart` | exit 0; 32 passed | `reveric-screenplay-v3-green-prompts.log` |

Total GREEN: **87 tests**. RED on unchanged v2 assets found two new official instruction gaps (source-function/craft routing and open prop criteria), two bundled gaps (resource delivery evidence and saved-body reconciliation), plus the expected version 2-versus-3 mismatch. The five scoped reference edits and approved metadata update resolve these failures; no failed assertions were removed.

Additional implementation checks, exit 0:
- `fvm flutter analyze --no-pub lib/shared/services/bundled_official_skills.dart test/shared/services/bundled_official_skills_test.dart test/shared/services/bundled_control_skills_test.dart test/shared/services/official_skill_sync_test.dart test/shared/services/ai/prompt_tool_guidelines_test.dart`: no issues (`/tmp/reveric-screenplay-v3-analyze.log`).
- `fvm dart format --output=none --set-exit-if-changed lib/shared/services/bundled_official_skills.dart test/shared/services/bundled_official_skills_test.dart test/shared/services/bundled_control_skills_test.dart`: three files, zero changes (`/tmp/reveric-screenplay-v3-format.log`).
- `git diff --check`: passed (`/tmp/reveric-screenplay-v3-diff-check.log`).
- Dart LSP unavailable; CLI analysis is the available static check, not a substitute claim of device execution.

### v3 independent final review

Independent `gpt-6.1-sol` reviewer found no remaining in-scope issue and made no file edits. It read full affected references and direct callers/operation/loader/sync contracts and reran all four suites serially: **15 + 25 + 15 + 32 = 87 passed**, each exit 0. Full final logs: `/tmp/reveric-screenplay-v3-check-{official,control,sync,prompts}.log`. Targeted analysis of the same five Dart files passed (`/tmp/reveric-screenplay-v3-check-analyze.log`); the three changed Dart files passed format verification, zero changes. `git diff --check` passed. All three changed Dart files lacked a configured Dart LSP; no LSP-success claim is made.

Parent retrieved the full review, inspected final test/analyzer log endings and independently recomputed the 15-reference hash. Both complete original parenthetical bullets and the full original timing paragraph were checked against HEAD and remain exact. The review also verified unchanged caller-prepares-or-authorizes, quiet-scene and local-ID clauses, unchanged main Skill/15-reference manifest and unchanged other 12 official references. Product scope remains exactly the eight approved files.

Final registered metadata: **version 3**, hash `b04aea179a1f8003914defb4c52835bdf3d8bcc642141c80800a412d2ed9b0fe`, updatedAt `2026-10-27T11:02:03-04:00`. Version increase uses explicit user approval, not inferred publication state. Existing sync/override/runtime code is unchanged.

V3-A–V3-E are satisfied at instruction/loading/contract level. No unexpected implementation/check failure required a fix; the only failing runs were the deliberate RED regressions above. This work does not prove the reported missing-location execution cause or improved screenplay quality. Task stays in_progress; archive, PR/base-branch resolution and push are not part of this iteration.

### v3 neutral cases — static instruction review only

- Long screen exchange: ordinary scene writing explicitly routes to existing scene/dialogue craft, retains causal words/order/time and allows selective compression; not automatically VO/in-person dialogue.
- Known/repeated versus ambiguous locations: the operational guide distinguishes actual location records, scene references and prose; same-place reuse does not require invented layout/photos, while uncertain identity stays pending.
- Authorized newly introduced receipt: saved-body resources absent from the prewrite list enter the existing authorized chronicler reconciliation, with source scene and real resource paths; they are not mislabeled as source facts.
- Writer/caller/chronicler permissions: the original caller-prepares-or-explicitly-authorizes clause remains; preview, planning-only and no-delegation cases do not authorize extra writes. Planned purchases or candidate objects do not establish current possession.
- Purposeful slow scenes: quiet aftermath, effective long messages and legitimate standalone parenthetical reactions remain permitted; no conflict, reaction or duration quota was introduced.

These are instruction coverage judgments, not model executions or successful extraction results.

### v3 spec-review decision

Reviewed `trellis-update-spec` and current spec/rule owners. No new API/schema/runtime convention is being added. Existing `.agents/rules/agent-skills.md` already owns method-vs-operation placement and the limits of static instruction tests; `tools_path.md` owns real identities/paths. Put the functional writing/resource criteria in the actual Skills and the evidence in this task, rather than duplicate them as a permanent development spec. Revisit only if independent checking uncovers a genuinely new contract.

## Historical v2 verification

## Authorization and scope

Latest user reply “同意啊” explicitly approves both the v1 → v2 exception and implementation. No tag-based publication claim is made. Prior premature edits were rolled back; only checks after the approved implementation are final acceptance evidence.

Shared assets serve Windows, macOS and Android. This task changes no UI, schema, tool descriptions, API, Agent lifecycle, skill-sync logic or business data. No downloaded external code is executed and no app model/provider call is made.

## Review gates

- Keep existing episode design, timing/capacity checks, scene craft, review-only and local-edit boundaries when adding the material-organizing route. The preliminary patch removed too much neighboring guidance; restoration was requested before final verification.
- Preserve the bundled `parenthetical` examples and constraints; these are operations guidance, not replaceable by broad writing prose.
- Read actual `/scenes/{scene_id}/elements` and `/scenes/{scene_id}/cast`; scene metadata is not body evidence. Current `tools_screenplay.dart` resource behavior was independently read.
- Distinguish discussion/preview from an explicit request to save planning resources. A planning-only request does not authorize body writes, but saving an outline/beat/scene synopsis must remain possible.
- Keep Writer non-body writes dependent on explicit assignment; reuse existing orchestrator/chronicler fact maintenance. These caller contracts and the story-continuity screenplay reference were independently read.
- The existing official synchronizer upgrades higher versions and preserves local/market sources; upgrade snapshot code retains installation identity and enabled state. These paths were independently read; runtime on the user's machine is not implied.

## Representative review cases (not model executions)

1. Prose: afternoon library key handover, then next night opening a corridor cabinet. Expect one continuous exchange and a distinct night/corridor scene, real resource reuse, no invented contents or new characters.
2. Existing valid screenplay: preserve scene structure, speaker sequence, useful action/dialogue and existing character identities/images; don't force adaptation assessment or whole-season planning.
3. Mixed fragment: anonymous dialogue, a valid scene, a duplicate prose note about the same handover. Keep unattributed speech unresolved, preserve valid portions, don't duplicate the event or infer objective truth from a character's denial.
4. Synopsis/incomplete material: separate source facts from expansion, ask only about consequential gaps under existing rules, honestly report unwritten/unknown scope.
5. Planning-only: no body saves or unsolicited resource creation; explicit authorized plan saves still use existing planning resources.

These cases guide instruction review. They do not prove actual model discovery, tool behavior, dramatic quality or persistence.

## Spec review

No new runtime/API/schema convention was introduced. Existing `.agents/rules/agent-skills.md`, `.agents/rules/tools_path.md` and `AGENTS.md` already own method/operation boundaries, source/body paths and official maintenance. No duplicate `.trellis/spec` rule is needed. The one-off no-tag version exception belongs in this task, not permanent source comments.

## Final checks

Final independent check completed, and the parent read the resulting full product diff and test-log endings. Exactly eight product files changed; no Agent prompts, sync/runtime logic, UI or database files changed.

All commands below executed after the final content fixes. Tests ran serially using `timeout 240 fvm flutter test --no-pub --concurrency=1 <file>`:

| File | Result |
| --- | --- |
| `test/shared/services/bundled_official_skills_test.dart` | 13 passed |
| `test/shared/services/bundled_control_skills_test.dart` | 23 passed |
| `test/shared/services/official_skill_sync_test.dart` | 15 passed |
| `test/shared/services/ai/prompt_tool_guidelines_test.dart` | 32 passed |
| Total | 83 passed |

- `fvm flutter analyze --no-pub lib/shared/services/bundled_official_skills.dart test/shared/services/bundled_official_skills_test.dart test/shared/services/bundled_control_skills_test.dart test/shared/services/official_skill_sync_test.dart test/shared/services/ai/prompt_tool_guidelines_test.dart`: no issues.
- `fvm dart format --output=none --set-exit-if-changed lib/shared/services/bundled_official_skills.dart test/shared/services/bundled_official_skills_test.dart`: 0 changes.
- `git diff --check`: passed.
- Independent content checks: both original parenthetical bullets retained exactly; original episode-planning body retained with heading-level changes only; all 15 official reference paths and content fingerprint verified.
- LSP diagnostics attempted on the changed Dart test and registry: no Dart LSP configured; CLI analysis is the available compilation/static check.
- Logs: `/tmp/reveric-screenplay-final-*.log`.
- Final metadata: version 2, hash `b659aadf6388121b99a1aecc363ddd4e3262945655853499552603f7472feb81`, updatedAt `2026-10-27T09:44:39-04:00`.

### Failures and corrections

- The implementation-stage official-skills test failed because scene-writing no longer contained the required resource handoff (`写入责任`). This was a real omission during restoration, not only a test-wording issue. The checker added explicit caller-prepares-or-authorizes resource completion, preserved the assertion, added permission checks and reran all four files successfully. Commands after the failed chained test had not run; only the final runs above count as final acceptance.
- Actual diff review found incomplete restoration of parenthetical examples and episode-plan guidance despite the implementation summary. The checker restored those exact original sections, restored adaptation deliverables/linking, made natural-scene guidance reachable, moved causality checks before writes and clarified caller-owned fact maintenance. Parent verified these in the final diff.

### Acceptance mapping

The implemented instructions and static/loading checks cover AC0–AC9: input diagnosis and scope (main/adaptation/source-analysis); natural scene boundaries (episode-planning); real body/resource/permission contracts (bundled reference/scene-writing); coverage and fact-maintenance boundaries (adaptation/scene-writing); version/hash and existing sync compatibility (registry/tests). These are instruction-level acceptance results, not successful live model runs. Qualitative model acceptance remains explicitly unverified.

### Delivery state

v2 implementation and deterministic validation completed and committed as `12b0f95`; no push. The task remains in_progress for the approved v3 iteration; archival is not part of this follow-up.

## Unverified

No same-model before/after generation comparison, live app writes, Mac installed snapshot inspection, device builds or media generation. Static content tests and hashes cannot establish screenplay-quality improvement. No release or remote push is included.
