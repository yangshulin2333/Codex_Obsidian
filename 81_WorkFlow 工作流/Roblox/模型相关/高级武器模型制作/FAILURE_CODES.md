---
type: workflow
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-08-13
updated: 2026-08-15
---

# 高级武器模型制作失败码

本文件只记录跨阶段和高级武器增量失败。多视图通用失败码继续参考 [[../Roblox 通用游戏素材道具制作工作流/FAILURE_CODES|通用道具失败码]]。

## 立项与拆件

| 失败码 | 判定 | 恢复 |
|---|---|---|
| `NEW_PROJECT_BOOTSTRAP_SKIPPED` | 全新武器未记录运行模式、输入来源和案例隔离，就开始生图或拆件 | 执行 [[新武器_新对话启动模板]]，只完成 P0，不生成图片 |
| `CASE_PARAMETER_INHERITED_WITHOUT_AUTHORIZATION` | 新项目直接沿用历史案例的拆件、尺寸、轴向、接口、视图或预算 | 清空继承值，改为 `UNCONFIRMED`，由用户重新确认 |
| `PROJECT_BRIEF_MISSING` | 用途、平台或目标范围未定义 | 补 `PROJECT_LOCK.md`，不生成正式效果图 |
| `MASTER_EFFECT_NOT_CONFIRMED` | 完整武器效果图未绑定明确确认 | 停止拆件，只继续效果图候选 |
| `COMPONENT_SPLIT_NOT_LOCKED` | 部件边界、角色或连接对象未确认 | 回到拆件表，不生成部件多视图 |
| `COMPONENT_IDENTITY_DRIFT` | 部件候选变成另一设计或与整体母版不一致 | 仅重做该部件，使用已确认母版 |
| `ASSEMBLY_RATIO_UNCONFIRMED` | 部件轴向比例或厚度包络缺失 | 先块模并让用户确认 |
| `CONNECTOR_NOT_LOCKED` | 接口类型、轴向、重叠或可见性未定义 | 补接口合同；精密孔槽转 Blender/工程补图 |
| `JOINT_CONTRACT_INCOMPLETE` | JOINT_ID、共享对位区、中心轴/FRONT、所有者、代理、防转、插入深度或删除项任一缺失 | 补完整 `JOINT_<ID>.md`；P2J 保持 FAIL |
| `JOINT_OWNER_AMBIGUOUS` | 共享可见外壳没有唯一最终所有者，或两个部件都声明保留 | 指定唯一 `final_surface_owner`，另一份改为 `DELETE_AFTER_ALIGN` 代理 |
| `JOINT_ROTATION_KEY_MISSING` | 接口存在旋转歧义但未定义 D 形平边、偏置键或方向缺口 | 补防转结构和 FRONT 方向后重新确认 P2J |

## 多视图与生成

| 失败码 | 判定 | 恢复 |
|---|---|---|
| `VIEW_REDUNDANCY_GATE_SKIPPED` | 未记录冗余判断与主动提问，就直接生成四视图或省略冗余视图 | 停止提升正式文件；补做 Gate，并按用户决定继续 |
| `PART_VIEW_CONTRACT_MISSING` | 未记录 `required_final_views / not_required_views`、用户原话、逐图相机或平台槽位状态，就生成/整理正式图 | 停止提升或打包；补齐部件视图合同并逐图确认 |
| `FRONT_ONLY_NOT_AUTHORIZED` | 未绑定明确用户原话/日期就采用单正视图，或把“看起来相同”当作授权 | 撤销 front-only；恢复 `MULTI_VIEW` 与侧向合同，或等待用户明确授权 |
| `SIDE_VISIBILITY_CONTRACT_MISSING` | `MULTI_VIEW` 部件的 left/right 或对应 45° 视图无逐文件合同 | Codex 主动补问并复述，等待确认；已授权 front-only 的部件不触发此码 |
| `SIDE_VISIBILITY_CONTRACT_BROKEN` | 可见、隐藏、数量、位置或遮挡与合同不符 | 只归档并重做该单图 |
| `UNCONFIRMED_SIDE_MIRROR` | 未经 source->target 授权复制/镜像 | 候选判废，独立生成或取得授权 |
| `SINGLE_CAMERA_CONTRACT_BROKEN` | 合同要求单相机，但候选使用拼接、混合角度或通过旋转/拉伸伪造同一视图 | 候选判废；按 `camera_count=1` 重做该文件 |
| `VIEW_NOT_ORTHOGRAPHIC` | 严格侧视出现 3/4、透视或宽正面 | 从纯净来源重做该图 |
| `CRITICAL_SIDE_PROFILE_MISSING` | 立体兽首、尾环、端面或方向性机构在侧视被完全抹掉，无法读出合同要求的局部剪影 | 修订 must-visible 与 `critical_side_profile`，只重做该图 |
| `SIDE_FEATURE_OVERFLATTENED` | 为追求严格侧视把实体尾环、端面或其它关键结构压成纸片/窄条，违背真实侧向厚度 | 回到端面/厚度合同；保持单相机正交后重做该图 |
| `FOUR_VIEW_IDENTITY_MISMATCH` | 四图不像同一部件 | 找到漂移图，只重做异常图 |
| `VIEW_SET_IDENTITY_MISMATCH` | 单图、基础四图、辅助 45° 或工程证据中的任一文件不像同一刚体 | 找到漂移文件，只重做该文件；不整套返工 |
| `THICKNESS_NOT_LOCKED` | 侧视无法解释层数、厚度或收束 | 补厚度合同，不进入正式目录 |
| `CROSS_SECTION_END_PROFILE_NOT_LOCKED` | MULTI_VIEW 部件在正式侧视/45° 前无法说明主截面、端面及侧壁关系 | 补几何卡；说不清时先做低成本 Proxy |
| `FINAL_DELIVERY_FOLDER_DIRTY` | 项目正式参考集或平台上传目录含文档、联系表、候选、子目录，或与 Manifest 的 `required_final_views` 不一致 | 清理目录，只保留准确、已确认的 required PNG |
| `FORMAL_REFERENCE_SET_MISMATCH` | 项目级正式参考集的文件名、哈希、确认状态或数量与 `FORMAL_REFERENCE_SET.md` 不一致 | 保留原图，重建非破坏性副本和映射；不覆盖确认源图 |
| `AUXILIARY_45_NOT_P5A_TRIGGERED` | 没有 P5A 空间歧义证据或用户批准，就默认创建 left45/right45 | 删除辅助正式包，回到基础视图与 P5A 决策 |
| `AUXILIARY_45_PACKAGE_DIRTY` | 辅助目录不是恰好 `left45.png/right45.png`，或混入 Proxy、工程图、文档、失败稿 | 清理独立辅助目录并重建 Manifest |
| `VIEW_45_CAMERA_INVALID` | 45° 候选出现 pitch/roll、高低机位、透视近大远小或非正交产品渲染 | 只重做该 45° 图，锁定 orthographic yaw ±45°、pitch/roll 0° |
| `END_PROFILE_SPHERIZED` | 既定平面/多边形端面被生成成球体、鼓包、宝石或薄圆片 | 回到 END_PROFILE/Proxy，恢复端面与厚侧壁分界 |
| `OBLIQUE_PROJECTION_BROKEN` | 中央正面机构未随刚体正交压缩，或端面/侧壁/遮挡关系不符合对应基础视图 | 修订该文件的 45° 合同，只重做该图 |
| `FINAL_VIEW_OBJECT_SCALE_CHANGED` | 统一画布时逐图缩放、拉伸或透视校正主体 | 恢复已确认原图，只做平移和纯色补边 |
| `FORMAL_IMAGEGEN_RETRY_BUDGET_EXCEEDED` | 同一正式视图连续两次失败后仍准备无新证据地重试 | 停止 imagegen，回到合同/Proxy 或使用 Blender 正交块模渲染 |
| `AI_MESH_GEOMETRY_DRIFT` | 输出网格轮廓/结构偏离正式图 | 反查冲突视图或重跑该部件 |
| `AI_MESH_SPATIAL_TRANSITION_AMBIGUOUS` | 正视/端视各自可读，但端面到侧壁、正面机构到端视的中间体积被错误猜测 | 记录 P5A 证据，询问用户是否进入 `VIEW_EVIDENCE_REPAIR` |
| `FRONT_ONLY_EVIDENCE_INSUFFICIENT` | 已授权单正视图生成的网格无法可靠解释厚度或端面 | 重新询问是否升级基础四视图；不得直接跳到辅助 45° |
| `P5A_SPATIAL_BRIDGE_UNRESOLVED` | 加入已确认辅助 45° 并重生成后，空间过渡仍错误 | 停止继续补图；转 Blender 块模/人工建模或判断生成器不适配 |
| `AI_MESH_BACKGROUND_FUSED` | 背景或阴影被生成进模型 | 清理输入背景后重跑该部件 |
| `SHARED_DATUM_VISUAL_DRIFT` | 两个部件图中的共享对位区轮廓、层数、厚度比例、朝向或相对尺度不一致 | 只修正漂移的部件图，重新绑定 JOINT 合同 |
| `AI_CONNECTOR_PRECISION_ASSUMED` | 因两份输入图相似而把两个 AI 网格视为数值相同的接口 | 停止装配；在 Blender 按 JOINT 合同重建精确基准与连接 |

## Blender

| 失败码 | 判定 | 恢复 |
|---|---|---|
| `ASSEMBLY_GAP` | 接口从任一验收视角透出背景 | 回退 WORK_CLEAN，增加插入/隐藏连接芯 |
| `ASSEMBLY_AXIS_MISMATCH` | 部件视觉中心对齐但实际接口不同轴 | 使用接口截面中心重新对轴 |
| `ASSEMBLY_RATIO_REJECTED` | 用户认为部件大小/厚度不协调 | 回到块模或记录非等比调整，不劈高模试错 |
| `DESTRUCTIVE_EDIT_WITHOUT_CHECKPOINT` | 唯一工作文件上执行不可逆大操作 | 停止，另存检查点后再做 |
| `BLENDER_RECOVERY_REQUIRED` | Blender 卡死、崩溃或保存状态不明 | 从 autosave/checkpoint 另存恢复文件并审计 |
| `AI_MESH_GLOBAL_WELD_RISK` | 碎片网格准备未经测试全局焊接 | 复制对象，局部测试 UV/法线/轮廓后决定 |
| `JOINT_REBUILD_MISSING` | 装配直接使用 AI 接口，未建立量化基准、插头/母槽或防转结构 | 回退 WORK_CLEAN，按 P6J 重建并复核 |
| `JOINT_PROXY_NOT_REMOVED` | 对齐后仍保留代理副本或 DELETE_AFTER_ALIGN 对象 | 删除代理，重新执行 P6J/P8J 检查 |

## 材质与导出

| 失败码 | 判定 | 恢复 |
|---|---|---|
| `MATERIAL_TRANSFER_ASSUMED` | 把 Blender 程序节点当作已进入 Roblox | 烘焙并列出实际贴图，重新验收 |
| `TEXTURE_MAP_MISSING` | 声称 PBR 但缺 Metalness/Roughness 等地图 | 降级标注 basecolor-only 或补图 |
| `MULTI_MATERIAL_SINGLE_MESH` | 一个导出 Mesh 依赖多套材质，Studio 映射风险高 | 导出副本按材质/控制需求拆 Mesh |
| `REFERENCE_PLANE_EXPORTED` | FBX 含参考图、旧零件或临时对象 | 只选正式 Mesh 重导 |
| `EXPORT_OBJECT_WHITELIST_BROKEN` | 实际选择集与 Manifest 正式对象白名单不一致 | 只选择白名单 Mesh，重建设置快照后重导 |
| `PART_ORIGIN_MISMATCH` | 正式部件没有共享项目定义的公共 Pivot | 回退导出副本，按 root_part/Datum 重新建立公共 Pivot |
| `PART_TRANSFORM_NOT_BAKED` | 任一正式部件不是 `Location=0 / Rotation=0 / Scale=1`，或清变换后装配漂移 | 从检查点恢复，保留世界变换后重新烘焙导出副本 |
| `MULTIPLE_SCALE_STRATEGIES` | 同时使用顶点缩放、对象 Scale、米/Stud 换算和 FBX Global Scale 等重复补偿 | 只保留一套单位策略并重做 P8A |
| `TEXTURE_FILENAME_EXTENSION_MISSING` | FBX 内部纹理引用名没有 `.png/.jpg/.jpeg` | 用“图像 > 另存为”生成带扩展名文件，重新绑定并重导 |
| `TEXTURE_FILE_FORMAT_MISMATCH` | 声明扩展名与检测到的真实编码不一致 | 真正转码为声明格式后重新绑定；兼容性成功案例也只记为偏差，不升级为默认 |
| `TEXTURE_REFERENCE_BROKEN` | 材质节点、外部事实源或 FBX 内部引用指向错误/不存在文件 | 重新绑定稳定 `textures/` 文件并核对哈希 |
| `FBX_EMBED_TEXTURES_DISABLED` | 只选择 `Path Mode=Copy`，未点亮右侧小包裹 | 开启 `Embed Textures` 后重导 |
| `EXPORT_NOT_REIMPORTED` | FBX 生成后未在空场景回导 | 停止 Studio 阶段，先回导 |
| `FBX_ROUNDTRIP_FAILED` | 已执行回导，但数量、名称、变换、尺寸、材质、贴图、Pivot 或杂物任一与 Manifest 不一致 | 删除失败 FBX，回到 EXPORT_COPY 修复并递增版本 |
| `FBX_DIMENSION_MISMATCH` | 回导尺寸与 Manifest 超出容差 | 检查单位、应用变换和导出 scale |
| `FBX_PART_COUNT_MISMATCH` | 回导部件数/名称不符 | 检查选择集、拆分和导出过滤 |
| `EXPORT_DUPLICATE_JOINT_SURFACE` | EXPORT_COPY 同时含共享外壳所有者与代理，或存在共面重复环/端盖/表面 | 停止导出；仅保留 final_surface_owner，清理代理和重复面后重跑 P8J |
| `JOINT_EXPORT_UNIQUENESS_NOT_VERIFIED` | 未逐 JOINT 记录唯一性检查就准备导出 | 补 `EXPORT_MANIFEST.md` 和 P8J 证据，不进入 FBX 回导 |

## Studio 与范围

| 失败码 | 判定 | 恢复 |
|---|---|---|
| `STUDIO_MERGE_MESHES_ENABLED` | 应分件却被合并 | 删除本轮 Model，关闭 Merge 后重导 |
| `STUDIO_PART_COUNT_MISMATCH` | Studio 层级与 Manifest 不符 | 先比对 FBX 回导，再修导入设置/包 |
| `STUDIO_TEXTURE_UPLOAD_FAILED` | 网格预览正常，但一张或多张纹理云端上传明确失败 | 用无贴图 FBX与单独图片上传做 A/B；核对实际编码、引用、Creator 和权限 |
| `STUDIO_IMPORT_FAILED_UNCLASSIFIED` | 导入红叉但没有可验证的服务器/解析错误 | 保存队列证据；先测已知成功 FBX、无贴图候选和单独贴图，不猜根因 |
| `STUDIO_UPLOAD_NOT_VERIFIED` | 只完成本地预览/Blender 回导，却宣称 Roblox 已接受 | 保持 `FBX_REIMPORT_VERIFIED`，完成正式上传队列后再推进 |
| `STUDIO_RUNTIME_ASSEMBLY_NOT_VERIFIED` | 导入成功，但 Root/Weld/碰撞或 Play 散架测试未记录 | 记录 `studio_import=PASS`，补运行装配验收后才能 `STUDIO_ACCEPTED` |
| `STUDIO_MUTATION_NOT_AUTHORIZED` | 未确认 Place、目标路径、模式、根件、锚定策略或写入授权 | 保持只读，补 Studio 写入合同 |
| `STUDIO_PARTS_NOT_WELDED` | Play 后散架或各自成为根装配 | 以根件建立 WeldConstraint 并复测 |
| `VISUAL_MESH_COLLISION_ENABLED` | AI 视觉网格参与复杂物理碰撞 | 关闭碰撞/查询，另建简单 Hitbox/Raycast |
| `VFX_SCOPE_CREEP` | 特效实验进入模型验收主线 | 停止并移除 VFX；保留已接受模型状态 |
| `FINAL_HANDOFF_INCOMPLETE` | 缺 Manifest、正式图、FBX、贴图或验收记录 | 按 [[CHECKLIST]] 补齐，不标记归档 |

## 通用恢复规则

1. 失败产物移到候选/失败目录，不能覆盖上一个确认版。
2. 只回退最小责任范围：单图、单部件、单 Blender 检查点或单次 Studio 导入。
3. 超时或平台配额问题最多按专项工作流重试；没有新证据时不循环生成。
4. 每次失败写入运行状态：失败码、精确文件、原因、恢复动作和是否可重试。
