# outputs

本目录保留历史输出和显式 `-OutputRoot` 指向工作流时产生的输出。

当前默认 Studio 导入包输出位置已经改为：

```text
%USERPROFILE%\Documents\RobloxImportPackages
```

这样可以减少 Roblox Studio 读取 FBX 外部贴图时受 Obsidian 中文长路径影响的概率。

每个模型会生成一个独立目录：

```text
输出名_roblox_direct
```

目录内保留给 Roblox 导入的文件：

```text
输出名_faces实际面数_direct_1024tex.fbx
输出名_faces实际面数_direct_1024tex.glb
输出名_faces实际面数_embedded_1024tex.fbx
输出名_faces实际面数_mesh_only.fbx
输出名_faces实际面数_texture_1024.jpg
README_import_order.txt
```

当前 FBX 尺寸规则：

```text
fbx_scale_mode=match_glb_world_scale
fbx_dimensions=(x, y, z)
glb_dimensions=(x, y, z)
fbx_glb_scale_match=True
```

如果 FBX 与 GLB 任一轴尺寸不一致，当前脚本会直接失败，不生成可交付状态。
