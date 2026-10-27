# Implementation verification

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

Implementation and deterministic validation complete. No commit or push has been made; commit confirmation and task archival remain separate workflow steps. The task remains in_progress pending delivery bookkeeping.

## Unverified

No same-model before/after generation comparison, live app writes, Mac installed snapshot inspection, device builds or media generation. Static content tests and hashes cannot establish screenplay-quality improvement. No release or remote push is included.
