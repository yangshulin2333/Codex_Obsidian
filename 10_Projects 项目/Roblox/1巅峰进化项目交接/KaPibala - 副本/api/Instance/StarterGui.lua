---@class StarterGui:Instance
---@field ProcessUserInput boolean
---@field ProcessUserInput ScreenOrientation @为使用移动设备的用户设置默认的屏幕方向模式
---@field ShowDevelopmentGui boolean
local module = {}
---@type fun(param:string):any @返回由Roblox CoreScript指定的变量
---@param parameterName string
---@return any
function module:GetCore()
end
---@type fun(param:CoreGuiType):boolean @返回指定的CoreGuiType是启用还是已使用StarterGui：SetCoreGuiEnabled禁用
---@param coreGuiType CoreGuiType @给定的CoreGuiType
---@return boolean @给定的CoreGuiType是否启用
function module:GetCoreGuiEnabled()
end
---@type fun(param:string,param:any) @SetCore（请勿与 SetCoreGuiEnabled 混淆）公开了 Roblox 的 CoreScript 所定义的一系列功能，例如发送通知、切换徽章/分数通知的开关、为重置按钮或切换顶端栏定义回调等。SetCore 的第一个参数为字符串，将会选择与调用交互的功能：CoreScript 需要提前对该字符串进行注册（否则将会报错）。由于相应 CoreScript 可能还没有加载（或已经被完全禁用），或许会需要使用 pcall 对 SetCore 进行多次调用。
---@param parameterName string @选择调用将会交互的功能：CoreScript 需要提前对该字符串进行注册（否则将会报错）
---@param enabled boolean 
function module:SetCore()
end
---@type fun(param:CoreGuiType,param:enabled) @设置是启用还是禁用与给定CoreGuiType关联的CoreGui元素
---@param coreGuiType CoreGuiType @给定的CoreGuiType
---@param enabled boolean @是否启用或禁用给定的CoreGuiType
function module:parameterName()
end
---@type fun(param:number,param:number):Instance
---@param x number
---@param y number
---@return Instance
function module:GetGuiObjectsAtPosition()
end