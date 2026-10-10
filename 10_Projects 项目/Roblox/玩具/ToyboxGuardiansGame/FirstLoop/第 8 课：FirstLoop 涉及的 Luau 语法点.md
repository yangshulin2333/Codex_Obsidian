
这节课不是系统学完整 Luau，而是专门解决你看 FirstLoop 时最容易卡住的语法。

**1. `.lua` 文件是不是自上而下执行**

是的，Lua / Luau 文件基本是自上而下执行。

比如：

```
local FirstLoopController = {
    Name = "FirstLoopController",
}

function FirstLoopController:Init(context)
end

return FirstLoopController
```

执行顺序是：

```
1. 创建 FirstLoopController 这张表
2. 往表里挂 Init 函数
3. return 这张表
```

`return FirstLoopController` 之后，这个 ModuleScript 就把这张表交给 `require(...)` 的调用方。

**2. return {} 里的顺序重要吗**

要分两种。

数组表，顺序重要：

```
return {
    require(GameServices.DataService),
    require(GameServices.NetService),
    require(GameServices.FirstLoopService),
}
```

这种会被 `ipairs` 按 1、2、3 顺序读取，所以启动顺序重要。

字典表，顺序通常不重要：

```
return {
    SmallGear = {
        MaxValue = 999,
    },
}
```

这里重点是通过名字访问：

```
ResourceConfig.SmallGear.MaxValue
```

不是靠顺序。

**3. `--!strict` 是什么**

```
--!strict
```

它看起来像注释，但对 Roblox Luau 分析器有特殊意义。

意思是：

```
请用更严格的规则检查这个脚本。
```

它不会在游戏运行时执行，也不会改变玩家看到的效果。  
它主要帮助开发时提前发现类型错误、nil 风险、写错字段等问题。

**4. `local` 是局部变量**

```
local GRANT_REMOTE_NAME = "FirstLoop.GrantSmallGear"
```

意思是：

```
只在当前脚本范围内使用这个变量。
```

推荐多用 `local`，因为它不会污染全局环境，也更容易追踪。

**5. `{}` 是 table**

Luau 里 table 很重要，既能当数组，也能当字典。

字典：

```
local FirstLoopController = {
    Name = "FirstLoopController",
}
```

访问：

```
FirstLoopController.Name
```

数组：

```
local list = {
    DataService,
    NetService,
    FirstLoopService,
}
```

访问：

```
list[1]
list[2]
```

**6. `.` 和 `:` 的区别**

这是你必须掌握的重点。

```
self._net.Request(...)
```

这里用 `.`，表示直接访问表里的函数。

```
self:_setCount(1)
```

这里用 `:`，等价于：

```
self._setCount(self, 1)
```

也就是说，`:` 会自动把左边的对象当作第一个参数传进去，这个参数通常叫 `self`。

**7. `self` 是谁**

在：

```
function FirstLoopController:_setCount(value)
    self._ui.CountText.Text = "当前小齿轮：" .. tostring(value)
end
```

`self` 就是 `FirstLoopController` 这张表。

所以：

```
self._ui
```

等价于：

```
FirstLoopController._ui
```

但用 `self` 更通用，方便以后复用或实例化。

**8. 匿名函数是什么**

```
self._ui.GrantButton.MouseButton1Click:Connect(function()
    self:_requestGrantSmallGear()
end)
```

这里的：

```
function()
    ...
end
```

就是匿名函数，没有名字。

它的意思是：

```
按钮被点击时，执行这段函数。
```

它不是马上执行，而是注册给点击事件，等玩家点击时再执行。

**9. 带参数的匿名函数**

服务端这里：

```
self._dataService:UpdateProfile(player, GRANT_REMOTE_NAME, function(data)
    data.Resources.SmallGear = nextSmallGear
end)
```

这个 `function(data)` 也是匿名函数。

真实含义是：

```
把“怎么改数据”这段逻辑交给 DataService。
DataService 执行时，会把 profile.Data 作为 data 传进来。
```

所以你看带参数函数时，先问三件事：

```
谁调用这个函数？
调用时传了什么？
这个函数返回什么？
```

**10. `or {}` 是防御写法**

```
local data = result.Data or {}
local resources = data.resources or {}
```

意思是：

```
如果左边有值，用左边。
如果左边是 nil，用右边。
```

这样可以避免：

```
result.Data 是 nil 时继续访问 result.Data.resources 报错。
```

**11. `if result.Ok then` 怎么读**

```
if result.Ok then
    ...
else
    ...
end
```

意思是：

```
如果 result.Ok 是 true，就走成功分支。
否则走失败分支。
```

`NetResult.Ok(...)` 返回：

```
{
    Ok = true,
    Data = ...
}
```

`NetResult.Err(...)` 返回：

```
{
    Ok = false,
    Code = "...",
    Message = "..."
}
```

**12. `type` 和 `typeof`**

```
type(payload) ~= "table"
```

`type` 是 Lua 基础类型检查，常见结果：

```
"nil" "string" "number" "boolean" "table" "function"
```

Roblox 对象常用：

```
typeof(button) == "Instance"
```

`typeof` 是 Roblox Luau 扩展，更适合检查 Roblox 对象。

**13. `pcall` 是保护执行**

```
local ok, result = pcall(function()
    return remote:InvokeServer(payload)
end)
```

意思是：

```
尝试执行这段可能报错的代码。
如果没报错：ok = true，result = 返回值。
如果报错：ok = false，result = 错误信息。
```

所以 `pcall` 常用于 Remote 调用、数据读写、外部接口这种可能失败的地方。

**14. `..` 是字符串拼接**

```
"当前小齿轮：" .. tostring(value)
```

意思是把两段字符串接起来。

`value` 可能是数字，所以先：

```
tostring(value)
```

转成字符串。

**15. `nil` 是没有值**

```
if template == nil then
    error("Missing Studio template")
end
```

`nil` 表示没有值、找不到、未设置。

你看到：

```
if xxx == nil then
```

基本就是在检查：

```
这个东西存在吗？
```

**16. 第 8 课最小掌握结论**

你现在优先掌握这些就够了：

```
.lua 文件自上而下执行。
return 把模块结果交给 require。
数组表顺序重要，字典表靠名字访问。
: 会自动传 self，. 不会。
匿名函数常用于事件回调和把逻辑传给别的函数。
or {} 是防 nil 报错。
pcall 是保护可能失败的代码。
--!strict 是开发期严格检查，不是运行逻辑。
```

到这里，FirstLoop 8 课就讲完了。  
下一步建议不是直接写 Combat，而是先做一次 **FirstLoop 总复盘**：把文件地图、Client 链、Remote 链、Server 链、Data 链、UI 链、Feature Pack 边界整理成一张检查表，你确认能讲出来以后，再进入 `002_CombatTrainingEnemy`。