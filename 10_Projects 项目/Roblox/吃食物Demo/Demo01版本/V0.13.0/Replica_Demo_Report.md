# 新项目 Demo 汇报

## 当前版本

| 项目 | 结论 |
|---|---|
| 当前 Demo | Eat Demo v0.13.0 真实 DataStore 已通过 |
| 运行环境 | Roblox Studio + Rojo，本地源码同步验证已通过 |
| 当前策略 | 手动粘贴阶段结束，后续优先从本地源码修改并通过 Rojo 同步 |
| 资产策略 | 不依赖旧项目无权限动画、音效、图片；先用代码占位表现 |

## 已完成闭环

| 版本 | 功能 | 状态 | 说明 |
|---|---|---|---|
| v0.1.4 | 吃食物 | 已通过 | 靠近食物自动触发，服务端增加 Muscle/Money，客户端刷新 UI，播放占位音效/特效 |
| v0.2.0 | 2x Speed | 已通过 | 点击按钮后服务端设置 WalkSpeed 32，持续 8 秒后恢复 |
| v0.4.5 | 2x Size / 体型同步 | 已通过 | `2x Size` 永久把 Muscle 乘以 2；角色体型跟随 Muscle 增长 |
| v0.5.1 | Auto Collect | 已通过 | 花费 250 Money 购买 60 秒自动收集范围提升，可重复购买续时间 |
| v0.6.0 | Backpack / Food Core | 已通过 | 吃食物获得 Food Core，打开背包后可 Use，消耗 1 个 Food Core 换 Muscle/Money |
| v0.7.0 | Reward 领取 | 已通过 | 点击 Reward 后领取 Muscle +100、Money +50、FoodCore +3，并进入 30 秒测试冷却 |
| v0.8.0 | 公共配置迁移 | 已通过 | `CONFIG` 和 Remote 名改为从 `ReplicatedStorage/Shared` 的 ModuleScript 读取，玩法不变 |
| v0.8.1 | InstanceUtil 迁移 | 已通过 | `ensureFolder` / `ensureRemoteEvent` 改为从 `ReplicatedStorage/Shared/InstanceUtil` 读取，客户端不变 |
| v0.8.2 | DataService 迁移 | 已通过 | `leaderstats` 和 `FoodCore` 的创建/读取改为从 `ServerScriptService/Services/DataService` 读取，客户端不变 |
| v0.8.3 | EatService 迁移 | 已通过 | 食物生成、吃食物校验、奖励结算和重生逻辑改为从 `ServerScriptService/Services/EatService` 执行，客户端不变 |
| v0.8.4 | ShopService 迁移 | 已通过 | `2x Speed`、`2x Size`、`Auto Collect` 改为从 `ServerScriptService/Services/ShopService` 执行，客户端不变 |
| v0.8.5 | InventoryService 迁移 | 已通过 | Bag 打开和 `FoodCore` 使用逻辑改为从 `ServerScriptService/Services/InventoryService` 执行，客户端不变 |
| v0.8.6 | RewardService 迁移 | 已通过 | Reward 领取和冷却逻辑改为从 `ServerScriptService/Services/RewardService` 执行，客户端不变 |
| v0.9.0 | FeedbackController 迁移 | 已通过 | 客户端音效和视觉反馈迁移到 `StarterPlayerScripts/ClientModules/FeedbackController`，服务端不变 |
| v0.9.1 | ScanController 迁移 | 已通过 | 客户端扫描食物和发起吃食物请求迁移到 `StarterPlayerScripts/ClientModules/ScanController`，服务端不变 |
| v0.9.2 | CharacterScaleController 迁移 | 已通过 | 客户端体型平滑、重生恢复和体型更新节流迁移到 `StarterPlayerScripts/ClientModules/CharacterScaleController`，服务端不变 |
| v0.9.3 | ShopController 迁移 | 已通过 | 客户端 Speed、Size、Auto 的按钮点击、倒计时和状态回写迁移到 `StarterPlayerScripts/ClientModules/ShopController`，服务端不变 |
| v0.9.4 | InventoryController 迁移 | 已通过 | 客户端 Bag/FoodCore 的打开、使用和状态回写迁移到 `StarterPlayerScripts/ClientModules/InventoryController`，服务端不变 |
| v0.9.5 | RewardController 迁移 | 已通过 | 客户端 Reward 的领取、冷却和状态回写迁移到 `StarterPlayerScripts/ClientModules/RewardController`，服务端不变 |
| v0.10.0 | UIController 迁移 | 已通过 | 客户端 UI 创建和响应式缩放迁移到 `StarterPlayerScripts/ClientModules/UIController`，服务端不变 |
| v0.11.0 | Rojo Sync 验证 | 已通过 | 本地 `Replica_Demo_RojoKnit` 源码同步进 Studio 后，Play 测试通过 |
| v0.11.1 | 命名和入口整理 | 已通过 | 只整理入口说明、Rojo README、VSCode 工作流，不改玩法；Studio 进入游戏测试无报错 |
| v0.12.0 | DataStore 准备层 | 已通过 | 默认关闭真实保存，先接入 Muscle/Money/FoodCore/RewardReadyAt 的读取和保存接口 |
| v0.12.1 | DataStore 自动保存准备层 | 已通过 | 新增脏数据标记、自动保存循环、保存节流；默认仍不真实写入 DataStore |
| v0.13.0 | 真实 DataStore 测试 | 已通过 | `PersistenceEnabled = true`，Muscle/Money/FoodCore/Reward 冷却保存和读取正常 |

## v0.10.0 当前结构

| 区域 | 当前结构 |
|---|---|
| Shared | `EatDemoConfig`、`RemoteNames`、`InstanceUtil` |
| Server | `EatDemoServer` + `DataService`、`EatService`、`ShopService`、`InventoryService`、`RewardService` |
| Client | `EatDemoClient` + `FeedbackController`、`ScanController`、`CharacterScaleController`、`ShopController`、`InventoryController`、`RewardController`、`UIController` |

## 下一阶段

```text
v0.11.1 命名和入口整理已通过
→ Studio 进入游戏测试无报错
→ Rojo 无新的同步提示
→ 后续优先修改本地 Rojo 源码
→ v0.12.0 DataStore 准备层已通过
→ v0.12.1 自动保存准备层已通过
→ v0.13.0 真实 DataStore 已通过
→ 当前需要做发布前配置检查
→ 下一步建议 v0.14.0 每日奖励正式化
```

## v0.7.0 新增内容

```text
Reward 按钮
→ Msg.RewardClaim
→ EatDemoServer.claimReward
→ 服务端检查 30 秒冷却
→ 成功发放 Muscle +100 / Money +50 / FoodCore +3
→ ServerMsg.RewardResult
→ 客户端刷新 UI 和冷却倒计时
```

说明：

- 现在的 30 秒是测试冷却，不是正式每日奖励。
- 正式每日奖励后面需要 DataStore 保存领取时间。
- 后续如果奖励改成 Robux 内容，必须接 Developer Product，不走 Money 扣费。

## 验证重点

| 检查项 | 期望结果 |
|---|---|
| 标题版本 | 左上角显示 `Eat Demo v0.7.0` |
| Reward 首次点击 | Muscle +100，Money +50，Food x+3 |
| Reward 冷却 | 已通过：按钮显示倒计时，冷却中再次点击不会重复发奖 |
| 冷却结束 | 已通过：倒计时归零后可再次领取 |
| 旧功能回归 | 吃食物、2x Speed、2x Size、Auto、Bag 仍可用 |
| Output | 出现 `[EatDemo] reward claimed ...`，无红色报错 |

## 当前取舍

| 取舍 | 原因 |
|---|---|
| 继续用两个脚本 | 方便你在 Studio 里直接粘贴测试，减少 Rojo/Knit 前置成本 |
| v0.7.0 之后开始迁移框架 | 当前核心闭环已经足够，下一步不再继续把功能堆进两个大脚本 |
| Reward 用 30 秒冷却 | 便于当场验证；正式版再改成每日冷却和 DataStore |
| UI 继续使用 Scale 布局 | 先满足不同设备适配的基本要求，后续迁移后再做组件化 |
| `Animate` 放在 `StarterCharacterScripts` | `Animate` 需要跟随角色生成并等待角色里的 `Humanoid`，不能放在 `StarterPlayerScripts` |
