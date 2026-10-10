---
type: workflow
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-08-14
updated: 2026-08-17
---

# 02 材质、纹理与导入包导出

## 目标

让每个导出 Mesh 具有一套明确、可追踪、可被 Studio 识别的材质和贴图。默认先生成 GLB 主文件；只有 GLB 失败或用户明确要求完整兼容包时，才补 FBX 回退与纯网格诊断。

## 一、每个 Mesh 一套正式材质

最低兼容结构：

```text
Image Texture
  └─ Color -> Principled BSDF / Base Color
Principled BSDF
  └─ BSDF -> Material Output / Surface
```

不要依赖 FBX 迁移以下内容：

- 程序 Noise、HSV Mask、复杂 Mix。
- Blender Coat、程序 Metallic/Roughness。
- 节点动画和动态 Emission。

这些视觉效果需要先烘焙为贴图，或在 Studio 用 `SurfaceAppearance` 重建。

## 二、把贴图真正另存为 PNG/JPG

对每个部件重复：

1. 在 Image Editor 选择该材质使用的图片。
2. `图像 > 另存为`，不是“保存副本”。
3. 保存到最终包的 `textures/`。
4. 文件名使用稳定英文，例如：

```text
HammerHead_BaseColor.png
Handle_BaseColor.png
```

5. 若文件名是 `.png`，保存面板里的格式也必须选择 `PNG`；不能只把 JPEG 改名为 PNG。
6. 回到 Shader Editor，确认节点仍引用刚保存的真实文件。

贴图分辨率按资产画面占比决定。`1024×1024` 是当前武器常用值，不是所有模型的强制值；Roblox 官方支持更高分辨率，但仍应按资产尺寸和性能预算选择。

## 三、保存 Blender 自身资源

```text
文件 > 外部数据 > 打包资源
Ctrl+S
```

这只保证 `.blend` 可迁移，**不等于** FBX 已内嵌贴图。

## 四、导出前选择

1. 切回物体模式。
2. 在 Outliner 中只选正式 Mesh。
3. 不选 Camera、Light、Empty、参考图和旧零件。
4. 先记录选中对象清单并只导出主 GLB。不要在 Studio 结果出现前预先展开 FBX 排障支线。

强制输出到短英文目录，工作源文件可以继续保留在原项目目录：

```text
%USERPROFILE%\Documents\RobloxImportPackages\AssetName_v01\
```

## 五、主交付：GLB

顶层只放一个供 Studio 首测的主文件：

```text
AssetName_facesNNNN_1024tex.glb
```

其中 `NNNN` 必须是导出后三角化的真实总三角面，`1024tex` 替换为实际贴图尺寸。GLB 必须保留多个 Mesh 和各自材质，不得为了导出把零件 `Ctrl+J` 合并，也不得把所有零件强制改成同一张贴图。

Blender 导出要点：

```text
Selected Objects = On
Apply Modifiers = On
Materials = Export
UV / Normals = On
Animations / Skins / Morph = Off（静态刚性模型）
Y Up = On
Format = glTF Binary (.glb)
```

GLB 成功的判定不是“文件已生成”，而是空场景回导后每件仍有正确材质/贴图，并最终由 Studio 接受。

## 六、FBX 回退设置（按需触发）

仅在以下任一条件成立时生成 FBX：

- 主 GLB 在 Studio 失败。
- 用户明确要求 FBX 或完整兼容包。
- 项目交付合同明确要求长期保留 FBX。

FBX 不放在顶层，统一放入 `manual_fallback/`。

### 通用设置

#### Include

```text
Selected Objects = On
Object Types = Mesh only
```

#### Transform

```text
Scale = 1.0
Apply Scalings = FBX Unit Scale
Apply Unit = On
Forward = -Z
Up = Y
Use Space Transform = On
Apply Transform = Off
```

`-Z/Y` 是当前项目基线；新项目改轴向前必须先建立新基线并回导验证。

#### Geometry

```text
Apply Modifiers = On
Triangulate Faces = On
```

#### Armature / Animation

```text
Add Leaf Bones = Off
Bake Animation = Off
```

### 回退 1：外置贴图 FBX

```text
Path Mode = Relative
Embed Textures = Off
```

每个部件的 BaseColor 文件与 FBX 放在同一目录；交接时不能单独移动 FBX。该版本用于 GLB 不被目标 Studio 接受、但仍希望保留贴图时。

### 回退 2：纯网格 FBX

复制导出副本或临时保存材质槽后，清除导出对象的材质槽，导出 `*_mesh_only.fbx`。它只用于诊断：

- 纯网格成功、带贴图格式失败：集中检查容器、材质、图片编码和上传链。
- 纯网格也失败：集中检查网格、对象范围、尺寸、账号/群组权限或 Studio 会话。

### 回退 3：内嵌贴图 FBX

```text
Path Mode = Copy
Embed Textures = On
```

内嵌 FBX 作为最后兼容选项，不再作为默认主交付。Blender 的“打包资源”与 FBX 的“内嵌纹理”仍是两个不同动作。

## 七、多材质映射门

对每个 Mesh 分别记录：

```text
PartName -> MaterialName -> BaseColorFile -> SHA-256
```

如果导出工具把多个零件统一到一个共享材质或只保留第一张贴图，记录 `MULTI_PART_TEXTURE_MAPPING_LOST`，禁止交付。旧版面向单体下载包的脚本不能直接套在已完成语义分件的多贴图装配上。

## 八、导出后立即记录

至少记录：

- 包根目录和主 GLB 路径、大小、SHA-256。
- 外置/内嵌/纯网格 FBX 的路径、大小、SHA-256。
- Blender 版本。
- 正式对象数和名称。
- 每件三角面、材质、贴图文件名和贴图哈希。
- 总尺寸、公共枢轴和单位策略。
- GLB/FBX 的轴向、Global Scale、材质/贴图策略。

模板见 [[EXPORT_MANIFEST_TEMPLATE]]。

## Gate P2/P4 验收

- [ ] 每个 Mesh 只有预期的一套材质。
- [ ] 每张贴图有真实扩展名，格式与扩展名一致。
- [ ] 节点是简单的 BaseColor 直连，或 PBR 已烘焙并记录。
- [ ] 只选中了正式 Mesh。
- [ ] 顶层只有一个短英文名主 GLB；名称包含真实三角面与贴图尺寸。
- [ ] GLB 保留每个 Mesh 的独立材质/贴图映射。
- [ ] 若 GLB 尚未失败且用户未要求完整包，没有提前生成不必要的 FBX。
- [ ] 若回退支线已触发，已生成外置贴图 FBX、纯网格 FBX 和内嵌 FBX。
- [ ] 若外置 FBX 已生成，它与全部贴图保持同目录。
- [ ] 没有动画时 `Bake Animation` 已关闭。
- [ ] 已生成 Manifest，且所有交付文件哈希已记录。

通过后进入 [[03_空场景回导与Studio验收]]。
