---
type: workflow
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-08-17
updated: 2026-08-17
---

# 单侧视图通用提示词模板

## 使用方式

提示词由四块组成：

```text
通用基础块
+ 当前几何类补充块
+ 当前目标侧可见性合同
+ 当前资产的锚点、材质和背景锁
```

不要一次加入所有几何类。每次只选择一个基础类，并叠加需要的修饰合同。

## 1. 通用基础块

```text
Using the accepted reference images as strict design, geometry, proportion, material and style locks, generate ONE independent <LEFT / RIGHT / SIDE A / SIDE B> 90-DEGREE ENGINEERING SIDE VIEW of the exact same physical Roblox game asset.

Input image roles:
- Image 1: accepted FRONT design lock.
- Image 2: accepted BACK or double-sided geometry evidence. <omit if unavailable>
- Image 3: structure or 45-degree evidence. <omit if unavailable>
- Image 4: accepted opposite-side thickness and landmark benchmark only. Do not copy, flip, mirror, trace or reuse its pixels. <omit if unavailable>
- Image 5: current side-view edit target. Change only the stated defect. <repair mode only>

Camera:
- Exactly one camera.
- Orthographic projection.
- Exact <left / right / confirmed semantic> observation direction relative to the accepted front.
- yaw=<-90 / +90 / confirmed value> degrees, pitch=0 degrees, roll=0 degrees.
- True 90-degree side profile, never a 3/4 view.
- No perspective distortion.

Orientation and framing:
- Keep the asset perfectly aligned to its confirmed main axis.
- Keep the full asset visible with safe margins.
- Preserve the same total height or length, main body center, handle or shaft length, interfaces, collars, sockets, end cap and pommel landmarks.
- Use the same canvas ratio, object scale and clean background as the accepted design lock.

Confirmed visibility contract for this exact output:
- Must be visible: <structures, counts, order, positions and thickness>
- Must be hidden: <front/back/opposite-side structures>
- Occlusion: <full / partial / thin edge / hidden>
- Details forbidden from transfer: <opposite-side details>

Style and materials:
- Preserve the accepted premium stylized Roblox game-asset style.
- Preserve the same large readable forms, faceted planes, material zones, palette and detail density.
- This is an engineering image-to-3D reference, not a redesign and not concept art.

Backdrop:
- Uniform clean solid light blue-gray or the accepted flat background color.
- No floor, horizon, wall corner, gradient, scenery, UI, text, watermark, character, hand, particles or extra objects.

Critical constraints:
- Same physical asset, rotated to the requested strict side camera.
- Do not horizontally squash the front image.
- Do not inherit the front pose if it is tilted or diagonal.
- No new geometry, no missing interfaces, no changed proportions, no broad face-on details unless explicitly required by the visibility contract.
```

## 2. `P1_THIN_PLATE` 薄片 / 薄刃补充

适用：剑、刀、薄镰刃、盾牌薄板、薄装饰片。

```text
Geometry class: P1_THIN_PLATE.
Reconstruct the front-facing blade or plate as a true narrow side edge.
Keep readable physical thickness, bevels, edge planes, sockets and side-visible material strips.
The side may be thin, but it must not collapse into a one-pixel line.
Front-facing engravings, full grooves, full emblems and full gemstones must be hidden or reduced to a thin side sliver.
Do not show the broad front blade or plate face.
```

失败预防：

```text
No compressed front texture, no broad face, no complete front gem, no spread guard, no diagonal blade pose.
```

## 3. `P2_LONG_HEAD` 长柄枪头 / 狭长头补充

适用：枪、矛、戟、长钻头、长护颈武器。

```text
Geometry class: P2_LONG_HEAD.
The head becomes narrow from the side but keeps its accepted longitudinal length.
Preserve the side bevel silhouette, neck, socket, collar, support block and connection to the shaft.
Do not reduce the head into a plain needle or remove its recognizable stepped structure.
Any front gemstone or emblem may appear only as a thin edge, tiny side sliver or fully occluded element according to the visibility contract.
```

失败预防：

```text
No shortened head, no plain needle, no missing socket, no complete front gem face.
```

## 4. `P3_LAYERED_FLAT_VOLUME` 层叠盘形 / 扁体块补充

适用：辐轮法杖头、徽章盘、双面宝石盘、宽正面薄纵深装饰头。

```text
Geometry class: P3_LAYERED_FLAT_VOLUME.
This is a broad but relatively flat layered ornamental body.
From the strict side camera, the front-facing radial arms or broad decorative structures overlap into one compact narrow side silhouette.
Show believable physical layer thickness: the main body layer in the middle, rear ring or support layer behind it, and shallow raised frames or ornaments on the front and rear faces.
Do not flatten it to a one-pixel line, but do not reveal the broad front or rear face.
Double-sided gemstones or colored inserts may appear only as thin edge slivers on the two opposing faces.
```

失败预防：

```text
No wide circular disk silhouette, no full radial spread, no complete gemstone face, no face-on ornament.
```

## 5. `V1_ROUND_VOLUME` 圆体块 / 旋转体补充

适用：狼牙棒、球锤、圆鼓、桶、瓶、罐、圆柱装置。

```text
Geometry class: V1_ROUND_VOLUME.
This is a true volumetric body, not a flat plate.
Preserve the round, spherical, drum, barrel or cylindrical volume from the side.
The side width should follow the confirmed cross-section evidence and normally remains close to the front/back volume.
Preserve side-facing spikes, handles, rings, caps, bands, nozzles and other structures that physically rotate into view.
Front-facing and rear-facing details may overlap or be hidden, but the overall volume must not collapse into a narrow line.
```

失败预防：

```text
No flattened oval plate, no missing side spikes, no plain stick, no deleted round body.
```

## 6. `V2_BOX_IRREGULAR_VOLUME` 箱体 / 不规则厚体补充

适用：锤头、宝箱、机器、厚重工具、组合体块。

先填写深度结构卡：

```text
main body depth: <relative value or evidence>
front protrusion: <part and thickness>
rear protrusion: <part and thickness>
top/bottom steps: <order>
side interfaces: <count and position>
```

提示词：

```text
Geometry class: V2_BOX_IRREGULAR_VOLUME.
Reconstruct the side from the confirmed depth structure card instead of applying a generic thin profile.
Preserve the main box or hammer volume, front and rear protrusions, stepped corners, interfaces, sockets, caps and support blocks at their confirmed relative depths.
Keep straight hard-surface planes and readable large forms.
Do not round a box into a ball, flatten it into a plate or invent hidden mechanical parts.
```

失败预防：

```text
No generic thin edge, no spherical simplification, no changed corner structure, no invented rear machinery.
```

## 7. `O1_OPEN_FRAME` 开放框架 / 空腔补充

适用：镂空机械框、轮架、门框、开放支架、关键孔洞结构。

```text
Geometry class: O1_OPEN_FRAME.
Preserve the confirmed side-visible openings, cavities, support bars, front and rear beams and their occlusion order.
Empty space must remain empty; do not fill openings with solid material.
Bars that overlap from the side may merge visually only where the strict camera physically aligns them.
Preserve the number and vertical order of openings and supports.
```

失败预防：

```text
No filled cavity, no missing support, no extra brace, no impossible open hole through a solid section.
```

## 8. 修饰合同补充

### `A_ASYMMETRIC` 单侧结构

```text
Modifier: A_ASYMMETRIC.
This target view has direction-specific structures.
Preserve exactly: <count, order, position, orientation and occlusion>.
Do not copy the opposite side's exclusive structures into this view.
Do not make the asset artificially symmetric.
```

### `D_DOUBLE_SIDED` 双面装饰

```text
Modifier: D_DOUBLE_SIDED.
The front and rear faces both contain visible raised structures.
From the strict side camera, show only their shallow protruding thickness or thin colored edge slivers.
Do not reveal either complete face.
```

### `R_ROTATIONAL` 近似旋转对称

```text
Modifier: R_ROTATIONAL.
Preserve the rotational cross-section and repeated ring/cap structure around the confirmed main axis.
This modifier reduces directional ambiguity but does not authorize copying or mirroring an image file.
```

### `H_SHAFT_ANCHORED` 长柄 / 长轴

```text
Modifier: H_SHAFT_ANCHORED.
Preserve the exact accepted shaft length, normal physical diameter, straight centerline, collar count and heights, connection socket and end decoration.
Do not shorten, thicken, bend or taper the shaft unless the design lock shows it.
```

### `C_CAVITY_CRITICAL` 关键孔洞 / 插槽

```text
Modifier: C_CAVITY_CRITICAL.
The cavity or socket is an identity-critical structure.
For this target camera it must be <fully visible / partially visible / edge-on / hidden>.
Preserve its count, order, depth cue and surrounding frame.
```

## 9. 已确认另一侧作为基准

独立生成对侧时追加：

```text
Use the accepted opposite-side image only as the exact benchmark for total height, canvas framing, main-body center, shaft length, component landmarks and front-to-back thickness.
Independently reconstruct the requested opposite camera direction.
Do not copy, flip, mirror, trace, edit or reuse pixels from the accepted side image.
Natural bevel highlights and occlusion may reverse, but the shared physical thickness and landmarks must match.
```

## 10. 单点修复模板

修复模式每轮只改一个主问题。

### 修相机，不改设计

```text
Change only the camera and orientation.
Rebuild this as a single-camera orthographic exact <LEFT/RIGHT> 90-degree side profile, yaw=<value>, pitch=0, roll=0.
Keep all accepted geometry, proportions, materials, landmarks and visibility contract unchanged.
No 3/4 view and no perspective.
```

### 修体积过薄

```text
Change only the side thickness interpretation.
The current result is too thin for geometry class <class>.
Restore these confirmed depth layers: <layers>.
Keep the camera, total height, shaft, landmarks, materials and background unchanged.
Do not reveal the broad front face.
```

### 修正面露出过多

```text
Change only the face visibility.
Hide the broad front/rear face and complete gemstone/emblem surfaces.
Keep only the confirmed edge, sliver, shallow protrusion and side thickness.
Keep camera, silhouette length, shaft and all landmarks unchanged.
```

### 修长柄长度漂移

```text
Change only the shaft or handle length.
Match the accepted design lock's exact start point, end point and total length.
Keep the head, socket, collars, diameter, pommel, camera and side thickness unchanged.
```

### 修单侧内容错误

```text
Change only the direction-specific visibility contract for <target file>.
Must be visible: <list>.
Must be hidden: <list>.
Remove details copied from the opposite side: <list>.
Keep camera, shared geometry, scale, materials and landmarks unchanged.
```

## 11. 禁止项词库

按当前失败选择，不要无差别全部堆入：

```text
no 3/4 angle
no perspective
no tilted pose
no diagonal pose
no camera roll
no broad front face
no complete front gemstone
no horizontally squashed front texture
no one-pixel thin silhouette
no missing side volume
no new geometry
no extra spikes or fins
no missing sockets or collars
no shortened handle
no changed pommel
no opposite-side detail transfer
no unapproved mirror
no style drift
no childish toy simplification
no text, watermark, UI, character, hand or scene clutter
```

## 12. 运行记录要求

每次保存最终提示词时记录：

- `target_view`
- `camera`
- `geometry_class`
- `modifiers`
- `must_visible`
- `must_hidden`
- `landmarks`
- `reference_roles`
- `mirror_authorization`
- `single_change_iteration`

相关入口：[[README|单侧视图生成工作流]]。
