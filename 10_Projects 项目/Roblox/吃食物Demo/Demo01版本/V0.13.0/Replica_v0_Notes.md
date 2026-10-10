# 新项目 v0 复刻笔记

## 源码位置

| 用途 | 文件 |
|---|---|
| 服务端源文件 | `D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_Source\ServerScriptService\EatDemoServer.server.luau` |
| 客户端源文件 | `D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_Source\StarterPlayer\StarterPlayerScripts\EatDemoClient.client.luau` |
| v0.7.0 服务端粘贴文件 | `D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_Source\Studio_Paste_EatDemoServer_v0.7.0.lua` |
| v0.7.0 客户端粘贴文件 | `D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_Source\Studio_Paste_EatDemoClient_v0.7.0.lua` |
| v0.8.0 公共配置模块 | `D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_Source\Studio_Paste_EatDemoConfig_v0.8.0.lua` + `Studio_Paste_RemoteNames_v0.8.0.lua` |
| v0.8.0 服务端/客户端粘贴文件 | `D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_Source\Studio_Paste_EatDemoServer_v0.8.0.lua` + `Studio_Paste_EatDemoClient_v0.8.0.lua` |
| v0.8.1 InstanceUtil 粘贴文件 | `D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_Source\Studio_Paste_InstanceUtil_v0.8.1.lua` + `Studio_Paste_EatDemoServer_v0.8.1.lua` |
| v0.8.2 DataService 粘贴文件 | `D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_Source\Studio_Paste_DataService_v0.8.2.lua` + `Studio_Paste_EatDemoServer_v0.8.2.lua` |
| v0.8.3 EatService 粘贴文件 | `D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_Source\Studio_Paste_EatService_v0.8.3.lua` + `Studio_Paste_EatDemoServer_v0.8.3.lua` |
| v0.8.4 ShopService 粘贴文件 | `D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_Source\Studio_Paste_ShopService_v0.8.4.lua` + `Studio_Paste_EatDemoServer_v0.8.4.lua` |
| v0.8.5 InventoryService 粘贴文件 | `D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_Source\Studio_Paste_InventoryService_v0.8.5.lua` + `Studio_Paste_EatDemoServer_v0.8.5.lua` |
| v0.8.6 RewardService 粘贴文件 | `D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_Source\Studio_Paste_RewardService_v0.8.6.lua` + `Studio_Paste_EatDemoServer_v0.8.6.lua` |
| v0.9.0 FeedbackController 粘贴文件 | `D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_Source\Studio_Paste_FeedbackController_v0.9.0.lua` + `Studio_Paste_EatDemoClient_v0.9.0.lua` |
| v0.9.1 ScanController 粘贴文件 | `D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_Source\Studio_Paste_ScanController_v0.9.1.lua` + `Studio_Paste_EatDemoClient_v0.9.1.lua` |
| v0.9.2 CharacterScaleController 粘贴文件 | `D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_Source\Studio_Paste_CharacterScaleController_v0.9.2.lua` + `Studio_Paste_EatDemoClient_v0.9.2.lua` |
| v0.9.3 ShopController 粘贴文件 | `D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_Source\Studio_Paste_ShopController_v0.9.3.lua` + `Studio_Paste_EatDemoClient_v0.9.3.lua` |
| v0.9.4 InventoryController 粘贴文件 | `D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_Source\Studio_Paste_InventoryController_v0.9.4.lua` + `Studio_Paste_EatDemoClient_v0.9.4.lua` |
| v0.9.5 RewardController 粘贴文件 | `D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_Source\Studio_Paste_RewardController_v0.9.5.lua` + `Studio_Paste_EatDemoClient_v0.9.5.lua` |
| v0.10.0 UIController 粘贴文件 | `D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_Source\Studio_Paste_UIController_v0.10.0.lua` + `Studio_Paste_EatDemoClient_v0.10.0.lua` |

## 当前功能范围

```text
进入游戏
→ 服务端生成食物
→ 客户端靠近食物自动请求吃
→ 服务端校验距离并加 Muscle/Money/FoodCore
→ 客户端刷新 UI、音效、占位特效
→ 玩家可点击 Speed / Size / Auto / Bag / Reward
```

## 功能映射

| 旧项目概念 | Demo 实现 | 当前状态 |
|---|---|---|
| `Msg["吃"]` 吃掉落物 | 继续使用同名 Remote，服务端处理吃食物 | 已通过 |
| `Msg["加速"]` 按键加速 | `2x Speed` 按钮，临时 WalkSpeed 32 | 已通过 |
| 体型由 Muscle 驱动 | 吃食物增加 Muscle 后重新计算体型；`2x Size` 永久 Muscle * 2 | 已通过 |
| 自动收集 | `Auto` 按钮，Money 购买 60 秒扩大吸收范围 | 已通过 |
| 背包物品 | `FoodCore` 数量，Bag 面板可 Use | 已通过 |
| 每日/限时奖励 | `Reward` 按钮，30 秒测试冷却 | 已通过 |
| 公共配置迁移 | `CONFIG` 和 Remote 名从 `ReplicatedStorage/Shared` 读取 | 已通过 |
| InstanceUtil 迁移 | `ensureFolder` 和 `ensureRemoteEvent` 从 `ReplicatedStorage/Shared/InstanceUtil` 读取 | 已通过 |
| DataService 迁移 | `leaderstats` 和 `FoodCore` 的创建/读取从 `ServerScriptService/Services/DataService` 读取 | 已通过 |
| EatService 迁移 | 食物生成、吃食物校验、奖励结算和重生逻辑从 `ServerScriptService/Services/EatService` 执行 | 已通过 |
| ShopService 迁移 | `2x Speed`、`2x Size`、`Auto Collect` 从 `ServerScriptService/Services/ShopService` 执行 | 已通过 |
| InventoryService 迁移 | Bag 打开和 `FoodCore` 使用逻辑从 `ServerScriptService/Services/InventoryService` 执行 | 已通过 |
| RewardService 迁移 | Reward 领取和冷却逻辑从 `ServerScriptService/Services/RewardService` 执行 | 已通过 |
| FeedbackController 迁移 | 客户端音效和视觉反馈从 `StarterPlayerScripts/ClientModules/FeedbackController` 执行 | 已通过 |
| ScanController 迁移 | 客户端扫描附近食物和发起吃食物请求从 `StarterPlayerScripts/ClientModules/ScanController` 执行 | 已通过 |
| CharacterScaleController 迁移 | 客户端体型平滑、重生恢复和体型更新节流从 `StarterPlayerScripts/ClientModules/CharacterScaleController` 执行 | 已通过 |
| ShopController 迁移 | 客户端 Speed、Size、Auto 的按钮点击、倒计时和状态回写从 `StarterPlayerScripts/ClientModules/ShopController` 执行 | 已通过 |
| InventoryController 迁移 | 客户端 Bag/FoodCore 的打开、使用和状态回写从 `StarterPlayerScripts/ClientModules/InventoryController` 执行 | 已通过 |
| RewardController 迁移 | 客户端 Reward 的领取、冷却和状态回写从 `StarterPlayerScripts/ClientModules/RewardController` 执行 | 已通过 |
| UIController 迁移 | 客户端 UI 创建和响应式缩放从 `StarterPlayerScripts/ClientModules/UIController` 执行 | 已通过 |

## 当前 Rojo 状态

`D:\AI\Codex\Codex_ProjectFixed\Replica_Demo_RojoKnit` 已同步到当前 v0.10.0 结构。

已清理早期占位文件：

```text
src/StarterPlayer/StarterPlayerScripts/Client.client.luau
src/StarterPlayer/StarterPlayerScripts/Controllers/
src/ServerScriptService/Server.server.luau
src/ServerScriptService/Services/PlayerStatsService.luau
```

v0.11.0 Rojo Sync 已通过。

后续新增或修改功能，优先改本地 Rojo 目录里的源码，再同步到 Studio，不再优先手动粘贴大段脚本。

v0.11.1 命名和入口整理已通过：

```text
不重命名 Studio 里的 EatDemoServer / EatDemoClient
只给入口脚本加职责说明
更新 Rojo README
新增 VSCode + Rojo 工作流说明
Studio 进入游戏测试无报错
```

v0.12.0 已生成 DataStore 准备层：

```text
版本号改为 v0.12.0
DataService 新增保存/读取接口
Reward 冷却改成可保存时间戳
玩家离开和服务器关闭时会调用 SavePlayer
当前 PersistenceEnabled = false，不会真实写入 DataStore
```

v0.12.1 自动保存准备层已通过：

```text
版本号改为 v0.12.1
DataService 新增 MarkDirty
Muscle / Money / FoodCore 变化会标记为需要保存
DataService 新增 StartAutoSave
玩家进入后启动自动保存循环
玩家离开和服务器关闭时强制保存
当前 PersistenceEnabled = false，不会真实写入 DataStore
Studio Play 测试无异常
```

v0.13.0 真实 DataStore 测试已通过：

```text
版本号改为 v0.13.0
PersistenceEnabled 改为 true
需要在云端项目 `Demo01` 中测试
需要 Studio 的“允许 Studio 访问 API 服务”保持开启
Muscle / Money / FoodCore 可以保存并读取
Reward 冷却可以保存并读取
```

## v0.7.0 改动

| 模块 | 改动 |
|---|---|
| Server | 新增 `Msg.RewardClaim` 和 `ServerMsg.RewardResult` |
| Server | 新增 `rewardReadyAtByPlayer`，服务端校验 30 秒冷却 |
| Server | 成功领取时 `Muscle +100`、`Money +50`、`FoodCore +3` |
| Client | 新增 `Reward` 按钮和倒计时状态 |
| Client | 收到 `RewardResult` 后刷新 Muscle/Money/FoodCore 和体型 |
| UI | 面板继续使用 Scale 布局，并略微增大以容纳新按钮 |

## 当前不做的事

| 不做 | 原因 |
|---|---|
| 不复用旧项目动画/音效 AssetId | 本地副本权限不可靠，旧资源只作为结构参考 |
| 不接真实每日奖励 DataStore | 当前还是 Demo 验证阶段，先用 30 秒冷却验证链路 |
| 不接 Robux 购买 | 后面需要 Developer Product 单独接入 |
| 不立即拆成 Knit 项目 | 手动粘贴阶段先保证功能稳定；功能冻结后再迁移 |

## 下一个结构化目标

v0.7.0 已通过，下一步进入“框架迁移准备”：

```text
EatDemoServer
→ DataService
→ EatService
→ ShopService
→ InventoryService
→ RewardService

EatDemoClient
→ EatController
→ ShopController
→ InventoryController
→ RewardController
→ UIController
```
