---
type: workflow
domain: roblox
status: active
owner: mixed
source: codex
created: 2026-07-13
updated: 2026-07-14
---

# Roblox 低模道具提示词模板

## 使用原则

提示词只保留会改变图片的约束。完整检查清单、失败代码、目录规则和状态机不要塞进生图提示词。

每次最多说明：

1. 这是哪一个道具。
2. 哪些大形体和轮廓必须保留。
3. 哪些细节需要简化或降为材质。
4. 当前相机角度。
5. 背景和禁止项。

## 通用风格句

```text
Stylized Roblox RPG low-poly game prop. Use a few clean, readable large forms, broad surfaces, controlled bevels, clear thickness, and simple material zones. Simplified but polished, designed for stable image-to-3D reconstruction.
```

## 通用简化句

```text
Keep geometry only when it changes the silhouette, volume, connection, or major material boundary. Convert tiny veins, cracks, sparkles, and surface patterns into simple color or material detail. Avoid dense nested layers, random faceting, micro-spikes, paper-thin parts, and photoreal transparent materials.
```

## 正视图

```text
Create one strict FRONT orthographic view of {ASSET_NAME}, Identity {IDENTITY_ID}, as a stylized Roblox RPG low-poly game prop.

Silhouette and major forms: {SILHOUETTE_AND_MAJOR_FORMS}.
Depth/thickness: {DEPTH_SUMMARY}.
Material zones: {MATERIAL_ZONES}.
Simplify: {SIMPLIFY_OR_REMOVE}.

Use a few clean large forms, broad surfaces, controlled bevels, and clear thickness. Simplified but polished, not rough or primitive. Keep geometry only for silhouette, volume, connections, and major material boundaries.

Centered strict front view, orthographic, zero yaw/pitch/roll, complete object with clean padding, uniform #D7D7D7 background. No character, UI, text, particles, floor, cast shadow, crop, random facets, dense micro-detail, or photoreal transparency.
```

## 其余独特视图

```text
Image 1 is the approved front design lock for {ASSET_NAME}, Identity {IDENTITY_ID}.
Generate the exact same physical prop from the strict {VIEW_NAME} orthographic view.

Preserve the approved silhouette, major forms, connections, thickness logic, and material zones. Rotate the object only; do not redesign it, add parts, increase detail density, or change the low-poly simplification.

Camera: {YAW} horizontal turntable rotation, zero pitch and roll, orthographic, same framing scale, uniform #D7D7D7 background. No floor, shadow, text, UI, particles, crop, random facets, micro-spikes, or new decoration.
```

角度替换：

- `left45`：`-45 degrees`
- `left`：`-90 degrees`
- `back`：`180 degrees`
- `right`：`+90 degrees`

## 背视图补充

只在需要时追加：

```text
Keep the rear structure simple and consistent with the approved depth. Do not copy front-only decoration onto the back, and do not invent a new visual theme or hidden mechanism.
```

## 花瓣、晶体和放射状法器补充

```text
Use a small number of broad, readable radial layers. Keep one clear center and a clean outer silhouette. Do not build the prop from many thin overlapping petals, crystal splinters, or random triangular shards. Preserve the approved radial rhythm without forcing every decorative petal to be counted as a separate identity-critical component.
```

## 左右侧向可见性合同

生成 `left/right` 或相应 45° 视图前，先逐文件填写：

```text
This exact output is <left.png / right.png / left45.png / right45.png>.
Must be visible: <structures, counts, positions, winding direction, attachment endpoints>.
Must be hidden: <structures>.
Do not copy these opposite-side-only structures: <structures>.
```

不从外观推断镜像。只有用户明确授权两个输出共用同一几何时，才执行确定性水平镜像，并在资产锁中记录映射。

## 局部修复

```text
Edit only {PROBLEM_AREA} in the target image.
Expected result: {EXPECTED_RESULT}.
Keep the approved camera, silhouette outside the target, major forms, material zones, framing, and background unchanged. Do not add detail or redesign other areas.
```

## 输入图角色

多图输入时只写实际存在的角色：

```text
Image 1: approved front design lock.
Image 2: approved 45-degree depth reference.
Image 3: approved strict side reference.
```

不要把失败候选、联系表或上一道具图片继续作为参考。
