---
type: workflow
domain: roblox
status: active
owner: mixed
source: mixed
created: 2026-06-15
updated: 2026-07-29
---

# 当前状态

## 三条正式入口

```text
效果图 / 多视图
-> 剑类效果图到多视图_V2.md

Tripo 低模 / UV / 局部纹理修复
-> Tripo武器低模清理与局部纹理修复流程.md

Roblox 导入打包
-> ../Roblox 可直接导入版打包流程/
```

三条流程互相交接，但不互相复制实现。

## 当前默认合同

### 图片阶段

- 效果图确认后再生成工程多视图。
- 正交视图遵守 XYZ 比例锁。
- top / bottom 是沿武器长轴观察的轴向端视。
- left45 / right45 必须是整把武器刚体旋转。

### Blender 修复阶段

- 先只读审计，记录网格、三角面、UV、材质和 Base Color。
- 原始 Tripo 外观大部分可用时，禁止全图重绘。
- 只修已确认的异常面。
- 每次同时检查正面、侧面和异常面。
- 用户要求实时观察时，操作当前可见 Blender MCP 会话。
- 保留 2K 母版，另生成 512 游戏版。

### Roblox 打包阶段

- 默认 Base Color 为 `512x512`。
- 默认标准包输出到 `%USERPROFILE%\Documents\RobloxImportPackages`，也允许显式传入 `{DELIVERY_ROOT}`。
- 优先外部相对贴图 FBX。
- GLB 是贴图或 FBX 兼容失败时的第二选择。
- 内嵌 FBX只用于兼容性排查。
- mesh-only FBX + 手动贴图是最后保底。

## 当前脚本边界

权威实现：

```text
../Roblox 可直接导入版打包流程/scripts/Prepare-RobloxWeaponImport.ps1
```

武器目录兼容入口：

```text
scripts/Prepare-RobloxWeaponImport.ps1
```

兼容入口只负责参数转发，不再保留第二份导出逻辑。

## 当前验证案例

2026-07-29 完成一把 Tripo 低模长剑的局部纹理修复和标准打包：

```text
mesh_count=1
vertices=1466
triangles=2928
uv_layers=UVMap
master_texture=2K
roblox_texture=512
geometry_modified=false
```

修复策略：

```text
保留 Tripo 正面、背面和侧面
-> 只修朝下底面与柄头底盖
-> 55° 侧视复核
-> 严格底视复核
-> FBX / GLB 回导
-> 通用脚本生成标准 Roblox 包
```

标准打包脚本返回：

```text
ROBLOX_WEAPON_EXPORT_OK
faces=2928
source_texture_mode=external_file
direct_fbx_texture_mode=external_relative
fbx_scale_mode=match_glb_world_scale
fbx_glb_scale_match=True
```

## 下一步门禁

这把剑还需要在目标 Roblox 游戏中完成人工验收：

- [ ] direct 512 FBX 导入成功。
- [ ] 512 贴图自动绑定。
- [ ] 正面、侧面和底面与 Blender 一致。
- [ ] 角色手持比例合理。
- [ ] 碰撞和物理属性符合项目规则。
- [ ] 决定使用 Tool、Accessory 或项目装备系统。

Studio 未验收前，状态是“Blender 与打包通过”，不是“游戏内最终完成”。
