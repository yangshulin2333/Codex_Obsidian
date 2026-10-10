---@class RunService:Instance @RunService 包含了用于时间管理的方法和事件，以及管理游戏或脚本所处于的内容。 IsClient、IsServer、IsStudio 等方法可以帮助你确定 Lua 代码在哪里运行。这些方法对于客户端和服务器都需要的 ModuleScript 是很有帮助的。此外，您可以使用 IsStudio 来添加特殊行为，用于 Studio 内部的测试。
---@field Heartbeat RBXScriptSignal @在物理模拟完成后每帧触发
---@field RenderStepped RBXScriptSignal @在帧被渲染之前每帧触发
---@field Stepped RBXScriptSignal @在物理模拟前每帧运行
local module = {}
---@type fun(param:string,param:number,param:function) @给出一个函数的字符串名称和优先级，该方法将函数绑定到 RunService.RenderStepped
---@param name string @name 参数为绑定所需的标签，如果不再需要绑定，可以与 RunService.Unbind 一起使用。
---@param priority number @绑定的 priority 是一个整型，它决定了在渲染步骤中何时调用自定义函数。这个数字越低，自定义函数被调用的时间就越早。如果两个绑定的优先级相同， Roblox 引擎会随机选择一个先运行。默认的 Roblox 控制脚本是按照下面的优先级来运行的： Player Input（玩家输入）：100 Camera Controls（镜头控制）：200 为了方便起见，可以使用 ‘’‘RenderPriority’’’ 枚举来确定设置绑定的整型值。例如，要在默认镜头更新之前进行绑定，只需比镜头优先级减 1 即可。
---@param function function @要绑定的自定义函数
function module:BindToRenderStep()
end
---@type fun():boolean @返回当前的环境是否运行在客户端上
---@return boolean
function module:IsClient()
end
---@type fun():boolean @返回当前运行环境是否为 Edit（编辑）模式
---@return boolean
function module:IsEdit()
end
---@type fun():boolean @返回 ‘Run’ 按钮是否被按下，以在 Roblox Studio 中运行模拟
---@return boolean
function module:IsRunModel()
end
---@type fun():boolean @返回游戏当前是否正在运行
---@return boolean
function module:IsRunning()
end
---@type fun():boolean @返回当前的环境是否运行在服务器上
---@return boolean
function module:IsServer()
end
---@type fun():boolean @返回当前的环境是否运行在服务器上
---@return boolean
function module:IsStudio()
end
---@type fun() @如果游戏在运行则暂停游戏的模拟，暂停物理运算和脚本
---@return boolean
function module:Pause()
end
---@type fun() @运行游戏的模拟，运行物理和脚本
function module:Run()
end
---@type fun() @如果游戏的模拟正在运行，结束模拟
function module:Stop()
end
---@type fun(param:string)
---@param name string @解除绑定一个用 RunService:BindToRenderStep 绑定至渲染循环的函数
function module:UnbindFromRenderStep()
end