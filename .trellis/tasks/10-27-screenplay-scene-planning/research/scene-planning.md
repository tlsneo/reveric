# Upstream screenplay scene-planning evidence

> Scope update: the latest user request is a stronger existing Skill that autonomously analyzes pasted prose, synopsis, dialogue, screenplay or mixed drafts and organizes them into a screenplay with resources. Follow the revised PRD/design. Source-work selection is not required; `research/adaptation-entry.md` is optional background. The original scene-only estimate is superseded.

## Scope and confidence

This task improves application instructions, not an observed deterministic scene-splitting algorithm. The user's actual generated scenes, source text, installed skill overrides and runtime tool trace are unavailable. Do not label possible causes as a confirmed cause of that user's output.

The downstream production split handoff in `lib/desktop/features/storyboard/region.dart:392` is a separate known issue and is explicitly excluded from this task, along with clip durations and H3/media generation.

## Existing ownership

- `assets/official_skills/screenplay-writing/SKILL.md`: optional professional writing methods and reference routing. Its current task table routes episode planning and writing individual scenes, but does not explicitly route scene arrangement/splitting/merging.
- `assets/official_skills/screenplay-writing/references/episode-planning.md`: episode structure, scope, timing and persistence of plans into existing outlines/beats/synopses. Extend this existing reference for arranging scenes; do not add a standalone skill or duplicate screenplay operations here.
- `assets/official_skills/screenplay-writing/references/scene-writing.md`: reading direct context, writing visible action/dialogue, preserving quiet scenes, distinguishing plan from body, and local edit boundaries. It has a brief final check but no compact, explicit coverage/duplicate/cross-scene-state handoff checklist.
- `assets/official_skills/screenplay-writing/references/scene-craft.md:5–37`: existing scene necessity, causal action/results, spatial consequences and quiet scenes. Reuse these principles instead of adding another mandatory conflict formula.
- `assets/official_skills/screenplay-writing/references/review.md`: explicit user-requested review; already distinguishes proven problems, missing evidence and optional suggestions. Do not turn routine writing self-check into a new independent-review workflow.
- `assets/bundled_skills/screenplay-tools/references/screenplay.md`: shared resource/read/write contracts. The distinction between scene metadata and body-element reading belongs here; writing-method files should refer to this contract instead of copying schemas.
- `assets/prompts/agent/orchestrator.md:43–49`, `writer.md:48–68` and `plot_architect.md:27–32`: existing skill loading, planning/body separation, real references and fact-maintenance routing. No agent lifecycle or new task routing system is necessary for the proposed change.

## Verified resource behavior

- `lib/shared/services/ai/tools_screenplay.dart:330–355`: `Read /scenes/{scene_id}` returns summary metadata/events, whereas `/scenes/{scene_id}/elements` returns actual body elements. `/scenes/{scene_id}/cast` is independently readable. A scene metadata read cannot prove that body text has been read.
- `lib/shared/services/ai/tools_screenplay.dart:547–585`: scene creation accepts optional `location_id`, cast and elements.
- `lib/shared/services/screenplay_create_orchestrator.dart:71–78`: cast and body writes occur only when supplied. This supports intentional planning/draft scenes; do not change it into unconditional database/tool validation.
- Desktop `lib/desktop/features/screenplay/scenes.dart` and mobile `lib/mobile/features/screenplay/scenes_page.dart` expose manual scene management. The shared `lib/shared/widgets/screenplay/editing_controller.dart:542` split operation divides authored document content; it is not an AI quality algorithm. No dedicated upstream AI scene-splitting button was established in investigation.
- App-level prompt and skill resources are shared by desktop and mobile. No platform UI edit is needed for instruction-only changes.

## Recommended content delta

1. In existing skill discovery/routing, explicitly include arranging, splitting, merging and checking scene boundaries; direct those tasks to the existing episode-planning reference.
2. In that reference, add a compact planning pass based on actual relevant material: space/time and continuous action; scene function and entering/leaving state; reason for a boundary and connection to the next scene. A reaction, camera change, emotional turn or paragraph break alone is not a boundary. Use short contrastive examples, including same classroom continuous exchange versus same classroom on another day, and corridor-to-classroom spatial transition.
3. State that scene arrangements are planning judgments, not new mandatory data fields or a fixed output schema. Keep local tasks local and do not demand a full replan before a line edit. Do not impose fixed seconds, fixed scene counts or conflict on quiet scenes.
4. In scene-writing, add explicit real entity reuse/authorized completion and actual-written-content self-check: source/beat coverage, duplicate events/dialogue, speaker assignments, ordering and time/place/knowledge/possession continuity. Preserve the orchestrator's existing fact-maintenance ownership and do not manufacture an additional automatic review loop.
5. In the bundled screenplay operations reference, clarify scene detail versus element/cast reads, pagination/completeness and metadata-only/empty-body status. No tool description, schema, API or service behavior change.

## Validation boundaries

Static regressions can verify skill/reference discovery, real paths, document contracts, assets/hash consistency and existing customized/disabled semantics. They cannot prove a model will always obey the instructions or that the user's existing screenplay is improved. A later qualitative acceptance run requires user-provided source plus several adjacent scenes or an explicitly authorized real app generation; no such call is included in planning.

## Latest skill-focused inspection

Read the current main screenplay-writing skill, source-analysis, adaptation, adaptation-decisions, episode-planning and scene-writing references, plus the bundled screenplay-tools main and screenplay reference in full.

- Current main skill already accepts story material and existing drafts, limits questions to consequential gaps, routes adaptation/episode/scene/dialogue/review, and respects actual-write versus discussion boundaries. Do not claim these methods are absent.
- Current source-analysis is organized around short/long source material and event causality; it does not explicitly give a differentiated prose/synopsis/dialogue-only/valid-screenplay/mixed-material organizing route. Adaptation currently centers on adaptation choices and requested deliverables, rather than this integrated pasted-material task.
- The concrete proposal is to make material diagnosis affect transformation, preserve valid parts, link entity reconciliation to writing, and add contrastive examples/self-checks. Existing source analysis and adaptation methods remain the foundation, not something to duplicate in a new skill.
- Current adaptation-decisions already limits prop tracking to meaningful evidence/exchange/identity/danger/relationship functions and cautions against silently altering evidence chains while externalizing psychology. Preserve those limits.
- Current episode-planning asks about duration for an episode-design task. A new material-organizing route must not turn that into an unnecessary prerequisite for every pasted scene.
- The user asks for AI autonomy; exact paste field identification is not a blocker for this skill-method proposal. No new UI or automatic paste listener follows from that request.
- Correction after comparing the actual instruction chain: ordinary expression/action/rhythm autonomy and confirmation for consequential changes are ALREADY defined in `screenplay-writing/SKILL.md:17` and `orchestrator.md` user-decision rules. Do not manufacture a new product-decision gate for keeping that existing behavior. Only propose a new decision if changing that boundary.

## Existing workflow versus targeted changes

Full inspection of orchestrator, writer, plot_architect, story-continuity main/screenplay reference, scene-craft and review establishes:

- `assets/prompts/agent/orchestrator.md:43–48` already routes available screenplay skills, writes real scene body, then delegates factual maintenance to the chronicler (subject to user rules/no-delegation restrictions).
- `assets/bundled_skills/story-continuity/references/screenplay.md:7–17` ALREADY reads complete body/cast, extracts character appearance/state and reconciles aliases/locations/items before creation. Lines 22–42 maintain scene titles/emotions/events and cumulative story state. Claims that entity extraction or saved-body checking are wholly absent are incorrect.
- `assets/bundled_skills/screenplay-tools/references/screenplay.md:11` already requires real prerequisites before scene references. Improve the explicit handoff from supplied-material analysis to those prerequisites; do not move all post-write fact maintenance earlier or duplicate it.
- `assets/prompts/agent/writer.md:15` only permits non-body data writes when the assignment authorizes them. Thus a delegated integrated organizing task must either include permitted resource completion in its assignment or have the caller complete prerequisites first. A skill change alone cannot override that boundary. This is a handoff risk, not evidence the user's session failed there.
- The existing route is task selection → adaptation/episode/scene methods as needed → real resource prerequisites → body write/readback → chronicler fact extraction → caller checks actual results. It is not a fixed enforced runtime pipeline and optional skills may be customized/disabled.
- Targeted additions: explicit mixed-input diagnosis; an end-to-end organizing route using existing attachments; concrete spatial/time scene-boundary contrasts; input-event-to-saved-scene coverage check. Preserve existing resource tools, writeback and continuity ownership.
- Do not demand separate user confirmation for an already-existing autonomy policy simply to supply the requested read-only flow comparison.

No product files, model calls or user data were changed during this inspection. The proposed method is not a measured model-quality result.

## External methods requested by the user

The user explicitly requested real-world screenwriting books and public GitHub Skills, rather than another restatement of the internal workflow. Research only; implementation remains paused.

Verified public method pages (not full-book reads):

- John Truby, *The Anatomy of Story*: https://truby.com/the-anatomy-of-story/ — author studio page describes premise/plot, theme, character, moral development and ending, with seven key structural steps within a 22-step method. Useful for causal character/event analysis; not a ready-made application resource-extraction contract.
- Blake Snyder, *Save the Cat!*: https://savethecat.com/products/books/save-the-cat-the-last-book-on-screenwriting-youll-ever-need — official page explicitly covers 15 beats, a board of 40 scenes with conflict/emotional change, and script repair. Use as optional macro-structure reference, not mandatory 15-beat/40-scene output for arbitrary pasted fragments.
- StudioBinder, script breakdown preparation: https://www.studiobinder.com/blog/format-script-breakdown/ — identifies characters, locations, key props, stunts, vehicles and sound effects per scene; covers reading the full script, consistent location/character names and scene numbering. Full public step guide also verified at https://www.studiobinder.com/blog/free-script-breakdown-sheet/: read as viewer → check formatting → page eighths → identify elements → breakdown reports → shooting schedule. For this task borrow scene-level resource identification/consistency, not page eighths, shooting schedules or unnecessary full production inventory. This production practice is a closer match for character/prop/location extraction than narrative theory alone. Breakdown assumes a script and does not by itself adapt prose or improve dialogue.

Known book leads not directly verified from publisher pages in this run: Robert McKee's *Story* (author page HTTP 406, HarperCollins page HTTP 403); Linda Seger's *The Art of Adaptation: Turning Fact and Fiction into Film* (Macmillan page HTTP 403). Do not describe those full books as read during this research. Public-page checks establish scope only, not comparative model quality.

### Verified GitHub candidates

1. https://github.com/eternityspring/shuohao-skills — Apache-2.0 (root LICENSE read). Parent read full `skills/novel-outline/SKILL.md`, `novel-characters/SKILL.md`, `novel-art/SKILL.md`, and `novel-script/SKILL.md` via raw GitHub, plus the opening of `novel-characters/examples/渡口.txt` and parsed/inspected the first episode of `novel-script/examples/渡口-script.json` (six episodes). A concrete reference for outline → cast/art → scene/action/dialogue → cross-resource checks. Characters can start from pasted raw text and verify quotes; art accepts outline/raw text/scene list; script normally consumes outline.json and checks cast/location/prop references. Samples demonstrate raw-story-to-structured-script artifacts, not a measured faithful adaptation or a test run.

   Important corrections/limits: `novel-outline` is a real upstream prerequisite in its standard flow, not an omitted step; it requires episode count/duration and genre, and explicit approval of cuts/character merges before detailed episodes. It defaults to short-drama adaptation choices, hook/cliff/reward rules and resource limits. `novel-script` uses heuristic duration (4.5 characters/sec and 2.5 sec/action by default), dialogue-length and action-beat checks; numeric validator success is not real performance-duration or dramatic-quality proof. Some instructions assert limits of AI action generation too broadly. Do not import those defaults, independent C/S/P IDs, images/voice prompts, scene-asset semantics or JSON files into the app as replacements for existing records. Borrow explicit stage deliverables, evidence, reuse and cross-check practices. The validator scripts themselves were not executed or fully audited.

2. https://github.com/gbellonre/psych-short-screenplay — MIT (root LICENSE read). Parent read full `skills/psych-short-screenplay/SKILL.md`. Pipeline: intake → locked sheet → 8–10 beats → scene draft → dialogue rewrite → cut to 70–85% → self-critique; optional shots. Useful concrete scene-turn/subtext/visible-action revision prompts. Narrowly 8–12-minute psychological thriller/horror, 2–4 speakers, 1–3 locations, genre-specific bans, confirmation at each gate unless 'just go', and provisional invented sheet details. Not a general adaptation/extraction skill and not appropriate as an extra mandatory review layer. Fountain format is not the application's body storage contract.

3. Research agent also inspected https://github.com/yingwang/inktofilm (MIT per agent) as a downstream still/video generation workflow, not primary material-to-screenplay processing. Parent did not independently inspect it; defer because video production is outside current scope.

No downloaded code was executed or installed. No external repository was demonstrated to be an implementation of Truby/McKee/Snyder merely because it uses related concepts. The recommendation is a selective method comparison, not installation or copying wholesale. Do not stack all frameworks as mandatory sequential gates.

No private local project context or user business data was copied into this artifact.
