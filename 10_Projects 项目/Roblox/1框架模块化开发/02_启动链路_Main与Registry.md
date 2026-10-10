---
type: concept
domain: roblox
status: evergreen
owner: mixed
source: self
created: 2026-07-08
updated: 2026-07-08
---

# 启动链路 Main 与 Registry

## 服务端启动链

```text
Main.server.lua
-> ServiceRegistry.new()
-> registry:Init()
-> registry:Start()
```

入口文件只负责启动，不写业务逻辑。

## ServiceRegistry.new()

`new()` 创建一个 registry 对象，里面有：

```text
_services：ServiceList 数组
_servicesByName：按名字查服务的字典
_context：传给每个 Service 的上下文
_initialized：是否 Init 过
_started：是否 Start 过
```

关键点：

```lua
self._context = {
	Logger = Logger,
	Services = self._servicesByName,
}
```

`Services` 不是复制一份表。它和 `_servicesByName` 指向同一张表。

## Init 两轮循环

第一轮：

```text
遍历 ServiceList
-> 检查 Service 格式
-> 用 service.Name 注册到 _servicesByName
```

第二轮：

```text
再次遍历 ServiceList
-> 调用 service:Init(context)
```

为什么要两轮？

```text
先让所有 Service 都能被名字找到。
再让每个 Service 开始初始化。
```

否则前面的 Service 在 Init 阶段可能找不到后面的 Service。

## Start

`Start()` 必须在 `Init()` 后执行。

它负责：

```text
按 ServiceList 顺序调用每个 Service 的 Start()
```

`Init()` 是准备阶段，`Start()` 是运行阶段。

## 客户端启动链

```text
Main.client.lua
-> ControllerRegistry.new()
-> registry:Init()
-> registry:Start()
```

和服务端类似，但客户端管理的是 Controller。

## 记忆句

```text
ServiceList 管顺序，_servicesByName 管按名字查找，context.Services 指向 _servicesByName。
```
