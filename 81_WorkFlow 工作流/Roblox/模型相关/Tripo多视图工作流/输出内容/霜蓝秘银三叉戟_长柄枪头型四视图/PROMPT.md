# 霜蓝秘银三叉戟 四视图 Prompt 记录

## 设计锁

- 设计锁来源：`霜蓝秘银三叉戟_长柄枪头型正视图/frost_blue_mithril_trident_front_candidate_01.png`
- 武器类型：长柄枪头型 / 三叉戟
- 颜色主题：霜蓝秘银
- 材质语言：银白金属、冰蓝晶体、深钢灰阴影、冷青色点缀、Roblox 低模手绘材质
- 关键轮廓：长柄、三尖枪头、中间主尖更高、两侧副尖、弧形护架、底部尖形端帽
- 局部改款：棱角化护架末端、中心冰蓝菱形徽记、银色与深钢灰交替握柄环

## Back Prompt

```text
Using the accepted front-view weapon image as the exact design lock, generate ONE independent BACK VIEW image of the same Roblox low-poly fantasy trident / polearm weapon.

It must look like the same model rotated 180 degrees, not a new weapon. Preserve the same total height, long handle length, three-pronged trident head, taller central spear tip, two slimmer side spear tips, crescent-like guard position, angular wing-like guard ends, pommel shape, alternating silver and dark steel grip rings, frost-blue mithril color palette, satin silver metal, pale ice-blue crystal inlays, deep gunmetal shadows, small cool cyan accents, faceted low-poly material, and Roblox viewport/model screenshot feel.

The rear texture may be simpler and less gem-forward, but the major silhouette, proportions, handle alignment, guard/head width, socket/collar structure, and skin must match the accepted front view. The central diamond emblem can appear as a simpler rear plate or a smaller rear crystal setting, not as a brand-new decoration.

Full weapon visible from tip to pommel, centered vertical orthographic back view, clean light Roblox viewport-style background with generous padding.
No text, no labels, no watermark, no UI, no character, no hand, no new parts, no serrations, no saw teeth, no dense micro-spikes, no high-poly ornament, no flat vector style, no concept art style.
```

## Left Prompt

```text
Using the accepted front-view weapon image as the exact design lock, generate ONE independent LEFT 90-DEGREE SIDE VIEW image of the same Roblox low-poly fantasy trident / polearm weapon.

This must be a true side profile, not a 3/4 view. Preserve the same total height, long handle length, pommel, bottom spike cap, alternating silver and dark steel grip rings, frost-blue mithril color palette, satin silver metal, pale ice-blue crystal accents, deep gunmetal shadows, faceted low-poly material, and Roblox viewport/model screenshot feel.

For this long polearm trident head, do not reduce the weapon head into a plain needle. Keep the elongated central spearhead length, side bevel silhouette, socket/collar outline, and the vertical side spear tip length. From the side, the wide front-facing crescent guard and diamond crystal must compress into a narrow side edge with visible thickness only. The blade/head should look thin from the side but still recognizable as the same frost-blue mithril trident head.

Full weapon visible from tip to pommel, centered vertical orthographic LEFT 90-degree side view, clean light Roblox viewport-style background with generous padding.
No text, no labels, no watermark, no UI, no character, no hand, no 3/4 angle, no broad front-facing guard spread, no full front-facing diamond gem, no new geometry, no side serrations, no saw teeth, no extra side spikes, no flat vector style, no concept art style.
```

## Right Rule

`right` was created by mirroring the accepted `left` side view, because this weapon is nearly symmetric and independent side generation can cause left/right drift.

