# 新对话入口：模型下载后直接打包成 Roblox 可导入版

更新时间：2026-06-07

## 先读哪些文件

项目根目录已有 `D:\SVN\AGENTS.md`，新对话应先遵守其中的 Roblox 武器模型打包规则。

新对话开始后，先读：

1. `D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\README.md`
2. `D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\STATUS.md`
3. `D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\Roblox导入_直接可用打包流程.md`

## 用户的真实目标

用户后续会从 Meshy 或其他 3D 模型网站下载武器模型，然后直接把路径发给 Codex。

用户希望 Codex 直接把模型处理成 Roblox Studio 可导入版本。

用户不希望 Codex 停在教程层面，也不希望让用户手动拆包、手动找贴图、手动分开导入。

## 最高优先级触发条件

如果用户消息里同时出现：

1. 一个本地模型路径，通常包含 `.fbx`、`.glb`、`texture_fbx`、`Meshy_AI`、`模型下载` 等字样。
2. “生成可直接导入roblox版本 / Roblox 可导入版 / 可直接导入 Roblox / 生成 Roblox 可导入 FBX”这类意图。

新对话必须直接执行下面的固定命令。不要临时写 Python，不要沿用 `Roblox_Ready`，不要把 PBR 多贴图全部嵌入 FBX，不要要求用户自己找贴图。

## 输入可能是什么

用户给的路径可能是：

1. 下载目录。
2. 真 FBX 文件。
3. 表面是 `.fbx`、实际是 ZIP 压缩包的 Meshy 下载文件。

新版脚本已经支持这三种输入。

## 直接执行的命令

```powershell
& "D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\scripts\Prepare-RobloxWeaponImport.ps1" `
  -InputPath "用户给的文件或目录路径" `
  -Name "武器名或编号" `
  -OutputRoot "C:\Users\14176\Desktop\weapon_upload"
```

如果用户没有明确给编号，就根据目录名或文件名生成 `-Name`。

## 脚本会自动做什么

1. 判断输入是目录还是文件。
2. 如果是目录，自动找主要 FBX。
3. 自动排除 `Roblox_Ready`、`Roblox_Import*`、`.fbm`、`*_roblox_direct` 等历史输出目录。
4. 如果是伪 FBX ZIP，自动解压。
5. 自动选择颜色贴图，避开 normal、roughness、metallic、emissive 等贴图。
6. 把颜色贴图压缩成 `1024x1024 jpg`。
7. 用 Blender 后台重新绑定材质。
8. 输出：
   - `*_direct_1024tex.fbx`
   - `*_direct_1024tex.glb`
   - `*_mesh_only.fbx`
   - `*_texture_1024.jpg`
   - `README_import_order.txt`

## 成功后必须验证

看脚本输出或输出目录，确认：

```text
ROBLOX_WEAPON_EXPORT_OK
faces=实际面数
direct_fbx generated
direct_glb generated
mesh_only_fbx generated
texture=1024x1024 RGB JPG
```

如果面数略高于 `3000-4000`，先交付给用户做 Roblox 导入测试。除非用户明确要求严格压面，否则不要先做 LOD。

## 回复用户的格式

必须给可点击链接，不要只给裸路径。

示例：

```md
已生成 Roblox 直接导入版：

- [打开输出文件夹](<C:\Users\14176\Desktop\weapon_upload\武器名_roblox_direct>)
- [优先导入 FBX](<C:\Users\14176\Desktop\weapon_upload\武器名_roblox_direct\武器名_direct_1024tex.fbx>)
- [备用 GLB](<C:\Users\14176\Desktop\weapon_upload\武器名_roblox_direct\武器名_direct_1024tex.glb>)
- [保底 mesh-only FBX](<C:\Users\14176\Desktop\weapon_upload\武器名_roblox_direct\武器名_mesh_only.fbx>)
- [压缩贴图 JPG](<C:\Users\14176\Desktop\weapon_upload\武器名_roblox_direct\武器名_texture_1024.jpg>)

验证结果：`faces=实际面数`，贴图已压成 `1024x1024 RGB JPG`。
Roblox 里先导入 `*_direct_1024tex.fbx`，失败再试 `GLB`，最后才用 `mesh_only + 手动贴图`。
```

## 导入失败时怎么接

如果 Roblox 报 `base_color_texture` 或贴图上传失败：

1. 让用户先试 `*_direct_1024tex.glb`。
2. 如果仍失败，试 `*_mesh_only.fbx`。
3. 再手动上传 `*_texture_1024.jpg`。
4. 如果 mesh-only 也失败，再排查 FBX 版本、面数、模型结构或 Roblox 导入器兼容。

## 工作记录

每次成功或失败，都把输入、输出、验证结果、失败原因和处理方式写入：

```text
D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\工作记录.md
```

具体模型案例只放在 `工作记录.md`，不要写成主流程依赖。

## 注意

这份交接只负责“下载模型转 Roblox 可导入包”。如果用户是在做三视图或 Prompt，才回到 `Prompt_素材库.md` 和三视图流程。
