# cracked_stone_halberd_variant 三视图生成记录

## 用途

用于 3D AI 模型生成的武器三视图参考图。本次只生成概念参考图片，不是 FBX / GLB 打包任务。

## 设计锁定

- 类型：Roblox 低模风格幻想长柄战斧 / halberd。
- 主轮廓：长直深色金属柄，顶部不对称石质斧刃，一侧宽斧面，另一侧横向尖刺，中间带弯月形内钩。
- 材质：灰黑裂纹石板、深枪灰金属边、少量暗铜黑色箍环。
- 改款点：整体轮廓比参考图更规整；弯月环更宽；尖刺更清晰；石面裂纹加入轻微冷蓝灰高光；长柄和尾锥更干净。
- 一致性要求：正面、侧面、背面必须是同一把武器，保持相同的总高度、头部尺寸、斧刃位置、弯月环位置、长柄长度和底部锥形尾坠。

## 核心提示词

```text
Using the three visible reference screenshots as the design family, create a high-quality concept-art reference sheet for ONE redesigned Roblox fantasy poleaxe / halberd weapon.

Output: one clean three-view sheet with exactly three separate vertical panels on a plain light gray background: FRONT orthographic view, 90-DEGREE SIDE orthographic view, BACK orthographic view. The same weapon must appear in all three panels with identical proportions, silhouette, handle length, head size, blade positions, spikes, shaft, pommel, and materials. No labels, no text, no numbers, no arrows, no UI, no chart, no poster design, no hands, no character, no watermark.

Weapon design lock: a tall long-handled stone-and-metal fantasy halberd, vertical orientation, slim dark gunmetal shaft, faceted spear-like bottom pommel, top head made of cracked dark gray stone plates and dark steel edges. Keep the same family identity from the reference: asymmetric broad axe blade on one side, curved crescent inner hook near the center, sharp rear spike/counter blade on the opposite side, small upward top spike, angular low-poly bevels, pale crack lines across the stone. Make only moderate variant changes: slightly cleaner heroic silhouette, a bit wider crescent hook, sharper but simple triangular spikes, subtle cold blue-gray rune/crack highlights, darker gunmetal shaft, small bronze-black collars at the head and lower grip.

Roblox 3D AI modeling reference style: centered object, full weapon visible from top spike to bottom pommel, product render lighting, clean silhouette, game-ready low-poly fantasy weapon, readable flat planes, hand-painted texture detail, no excessive tiny geometry, no floating parts, no dense sculpted relief, no noisy background, no room walls, no floor, no blue sky. The sheet should look like a professional weapon turnaround reference for 3D modeling.
```

## 输出文件

```text
cracked_stone_halberd_variant_front_view.png
cracked_stone_halberd_variant_side_view.png
cracked_stone_halberd_variant_back_view.png
cracked_stone_halberd_variant_three_view_sheet.png
```

## 检查结果

```text
front_view: 512x1024 PNG
side_view: 390x1024 PNG
back_view: 576x1024 PNG
sheet: 1536x1024 PNG
background: light gray / clean
no text / no watermark / no UI
full weapon visible
```

## 备注

本次采用高质量三视图母图裁切方式，优先保证复杂斧头结构在正面、侧面、背面中的一致性。侧视图已重新裁切去除分栏线，背视图已补安全边距，避免尖刺被 3D AI 误判为裁切。
