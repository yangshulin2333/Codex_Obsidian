---
type: workflow
domain: roblox
status: active
owner: mixed
source: self
created: 2026-08-13
updated: 2026-08-15
---

# 高级武器 RUN_STATE 模板

> 复制到运行目录 `00_brief/RUN_STATE.md`。它是新对话唯一继续入口，不能只依赖聊天记录。

## 当前项目

- 项目名：
- run_mode：`NEW_PROJECT / RESUME`
- 输入来源：
- inherited_case_parameters：`FORBIDDEN / EXPLICITLY_AUTHORIZED`；授权字段与原话：
- 运行目录：
- 当前状态：`DRAFT`
- 当前 Gate：
- 最后更新时间：
- 下一步唯一动作：
- required 部件数：
- 当前 Gate 已通过 required 部件数：
- 未通过/阻塞的 required 部件：

## 状态机

```text
DRAFT
-> BRIEF_READY
-> MASTER_EFFECT_APPROVED
-> COMPONENT_SPLIT_LOCKED
-> JOINT_CONTRACT_APPROVED
-> COMPONENT_IMAGES_APPROVED
-> VIEW_REDUNDANCY_GATE_APPROVED
-> SIDE_VISIBILITY_CONTRACT_APPROVED
-> MULTIVIEW_APPROVED
-> AI_MESH_ACCEPTED
-> ASSEMBLY_APPROVED
-> MATERIAL_TRANSFER_READY
-> EXPORT_COPY_READY
-> FBX_EXPORTED
-> FBX_REIMPORT_VERIFIED
-> STUDIO_ACCEPTED
-> ARCHIVED
```

`MULTIVIEW_APPROVED -> AI_MESH_ACCEPTED` 之间必须逐部件执行 P5A/P5B。任一部件若为 `SPATIAL_BRIDGE_REQUIRED`，其局部状态走 `VIEW_EVIDENCE_REPAIR -> AUX45_APPROVED -> AI_MESH_REGENERATED -> P5A`；该回路没有重新通过前，项目总状态停留在 `MULTIVIEW_APPROVED`，不能提前写 `AI_MESH_ACCEPTED`。

## Canonical 文件

| 类型 | 精确路径 | SHA-256 | 状态 |
|---|---|---|---|
| PROJECT_LOCK |  |  |  |
| master_effect |  |  |  |
| formal model reference set |  |  |  |
| formal reference manifest |  |  |  |
| component base package |  |  |  |
| component auxiliary 45 package | NOT_CREATED | N/A | NOT_TRIGGERED |
| WORK_CLEAN blend |  |  |  |
| EXPORT blend |  |  |  |
| FBX |  |  |  |
| EXPORT_MANIFEST |  |  |  |
| Studio evidence |  |  |  |

## 部件状态

| ID / Role | required / optional / deferred | effect_gate | view_mode | redundancy_gate | side_visibility_gate | view_contract_gate | multiview_gate | ai_mesh_gate | Blender | material | Studio | 证据/阻塞 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
|  | required | NOT_STARTED | UNCONFIRMED | NOT_STARTED | NOT_STARTED | NOT_STARTED | NOT_STARTED | NOT_STARTED |  |  |  |  |

Gate 枚举：`NOT_STARTED / IN_PROGRESS / PASS / FAIL / WAIVED`。

项目汇总规则：只有全部 `required` 行的对应 Gate 满足本段规则，才能推进项目总状态。`redundancy_gate` 必须全部为 `PASS` 才能进入 `VIEW_REDUNDANCY_GATE_APPROVED`。`MULTI_VIEW` 部件的 `side_visibility_gate` 与 `multiview_gate` 必须为 `PASS`；`FRONT_ONLY_USER_APPROVED` 可写 `side_visibility_gate=WAIVED`、`multiview_gate=WAIVED`；`USER_DECLARED_SET` 则必须逐张通过命名方向的相机与可见性合同。后两类都必须在下表绑定明确授权证据。全部部件完成各自声明的正式视图包后，项目才进入 `SIDE_VISIBILITY_CONTRACT_APPROVED / MULTIVIEW_APPROVED`。单部件通过只更新本表，不直接推进项目总状态。

## 部件级视图证据状态

| Component ID / Role | view_set_mode | cross_section_end_profile_gate | base upload dir / count | p5a_outcome | aux45_gate | auxiliary dir / count | regeneration_task_id | 当前结论 |
|---|---|---|---|---|---|---|---|---|
|  | FRONT_ONLY / USER_DECLARED_SET / FOUR_VIEW | NOT_STARTED |  | NOT_EVALUATED | NOT_TRIGGERED | NOT_CREATED |  |  |

- `view_set_mode` 不预设 SIX_VIEW；`USER_DECLARED_SET` 必须在 `PART_VIEW_CONTRACT_GATE` 记录 `required_final_views / not_required_views / 用户原话`，不能只写数量。辅助 45° 通过独立 `aux45_gate` 追加到基础四视图。
- `p5a_outcome`：`NOT_EVALUATED / PASS / BASE_VIEW_DEFECT / SPATIAL_BRIDGE_REQUIRED / GENERATOR_DRIFT`；首轮 P5A 前只能写 `NOT_EVALUATED`。
- `aux45_gate`：`NOT_TRIGGERED / IN_PROGRESS / PASS / FAIL`。
- `VIEW_EVIDENCE_REPAIR` 是当前部件的修复子状态，不推进或覆盖项目总状态。

## P5A 尝试与空间证据修复记录

| 尝试 | 日期 | Component | 平台 / task ID | 输入 Manifest | p5a_outcome | 证据路径 | 用户是否批准补图 | aux45 合同/目录 | 下一动作 / 结果 |
|---|---|---|---|---|---|---|---|---|---|
| 1 |  |  |  |  |  |  | N/A | N/A |  |

首轮若为 `SPATIAL_BRIDGE_REQUIRED`，先记录证据并取得用户批准，再锁定 `left45/right45`。重生成后新增下一行并重新执行 P5A；没有通过 P5A/P5B 前，项目不得进入 `AI_MESH_ACCEPTED`。

## VIEW_REDUNDANCY_GATE 审批记录

| 日期 | Component ID / Role | 候选依据 | Codex 提问原文 | 用户决策与原话 | required_final_views / not_required_views | 正式目录 | 结果 |
|---|---|---|---|---|---|---|---|
|  |  |  |  | KEEP_MULTI_VIEW / FRONT_ONLY_APPROVED / CUSTOM_SET_APPROVED： |  |  | NOT_STARTED |

未明确授权时不得填写 `FRONT_ONLY_USER_APPROVED` 或 `USER_DECLARED_SET`；用户没有回答、只说“继续”或描述“看起来差不多”均按 `KEEP_MULTI_VIEW`。项目级正式参考集还须记录唯一语义文件名、源文件哈希、交付副本哈希和每张图的确认结论。

## 接口状态

| JOINT_ID | From -> To | joint_contract_gate | joint_rebuild_gate | joint_export_gate | final_surface_owner | proxy_copy | 证据/阻塞 |
|---|---|---|---|---|---|---|---|
| JOINT_A |  | NOT_STARTED | NOT_STARTED | NOT_STARTED |  |  |  |

接口 Gate 使用：`NOT_STARTED / IN_PROGRESS / PASS / FAIL`。全部接口 `joint_contract_gate=PASS` 才能进入 `JOINT_CONTRACT_APPROVED`；P6 装配确认前全部 `joint_rebuild_gate=PASS`；FBX 导出前全部 `joint_export_gate=PASS`。

## 人工审批记录

| 日期 | Gate / 文件 | 用户原话或精确结论 | 影响 |
|---|---|---|---|
|  |  |  |  |

## 镜像/几何复用授权

| 日期 | 资产/部件 | source -> target | 用户授权原文 |
|---|---|---|---|
| 无 |  |  |  |

## 失败与恢复

| 时间 | 失败码 | 精确对象/文件 | 原因 | 恢复动作 | 结果 |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

## Blender 状态

- SOURCE_HIGH：
- 最新 WORK_CLEAN：
- 最新检查点：
- 最新 EXPORT_COPY：
- selected_object_whitelist：
- root_part：
- common_pivot_definition / coordinates：
- unit_strategy / conversion_applied_at：
- 逐件 Transform 审计：`Location=0 / Rotation=0 / Scale=1`；证据：
- Parent / Constraint / Delta Transform 处理：
- 真实贴图格式/扩展名审计：
- `Copy + Embed` 状态：
- EXPORT_COPY_READY：`PASS / FAIL / NOT_RUN`
- 材质迁移状态：basecolor-only / PBR maps / pending
- 已知拓扑风险：
- JOINT 合同目录：
- 未删除代理/重复表面：无 / 有，列表：

## FBX 回导报告

- FBX：
- FBX bytes / SHA-256：
- FBX_EXPORTED：`PASS / FAIL / NOT_RUN`
- 导出设置快照：
- 期望/实际 Mesh 数：
- 期望/实际总尺寸：
- 期望/实际三角面：
- 每 Mesh 材质数：
- 贴图声明扩展名 / 检测编码 / 内部引用 / Embedded：
- 公共 Pivot / 是否无需重新对位：
- 多余对象类型：
- FBX_REIMPORT_VERIFIED：`PASS / FAIL / NOT_RUN`
- 偏差与恢复动作：

## Studio 状态

- Project / Place：
- Creator：
- Model 路径：
- studio_mode：display / tool / npc
- mutation_authorized_by_user：NO / YES；原文/日期：
- PrimaryPart：
- anchored_policy：
- Weld：
- Collision / Massless：
- 材质：
- import_queue_status：`PASS / FAIL / NOT_RUN`
- Mesh / Texture asset IDs：
- Play scatter test：`PASS / FAIL / NOT_RECORDED`
- 正/侧/3Q 截图：
- 用户结论原话/日期：
- STUDIO_ACCEPTED：`PASS / FAIL / NOT_RUN`

## 边界

- 动画：不在本运行 / 单独任务
- VFX：不在本运行 / 单独任务
- 伤害与技能：不在本运行 / 单独任务

## 新对话继续指令

```text
先判断 run_mode：
- NEW_PROJECT：改读“新武器_新对话启动模板.md”，从 P0 开始，禁止继承案例参数。
- RESUME：按下列顺序继续。

先读取：
1. 高级武器模型制作/README.md
2. 本 RUN_STATE.md
3. PROJECT_LOCK.md
4. 当前 Gate 对应专项文件

若当前 Gate 为 P8/P9，还必须读取：
5. 高级武器模型制作/03_Blender拼接材质与FBX导出.md
6. 多零件模型转为roblox可导入文件/README.md

只执行“下一步唯一动作”；不要重新解释已确认设计，不要读取失败候选作为新母版。
```
