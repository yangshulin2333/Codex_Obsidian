---
type: concept
domain: roblox
status: evergreen
owner: mixed
source: self
created: 2026-07-08
updated: 2026-07-08
---

# Service 与 Controller 规则

## Service 是什么

Service 是服务器端模块。

它负责：

- 修改真实数据
- 校验客户端请求
- 管理玩家状态
- 调用存储
- 注册和处理 Remote

标准格式：

```lua
local MyService = {
	Name = "MyService",
}

function MyService:Init(context)
end

function MyService:Start()
end

return MyService
```

## Controller 是什么

Controller 是客户端模块。

它负责：

- 绑定 UI
- 监听输入
- 向服务端发请求
- 显示结果
- 播放简单反馈

Controller 不负责决定真实数据。

## 核心区别

```text
Service 决定真实结果。
Controller 负责表现和请求。
```

金币、背包、等级、购买结果必须由服务器决定。

## 新增 Service

建议位置：

```text
src/ServerScriptService/Server/Module/Services
```

然后加入：

```text
Framework/Runtime/ServiceList.lua
```

顺序原则：

```text
Framework Service 先启动，Module Service 后启动。
```

## 新增 Controller

建议位置：

```text
src/StarterPlayer/StarterPlayerScripts/Client/Module/Controllers
```

然后加入：

```text
Framework/Runtime/ControllerList.lua
```

## Lifecycle 检查

`Lifecycle.AssertModule(module, owner)` 检查：

1. module 必须是 table。
2. module.Name 必须是非空 string。
3. Init 如果存在，必须是 function。
4. Start 如果存在，必须是 function。

它不检查数据版本。数据版本由 StorageConfig 检查。
