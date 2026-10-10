---
type: retrospective
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-08-17
updated: 2026-08-17
---

# 案例：黑曜狼首月牙战斧 GLB 导入复盘

## 结果

2026-08-17，用户确认下面的 GLB 可以导入 Roblox Studio：

```text
C:\Users\14176\Documents\RobloxImportPackages\ObsidianWolfAxe_v04\ObsidianWolfAxe_faces4355_1024tex.glb
```

记录状态：

```text
roundtrip = PASS
studio_import = PASS
runtime_assembly = NOT_RECORDED
```

这表示 Studio 已接受主文件；当前没有独立记录 `PrimaryPart`、Weld、碰撞和 Play 散架测试，因此不能把完整运行验收写成 `STUDIO_ACCEPTED`。

## 第一次失败文件

```text
D:\AI\Codex\Codex_3DModel\Roblox 武器模型制作工作流\outputs\2026-08-14_ObsidianWolfCrescentAxe_Jade\05_roblox_import_package\ObsidianWolfCrescentAxe_v03\ObsidianWolfCrescentAxe_v03.fbx
```

Studio 导入队列只显示红叉，没有可定位到 Texture、Mesh、Creator 或服务端的详细错误。因此原始失败码应保持：

```text
STUDIO_IMPORT_FAILED_UNCLASSIFIED
```

## 本地验证事实

v04 诊断包中的四个文件均通过 Blender 5.1 工厂空场景回导：

```text
GLB 主文件                    PASS
外置双贴图 FBX               PASS
内嵌双贴图 FBX               PASS
纯网格 FBX                   PASS
```

装配合同：

```text
AxeHead: 2216 vertices / 2920 triangles / 1 material / 1 BaseColor
Handle:  1182 vertices / 1435 triangles / 1 material / 1 BaseColor
Total:   4355 triangles
Bounds:  1.791772 x 0.672978 x 7.909346 studs
Transforms: Location 0 / Rotation 0 / Scale 1
```

主 GLB：

```text
Size:   385788 bytes
SHA256: 5EFA355BEE42A6D0E35D23CD1D126AC8F967801E324543DD80325FB1343844EB
```

## 失败与成功对照

| 变量 | 第一次失败 | 后续成功 | 是否已单独隔离 |
|---|---|---|---|
| 正式几何 | `AxeHead + Handle`，4355 triangles | 相同 | 是；成功文件证明几何可被 Studio 接受 |
| 材质/贴图数量 | 两件、两材质、两张 BaseColor | 相同 | 是；成功 GLB 保留逐件贴图 |
| 容器 | 内嵌贴图 FBX | GLB | 否；与路径同时变化 |
| Studio 首测路径 | 深层中文/空格路径 | `Documents\RobloxImportPackages` 短英文路径 | 否；与容器同时变化 |
| Studio 服务/会话 | 红叉时状态未知 | 后续成功 | 否；没有服务端错误码 |

## 原因判断

### 可以确认

第一次失败不是由“面数过高、两个零件、装配尺寸或模型几何损坏”造成。原因是同一套正式几何和双贴图映射已经通过 GLB 被 Studio 接受。

### 高概率范围

失败更可能落在原 v03 的 **FBX 封装/内嵌纹理上传链**，长中文深层路径是额外兼容风险。二者在成功测试中同时被替换，因此当前证据不能把其中一个宣布为唯一根因。

### 不能据此断言

- 不能断言“所有内嵌 FBX 都会失败”；猫猫剑和冰晶战锤已有成功反例。
- 不能断言“只要有中文路径就一定失败”。
- 不能断言当时一定是 Creator 权限或 Roblox 服务故障；截图没有对应错误码。

如果未来必须确定唯一原因，应在同一 Studio 会话、同一 Creator 下分别测试：

1. 短英文路径的内嵌 FBX。
2. 同目录的外置贴图 FBX。
3. 同目录的纯网格 FBX。

不过当前主 GLB 已满足交付目标，没有必要为了生产交付继续消耗时间证明每一种回退格式。

## 升级为默认规则

1. 多零件、多贴图刚性资产默认交付短英文路径下的单个 GLB。
2. 顶层只放主 GLB；只有主 GLB 失败或用户明确要求完整包时，才生成 FBX 和贴图回退。
3. 主 GLB 必须在工厂空场景回导；任何已生成的外置 FBX、内嵌 FBX 和纯网格 FBX 也必须逐项回导。
4. Studio 红叉后每次只改变一个变量并记录结果。
5. 主 GLB 成功后停止格式排查，继续 Root/Weld/Play 验收。
