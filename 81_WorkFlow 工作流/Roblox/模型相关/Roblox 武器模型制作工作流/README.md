# Roblox 武器模型制作工作流

更新时间：2026-07-29

## 新对话先看这一段

本目录是武器资产的任务路由入口，分成三条互相解耦的流程：

```text
效果图 / 多视图生成
-> 剑类效果图到多视图_V2.md

Tripo 低模审计 / 局部修复
-> Tripo武器低模清理与局部纹理修复流程.md

Roblox 直接导入打包
-> ../Roblox 可直接导入版打包流程/
```

当前目录不再维护第二份完整打包实现。`scripts/Prepare-RobloxWeaponImport.ps1` 只作为兼容入口，转发到相邻的通用打包工作流，避免规则分叉。

## 固定触发语句

用户以后可能只发一条类似这样的消息：

```text
C:\Users\14176\Desktop\武器\模型下载\某个FBX或目录 生成可直接导入roblox版本
```

只要看到“FBX/GLB/模型下载目录路径”加“生成可直接导入 Roblox 版本 / Roblox 可导入版 / 可直接导入roblox”这类说法，Codex 必须直接运行固定脚本。不要重新写临时脚本，不要输出 `Roblox_Ready`，不要让用户手动找贴图。

用户以后会把 3D 模型网站下载的武器模型路径直接发给 Codex，路径可能是：

1. 一个具体 `.fbx` 文件。
2. 一个包含 `.fbx` 和贴图的下载目录。
3. 一个表面是 `.fbx`、实际是 ZIP 压缩包的 Meshy 下载文件。

Codex 的默认动作不是讲教程，而是直接打包成 Roblox 可导入版本：

```powershell
& "{WORKFLOW_ROOT}\scripts\Prepare-RobloxWeaponImport.ps1" `
  -InputPath "用户给的文件或目录路径" `
  -Name "武器名" `
  -TextureSize 512
```

如果用户没有给武器名，Codex 可以根据目录名或文件名自动命名；如果用户给了明确编号或名称，就用用户给的名称。

## 这套流程解决什么

把 Tripo、Meshy 或其他 3D 模型网站下载的武器模型，稳定整理成 Roblox Studio 能导入、能预览、能继续挂到 Tool / Accessory 的文件。

一句话：

```text
用户负责提供模型路径和在 Roblox Studio 里看效果；Codex 负责识别文件、只读审计、必要时局部修复、打包、排错和记录。
```

## 三视图参考图生成规则

如果用户提供武器截图，并要求“生成同系列改款三视图 / 用于 3D AI 模型生成 / 注意图片一致性”，这不是 FBX / GLB 打包任务，应走独立三张三视图流程：

剑类新任务从 2026-07-29 起优先使用：

```text
剑类效果图到多视图_V2.md
```

该入口采用“效果图确认 -> 视觉 DNA 与几何锁 -> 严格正面 -> 工程多视图 -> 联系表”的顺序，并复用通用 AI 道具参考图工作流。它只负责图片参考，不改变本目录现有 FBX / GLB 打包流程。

旧三视图流程保留用于历史项目和兼容：

```text
三视图生成_独立三张流程.md
```

默认交付三张独立图片：

```text
*_front_view.png
*_side_view.png
*_back_view.png
```

不要默认只生成一张三视图合图再裁切。合图可以作为人工检查用的附加文件，但最终给 3D AI 的主交付必须是三张独立视角图。

从 2026-06-15 起，三视图任务必须先保护风格一致性。用户强调“重新生成 / 风格变了 / 用于 3D AI 建模”时，正式交付不要默认调用内置图像生成；优先使用本地可控渲染或绘制。内置图像生成如果出现无关信息图、图表、人物、咖啡、税表、文字海报或非武器内容，立即废弃该路线，不要把错误图写入 `generated_views`，也不要在最终回复中作为交付展示。

推荐输出目录：

```text
{WORKFLOW_ROOT}\generated_views\武器名_日期_three_views
```

## 每把武器固定流程

1. 用户提供一个模型路径，可以是目录、真 FBX、或伪 FBX 压缩包。
2. 若用户只要求直接打包，运行通用 `Prepare-RobloxWeaponImport.ps1`。
3. 若用户指出几何、UV 或纹理瑕疵，先进入只读审计，不直接重画或减面。
4. 局部纹理修复必须从原 Base Color 开始，只修改已确认的目标面。
5. 每次修复同时检查正面、侧面和异常面，防止修底面时污染侧面。
6. 保留 2K Blender 母版，另生成 512 Roblox 游戏版。
7. 导出后回导 FBX / GLB，核对三角面、UV 和贴图尺寸。
8. Codex 验证 `ROBLOX_WEAPON_EXPORT_OK`、面数、贴图尺寸和输出文件。
9. Codex 用可点击链接给用户导入文件，不只给裸路径。
10. 用户在 Roblox Studio 里按优先级导入和验收。
11. 如果失败，用户发截图或报错，Codex继续排查。
12. Codex 把个案结果写入 `工作记录.md`，主流程保持通用。

## 用户负责什么

- 提供下载目录或 FBX 文件路径。
- 在 Roblox Studio 里导入测试。
- 判断外形、贴图、比例是否能接受。
- 把失败截图或报错发给 Codex。

## Codex 负责什么

- 自动判断输入是目录、真 FBX、还是伪 FBX 压缩包。
- 从目录里自动选择主要 FBX。
- 从同目录或子目录里自动选择颜色贴图。
- 自动排除 `Roblox_Ready`、`Roblox_Import*`、`.fbm`、`*_roblox_direct` 等历史输出目录，避免误选失败文件。
- 避开 normal、roughness、metallic、emissive 等非颜色贴图。
- 把贴图压缩到默认 `512x512`，降低内存和上传成本。
- 用 Blender 后台重新绑定材质。
- 输出直接可导入的 FBX / GLB。
- 保留 mesh-only 保底 FBX 和压缩贴图。
- 给用户可点击打开的输出文件链接。
- 更新工作记录和流程文档。

## 不再默认做什么

- 不让用户自己分开导入模型和贴图，除非直接 FBX / GLB 都失败。
- 不直接把 Meshy 原始 `.fbx` 拖进 Roblox。
- 不停留在“你可以试试”的说明层面。
- 不大面积手工修模型，除非用户明确要修。
- 不默认把高模硬压到 3000 面后说可用。

## 目标规格

- 面数：先保留已通过的低模几何；需要优化时再建立独立性能任务，不盲目压到固定面数。
- 贴图：Blender 修复母版可保留 2K，Roblox 默认交付 `512x512`；近景确认模糊后才测试 1024。
- 风格：Roblox 低模游戏资产。
- 交付：优先一个文件直接导入。

减面前后必须分别保存并在目标游戏中对比。性能预算不能代替轮廓、UV 和法线验收。

## 输出文件

通用脚本默认输出目录一般是：

```text
%USERPROFILE%\Documents\RobloxImportPackages\武器名_roblox_direct
```

重点文件：

```text
武器名_faces实际面数_direct_512tex.fbx     优先导入
武器名_faces实际面数_direct_512tex.glb     FBX 失败时备用
武器名_faces实际面数_embedded_512tex.fbx   兼容性排查
武器名_faces实际面数_mesh_only.fbx          贴图仍失败时保底
武器名_faces实际面数_texture_512.jpg         手动贴图备用
README_import_order.txt                      本次打包说明
```

## Roblox 导入顺序

1. 先导入 `*_direct_512tex.fbx`，并保持 512 贴图在同一目录。
2. 如果失败，导入 `*_direct_512tex.glb`。
3. 如需排查 FBX 兼容性，再试 `*_embedded_512tex.fbx`。
4. 如果还是失败，导入 `*_mesh_only.fbx`，再手动上传 `*_texture_512.jpg`。

## 关键验证点

Codex 完成后至少要报告：

```text
faces=实际面数
texture=512x512 RGB JPG 或 PNG
source_texture_mode=external_file 或 embedded_packed_image
direct_fbx generated
direct_glb generated
embedded_fbx generated
mesh_only_fbx generated
```

最终回复必须提供可点击链接，例如：

```md
- [打开输出文件夹](<{DELIVERY_ROOT}\武器名_roblox_direct>)
- [优先导入 FBX](<{DELIVERY_ROOT}\武器名_roblox_direct\武器名_faces实际面数_direct_512tex.fbx>)
```

## 文件说明

- `README.md`：总流程，新对话先读这个。
- `STATUS.md`：当前验证结果和下一步规则。
- `Roblox导入_直接可用打包流程.md`：一条命令打包细节。
- `Tripo武器低模清理与局部纹理修复流程.md`：只读审计、局部贴图修复、回导和 Studio 验收。
- `Prompt_素材库.md`：三视图和低模 Prompt。
- `三视图生成_独立三张流程.md`：参考图生成时默认交付正视、侧视、背视三张独立图。
- `三视图失败复盘_风格一致性.md`：用户反馈风格不对时必须先读的纠偏规则。
- `Studio_纯色预览棚使用说明.md`：Roblox 预览棚说明。
- `工作记录.md`：每把武器的尝试结果。
- `handoff/NEXT_CHAT_HANDOFF_模型下载直接打包.md`：给新对话复制的交接入口。
- `handoff/NEXT_CHAT_HANDOFF_三视图独立生成.md`：给新对话复制的三视图参考图生成入口。
