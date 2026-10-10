---@class MessagingService @用于服务器通信,MessagingService 允许同一个游戏中不同的游戏服务器利用主题进行相互的实时通信（< 1 秒）。主题是由开发者定义的字符串（ 1 - 80 个字符），让游戏服务器之间能够收发消息。由于目前无法保证消息的传达，在构建游戏时请确保传达失败时不会导致严重错误。
-- MessagingService 允许同一个游戏中不同的游戏服务器利用主题进行相互的实时通信（< 1 秒）。主题是由开发者定义的字符串（ 1 - 80 个字符），让游戏服务器之间能够收发消息。由于目前无法保证消息的传达
-- 在构建游戏时请确保传达失败时不会导致严重错误。
local c = {}

---@type function @当有消息被推送到主题时，调用提供的回调
---@param topic string @发送的主题
---@param message table @传递的数据
function c:PublishAsync(topic, message)
end
---@return RBXScriptConnection @开始监听给定主题(topic)
---@param topic string @监听的主题
---@param callback func @回调,自动传入message
function c:SubscribeAsync(topic, callback)
end
return c
