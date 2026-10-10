---
type: resource-card
domain: ai-programming-product
status: active
owner: mixed
source: mixed
created: 2026-07-23
updated: 2026-07-23
---

# ElevenLabs：游戏宣传 BGM 实操与复用清单

## 一句话定位

ElevenLabs 当前可用于“快速生成游戏宣传片 BGM 候选 + 在 Studio 内完成轻量混音和 MP4 导出”。它能缩短找方向的时间，但 AI 音乐不是免试听的最终成片；上线前必须由项目负责人试听、挑选并确认版权与项目适配度。

## 本次实际验证

对象：`Peak Evolution` 的 47 秒游戏宣传视频。

| 项目 | 本次结果 | 结论 |
| --- | --- | --- |
| Music v2 生成 | 请求 3 个、实际得到 2 个约 47 秒候选；合计消耗 1,410 credits | 可作为候选生成工具；不要把数量选择器当成必然交付数量或固定价格 |
| Studio 时间线 | 将一条候选铺到 0:00–0:47；保留原视频声音，BGM 设为 60% | 简单叠轨和基础混音可用 |
| 视频导出 | 曾成功导出 MP4；免费计划导出带水印 | 基础 MP4 导出已验证；实际导出条件随套餐和当时平台状态变化 |
| 纯 BGM MP3 | 已看到音频单文件导出入口，但本次触发“Too many exports”限流，未成功交付纯音频 | **不能写成已验证成功**；下次需等待限流解除后单独验证 |

主观音质与镜头节奏仍应人工试听。本次并未建立“每次都可直接上线”的音乐质量标准。

## 可直接复用的提示词

```text
Instrumental dark epic fantasy game trailer music, about 47 seconds. Start with ominous low strings and distant choir, then build with taiko drums, brass hits, and rising orchestral tension. Powerful fiery climax from 0:35 to 0:43, then a clean final hit and short fade for the logo reveal. No vocals, no lyrics, no singing. Cinematic, polished, dramatic, high-energy, around 105 BPM.
```

替换时优先只改四类信息：

1. 总时长；
2. 情绪与题材，例如 `dark epic fantasy`；
3. 高潮时间段；
4. 片尾收束方式，例如 logo hit、停顿或 fade。

不要只写“史诗、燃”。必须写清楚开场、推进、高潮、收尾和是否允许人声。

## 下次操作顺序

### 1. 生成候选

1. 在 ElevenLabs Studio 导入已剪好的宣传片，先确认总时长和 Logo 出现时间。
2. 打开 **Music**，粘贴提示词；先生成 2–3 个候选。
3. 逐条试听 0 秒、高潮点、Logo 点和片尾；选中的标准是节奏贴画面，而不是单独听起来最热闹。
4. 把选中的音乐放到时间线，从 0 秒对齐；默认保留视频原声，再从 BGM 约 60% 开始试听调整。

### 2. 导出视频

1. 导出前播放检查：开头、高潮、Logo、最后一帧。
2. 选择 Video/MP4 导出。
3. 只在导出的文件中确认音画同步后，才替换项目交付版。

### 3. 单独导出纯 BGM（待再次验证）

这是本次看到的界面流程，**不是已成功验收的结果**：

1. 先记住当前混音：视频原声是否静音、BGM 音量是多少。
2. 临时静音视频原声，把 BGM 调到 100%。
3. 选择 Export → Audio → Single file → MP3。
4. 下载后立即恢复视频原声和 BGM 混音设置。

若出现“Too many exports”之类提示，不要连续点击重试；等待一段时间后再导出。下次应把“纯 BGM MP3 成功下载、可播放、时长正确”作为独立验收项。

## 账号与成本边界（时间敏感）

- 2026-07-23 的账户状态：Creator 订阅已主动取消，页面显示计划将在 **2026-08-23** 结束；当时自动充值为关闭。
- 每次重新使用前，先在 Subscription 核验订阅状态、自动充值状态和余额；不要依赖本条历史记录。
- 本次两条约 47 秒候选共消耗 1,410 credits，只是一次实测，不代表固定单价或未来成本。
- 账户、套餐、额度、导出限制和产品能力都可能调整，以 ElevenLabs 当时页面和官方说明为准。

## 能向老板承诺什么，不能承诺什么

| 分类 | 当前表述 |
| --- | --- |
| 已验证可用 | Studio 中导入视频、叠加 BGM、做基础音量混合、导出 MP4。 |
| 适合试用但必须人工把关 | Music v2 生成宣传片 BGM 候选；最终成片仍需要试听筛选。 |
| 尚未纳入生产承诺 | 纯 BGM 音频导出、中文配音/音色克隆、音效、自动字幕、自动配音、多语言配音。均需要独立 PoC。 |
| 不建议承诺 | Image & Video（官方标为 beta）与 Studio Agent（界面标为 Alpha）；不作为当前生产链依赖。 |

可用于汇报的结论：

> ElevenLabs 可作为“声音资产生产 + 轻量宣传片音频整合”工具。基础视频时间线、BGM 插入和 MP4 导出已完成一次实操验证；AI 音乐定位为高效候选生成，最终上线仍保留人工试听筛选。自动配音、图像视频、智能体等能力先做小范围 PoC，不纳入现阶段生产承诺。

## 下一轮 PoC 清单

- [ ] 用 30 秒中文脚本验证 TTS：发音、情绪、导出格式、可商用边界。
- [ ] 用 10 条 Roblox UI / 战斗音效验证音效生成、导出和导入 Roblox 的实际效果。
- [ ] 用同一支宣传片生成 3 个 BGM 方向，记录人工评分与最终采用率。
- [ ] 重新验证纯 BGM MP3 导出，并把文件时长、可播放性和水印情况记录下来。

## 官方入口与来源

- [ElevenLabs Music](https://elevenlabs.io/music)
- [Music 文档](https://elevenlabs.io/docs/overview/capabilities/music)
- [ElevenLabs Studio](https://elevenlabs.io/studio)
- [Studio 产品文档](https://elevenlabs.io/docs/eleven-creative/products/studio)
- [Music v2 发布说明](https://elevenlabs.io/blog/introducing-music-v2)

## 相关链接

- [[AI 工具卡模板]]
- [[AI_Programming_Product/index|AI 编程与产品 Wiki]]
- [[30_MOC 内容地图/AI 编程与产品 MOC|AI 编程与产品 MOC]]
