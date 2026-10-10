local setmetatable = setmetatable
---@class FunctionList
local module = {}
local meta = {}
function meta:__index(key)
    return key
end
function meta:__newindex(key,val)
end
setmetatable(module,meta)
return module