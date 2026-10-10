---
type: index
domain: roblox
status: active
owner: mixed
source: self
created: 2026-08-13
updated: 2026-08-15
---

# 高级武器模型制作工作流注册表

## Workflows

| Workflow | Spec | Status | Trigger | Primary actor | Last reviewed |
|---|---|---|---|---|---|
| 高级武器端到端总编排 | [[README]] | Review | 用户要求从立项做到 Studio | Codex + 用户 | 2026-08-14 |
| 新项目冷启动与案例隔离 | [[新武器_新对话启动模板]] | Review | 用户要求从零制作一把新武器 | Codex 提问 + 用户确认 P0 | 2026-08-14 |
| 立项与跨部件设计锁 | [[01_立项与跨部件设计锁]] | Review | 新武器 Brief | 用户 | 2026-08-13 |
| 共享对位区与接口合同 | [[JOINT_CONTRACT_TEMPLATE]] | Review | 拆件边界确认 | 用户 + Codex + Blender | 2026-08-13 |
| 视图冗余门 | [[VIEW_SET_CONTRACT_TEMPLATE#VIEW_REDUNDANCY_GATE]] | Review | 部件 front 确认 | Codex 提问 + 用户决策 | 2026-08-14 |
| 部件视图合同与正式参考打包 | [[VIEW_SET_CONTRACT_TEMPLATE#PART_VIEW_CONTRACT_GATE]] | Review | 用户确认部件所需视图后 | Codex + 用户 | 2026-08-15 |
| 截面/端面与 45° 空间桥接门 | [[02_部件多视图与AI生成#DEPTH_BRIDGE_GATE]] | Review | P5A 证明基础四视图无法解释体积过渡 | Codex 诊断 + 用户决策 | 2026-08-14 |
| 部件多视图与 AI 生成 | [[02_部件多视图与AI生成]] | Review | 部件拆分通过 | Codex + 用户 | 2026-08-14 |
| Blender 拼接、材质与导出 | [[03_Blender拼接材质与FBX导出]] | Review | AI 部件网格接收 | Codex + Blender | 2026-08-14 |
| 多零件导出副本与 FBX 合同 | [[../多零件模型转为roblox可导入文件/README]] | Review | `ASSEMBLY_APPROVED + MATERIAL_TRANSFER_READY` | Codex + Blender | 2026-08-14 |
| Studio 导入验收 | [[04_Roblox_Studio导入验收]] | Review | FBX 回导通过 | Codex + 用户 | 2026-08-14 |

## Components / Tools

| 组件或工具 | 参与工作流 | 权威说明 |
|---|---|---|
| 图像生成 | 效果图、部件图、多视图候选 | [[../Tripo多视图工作流/README]] |
| Tripo / 混元 3D | 单部件图生 3D | [[02_部件多视图与AI生成]] |
| 全视图合同 | 视图集合、槽位与逐图审批 | [[VIEW_SET_CONTRACT_TEMPLATE]] |
| 视图冗余门 | 识别高重复视图、主动询问并记录 front-only 授权 | [[VIEW_SET_CONTRACT_TEMPLATE#VIEW_REDUNDANCY_GATE]] |
| 侧向合同 | left/right/45° 方向与遮挡 | [[SIDE_VISIBILITY_CONTRACT_TEMPLATE]] |
| 单相机视图合同 | 自定义 Side A/B、严格 90° 正交、关键立体侧向剪影 | [[SIDE_VISIBILITY_CONTRACT_TEMPLATE#每张严格侧向图的单相机合同]] |
| 正式参考集 | 用户确认图的项目级干净目录、语义唯一命名与 source -> delivered 映射 | [[EXPORT_MANIFEST_TEMPLATE#正式建模参考集（P4 / 项目级交付）]] |
| 低成本几何 Proxy | 只验证截面、端面、侧壁、中央机构投影和相机；不得进入正式上传目录 | [[02_部件多视图与AI生成#正式生图预算与停止条件]] |
| JOINT 合同 | 对位区、FRONT、所有权、防转、插入、清理和导出唯一性 | [[JOINT_CONTRACT_TEMPLATE]] |
| Blender | 拼接、清理、材质、导出 | [[03_Blender拼接材质与FBX导出]] |
| 多零件 Blender 直导 | P8 权威执行入口：对象白名单、公共 Pivot、`0/0/1`、单位、真实贴图、`Copy + Embed` 与回导 | [[../多零件模型转为roblox可导入文件/README]] |
| 单体下载包兼容脚本 | 伪 FBX、`.fbm`、GLB 与旧模型包转换 | [[../Roblox 可直接导入版打包流程/README]] |
| Roblox Studio | 导入、焊接和游戏相机验收 | [[04_Roblox_Studio导入验收]] |

## User Journey

```text
提出武器想法
-> 看并确认完整效果图
-> 确认拆件和每个部件
-> 确认每个接口的共享对位区与唯一最终所有者
-> Codex 判断视图是否高度重复并主动询问；用户决定单正视图、具名自定义视图集或多视图
-> 确认基础视图包中的每个视图
-> 首轮审核 AI 3D 部件
-> 若 P5A 证明空间过渡证据不足，用户确认后补左右 45°，只重生成该部件
-> 在 Blender 确认拼接和材质
-> 建立 EXPORT_COPY、导出 FBX 并空场景回导
-> 在 Studio 确认最终模型
```

用户只对视觉和用途做决策，不需要手工追踪临时路径、哈希和导出统计。

## State Map

| 状态 | 进入条件 | 退出条件 | 可回退到 |
|---|---|---|---|
| `DRAFT` | 新项目 | Brief 通过 | — |
| `MASTER_EFFECT_APPROVED` | 整体图确认 | 拆件通过 | `DRAFT` |
| `JOINT_CONTRACT_APPROVED` | 全部接口 P2J 通过 | 部件效果图与多视图 | `COMPONENT_SPLIT_LOCKED` |
| `VIEW_REDUNDANCY_GATE_APPROVED` | 全部 required 部件已记录 view_mode；front-only 均有明确授权 | 正式视图包 | `COMPONENT_IMAGES_APPROVED` |
| `MULTIVIEW_APPROVED` | 全部 required 部件按已批准 view_mode 完成正式视图包；授权 front-only 可用 WAIVED 汇总 | AI 网格接收 | 单视图候选或单部件视图包 |
| `AI_MESH_ACCEPTED` | 全部 required 部件通过 P5A/P5B | Blender 装配确认 | 单部件生成 |
| `ASSEMBLY_APPROVED` | 正/侧/3Q 通过 | 材质迁移就绪 | WORK_CLEAN 检查点 |
| `MATERIAL_TRANSFER_READY` | 材质目标和可迁移贴图清单通过 | 建立导出副本 | WORK_CLEAN |
| `EXPORT_COPY_READY` | 对象白名单、公共 Pivot、单一单位、逐件 `0/0/1` 与 P8J 通过 | FBX 导出 | EXPORT_COPY 检查点 |
| `FBX_EXPORTED` | `Copy + Embed` FBX、贴图事实源、SHA-256 和设置快照存在 | 空场景回导 | EXPORT_COPY |
| `FBX_REIMPORT_VERIFIED` | 回导与 Manifest 一致 | Studio 验收 | EXPORT_COPY |
| `STUDIO_ACCEPTED` | 导入队列、资产、Root/Weld、碰撞、Play 与游戏相机全部通过 | 归档或另开玩法/VFX | Studio |

部件级修复子状态：`VIEW_EVIDENCE_REPAIR`。它只在 `p5a_outcome=SPATIAL_BRIDGE_REQUIRED` 且用户批准后进入；`AUX45_APPROVED -> AI_MESH_REGENERATED -> P5A`。它不是项目汇总状态，也不能直接推进 `AI_MESH_ACCEPTED`。

## 维护规则

- 新阶段、真实故障或专项工作流变化时，同步更新本注册表和 [[FAILURE_CODES]]。
- 新项目必须先走 [[新武器_新对话启动模板]]；案例参数不跨项目继承。
- 状态未经过另一把武器复验前保持 `Review`。
- VFX 不静默塞回主流程；如要建立，新增独立工作流和验收标准。
- 表中状态都是项目汇总状态；单部件通过只更新 `RUN_STATE.md` 的部件 Gate。
- `front-only` 不是默认优化：Codex 必须先主动询问，只有明确用户授权才能在该部件上生效；授权不跨部件。
- 每件正式图的数量和语义由 `required_final_views / not_required_views` 与用户原话决定；允许明确授权的自定义视图对/组，但不允许以平台槽位为由复制、翻转或镜像补数。
- 严格侧视必须写明 `camera_count=1 / projection=ORTHOGRAPHIC / yaw / pitch / roll`。关键立体结构的侧向轮廓与真实厚度属于合同，不因 90° 相机而默认消失。
- 项目级 `00_formal_model_references/` 只保存用户确认的正式 PNG；平台上传包与它分离，并通过 Manifest 映射、数量和哈希复核。
- front-only 首轮证据不足时，先重新询问并升级为基础四视图；四视图试模前不得进入辅助 45° 修复分支。
- 6 视图不是高级武器默认数量：基础四视图与 P5A 触发的辅助 45° 对分开建包、分开审计，提交时才按平台槽位组合 `4 + 2`。
- 两份 45° 合同都通过后可并行生成，但必须是独立任务、最小参考集和逐文件验收；同一视图连续两次正式失败后停止盲目重试。
- 已完成语义分件的 Blender 装配必须走多零件直导入口，不得交给旧版单体下载包兼容脚本。
