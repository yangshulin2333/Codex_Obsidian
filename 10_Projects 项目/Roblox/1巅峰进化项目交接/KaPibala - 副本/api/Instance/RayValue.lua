---@class RayValue:Instance @一个用于盛装单个射线的实例。该值有很多用处，比如用于脚本之间的通信。
---@field Value Ray @用于存储的射线
---@field Changed RBXScriptSignal @每当对象的Value更改时就会触发
local module = {}

