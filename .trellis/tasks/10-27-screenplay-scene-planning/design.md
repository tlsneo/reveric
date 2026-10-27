# Skill proposal — diagnose and organize supplied material

## Status and scope

The user now explicitly asks for better skills so AI can analyze whatever narrative material is pasted and organize it well. This supports a skill/method-first proposal, not a source-work selector or new UI. Paste-surface identification is not a blocker for the current method design. The user approved the selective-adaptation recommendation after external research. Product direction, the explicit v1 → v2 exception, and implementation are approved by the latest user reply “同意啊”. There are no remaining product decisions. This is one cohesive skill enhancement.

## Evidence and smallest proposed ownership

The existing `assets/official_skills/screenplay-writing/SKILL.md` already covers story-to-screenplay adaptation and scene writing. Its current references provide source-event analysis, character/place consolidation, prose-to-screen conversion and scene craft. Reuse this business owner rather than create a competing skill only because input formats differ.

The specific proposed improvement is an explicit integrated task: diagnose supplied material, preserve effective parts, choose the appropriate transformation, reconcile real resources, arrange/write scenes and check saved results. The current files do not explicitly teach this task for synopsis, dialogue-only and mixed/partial material as a unified route. This is a source-backed content gap, not proof of the user's particular model failure.

Proposed file responsibilities:

- `assets/official_skills/screenplay-writing/SKILL.md`: discover/route "organize this material into a screenplay" without requiring users to pick the material format or enter a value-assessment task first. Preserve local-task scope and optional skill semantics.
- `references/adaptation.md`: compact end-to-end material-organizing procedure using existing methods, with the user-approved fidelity/expansion boundary.
- `references/source-analysis.md`: segment-level diagnosis of prose, synopsis, dialogue, existing screenplay and mixed/partial material; track actual coverage, facts, uncertainty and event/entity dependencies. No mandatory whole-book setup or verbose analysis table for every paragraph.
- `references/episode-planning.md`: scene boundaries by space/time/continuous action; do not ask for episode duration merely to organize supplied scenes when no episode-design task was requested.
- `references/scene-writing.md`: visible action/dialogue, preserving valid existing text, authorized resource completion and bounded saved-content self-check.
- `assets/bundled_skills/screenplay-tools/references/screenplay.md`: actual read/write/reference operations, complete element/cast reads, source text versus metadata and real resource reuse. Method files refer to this owner instead of duplicating schemas.
- Official registry metadata and existing loading/hash/contract tests only where affected. Recheck Agent discovery/routing for this request, but do not bypass custom/disabled skills or preselect prompt edits without evidence.

## Adaptive procedure

1. Read the actual supplied material and necessary current-work context, not just summaries.
2. Infer the kind and completeness of each relevant portion. This diagnosis must change the chosen action: adapt prose; preserve and improve valid screenplay; organize dialogue without inventing speakers; treat synopsis expansion and missing facts as creative gaps; process mixed material locally rather than rewrite everything the same way.
3. Establish key events and causal/information dependencies; reconcile characters, meaningful props and locations with existing target resources. Do not inventory every background object or infer unsupported appearance/layout facts.
4. Arrange scenes by location/time/continuous events and write the required structured body. Preserve quiet scenes and effective original text. Scene boundaries are not five-second cuts.
5. For an explicitly authorized write request, create/reuse actual records and save real body elements. For discussion-only requests, do not mutate resources. Tool schemas and current permissions remain authoritative.
6. Read back the saved scope and check event coverage, duplication, speakers, ordering and continuity. Hand fact maintenance to the existing owner; do not build a second automatic review pipeline.

Steps may cooperate per batch. They are a working method, not a required lengthy intermediate reply or a claim that merely listing a plan completed the task.

## Validation design

Add/use examples that differentiate prose, valid screenplay, dialogue-only, synopsis and mixed/partial material. Deterministic tests can guard skill/reference discovery, loaded contracts, metadata/hash consistency and existing override behavior. They cannot prove model-quality improvement. A qualitative comparison on representative material requires a separately authorized model run; do not claim "any input always produces a good complete screenplay."

## Approved maintenance and compatibility

- Preserve existing autonomy/confirmation rules (`screenplay-writing/SKILL.md:17`); no new approval question is needed merely to retain them. The user accepted adapting shuohao-skills stage deliverables/evidence/reconciliation into the current skill, not its independent JSON/Node pipeline, short-drama quotas or a second skill stack. Preserve existing scene/body records and continuity ownership. The user separately approved the v1 → v2 exception and proceeding after its effect on official installations was explained.
- Existing entity extraction is already owned by story-continuity after body writing; real resource prerequisites are already required before scene references. Only strengthen material-to-prerequisite/authorized-assignment handoff and source coverage checks; do not duplicate this pipeline. See the latest comparison in `research/scene-planning.md`.
- Update this official skill to version 2, recompute contentHash and set current updatedAt under the explicit user exception. Publication status remains unknown. Existing sync logic stays unchanged; no unchanged-version Debug snapshot strategy or business DB access is needed.

No new UI, database schema, standalone skill, source-selection requirement, media generation or H3/production work is proposed. The minimal file scope and executable checks are finalized in implement.md. Before deployment, rollback means reverting the cohesive content/metadata/test diff; do not silently downgrade a user installation that already upgraded.
