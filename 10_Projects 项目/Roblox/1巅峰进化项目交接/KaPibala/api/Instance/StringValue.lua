---@class StringValue:Instance @一个用于盛装单个字符串的实例。该值有很多用处，比如用于脚本之间的通信。
---@field Value string @用于保存字符串值
---@field Changed RBXScriptSignal @每当对象的Value更改时就会触发
local module = {}

