# Skill-first execution plan — approved

## Planning gate

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
