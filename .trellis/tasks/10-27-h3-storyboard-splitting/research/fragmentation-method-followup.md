# 第四轮方法对照：充实的短片段，最终输出 H3

## 用户最终决定

用户已明确批准实施：改善分镜本身，输出按MiniMax H3；独立生成片段因本地显卡能力优先约5秒，但不是上限，内容放不下可超；五秒也不能空洞，需分析对应对白、动作与反应是否真能在该窗口完成。不实施通用缓存／会话刷新，不操作已有分镜或生成媒体。

现有桌面请求已表达短片段优先、逐字对白／动作／连续性更重要、未定模型时暂定、只写草稿。保持入口不变，修改真正拥有方法的Skill与完整案例；五文件见design.md。

## 已读官方依据

当前公开MiniMax H3 skills目录为1份h3-prompt-writing和8份题材制作Skill。已读取其主文件；重点完整读取h3的base-en/ref-en、3d-animation的shot-table、storyboard、model-selection、fallback、qc附件。其他题材经独立gpt-6.1-sol研究核对，主会话复核minimalist产品编排、music连续性及brand节拍关键原文。

- https://github.com/MiniMax-AI/MiniMax-H3/tree/main/skills/h3-prompt-writing ：镜头描述不能缩成剧情梗概；保持格式、切点与实际输入模式。官方全参考例子将人物对白／反应放在同一prompt的多个Shot中。
- https://github.com/MiniMax-AI/MiniMax-H3/blob/main/skills/minimalist-product-ad-generator/SKILL.md ：编排决定镜头顺序与动作，参考图不等于连续视频段；多个节拍可在一次H3生成内。但广告镜头数、文案和美学不可复制到短剧。
- https://github.com/MiniMax-AI/MiniMax-H3/tree/main/skills/3d-animation-short-generator ：镜头计划和连续性自检值得参考；Pixar、逐秒五要素、固定钩子、每行独立视频、Hub确认卡不适用于本任务。

## 第三方已核验方法

### ZenStory：动作归属与表演时间预算

https://github.com/zenstory-ai/drama-skills （研究固定于fdb7b7c58017e3eae64eca382c2a85ede368dab0）

独立研究完整阅读short-drama-storyboard和short-drama-video-prompts及关键附件；主会话直接复核shot-craft、delivery-profile、performance-action-timing与storyboard主文件。

- `skills/short-drama-storyboard/references/shot-craft.md:39–63`：不可逆动作明确前态、发生镜头、后态，其余镜头观察或承接，不重新取出／递交同一物件。这比抽象“不要重复”可核对。
- 同文件`:232–248`及`short-drama-video-prompts/references/performance-action-timing.md:161–191`：真实发声窗口优先，无实测时用受语气影响的估计；顺序发生累加，真正同步部分重叠，必要反应与停顿只计一次。
- `short-drama-video-prompts/references/delivery-profile.md:92–111`：生成容器可有多个镜头，动作阶段本身不自动成为新的切镜。
- 不采纳其一句台词一镜、目标平均镜长、固定反应窗口、每切关键帧或英文强制。4.1字／秒是其小样本观察，不是本项目真值，不移植为门禁。
- MIT；本轮只归纳并独立改写方法，不复制大段原文或实现。

### shuohao：片段／切镜分层与原文事项覆盖

https://github.com/eternityspring/shuohao-skills/tree/main/skills/novel-storyboard

主会话完整读取novel-storyboard主文及storyboard-pass、shot-writing、h3-prompt、schema、frame；读取novel-staging主文与staging-pass；检查实际storyboard脚本的节拍展开与质量门、novel-script的计秒实现，并解析原创渡口JSON例子。

- `segment`对应一次生成，`cut`对应内部镜头；事项认领记录先后和唯一归属。实际案例为10段、34切、119秒，各段8–15秒，说明34个镜头不是34次生成。
- 借片段／镜头分层、原文事项归属和切点／总长一致性；不引入其JSON／Node／18门／报告工具链。
- 不采纳文案建议的9–15秒段、2–5秒切镜硬限制或4.5字／秒＋每动作2.5秒的固定估算。
- 其H3模板主要为多图时间锚定三字段，中文模式翻译字段，与本项目保留原字段及真实Ref2VA六字段目标不同；不移植协议模板、不承诺参考图能强制多个精确关键帧。
- Apache-2.0；本轮独立改写方法，不复制实现。

### 其他候选为何不作为主方案

- https://github.com/liangdabiao/Seedance2-Storyboard-Generator ：独立研究读主文、手册与实际样例；固定13–15秒、2–5秒镜头、30字切分等偏模板化，不适合作为当前软五秒自然表演方法；未核实可再分发许可，不复制文本。
- https://github.com/yanshangcha01/libtv-shortdrama-storyboard ：主会话读主文、analyzer、storyboard_template、node_prompts和模板案例；每镜一个视频节点、固定爽剧四幕与按类型配秒数，无法解决当前短片段内多镜头编排与真实表演预算，不导入CLI或固定美学。

## 本轮落点

现有production第2步在镜头设计前分配片段，第3步设计镜头，第4步再选择边界；重排为事项／戏剧变化→镜头与完整表演预算→约5秒优先的生成分组。主文只引用这条工作链。

整场案例沿用原创“车站失物处”的原文、人物与资产设定，不将用户剧本或第三方样例写进产品。展示至少一段接近5秒且有实际信息／动作负载的片段，以及确因原话／动作需要而超过5秒的片段；不强制具体条目数或镜头数，不让延长片段变成新的默认。逐段给简明预算与边界理由，H3正文只保留实际视听内容。

测试可以验证资源、契约、格式、范例覆盖与时间自洽，不能证明真实Agent理解或视频质量；本轮不通过fake回复、文本contains或版本升级宣称真实分镜效果已实测。所有必要验证完成后自动限定范围提交，不推送。
