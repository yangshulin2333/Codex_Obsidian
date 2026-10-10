---@class IntValue:Instance @一个用于盛装单个整型的实例。该值有很多用处，比如用于脚本之间的通信。
---@field Value number @用于保存整型值
---@field Changed RBXScriptSignal @每当对象的Value更改时就会触发
local module = {}
