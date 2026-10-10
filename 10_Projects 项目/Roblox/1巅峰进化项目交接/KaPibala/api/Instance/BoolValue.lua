---@class BoolValue:Instance @一个用于盛装单个布尔值的实例。该值有很多用处，比如用于脚本之间的通信。
---@field Value boolean @用于保存布尔值
---@field Changed RBXScriptSignal @每当BoolValue的BoolValue.Value更改时就会触发
local module = {}

