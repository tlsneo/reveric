# Skill-first execution plan — approved

## Current v3 iteration — approved

The user approved v3 and implementation after verifying the existing location-reference capability. Previous v2 work is committed as `12b0f95`; commands/counts below are historical, not v3 verification. No additional product/version question is pending. All delegated agents use `gpt-6.1-sol` explicitly. Scope is the eight product files listed in the current design, plus task records; preserve other files and user data.

1. [x] Read current manifests, PRD/design and `research/writing-resource-followup.md`; inspect complete target files, callers and tests. Preserve original detailed craft, permissions and examples. Confirm source gaps rather than asserting a runtime diagnosis.
2. [x] Add narrow loaded-instruction regression guards in the existing official/control test files before touching assets; run affected tests serially on current v2 assets and record expected RED. These tests prove instruction contracts, not extraction or writing quality.
3. [x] Make targeted edits to the five references: function-preserving adaptation + applicable chat/dialogue routing; both prop-selection predicates; real entity/location-reference checks; saved-body new-resource handoff within existing chronicler ownership. No schema/UI/generic Agent prompt or tool-description changes.
4. [x] Set only screenplay-writing metadata to v3, recompute sorted-reference SHA-256, update current timestamp; keep the 15-reference manifest and all other skill metadata unchanged. Do not touch any business or installed-skill database.
5. [x] Run official and control suites, sync and prompt-guideline suites serially with `timeout 240 fvm flutter test --no-pub --concurrency=1`; write complete logs before summarizing. Run narrow analyze, format and diff checks; attempt LSP diagnostics for modified Dart files and report unavailable honestly.
6. [x] Parent verifies actual diff and logs, then dispatches independent `trellis-check` on gpt-6.1-sol to check the whole iteration and fix within scope. Re-run affected checks after fixes. Record findings and neutral scenario review separately from unrun live/model validation.
7. [x] Update verification/task status and perform spec-review judgment; prepare the scoped work commit after final checks, no push/amend. Do not archive the active task or invent a PR/base branch resolution.

Final evidence: implementation and independent check both ran all 87 tests successfully; analyzer/format/diff passed. Reviewer made no fixes. Parent verified final logs, hash and exact preserved examples/timing. V3-A–V3-E are instruction-level acceptance only; no live extraction or model-quality run. See verification.md. This checklist is included in the scoped work commit; the commit hash is recorded by Git and reported at delivery.

Logs: use `/tmp/reveric-screenplay-v3-*` and record exact exit/count results. No codegen is required. Existing source/agent contract changes do not authorize model calls or rewriting the user's current episode.

## Historical v2 plan

## Historical planning gate

The user explicitly approved the v1 → v2 maintenance exception and implementation with “同意啊”. The product scope and method comparison are already approved. Validate manifests, start this task, implement and check. No further product confirmation is needed. Do not infer publication state from missing tags, modify business data, or make paid model calls.

Use concise original method text, not copied external prose/code/samples. Preserve existing app contracts and writing autonomy. The eight-file product patch from the rolled-back attempt may be reviewed and reused as a starting point; it is not accepted merely because earlier tests passed.

## Ordered work

1. Review current skill discovery, relevant Writer/Agent guidance, official registry, loaders and existing contract tests; verify the proposed input-organizing route can be discovered without bypassing customized/disabled skills.
2. Extend the existing main skill and adaptation/source-analysis references with segment-level input diagnosis and the approved adaptive organizing procedure. Reuse the existing adaptation decisions and craft references rather than copy them or add a parallel skill.
3. Extend episode-planning/scene-writing with natural scene boundaries, real resource reconciliation and actual-written-body checks. Keep local tasks local; avoid mandatory full-season planning or duration questions for a simple scene-organization task.
4. Clarify real body/cast reads and resource references in the existing bundled screenplay operations reference, without changing tool descriptions, schemas, nullable draft contracts, persistence APIs or Agent lifecycle.
5. Update only 「剧本写作」 to version 2 with current updatedAt and exact contentHash. Preserve installation/custom/disabled semantics and existing sync logic. No direct Debug snapshot updates are required by this version-increase strategy; do not access business databases.
6. Review concrete contrasts for prose, existing screenplay, dialogue-only, synopsis and mixed/partial material. Add narrow contract tests only where they guard meaningful routing/loading/behavior boundaries.
7. Run the applicable commands below serially, review actual diffs and report deterministic validation separately from unrun qualitative model acceptance.

## Candidate narrow validation commands

Implementation and final independent checks are complete. All four test files below ran serially: 13 + 23 + 32 + 15 = 83 tests passed. Targeted analysis (also including the sync and prompt-guideline tests), format and diff checks passed. See verification.md for exact final evidence and the handoff omission found/fixed during checking. No live model-quality comparison ran.

```bash
fvm flutter test --no-pub --concurrency=1 test/shared/services/bundled_official_skills_test.dart
fvm flutter test --no-pub --concurrency=1 test/shared/services/bundled_control_skills_test.dart
fvm flutter test --no-pub --concurrency=1 test/shared/services/ai/prompt_tool_guidelines_test.dart
fvm flutter test --no-pub --concurrency=1 test/shared/services/official_skill_sync_test.dart
fvm flutter analyze --no-pub lib/shared/services/bundled_official_skills.dart test/shared/services/bundled_official_skills_test.dart test/shared/services/bundled_control_skills_test.dart
git diff --check
```

Sync tests validate compatibility; they do not authorize changing sync logic. Static text/hash tests do not establish actual model creativity, extraction accuracy or universal input handling. No paid/model call or real screenplay rewrite is authorized by this planning task.
