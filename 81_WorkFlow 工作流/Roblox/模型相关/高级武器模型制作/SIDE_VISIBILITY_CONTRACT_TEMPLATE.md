---
type: workflow
domain: roblox
status: active
owner: mixed
source: self
created: 2026-08-13
updated: 2026-08-15
---

# SIDE_VISIBILITY_CONTRACT 模板

> 每个部件单独复制。生成任何 `left/right/Side A/Side B/left45/right45` 前，由 Codex 主动逐项询问、按文件名复述，用户明确确认后才能进入生成。

## 部件身份

- 项目：
- Component ID / Role：
- 正式 `effect.png`：
- Front 定义：
- Length / Width / Thickness 轴：
- 合同确认日期：
- 用户确认原文：

整套视图、平台槽位、canonical 路径与逐图审批先填写 [[VIEW_SET_CONTRACT_TEMPLATE]]。本文件只补充侧向视图的方向性结构和遮挡合同。

## 每张严格侧向图的单相机合同

- camera_count：`1`
- projection：`ORTHOGRAPHIC`
- camera_target：部件几何中心；不允许从局部细节单独取景或拼接
- yaw / pitch / roll：逐文件填写；若写 `90° / 0° / 0°`，偏差、三分之四、透视、混合相机和后期拉伸均为 `FAIL`
- object_rotation：`0°` 或项目合同中的明确值；不得以旋转模型补偿未声明的相机角度
- critical_side_profile：立体兽首、人物首、尾环、端面、雕像或方向性机构在该视图必须仍可读的轮廓地标
- profile_silhouette_check：PASS / FAIL

严格 90° 只约束相机，不授权把实体结构压成纸片、窄条或正面贴片。关键立体结构必须随同一刚体正交旋转，保留合同所述的真实侧向轮廓与厚度。

## left.png

- 摄像机起点与观察方向：
- camera_count / projection：`1 / ORTHOGRAPHIC`
- yaw / pitch / roll：严格 90° / 0° / 0°，禁止 3/4、透视、拼接或混合视角
- 必须看见：
- 必须隐藏：
- 方向性结构的数量、顺序、位置：
- 遮挡者 -> 被遮挡者：
- 厚度和层级：
- 插头、槽位、孔口或端面投影：
- 与 front/back 对齐的地标：
- critical_side_profile / silhouette：
- 禁止新增：

## right.png

- 摄像机起点与观察方向：
- camera_count / projection：`1 / ORTHOGRAPHIC`
- yaw / pitch / roll：严格 90° / 0° / 0°，禁止 3/4、透视、拼接或混合视角
- 必须看见：
- 必须隐藏：
- 方向性结构的数量、顺序、位置：
- 遮挡者 -> 被遮挡者：
- 厚度和层级：
- 插头、槽位、孔口或端面投影：
- 与 front/back 对齐的地标：
- critical_side_profile / silhouette：
- 禁止新增：

## `{semantic_side_name}.png`（例如 `side_a_90.png`；按 required_final_views 复制）

- 摄像机起点与观察方向：
- camera_count / projection：`1 / ORTHOGRAPHIC`
- yaw / pitch / roll：
- 必须看见：
- 必须隐藏：
- 方向性结构的数量、顺序、位置：
- 遮挡者 -> 被遮挡者：
- 厚度和层级：
- 插头、槽位、孔口或端面投影：
- critical_side_profile / silhouette：
- 与 front/back 对齐的地标：
- 禁止新增：
- 独立生成：`YES`；不得引用、复制、翻转或镜像其他方向候选
- canonical path / SHA-256：
- 用户批准原文 / 日期：

## left45.png（如使用）

- 触发依据（P5A evidence）：
- 来源锁：`front.png + left.png`
- projection：`ORTHOGRAPHIC`
- yaw：项目坐标中的 front -> left 精确 45°
- pitch / roll：`0° / 0°`
- near end / far end：
- end-profile silhouette：
- visible side-wall depth：
- central front mechanism foreshortening：
- 必须看见：
- 必须隐藏：
- 方向性结构的数量、顺序、位置：
- 遮挡者 -> 被遮挡者：
- 厚度与接口投影：
- 与基础四视图对齐的垂直地标：
- perspective size drift：`FORBIDDEN`
- high / low camera：`FORBIDDEN`
- 整个部件刚体旋转证据：
- 独立生成：`YES`；不得引用或镜像 right45 候选
- canonical path / SHA-256：
- 用户批准原文 / 日期：

## right45.png（如使用）

- 触发依据（P5A evidence）：
- 来源锁：`front.png + right.png`
- projection：`ORTHOGRAPHIC`
- yaw：项目坐标中的 front -> right 精确 45°
- pitch / roll：`0° / 0°`
- near end / far end：
- end-profile silhouette：
- visible side-wall depth：
- central front mechanism foreshortening：
- 必须看见：
- 必须隐藏：
- 方向性结构的数量、顺序、位置：
- 遮挡者 -> 被遮挡者：
- 厚度与接口投影：
- 与基础四视图对齐的垂直地标：
- perspective size drift：`FORBIDDEN`
- high / low camera：`FORBIDDEN`
- 整个部件刚体旋转证据：
- 独立生成：`YES`；不得引用或镜像 left45 候选
- canonical path / SHA-256：
- 用户批准原文 / 日期：

## 镜像或几何复用授权

默认：`NOT_AUTHORIZED`

只有用户明确授权时填写：

- `source file -> target file`：
- 授权范围：仅本部件/本运行
- 用户原文：
- 日期：

授权不能从外观或“对称性”推断，不能跨部件、跨资产或跨运行继承。

## 验收结果

| 文件 | 相机通过 | must-visible/hidden | 数量/位置/遮挡 | end profile | side wall | central mechanism projection | perspective-free | 厚度/接口 | 用户结论 |
|---|---|---|---|---|---|---|---|---|---|
| left.png |  |  |  | N/A |  | N/A |  |  |  |
| right.png |  |  |  | N/A |  | N/A |  |  |  |
| left45.png | N/A | N/A | N/A | N/A | N/A | N/A | N/A | N/A | N/A |
| right45.png | N/A | N/A | N/A | N/A | N/A | N/A | N/A | N/A | N/A |
| `{semantic_side_name}.png` |  |  |  | N/A |  | N/A |  |  |  |
