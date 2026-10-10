# amethyst_void_spear_variant_v2 三视图生成记录

日期：2026-06-15

## 本次目标

重新生成紫晶虚空短枪 / 魔法法杖刃同系列改款三视图，用于 3D AI 建模参考。

上一版 `amethyst_void_spear_variant_20260615_three_views` 风格偏平面插画，且内置图像生成在聊天预览里出现过无关信息图，已不作为主交付继续使用。本次 v2 改为本地 Blender 可控低模 3D 渲染，优先保证风格、几何结构和三视角一致。

## 设计锁定

同系列改款紫晶虚空短枪 / 魔法法杖刃。保留参考图的黑紫菱形枪尖、洋红能量边、分段紫色上柄、中部黑色圆核、象牙金翼形护板、蓝紫水晶主刃和对称漂浮紫晶侧片。

允许变化范围：

- 颜色轻微变化为冷蓝紫晶、象牙金、深紫黑、洋红能量边。
- 护板形状更硬朗，适合 Roblox 低模读取。
- 晶片更规整，减少高模噪点。
- 主刃保留长水晶轮廓，但改为可建模的 faceted low-poly 结构。

不允许变化：

- 不改变武器类型。
- 不改变上下长比例。
- 不改变黑圆核、金护板、紫晶主刃、紫色上柄、顶部菱形枪尖的相对位置。
- 不生成角色、手、场景、文字、水印、UI。

## 生成路线

```text
generation_route: local_blender_render
renderer: Blender 5.1 background render
style_target: Roblox low-poly 3D render reference
imagegen_usage: not used for official v2 output
```

本次没有执行 Roblox FBX / GLB 导入打包流程。

## 输出

```text
amethyst_void_spear_variant_v2_front_view.png  900x1600
amethyst_void_spear_variant_v2_side_view.png   900x1600
amethyst_void_spear_variant_v2_back_view.png   900x1600
amethyst_void_spear_variant_v2_three_view_sheet.png  2924x1712
render_amethyst_void_spear_v2.py
```

## 检查结果

```text
front_view: full weapon visible, no UI, no text, light gray background
side_view: same weapon geometry, orthographic 90-degree side view
back_view: same weapon geometry, rear lighting/material variation only
three views share one Blender scene and one geometry definition
top spear tip and bottom crystal point are not cropped
```

## 后续注意

这类 Roblox 三视图任务如果用户强调“风格一致 / 不要跑偏 / 用于 3D AI 建模”，默认不要先调用内置图像生成。优先使用本地可控渲染、矢量或已验证的模型视角流程；只有用户明确接受探索性 AI 概念图时，再把内置图像生成作为候选方案。
