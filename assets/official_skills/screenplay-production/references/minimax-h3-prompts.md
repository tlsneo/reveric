# MiniMax H3 提示词

适用于 `MiniMax-H3`。内容原则见 [视频提示词](video-prompts.md) 与 [分镜指南](storyboard.md)；本附件只规定 H3 的结构与标记，取代通用 Shot 格式。正文默认使用中文：画面、动作、运镜、声音、主体定义、摘要、参考保留解释与衔接均写成可直接阅读和编辑的中文。字段名、镜头标记和固定语法保持原样；对白、歌词和画面中可见的文字逐字保留原文，不为迁就正文语言而翻译。

## 来源与中文适配边界

- [官方云 API](https://platform.minimaxi.com/docs/api-reference/video-generation-v2-create) 的请求示例直接使用中文，说明中文是合法输入。
- [官方改写 Skill](https://github.com/MiniMax-AI/MiniMax-H3/tree/main/skills/h3-prompt-writing) 要求英文正文；三段／六段结构及标记参照官方[基础指南](https://huggingface.co/MiniMaxAI/MiniMax-H3/blob/main/docs/VIDEO_PROMPT_WRITING_GUIDE_base_en.md)与[全参考指南](https://huggingface.co/MiniMaxAI/MiniMax-H3/blob/main/docs/VIDEO_PROMPT_WRITING_GUIDE_ref_en.md)。

本附件是保留 H3 结构与固定语法的中文适配，不是官方英文改写要求的逐条复刻。中文输入合法不代表中文与英文的成片质量等价，效果仍需实际生成核验。

## 先判断输入模式

| 实际输入 | 模式 | 结构 |
|---|---|---|
| 无参考 | T2VA | 三个核心字段 |
| 只有首帧 | I2VA | 首行对齐句 + 三个核心字段 |
| 首帧 + 尾帧 | FL2VA | 首行对齐句 + 三个核心字段 |
| 人物、场景、动作、音频等参考 | Ref2VA | 六个字段 |

模式按实际绑定的输入判断，不按计划判断。

## 帧模式：对齐句 + 三个核心字段

对齐句是提示词第一行，后接一个空行。它说明输入图片与视频时刻的对应关系，保留固定英文句式；句中图片位置放对应输入的真实 ref 标签：

- I2VA：`For the target video, at 0.00 seconds into the target video, <ref input_id="…" label="首帧" /> (from [Shot 1]) is fully referenced.`
- FL2VA：`How the reference pictures align with the target video — <ref input_id="…" label="首帧" /> (from Shot 1) aligns with the 0.00-second mark of the target video; <ref input_id="…" label="尾帧" /> (from Shot N) aligns with the S.SS-second mark of the target video.`

`N` 是最后一个镜头的序号，`S.SS` 是生成时长，固定两位小数（8 秒写 `8.00`）。改时长或镜头数后同步改这一行。

```text
integrated_multimodal_description: [Shot 1] ...

overall_soundscape: ...

non_diegetic_music: ...
```

- `integrated_multimodal_description`：按时间线用中文写画面、动作、镜头、说话人、台词和同步发生的剧内声音。`[Shot 1]` 开头先写整体风格（如“真人实拍，左侧暖光，木桌保留自然纹理”）和起始构图。I2VA 从首帧的主体、构图和场景出发往后写，不重新设计图中外观；FL2VA 写两端之间可见的过程，优先单镜头，最后一个镜头结束时到达尾帧。
- `overall_soundscape`：用中文写 1–4 句环境声、动作声和非语言人声（脚步、呼吸、关门），不重复台词。只有要求全程无声时写 `N/A`。
- `non_diegetic_music`：用中文写 1–3 句配器、速度与强弱变化，不写情绪词。剧中人物听得见的音乐写进第一个字段。没有配乐写 `N/A`。

## Ref2VA：六个字段

依次写 `subject_definitions`、`summary`、`retention_analysis`、`detailed_description`、`overall_soundscape`、`non_diegetic_music`。

- `subject_definitions`：每行定义一个要追踪的内容，用 `<Subject N>` 标记，并用中文写明来源参考、用途和主要特征，如 `<Subject 1> 是 <ref input_id="…" label="人物参考" /> 中的年轻女子，黑发齐肩，穿灰色羊毛外套；该图用于身份与服装参考。` 参考图本身作为首帧或构图锚点时，单独写一行说明它对应哪个镜头。
- `summary`：用中文写一段摘要，用方括号前缀写任务类型，如 `[reference generation]`、`[keyframe completion + reference generation]`，再概括目标视频和各参考的作用。不在这里引入新标签。
- `retention_analysis`：每个标签一行，写出现在哪些镜头，以及 `fully_preserved`、`partially_preserved`、`attribute_transfer` 或 `weak_reference`；音频用 `fully_copy`、`partially_copy`、`reference` 或 `weak_reference`。标记不翻译，随后用中文解释具体保留、借用或不继承的内容。
- `detailed_description`：先用中文写一两句整体风格，再逐镜写。每个镜头写清当前构图、主体外观与位置、环境与光线、动作与状态变化、运镜和声音，以及参考内容在哪里起作用。篇幅以完整表达动作、逐字对白和连续状态为准，不设词数或字数配额。
- 后两个声音字段同帧模式。

## 镜头、运镜与切点

- `[Shot 1]` 不写时间；之后每个镜头写 `[Shot N] At MM:SS.mmm, the camera cuts to ...`，切点严格递增，且落在生成时长内。英文前缀表示在该时刻切镜，后面直接接中文景别、构图与动作描述。
- 切镜要带来新的主体、空间、状态、视角或时间信息；只需要稍微改变景别或角度时，用运镜代替切镜。
- 运镜用中文写成句中的自然动作：类型（推近、拉远、向左摇、向右横移、向上仰、机位下降、变焦推近、环绕、跟拍、固定、轻微抖动、主观视角）加上需要时的幅度与速度，如“镜头以小幅度缓慢推近桌沿的钥匙”。区分机位移动与镜头变焦，不用英文术语串代替实际运动过程。

## 说话人与台词

- 说话、唱歌或画外发声的人用稳定编号 `(S1)`、`(S2)`，跨镜头不变；同时开口用 `(S1,S2)`。不发声的人不编号。
- 说话人第一次出现时，在 `<d>` 外用中文写清身份、年龄段、性别、是否在画内、音色、语速或口音。`<d>` 内只放语言标签和原话，逐字保留标点：
  `画内的三十多岁男子，声音低沉疲惫 (S2)，放慢语速问：<d>[Chinese] 你真的要走？</d>`
- 画外音用固定说法，并紧跟口型说明：`(S1) says in an off-screen voiceover: <d>[Chinese] ……</d> while his lips remain completely closed.` 这表示声音来自画外，人物嘴唇完全闭合；身份、音色等描述仍写中文，口型说明按实际人物使用对应代词。
- 同一句话跨切点时，在前后两处用 `<scenetrans>` 并用中文写明声音延续；台词被视频结尾截断时用 `<cutoff>`。
- 画面中真实可见的招牌、字条用英文双引号原样引用，不翻译，如 `门口招牌写着 "营业中"`。

## 示例

以下是假设剧情与参考条件下的格式示范，不代表实际已绑定素材、已配置模型或已生成视频。示例中的 ref 占位符不能直接提交；实际写作须使用已读取的真实人物、原文、状态及应用返回的完整 ref 标签，不把示例设定补成作品事实。

### 三字段：8 秒，只有首帧（I2VA）

假设首帧已呈现女子与男子隔桌相坐，原文为女子把钥匙推到桌沿，男子问“你真的要走？”，随后女子松手：

```text
For the target video, at 0.00 seconds into the target video, <ref input_id="…" label="桌前首帧" /> (from [Shot 1]) is fully referenced.

integrated_multimodal_description: [Shot 1] 真人实拍，木桌保留自然纹理；中景严格沿用首帧中女子与男子隔桌相坐的构图、外观与站位，暖色台灯从画面左侧照入。女子用右手食指把黄铜钥匙沿桌面推到男子面前的桌沿内侧，停住时指尖仍压着钥匙。男子看着钥匙，没有伸手，随后抬眼看向女子。[Shot 2] At 00:04.000, the camera cuts to 男子近景，保持原有轴线与面部左侧暖光。画内的三十多岁男子，声音低沉疲惫 (S1)，放慢语速问：<d>[Chinese] 你真的要走？</d> 说完仍看着女子，双手不动。[Shot 3] At 00:06.500, the camera cuts to 桌沿钥匙的俯拍特写，光线方向不变。女子右手食指松开，向画面左侧退出；钥匙留在原处，无人拿起，作为本段结束状态。

overall_soundscape: 室内底声安静而持续。钥匙擦过木桌发出轻微摩擦声，停下时有一声轻响；对白结束后只保留室内底声。

non_diegetic_music: N/A
```

### 六字段：8 秒，人物与场景参考（Ref2VA）

沿用上述假设剧情，但实际输入改为两张人物参考与一张房间参考；没有绑定首尾帧，不把身份参考当作首帧约束：

```text
subject_definitions: <Subject 1> 是 <ref input_id="…" label="女子参考" /> 中的年轻女子，黑发齐肩，穿灰色羊毛外套；参考用于面容、发型与服装，不继承图片背景。
<Subject 2> 是 <ref input_id="…" label="男子参考" /> 中的三十多岁男子，短黑发，穿深色衬衫；参考用于面容、发型与服装，不继承图片姿势。
<Subject 3> 是 <ref input_id="…" label="房间参考" /> 中带木桌与左侧台灯的房间；参考用于空间布局、材质与光源，不作为首帧。

summary: [reference generation] 在 <Subject 3> 的房间内，<Subject 1> 将钥匙推到 <Subject 2> 面前，后者没有接，只低声发问，随后女子松开手。人物参考保持身份与服装，房间参考保持桌面布局及左侧暖光；不借用人物图的背景或姿势。

retention_analysis: <Subject 1> — [Shot 1]、[Shot 3]，fully_preserved：保持面容、齐肩黑发与灰色外套；手部特写延续同一只右手和袖口。
<Subject 2> — [Shot 1]、[Shot 2]，fully_preserved：保持面容、短黑发和深色衬衫；从看钥匙到抬眼的状态连续。
<Subject 3> — [Shot 1]、[Shot 2]、[Shot 3]，fully_preserved：按定义的参考用途保持空间布局、木桌材质与左侧暖光；景别裁切不改变空间与光源，不要求整间房始终入镜。

detailed_description: 真人实拍，左侧暖色台灯照亮木桌，背景保持低照度，木纹与衣料质感自然。[Shot 1] 中景，<Subject 1> 坐在画面左侧，<Subject 2> 坐在右侧，隔桌相对，双手均在各自一侧桌沿附近。镜头固定，沿用 <Subject 3> 的桌面布局与光源。<Subject 1> 用右手食指将黄铜钥匙推向男子，在他面前的桌沿内侧停住，指尖仍压着钥匙；<Subject 2> 没有伸手，先看钥匙再抬眼看向女子。[Shot 2] At 00:04.000, the camera cuts to <Subject 2> 的近景，沿用轴线与面部左侧暖光，视线朝画面左侧的女子。画内的 <Subject 2> 是三十多岁男子，声音低沉疲惫 (S1)，放慢语速问：<d>[Chinese] 你真的要走？</d> 说完保持视线，双手位置不变。[Shot 3] At 00:06.500, the camera cuts to 桌沿钥匙的俯拍特写，<Subject 1> 的右手食指仍从画面左侧伸入并压着钥匙。手指松开并向左退出，袖口沿用人物参考的灰色外套；钥匙留在原处，无人拿起，结束时只见钥匙与桌面。

overall_soundscape: 持续的安静室内底声贯穿切镜。钥匙滑动时有轻微的金属擦木声，停止时轻响一次；不增加脚步、开门声或额外人声。

non_diegetic_music: 稀疏的钢琴单音以缓慢、均匀的间隔进入，男子开口时降低音量，最后一个镜头逐渐减弱至停止。
```
