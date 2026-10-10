---
type: concept
domain: roblox
status: evergreen
owner: mixed
source: self
created: 2026-07-08
updated: 2026-07-08
---

# Net 网络层

## 定位

Net 层负责客户端和服务端通信。

当前底座只保留两类通信：

```text
RemoteFunction：客户端请求服务端，并等待返回
RemoteEvent：单向发送消息，不等待返回
```

## NetService:Init

服务端启动时创建 Remote 文件夹结构。

大致结构：

```text
ReplicatedStorage
  ModuleDev_Remotes
    ClientToServer
      Requests
      Events
    ServerToClient
      Events
```

`Init()` 阶段只准备文件夹和引用。

## NetService:Start

`Start()` 注册框架自检请求：

```text
Framework.Ping
```

它用于启动冒烟测试，不是正式业务功能。

## RegisterRequest

服务端注册请求：

```lua
NetService:RegisterRequest(remoteName, handler)
```

它会：

1. 检查 Remote 名字。
2. 检查 handler 是函数。
3. 防止重复注册。
4. 创建或找到 RemoteFunction。
5. 绑定 `OnServerInvoke`。
6. 统一包装返回结果。

## NetClient.Request

客户端请求服务端：

```lua
NetClient.Request(remoteName, payload)
```

底层使用：

```lua
RemoteFunction:InvokeServer(payload)
```

所以它会等待服务端返回。

## NetResult

统一返回格式：

成功：

```lua
{
	Ok = true,
	Data = data,
}
```

失败：

```lua
{
	Ok = false,
	Code = code,
	Message = message,
	Data = data,
}
```

判断是否成功看 `result.Ok`。真正数据在 `result.Data`。

## RemoteNames

Remote 名字集中管理，避免客户端和服务端字符串写错。

模块 Remote 建议带模块前缀：

```text
Shop.BuyItem
Inventory.EquipItem
Enemy.Hit
```

## 记忆句

```text
RemoteNames 管名字，RemoteGuards 管名字是否合法，NetResult 管返回格式，NetService / NetClient 管通信。
```
