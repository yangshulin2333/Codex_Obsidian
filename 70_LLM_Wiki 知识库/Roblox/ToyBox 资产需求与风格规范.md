---
type: concept
domain: roblox
status: evergreen
owner: mixed
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# ToyBox 资产需求与风格规范

## 一句话说明

ToyBox 资产规范负责统一模型、UI 图标、VFX、SFX、占位资产和风格口径，避免后续实现时出现“能跑但看不懂”的素材问题。

## 资产边界

| 内容 | 放置位置 |
|---|---|
| GDD、Brief、规格 | `ToyboxGuardiansDemo` |
| Roblox 工程代码和 Studio 节点 | `ToyboxGuardiansGame` |
| 通用框架 | `RobloxGameFramework` |
| 实际 AssetId | 进入实现后写入游戏配置或 Feature Card |

通用框架不存具体游戏 AssetId。

## 命名规则

建议统一前缀：

```text
TBG_
```

| 类型 | 示例 |
|---|---|
| 玩具模型 | `TBG_Toy_T001_BubbleSoldier_Model` |
| 怪物模型 | `TBG_Monster_M001_TrainingBlockSoldier_Model` |
| Boss 模型 | `TBG_Boss_B001_OldToyGuardian_Model` |
| 拼装台 | `TBG_Prop_AssemblyBench_Model` |
| 掉落物 | `TBG_Drop_SmallGear_Model` |
| UI 图标 | `TBG_UI_Icon_SmallGear` |
| VFX | `TBG_VFX_BubbleProjectile` |
| SFX | `TBG_SFX_AssemblyReveal` |

命名必须能看出用途，不依赖记忆。

## UI 图片尺寸

| 素材 | 建议尺寸 |
|---|---:|
| 资源图标 | 512 x 512 |
| 玩具头像 | 512 x 512 |
| 按钮九宫格背景 | 256 x 128 或 512 x 256 |
| Toast 背景 | 512 x 128 |
| 奖励弹窗背景 | 1024 x 768 |
| 游戏效果图 | 16:9 和 1:1 |
| 移动端 UI mockup | 9:16 |

按钮文字优先用 Roblox `TextLabel`，不要把长文字烘焙进图片。

## 模型基础要求

每个可交互或可战斗模型至少满足：

- Model 名称稳定。
- Pivot 在地面中心或逻辑中心。
- 有 PrimaryPart 或明确根部件。
- 缩放接近最终用途。
- 默认朝向统一。
- 不包含业务脚本。

## 必要节点

| 节点 | 用途 |
|---|---|
| `Root` | 跟随、定位、同步 |
| `Hitbox` | 调试和命中范围 |
| `AttackOrigin` | 近战或冲锋起点 |
| `ProjectileOrigin` | 弹体发射点 |
| `FollowAnchor` | 玩具跟随表现参考 |
| `PreviewCameraPoint` | UI 预览角度参考 |

## 占位资产等级

| 等级 | 用途 |
|---|---|
| Greybox | 内部尺寸、碰撞、流程验证 |
| Readable Placeholder | 正式原型，玩家能看懂功能 |
| Presentation Ready | 截图、10 秒视频、对外演示 |

P0 资产最低必须是 `Readable Placeholder`，不能只用无意义方块。

P0 包括：

- 发条拼装台。
- 泡泡小兵 T001。
- 训练积木兵。
- `SmallGear / WoodBody / BubbleCore` 掉落物。

## 风格关键词

```text
bright toybox
colorful plastic blocks
wind-up clockwork
rounded edges
playful action
clear silhouette
Roblox-friendly
kid-friendly
```

中文口径：

- 明亮玩具箱。
- 彩色积木。
- 发条机械。
- 圆润边缘。
- 低龄友好。
- 轮廓一眼可读。
- 动作反馈清楚。

## 避免方向

- 写实军事。
- 恐怖怪物。
- 脏旧废土。
- 复杂机甲。
- 高细节但缩略图不可读。
- 普通宠物模拟器风格。

## 资源图标识别

| 图标 | 要求 |
|---|---|
| `SmallGear` | 小齿轮轮廓清楚 |
| `WoodBody` | 木质身体或木块形状 |
| `BubbleCore` | 蓝色透明泡泡核心 |
| `Spring` | 弹簧轮廓清楚 |
| `MagnetSheet` | 磁铁或磁片轮廓清楚 |
| `ClockworkCore` | 稀有发条核心感 |
| `ToyFragments` | 碎片感，不和 SmallGear 混淆 |

## 来源

- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\art\ASSET_REQUIREMENTS.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\art\TOY_STYLE_GUIDE.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\UI_ASSET_WORKFLOW.md`
- `D:\AI\Codex\ToyBox\ToyboxGuardiansDemo\docs\ui\SCREEN_LIST.md`

## 相关链接

- [[发条拼装台 UI]]
- [[ToyResultUI 拼装结果弹窗]]
- [[EliteEnemies 与 RareMaterials 稀有材料]]
- [[BossEncounter 与 BossRewardUI]]
- [[Roblox GUI 读取工作流]]
