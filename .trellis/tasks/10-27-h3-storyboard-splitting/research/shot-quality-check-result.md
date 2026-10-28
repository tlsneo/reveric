# Third-round H3 shot quality — independent check

**Verdict: no unresolved findings; ready for the main session's final diff review.** No delegation, commit, task-state/checklist/verification edits, push or amend. Only three of the five authorized product/test files needed review fixes; this report is the checker's only task-record addition.

## Findings fixed

1. **The teaching example dropped a visible source event.** The user's actual excerpt includes “虫族母巢被炮火吞没”. The incoming example only showed sustained fire and cautioned against inventing destruction. Those are not equivalent: gunfire can obscure the base without establishing destruction, an explosion or victory. Restored the visible progression “母巢轮廓被炮火逐渐遮没” in the source-event paraphrase, plan, summary, retention explanation, first Shot and acceptance notes. The first Shot establishes the fleet/target relationship, shows sustained fire obscuring the outline, then cuts to the hands. The existing 3-second opening budget remains a teaching estimate, not a measured result. Removed the unsupported “战列” qualifier so the example uses the source's 人类巡洋舰. No new dialogue, Enter/send action, destruction, victory, appearance or reaction was introduced.
2. **Subject 3's retention label contradicted its defined purpose and the established H3 example.** Read `research/chinese-check-result.md` and the unchanged H3 truth guide. Subject 3 supplies desk relationships, light and visible materials; cropping does not discard those roles. Changed only the new recipe's Subject 3 to `fully_preserved`, with a purpose-based explanation. Subject 2 stays `partially_preserved`: its game state progresses instead of freezing the reference.

Extended the existing third new loader test, not the number of tests or a parser framework. It now checks barrage coverage in plan/summary/first Shot/acceptance, fire-before-obscuration order, no invented destruction in the plan/acceptance, and the two distinct retention labels. An initial full-file RED run failed specifically on missing obscuration, **19 passed / 1 failed**, before the prose fix (`/tmp/reveric-h3-shot-quality-check-red.log`, exit 1).

## Substantive review and preservation

Read curated `check.jsonl` entries, third-round PRD/design/implementation plan, follow-up and implementation report, all five full sources, neighboring H3/storyboard/video formats, and sync source/tests. Reviewed the actual connected content, not only keyword matches.

- Main route is source events → shootable plan → target-model prompt → per-Shot review → saved readback. Production gives concrete framing, visible action endpoints, cut versus camera movement, sound and duration checks; local changes stay local. Plans/checklists/status are outside the actual H3 prompt.
- Six fields are complete and ordered; Subjects 1–3 and reference roles remain consistent. Hypothetical three-image assumptions and ellipsis refs are explicitly not real bound inputs or directly submittable IDs. Explicit full-reference targets with missing inputs remain complete drafts, with pending state outside prompt; no silent T2VA substitution. Normal other modes/models remain supported.
- Eight seconds is example-only, with cuts at 3 and 6 seconds strictly inside its duration. Fixed camera and hand motion are distinct. The keyboard framing contains TrackPoint/G/H/B and the hand; final framing returns to a readable screen. GG stays typed text, not speech or a sent message. Game content stays on-screen. Exact twelve-ship counts, UI, text and actual cut execution remain unguaranteed.
- Independent byte comparisons confirm unchanged frontmatter/name/when_to_use/description, original four recipes including preamble, and all previous **17 tests** except the authorized version expectation. Exactly **3** new tests. H3 truth guide, sync source/test and first-round UI source/test are byte-identical to HEAD. Registry differs only in production version/hash/date; identity, paths, other Skills and loader code are unchanged. No new runtime validator or interface contract.

## Final metadata and scope

Production **v3**, expressly approved after disclosure that v2 publication is **UNKNOWN**. Independent `git tag --list` remains empty; this does not establish published or unpublished status.

- Final hash: `f6ce8132a48aafead8d21cb8438adeea02b05c595e1196a6fa3805411593a8d8`
- Final `updatedAt`: `2026-10-28T09:43:18+00:00`
- Independently recomputed SHA-256 from raw SKILL bytes plus all **15** registered references sorted by full path, each NUL/path/NUL/raw bytes; registry agrees. Local production Markdown links resolve.
- Exactly the five authorized tracked product/test paths differ from HEAD. Reviewer edits are `references/shot-recipes.md`, `bundled_official_skills.dart`, and `bundled_official_skills_test.dart`. Parent-owned planning and unrelated remote-catalog planning were not edited. The implementation report's earlier hash/date are superseded by the values above.

## Executed verification

All Flutter commands ran serially, with complete redirected logs inspected after completion. Final commands all exited **0**:

```bash
timeout 240 fvm flutter test --no-pub --concurrency=1 test/shared/services/bundled_official_skills_test.dart > /tmp/reveric-h3-shot-quality-check-official.log 2>&1
# 20/20 passed: 17 previous + 3 new.
timeout 240 fvm flutter test --no-pub --concurrency=1 test/shared/services/official_skill_sync_test.dart > /tmp/reveric-h3-shot-quality-check-sync.log 2>&1
# 15/15 passed; expected simulated failure/retry logs are not failures.
timeout 240 fvm flutter analyze --no-pub lib/shared/services/bundled_official_skills.dart test/shared/services/bundled_official_skills_test.dart > /tmp/reveric-h3-shot-quality-check-analyze.log 2>&1
# Two items, no issues.
fvm dart format --output=none --set-exit-if-changed lib/shared/services/bundled_official_skills.dart test/shared/services/bundled_official_skills_test.dart > /tmp/reveric-h3-shot-quality-check-format.log 2>&1
# Two files, zero changes.
git diff --check > /tmp/reveric-h3-shot-quality-check-diff.log 2>&1
# No diagnostics.
```

Read-only Python audit of scope, old-test/frontmatter/recipe byte preservation, registry-only metadata changes, independent hash, local links and tags: `/tmp/reveric-h3-shot-quality-check-scope.log`, exit 0. Before final verification, `fvm dart format` on the same two Dart files formatted only the new test additions (`/tmp/reveric-h3-shot-quality-check-preformat.log`, exit 0). No concurrent Flutter or live output pipe. Flutter's root-user warning is informational.

## Limits and handoff

Static checks prove packaged text, loader contracts and existing sync behavior, not real Agent compliance, H3 filmmaking quality, precise frames/cuts/UI/counts/text, or an upgrade on any user's device. URLs were compared with local authoritative research, not fetched for live availability. No real model/provider/media calls, business/installation database access, saved-storyboard edits, automatic binding, pub/codegen/clean/stash, API/schema/UI changes or remote-catalog work.

Existing agent-skills/testing and reuse/cross-layer rules cover these local corrections; no new spec pattern is needed. Main retains final actual-diff inspection, task state/checklist/verification, spec-review decision and scoped commit ownership.
