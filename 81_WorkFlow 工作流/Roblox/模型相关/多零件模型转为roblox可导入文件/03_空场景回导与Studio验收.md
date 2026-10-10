---
type: workflow
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-08-14
updated: 2026-08-17
---

# 03 空场景回导与 Studio 验收

## 目标

证明最终主 GLB 和 FBX 回退本身能够恢复正确的装配、材质和尺寸，再进入 Studio。Blender 源场景“看起来正确”不能替代最终交付文件回导。

## 一、空场景回导

1. 新开一个 Blender `General` 文件。
2. 删除默认 Cube、Camera、Light。
3. 先 `文件 > 导入 > glTF 2.0 (.glb/.gltf)`，回导顶层主 GLB。
4. 如果回退支线已经触发，再分别回导外置贴图 FBX、内嵌 FBX 和纯网格 FBX；每次回导前恢复空场景。未生成的回退记录为 `NOT_GENERATED`，不视为漏验。

也可以使用已有只读验证脚本：

```text
D:\AI\Codex\Codex_3DModel\scripts\verify_fbx_import_contract.py
```

当前旧脚本只负责 FBX 信息采集，不能单独签发 `ROUNDTRIP_VERIFIED=PASS`。正式判定必须把主 GLB 和每个回退的报告与 Manifest 逐项比较；验证器没有覆盖的 Rotation、Scale、Dimensions、UV、额外对象、真实贴图编码、公共 Pivot 和真实三角面必须人工补验。若没有完成这次比较，记录 `ROUNDTRIP_VERIFIER_INCOMPLETE`。

## 二、回导必须核对

| 检查项 | 期望 |
|---|---|
| Mesh 数量 | 与 Manifest 完全一致 |
| 对象名称 | 稳定英文名，无 `.001` 漂移 |
| 相对位置 | 已拼好，不需要再次移动 |
| 总尺寸 | 与导出副本一致 |
| 公共枢轴 | 根件位置正确，各件共坐标 |
| 三角面 | 每件及总数与 Manifest 一致 |
| 材质 | 每个 Mesh 一套预期材质 |
| 贴图 | 正确部件、正确方向、没有纯白/串图 |
| 场景杂物 | 无参考平面、Camera、Light、旧零件 |

任何一项不符，按具体格式记录 `GLB_ROUNDTRIP_FAILED` 或 `FBX_ROUNDTRIP_FAILED`，保留失败证据但禁止交付，回到导出副本修正。

## 三、Studio 正常导入

在 Studio 的 3D Importer 中，只选择短英文路径下的顶层主 GLB。正常情况下不需要同时选择 PNG/JPG。

```text
Import Only as Model = On
Add to Workspace = On
Insert Using Scene Position = Off
Merge Meshes = Off
Make Double Sided = Off
```

预览中必须先看到：

- 一个 Model，下面是预期数量的独立 Mesh。
- 各零件已经装配完成。
- 方向、尺寸和贴图正确。
- 没有额外参考对象。

预览不正确时不要导入后再手工拼，回 Blender 修复。

## 四、Studio 装配

导入后只做运行结构，不重做模型位置：

1. 把根件设为 `PrimaryPart`，武器通常是 `Handle`。
2. 为其他 MeshPart 添加 `WeldConstraint`：

```text
Part0 = Handle
Part1 = HammerHead / Blade / Guard / Pommel...
```

3. 视觉零件建议：

```text
CanCollide = false
CanTouch = false
CanQuery = false
Massless = true   # 根件按项目物理策略决定
```

4. 展示测试可临时把根件 `Anchored=true`；进入 Tool 后按 Tool 规则解除。
5. Play 一次，确认模型不会散开。

## 五、失败隔离顺序

每次只改变一个变量，并记录“文件格式、路径、是否带贴图、Creator、Studio 会话”五项。禁止同时换格式、改网格、改单位、缩贴图和切 Creator 后再猜原因。

### A. 同一 Studio 会话导入已知成功 GLB

- 已知成功文件也失败：优先排查 Studio 会话、Creator 权限或上传服务。
- 已知成功文件成功、候选失败：候选包或资产上传链路有差异。

### B. 候选主 GLB 失败时导入外置贴图 FBX

- 外置 FBX 成功：问题集中在 GLB 容器/导入器兼容性。
- 外置 FBX 也失败：继续纯网格对照，不随机重导全部内容。

### C. 导入纯网格 FBX

- 无贴图网格能导入：问题集中在贴图格式、引用、上传权限或材质链。
- 无贴图也失败：问题集中在 FBX 网格、对象、单位或导入器兼容性。

### D. 单独上传贴图

- PNG/JPG 单独也失败：检查真实格式、账号/群组权限和图片审核。
- 单独成功、FBX 内嵌失败：检查 FBX 的 Texture/Video 引用与导出设置。

### E. 查看证据，不猜日志

导入器红叉但没有服务器详细错误时，记录 `STUDIO_IMPORT_FAILED_UNCLASSIFIED`。本地回导成功只证明文件可解析，不证明 Roblox 云端已经接受网格和纹理。

### F. 主 GLB 成功后停止

主 GLB 成功即记录 `studio_import=PASS` 并停止格式排查。回退文件的职责是恢复和定位，不要求每个项目都在 Studio 全部导入一遍。

## 失败结果判读矩阵

| 主 GLB | 外置 FBX | 纯网格 FBX | 可以确认 | 仍不能确认 |
|---|---|---|---|---|
| PASS | 未测 | 未测 | 几何与主 GLB 上传链可用 | 原 FBX 红叉的唯一底层原因 |
| FAIL | PASS | 未测 | GLB 容器/目标导入器差异 | 是否与贴图相关 |
| FAIL | FAIL | PASS | 带材质/贴图链存在问题 | 具体是哪张图或哪条材质记录 |
| FAIL | FAIL | FAIL | 问题不只在贴图 | 网格、Creator 权限、会话或服务中的具体一项 |

## Studio 导入与运行验收分层

Studio 导入队列成功、MeshPart/贴图显示正确时，先记录：

```text
studio_import = PASS
runtime_assembly = NOT_RECORDED
```

只有继续完成 Root、Weld、碰撞和 Play 散架测试，才进入下面的 `STUDIO_ACCEPTED`。

## `STUDIO_ACCEPTED` 条件

- [ ] 对象数量、名称、尺寸、方向与 Manifest 一致。
- [ ] 每个零件仍是独立 MeshPart，且无需手工重新对位。
- [ ] BaseColor/SurfaceAppearance 对应正确。
- [ ] `PrimaryPart` 和 Weld 已设置。
- [ ] Play 后不散架。
- [ ] 实际游戏相机下尺寸合理。
- [ ] 用户明确确认。

本流程的最新 Studio 成功控制组见 [[案例_黑曜狼首月牙战斧_GLB导入复盘]]。
