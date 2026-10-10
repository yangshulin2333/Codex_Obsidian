# 新对话入口：Roblox 武器模型工作流

更新时间：2026-06-07

> 如果用户只是给了 3D 模型网站下载目录或 FBX，让 Codex 生成 Roblox 可导入版，请优先读：
> `D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\handoff\NEXT_CHAT_HANDOFF_模型下载直接打包.md`

## 先读这三个文件

1. `D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\README.md`
2. `D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\STATUS.md`
3. `D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\Roblox导入_直接可用打包流程.md`

## 这套工作流怎么分工

用户自己做武器模型：

```text
参考图 / Prompt / Meshy 生成 / 视觉判断 / Roblox Studio 导入测试
```

Codex 负责机械处理：

```text
检查文件
解压 Meshy 下载包
压缩贴图
重新打包 FBX/GLB
排查 Roblox 导入失败
更新工作记录
```

## 新武器开始时，用户只需要给 Codex

```text
Meshy 或其他 3D 模型网站下载文件路径 / 下载目录
```

例如：

```text
C:\Users\14176\Desktop\武器\模型下载\某个下载目录
```

## Codex 应该做什么

运行：

```powershell
& "D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\scripts\Prepare-RobloxWeaponImport.ps1" `
  -InputPath "用户给的文件或目录路径" `
  -Name "武器名或编号" `
  -OutputRoot "C:\Users\14176\Desktop\weapon_upload"
```

然后给用户这几个可点击路径：

```text
*_direct_1024tex.fbx
*_direct_1024tex.glb
*_mesh_only.fbx
*_texture_1024.jpg
```

## 注意

不要默认让用户分开导入模型和贴图。

优先目标是：

```text
一个 FBX 或 GLB 直接导入 Roblox。
```

分开导入只作为最后保底。

## 可复制给新对话的话

```text
请先读 D:\SVN\Project_Analysis_Package\Roblox 武器模型制作工作流\handoff\NEXT_CHAT_HANDOFF_第二把武器.md。
我自己做武器模型。你负责沿用工作流，把我给你的模型下载目录或 FBX 文件打包成 Roblox 直接可导入格式，并在失败时排查原因。
```
