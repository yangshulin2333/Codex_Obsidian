---
created: 2026-05-12
type: GPT
---

# Roblox《小小英雄/横扫千军 Roblox 版》项目交接知识文档（AI 可读版）

> 更新时间：2026-05-12  
> 目的：把目前已经和 AI 协作完成的 Roblox 游戏功能、目录结构、代码分层、UI 约定、已踩坑问题、下一步开发方向整理成一份“交给新同事或新的 AI 后，能快速接手”的上下文文档。  
> 重要提醒：本项目由 Roblox 新手逐步开发，后续任何 AI 辅助都必须遵守“新手可落地、一步一步、不跳步骤、严格适配现有 UI 结构”的原则。

---

## 0. 给后续 AI 的使用说明

如果你是后续接手此项目的 AI，请先完整阅读本文，再给代码建议。不要默认使用你自己的标准 UI 结构，必须以本文中的实际项目结构为准。

后续回答必须遵守：

1. **先确认现有结构，再写代码。** 用户经常已经搭好了 UI 和目录，不能擅自假设新的层级。
2. **UI 资源不需要你提供。** 用户会自己找背景、图标、按钮素材。你只需要说明需要哪些 UI 对象、对象类型、名字、放在哪里。
3. **创建对象必须说清楚数据结构。** 例如：`Frame / TextButton / ImageLabel / TextLabel / ScrollingFrame / ModuleScript / Script / LocalScript`。
4. **不要跳步骤。** 推荐顺序：UI 层级 → 配置表 → Remote → 服务端 → 客户端 → Bootstrap 接入 → 测试流程。
5. **不要把客户端当成权威。** 奖励、扣钱、穿戴、采集、传送等必须由服务端校验。
6. **代码要模块化，易迁移。** 尽量保持 `Shared / Server / Client / Workspace / StarterGui` 分层。
7. **用户是 Roblox 新手。** 解释要讲“为什么这么做”，但不要长篇理论压垮节奏。
8. **当前项目 UI 很多是手工搭的，不是代码生成。** 代码应该 Clone 模板、填数据、绑定按钮，不应该用代码硬生成丑 UI。
9. **如果用户发截图，要严格照截图里的 Explorer 层级适配。** 之前曾出现 AI 无视 `InventoryGui` 实际结构的问题，导致用户不满。

---

## 1. 项目定位

项目参考《横扫千军》的三国养成玩法，但第一版不照搬复杂商业系统，而是做 Roblox 新手可落地的 MVP。

当前项目定位：

> 一个参考三国养成玩法结构的 Roblox 单地图游戏。第一阶段先实现主公选择、主城传送、资源采集、商店购买、背包装备展示和穿戴，形成“选主公 → 主城 → 资源区 → 采集 → 回主城 → 商店购买 → 背包查看装备”的基础闭环。后续再接副本、战斗、奖励、升级、装备强化和数据持久化。

第一版优先做：

- 选主公 / 阵营
- 主城出生
- 资源区采集
- 传送点联调
- HUD 真实数据显示
- 主界面 UI 框架
- 商店购买装备
- 背包显示装备 / 穿戴装备

第一版暂缓：

- 武将抽卡
- 武将升星/技能/羁绊
- 战马系统
- 部曲系统
- 科技树
- 主城建筑升级
- 宝石 / 套装 / 精炼
- PvP
- 复杂副本实例
- 数据持久化 ProfileService

---

## 2. 当前已实现功能总览

截至本文整理时，项目已完成或基本完成以下内容：

### 2.1 已完成：项目迁移与工程结构

项目已经迁移到新的 Roblox 项目中，并经过测试。当前使用明确的工程分层：

- `ReplicatedStorage`：共享配置、常量、工具、Remotes
- `ServerScriptService`：服务端 Bootstrap、Managers、Services、Systems
- `StarterPlayerScripts`：客户端 Bootstrap、Controllers、UI 工具
- `StarterGui`：MainHUD、选主公、传送提示、采集提示、商店、背包等 UI
- `Workspace`：地图、出生点、资源点、传送点、商店交互点
- `ServerStorage`：后续存副本地图、怪物、装备模板等服务端资产

### 2.2 已完成：RemoteManager

`RemoteManager` 负责根据 `RemoteNames` 自动创建：

- `ReplicatedStorage.Remotes.Events`
- `ReplicatedStorage.Remotes.Functions`

已使用过的 Remote 包括：

```text
Events:
- SelectLordRequest
- TeleportRequest
- DungeonRequest
- ResourceCollectRequest
- PlayerDataUpdate
- BuyItemRequest
- EquipItemRequest
- UnequipItemRequest

Functions:
- GetPlayerData
```

关键经验：

- `RemoteManager.Init()` 必须在依赖 Remote 的系统之前执行。
- `ServerBootstrap` 初始化顺序必须保证：先 Remote，再 DataService，再各 Systems。

### 2.3 已完成：UIManager + MainMenuController

`UIManager`：

- 统一注册窗口
- 打开窗口
- 关闭窗口
- 关闭全部窗口
- 绑定弹窗关闭按钮

主要接口：

```lua
UIManager.Open("InventoryGui")
UIManager.Close("InventoryGui")
UIManager.CloseAll()
UIManager.Toggle("InventoryGui")
```

`MainMenuController`：

- 负责监听 `MainHUD` 上的按钮
- 调用 `UIManager` 打开对应界面

注意：由于 Roblox 启动时 `PlayerGui` 可能尚未完整复制，后续查找 UI 对象时更推荐：

```lua
playerGui:WaitForChild(guiName, 3)
current:WaitForChild(childName, 3)
```

而不是单纯 `FindFirstChild`。

### 2.4 已完成：LoadingGui / LoadingController

为解决 UI 初始化等待问题，已增加加载界面：

```text
StarterGui
└─ LoadingGui
   └─ Root
      ├─ Background
      ├─ TitleLabel
      └─ StatusLabel
```

`LoadingController` 负责：

- 初始化加载界面
- 设置加载文字
- 加载结束后隐藏

典型流程：

```text
进入游戏
→ 显示 LoadingGui
→ 初始化 UIManager / HUD / 选主公 / 传送 / 资源 / 商店等 Controller
→ 隐藏 LoadingGui
```

### 2.5 已完成：选主公系统

功能：

- 玩家进入游戏后显示 `SelectLordGui`
- 玩家选择魏 / 蜀 / 吴
- 客户端 `SelectionController` 发送 `SelectLordRequest`
- 服务端 `SelectionSystem` 记录玩家阵营
- `DataService` 写入玩家数据
- 玩家传送到对应主城/出生点

相关模块：

```text
Client:
- SelectionController

Server:
- SelectionSystem
- DataService
- WorldTeleportService / TeleportSystem 相关传送能力

Shared:
- FactionConfig
- RemoteNames
```

已验证：选主公成功后 Output 有日志，玩家能传送到对应地点。

### 2.6 已完成：HUD 接真实数据

之前 HUD 是假数据，现在已经接入服务端真实数据。

流程：

```text
DataService 创建玩家数据
→ 客户端 HUDController 调用 GetPlayerData
→ 服务端返回玩家数据
→ HUDController 更新 Gold / Wood / Stone / Level
→ 服务端数据变化时 FireClient(PlayerDataUpdate)
→ HUD 自动刷新
```

相关 Remote：

```text
PlayerDataUpdate = RemoteEvent
GetPlayerData = RemoteFunction
```

当前默认玩家数据大致包含：

```lua
{
    HasSelectedLord = false,
    Faction = nil,
    LordId = nil,

    Level = 1,
    Exp = 0,

    Gold = 100,
    Wood = 20,
    Stone = 15,

    Inventory = {},
    Equipped = {
        Weapon = nil,
        Armor = nil,
    },

    UnlockedDungeons = {
        TestDungeon = true,
    },
}
```

### 2.7 已完成：传送系统

功能：

- 玩家靠近传送点 Part
- `TeleportController` 显示提示，例如“按 E 前往资源区”
- 玩家按 E
- 客户端发送 `TeleportRequest`
- 服务端 `TeleportSystem` 校验请求
- 玩家被传送到目标点

相关场景结构：

```text
Workspace
└─ Interactables
   └─ Teleporters
      ├─ WeiToResourceZone
      ├─ ShuToResourceZone
      ├─ WuToResourceZone
      ├─ ResourceToCity
      ├─ WeiToDungeon
      ├─ ShuToDungeon
      └─ WuToDungeon
```

已验证：选主公后能传送，资源区和主城之间可往返。

### 2.8 已完成：资源采集系统

功能：

- 资源区有树和矿
- 玩家靠近资源点显示采集提示
- 玩家按 E 采集
- 显示采集进度条
- 客户端发送 `ResourceCollectRequest`
- 服务端 `ResourceSystem` 校验资源类型、距离、冷却
- 成功后调用 `DataService.AddCurrency`
- HUD 自动刷新

资源点结构：

```text
Workspace
└─ Interactables
   └─ ResourceNodes
      ├─ Trees
      │  ├─ Tree_01
      │  └─ Tree_02
      └─ Rocks
         ├─ Rock_01
         └─ Rock_02
```

资源点 Attribute：

```text
Tree_01.ResourceType = "Tree"
Rock_01.ResourceType = "Rock"
```

相关 UI：

```text
StarterGui
├─ GatherPromptGui
│  └─ Root
│     └─ PromptLabel
└─ GatherProgressGui
   └─ Root
      ├─ StatusLabel
      └─ ProgressBar
         └─ Fill
```

相关配置：

```text
ReplicatedStorage.Shared.Config.ResourceConfig
```

配置内容包括：

- 检测距离
- 服务端采集距离
- Tree / Rock 类型
- 提示文字
- 奖励类型
- 奖励数量
- 采集时间
- 冷却时间

已验证：采树增加木材，采矿增加石头，HUD 刷新，冷却生效。

### 2.9 已完成：商店系统真实购买

功能：

- 玩家靠近商店点，按 E 打开商店
- `ShopController` 根据 `ShopConfig` 渲染商品
- UI 使用手工制作的 `ShopItemTemplate` 模板，不是纯代码硬生成
- 点击 `PriceButton` 购买
- 客户端发送 `BuyItemRequest`
- 服务端 `ShopSystem` 校验商品、价格、金币
- `DataService.SpendCurrency` 扣金币
- `DataService.AddInventoryItem` 加入背包
- `DataService.PushPlayerData` 刷新 HUD
- 客户端显示购买成功/失败

商店 UI 当前结构大致：

```text
StarterGui
└─ ShopGui
   └─ Root
      ├─ BackgroundDim
      └─ Window
         ├─ Header
         │  ├─ TitleLabel
         │  └─ CloseButton
         ├─ Content
         │  └─ ItemScroll
         │     ├─ UIListLayout
         │     └─ ShopItemTemplate
         │        ├─ SelectedFrame
         │        ├─ PriceButton
         │        ├─ CardBG
         │        ├─ Icon
         │        ├─ NameLabel
         │        └─ DescLabel
         └─ Footer
```

商店交互点：

```text
Workspace
└─ Interactables
   └─ ShopPoints
      └─ MainShop
```

当前商品：

- 木剑 `WoodSword`
- 铁剑 `IronSword`
- 布甲 `ClothArmor`
- 铁甲 `IronArmor`

注意：当前金币增长机制还没做。用户计划后续通过“出售物品”获得金币。当前只是初始金币 + 商店扣费。

### 2.10 正在进行/作为主脉：背包系统真实接入

目标：

- 商店买到的装备进入 `Inventory`
- 打开 `InventoryGui` 后能看到装备图标
- 点击装备显示详情
- 点击右侧按钮穿戴
- 再点可卸下
- 穿戴状态保存到 `Equipped`

当前最重要的是：**背包 UI 必须适配用户当前真实结构，不可套用通用结构。**

用户当前 `InventoryGui` 真实结构如下：

```text
StarterGui
└─ InventoryGui                         ScreenGui
   └─ Root                              Frame
      └─ Window                         Frame
         ├─ UIAspectRatioConstraint
         ├─ Header                      Frame
         │  ├─ CloseButton              ImageButton
         │  └─ Header                   ImageLabel / ImageButton
         │
         ├─ MainInventoryBG             Frame / ImageLabel
         │  ├─ LeftSidebar              Frame
         │  │  ├─ UICorner
         │  │  ├─ UIStroke
         │  │  └─ Frame                 Frame
         │  │     ├─ UIListLayout
         │  │     ├─ AllImageButton     ImageButton
         │  │     │  ├─ Texture         ImageLabel
         │  │     │  └─ Name            TextLabel
         │  │     ├─ WeaponImageButton  ImageButton
         │  │     └─ EquipImageButton   ImageButton
         │  │
         │  ├─ UnitsHolder              Frame
         │  │  ├─ UICorner
         │  │  ├─ UIStroke
         │  │  └─ ScrollingFrame        ScrollingFrame
         │  │     ├─ UIGridLayout
         │  │     └─ InventoryItemTemplate  Frame
         │  │        ├─ ViewportFrame   ViewportFrame
         │  │        ├─ CarBG           ImageLabel / Frame
         │  │        └─ ItemIcon        ImageLabel
         │  │
         │  └─ RightItemDetailsPanel    Frame
         │     ├─ UICorner
         │     ├─ UIStroke
         │     ├─ EquipImageButton      ImageButton
         │     ├─ Texture               ImageLabel
         │     ├─ AttackPower           TextLabel
         │     ├─ HasNumber             TextLabel
         │     ├─ UnitName              TextLabel
         │     ├─ BasicAttributes       TextLabel
         │     └─ IsEquiped             TextLabel
         │
         └─ Background                  ImageLabel / Frame
```

重要细节：

- 左侧 `LeftSidebar.Frame.EquipImageButton` 是“装备分类按钮”
- 右侧 `RightItemDetailsPanel.EquipImageButton` 是“穿戴/卸下按钮”
- 两个按钮同名，但路径不同，代码必须完整路径区分
- `InventoryItemTemplate` 是 `Frame`，不是 `TextButton`，所以点击时需要用 `InputBegan` 或给它设置 `Active = true`
- `InventoryItemTemplate.Visible = false`，作为模板 Clone

当前计划使用：

```text
Client:
- InventoryController

Server:
- InventorySystem
- DataService.EquipItem
- DataService.UnequipSlot

Remote:
- EquipItemRequest
- UnequipItemRequest
```

---

## 3. 当前核心目录结构

### 3.1 ReplicatedStorage

```text
ReplicatedStorage
├─ Remotes
│  ├─ Events
│  │  ├─ SelectLordRequest
│  │  ├─ TeleportRequest
│  │  ├─ DungeonRequest
│  │  ├─ ResourceCollectRequest
│  │  ├─ PlayerDataUpdate
│  │  ├─ BuyItemRequest
│  │  ├─ EquipItemRequest
│  │  └─ UnequipItemRequest
│  └─ Functions
│     └─ GetPlayerData
│
└─ Shared
   ├─ Config
   │  ├─ DungeonConfig
   │  ├─ EquipmentConfig
   │  ├─ FactionConfig
   │  ├─ LevelConfig
   │  ├─ ResourceConfig
   │  ├─ ShopConfig
   │  └─ TeleportConfig
   │
   ├─ Constants
   │  ├─ GameConstants
   │  ├─ MapConstants
   │  └─ RemoteNames
   │
   ├─ Types
   └─ Utils
      ├─ FormatUtils
      ├─ InstanceUtils
      ├─ TableUtils
      └─ UIWaitUtils
```

### 3.2 ServerScriptService

```text
ServerScriptService
└─ Server
   ├─ Bootstrap
   │  └─ ServerBootstrap
   │
   ├─ Managers
   │  └─ RemoteManager
   │
   ├─ Services
   │  ├─ DataService
   │  ├─ PlayerService
   │  └─ WorldTeleportService
   │
   └─ Systems
      ├─ DungeonSystem
      ├─ ResourceSystem
      ├─ SelectionSystem
      ├─ TeleportSystem
      ├─ ShopSystem
      └─ InventorySystem
```

### 3.3 StarterPlayerScripts

```text
StarterPlayer
└─ StarterPlayerScripts
   └─ Client
      ├─ Bootstrap
      │  └─ ClientBootstrap
      │
      ├─ Controllers
      │  ├─ HUDController
      │  ├─ MainMenuController
      │  ├─ LoadingController
      │  ├─ ResourceController
      │  ├─ SelectionController
      │  ├─ TeleportController
      │  ├─ ShopController
      │  ├─ ShopInteractController
      │  └─ InventoryController
      │
      └─ UI
         └─ UIManager
```

### 3.4 Workspace

```text
Workspace
├─ Interactables
│  ├─ ResourceNodes
│  │  ├─ Trees
│  │  │  ├─ Tree_01
│  │  │  └─ Tree_02
│  │  └─ Rocks
│  │     ├─ Rock_01
│  │     └─ Rock_02
│  │
│  ├─ Teleporters
│  │  ├─ WeiToResourceZone
│  │  ├─ ShuToResourceZone
│  │  ├─ WuToResourceZone
│  │  ├─ ResourceToCity
│  │  ├─ WeiToDungeon
│  │  ├─ ShuToDungeon
│  │  └─ WuToDungeon
│  │
│  └─ ShopPoints
│     └─ MainShop
│
└─ Map
   ├─ Cities
   │  ├─ WeiCity
   │  ├─ ShuCity
   │  └─ WuCity
   ├─ ResourceZone
   │  ├─ RocksArea
   │  └─ TreesArea
   ├─ SpawnPoints
   │  ├─ WeiSpawn
   │  ├─ ShuSpawn
   │  └─ WuSpawn
   └─ DungeonInstances
```

---

## 4. 当前玩家数据结构

当前内存版玩家数据由 `DataService` 管理，后续会接持久化。

推荐当前结构：

```lua
PlayerData = {
    HasSelectedLord = false,
    Faction = nil,
    LordId = nil,

    Level = 1,
    Exp = 0,

    Gold = 100,
    Wood = 20,
    Stone = 15,

    Inventory = {
        -- {
        --     InstanceId = "GUID",
        --     ItemId = "WoodSword",
        --     Level = 0,
        -- }
    },

    Equipped = {
        Weapon = nil,
        Armor = nil,
    },

    UnlockedDungeons = {
        TestDungeon = true,
    },
}
```

字段解释：

- `HasSelectedLord`：是否已选主公
- `Faction`：魏/蜀/吴
- `LordId`：主公 ID，目前简化
- `Gold`：金币，当前主要用于商店购买
- `Wood`：木材，由砍树获得
- `Stone`：石头/矿石，由挖矿获得
- `Inventory`：玩家拥有的装备实例列表
- `Equipped`：当前穿戴的装备槽，存 `InstanceId`

---

## 5. 配置表约定

### 5.1 GameConstants

负责：

- 默认玩家数据
- 资源类型
- 游戏基础常量

建议资源类型：

```lua
GameConstants.ResourceTypes = {
    Gold = "Gold",
    Wood = "Wood",
    Stone = "Stone",
}
```

### 5.2 RemoteNames

负责统一 Remote 名称。

必须保持所有通信都从这里读取，不要在 Controller/System 中到处手写字符串。

### 5.3 EquipmentConfig

负责装备本身属性。

当前装备：

```lua
EquipmentConfig.Equipments = {
    WoodSword = {
        Id = "WoodSword",
        DisplayName = "木剑",
        Desc = "新手使用的基础木剑。",
        Slot = "Weapon",
        Attack = 5,
        Defense = 0,
        Hp = 0,
        Icon = "rbxassetid://...",
    },

    IronSword = {
        Id = "IronSword",
        DisplayName = "铁剑",
        Desc = "比木剑更强的基础武器。",
        Slot = "Weapon",
        Attack = 12,
        Defense = 0,
        Hp = 0,
        Icon = "rbxassetid://...",
    },

    ClothArmor = {
        Id = "ClothArmor",
        DisplayName = "布甲",
        Desc = "基础防具，提供少量防御。",
        Slot = "Armor",
        Attack = 0,
        Defense = 4,
        Hp = 20,
        Icon = "rbxassetid://...",
    },

    IronArmor = {
        Id = "IronArmor",
        DisplayName = "铁甲",
        Desc = "比布甲更结实的护甲。",
        Slot = "Armor",
        Attack = 0,
        Defense = 10,
        Hp = 50,
        Icon = "rbxassetid://...",
    },
}
```

### 5.4 ShopConfig

负责商店卖什么、价格多少、图标是什么。

重点区别：

- `ShopConfig`：商店售卖信息
- `EquipmentConfig`：装备属性信息

不要把两个表混在一起。

---

## 6. 已完成闭环时序图

### 6.1 选主公闭环

```text
SelectLordGui
→ SelectionController
→ SelectLordRequest
→ SelectionSystem
→ DataService.SetFaction
→ DataService.PushPlayerData
→ WorldTeleportService / TeleportSystem
→ 玩家到对应主城
```

### 6.2 HUD 数据同步闭环

```text
玩家加入
→ DataService 创建默认数据
→ HUDController 调用 GetPlayerData
→ 服务端返回数据
→ HUD 显示 Gold / Wood / Stone / Level
→ 任何系统修改数据
→ DataService.PushPlayerData
→ HUDController 收到 PlayerDataUpdate
→ HUD 刷新
```

### 6.3 传送闭环

```text
玩家靠近 Teleporter Part
→ TeleportController 显示提示
→ 玩家按 E
→ TeleportRequest
→ TeleportSystem 校验目标点
→ WorldTeleportService 移动角色
→ 玩家到资源区/主城/副本入口
```

### 6.4 资源采集闭环

```text
玩家靠近 Tree_01 / Rock_01
→ ResourceController 显示 GatherPromptGui
→ 玩家按 E
→ GatherProgressGui 显示读条
→ ResourceCollectRequest
→ ResourceSystem 校验资源点/距离/冷却
→ DataService.AddCurrency
→ DataService.PushPlayerData
→ HUD 刷新 Wood / Stone
→ 资源点进入冷却
```

### 6.5 商店购买闭环

```text
玩家靠近 MainShop
→ ShopInteractController 检测到商店点
→ 玩家按 E
→ UIManager.Open("ShopGui")
→ ShopController 渲染商品卡片
→ 玩家点击 PriceButton
→ BuyItemRequest
→ ShopSystem 校验商品和金币
→ DataService.SpendCurrency 扣 Gold
→ DataService.AddInventoryItem 加装备
→ DataService.PushPlayerData
→ HUD 金币刷新
→ ShopController 显示购买成功
```

### 6.6 背包穿戴闭环（当前主脉）

```text
商店购买装备
→ DataService.Inventory 增加装备实例
→ PlayerDataUpdate 推送给客户端
→ InventoryController 渲染 InventoryGui
→ 玩家点击装备图标
→ 右侧 RightItemDetailsPanel 显示详情
→ 玩家点击 RightItemDetailsPanel.EquipImageButton
→ EquipItemRequest / UnequipItemRequest
→ InventorySystem 校验
→ DataService.EquipItem / UnequipSlot
→ DataService.PushPlayerData
→ 背包刷新穿戴状态
```

---

## 7. 当前已踩坑和解决经验

### 7.1 PlayerGui 加载时序问题

问题：

- `FindFirstChild` 有时找不到刚复制到 `PlayerGui` 的 UI
- 进入游戏时 UI 尚未加载完成，导致 Controller 初始化失败

解决：

- 使用 `WaitForChild(name, timeout)`
- 增加 `LoadingGui`
- 初始化顺序由 `ClientBootstrap` 管理

### 7.2 UI 结构必须严格适配实际层级

曾出现问题：AI 默认生成 `InventoryGui` 通用结构，但用户实际 UI 已经是另一套层级。

解决：

- 必须以截图中的 Explorer 层级为准
- 代码路径必须完全匹配
- 对同名按钮必须用完整路径区分

### 7.3 UI 外观不要纯代码生成

商店系统一开始用代码生成商品按钮，结果很丑、难改。

解决：

- 在 Studio 中手工做 `ShopItemTemplate`
- 代码只负责 Clone 模板、填数据、绑定事件

此原则后续也用于背包：

- `InventoryItemTemplate` 手工制作
- `InventoryController` 只 Clone 和填数据

### 7.4 服务端权威

所有关键逻辑都必须服务端处理：

- 选主公
- 传送目标
- 采集奖励
- 商店扣费
- 背包穿戴
- 后续副本奖励

客户端只负责：

- UI 显示
- 本地提示
- 按钮点击
- 发请求

### 7.5 初始化顺序很重要

服务端推荐：

```lua
RemoteManager.Init()
DataService.Init()
SelectionSystem.Init()
TeleportSystem.Init()
ResourceSystem.Init()
ShopSystem.Init()
InventorySystem.Init()
```

客户端推荐：

```lua
LoadingController.Init()
UIManager.Init()
UIManager.BindAllCloseButtons()
HUDController.Init()
SelectionController.Init()
TeleportController.Init()
ResourceController.Init()
ShopController.Init()
ShopInteractController.Init(UIManager)
InventoryController.Init()
MainMenuController.Init(UIManager)
LoadingController.Hide()
```

---

## 8. 当前还没做 / 下一步建议

### 8.1 P5：完成背包系统验收

需要确认：

- 购买装备后打开背包能看到装备图标
- 点击装备后右侧详情刷新
- 木剑/铁剑显示攻击
- 布甲/铁甲显示防御和生命
- 点击右侧按钮能穿戴
- 再点能卸下
- Output 有 `InventorySystem` 和 `InventoryController` 日志

### 8.2 P5.5：出售装备获得金币

用户提到金币增长还没确定，计划后续通过卖东西获得金币。

建议后续做：

```text
SellItemRequest
SellItemSystem
DataService.RemoveInventoryItem
DataService.AddCurrency(player, "Gold", sellPrice)
```

注意：已装备的装备不能直接出售，必须先卸下或服务端自动拒绝。

### 8.3 P6：副本入口 UI + 最小副本

目标：

- DungeonGui
- 副本列表
- 进入按钮
- 服务端检查等级
- 传送到副本区

### 8.4 P7：最小战斗系统

建议先做主公自身战斗，不做武将队伍。

属性：

```text
HP
ATK
DEF
```

伤害公式：

```lua
damage = math.max(1, attackerAtk - defenderDef)
```

### 8.5 P8：主公等级系统

目标：

- 获得经验
- 达到阈值升级
- 等级提升属性
- HUD 刷新等级

### 8.6 P9：装备强化

目标：

- 选择装备
- 显示强化消耗
- 消耗金币/木材/石头
- 装备 Level +1
- 属性提升

### 8.7 P10：数据持久化

建议等数据结构稳定后再接 ProfileService。

需要持久化字段：

```text
HasSelectedLord
Faction
LordId
Level
Exp
Gold
Wood
Stone
Inventory
Equipped
UnlockedDungeons
SignIn
```

---

## 9. 与 3D 场景同事的协作规范

场景同事主要负责：

- 主城模型
- 资源区模型
- 副本场景模型
- 角色模型与骨骼导入

代码/UI 侧负责：

- 绑定交互逻辑
- UI 反馈
- Remote 通信
- 服务端校验

协作规则：

1. 场景只负责“点位”和“模型”，不要在 Workspace 直接写 Script。
2. 所有交互点必须命名规范。
3. 交互点使用 Part 或 Model，但最好都有可定位的 BasePart/PrimaryPart。
4. 资源点需要 `ResourceType` Attribute。
5. 传送点命名必须和配置对应。
6. 商店交互点建议统一放到：

```text
Workspace.Interactables.ShopPoints.MainShop
```

---

## 10. 给后续 AI 的优先级判断

如果用户继续开发，不要一上来重构所有系统。当前优先顺序应为：

```text
1. 完成 P5 背包系统真实接入
2. 增加装备出售，解决金币增长来源
3. 做副本入口 UI
4. 做最小副本和最小战斗
5. 做副本奖励和主公经验
6. 做装备强化
7. 再考虑数据持久化 ProfileService
```

遇到问题时，优先排查：

```text
1. Explorer 层级路径是否和代码一致
2. RemoteNames 是否新增了对应事件
3. RemoteManager 是否创建了 Remote
4. ServerBootstrap 是否初始化了 System
5. ClientBootstrap 是否初始化了 Controller
6. DataService 是否 PushPlayerData
7. UI 模板是否 Visible=false 且名字正确
```

---

## 11. 一句话总结当前项目主干

```text
Shared 定规则和配置
Server 负责权威判定和数据修改
Client 负责 UI 和玩家交互
Workspace 放交互点和地图点位
StarterGui 做界面模板
DataService 是所有玩家数据的中心
```

当前已经形成的核心闭环是：

```text
选主公 → 主城出生 → 传送资源区 → 采集木材/石头 → 回主城 → 商店购买装备 → 背包显示和穿戴装备
```

