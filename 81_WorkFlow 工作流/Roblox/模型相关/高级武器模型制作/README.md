---
type: workflow
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-08-13
updated: 2026-08-15
---

# Roblox 高级武器模型制作工作流

## 定位

这是一套把“武器想法”推进为 Roblox Studio 可验收模型的端到端总编排流程，适用于由多个独立部件组成、需要按部件判断单正视图或多视图、AI 图生 3D、Blender 拼接和材质整理的高级风格化武器。

```text
立项
-> 完整武器效果图
-> 拆件与连接合同
-> 共享对位区与接口合同门
-> 各部件效果图
-> VIEW_REDUNDANCY_GATE（单正视图或多视图）
-> 各部件正式视图包
-> Tripo / 混元 3D 生成
-> Blender 拼接、清理与材质
-> 导出专用副本与 FBX
-> FBX 回导验证
-> Roblox Studio 导入与模型验收
```

本工作流是**总编排层**，不替代已有的专项执行规范：

- 多视图相机、厚度、轴向证据和侧向可见性：[[../Roblox 魔法剑模型制作工作流/README|Roblox 魔法剑模型制作工作流]]。
- 四视图逐张审核、候选目录与正式上传目录：[[../Tripo多视图工作流/README|Tripo 多视图工作流]]。
- 画布和主体归一化：[[../Roblox 通用游戏素材道具制作工作流/NORMALIZATION_CONTRACT|归一化合同]]。高级武器正式视图调用该合同时只允许 `measure-only / padding-only`：保持主体像素尺度，只测量、平移和补纯色边；本工作流明确覆盖其中任何自动缩放、逐图缩放或非等比归一化行为。
- AI 网格清理与局部纹理修复：[[../Roblox 武器模型制作工作流/Tripo武器低模清理与局部纹理修复流程|Tripo 武器低模清理与局部纹理修复流程]]。
- 已完成 Blender 装配、需要保留多个独立 MeshPart：[[../多零件模型转为roblox可导入文件/README|多零件模型转为 Roblox 可导入文件]]。
- 下载站单体模型包、伪 FBX、`.fbm` 与 GLB 兼容打包：[[../Roblox 可直接导入版打包流程/README|Roblox 可直接导入版打包流程]]。

## 当前版本

- 版本：`1.5`
- 规格状态：`Review`
- 实测依据：[[猫猫剑案例复盘]]、[[冰晶战锤45度空间桥接复盘]]、[[../多零件模型转为roblox可导入文件/案例_猫猫剑与冰晶战锤|猫猫剑与冰晶战锤多零件导出案例]]
- 当前导出证据：冰晶战锤 v04 已由用户确认能进入 Studio；这证明导入层通过，不自动替代 Root、Weld、碰撞和 Play 的 P9 运行验收。
- 升级为 `Approved` 的条件：使用本文件从零完成第三把拆件型武器，并把新偏差写回流程。

## 新项目冷启动与案例隔离

新对话开始新武器时，必须先读 [[新武器_新对话启动模板]]，并使用 `run_mode=NEW_PROJECT`。P0 之前不得生成效果图，也不得从历史案例复制设计参数。

允许复用的是 Gate、命名、目录、导出和验收规则；禁止默认继承：

- 猫猫剑或冰晶战锤的拆件数量、部件名、比例、目标 Stud、三角面和贴图预算。
- 历史 Front、长/宽/厚轴、接口方向、Root、Pivot、Studio 路径和锚定方式。
- 历史 front-only、镜像、四视图或 `4 + 2` 授权。

未知字段一律写 `UNCONFIRMED`。案例文件只用于故障和决策证据，不是第三把武器的参数母版。

## 范围边界

### 本流程包含

- Roblox RPG 武器的视觉立项、比例和拆件。
- 面向 Tripo、混元 3D 等平台的几何参考图。
- 独立部件按已声明的正式视图清单生成：可为经授权的单正视图、用户明确锁定的自定义视图对/组，或基础四视图；另有 P5A 证据触发的左右 45° 辅助图和可选顶底工程证据。
- AI 3D 网格的接收、Blender 拼接和材质整理。
- 导出专用副本、FBX / 贴图包和回导验证。
- Studio 中的 MeshPart、焊接、碰撞和游戏相机验收。

### 本流程明确不包含

- 攻击、待机、装备动画。
- `Trail`、`Beam`、`ParticleEmitter`、动态灯光和命中特效。
- 武器伤害、Remote、技能、状态机和运行时代码。
- 游戏商城、定价、购买按钮和商业化逻辑。

运行时表现必须在 `STUDIO_ACCEPTED` 之后另立任务。不得为了“顺便看效果”把特效混入模型主流程；出现时记录 `VFX_SCOPE_CREEP`。

## 核心原则

1. **先确认整体，再拆件。** 没有完整武器效果图，就无法判断各部件的比例与装配关系。
2. **参考图是几何输入，不是宣传插画。** 不要角色、场景、烟雾、粒子、速度线和大面积发光。
3. **每个部件独立生成 3D。** 不把多个零件混在同一次单物体生成任务中。
4. **相机方向优先于“是否对称”。** `left` 与 `right` 是两个观察合同，绝不根据外观默认镜像。
5. **先块模、后精调。** 在 Blender 先锁定主轴、比例、厚度和接口，再调整材质与细节。
6. **预览材质不等于可迁移材质。** Blender 程序节点不会自动完整进入 Roblox。
7. **导出成功不等于交付成功。** FBX 必须回导验证，随后还要在 Studio 的实际游戏相机中验收。
8. **所有大操作可回退。** 原始 AI 模型只读，工作版和导出版分离；每个阶段只回退到最近一个已确认门。
9. **共享对位不等于重复导出。** 两个部件可使用同一共享对位区做粗定位，但精确接口必须在 Blender 重建；可见共享外壳只有一个最终所有者，代理副本不得进入 `EXPORT_COPY`。
10. **视图数量与名称只能由部件合同决定。** 当部件近似轴对称或四向几何信息高度重复时，Codex 可主动建议单正视图；用户也可明确锁定如 `front + side_a_90` 的自定义正式视图集。未绑定用户原话、日期、`required_final_views` 和 `not_required_views` 前，不得减少、补猜或默认镜像任何方向。
11. **四视图是常见多视图基础包，不是每件的固定数量。** 左右 45° 仍是 P5A 触发的条件式空间桥接证据；不因“高级武器”默认生成六视图。只有基础证据送入 AI 3D 后，P5A 证明端面、侧壁或正面机构之间的体积过渡仍被错误猜测，才进入部件级 `VIEW_EVIDENCE_REPAIR`，经用户确认后补 `left45/right45`。
12. **正式参考集与平台上传包分离。** 用户确认过的图先按唯一语义文件名汇总到项目级 `00_formal_model_references/`；候选、联系表、提示词和未选视图不得混入。平台是否接受该部件的图数/槽位另行在 Manifest 中验证，不能通过复制、翻转或伪造缺失方向凑数。
13. **Blender 必须完成装配坐标，Studio 不重新拼位置。** 多零件导出前锁定正式对象白名单、共同 Pivot、唯一单位策略和逐件 `Location=0 / Rotation=0 / Scale=1`；FBX 只负责传递已完成的装配。

## 参与者与职责

| 参与者 | 负责 | 不负责 |
|---|---|---|
| 用户 | 审美、比例、拆件、逐视图可见性、最终模型确认 | 猜测脚本和文件状态 |
| Codex | 结构化提问、提示词、文件整理、Blender/导出/验证自动化、记录 | 擅自决定左右视图或批准自己的候选 |
| 图像生成模型 | 生成候选参考图 | 设计裁决、尺寸合同 |
| Tripo / 混元 3D | 根据正式视图生成单部件网格 | 推断未提供的连接工程结构 |
| Blender | 拼接、清理、材质、贴图烘焙、导出 | 替代用户的视觉确认 |
| Roblox Studio | 进口、装配、游戏相机和运行环境验收 | 还原未烘焙的 Blender 程序节点 |

## 总状态机

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

规则：

- 当前状态、正式文件和审批证据写入 [[RUN_STATE_TEMPLATE]] 的运行副本。
- 总状态是**全项目汇总状态**，不是当前单部件状态。各部件分别记录 `effect_gate / redundancy_gate / view_mode / side_visibility_gate / view_contract_gate / multiview_gate / ai_mesh_gate`。`MULTI_VIEW` 要求侧向与多视图 Gate 为 `PASS`；`FRONT_ONLY_USER_APPROVED` 与 `USER_DECLARED_SET` 必须附用户原话、`required_final_views` 和逐图合同。全部 `required` 部件满足对应分支后才推进总状态。
- `MULTIVIEW_APPROVED` 为兼容既有文件名保留的项目状态，实际含义是“全部部件的已声明正式视图包通过”。它允许经授权的单正视图与自定义视图对/组，不要求每个部件恰好 1 张或 4 张。
- `optional / deferred` 部件必须在拆件确认门锁定；不得为了绕过失败而临时把 `required` 部件降级。
- 未通过当前门，不得创建下一阶段的正式交付目录。
- 单图失败只回退该图；单部件失败只回退该部件；导入失败只删除本轮导入副本。
- “确认”必须绑定准确文件名或明确标注的单图；两张无标签图片不能形成有效确认。

P5A 内部使用下列**部件级修复回路**，不新增项目级汇总状态：

```text
MULTIVIEW_APPROVED
-> AI_MESH_TRIAL / P5A
   ├─ PASS -> P5B
   ├─ BASE_VIEW_DEFECT -> 只修异常基础图 -> MULTIVIEW_APPROVED -> 重新试模
   └─ SPATIAL_BRIDGE_REQUIRED
      -> VIEW_EVIDENCE_REPAIR
      -> AUX45_CONTRACT_LOCKED
      -> AUX45_APPROVED
      -> AI_MESH_REGENERATED
      -> 回到 P5A
```

`VIEW_EVIDENCE_REPAIR` 只更新当前部件的 `p5a_outcome / aux45_gate / regeneration_task_id`。没有通过新一轮 P5A/P5B 前，不得写入项目级 `AI_MESH_ACCEPTED`。

## 阶段总表

| 阶段 | 主要产物 | 人工门 | 通过后状态 |
|---|---|---|---|
| P0 立项 | `PROJECT_LOCK.md` 初稿 | 用途、平台、风格、预算 | `BRIEF_READY` |
| P1 完整效果图 | `master_effect_vNN.png` | 轮廓、比例、主色、部件位置 | `MASTER_EFFECT_APPROVED` |
| P2 拆件 | 部件清单、装配轴、接口索引 | 部件边界 | `COMPONENT_SPLIT_LOCKED` |
| P2J 共享对位区与接口 | 每接口 `JOINT_<ID>.md` | 对位区、FRONT、所有者、代理、防转、插入和删除项 | `JOINT_CONTRACT_APPROVED` |
| P3 部件效果图 | 每个部件的 `effect.png` | 逐件造型 | `COMPONENT_IMAGES_APPROVED` |
| P3V 视图冗余门 | 每件 `view_mode`、提问与用户原话 | 是否明确授权单正视图 | `VIEW_REDUNDANCY_GATE_APPROVED` |
| P4 基础正式视图包 | 每件按 `required_final_views` 生成；顶底工程证据另列 | 单图或逐视图与联系表 | `MULTIVIEW_APPROVED` |
| P5A AI 3D 视觉验收与证据修复 | 每件原始模型、检查截图；必要时独立 `left45/right45` 辅助包 | 判断 PASS / BASE_VIEW_DEFECT / SPATIAL_BRIDGE_REQUIRED；补图须再确认 | 单部件 `ai_mesh_gate=IN_PROGRESS` |
| P5B AI -> Blender 交接审计 | 来源、统计、贴图、已知缺陷 | 源文件可追溯且可安全进入工作版 | 全部 required 部件通过后 `AI_MESH_ACCEPTED` |
| P6 Blender 拼接 | `*_WORK_CLEAN_vNN.blend` | 正、侧、3/4 装配 | `ASSEMBLY_APPROVED` |
| P7 材质迁移 | 贴图清单与材质验收图 | Blender 与 Roblox 目标观感 | `MATERIAL_TRANSFER_READY` |
| P8A 导出副本 | `*_ROBLOX_EXPORT.blend`、对象白名单、公共 Pivot、单位/变换审计 | 逐件 `0/0/1`、装配位置不变、P8J 通过 | `EXPORT_COPY_READY` |
| P8B FBX 导出 | 真实 PNG/JPG、FBX、SHA-256、设置快照 | 每 Mesh 一材质、`Copy + Embed`、内部贴图引用有效 | `FBX_EXPORTED` |
| P8C 空场景回导 | 回导报告与截图 | 数量、名称、尺寸、方向、材质、贴图、公共 Pivot | `FBX_REIMPORT_VERIFIED` |
| P9 Studio | Model、MeshPart、焊接、截图 | 游戏相机中的最终模型 | `STUDIO_ACCEPTED` |
| P10 归档 | Manifest、状态、案例偏差 | 交付完整性 | `ARCHIVED` |

分阶段细则：

- [[01_立项与跨部件设计锁]]
- [[02_部件多视图与AI生成]]
- [[03_Blender拼接材质与FBX导出]]
- [[04_Roblox_Studio导入验收]]

## 标准运行目录

```text
{RUN_DIR}/
├─ 00_brief/
│  ├─ PROJECT_LOCK.md
│  ├─ RUN_STATE.md
│  └─ joints/
│     └─ JOINT_<ID>.md
├─ 00_formal_model_references/
│  └─ {component_role}_{semantic_view}.png
├─ 01_master_effect/
│  ├─ _candidates/
│  └─ master_effect.png
├─ 02_components/
│  └─ {component_id}_{component_name}/
│     ├─ effect.png
│     ├─ _docs/
│     ├─ _candidates/
│     ├─ _checks/
│     ├─ 00_final_image_to_3d_upload/
│     └─ 01_auxiliary_45_upload/   # 仅 P5A 触发后创建
├─ 03_ai_mesh_source/
│  └─ {component_id}_{component_name}/
├─ 04_blender/
│  ├─ SOURCE_HIGH/
│  ├─ WORK_CLEAN/
│  └─ EXPORT_COPY/
├─ 05_roblox_import_package/
│  ├─ Weapon_vNN.fbx
│  ├─ textures/
│  ├─ EXPORT_MANIFEST.md
│  └─ README_导入说明.md
├─ 06_studio_checks/
└─ 07_handoff/
   └─ FORMAL_REFERENCE_SET.md
```

目录纪律：

- `_candidates` 保存候选；`_checks` 保存联系表和标注图；`_docs` 保存合同和提示词。
- `00_formal_model_references` 是项目级干净正式参考集：只含用户已确认、在 `FORMAL_REFERENCE_SET.md` 映射过的 PNG，文件名必须包含部件角色和语义视图，避免多个 `front.png` 冲突。
- `00_final_image_to_3d_upload` 是平台级输入包：只含当前平台接受且 Manifest 标注为 `platform_input=yes` 的正式 PNG。数量由该部件的 `required_final_views` 与平台槽位共同决定；平台不支持的自定义视图集不得靠复制、镜像或候选图补数。
- `01_auxiliary_45_upload` 仅在 P5A 判定 `SPATIAL_BRIDGE_REQUIRED` 且用户批准后创建，恰好只含 `left45.png/right45.png`。平台提交清单可组合基础 `4 + 2`，但物理目录保持分离；本流程不使用外部工作流的“六张混在一个正式目录”模式。
- 已确认文件不得原地覆盖。修改时生成新版本，经确认后更新 Manifest 和 SHA-256。
- 外部生成图片必须复制到稳定项目路径后再确认；不能把临时会话路径当长期设计锁。
- 两个部件图中的共享对位区是装配代理；最终可见表面所有权与删除规则以 `JOINT_<ID>.md` 为准。

## 五个硬交接合同

### H1：整体设计 -> 部件生产

```text
PAYLOAD:
  master_effect: canonical file
  component_manifest: IDs, roles, ratios
  assembly_axis: length/width/thickness axes
  joint_contracts: JOINT_ID, shared datum, FRONT, final owner, proxy, anti-rotation, insertion depth, cleanup
SUCCESS: user approved split and all required JOINT contracts
FAILURE: COMPONENT_SPLIT_NOT_LOCKED / JOINT_CONTRACT_INCOMPLETE -> return to P2/P2J
```

### H2：部件正式视图包 -> 图生 3D 平台

```text
PAYLOAD:
  required_final_views / not_required_views and exact approved PNG set
  auxiliary_45_views: exact pair or NOT_TRIGGERED
  cross_section and end_profile
  view_mode: FRONT_ONLY_USER_APPROVED / USER_DECLARED_SET / MULTI_VIEW
  view_set_authorization: exact user quote/date
  formal_reference_manifest and source -> delivered hash mapping
  platform input slot mapping / accepted count
  p5a_attempt / p5a_outcome / aux45_trigger_evidence
  formal_imagegen_attempts_by_view
  clean background
  same component identity
  per-file camera contract
SUCCESS: platform accepts one component task
FAILURE: VIEW_REDUNDANCY_GATE_SKIPPED / FRONT_ONLY_NOT_AUTHORIZED / FINAL_DELIVERY_FOLDER_DIRTY / AUXILIARY_45_PACKAGE_DIRTY / VIEW_SET_IDENTITY_MISMATCH
```

### H3：AI 3D -> Blender

```text
PAYLOAD:
  one source model per component
  joint proxy inventory and final surface owner
  source platform and task/version
  texture files
  known defects
SUCCESS: source files copied into SOURCE_HIGH and opened read-only
FAILURE: AI_MESH_GEOMETRY_DRIFT -> regenerate only that component
```

### H4：Blender -> FBX 包

```text
PAYLOAD:
  approved assembly
  selected_object_whitelist and stable ASCII part names
  root_part and common_pivot
  unit_strategy: exactly one
  target length
  per-part transform: Location=0 / Rotation=0 / Scale=1
  one transferable material set per exported Mesh
  texture real format, extension, path and SHA-256
  export-only copy
  JOINT uniqueness report
  FBX settings snapshot: Selected Mesh / Scale 1 / FBX Unit Scale / -Z,Y / Copy+Embed / no animation
SUCCESS:
  P8A -> EXPORT_COPY_READY
  P8B -> FBX_EXPORTED
  P8C empty-scene round trip -> FBX_REIMPORT_VERIFIED
FAILURE: REFERENCE_PLANE_EXPORTED / PART_ORIGIN_MISMATCH / PART_TRANSFORM_NOT_BAKED / MULTIPLE_SCALE_STRATEGIES / TEXTURE_FILE_FORMAT_MISMATCH / FBX_EMBED_TEXTURES_DISABLED / FBX_ROUNDTRIP_FAILED
```

P8 的权威手工执行规范是 [[../多零件模型转为roblox可导入文件/README|多零件模型转为 Roblox 可导入文件]]。这是必读 Gate，不是可选参考；旧版单体下载包兼容脚本不得处理已经完成语义分件的 Blender 装配。

### H5：FBX 包 -> Studio

```text
PAYLOAD:
  FBX verified by reimport
  FBX SHA-256 and selected object manifest
  expected part count, names, dimensions and triangles
  texture/PBR maps
  importer settings
NORMAL INPUT: select the final FBX only; external textures are evidence/fallback, not a second required import input
SUCCESS: import queue succeeds; Studio model matches the manifest; root/Weld/Play checks pass; user confirms
FAILURE: STUDIO_PART_COUNT_MISMATCH / FBX_DIMENSION_MISMATCH / STUDIO_TEXTURE_UPLOAD_FAILED / STUDIO_IMPORT_FAILED_UNCLASSIFIED
```

## 人工与自动边界

### 必须由用户确认

- 完整效果图和部件拆分。
- 每个部件的正面设计锁。
- 当 Codex 判断视图高度重复时，是否明确授权该部件改用单正视图或某个具名自定义视图集。
- `required_final_views` 中每张图的可见、隐藏、数量、位置、遮挡与单相机合同；已授权单正视图/自定义视图集必须保留确认授权与逐图记录。
- P5A 若提出 `SPATIAL_BRIDGE_REQUIRED`，用户确认是否进入证据修复，并分别确认 `left45.png/right45.png` 的合同与最终文件。
- 真实厚度、插头、槽位和部件重叠是否合理。
- Blender 中的最终比例与装配观感。
- 材质的最终视觉目标和 Studio 游戏相机结果。

### 可由 Codex 自动执行

- 创建目录、命名、Manifest、SHA-256 和联系表。
- 识别“近似轴对称/四向信息高度重复”的候选并主动询问；Codex 只能提出 `front-only` 建议，不能替用户批准。
- 根据首轮 AI 网格证据区分 `BASE_VIEW_DEFECT / SPATIAL_BRIDGE_REQUIRED / GENERATOR_DRIFT`，提出最小回退范围；不能自行批准辅助视图。
- 两份 45° 合同均已确认后，可使用 `front + 对应 90° 侧视图` 作为最小参考，分别独立、并行生成左右候选；不得把两张合成一次输出或互相镜像。
- 根据已确认合同生成或修复单张候选。
- 候选先过相机与几何预检，再清理背景。正式统一画布只允许保持主体像素尺度的平移与纯色补边，不得逐图缩放、拉伸、裁切或透视校正。
- Blender 中的批量导入、统计、导出副本、拆材质和 FBX 导出。
- FBX 回导，核对部件数、尺寸、面数、材质和贴图。
- 在用户确认 `Place / target_model_path / studio_mode / root_part / anchored_policy` 并明确授权写入后，Studio 中建立根件、焊接和视觉碰撞设置；未授权时只读检查。

### Codex 不得自动假设

- 左右两侧相同。
- 两张、四张或六张是任一部件的默认正式图数。
- 严格 90° 侧视可以牺牲已声明的立体狼首、尾环、端面或其它关键局部轮廓。
- 正背相同或不同。
- 外观近似轴对称就等于已获 `front-only` 授权。
- 四视图通过就必然足以解释端面到侧壁、正面机构到端视之间的空间过渡。
- “高级武器”默认需要六视图，或 P5A 未提供证据时也应自动补 45°。
- AI 生成的隐藏孔槽具有工程精度。
- 两次独立 AI 生成的共享对位区具有相同数值尺寸。
- 共享对位区的两个副本可以同时留在最终可见网格中。
- 部件长度简单相加等于成品总长；插接会产生重叠。
- Blender 程序材质会随 FBX 完整迁移。
- 一个 Mesh 的多个材质会在 Studio 中稳定成为多个 SurfaceAppearance。
- “看起来像成功”可以替代 FBX 回导和 Studio 验收。
- Blender 空场景回导通过等于 Roblox 已接受资产。
- Studio 导入失败时可以只凭红叉或无关警告直接猜根因。

## 故障与回退原则

详见 [[FAILURE_CODES]]。最小原则：

| 故障 | 回退范围 | 保留内容 |
|---|---|---|
| 单张视图错误 | 只重做该文件 | 其他已确认视图 |
| AI 网格的空间过渡歧义 | 当前部件进入 `VIEW_EVIDENCE_REPAIR`；补辅助 45° 后只重生成该部件 | 基础四视图、其他部件源模型 |
| 单个 AI 部件失败 | 只重做该部件 | 其他部件源模型 |
| Blender 拼接失败 | 最近检查点 | SOURCE_HIGH 与设计锁 |
| 材质迁移失败 | 补烘焙贴图 | 已通过的几何和 UV |
| FBX 回导失败 | 导出副本 | 主制作文件 |
| Studio 导入失败 | 删除本轮导入 Model | 已验证的本地包 |

## 验收入口

- 一页执行：[[快速执行卡_QUICK_START]]
- 全量清单：[[CHECKLIST]]
- 跨部件项目锁：[[PROJECT_LOCK_TEMPLATE]]
- 单接口合同：[[JOINT_CONTRACT_TEMPLATE]]
- 全视图集合约：[[VIEW_SET_CONTRACT_TEMPLATE]]
- 逐侧观察合同：[[SIDE_VISIBILITY_CONTRACT_TEMPLATE]]
- 导出与回导清单：[[EXPORT_MANIFEST_TEMPLATE]]
- 运行续接：[[RUN_STATE_TEMPLATE]]
- 新武器冷启动：[[新武器_新对话启动模板]]
- 工作流注册表：[[WORKFLOW_REGISTRY]]
- 实测案例：[[猫猫剑案例复盘]]
- 空间桥接案例：[[冰晶战锤45度空间桥接复盘]]

## Workflow Check

- **Missing gate**：补齐 `NEW_PROJECT_BOOTSTRAP`、P2J 接口合同、P5A 空间证据修复、P6J 精确接口重建、P8A 导出副本、P8B `Copy + Embed`、P8C 回导，以及 Studio 游戏相机硬门。
- **Removed redundancy**：专项相机、归一化、网格清理和打包实现继续由现有工作流负责，本目录只编排交接。
- **Manual/automatic boundary**：设计、front-only 授权、是否进入辅助 45° 修复及最终视觉验收归用户；诊断、命名、并行生成、哈希和报告可自动化。当前回导脚本只是信息采集器，未与 Manifest 完整比对前不能自动签发 PASS。
- **Verification evidence**：每个状态必须有正式文件、确认记录、Manifest、SHA-256、设置快照和回导比较；Studio 还要记录导入队列、资产 ID、Root/Weld、Play 与用户确认。辅助 45° 必须绑定 P5A 触发证据、独立合同、路径、哈希和重生成结果。
- **Handoff impact**：新对话先走冷启动模板；Tripo/混元、Blender、FBX 和 Studio 之间均有显式 payload、成功条件和失败回退。
- **Scope correction**：VFX 从模型主流程移除，防止模型交付被不相关实验阻塞。
- **Rule/doc update**：新项目冷启动禁止继承案例参数；P8 必须读取多零件导出专项，且回导通过与 Studio 接受分开记状态。
