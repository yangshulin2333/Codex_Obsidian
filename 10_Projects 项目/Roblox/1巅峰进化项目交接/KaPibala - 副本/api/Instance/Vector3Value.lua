---@class Vector3Value:Instance @一个用于盛装单个向量的实例。该值有很多用处，比如用于脚本之间的通信。
---@field Value Vector3 @用于保存向量值
---@field Changed RBXScriptSignal @每当对象的Value更改时就会触发
local module = {}

