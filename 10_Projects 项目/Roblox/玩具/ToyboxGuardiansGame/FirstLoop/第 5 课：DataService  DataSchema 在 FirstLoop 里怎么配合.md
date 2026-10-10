
这一课解决一个核心问题：

```
FirstLoopService 里写的 data.Resources.SmallGear
这个 data 到底从哪里来？
```

答案是：

```
DataSchema 定义默认数据结构
DataService 给每个玩家创建一份独立数据
FirstLoopService 通过 DataService 修改这份玩家数据
```

**1. 先看三者分工**

|文件|作用|能不能写业务规则|
|---|---|---|
|`DataSchema.lua`|定义玩家存档默认结构|不能|
|`DataService.lua`|管理玩家数据读写入口|尽量不能|
|`FirstLoopService.lua`|管 FirstLoop 玩法规则|可以|

对应文件：

[D:\\AI\\Codex\\ToyBox\\ToyboxGuardiansGame\\src\\ReplicatedStorage\\Game\\Shared\\Config\\DataSchema.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/ReplicatedStorage/Game/Shared/Config/DataSchema.lua)

[D:\\AI\\Codex\\ToyBox\\ToyboxGuardiansGame\\src\\ServerScriptService\\Server\\Framework\\Services\\DataService.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/ServerScriptService/Server/Framework/Services/DataService.lua)

[D:\\AI\\Codex\\ToyBox\\ToyboxGuardiansGame\\src\\ServerScriptService\\Server\\Game\\Services\\FirstLoopService.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/ServerScriptService/Server/Game/Services/FirstLoopService.lua)

一句话：

```
DataSchema 负责“玩家数据长什么样”
DataService 负责“玩家数据怎么读写”
FirstLoopService 负责“这次玩法能不能改数据”
```

**2. DataSchema 是什么**

`DataSchema.lua` 现在大概是：

```
local DataSchema = {
    Version = 1,

    Defaults = {
        Resources = {
            SmallGear = 0,
            WoodBody = 0,
            Spring = 0,
            BubbleCore = 0,
            MagnetSheet = 0,
            ClockworkCore = 0,
            ToyFragments = 0,
        },

        Progression = {
            Level = 1,
            Exp = 0,
            TutorialCompleted = false,
            TutorialFlags = {
                GainedSmallGear = false,
            },
        },
    },
}
```

你可以把它理解成：

```
新玩家第一次进入游戏时，默认应该拥有哪些字段。
```

比如：

```
Resources.SmallGear 默认是 0
Progression.Level 默认是 1
Progression.TutorialFlags.GainedSmallGear 默认是 false
```

所以 `DataSchema` 不是某个玩家的数据。  
它是“模板”。

**3. 玩家真实数据不是 DataSchema 本身**

这一点很重要：

```
DataSchema.Defaults 只是模板。
真正玩家的数据在 DataService._profiles[player].Data 里。
```

比如玩家 A 进服后，DataService 会创建：

```
profile = {
    UserId = 玩家A.UserId,
    LoadedAt = 当前时间,
    UpdatedAt = 当前时间,
    IsEphemeral = true,
    Data = {
        Resources = {
            SmallGear = 0,
            ...
        },
        Progression = {
            Level = 1,
            ...
        },
    },
}
```

然后放进：

```
DataService._profiles[player] = profile
```

所以后面 FirstLoop 修改的是：

```
profile.Data.Resources.SmallGear
```

不是直接改 `DataSchema.Defaults.Resources.SmallGear`。

**4. 为什么要 deepCopy**

`DataService` 里有一个关键函数：

```
local function deepCopy(value)
```

它的作用是：

```
从 DataSchema.Defaults 复制一份新的玩家数据。
```

为什么不能直接这样写？

```
local data = DataSchema.Defaults
```

因为这样所有玩家可能共用同一张表。

举例：

```
玩家 A 获得 SmallGear
玩家 B 的 SmallGear 可能也受影响
```

尤其是这种字段：

```
OwnedToyIds = {}
CollectedToyIds = {}
Flags = {}
```

如果不深拷贝，表会被共享，后期会出非常难查的问题。

所以正确流程是：

```
DataSchema.Defaults
-> deepCopy
-> 得到玩家自己的 Data
```

**5. DataService 怎么创建玩家数据**

玩家进服时，`DataService:Start()` 会监听：

```
Players.PlayerAdded:Connect(function(player)
    self:_openProfile(player)
end)
```

然后：

```
function DataService:_openProfile(player)
    local profile = self:_loadProfile(player)
    self._profiles[player] = profile
end
```

再往下：

```
function DataService:_loadProfile(player)
    return {
        UserId = player.UserId,
        LoadedAt = os.time(),
        UpdatedAt = os.time(),
        IsEphemeral = true,
        Data = createDefaultData(),
    }
end
```

也就是说：

```
玩家进服
DataService 创建 profile
profile.Data 来自 DataSchema.Defaults 的深拷贝
```

当前 `IsEphemeral = true` 表示：

```
现在还是临时内存数据，没有真正持久化到 ProfileStore。
```

后面接 ProfileStore 时，底层会换成真实存档，但业务层仍然通过 `DataService` 读写。

**6. FirstLoopService 为什么先检查 IsProfileReady**

上一课你看到：

```
if not self._dataService:IsProfileReady(player) then
    return NetResult.Err("PROFILE_NOT_READY", "Player profile is not ready")
end
```

`IsProfileReady` 实际就是：

```
return self._profiles[player] ~= nil
```

意思是：

```
这个玩家是否已经有 profile。
```

如果没有 profile，就不能改：

```
data.Resources.SmallGear
```

因为 `data` 根本不存在。

**7. GetDataSnapshot 是干什么的**

FirstLoop 初始化 UI 时，会请求：

```
FirstLoop.GetSnapshot
```

服务端调用：

```
self._dataService:GetDataSnapshot(player)
```

这个函数做的是：

```
local profile = self:RequireProfile(player)
return deepCopy(profile.Data)
```

重点是：

```
返回的是玩家数据副本，不是原始数据本体。
```

为什么？

因为快照是给 UI 看、给其他系统读的。  
如果把原始表直接暴露出去，外部代码可能绕过 `UpdateProfile` 乱改数据。

所以：

```
GetDataSnapshot = 安全读取
UpdateProfile = 正式写入
```

**8. UpdateProfile 是 FirstLoop 写数据的入口**

FirstLoop 真正加小齿轮时调用：

```
self._dataService:UpdateProfile(player, GRANT_REMOTE_NAME, function(data)
    ...
end)
```

这三个参数分别是：

```
player：改哪个玩家
GRANT_REMOTE_NAME：为什么改，方便日志追踪
function(data)：具体怎么改
```

真实执行时，`data` 就是：

```
profile.Data
```

所以在匿名函数里：

```
data.Resources.SmallGear = nextSmallGear
```

等价于：

```
修改这个玩家存档里的 Resources.SmallGear
```

**9. DataService 不负责判断加多少**

这一点是架构边界：

```
DataService 不应该知道 FirstLoop 每次加几个小齿轮。
```

所以加多少来自：

[D:\\AI\\Codex\\ToyBox\\ToyboxGuardiansGame\\src\\ReplicatedStorage\\Game\\Shared\\Config\\FirstLoopConfig.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/ReplicatedStorage/Game/Shared/Config/FirstLoopConfig.lua)

```
GrantAmount = 1
CooldownSeconds = 0.1
```

小齿轮上限来自：

[D:\\AI\\Codex\\ToyBox\\ToyboxGuardiansGame\\src\\ReplicatedStorage\\Game\\Shared\\Config\\ResourceConfig.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/ReplicatedStorage/Game/Shared/Config/ResourceConfig.lua)

```
SmallGear = {
    MaxValue = 999,
}
```

所以三个配置/服务的边界是：

```
DataSchema：默认有 SmallGear，默认是 0
ResourceConfig：SmallGear 最大值是 999
FirstLoopConfig：这次点击增加 1，冷却 0.1 秒
```

**10. FirstLoop 改数据的完整链路**

现在你可以把整条数据链串起来：

```
玩家进服
-> DataService:_openProfile(player)
-> DataService:_loadProfile(player)
-> createDefaultData()
-> deepCopy(DataSchema.Defaults)
-> profile.Data.Resources.SmallGear = 0
```

然后玩家点按钮：

```
FirstLoopController 请求服务器
-> FirstLoopService:_handleGrantSmallGear(player, payload)
-> DataService:IsProfileReady(player)
-> DataService:UpdateProfile(player, reason, updater)
-> updater(data)
-> data.Resources.SmallGear = nextSmallGear
-> 返回 updateResult
-> NetResult.Ok(updateResult)
-> 客户端刷新 UI
```

**11. 这一课最容易混的点**

第一，`DataSchema` 不是玩家当前数据。

```
DataSchema 是模板。
profile.Data 才是玩家当前数据。
```

第二，`GetDataSnapshot` 不应该用来改数据。

```
Snapshot 是副本，只适合显示。
```

第三，`UpdateProfile` 不是业务规则本身。

```
UpdateProfile 只是安全写数据的入口。
具体怎么改，由传进去的 updater 函数决定。
```

第四，`DataService` 不应该写成“加小齿轮服务”。

```
加小齿轮属于 FirstLoopService。
DataService 只管 profile。
```

**12. 第 5 课最小掌握结论**

你只要记住这个：

```
DataSchema 定义默认存档结构。
DataService 根据 DataSchema 给每个玩家创建 profile。
FirstLoopService 不直接管理存档，只通过 DataService:UpdateProfile 修改 profile.Data。
```

更短一点：

```
DataSchema 管结构。
DataService 管读写。
FirstLoopService 管规则。
```

下一课第 6 课：**Server 返回后 UI 怎么刷新**。  
也就是服务端返回 `NetResult.Ok(...)` 以后，`FirstLoopController` 怎么把 `SmallGear` 数量、成功提示、错误提示更新到界面上。