---
type: workflow
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-08-13
updated: 2026-08-14
---

# 高级武器模型制作快速执行卡

## 新项目触发语句

```text
按 D:\AI\Codex\Codex_Obsidian\81_WorkFlow 工作流\Roblox\模型相关\高级武器模型制作\README.md 从零立项一把新武器。
这是独立新项目，不继承任何案例参数；先只完成 P0 提问和项目初始化，未确认前不要生图。
```

第三把武器可直接使用 [[新武器_新对话启动模板]]。继续旧项目时不要用上面的冷启动语句，应读取该项目自己的 `RUN_STATE.md`，只执行“下一步唯一动作”。

## 10 步最短路径

1. 从 [[PROJECT_LOCK_TEMPLATE]] 建 `PROJECT_LOCK.md`，写用途、目标平台、总长变量、主轴和禁止项。
2. 只生成一张完整武器效果图；无角色、无场景、无粒子、无大面积发光。
3. 用户确认后拆件；每个接口建立 `JOINT_ID`、共享对位区、中心轴/FRONT、最终所有者、代理、防转、插入深度和删除项。
4. 每次只生成一个部件效果图，必须标出准确文件名。
5. `front` 确认后先执行 `VIEW_REDUNDANCY_GATE`：若近似轴对称或四向信息高度重复，Codex 主动问“是否改用仅 `front.png`”；只有用户明确同意才走 `FRONT_ONLY_USER_APPROVED`，否则逐文件确认 `front/back/left/right` 并执行侧向合同。
6. 先用 front-only 1 张或基础四视图 4 张做首轮 Tripo / 混元 3D。front-only 若证据不足，先重新询问并升级为基础四视图；基础四视图试模后，P5A 若仍判定 `SPATIAL_BRIDGE_REQUIRED`，用户确认后才将 `left45/right45` 独立放入辅助目录，再只重生成该部件。
7. Blender 按 `SOURCE_HIGH -> WORK_CLEAN -> EXPORT_COPY` 三层处理；先块模比例，再替换正式网格。
8. 材质先区分 Blender 预览与 Roblox 可迁移贴图；没有烘焙图就不能声称 PBR 已迁移。
9. 到 P8 必须读取 [[../多零件模型转为roblox可导入文件/README|多零件模型转为 Roblox 可导入文件]]：对象白名单与公共 Pivot -> 全件 `0/0/1` -> 一套单位策略 -> 每 Mesh 一材质与真实 PNG/JPG -> Selected Mesh -> Scale 1 / FBX Unit Scale -> `-Z/Y` -> `Copy + Embed` -> 空场景回导。
10. Studio 正常只选择最终 FBX，关闭 `Merge Meshes`，按 Manifest 检查队列、部件、尺寸、方向、贴图、Root/Weld、碰撞和 Play；用户确认后结束。

## 每一步都要问的四件事

```text
输入是什么？
谁确认？
通过证据在哪里？
失败只回退哪一层？
```

## 三个禁止跳过的门

### 门 A：拆件与连接

- 没有完整效果图，不拆件。
- 没有完整 JOINT 合同，不开始部件效果图或多视图。
- 共享对位区可在两份参考图中重复，但两次 AI 生成只能近似；精确接口必须在 Blender 重建。
- 共享可见外壳只保留一个最终所有者；代理副本对齐后删除，不进入 `EXPORT_COPY`。
- 部件总长度不是简单相加；记录插入深度和可见长度。

### 门 B：视图冗余与逐侧可见性

- Codex 先记录冗余候选依据并主动询问，不能因“看起来都一样”自行省略 back/left/right。
- 用户明确授权 `front-only` 后，正式目录只保留 `front.png`，并记录原话、日期与哈希；没有明确授权时默认 `MULTI_VIEW`。
- `front-only` 只豁免冗余视图，不豁免正视图验收、厚度/接口说明或必要工程补图。
- front-only 首轮证据不足时，必须先获批升级并完成基础四视图；不能直接把左右 45° 当作单图的补丁。
- `MULTI_VIEW` 在生成侧视前锁定 `CROSS_SECTION / END_PROFILE`；说不清时先做简单 Proxy。
- `left`、`right` 分别写摄像机方向、must-visible、must-hidden、数量/位置、遮挡、厚度和连接。
- 严格单摄像机 90° 正交，不用 3/4 图冒充。
- 只有用户明确写出 `source -> target` 授权，才允许镜像或复用。
- 六视图不是默认：先用基础四视图试模，只有 P5A 证据和用户批准才补独立 `left45/right45`。
- 条件 45° 必须 orthographic yaw ±45°、pitch/roll 0°；近远同源结构无透视缩放，平端面不球化，中央机构只做刚体正交压缩。
- 两份 45° 合同锁定后可用两个独立任务并行生成；left 只读 front+left，right 只读 front+right，禁止互相镜像。
- 候选先验收几何再清背景；正式统一画布只做平移和补边，不缩放主体。
- 同一正式视图连续失败两次就停止盲目生成，回到合同/Proxy 或 Blender 正交块模。

### 门 C：材质与导出

- Blender 程序节点不是 Roblox 贴图。
- 正式 PBR 至少准备 `BaseColor / Metalness / Roughness`，按需加 `Normal / EmissionMask`。
- root_part、正式对象白名单、公共 Pivot、唯一单位策略必须写入 Manifest；每件必须为 `Location=0 / Rotation=0 / Scale=1`，且相对装配位置不变。
- 贴图必须用 `图像 > 另存为` 形成真实文件；`.png/.jpg` 扩展名、实际编码和节点引用要一致。
- `文件 > 外部数据 > 打包资源` 不等于 FBX 内嵌；FBX 必须同时选择 `Path Mode=Copy` 并点亮小包裹 `Embed Textures`。
- FBX 必须回导；没有回导报告，不进入 Studio。回导通过只写 `FBX_REIMPORT_VERIFIED`，不能提前写 `STUDIO_ACCEPTED`。
- 每个 JOINT 必须通过导出唯一性检查；发现代理、重复环、共面双层面时停止导出。

## Studio 最小设置

```text
Import Only as Model = On
Add to Workspace = On
Merge Meshes = Off
Insert Using Scene Position = Off
Make Double Sided = Off（除非已验证需要）
正常只选择最终 FBX；外部 textures 是证据/回退，不是第二个必选输入
PrimaryPart = PROJECT_LOCK.root_part
所有非根视觉部件 -> WeldConstraint -> root_part
视觉 MeshPart：CanCollide/CanTouch/CanQuery = false
非根视觉件：Massless = true
```

## 完成定义

- [ ] Studio 中的部件数量、名称、总长和方向与 Manifest 一致。
- [ ] 正面、侧面和 3/4 视角无明显空隙、错轴、穿模或翻面。
- [ ] 基础颜色和 PBR 贴图没有串件。
- [ ] 实际游戏摄像机距离下仍能读出主轮廓和材质层级。
- [ ] 没有把参考图、旧零件、候选或被否决的 VFX 放入正式 Model。
- [ ] `RUN_STATE.md` 已标为 `STUDIO_ACCEPTED` 或写明剩余阻塞。

完整说明见 [[README]]，问题处理见 [[FAILURE_CODES]]。
