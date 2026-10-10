这一课讲：

```
Client 怎么请求 Server？
Server 怎么返回统一结果？
RemoteFunction 和 RemoteEvent 怎么被框架管理？
```

核心文件：

- [NetService.lua (line 1)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ServerScriptService/Server/Framework/Services/NetService.lua:1)
- [NetClient.lua (line 1)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ReplicatedStorage/Framework/Shared/Net/NetClient.lua:1)
- [NetResult.lua (line 1)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ReplicatedStorage/Framework/Shared/Net/NetResult.lua:1)
- [RemoteNames.lua (line 1)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ReplicatedStorage/Framework/Shared/Net/RemoteNames.lua:1)
- [RemoteGuards.lua (line 1)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ReplicatedStorage/Framework/Shared/Net/RemoteGuards.lua:1)

**1. Remote 放在哪里**

`NetService:Init()` 会创建 Remote 文件夹：

[NetService.lua (line 67)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ServerScriptService/Server/Framework/Services/NetService.lua:67)

最终 Roblox 里大概是：

```
ReplicatedStorage
  RGF_Remotes
    ClientToServer
      Requests
      Events
    ServerToClient
      Events
```

含义：

```
ClientToServer/Requests  = RemoteFunction，客户端请求服务端并等待返回
ClientToServer/Events    = RemoteEvent，客户端单向通知服务端
ServerToClient/Events    = RemoteEvent，服务端通知客户端
```

**2. Remote 名字集中管理**

[RemoteNames.lua (line 3)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ReplicatedStorage/Framework/Shared/Net/RemoteNames.lua:3)

现在内置一个：

```
FrameworkPing = "Framework.Ping"
```

这只是 smoke test，用来确认网络链路能跑通。

以后 Toybox 的第一条 Remote 会类似：

```
FirstLoop.GrantSmallGear
```

**3. 名字要先过检查**

[RemoteGuards.lua (line 8)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ReplicatedStorage/Framework/Shared/Net/RemoteGuards.lua:8)

它检查 Remote 名：

```
不能为空
不能超过 80 字符
只能用字母、数字、点、下划线、短横线
```

所以这些合法：

```
Framework.Ping
FirstLoop.GrantSmallGear
Combat.Attack
ToyLoadout.Equip
```

**4. Server 注册请求**

服务端用：

[NetService.lua (line 119)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ServerScriptService/Server/Framework/Services/NetService.lua:119)

```
NetService:RegisterRequest(remoteName, handler)
```

意思是：

```
创建或找到一个 RemoteFunction
把 handler 绑定到 OnServerInvoke
客户端请求时，Server 执行 handler
```

框架内置例子在：

[NetService.lua (line 80)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ServerScriptService/Server/Framework/Services/NetService.lua:80)

```
self:RegisterRequest(RemoteNames.FrameworkPing, function(player, _payload)
	return {
		PlayerUserId = player.UserId,
		ServerTime = os.time(),
	}
end)
```

这表示客户端请求 `Framework.Ping` 时，服务端返回玩家 UserId 和服务器时间。

**5. Client 发请求**

客户端用：

[NetClient.lua (line 57)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ReplicatedStorage/Framework/Shared/Net/NetClient.lua:57)

```
NetClient.Request(remoteName, payload)
```

比如 smoke test：

[StartupSmokeTestController.lua (line 42)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/StarterPlayer/StarterPlayerScripts/Client/Framework/Controllers/StartupSmokeTestController.lua:42)

```
local result = self._net.Request(RemoteNames.FrameworkPing, {
	Source = self.Name,
})
```

这里的 `payload` 就是客户端发给服务端的数据。

你可以理解成：

```
remoteName = 我要请求哪个功能
payload = 我这次请求附带的信息
```

**6. 统一返回格式 NetResult**

[NetResult.lua (line 5)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ReplicatedStorage/Framework/Shared/Net/NetResult.lua:5)

成功：

```
{
	Ok = true,
	Data = data,
}
```

失败：

```
{
	Ok = false,
	Code = code,
	Message = message,
	Data = data,
}
```

这样客户端不用猜返回值格式，只需要先看：

```
if result.Ok == true then
	-- 成功
else
	-- 失败
end
```

**7. NetService 会兜底错误**

[NetService.lua (line 177)](D:/AI/Codex/ToyBox/RobloxGameFramework/src/ServerScriptService/Server/Framework/Services/NetService.lua:177)

`_handleRequest()` 用 `pcall` 包住 handler。

如果服务端 handler 报错，客户端不会直接看到服务端内部错误，而是收到：

```
SERVER_ERROR
```

这很重要，因为不能把服务端内部错误、路径、数据结构随便暴露给客户端。

**8. RemoteFunction 和 RemoteEvent 区别**

`RemoteFunction`：

```
Client 请求
Server 处理
Server 返回结果
Client 等结果
```

适合：

```
领取奖励
购买
强化
拼装
获取快照
FirstLoop.GrantSmallGear
```

`RemoteEvent`：

```
只发消息，不等直接返回
```

适合：

```
播放表现
战斗输入
服务端推送血量变化
Boss 状态变化
```

**9. 未来 FirstLoop 会怎么用**

大概链路是：

```
FirstLoopController
-> context.Net.Request("FirstLoop.GrantSmallGear", { requestId = "..." })
-> NetClient 找到 RemoteFunction
-> InvokeServer
-> NetService 收到
-> FirstLoopService handler 校验
-> DataService 写入 Resources.SmallGear
-> 返回 NetResult.Ok(...)
-> Client 刷新 UI
```

重点：

```
NetService 只负责通信边界。
FirstLoopService 才负责校验和玩法规则。
DataService 才负责改数据。
Client 只负责发请求和显示结果。
```

**本课记住这 4 句话**

```
NetClient 是客户端请求工具。

NetService 是服务端 Remote 管理器。

NetResult 统一成功/失败返回格式。

NetService 不做玩法裁判，具体规则必须由业务 Service 判断。
```

下一课建议讲：

```
DataService / DataSchema
```

这会直接解释：玩家数据从哪里创建、怎么读、怎么改、为什么不能让客户端直接改。