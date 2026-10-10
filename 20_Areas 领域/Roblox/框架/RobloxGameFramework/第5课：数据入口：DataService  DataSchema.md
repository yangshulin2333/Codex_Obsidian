这一课讲：

```
玩家数据从哪里来？
谁能读写？
为什么不能让 Client 直接改？
ToyboxGuardiansGame 后面该怎么接数据？
```

核心文件：

- [DataService.lua (line 1)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ServerScriptService/Server/Framework/Services/DataService.lua:1)
- [DataSchema.lua (line 1)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ReplicatedStorage/Game/Shared/Config/DataSchema.lua:1)
- [DATA_RULES.md (line 1)](D:/AI/Codex/ToyBox/RobloxGameFramework/docs/DATA_RULES.md:1)

**1. DataService 是唯一数据入口**

规则在 [DATA_RULES.md (line 3)](D:/AI/Codex/ToyBox/RobloxGameFramework/docs/DATA_RULES.md:3)：

```
所有存档读写必须经过 DataService。
```

意思是：

```
CombatService 不能自己改存档
RewardService 不能自己改存档
FirstLoopService 不能自己乱改存档
Client 更不能改存档
```

正确路线是：

```
业务 Service 判断规则
-> 调用 DataService
-> DataService 修改玩家数据
```

**2. DataSchema 是默认数据模板**

文件：

[DataSchema.lua (line 3)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ReplicatedStorage/Game/Shared/Config/DataSchema.lua:3)

当前只有：

```
local DataSchema = {
	Version = 1,

	Defaults = {
		Meta = {
			SchemaVersion = 1,
			CreatedAt = 0,
			LastLoginAt = 0,
		},
		Flags = {},
	},
}
```

说明当前框架只是通用模板，所以不放 RPG 字段。

现在没有：

```
Resources
Level
Exp
Toys
Inventory
Boss
Collection
```

这些是 Toybox Guardians 的具体游戏数据，不能写进通用 `RobloxGameFramework` 核心。  
后面做 `ToyboxGuardiansGame` 时，才在游戏工程自己的 `DataSchema` 里加入：

```
Resources.SmallGear
Progression.Level
Toys.Owned
Collection.CollectedToyIds
```

**3. 玩家进入时怎么创建数据**

核心在 [DataService.lua (line 46)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ServerScriptService/Server/Framework/Services/DataService.lua:46)

`DataService:Start()` 会监听：

```
Players.PlayerAdded
Players.PlayerRemoving
```

玩家进入：

```
PlayerAdded
-> _openProfile(player)
-> _loadProfile(player)
-> 如果没有 ProfileStore adapter，就创建内存 profile
```

当前没有真实 ProfileStore，所以会走内存数据：

[DataService.lua (line 181)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ServerScriptService/Server/Framework/Services/DataService.lua:181)

```
return {
	UserId = player.UserId,
	LoadedAt = os.time(),
	UpdatedAt = os.time(),
	IsEphemeral = true,
	Data = createDefaultData(),
}
```

`IsEphemeral = true` 的意思是：

```
临时数据
退出就没
不是正式存档
```

**4. deepCopy 为什么重要**

[DataService.lua (line 17)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ServerScriptService/Server/Framework/Services/DataService.lua:17)

```
local function deepCopy(value)
```

它做的是深拷贝。

为什么需要？

因为 `DataSchema.Defaults` 是一个模板。如果不复制，多个玩家可能共享同一张表。  
那就会出现很严重的问题：

```
玩家 A 改了 Flags
玩家 B 也受到影响
```

所以每个玩家进入时都要：

```
复制一份独立数据
```

**5. 常用 API 怎么理解**

[DataService.lua (line 84)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ServerScriptService/Server/Framework/Services/DataService.lua:84)

```
GetProfile(player)
```

拿玩家 profile，可能是 `nil`。

```
RequireProfile(player)
```

必须拿到 profile，拿不到就报错。适合服务端内部确定必须有数据时用。

```
IsProfileReady(player)
```

检查数据是否准备好。Remote 请求里经常先判断它。

```
GetDataSnapshot(player)
```

返回玩家数据副本，不是原始表。适合给 UI 展示。

```
GetValue(player, key)
SetValue(player, key, value, reason)
```

读写顶层字段。

```
UpdateProfile(player, reason, updater)
```

推荐的正式修改方式。

**6. UpdateProfile 是最重要的方法**

核心在 [DataService.lua (line 124)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ServerScriptService/Server/Framework/Services/DataService.lua:124)

用法大概是：

```
DataService:UpdateProfile(player, "FirstLoop.GrantSmallGear", function(data)
	data.Resources.SmallGear += 1
end)
```

它要求必须传 `reason`：

```
FirstLoop.GrantSmallGear
Quest.Accept
Upgrade.ApplyAttack
ToyAssembly.Assemble
```

原因是以后排查数据问题时，能知道：

```
是谁改了数据
为什么改
从哪个功能来的
```

**7. DataService 不负责玩法裁判**

这一点很关键。

`DataService` 负责：

```
创建 profile
保存 profile
读取数据
修改数据
统一接 ProfileStore adapter
```

它不负责：

```
判断攻击是否命中
判断奖励该给多少
判断材料够不够
判断 Boss 是否死亡
判断玩家能不能强化
```

这些要由业务 Service 判断。

比如未来 `FirstLoopService`：

```
FirstLoopService 判断：
- profile 是否 ready
- requestId 是否存在
- 是否冷却
- SmallGear 是否没超过上限

然后才调用 DataService 修改：
Resources.SmallGear += 1
```

**8. ProfileStore adapter 是预留口**

[DataService.lua (line 64)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ServerScriptService/Server/Framework/Services/DataService.lua:64)

```
DataService:RegisterAdapter(adapter)
```

这是给未来真实存档用的。

当前没有真实 ProfileStore。  
未来接入时，不允许业务代码到处：

```
require(ProfileStore)
```

而是：

```
ProfileStore 包在 adapter 里
DataService 只调用 adapter.LoadProfile / SaveProfile / ReleaseProfile
```

这样存档边界不会散掉。

**9. FirstLoop 未来会怎么走数据**

完整链路会是：

```
FirstLoopController 点击按钮
-> NetClient.Request("FirstLoop.GrantSmallGear")
-> FirstLoopService 收到请求
-> 检查 DataService:IsProfileReady(player)
-> DataService:UpdateProfile(player, "FirstLoop.GrantSmallGear", function(data)
       data.Resources.SmallGear += 1
   end)
-> 返回最新 ResourcesSnapshot
-> UI 刷新 SmallGear 数量
```

注意：

```
Client 不传最终 SmallGear 数量。
Server 决定加多少。
DataService 执行写入。
```

**本课记住 5 句话**

```
DataSchema 是默认数据模板。

DataService 是唯一数据读写入口。

当前框架只有内存 profile，退出后数据会丢。

UpdateProfile 是推荐修改方式，必须写 reason。

DataService 管数据读写，不管具体玩法规则。
```

下一课就是第六课：

```
把 001_FirstLoop 串起来
```

也就是把前五课合并成一条完整链路：UI 按钮、Controller、Remote、Service、DataService、返回 UI。