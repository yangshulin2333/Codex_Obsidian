# weapon_series_06_ruby_poleaxe 三视图 Prompt

用途：给 Meshy / 3D AI 做 Roblox 低模武器参考图。

## 生成目标

基于用户提供的长柄斧截图，生成同系列改款三视图。

保留系列特征：

1. 长柄竖向武器轮廓。
2. 黑灰金属杆身。
3. 大月牙斧刃。
4. 银白外侧刃口。
5. 红晶顶部。
6. 金色连接件、中心菱形装饰和底部金色尾件。
7. 橙色握把区域。

本次改款：

1. 红色改为更深的 ruby / crimson。
2. 橙色握把改为 copper-orange。
3. 银白刃口略加宽，并做成更清楚的低模折面。
4. 黑色内刃略微增加折角，但不增加复杂高模细节。
5. 三视图共用相同结构位置和比例，优先保证一致性。

## 核心 Prompt

```text
Create one clean orthographic three-view model sheet showing the same redesigned low-poly Roblox fantasy battle axe / poleaxe weapon in three views: front view, side view, and back view, placed evenly left to right on one wide canvas.

Use the attached screenshots as reference only. Keep the same weapon family feel but make a slight same-series variant, not an exact copy.

The weapon has a long vertical dark gunmetal segmented shaft, one large crescent axe blade on one side, dark blackened steel inner blade, bright pale silver cutting edge on the outer rim, a compact dark hammer or guard block on the opposite side with one small red gemstone inset, a faceted deep ruby red crystal cone cap on top, a short weathered gold collar below the cap, a small faceted gold diamond ornament in the center, a muted copper-orange grip/collar below the head, and a small gold axe-like hooked finial at the bottom.

Keep the original long-handle axe silhouette. Do not turn it into a sword, spear, or double-sided axe.

Clean 3D concept render, low-poly Roblox game asset design, readable flat planes, hand-painted texture detail, game-ready look, simple geometry suitable for about 3000 to 4000 triangles.

Orthographic model sheet, no perspective distortion. Full weapon visible from top crystal cap to bottom gold finial. Each view centered vertically, equal scale, large enough to inspect, generous padding. Plain light gray or off-white background. No floor horizon, no cast shadow, no UI, no axes, no labels, no text, no watermark.

The three views must clearly represent the exact same redesigned weapon. Match the shaft length, ring positions, top crystal size, gold collar, axe head height, crescent blade placement, orange collar, center diamond, and bottom finial across all three views.
```

## 反向约束

```text
no sword, no spear, no extra weapon heads, no character holding it, no scene background, no Roblox viewport UI, no labels, no text, no high-poly sculpted relief, no dense ornaments, no skulls, no tiny detached parts, no floating fragments, no noisy surface, no excessive spikes, no complex filigree
```
