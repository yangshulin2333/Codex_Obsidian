---
type: workflow
domain: roblox
status: active
owner: mixed
source: self
created: 2026-08-13
updated: 2026-08-15
---

# 高级武器模型制作全量检查表

## A. 立项与完整效果图

- [ ] `PROJECT_LOCK.md` 已建立，范围、用途、平台和禁止项明确。
- [ ] 目标总长和三角面预算已确认，或明确写 `UNCONFIRMED`。
- [ ] 完整武器效果图单物体、背景干净、无角色和特效。
- [ ] 正面、主轴、宽度轴和厚度轴有定义。
- [ ] 用户确认的是准确文件名，不是“第一张/第二张”的模糊指代。

## B. 拆件与连接

- [ ] 每个部件有 ID、英文 Role 和中文名。
- [ ] 记录轴向站位、可见长度、宽度和厚度包络。
- [ ] 每个接口有唯一 `JOINT_ID` 和独立 JOINT 合同。
- [ ] 每个接口写明 From/To、共享对位区、中心轴与 FRONT。
- [ ] 每个接口写明最终所有者、代理副本和对齐后删除项。
- [ ] 每个接口写明插入深度、隐藏防转结构和遮挡件。
- [ ] 明确 AI 负责装饰外壳，Blender 负责哪些隐藏工程结构。
- [ ] 已声明两次 AI 生成只能近似，精确基准、插头和母槽由 Blender 重建。
- [ ] 部件真实长度没有被简单相加成成品长度。
- [ ] 全部接口 `joint_contract_gate=PASS` 后才进入部件效果图。

## C. 部件效果图与多视图

- [ ] 每次只处理一个部件。
- [ ] 每个部件的 `effect.png` 已确认并落到稳定路径。
- [ ] 每个部件已在 P2 标记 `required / optional / deferred`，没有因生成失败临时降级。
- [ ] 总状态只在所有 required 部件通过对应 Gate 后推进。
- [ ] effect 的路径、SHA-256、确认原文与日期已记录。
- [ ] 每个部件都执行了 `VIEW_REDUNDANCY_GATE`，并记录候选依据、Codex 提问和用户结论。
- [ ] 每个部件都通过 `PART_VIEW_CONTRACT_GATE`：用户原话/日期、`required_final_views`、`not_required_views`、预期张数和平台槽位状态可追溯。
- [ ] 未选方向（包括此前确认但仅作历史参考的图）已明确记录，不会因为“已有图片”自动混入本次正式集。
- [ ] `front-only` 仅用于有明确用户授权原文/日期的部件；未授权或含糊回复仍按多视图执行。
- [ ] 单正视图模式的正式目录恰好只有 `front.png`；厚度、接口或隐藏孔槽若仍需证据，已另做工程补图或留给 Blender。
- [ ] `MULTI_VIEW` 部件已锁定 `CROSS_SECTION / END_PROFILE / near_end_face / side_wall`；说不清时先做低成本 Proxy。
- [ ] `front/back/left/right` 的相机语义清楚。
- [ ] `left/right` 分别有 must-visible、must-hidden、数量、位置、遮挡、厚度和接口合同。
- [ ] 不对称部件允许使用 `Side A / Side B` 等语义方向名，且没有为了文件习惯强行映射为 left/right。
- [ ] 没有从“看起来对称”推断镜像；若复用，有准确 `source -> target` 用户授权。
- [ ] 每张严格侧视明确 `camera_count=1 / ORTHOGRAPHIC / yaw / pitch / roll`；要求 90° 时不是 3/4、透视、拼接或混合视角。
- [ ] 立体兽首、尾环、端面等 `critical_side_profile` 在侧视仍能读出真实局部剪影与厚度，没有被压成纸片或窄条。
- [ ] 正背相同或不同的理由已记录。
- [ ] 空心端、孔槽等四侧无法表达的结构已有轴向/剖面补图，或明确留给 Blender。
- [ ] `MULTI_VIEW` 的单图和带标签联系表都已验收；`FRONT_ONLY_USER_APPROVED` 已保存单图全分辨率验收证据。
- [ ] 项目级 `00_formal_model_references/` 恰好只含 `required_final_views` 的用户确认 PNG，使用 `{component_role}_{semantic_view}.png` 唯一命名，且没有候选、文档或联系表。
- [ ] `00_final_image_to_3d_upload/` 只含平台实际接受的正式 PNG；图数不匹配已记录并取得下一步决定，没有复制、翻转、镜像或伪造缺失方向。
- [ ] 没有把六视图设为高级武器默认；`left45/right45` 只有 P5A 证据和用户批准后才生成。
- [ ] 条件 45° 为正交 yaw ±45°、pitch/roll 0°，无高机位、透视近大远小、端面球化或中央机构重设计。
- [ ] 辅助 45° 目录若存在，恰好只有 `left45.png/right45.png`；基础 4 张与辅助 2 张没有混进同一物理目录。
- [ ] 候选先过相机/几何验收再清背景；正式统一画布只做平移和补边，主体未逐图缩放或拉伸。
- [ ] 每个正式视图连续失败不超过 2 次；超出前已停止盲目生成并回到合同/Proxy。

> 上述 `front/back/left/right` 与侧向合同项仅对它们被列入 `required_final_views` 的部件为必填；`FRONT_ONLY_USER_APPROVED` 或 `USER_DECLARED_SET` 部件必须以授权记录、逐图相机合同和正式参考集映射替代，不能静默跳过。

## D. AI 3D 接收

- [ ] 每个部件独立提交，记录平台、任务/版本和输入哈希。
- [ ] 每次 P5A 已记录 `attempt / input Manifest / outcome / evidence / next_action`。
- [ ] 首轮 P5A 前 `p5a_outcome=NOT_EVALUATED`；执行后已区分 `PASS / BASE_VIEW_DEFECT / SPATIAL_BRIDGE_REQUIRED / GENERATOR_DRIFT`，没有一律归因于缺少 45°。
- [ ] 若为 `SPATIAL_BRIDGE_REQUIRED`，已记录用户批准、两份独立 45° 合同、辅助目录哈希和重生成 task ID，并重新执行 P5A。
- [ ] front-only 首轮证据不足时已重新询问是否升级基础四视图，没有直接跳到辅助 45°。
- [ ] 轮廓、识别点、方向性结构与正式视图一致。
- [ ] 厚度不为纸片，也没有无依据膨胀。
- [ ] 正背装饰没有错误融合或漂浮。
- [ ] 接口附近有可用于 Blender 重建的实体。
- [ ] 原始模型和贴图复制到只读 `SOURCE_HIGH`。
- [ ] 已知缺陷已记录，没有被“后面再说”隐藏。

## E. Blender 拼接

- [ ] 使用 `SOURCE_HIGH / WORK_CLEAN / EXPORT_COPY` 三层文件。
- [ ] 块模先通过比例、厚度和接口检查。
- [ ] 正式部件按实际接口中心对轴，不只看包围盒中心。
- [ ] 每个接口有 `AXIS_<ID>`、`FRONT_<ID>` 和量化重建的精确基准。
- [ ] 接口有隐藏相交或连接芯，没有背景透出。
- [ ] 防转方向和插入深度符合 JOINT 合同。
- [ ] 对位完成后，代理副本与 `DELETE_AFTER_ALIGN` 项已删除。
- [ ] 正、侧、3/4 都通过用户确认。
- [ ] 非等比缩放有明确授权和 XYZ 记录。
- [ ] 大操作前有检查点；批量脚本可重复运行且不清空用户节点。
- [ ] AI 碎片网格没有未经测试就全局焊接。

## F. 材质

- [ ] Blender 预览节点与 Roblox 可迁移贴图分开记录。
- [ ] BaseColor、Metalness、Roughness、Normal、EmissionMask 的存在状态清楚。
- [ ] 没有把 basecolor-only 称作完整 PBR。
- [ ] 每个导出 Mesh 只依赖预期的一套可迁移材质。
- [ ] 在实际游戏相机距离测试了贴图，不只看特写。

## G. 导出与回导

- [ ] 在导出副本中操作，没有覆盖主制作文件。
- [ ] 已锁定 `root_part` 和 Selected Objects 正式白名单。
- [ ] 参考图、旧件、相机、灯光和临时对象已移除。
- [ ] `EXPORT_COPY` 不含 `ALIGN_PROXY_*` 或 `*_DELETE_AFTER_ALIGN`。
- [ ] 每个共享可见外壳只有 `final_surface_owner` 一份；无共面重复面、重复装饰环或双层外壳。
- [ ] 隐藏插头/连接芯已在 JOINT 合同中批准，且不与外壳形成共面重复表面。
- [ ] 部件有稳定英文 ASCII 名，并共享同一个可解释 Pivot。
- [ ] 若对象有 Parent/Constraint/Delta Transform，已先保留世界变换并烘焙到导出副本。
- [ ] 每件 `Location=0 / Rotation=0 / Scale=1`，且正、侧、3/4 装配位置没有变化。
- [ ] 只采用一种单位策略；未混用顶点缩放、对象 100 倍、FBX 0.01 等重复补偿。
- [ ] 每个 Mesh 只有一套正式材质；贴图使用“图像 > 另存为”生成真实 PNG/JPG。
- [ ] 贴图声明扩展名、实际编码与节点引用一致；FBX 内部纹理引用名含图片扩展名。
- [ ] FBX 只导出 Selected Mesh，无动画；`Apply Scalings=FBX Unit Scale`、`Apply Unit=On`。
- [ ] `Path Mode=Copy` 且右侧小包裹 `Embed Textures=On`。
- [ ] FBX 路径、大小、SHA-256、设置快照和贴图哈希已写入 Manifest。
- [ ] FBX 已导入空场景检查部件数、尺寸、面数、方向、材质和贴图。
- [ ] 回导后零件仍可独立选择、共享公共 Pivot，且不需要重新位移/旋转/缩放。
- [ ] 导出 Manifest 与回导结果一致。
- [ ] `FBX_REIMPORT_VERIFIED` 没有被当成 Studio 云端接受证据。

## H. Studio

- [ ] `Import Only as Model = On`。
- [ ] `Add to Workspace = On`。
- [ ] `Merge Meshes = Off`。
- [ ] `Insert Using Scene Position = Off`。
- [ ] 正常导入只选择最终 FBX；没有把 PNG/JPG 当成第二个必选输入。
- [ ] 预览长度、方向、部件名和数量符合 Manifest。
- [ ] 正式上传队列成功，Mesh/Texture 资产 ID 或导入记录已保存。
- [ ] PrimaryPart / Handle、WeldConstraint、碰撞和 Massless 已设置。
- [ ] 导入后没有手工重新拼位置，Play 后模型不散架。
- [ ] 视觉网格不用作精确碰撞。
- [ ] 正、侧、3/4 和实际游戏相机均通过。
- [ ] 正式 Model 不含被否决的 VFX。
- [ ] 用户明确确认，状态为 `STUDIO_ACCEPTED`。

## I. 交付与归档

- [ ] 保存完整效果图、部件正式图、多视图和审批记录。
- [ ] 保存原始 AI 模型、工作 Blender、导出 Blender、FBX、贴图和回导报告。
- [ ] `RUN_STATE.md` 写明最终状态、偏差、未决项和下一任务。
- [ ] 案例专属数值没有被误写成通用默认。
- [ ] VFX、动画、伤害系统作为独立任务，不阻塞模型归档。
