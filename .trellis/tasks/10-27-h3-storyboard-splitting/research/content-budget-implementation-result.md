# Fourth-round implementation result: H3 content and performance budgets

## Scope

Implemented directly without further agents or a commit. Only these five product files were edited:

1. `assets/official_skills/screenplay-production/SKILL.md`
2. `assets/official_skills/screenplay-production/references/production.md`
3. `assets/official_skills/screenplay-production/references/scene-example.md`
4. `lib/shared/services/bundled_official_skills.dart`
5. `test/shared/services/bundled_official_skills_test.dart`

This report is the one additional task-local artifact. Parent-owned planning files, pre-existing research/WIP, and the separately observed change to `.trellis/spec/guides/cross-layer-thinking-guide.md` were not edited by this implementation. No `docs/` reads/searches, runtime/cache/provider/tool/UI changes, database changes, pub/codegen/clean/stash, media generation, or live model calls were performed. Existing Dart headers were preserved because responsibilities/rule dependencies did not change.

## Implemented method

The actual numbered production workflow now reads source facts and dramatic change, designs shootable shots with complete performance budgets, then chooses independent generation groups. Target serialization, shot/cross-group review, write and readback follow. The main Skill contains a compact route rather than a second detailed method.

The detailed method distinguishes sequential time from genuinely simultaneous performance, counts opening/reaction/reading time once, labels estimates versus measurements, and rejects fixed character rates/uniform action seconds as measured facts. Approximately five seconds remains a GPU-budget preference, not a maximum, minimum, or filler target; legal shorter clips and justified longer clips are allowed. It adds inspectable prompt-external grouping/time rationale, action ownership (prior state → unique executing Shot → resulting state), and adjacent-group merge/split review. There is no new resource, validator, mandatory per-second table, fixed shot count, or longer default.

Full-reference readiness and other model/input routes remain intact. The H3 format attachment and existing six-field screen-operation recipe were not edited.

## Tests first: observed RED

Before any product resource/registry edits:

```bash
timeout 240 fvm flutter test --no-pub --concurrency=1 test/shared/services/bundled_official_skills_test.dart > /tmp/reveric-h3-content-budget-red.log 2>&1
```

Exit 1: **19 passed, 4 failed**, comprising the intended legacy-chain expectation update plus three new regressions:

- The main Skill still exposed the old work chain without performance budgeting and independent grouping.
- Production step 2 explicitly allocated matters to clips before step 3 designed shots; the new ordered-step test rejected this old method.
- The real whole-scene case lacked the per-clip duration/performance-budget rows (zero rows, three clips).
- The real generic prompts had no H3 spoken `<d>[Chinese] …</d>` blocks; the four required spoken lines were absent from that parsed speech list.

This was not a version/hash-only RED: the original v3 expectation still passed and no product resources or registry metadata had changed. The saved RED log is the final pre-product run; a first equivalent RED run also produced 19/4.

All twenty original test names remain. Only the obsolete chain and production-version expectations changed; original H3 Chinese/fixed-syntax, six-field reference, screen recipe, packaging, links, hash and registry guards remain. Three new tests cover the actual method, complete H3 case fields/cuts/budgets, and exact source/speech/action-state progression. Parsing stays local to these fixture tests, not a general validation framework.

## Before/after whole-scene review

The original lost-property-counter script, character identities, visual assumptions, and **entire picture-preparation section are byte-identical** to HEAD. No user family/reception story or third-party example was introduced.

Before: three generic ten-second videos, with separate reaction/reading/ending windows and generic `首帧：` / `结束状态：` wrappers. They did not teach H3 serialization or inspectable substantive-short/necessary-long grouping.

After: three complete Chinese T2VA three-field prompts, explicitly unbound assumed text drafts, without fake references. The prepared-picture examples remain conditional teaching assumptions, not claimed video inputs. An explicit full-reference target must still remain pending until real binding; this example is not a substitute full-reference final draft.

| Clip | Estimated budget | Internal cuts | Rationale and ownership |
|---|---|---|---|
| A, 8s / 8000ms | 0.4 opening + 3.2 first line + 0.5 press lid + 1.4 question + 2.1 answer + 0.4 necessary wait = 8.0 | 3.600s, 5.500s | Three lines form one coherent confirmation exchange. Speech is sequential; the question follows pressing the lid. Eight seconds avoids rushing the original lines and action; three speaking turns do not become three generation tasks. Ends with the clerk's palm already on the closed lid. |
| B, 6s / 6000ms | 0.7 move palm + 2.3 push/receive/release + 1.7 move fingers/open/clear lid edge + 1.3 read key detail = 6.0 | 3.000s | Small unlatched box, short table movement. Push and receiving overlap within the same contact window, not separately counted. The cut follows receipt and only changes view; opening occurs once and the missing tooth is visibly revealed. Six seconds avoids rushing contact or deleting the information-reading window. |
| C, 5s / 5000ms | 0.7 stop/look up + 1.5 final short line + 1.1 close lid + 1.7 lift/embrace box = 5.0 | None | A substantive short clip with reaction, speech and two ordered object-state changes in one medium shot. Closing follows the final line, then the small unlatched box is lifted to the body. It ends at arrival, not an added frozen hold. |

These are plausible **text estimates**, not trial-read/audio/video measurements or guaranteed model performance. The case explicitly assumes the target channel permits 5/6/8-second integer durations and leaves provider/model unconfigured and output fps/frame count uncalibrated. No fixed character rate or uniform action duration was used as a measurement. Slower real delivery, a different object or incompatible legal durations requires re-budgeting, not speeding up or deleting content.

Action review: A/Shot 2 exclusively presses the lid; B/Shot 1 exclusively removes the palm, pushes and receives; B/Shot 2 exclusively opens and reveals; C/Shot 1 reacts, speaks the final line, closes and lifts. Later shots carry completed states rather than repeat executions. All four original dialogue lines appear exactly once, in original order, only once each across final video prompts and in spoken d-blocks. A→B carries pressed/closed; B→C carries open/key-in-box. Complete-question/answer and reveal→reaction boundaries are meaningful independent-generation points; merging A+B or B+C unnecessarily lengthens a single generation against the GPU preference, while splitting the exchange or handoff further would add fragmentation. Actual generated seams still require observation.

## Review defects found and corrected

- The original pre-shot allocation order was the root method gap; it was reordered instead of adding another cache/runtime rule.
- The first post-edit loader run had **22 passed / 1 failed** because a newly added broad negative assertion rejected the sentence “不预先分配给片段”. Corrected the test to require that explicit prohibition and reject the old positive “再分配给片段” instruction. The stage-order checks remain strict. This was a test-negation bug, not a product failure hidden by removing the new method requirement.
- Review caught a visual subtitle instruction inside A's sound-only field; removed it there while preserving the visual no-subtitle instruction in the description.
- Strengthened positive action checks to count each exact execution once across all shot bodies, not merely one matching shot, and matched internal cuts to cumulative performance-budget boundaries. These static guards cannot detect arbitrary semantic paraphrases; manual review remains necessary and neither proves real filming quality.

## Final verification (all Flutter commands serial)

All commands exited 0 unless explicitly noted above. Complete logs were redirected before inspecting output.

```bash
timeout 240 fvm flutter test --no-pub --concurrency=1 test/shared/services/bundled_official_skills_test.dart > /tmp/reveric-h3-content-budget-official.log 2>&1
timeout 240 fvm flutter test --no-pub --concurrency=1 test/shared/services/official_skill_sync_test.dart > /tmp/reveric-h3-content-budget-sync.log 2>&1
timeout 240 fvm flutter analyze --no-pub lib/shared/services/bundled_official_skills.dart test/shared/services/bundled_official_skills_test.dart > /tmp/reveric-h3-content-budget-analyze.log 2>&1
timeout 60 fvm dart format --output=none --set-exit-if-changed lib/shared/services/bundled_official_skills.dart test/shared/services/bundled_official_skills_test.dart >> /tmp/reveric-h3-content-budget-format.log 2>&1
git diff --check > /tmp/reveric-h3-content-budget-diff.log 2>&1
```

- Official loader suite: **23 passed, 0 failed** (all 20 originals retained plus 3 regressions).
- Unchanged official sync suite: **15 passed, 0 failed**; error messages in its log are expected failure/retry test fixtures, not failed tests or actual database operations.
- Narrow analyze: **No issues found** for the two authorized Dart files.
- Format check: **2 files, 0 changes**. The same format log also contains the earlier formatting write (test file only), performed with `timeout 60 fvm dart format …`.
- `git diff --check`: clean.
- LSP diagnostics requested after code changes for each Dart file: **unavailable**, “No LSP server configured for file type”. Actual fallback was pinned FVM CLI analysis, not a claimed LSP pass.
- Independent Python audit (filesystem enumeration of 15 references, NUL/path/content hash serialization, local-link resolution, metadata-only registry comparison, original case/preparation equality, 20→23 test-name retention and exact five-product-file scope): passed. Log: `/tmp/reveric-h3-content-budget-audit.log`.

Production metadata only: version **4**, updatedAt **2026-10-28T11:37:30+00:00**, independently recomputed contentHash **68341966ca2aa51ff959886cc7fdd92ec3315b1afafc22855748fdd69a748b2e**. The local repo remains non-shallow with no tags; v3 publication is unknown. The separately approved v3→v4 decision is followed without adding hash-based upgrade fallback or modifying installation snapshots. No other skill metadata changed.

## Honesty and handoff

These tests/audits establish asset loading, packaging, local links, intended text contracts, deterministic fixture constraints and existing sync behavior. They do **not** establish real app Agent comprehension, H3 generation quality, natural performance measured in media, exact cuts/frames, GPU memory consumption, Windows/macOS/Android device behavior, current user installation upgrade, or refresh of old session history. No live model/video call or database write was performed.

No engineering-spec change was needed from this implementation: the creative method belongs in the approved existing Skill, and no new runtime contract/pattern was introduced. Any parent-owned spec work remains separate. The parent should independently review the complete sample and logs, then perform its own check/commit; this sub-agent has not staged or committed files.
