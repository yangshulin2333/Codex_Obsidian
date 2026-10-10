# amethyst_void_spear_variant 三视图生成记录

## 用途

用于 3D AI 模型生成的武器三视图参考图。本次只生成概念参考图片，不是 FBX / GLB 打包任务。

## 设计锁定

- 类型：Roblox 低模风格紫晶虚空短枪 / 魔法法杖刃。
- 主轮廓：竖直武器，上方黑紫菱形枪尖，中段分段紫色握柄，中部黑色圆形能量核心，核心两侧象牙金翼形护板，下方长蓝紫水晶主刃，底部尖锐。
- 材质：黑紫虚空核心、洋红能量描边、象牙金护板、蓝紫水晶刃、紫晶侧边饰片。
- 改款点：金色从原参考图偏亮金调整为象牙金；紫色从纯紫调整为更冷的蓝紫晶；侧边晶片从随机碎片整理为更规整的对称晶片；护板边缘更硬朗，适合低模建模。
- 一致性要求：正面、侧面、背面必须是同一把武器，保持相同总高度、顶部枪尖、分段握柄、圆核、金色护板、侧边晶片、主刃长度和底部尖点。

## 核心提示词

```text
Create one same-series redesigned Roblox low-poly purple-gold crystal spear / arcane staff weapon based on the provided reference screenshots.

Keep the same family identity: black-purple diamond spear tip with magenta rim, segmented purple handle, central black void orb with magenta energy ring, ivory-gold wing guard, violet crystal side ornaments, and a long blue-violet crystal blade ending in a sharp bottom point.

Make only moderate variant changes: warmer ivory-gold guard, cooler blue-violet crystal blade, cleaner angular wing edges, more regular symmetric crystal shard panels, subtle cyan-blue crystal crack highlights, no scattered random fragments.

Generate three views: front view, 90-degree side view, back view. The three views must describe the exact same weapon design. Use a clean Roblox low-poly readable silhouette with hand-painted texture detail, not dense high-poly sculpture. Plain light gray background. No labels, text, watermark, UI, character, hand, or extra weapons.
```

## 输出文件

```text
amethyst_void_spear_variant_front_view.png
amethyst_void_spear_variant_side_view.png
amethyst_void_spear_variant_back_view.png
amethyst_void_spear_variant_three_view_sheet.png
```

## 检查结果

```text
front_view: 768x1536 PNG
side_view: 768x1536 PNG
back_view: 768x1536 PNG
sheet: 2304x1536 PNG
background: light gray / clean
no text / no watermark / no UI
full weapon visible
```

## 备注

内置图像生成连续三次跑偏成无关信息图，已全部废弃且未放入项目目录。最终交付采用本地可控低模矢量绘制，复用同一套部件坐标生成正、侧、背三视图，优先保证 3D AI 建模阶段的结构一致性。
