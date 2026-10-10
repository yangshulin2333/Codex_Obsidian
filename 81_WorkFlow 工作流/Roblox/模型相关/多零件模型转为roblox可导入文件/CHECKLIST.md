---
type: checklist
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-08-14
updated: 2026-08-17
---

# 多零件模型直导检查表

> 快速通道由脚本自动完成 P4/P5 并生成 `*.verification.json`。只有脚本失败、GLB 在 Studio 失败或明确要求完整兼容包时，才人工执行本检查表的全部分支。

## P0 源对象

- [ ] 源 `.blend` 已保留，只在导出副本工作。
- [ ] 正式对象名、数量、用途和根件已记录。
- [ ] Camera、Light、参考图、旧件和代理不在正式对象清单。

## P1 装配与坐标

- [ ] Blender 正面、侧面、3/4 拼接正确。
- [ ] 接口有合理重叠/连接，不是只靠边界碰触。
- [ ] 零件保持独立，没有 `Ctrl+J` 合并。
- [ ] 全部正式对象共享公共原点。
- [ ] 全部正式对象 `Location=0`、`Rotation=0`、`Scale=1`。

## P2 材质与贴图

- [ ] 每个 Mesh 只有一套正式材质。
- [ ] 每个 Mesh 只有一个正式 UV 集，UV 位于 0–1。
- [ ] BaseColor 为简单 Image Texture 直连，或 PBR 已烘焙。
- [ ] 每张图片用真实 PNG/JPG 另存，扩展名与格式一致。
- [ ] 每个部件贴图名唯一，路径和哈希已记录。

## P3 单位

- [ ] 已选择 Blender Unit=Stud 或真实米制转换之一。
- [ ] 米制转 Stud 只执行一次。
- [ ] 没有同时使用 `Scale=100`、`Global Scale=.01` 和顶点缩放。
- [ ] 完整模型目标尺寸已记录为 Stud。

## P4 导入包

- [ ] 包输出在 `%USERPROFILE%\Documents\RobloxImportPackages\短英文资产名\`。
- [ ] 顶层只有一个主 GLB，名称包含真实三角面和实际贴图尺寸。
- [ ] GLB 保留预期 Mesh 数量以及逐件材质/贴图映射。
- [ ] 未触发回退时，不生成 `manual_fallback/`；已触发时包含外置贴图 FBX、全部贴图、纯网格 FBX、内嵌 FBX。
- [ ] FBX Selected Objects 开启，Object Types 仅 Mesh。
- [ ] Apply Modifiers、Triangulate 开启。
- [ ] Global Scale=1、Apply Scalings=FBX Unit Scale。
- [ ] Forward/Up 与项目基线一致。
- [ ] 外置 FBX 使用 Relative + Embed Off；内嵌 FBX 使用 Copy + Embed On。
- [ ] Add Leaf Bones、Bake Animation 关闭。
- [ ] 所有交付文件的名称、大小和 SHA-256 已记录。

## P5 空场景回导

- [ ] 主 GLB 已在空 Blender 场景回导；任何已生成 FBX 回退也已分别回导。
- [ ] Mesh 数量和稳定名称一致。
- [ ] 相对位置和总尺寸一致。
- [ ] 每件及总三角面一致。
- [ ] 每件材质与贴图对应正确。
- [ ] 没有多余对象。
- [ ] `ROUNDTRIP_VERIFIED=PASS`。

## P6 Studio

- [ ] 首测文件是短英文路径下的顶层主 GLB。
- [ ] 预览中各零件已经拼好。
- [ ] Merge Meshes 关闭。
- [ ] 每件为独立 MeshPart。
- [ ] 贴图正确，没有纯白或串件。
- [ ] PrimaryPart/Root 已设置。
- [ ] 其他零件 Weld 到 Root。
- [ ] 视觉碰撞属性已关闭。
- [ ] Play 后不散架。
- [ ] 用户确认 `STUDIO_ACCEPTED`。

## 交付

- [ ] 顶层主 GLB。
- [ ] 若回退支线已触发，交付 `manual_fallback/` 外置/内嵌/纯网格 FBX 与外置贴图。
- [ ] `*_ROBLOX_EXPORT_vNN.blend`。
- [ ] `textures/`。
- [ ] 快速通道验证 JSON，或完整兼容包 Manifest。
- [ ] 导入说明。
- [ ] 空场景回导报告/截图。
- [ ] Studio Explorer 和实际游戏相机截图。
