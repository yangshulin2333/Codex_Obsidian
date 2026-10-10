# weapon_series_05_amber_blue_sword 三视图 Prompt

用途：给 Meshy / 3D AI 做 Roblox 低模武器参考图。

## 生成目标

基于用户提供的黑金橙蓝幻想剑参考图，生成同系列改款三视图。

本次重点不是完全复制原剑，而是在保持家族感的前提下做小幅改款：

1. 保留黑蓝金属外框、琥珀橙发光内芯、冷蓝边缘高光。
2. 保留长竖向刀身、弯月形护手、环形尾部、尖锐下端。
3. 调整护手尖角、中央脊线、尾部外轮廓和侧面厚度。
4. 颜色从原本偏黑橙，改为更深的蓝黑金属 + 更暖的琥珀金 + 少量青蓝边缘。
5. 三个视角必须是同一把武器，不能生成三把相似但不同的武器。

## 核心 Prompt

```text
Use case: stylized-concept
Asset type: Roblox fantasy weapon orthographic reference sheet for 3D AI model generation.
Input images: the three attached screenshots are reference images of the original sword from front, side, and back. Use them only as style and construction references, not as a scene background.
Primary request: Generate one redesigned same-series weapon three-view sheet. The result must show the exact same redesigned sword in three orthographic views: front view, 90-degree side view, and back view, arranged left to right on one canvas.
Subject: a Roblox-stylized fantasy sword/dagger in the same family as the reference: long vertical blade body, dark gunmetal and black metal frame, molten amber-orange inner panels, icy silver-blue edge highlights, small glowing central gem, curved horn-like crossguard, ring-shaped pommel, sharp triangular lower blade/pommel point. Make it a variant: keep the same series identity, but slightly change the guard tips, central ridge, pommel outline, side thickness, and color distribution. Use a darker blue-black metal base, warmer amber-gold core accents, and a few cool cyan edge highlights.
Consistency requirements: all three views must be the same weapon, same height, same proportions, same guard and pommel positions, same decorative elements wrapping consistently around the form. The side view must be a thin profile view of the same object, not a different weapon. The back view should match the front silhouette but show simpler rear metal panels and the same ring pommel.
Composition: clean orthographic model sheet, centered object views, equal scale, vertical alignment baseline, generous padding around each view. No perspective camera angle, no floor plane, no environment, no Roblox Studio UI, no axes, no grid, no labels, no text.
Style: polished stylized 3D game concept art, crisp readable silhouette, hard-surface fantasy metal, hand-painted texture hints, clear bevels and thickness, suitable for 3D AI reconstruction.
Background: plain matte very light gray or white background, uniform lighting, no cast shadows, no reflections, no watermark.
```

## 反向约束

```text
no character holding it, no hand, no scene props, no floor plane, no perspective view, no labels, no text, no watermark, no Roblox Studio UI, no axes, no grid, no random floating pieces, no three different weapons, no mismatched proportions, no dense filigree, no high-poly sculpture, no skull decoration, no tiny unreadable spikes
```

## 本次输出规格

1. 合图：`1536x1024`。
2. 独立视角图：每张 `512x1024`。
3. 视角顺序：`front / side / back`。
4. 背景：浅灰白干净背景。
5. 用途：先给 3D AI 生成模型，再进入 Blender / Roblox 导入流程。
