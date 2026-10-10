---
type: workflow
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-08-17
updated: 2026-08-17
---

# 单侧视图验收清单

## A. 启动门

- [ ] 只处理一个当前资产。
- [ ] 只处理一个目标文件：`left / right / Side A / Side B`。
- [ ] 已确认是新生成、对侧生成，还是修复现有候选。
- [ ] 已记录父工作流和正式目标路径（如有）。
- [ ] 没有加载旧资产、旧武器或无关候选。
- [ ] 当前只有一个活动图像生成任务。

失败码：`SIDE_TARGET_NOT_DEFINED`、`OLD_ASSET_CONTEXT_POLLUTION`、`DUPLICATE_SIDE_TASK_ACTIVE`。

## B. 输入锁

- [ ] Image 1 已标明为当前正视设计锁。
- [ ] 背视图如存在，已标明为背面或双面结构证据。
- [ ] 结构图 / 45° 图如存在，已说明只补充哪些体积证据。
- [ ] 已确认另一侧如存在，已说明只作厚度和锚点基准。
- [ ] 修复候选如存在，已说明它是唯一编辑目标。
- [ ] 单次输入不超过 5 张当前资产图片。

失败码：`SIDE_DESIGN_LOCK_MISSING`、`SIDE_REFERENCE_ROLE_AMBIGUOUS`、`SIDE_CONTEXT_OVERLOAD`。

## C. 相机锁

- [ ] `camera_count=1`。
- [ ] `projection=ORTHOGRAPHIC`。
- [ ] `left` 使用已约定的 `yaw=-90°`。
- [ ] `right` 使用已约定的 `yaw=+90°`。
- [ ] `pitch=0°`。
- [ ] `roll=0°`。
- [ ] 如果平台轴向不同，已在运行开始时重新映射，而不是生成后改口。
- [ ] 目标是严格 90°，不是 45°、3/4 或轻微侧转。

失败码：`SIDE_VIEW_NOT_90_DEGREE`、`SIDE_VIEW_PERSPECTIVE`、`SIDE_CAMERA_DIRECTION_AMBIGUOUS`。

## D. 姿态与画布

- [ ] 主轴严格竖直或按合同严格水平。
- [ ] 没有继承正视图的斜摆、交叉或倾斜姿态。
- [ ] 物体完整进入画面，无裁切。
- [ ] 总高度 / 总长度与设计锁一致。
- [ ] 主体中心、柄起止、接口、环箍和尾饰锚点一致。
- [ ] 只做等比缩放、平移和补边。
- [ ] 没有非等比横向压缩或纵向拉伸。

失败码：`SIDE_VIEW_NOT_ALIGNED`、`SIDE_VIEW_CROPPED`、`SIDE_LANDMARK_DRIFT`、`SIDE_NONUNIFORM_SCALE`。

## E. 几何分类

- [ ] 已选择一个基础几何类。
- [ ] 已记录所有适用修饰合同。
- [ ] 分类有正视、背视、结构图或用户描述证据。
- [ ] 没有只凭一句 `make it thin` 代替体积判断。

基础类：

- [ ] `P1_THIN_PLATE`
- [ ] `P2_LONG_HEAD`
- [ ] `P3_LAYERED_FLAT_VOLUME`
- [ ] `V1_ROUND_VOLUME`
- [ ] `V2_BOX_IRREGULAR_VOLUME`
- [ ] `O1_OPEN_FRAME`

修饰合同：

- [ ] `A_ASYMMETRIC`
- [ ] `D_DOUBLE_SIDED`
- [ ] `R_ROTATIONAL`
- [ ] `H_SHAFT_ANCHORED`
- [ ] `C_CAVITY_CRITICAL`

失败码：`SIDE_GEOMETRY_CLASS_MISSING`、`SIDE_GEOMETRY_CLASS_WRONG`、`SIDE_GEOMETRY_EVIDENCE_MISSING`。

## F. 可见性合同

- [ ] 已写 `must_visible`。
- [ ] 已写 `must_hidden`。
- [ ] 已写单侧零件的数量、顺序和位置。
- [ ] 已写每项是完整可见、部分遮挡、露薄边还是完全隐藏。
- [ ] 已写不得从另一侧复制的内容。
- [ ] Codex 已复述，用户已确认或原要求已经足够明确。

失败码：`SIDE_VISIBILITY_CONTRACT_MISSING`、`SIDE_VISIBILITY_CONTRACT_BROKEN`、`SIDE_OCCLUSION_ORDER_WRONG`。

## G. 分类专项检查

### `P1_THIN_PLATE`

- [ ] 侧面是窄边，不露大面积正面。
- [ ] 仍能读出厚度、倒角、插槽或护手深度。
- [ ] 不是一像素线。
- [ ] 正面纹理、完整槽和完整宝石已隐藏或变成薄边。

### `P2_LONG_HEAD`

- [ ] 头部宽度变窄，但长度未缩短。
- [ ] 护颈、枪托、插槽和连接轮廓保留。
- [ ] 没有变成普通细针。
- [ ] 完整正面宝石没有露出。

### `P3_LAYERED_FLAT_VOLUME`

- [ ] 正面宽结构已重叠为紧凑窄体块。
- [ ] 主体中层、后置层和正反浅凸层可读。
- [ ] 没有展开完整轮盘 / 辐臂 / 徽章正面。
- [ ] 双面宝石只露薄边。
- [ ] 没有被压成无层次细线。

### `V1_ROUND_VOLUME`

- [ ] 球、圆鼓、圆柱或瓶罐体积仍然成立。
- [ ] 侧向尖刺、把手、环、盖和喷口按合同保留。
- [ ] 没有被压成薄板或普通竖条。

### `V2_BOX_IRREGULAR_VOLUME`

- [ ] 主箱体 / 锤头前后深度符合结构卡。
- [ ] 前后凸起、台阶、转角和接口顺序正确。
- [ ] 没有球化、薄片化或新增机械结构。

### `O1_OPEN_FRAME`

- [ ] 关键孔洞和空腔没有被填死。
- [ ] 支撑杆、前后梁和开口数量正确。
- [ ] 重叠只发生在严格侧视物理对齐的位置。

## H. 身份与风格锁

- [ ] 仍然是同一个资产，不是同系列的新设计。
- [ ] 材质区、主色、切面语言和细节密度一致。
- [ ] 没有新增尖刺、鳍片、装甲、宝石、按钮或孔洞。
- [ ] 没有缺失关键插槽、接口、环箍、端帽或尾饰。
- [ ] 没有变成儿童玩具、训练模型、扁平图标或概念插画。

失败码：`SIDE_IDENTITY_DRIFT`、`SIDE_STYLE_DRIFT`、`SIDE_NEW_GEOMETRY_ADDED`、`SIDE_REQUIRED_GEOMETRY_MISSING`。

## I. 左右独立性 / 镜像门

- [ ] 当前侧自己的可见性合同已确认。
- [ ] 另一侧只作共享厚度和锚点基准。
- [ ] 没有复制另一侧的单侧结构、高光或像素。
- [ ] 如果使用镜像，已有用户明确的来源、目标和授权日期。
- [ ] 授权镜像使用本地确定性水平翻转。
- [ ] 授权镜像已做往返像素校验，误差为 0。
- [ ] 用户若说“单独生成”，旧镜像授权已撤销。

失败码：`UNCONFIRMED_SIDE_MIRROR`、`OPPOSITE_SIDE_DETAIL_COPIED`、`LEFT_RIGHT_MISMATCH`。

## J. 背景与文件门

- [ ] PNG 存在且可解码。
- [ ] 宽高大于 0。
- [ ] 画布尺寸符合父工作流或设计锁。
- [ ] 背景是约定的干净纯色或稳定中性背景。
- [ ] 无地面、地平线、墙角、坐标轴、UI、文字和水印。
- [ ] 候选位于 `_candidates` 或短英文审核路径。
- [ ] 正式目录没有候选、文档、检查图或子目录。
- [ ] 已记录 SHA-256、尺寸和来源候选。

失败码：`BACKGROUND_NOT_CLEAN`、`TEXT_UI_WATERMARK`、`SIDE_IMAGE_DECODE_FAILED`、`FINAL_SIDE_FOLDER_DIRTY`。

## K. 人工确认门

- [ ] 候选已在聊天中直接显示。
- [ ] 审核副本已在资源管理器 / 图片查看器中打开。
- [ ] 用户明确说“确认、可以、这版很好、就用这张”等。
- [ ] 用户没有同时指出仍需修改的问题。
- [ ] 已记录确认原话和日期。

失败码：`SIDE_USER_APPROVAL_MISSING`、`CODEX_LOCAL_PREVIEW_UNAVAILABLE`、`REVIEW_WINDOW_NOT_FOREGROUND`。

## L. 最终签发

- [ ] 自动检查全部通过。
- [ ] 用户确认通过。
- [ ] 正式文件只有当前目标侧。
- [ ] 父工作流修复模式只替换当前目标文件。
- [ ] 其他已确认视图未被改动。
- [ ] `RUN_STATE.md` 已更新为 `SIDE_FINALIZED`。
- [ ] 最终文件路径可点击，文件夹由 Codex 主动打开而不是依赖文件夹 Markdown 链接。

相关入口：[[README|单侧视图生成工作流]]。
