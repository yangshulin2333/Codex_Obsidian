
这节课只看服务端。你可以先把 `FirstLoopService` 理解成一句话：

```
FirstLoopService 是 FirstLoop 功能在服务器上的规则裁判。
```

客户端只能说：“我点了按钮，请求加小齿轮。”  
服务器才决定：“能不能加、加多少、写到哪里、返回什么。”

**第 4 课函数职责表**

|函数|谁调用它|入参|返回|职责|
|---|---|---|---|---|
|`Init(context)`|`ServiceRegistry`|框架传入的工具包|无|拿到 `Logger`、`DataService`、`NetService`|
|`Start()`|`ServiceRegistry`|无|无|注册两个远程请求|
|`_handleGetSnapshot(player, payload)`|`NetService`|玩家、请求数据|`NetResult`|读取当前小齿轮数量给 UI|
|`_handleGrantSmallGear(player, payload)`|`NetService`|玩家、请求数据|`NetResult`|校验请求、修改小齿轮、返回结果|

对应文件：

[D:\\AI\\Codex\\ToyBox\\ToyboxGuardiansGame\\src\\ServerScriptService\\Server\\Game\\Services\\FirstLoopService.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/ServerScriptService/Server/Game/Services/FirstLoopService.lua)

**1. Init：先拿工具，不做业务**

```
function FirstLoopService:Init(context)
    self._logger = context.Logger
    self._dataService = context.Services.DataService
    self._netService = context.Services.NetService
end
```

这里不是在加小齿轮，只是在准备工具。

真实含义是：

```
self._logger      = 打日志用
self._dataService = 读写玩家数据用
self._netService  = 注册 RemoteFunction 用
```

这就是依赖注入。`FirstLoopService` 不自己创建 `DataService`，而是从框架传进来的 `context.Services.DataService` 里拿。

**2. Start：注册服务器接口**

```
self._netService:RegisterRequest(SNAPSHOT_REMOTE_NAME, function(player, payload)
    return self:_handleGetSnapshot(player, payload)
end)

self._netService:RegisterRequest(GRANT_REMOTE_NAME, function(player, payload)
    return self:_handleGrantSmallGear(player, payload)
end)
```

这里注册了两个接口：

```
FirstLoop.GetSnapshot
FirstLoop.GrantSmallGear
```

意思是：

```
客户端请求 FirstLoop.GetSnapshot -> 服务器执行 _handleGetSnapshot
客户端请求 FirstLoop.GrantSmallGear -> 服务器执行 _handleGrantSmallGear
```

所以 `Start()` 的职责不是处理业务，而是把“接口名字”和“处理函数”绑定起来。

**3. _handleGetSnapshot：给 UI 拿当前数据**

这个函数用于 UI 初始化时获取当前小齿轮数量。

大概流程：

```
1. 检查玩家数据是否准备好
2. 检查 payload 是否合法
3. 调用 DataService:GetDataSnapshot(player)
4. 从快照里取 Resources.SmallGear
5. 返回 NetResult.Ok(...)
```

成功返回大概是：

```
{
    Ok = true,
    Data = {
        resources = {
            SmallGear = 0
        }
    }
}
```

这里的重点是：  
`GetSnapshot` 只读数据，不改数据。

**4. _handleGrantSmallGear：真正加小齿轮**

这是本课核心。

```
function FirstLoopService:_handleGrantSmallGear(player, payload)
```

真实入参是：

```
player = 当前点击按钮的玩家对象

payload = {
    requestId = "客户端生成的一串请求ID"
}
```

注意：`player` 是 Roblox 自动给服务器的，不是客户端自己传的。  
`payload` 是客户端传来的，所以要校验。

**5. 第一步：检查数据是否准备好**

```
if not self._dataService:IsProfileReady(player) then
    return NetResult.Err("PROFILE_NOT_READY", "Player profile is not ready")
end
```

意思是：

```
如果这个玩家的数据还没加载完成，就拒绝请求。
```

为什么需要这个？

因为玩家刚进游戏时，客户端 UI 可能已经显示了，但服务器数据还没完全准备好。这个检查能防止“数据没准备好就写数据”。

**6. 第二步：检查 payload**

```
if type(payload) ~= "table" or type(payload.requestId) ~= "string" or payload.requestId == "" then
    return NetResult.Err("SERVER_ERROR", "Invalid FirstLoop request")
end
```

这段检查三件事：

```
payload 必须是 table
payload.requestId 必须是 string
payload.requestId 不能为空
```

为什么要检查？

因为客户端数据不可信。玩家、外挂、错误脚本，都可能发奇怪的数据过来。

但也要注意：  
`requestId` 不是防作弊核心，它只是请求标识。真正的防作弊是服务器不相信客户端的奖励数量，奖励数量由服务器配置决定。

**7. 第三步：冷却检查**

```
local now = os.clock()
local lastRequestAt = self._lastRequestAt[player]

if lastRequestAt ~= nil and now - lastRequestAt < FirstLoopConfig.CooldownSeconds then
    return NetResult.Err("COOLDOWN", "FirstLoop request is cooling down")
end

self._lastRequestAt[player] = now
```

这里防止玩家疯狂点击按钮。

逻辑是：

```
现在时间 - 上次请求时间 < 冷却时间
说明点太快了
返回 COOLDOWN
```

`self._lastRequestAt[player]` 是一个表：

```
{
    [玩家A] = 上次请求时间,
    [玩家B] = 上次请求时间,
}
```

玩家离开时，`PlayerRemoving` 会清掉这个玩家的记录，避免内存里一直留着旧玩家对象。

**8. 第四步：读取服务器配置**

```
local grantAmount = FirstLoopConfig.GrantAmount
local maxSmallGear = ResourceConfig.SmallGear.MaxValue
```

这里非常关键。

客户端没有资格决定：

```
加多少小齿轮
小齿轮最大值是多少
```

这些都从服务器能 require 到的配置里读。

所以规则来源是：

```
FirstLoopConfig.GrantAmount       本次加多少
ResourceConfig.SmallGear.MaxValue 小齿轮最大值
```

**9. 第五步：调用 DataService:UpdateProfile**

```
local ok, updateResult = self._dataService:UpdateProfile(player, GRANT_REMOTE_NAME, function(data)
    ...
end)
```

你可以把这句拆成三部分：

```
player
```

改哪个玩家的数据。

```
GRANT_REMOTE_NAME
```

为什么改数据。这里是 `"FirstLoop.GrantSmallGear"`，方便日志和未来排查。

```
function(data)
    ...
end
```

具体怎么改数据。

这就是一个“把修改逻辑交给 DataService 执行”的写法。

**10. updater 匿名函数里真正改数据**

匿名函数里面：

```
local currentSmallGear = tonumber(data.Resources.SmallGear) or 0
local nextSmallGear = currentSmallGear + grantAmount
```

意思是：

```
当前小齿轮数量
+
本次奖励数量
=
新的小齿轮数量
```

然后检查上限：

```
if nextSmallGear > maxSmallGear then
    error("SmallGear would exceed max value")
end
```

这里的 `error(...)` 会让 `DataService:UpdateProfile` 返回失败：

```
ok = false
updateResult = "SmallGear would exceed max value"
```

如果没超上限，才真正写入：

```
data.Resources.SmallGear = nextSmallGear
```

这一句才是数据真正变化的位置。

**11. TutorialFlags 的变化**

```
if currentSmallGear == 0 then
    data.Progression.TutorialFlags.GainedSmallGear = true
end
```

意思是：

```
如果玩家原来是 0 个小齿轮
这次第一次获得小齿轮
就标记 GainedSmallGear = true
```

这个字段以后可以用于：

```
新手引导进度
解锁下一步教程
判断玩家是否完成过第一次资源获取
```

**12. updater 返回给客户端的数据**

匿名函数最后返回：

```
return {
    resources = {
        SmallGear = nextSmallGear,
    },
    added = {
        SmallGear = grantAmount,
    },
}
```

这个不是直接写进存档的完整数据，而是告诉客户端：

```
现在小齿轮是多少
这次增加了多少
```

所以成功时客户端最终拿到：

```
{
    Ok = true,
    Data = {
        resources = {
            SmallGear = 新数量
        },
        added = {
            SmallGear = 本次增加数量
        }
    }
}
```

**13. 如果 UpdateProfile 失败**

```
if not ok then
    self._logger.Warn(...)
    return NetResult.Err("SERVER_ERROR", "FirstLoop update failed")
end
```

失败可能来自：

```
玩家 profile 不存在
updater 内部 error
数据结构异常
超过上限
```

失败时返回统一格式：

```
{
    Ok = false,
    Code = "SERVER_ERROR",
    Message = "FirstLoop update failed"
}
```

**14. 如果成功**

```
return NetResult.Ok(updateResult)
```

也就是返回：

```
{
    Ok = true,
    Data = updateResult
}
```

`NetResult` 在这个文件：

[D:\\AI\\Codex\\ToyBox\\ToyboxGuardiansGame\\src\\ReplicatedStorage\\Framework\\Shared\\Net\\NetResult.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/ReplicatedStorage/Framework/Shared/Net/NetResult.lua)

它的作用就是统一返回格式：

```
成功：Ok = true, Data = ...
失败：Ok = false, Code = ..., Message = ...
```

**你前面理解里需要校正的几个点**

你前面整体理解是对的，但有几个地方要修正：

```
1. requestId 只是请求标识，不是玩家ID。
2. 玩家是谁，不靠客户端传，由 Roblox 自动传给服务器。
3. grantAmount 是每次增加数量，不是客户端传来的。
4. data.Resources.SmallGear = nextSmallGear 才是真正写数据的位置。
5. UpdateProfile 的匿名函数返回值，会变成 updateResult，再作为 NetResult.Ok 的 Data 返回客户端。
```

还有一个工程观察：  
现在冷却时间是在 `UpdateProfile` 之前写入的。如果后面数据更新失败，玩家也会进入冷却。对于 Debug FirstLoop 可以接受，但正式玩法里可以考虑更细地处理失败场景。这里先不改，只作为你理解服务端规则时要注意的点。

**第 4 课最小掌握结论**

你只要记住这条链：

```
_handleGrantSmallGear
先校验玩家数据
再校验客户端 payload
再检查冷却
再读取服务器配置
再通过 DataService:UpdateProfile 改数据
最后用 NetResult 返回结果
```

最重要的架构思想是：

```
FirstLoopService 管玩法规则。
DataService 管数据读写。
NetResult 管返回格式。
客户端只负责请求和显示。
```

下一课第 5 课就讲：**DataService / DataSchema 在 FirstLoop 里怎么配合**。这会解释 `data.Resources.SmallGear`、`data.Progression.TutorialFlags` 这些字段最开始从哪里来。