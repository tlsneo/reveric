# Independent「AI 拆分镜」Skill: bounded extraction research

Research only; no implementation or tests. `task.py current --source` returned none; the caller supplied this task directory. Planning artifacts were not modified. Fully read the production Skill and its 15 references; excluded `docs/`, user databases/logs and unrelated WIP.

## Recommendation and ownership

Use a new **official** Skill, exact name `AI 拆分镜`, rooted at `assets/official_skills/storyboard-splitting/`. It must own scene-to-storyboard method **and video-prompt authoring**, not delegate its method to production. Keep `剧本制片` as the separate visual-asset/previsualization/generation/inspection entry. This uses existing optional professional-method architecture (`.agents/rules/agent-skills.md:18–36`); no service or schema is needed.

Below, **P** = `assets/official_skills/screenplay-production`, **N** = `assets/official_skills/storyboard-splitting`.

- Extract P/SKILL.md:41–45 and P/references/production.md:11–36,67–73 into N/references/splitting.md. Preserve understanding → shot/performance budget → independent grouping → format → review → authorized save/readback; sequential versus genuine overlap, estimation evidence, unique irreversible-action ownership, substantive soft ~5s and longer justified clips. Move episode-total checking too, without copying query contracts.
- Split P/references/storyboard.md:3–25,52–67 into N/references/storyboard.md; retain occupancy/director-previsualization method at P:27–50. New splitting must not require producing images or director documents.
- Move these **nine existing reference files**, same basenames, from P/references/ to N/references/: `video-prompts.md`, `minimax-h3-prompts.md`, `seedance-prompts.md`, `kling-prompts.md`, `veo-prompts.md`, `wan-prompts.md`, `model-capabilities.md`, `shot-recipes.md`, `scene-example.md`. Formats/capability adaptation are shared authoring support, not exclusively splitting; moving their single source avoids duplicates and lets the new Skill work with production disabled. Keep the complete worked case, including illustrative asset preparation and result checklist, explicitly non-executing.
- Retain production’s `character-design.md`, `image-references.md`, `image-recipes.md`, `troubleshooting.md`, production dependency ordering/concurrent-versus-serial generation and real-result inspection (P/references/production.md:38–65,74–80).
- Resolve the existing unselected-model **generic** default at video-prompts.md:26: new Skill must explicitly default to Chinese H3 drafts, retaining selected non-H3 formats. Preserve H3 real-input modes, three/six fields and fixed syntax (minimax-h3-prompts.md:3,14–21,44–67); no provider auto-selection or invented refs.

## Exact integration/link changes

Besides the moves/split above, edit:

1. N/SKILL.md (new), including distinct triggers and full-method routing, own `reference-list/get` name, optional production handoff only for asset preparation/generation.
2. P/SKILL.md and P/references/production.md: remove competing splitting instructions/triggers; route authoring to the new name while retaining production work.
3. P/references/image-references.md:77: replace moved model-capability relative link with named-Skill/reference guidance. Fix moved files’ links to retained image recipes/references/troubleshooting similarly; local authoring links remain relative. No `../other-skill` links: loader rejects references outside the Skill root (`lib/shared/services/bundled_official_skills.dart:301–319`), and tests require installed-local Markdown targets (`test/shared/services/bundled_official_skills_test.dart:118–143`). Register each physical file under **one** owner only; no wrappers containing duplicate methods.
4. `assets/official_skills/screenplay-writing/SKILL.md:44`: distinguish splitting/video authoring from production; writing remains screenplay creation, not camera planning.
5. `assets/bundled_skills/screenplay-tools/SKILL.md:9` and `references/clips.md:45`: update creative-format owner names only. Keep all paths, JSON, ref/input rules, generation contracts in bundled tools; do not transplant them into the new method.
6. `lib/desktop/features/storyboard/region.dart:393`: load the new Skill, preserving request safeguards at 394–401. The action only prefills chat, `autoSend:false` (`lib/desktop/pages/novel_editor.dart:4548–4559`). Sole productionSplit caller is desktop; no mobile split entry found. Shared Skill still reaches all supported platforms.
7. `lib/shared/services/bundled_official_skills.dart:200–225`: new identity/ordered entry, redistributed references, changed Skill metadata; `pubspec.yaml:219–225`: add new nested main/reference assets.

Generic summary routing already works (`lib/shared/services/ai/prompts/prompt_fragments.dart:186–211`); Run maps only bundled operation owners (`bundled_control_skills.dart:64–77`). No prompt-engine/command-map edits. Align the old ownership example in `.agents/rules/agent-skills.md:34` when implementing.

## Installation, versions, validation

Startup installs new catalog identities enabled, independently of whether old production is disabled/deleted; same-name local collisions are preserved, handled/deleted identities are not reinstalled (`official_skill_sync.dart:108–160`; `novel_agent_skill_providers.dart:458–483`). Existing official snapshots upgrade only on a larger version; disabled/name/order/ID survive, local conversions do not upgrade. Customized old production may keep old triggers; do not rewrite it automatically. Disabled/newly removed splitter is unavailable at runtime, not secretly loaded from bundled assets (`chat_turn_runner.dart:736–803`). Explain unavailable named skills rather than bypass user choice.

`git tag --list` is empty; repository is not shallow. Release status remains unknown. **Fresh approval needed** for proposed new v1, production v4→v5 and writing v3→v4; previous bump approval is not reusable. Update hashes/dates for both changed existing official Skills and new Skill; path changes affect hashes. Do not touch user/Debug/Release databases.

Required test edits: `test/desktop/features/storyboard/region_test.dart:198–223`; `test/shared/services/bundled_official_skills_test.dart:42–49,251–941` (retarget real-method/format/case assertions, preserve budgeting/ownership checks); add boundary assertions in `test/shared/services/bundled_control_skills_test.dart`; add packaged old-production→new-splitter installation/upgrade coverage in `test/shared/providers/official_skill_sync_providers_test.dart`. Reuse existing deletion/disabled/customization scenarios there at 262–360 and `test/shared/services/official_skill_sync_test.dart`. Later run these serially with `fvm flutter test`, plus narrow analysis/format, packaging/link/hash/drift guards and request-only UI acceptance. Static tests cannot prove Agent creative quality.

More than eight files are affected, primarily relocation/link maintenance. No tests, paid calls or runtime replay were performed; no tool descriptions/schema, caches, orchestration or business-data rewrites are proposed.
