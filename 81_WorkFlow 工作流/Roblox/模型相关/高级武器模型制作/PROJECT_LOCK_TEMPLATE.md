---
type: workflow
domain: roblox
status: active
owner: mixed
source: self
created: 2026-08-13
updated: 2026-08-14
---

# 高级武器 PROJECT_LOCK 模板

> 复制为运行目录的 `00_brief/PROJECT_LOCK.md`。未确认字段写 `UNCONFIRMED`，不要留空后自行推断。

## 项目身份

- 项目名：
- run_mode：`NEW_PROJECT / RESUME`
- 输入来源：用户附件 / 文字构想 / 已有项目 RUN_STATE / 其他
- 历史案例参数继承：`FORBIDDEN`；如为续作，必须列出明确授权字段：
- 资产英文名：
- 用途：
- 目标玩家视角：
- 目标风格：
- 图生 3D 平台：
- Roblox 目标：展示 Model / Tool / NPC 武器 / 其他
- 目标总长：`SCALE_UNCONFIRMED`
- 单位：Stud / m / 归一化 L=1000
- 三角面预算：
- 贴图尺寸：
- 明确不做：

新项目不得默认复制猫猫剑、冰晶战锤或其他案例的拆件数、目标尺寸、视图集、front-only/镜像授权、接口、Root、材质和 Studio 设置。未知值写 `UNCONFIRMED`。

## 视觉 DNA

- 一句话剪影：
- 主色：
- 辅色：
- 识别点：
- 材质语言：
- 禁止漂移：

## 坐标与正面

- Length 轴：
- Width 轴：
- Thickness 轴：
- Front 定义：
- 武器尖端：
- 武器尾端：
- Roblox 推荐 PrimaryPart / Pivot：

## Blender / FBX 导出合同

- selected_object_whitelist：
- root_part：
- common_pivot_definition：
- common_pivot_coordinates：
- unit_strategy：`BU_AS_STUD / TRUE_METRE_ONCE / UNCONFIRMED`
- `TARGET_LENGTH_STUDS`：
- source_unit / conversion_applied_at：
- transform_target：`Location=0 / Rotation=0 / Scale=1`
- Forward / Up：`-Z / Y`（新项目若更改，须以回导和 Studio 预览建立新基线）
- material_policy：`one transferable material set per Mesh`
- texture_format_policy：真实编码与 `.png/.jpg/.jpeg` 扩展名一致
- embed_policy：`Path Mode=Copy + Embed Textures=On`
- 正常 Studio 输入：只选择最终 FBX；外部 textures 仅作证据/回退

## Studio 写入合同

- Studio Project / Place：
- 目标 Model 路径：
- 模式：display / tool / npc
- root_part：
- anchored_policy：
- 允许 Codex 写入：NO / YES
- 用户授权原文与日期：

## 部件清单

| ID | Role | 中文名 | required / optional / deferred | 轴向范围 | 可见长度 | 最大宽/厚 | 独立 MeshPart | 状态 |
|---|---|---|---|---:|---:|---|---|---|
| 01 |  |  | required |  |  |  |  | DRAFT |

部件级 Gate 只使用：`NOT_STARTED / IN_PROGRESS / PASS / FAIL / WAIVED`。`WAIVED` 仅适用于已在拆件门确认的 optional/deferred 部件，或另有新的用户审批记录。

## 接口清单

| JOINT_ID | From -> To | 类型/截面 | 共享对位区 | 中心轴 / FRONT | 最终所有者 | 代理副本 | 防转 | 插入深度 | 可见接缝/遮挡 | 对齐后删除项 | 精确重建 | Gate |
|---|---|---|---|---|---|---|---|---:|---|---|---|---|
| JOINT_A |  |  |  |  |  |  |  |  |  |  | Blender | DRAFT |

每行必须链接对应的 `00_brief/joints/JOINT_<ID>.md`，并使用 [[JOINT_CONTRACT_TEMPLATE]]。接口 Gate：`DRAFT / APPROVED / REBUILD_PASS / EXPORT_PASS / FAIL`。

项目约束：

- 共享对位区可同时出现在两个部件的参考图中，但只允许一个最终可见表面所有者。
- 代理副本必须标记 `DELETE_AFTER_ALIGN`，不得与所有者副本一起进入 `EXPORT_COPY`。
- 两次 AI 生成只作为近似造型证据；精确接口由 Blender 按 JOINT 合同重建。
- 隐藏插头/连接芯不等于代理副本；只有合同明确批准且无共面重复面时才可保留。

## 比例合同

- 归一化总长：`L = 1000`
- 各站位：
- 部件真实长度与成品外露长度差异：
- 非等比缩放授权：无 / 有，XYZ =
- `TARGET_LENGTH_STUDS`：

## 部件设计锁

每个部件另复制 [[../Roblox 魔法剑模型制作工作流/DESIGN_LOCK_TEMPLATE|魔法剑 DESIGN_LOCK 模板]]，并补充：

- 它与完整效果图的对应区域。
- 接口周围必须保留的实体。
- 装配后会被其他部件遮挡的区域。
- 需要的视图集与额外轴向/剖面证据。

## 视图证据策略（部件级）

> 默认 `aux45_policy=P5A_TRIGGER_ONLY`。先用已批准的单正视图或基础四视图试模；只有 P5A 有证据且用户确认，才为该部件创建左右 45° 辅助包。

> `FRONT_ONLY_USER_APPROVED` 若在首轮模型中证据不足，先重新询问用户是否升级为基础四视图；只有四视图完成、试模并在 P5A 证明空间桥接仍不足后，才能触发辅助 45°，不得从单正视图直接跳到 `4 + 2`。

| Component ID / Role | primary_volume | CROSS_SECTION | END_PROFILE | base view mode | aux45_policy | 工程补图 |
|---|---|---|---|---|---|---|
|  |  |  |  | FRONT_ONLY / FOUR_VIEW | P5A_TRIGGER_ONLY | none / axial / section / top / bottom |

`CROSS_SECTION / END_PROFILE` 不能说明时先用简单 Proxy；不得让图像模型用正式候选反复猜空间关系。辅助 45° 不替代 Blender 的精确接口重建。

## VIEW_REDUNDANCY_GATE（部件级）

> `redundancy_candidate=YES` 只是 Codex 的提问触发器，不是 `front-only` 许可。用户未明确授权时，`view_mode` 必须保持 `MULTI_VIEW`，并继续 [[SIDE_VISIBILITY_CONTRACT_TEMPLATE]]。

| Component ID / Role | redundancy_candidate | 判断依据/反例风险 | Codex 已主动询问 | 用户决策 | 用户原话/日期 | view_mode | required_views | side contract | Gate |
|---|---|---|---|---|---|---|---|---|---|
|  | YES / NO |  | YES / NO | UNCONFIRMED / KEEP_MULTI_VIEW / FRONT_ONLY_APPROVED |  | MULTI_VIEW / FRONT_ONLY_USER_APPROVED |  | REQUIRED / WAIVED_WITH_AUTHORIZATION | NOT_STARTED |

Gate 只使用 `NOT_STARTED / IN_PROGRESS / PASS / FAIL`。通过条件：已记录判断依据；若为冗余候选，已主动询问；`FRONT_ONLY_USER_APPROVED` 必须绑定明确用户原话与日期。未明确授权或表达含糊时，按 `KEEP_MULTI_VIEW` 处理。

## 材质迁移合同

| 部件 | Blender 预览材质 | Roblox 贴图 | 是否需独立 MeshPart |
|---|---|---|---|
|  |  | BaseColor / Metalness / Roughness / Normal / EmissionMask |  |

## 人工确认记录

| 日期 | Gate | 精确文件/合同 | 用户结论 | 下一状态 |
|---|---|---|---|---|
|  |  |  |  |  |

## 假设与未决项

| ID | 假设/问题 | 风险 | 负责人 | 截止 Gate |
|---|---|---|---|---|
| A1 |  |  |  |  |
