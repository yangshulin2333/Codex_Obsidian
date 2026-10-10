---@type CommonHotpot
local Hotpot = _G.CommonHotpot
---@type StarterGui
local startGui = game:GetService("StarterGui")
---@class ClientSystemMessageHelper
local module = Hotpot.class.new(script)
---@type func @本地端调用
---@param msg string @传入需要展示的文本
---@param color Color3 @文本的颜色
function module:ShowMessage(msg, color)
    startGui:SetCore("ChatMakeSystemMessage", {
        Text = msg,
        Font = Enum.Font.SourceSansBold,
        Color = color
    })
end

function module.new()
    return module()
end
function module:ctor()
end

return module
