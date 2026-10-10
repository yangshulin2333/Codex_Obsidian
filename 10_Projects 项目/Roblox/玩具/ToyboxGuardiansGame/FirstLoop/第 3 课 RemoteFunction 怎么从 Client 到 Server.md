开始第 3 课：**RemoteFunction 怎么从 Client 到 Server**。

这一课只讲一件事：玩家点了「小齿轮 +1」后，请求是怎么从客户端脚本走到服务器脚本的。先不讲 DataService 细节。

**1. 一句话总览**

按钮点击以后，调用链是：

```
FirstLoopController
-> NetClient.Request("FirstLoop.GrantSmallGear", payload)
-> RemoteFunction:InvokeServer(payload)
-> NetService.OnServerInvoke(player, payload)
-> FirstLoopService:_handleGrantSmallGear(player, payload)
-> 返回结果给客户端
-> FirstLoopController 刷新 UI
```

你可以把它理解成：

```
客户端按钮
请求服务器
服务器校验并处理
服务器返回结果
客户端显示结果
```

**2. 客户端从哪里开始**

在这个文件：

[D:\\AI\\Codex\\ToyBox\\ToyboxGuardiansGame\\src\\StarterPlayer\\StarterPlayerScripts\\Client\\Game\\Controllers\\FirstLoopController.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/StarterPlayer/StarterPlayerScripts/Client/Game/Controllers/FirstLoopController.lua)

核心函数是：

```
function FirstLoopController:_requestGrantSmallGear()
```

它的职责是：

```
向服务器请求：给当前玩家增加小齿轮
```

这里有两个关键参数：

```
GRANT_REMOTE_NAME = "FirstLoop.GrantSmallGear"
```

意思是：我要调用服务器上名叫 `FirstLoop.GrantSmallGear` 的远程接口。

还有一个 payload，大概长这样：

```
{
    requestId = "一串随机ID"
}
```

真实含义是：

```
requestId 用来标记这一次请求
不是加多少齿轮
不是玩家ID
不是资源数量
```

客户端不能说“我要加 999 个齿轮”。增加多少，必须由服务器决定。

**3. self._net 是谁**

你看到的：

```
self._net.Request(...)
```

这里的 `self._net` 来自：

```
function FirstLoopController:Init(context)
    self._net = context.Net
end
```

也就是说：

```
context.Net = NetClient
self._net = NetClient
```

所以实际调用的是：

```
NetClient.Request("FirstLoop.GrantSmallGear", payload)
```

`NetClient` 是客户端统一发请求的工具。Controller 不直接到处找 RemoteFunction，而是交给 `NetClient`。

这就是一层解耦：

```
FirstLoopController 不关心 RemoteFunction 放在哪里
它只知道：我要请求 FirstLoop.GrantSmallGear
```

**4. NetClient.Request 做什么**

在这个文件：

[D:\\AI\\Codex\\ToyBox\\ToyboxGuardiansGame\\src\\ReplicatedStorage\\Framework\\Shared\\Net\\NetClient.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/ReplicatedStorage/Framework/Shared/Net/NetClient.lua)

它大致做三件事：

```
1. 找到 RemoteFunction 文件夹
2. 找到名字为 FirstLoop.GrantSmallGear 的 RemoteFunction
3. 调用 remote:InvokeServer(payload)
```

重点是这句：

```
remote:InvokeServer(payload)
```

这就是 Roblox 的客户端到服务器调用。

你可以把它理解成：

```
客户端：服务器，我要调用 FirstLoop.GrantSmallGear，这是我带的数据 payload。
```

**5. player 是谁传的**

服务器函数最后收到的是：

```
player, payload
```

但客户端只传了：

```
payload
```

也就是说，客户端没有传 player。

这是 Roblox 自动补上的：

```
客户端调用 InvokeServer(payload)
服务器收到 OnServerInvoke(player, payload)
```

这点很重要：

```
player 是 Roblox 自动识别的真实玩家
payload 是客户端自己发来的数据，不能完全相信
```

所以安全规则是：

```
player 可以信
payload 必须校验
```

**6. 服务器在哪里接住请求**

服务器入口在：

[D:\\AI\\Codex\\ToyBox\\ToyboxGuardiansGame\\src\\ServerScriptService\\Server\\Framework\\Services\\NetService.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/ServerScriptService/Server/Framework/Services/NetService.lua)

服务端会提前注册接口：

```
RegisterRequest("FirstLoop.GrantSmallGear", handler)
```

这一步的意思是：

```
服务器声明：如果客户端请求 FirstLoop.GrantSmallGear，就交给这个 handler 处理
```

内部会设置：

```
remote.OnServerInvoke = function(player, payload)
    return self:_handleRequest(remoteName, handler, player, payload)
end
```

这就是服务器真正接住请求的位置。

**7. 最后交给 FirstLoopService**

在这个文件：

[D:\\AI\\Codex\\ToyBox\\ToyboxGuardiansGame\\src\\ServerScriptService\\Server\\Game\\Services\\FirstLoopService.lua](D:/AI/Codex/ToyBox/ToyboxGuardiansGame/src/ServerScriptService/Server/Game/Services/FirstLoopService.lua)

最终会进入：

```
function FirstLoopService:_handleGrantSmallGear(player, payload)
```

这时候入参是真实的：

```
player = 当前点击按钮的 Roblox 玩家对象
payload = {
    requestId = "客户端生成的一串随机ID"
}
```

这个函数才开始做服务器规则：

```
1. 检查玩家数据是否准备好
2. 检查 payload 是否是 table
3. 检查 requestId 是否合法
4. 检查冷却时间
5. 调用 DataService 修改数据
6. 返回成功或失败
```

但这些是第 4 课的重点。第 3 课你先记住：**请求已经从客户端走到了服务器。**

**8. 返回结果怎么回客户端**

服务器最后返回类似：

```
{
    Ok = true,
    Data = {
        SmallGear = 1,
        Granted = 1
    }
}
```

或者失败：

```
{
    Ok = false,
    Code = "COOLDOWN",
    Message = "..."
}
```

这个返回值会沿原路回到：

```
local result = self._net.Request(...)
```

然后客户端根据：

```
if result.Ok then
    -- 显示成功
else
    -- 显示错误
end
```

刷新 UI。

**9. 你这一课需要掌握的最小结论**

你现在只需要记住这 4 条：

```
1. FirstLoopController 负责发起请求。
2. NetClient.Request 负责找到 RemoteFunction 并 InvokeServer。
3. NetService 负责在服务器接住请求。
4. FirstLoopService 负责真正处理 FirstLoop 的业务规则。
```

最关键的一句是：

```
客户端只提出请求，服务器决定结果。
```

下一课就是第 4 课：**FirstLoopService 怎么校验、写 DataService、返回结果**。这会对应你前面自己逐行分析的 `_handleGrantSmallGear`，我们会把它拆成职责表，而不是继续硬翻译代码。