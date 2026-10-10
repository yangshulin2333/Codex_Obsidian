---@class Color3Value:Instance @一个用于盛装单个Color3的实例。该值有很多用处，比如用于脚本之间的通信。
---@field Value Color3 @用于保存Color3
---@field Changed RBXScriptSignal @每当对象的Value更改时就会触发
local module = {}

