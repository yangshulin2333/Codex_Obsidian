---
type: workflow
domain: roblox
status: active
owner: mixed
source: self
created: 2026-08-13
updated: 2026-08-15
---

# VIEW_SET_CONTRACT 模板

> 每个部件单独复制。先通过 `VIEW_REDUNDANCY_GATE`，再通过 `PART_VIEW_CONTRACT_GATE` 明确本件的正式视图列表；可使用单正视图、用户声明的视图对/组或基础四视图。任何侧向或命名方向都使用 [[SIDE_VISIBILITY_CONTRACT_TEMPLATE]] 细化方向性结构。

## 部件身份

- 项目：
- Component ID / Role：
- 正式 `effect.png`：
- Front 定义：
- Length / Width / Thickness 轴：
- required / optional / deferred：

## VIEW_REDUNDANCY_GATE

- redundancy_candidate：YES / NO
- Codex 判断依据：
- 可能反例/信息损失：方向性装饰 / 非对称截面 / 厚度 / 孔槽 / 接口 / 其他
- Codex 主动询问原文：
- 用户决策：UNCONFIRMED / KEEP_MULTI_VIEW / FRONT_ONLY_APPROVED / CUSTOM_SET_APPROVED
- 用户明确原话与日期：
- view_mode：MULTI_VIEW / FRONT_ONLY_USER_APPROVED / USER_DECLARED_SET
- side_visibility_contract：REQUIRED / REQUIRED_PER_NAMED_SIDE / WAIVED_WITH_AUTHORIZATION
- Gate：NOT_STARTED / IN_PROGRESS / PASS / FAIL

`redundancy_candidate=YES` 不能自动推出 `front-only`。只有绑定明确用户原话与日期，才可填写 `FRONT_ONLY_USER_APPROVED` 或 `USER_DECLARED_SET`；其余情况均保持 `MULTI_VIEW`。

## PART_VIEW_CONTRACT_GATE

- view_set_authorization：UNCONFIRMED / FRONT_ONLY_APPROVED / CUSTOM_SET_APPROVED / DEFAULT_FOUR_VIEW
- 用户明确原话与日期：
- required_final_views：例如 `front.png`；或 `front.png / side_a_90.png`；或 `front.png / back.png / left.png / right.png`
- not_required_views：明确列出本次不入正式集的方向与已确认但仅作历史参考的文件
- semantic naming：`front / back / left / right / side_a_90 / side_b_90 / other`；不对称部件不得强行把 `Side A / Side B` 改名为 left/right
- view_count_expected：
- platform_view_count_supported：UNKNOWN / YES / NO；若 `NO`，只记录限制并等待用户决定，不复制、镜像或伪造缺失方向
- formal_reference_package_path：`{RUN_DIR}/00_formal_model_references/`
- formal_reference_manifest：`{RUN_DIR}/07_handoff/FORMAL_REFERENCE_SET.md`
- Gate：NOT_STARTED / IN_PROGRESS / PASS / FAIL

本 Gate 的通过条件是：`required_final_views`、`not_required_views`、逐图相机合同和用户授权均可追溯。此前生成或确认过、但不在本次 `required_final_views` 内的图只保留为历史参考，不能混入正式集。

## 几何证据与视图集

- primary_volume：板体 / 柱体 / 棱柱 / 体块 / 组合体
- CROSS_SECTION：
- END_PROFILE：
- near_end_face / side_wall：
- four_view_sufficient：UNKNOWN（P5A 前）/ YES / NO
- aux45_policy：`P5A_TRIGGER_ONLY`
- base_required_views：以 `required_final_views` 为准；经授权可为 front、明确的视图对/组或 front / back / left / right
- depth_bridge_decision：NOT_EVALUATED / NOT_REQUIRED / REQUIRED
- depth_bridge_trigger_evidence：
- proxy_gate：NOT_REQUIRED / IN_PROGRESS / PASS / FAIL
- proxy_path / SHA-256：
- proxy_purpose / user_conclusion：
- formal_attempt_budget_per_view：`2`

若 `FRONT_ONLY_USER_APPROVED` 的首轮模型暴露证据不足，必须重新取得用户授权并先升级成完整基础四视图；基础四视图完成并试模前，`left45/right45` 仍保持 N/A，不能从单正视图直接跳到辅助 45°。
- engineering_reference_views：axial / section / other
- 平台与版本：
- base platform_slot_mapping：
- auxiliary 45 platform_slot_mapping：
- 是否存在平台不接收、仅供 Blender/人工理解的视图：

## 逐文件合同与审批

| 文件 | projection / yaw / pitch / roll | must-visible | must-hidden | landmarks / 数量 / 位置 | platform slot | engineering only | attempt / failure code | canonical path / SHA-256 | 用户结论 / 日期 |
|---|---|---|---|---|---|---|---|---|---|
| front.png |  |  |  |  |  | no |  |  |  |
| back.png |  |  |  |  |  | no |  |  |  |
| left.png |  |  |  |  |  | no |  |  |  |
| right.png |  |  |  |  |  | no |  |  |  |
| left45.png | N/A until P5A trigger | N/A | N/A | N/A | N/A | no | N/A | N/A | N/A |
| right45.png | N/A until P5A trigger | N/A | N/A | N/A | N/A | no | N/A | N/A | N/A |
| `{custom_semantic_view}.png` |  |  |  |  |  |  |  |  |  |

按实际证据继续添加 top/bottom/axial/section 或具名 `Side A / Side B` 行。只保留/填写 `required_final_views` 的正式行，非 required 方向在上方 `not_required_views` 记录；不是只有 `FRONT_ONLY_USER_APPROVED` 才可减少视图。`left45/right45` 只有 P5A 触发并获用户确认后才从 N/A 改为正式合同；缺少可靠证据的视图不得为了凑数上传。工程补图必须标记 `engineering only=yes`，不能冒充平台标准槽位。

## 联系表与正式目录

- 单图全分辨率验收：PASS / FAIL
- 带准确文件名的联系表：
- 联系表用户结论与日期：
- project formal reference dir：`{RUN_DIR}/00_formal_model_references/`
- expected / actual formal reference file count：
- formal reference PNG list（`{component_role}_{semantic_view}.png`）：
- 每个正式文件的 user approval / source -> delivered mapping：
- base upload dir：`00_final_image_to_3d_upload`
- expected / actual base file count：
- actual base PNG list：
- auxiliary 45 upload dir：`01_auxiliary_45_upload` / NOT_CREATED
- expected / actual auxiliary file count：`0` 或 `2`
- actual auxiliary PNG list：
- upload union / slot mapping：
- 两个目录中是否仅含平台所需 PNG：
- object scale unchanged：PASS / FAIL
- translation-padding only：PASS / FAIL

项目正式参考集必须恰好等于上方 `required_final_views` 的已确认副本，且只含 PNG。平台基础包只能包含平台已接受的正式文件，实际数量以 `platform_view_count_supported` 和 slot mapping 为准。辅助目录若存在，必须恰好是 `left45.png/right45.png`；不把候选、工程图或未选视图混入任一正式目录。

## P5A 空间证据修复

- p5a_attempt / task ID：
- p5a_outcome：NOT_EVALUATED / PASS / BASE_VIEW_DEFECT / SPATIAL_BRIDGE_REQUIRED / GENERATOR_DRIFT
- evidence path：
- aux45_trigger approved by user / date：
- aux45_gate：NOT_TRIGGERED / IN_PROGRESS / PASS / FAIL
- regeneration task ID：
- regenerated P5A result：

## 汇总 Gate

- `view_contract_gate`：NOT_STARTED / IN_PROGRESS / PASS / FAIL / WAIVED
- `multiview_gate`：NOT_STARTED / IN_PROGRESS / PASS / FAIL / WAIVED
- `aux45_gate`：NOT_TRIGGERED / IN_PROGRESS / PASS / FAIL
- 证据：

只有当前部件全部 required 视图通过，才把该部件的 Gate 写为 `PASS`；项目总状态仍需等待全部 required 部件汇总通过。
