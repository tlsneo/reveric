# Runtime constraints — narrow split-shortcut scope

Planning evidence only; no tests, model/network calls, business DB access, or product changes. `task.py current --source` returned none; this report uses the explicitly supplied task and its new PRD. Parent owns Skill content/release auditing; not repeated here.

## Scope assessment

**No factual blocker found to changing only the existing desktop split request and its existing widget test.** Existing methods can remain unchanged. This conclusion supports prompt routing/preferences, not deterministic splitting or exact generated frames.

## Entry, callers, mobile, test seam

- `lib/desktop/features/storyboard/region.dart:389–393` calls `sceneActions.ask` with the scene resource path and unconditional generic Shot demand. The split button exists only with a scene and callback (`:563–568`). All scenes, including empty ones, receive groups (`:352–356`).
- Caller: `lib/desktop/features/production/region.dart:1044–1049` supplies `sceneActions`; `:181–184` connects `ask: onAsk`. `lib/desktop/widgets/workspace/novel_workspace_panel.dart:668–671` connects that to `onProductionPrompt`. `lib/desktop/pages/novel_editor.dart:4548–4559` opens chat and drafts text with **autoSend:false** for requests without files. The split request supplies no files.
- Callback contract: `lib/desktop/features/production/edit_session.dart:30–38` has `void Function(String prompt)? ask` and required `openDirector`. A test can inject a prompt collector plus async no-op director callback; director signature is `Future<void> Function(String, {ScreenplayDirectorCanvas? canvas})` (`lib/shared/widgets/screenplay/director_shell.dart:14–15`).
- Existing target: `test/desktop/features/storyboard/region_test.dart:41–151` already constructs scenes, in-memory services, providers, localization/theme, and the widget. At `:141` it supplies **no sceneActions**, so currently does not exercise split or assert prompt wording. Add callback injection/tap assertions here; no new abstraction needed. Existing refresh/deletion assertions begin `:152`.
- No corresponding mobile split shortcut found in mobile source search. Mobile explicitly declines storyboard-page navigation (`lib/mobile/pages/novel_chat_page.dart:2618–2628`). Mobile can use installed shared Skills (`:753–755`; `lib/shared/providers/agent_skill_providers.dart:23–45`), but a desktop-request-only edit does **not** alter mobile chat requests. This does not require adding mobile UI.

## Catalog and exposed capabilities

The requested `lib/shared/models/video/model_capabilities.dart` does not exist. Actual declaration: `lib/shared/models/video/config.dart:109–166`.

- Catalog `MiniMax-H3`, aliases `minimax-h3`, `hailuo-3`: integer durations **4–15 seconds** (`catalog.dart:526–531`). Native MiniMax channel uses this catalog (`channels.dart:1689–1693`).
- AtlasCloud `minimax/h3` and its text/image/reference routes: **4–15 seconds** (`channels.dart:1363–1436`). OpenRouter `minimax/hailuo-3`: **5–15 seconds** (`:1870–1880`).
- Separate catalog `hailuo-3-max`: **5–15 seconds** (`catalog.dart:342–350`); OpenRouter channel `minimax/hailuo-3-max` (`channels.dart:1882–1887`). Thus five seconds is represented on these channels; “H3” alone is not a catalog key. Match actual configured model/channel, not a universal spelling or duration range.
- Provider tool returns configured models through `providerModelResource` (`lib/shared/services/ai/providers_run_command_handler.dart:142–145`). Its video serializer exposes durations, modes and reference constraints (`provider_resources.dart:127–198`), **not output fps, frame count or frame-step rules**. `references.video.min_frame_rate/max_frame_rate` are input limits; H3’s 23.976–60 range is not output fps (`catalog.dart:547–559`). Unknown capability mappings remain explicit null/unknown (`provider_resources.dart:69–82`). Availability is local, not remote verification.

## Timing boundary and verification limits

- Saved `duration_ms` is a clip plan (`lib/shared/services/storyboard/service.dart:222`). Generation builds integer seconds (`generate_orchestrator.dart:30–36`) and rejects non-whole-second plans before submit (`:235–241`). Known external frame-snapped fractional durations may therefore be unsendable without out-of-scope runtime changes.
- `VideoRequest` has integer `durationSeconds`, no output fps/count/step (`lib/shared/models/video/request.dart:35–60,88–100`). MiniMax sends that as `duration` (`lib/shared/services/ai/video/minimax.dart:24–33`). Reference fps is probed input metadata (`video/task_service.dart:608–619`), not control over output frames.
- Safe narrow request: approximately five seconds subject to actual model duration support; fps calibration only when genuinely known, otherwise explicitly uncalibrated. Do not promise computed exact output frames. External Hybrid H3 24fps/17k+5-like snapping is **not established here as an app default or universal rule**.
- Existing contract tests: `test/shared/services/ai/providers_run_command_handler_test.dart:602–610` checks video capability output; `test/shared/models/video/channels_test.dart:155–167` checks native/OpenRouter H3 identity; `test/shared/models/video/capabilities_test.dart:187–198` records native duration/input-fps bounds. `test/shared/services/bundled_official_skills_test.dart:60–75` verifies reference bodies load intact, not H3 execution quality.

No tests executed. Exact real provider output fps/frame rules remain unknown; prompt/widget tests cannot establish them. No Skill changes or version exception are needed for the narrowed request-only scope.
