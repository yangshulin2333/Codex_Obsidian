--负责服务器间通信
local hotpot = _G.CommonHotpot
---@type MessagingService
local messagingService = game:GetService("MessagingService")
---@class MessagingHelper
local c = {}
---@type func @仅在服务器端进行调用
---@param topic string
---@param handle func @会传入获得的data,传入data的样式待定
function c:SubscribeAsync(topic, handle)
    return messagingService:SubscribeAsync(topic, handle)
end
---@type func @进行指定的服务器通信广播
---@param topic string @发送的主题
---@param message table @传递的数据
function c:BroadMessage(topic, message)
    messagingService:PublishAsync(topic, message)
end

return c
