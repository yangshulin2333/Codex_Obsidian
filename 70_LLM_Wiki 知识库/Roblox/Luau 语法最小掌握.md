---
type: concept
domain: roblox
status: evergreen
owner: codex
source: mixed
created: 2026-06-26
updated: 2026-06-26
---

# Luau 语法最小掌握

## 一句话说明

这页不是系统学习全部 Luau，而是记录读 Roblox 项目时最先要掌握的语法点。

## 为什么重要

你看 FirstLoop、Service、Controller、DataService 时，很多卡点不是业务复杂，而是 Luau 写法不熟：

- `:` 和 `.` 的区别。
- `self` 是谁。
- `return {}` 到底返回什么。
- `or {}` 为什么能防 nil。
- 匿名函数什么时候执行。
- `pcall` 为什么包住 Remote 或数据操作。

先掌握这些，就能读懂多数 Roblox 项目骨架。

## 最小语法表

| 语法 | 怎么理解 |
|---|---|
| `.lua` / `.luau` 自上而下执行 | 先创建表，再挂函数，最后 `return` |
| `return table` | ModuleScript 把这个表交给 `require()` 的调用者 |
| `local` | 局部变量，不污染全局 |
| `{}` | table，既能当数组，也能当字典 |
| `ipairs(list)` | 按数组顺序遍历，适合 ServiceList / ControllerList |
| `pairs(dict)` | 按键遍历字典，不保证业务顺序 |
| `:` | 自动传入 `self` |
| `.` | 直接访问字段或函数，不自动传 `self` |
| `function() ... end` | 匿名函数，常用于按钮事件、回调、updater |
| `or {}` | 左边是 nil 时用空表兜底 |
| `pcall` | 保护可能失败的调用，避免直接炸掉 |
| `..` | 字符串拼接 |
| `--!strict` | 开启 Luau 静态严格检查，不是运行时代码 |

## `:` 和 `.` 的核心区别

```lua
self:_setCount(1)
```

等价于：

```lua
self._setCount(self, 1)
```

所以定义方法时：

```lua
function FirstLoopController:_setCount(value)
end
```

函数内部的 `self` 通常就是 `FirstLoopController` 这张表。

## `or {}` 的使用场景

```lua
local data = result.Data or {}
local resources = data.resources or {}
```

这是防御写法。即使 `result.Data` 是 nil，也不会马上报错。

它适合 UI 刷新和返回值读取，不适合掩盖服务端数据结构错误。正式逻辑里仍然要有清晰校验。

## 匿名函数的两种常见用途

按钮点击：

```lua
button.MouseButton1Click:Connect(function()
    self:_requestGrantSmallGear()
end)
```

数据更新：

```lua
DataService:UpdateProfile(player, reason, function(data)
    data.Resources.SmallGear += 1
end)
```

读匿名函数时先问：

```text
谁调用它？
调用时传什么？
它返回什么？
```

## 来源

- [[../../10_Projects 项目/Roblox/玩具/ToyboxGuardiansGame/FirstLoop/第 8 课：FirstLoop 涉及的 Luau 语法点]]
- [[20_Areas 领域/Roblox/框架/RobloxGameFramework/通用 Roblox 工程骨架]]

## 相关链接

- [[RobloxGameFramework 启动链路]]
- [[Client Server Remote 请求链路]]
- [[DataService 与 DataSchema 边界]]

