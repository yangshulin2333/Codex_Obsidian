---@class PluginClass
local module = {}
---@type fun(class_script:Instance,inherit_class_script:Instance)
---@param class_script Instance
---@param inherit_class_script Instance
---@return Class @定义类
function module.new(class_script,inherit_class_script)
    assert(class_script,"class_script is nil")
    if not class_script.ClassName or class_script.ClassName ~= "ModuleScript"   then
        warn("传入错误参数！")
    end
    ---@type table
    local c = {}
    ---@type BasePlugin
    if inherit_class_script then
        c.super = require(inherit_class_script)
    end
    ---@type string
    c.class = class_script.Name 
    ---@type table
    local meta = {__index = c}
    return setmetatable(c,{
        __index = c.super,
        __call = function(_,...)
            local obj = setmetatable({},meta)
            if c.ctor then
                local args = {...}
                local r,e = xpcall(function()
                    c.ctor(obj,table.unpack(args))
                end,debug.traceback)
                if not r then
                    warn(e)
                else
                    return obj
                end
            end
            return obj
        end
    })
end
return module