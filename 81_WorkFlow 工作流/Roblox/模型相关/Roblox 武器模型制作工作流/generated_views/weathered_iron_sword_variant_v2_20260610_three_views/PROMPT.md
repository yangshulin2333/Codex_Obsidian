# weathered_iron_sword_variant_v2 三视图生成记录

## 用途

用于 3D AI 模型生成的武器三视图参考图。本次只生成概念参考图片，不是 FBX / GLB 打包任务。

## 设计锁定

- 类型：Roblox 低模风格幻想长剑。
- 主轮廓：长直剑身，顶部木质握柄，小型多边形护手，底部菱形强化剑尖。
- 材质：棕色木柄，暗铜 / 深木护手，风化银灰铁石剑刃，深灰中央 fuller / spine。
- 改款点：剑身更宽、更规整，低模块面更清楚；护手加入铜边和背面铆钉；中央黑色凹槽更清晰；剑刃保留少量划痕和石质颗粒，但不做复杂高模浮雕。
- 一致性要求：正面、侧面、背面必须是同一把武器，保持相同长度、握柄、护手、剑身宽度和材质。

## 核心提示词

```text
Using the three visible reference images as the design family, create a high-quality concept-art reference sheet for ONE redesigned Roblox fantasy sword weapon.

Output: one clean three-view sheet with exactly three separate vertical panels on a plain light gray background: front orthographic view, 90-degree side orthographic view, back orthographic view. The same weapon must appear in all three panels with identical proportions, silhouette, handle, guard, blade length, and materials. No labels, no text, no numbers, no arrows, no UI, no chart, no poster layout, no hands, no character, no watermark.

Weapon design lock: a long straight low-poly sword, vertical orientation, wooden brown grip at the top, compact angular bronze/dark-wood guard under the grip, long faceted pale silver weathered iron/stone blade, dark central fuller/groove running down the blade, diamond-shaped reinforced tip at the bottom. Improve quality from the reference: cleaner bevel planes, readable metal facets, subtle scratches painted as texture, small bronze rivets on the guard, a dark steel spine in the central groove, slightly wider heroic blade shape, crisp Roblox game-ready low-poly style.

Roblox 3D AI modeling reference style: centered object, full weapon visible, product render lighting, clean silhouette, moderate texture detail, no excessive tiny geometry, no floating parts, no dense relief, no photorealistic environment, no blue sky, no room walls. The image should look like a professional weapon turnaround sheet for 3D modeling.
```

## 输出文件

```text
weathered_iron_sword_variant_v2_front_view.png
weathered_iron_sword_variant_v2_side_view.png
weathered_iron_sword_variant_v2_back_view.png
weathered_iron_sword_variant_v2_three_view_sheet.png
```

## 检查结果

```text
front_view: 512x1024 PNG
side_view: 356x1024 PNG
back_view: 512x1024 PNG
sheet: 1536x1024 PNG
background: light gray / clean
no text / no watermark / no UI
```

## 备注

上一版本地绘制质量不足，已不推荐使用。本 v2 版本使用高质量三视图母图裁切，优先保证同一武器在正面、侧面、背面的一致性。
