# Fourth-round independent check: H3 content/performance budgets

## Result and changes

**No concrete in-scope defects remain. No product fixes were necessary.** Reviewed the actual five-file HEAD diff, complete Skill and production workflow, whole scene and picture preparation, loader implementation and all tests, current H3 format, video-format routing, and unchanged screen-operation recipe against the fourth-round requirements and nine check-context entries. No agents were spawned and nothing was staged or committed.

The only file written by this check is this report. Parent-owned task/spec changes and unrelated untracked diagnoses/model-catalog work were preserved. No runtime/cache/provider/UI/tool/schema/database/media changes, dependency operations, codegen, clean, stash, network or live-model calls.

## Content review

- The operative chain now budgets source facts and shootable performances before choosing independent generation groups, then formats, checks, saves and reads back. Approximately five seconds is explicitly neither maximum, minimum nor filler target; longer content requires a reason and shorter legal clips remain allowed. No fixed character rate, uniform action duration, mandatory per-second framework or longer default was introduced.
- Original lost-property-counter text, visual assumptions and the **entire image-preparation section are byte-identical to HEAD**. Preparation remains conditional image work, not a claim that video references are bound. All three video drafts correctly use no-input T2VA fields; real Ref2VA, frame-input and other-model routes remain. The six-field device recipe and H3-format attachment are unchanged.
- **A: 8s, cuts 3.6/5.5.** Three exact original lines remain sequential. Pressing precedes the question; the answer precedes the handoff. Face/hand/lid framing keeps the pressed-lid endpoint visible and the key concealed. The 0.4+3.2+0.5+1.4+2.1+0.4 estimate totals eight seconds without compressing the exchange into five.
- **B: 6s, cut 3.0.** Carries the already-pressed lid, then uniquely releases the palm, pushes, receives/releases, opens and reveals. Both hands and the transfer surface are framed; the near view can show the small box/key. Opening and detail reading share that view rather than repeating the opening for an insert. The 0.7+2.3+1.7+1.3 estimate totals six; mutual contact is not double-counted.
- **C: 5s, one Shot.** Carries the already-open box; stop/look-up precedes the last line, then closing precedes lifting/embracing. The medium view contains faces, hands, table and chest position. The 0.7+1.5+1.1+1.7 estimate is plausible for the stated small unlatched box and short line; it ends on arrival, not a filler hold. These are not measured timings.
- Each source action executes once; later descriptions are completed-state anchors, not re-enactments. Negatives prohibit extra actions/voices without deleting required source facts. Identities, screen sides, hinge direction and dialogue speakers are consistent. C's first spoken voice `(S2)` is legitimate stable identity numbering: the current format does not require the first voice of each independent clip to be `(S1)` and itself illustrates an initial `(S2)`. No taste-only renumbering was made.
- A→B ends an intact exchange before handoff; B→C ends the reveal before reaction. These are specific editable boundaries, not line-count splitting. The method also addresses the known dialogue-fragmentation and repeated-gesture counterexamples without embedding those user stories in assets.

## Tests and their limits

The three added tests exercise actual loaded workflow/case content, format/duration/budget/cut consistency, and exact spoken/source-action order and ownership. They are fixture-specific lexical guards, not semantic evaluators. Exact cut/action expectations intentionally freeze this teaching example; paraphrased duplicates or physically invalid changes can still require manual detection. No runtime parser or evaluation framework was added.

Independent comparison confirms all **20 existing tests** remain byte-identical except the authorized version and workflow-chain expectations; reference/screen/hash guards are intact. The saved implementation RED log was inspected: **19 pass / 4 fail**, rejecting the old workflow/order and missing H3 case/budgets, not merely metadata. No new defect was found, so no artificial additional RED or test weakening was introduced.

## Independently executed verification

Commands ran **serially**, using FVM and complete redirected logs, all exit 0:

```bash
timeout 240 fvm flutter test --no-pub --concurrency=1 test/shared/services/bundled_official_skills_test.dart
timeout 240 fvm flutter test --no-pub --concurrency=1 test/shared/services/official_skill_sync_test.dart
timeout 240 fvm flutter analyze --no-pub lib/shared/services/bundled_official_skills.dart test/shared/services/bundled_official_skills_test.dart
timeout 60 fvm dart format --output=none --set-exit-if-changed lib/shared/services/bundled_official_skills.dart test/shared/services/bundled_official_skills_test.dart
git diff --check
```

Logs: `/tmp/reveric-h3-content-budget-check-{official,sync,analyze,format,diff}.log`. Loader **23/23**, unchanged sync **15/15**, analysis **no issues**, formatting **two files / zero changes**, diff clean. Sync error traces are expected mocked failure/retry scenarios. CLI analysis is the actual static check; no LSP success is claimed.

Independent Python audit: `/tmp/reveric-h3-content-budget-check-audit.log`. Exactly five tracked product files; registry metadata-only; all 15 references registered; 62 package-relative links resolve; retained sections/guards verified; hash independently recomputed. Version **4**, updatedAt **2026-10-28T11:37:30+00:00**, contentHash **68341966ca2aa51ff959886cc7fdd92ec3315b1afafc22855748fdd69a748b2e**. No asset edits during check, so metadata was not rewritten. Repository non-shallow, tags absent: publication remains unknown; the independently authorized v3→v4 decision stands.

These checks do not prove real Agent adherence, measured performance, video quality, precise cuts/frames, GPU use, supported-device execution, installation upgrades or old-session refresh. No live application/model/video/DB validation was performed. No additional engineering-spec change is required by this check; creative methods remain in the approved Skill. Parent owns final integration and commit.
