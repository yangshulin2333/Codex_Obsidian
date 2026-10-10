local _G = _G
local script = script
local table = table
local hotpot = _G.CommonHotpot
---@class HotpotConnection
local c = hotpot.class.new(script)
---@type fun(obj:BaseObject,del_func:function,check_func:function,...):HotpotConnection
---@param obj BaseObject
---@param del_func function
---@param check_func function
---@return HotpotConnection
function c.new(obj,del_func,check_func,...)
    return c(obj,del_func,check_func,...)
end
---@param obj BaseObject
function c:ctor(obj,del_fun,check_func,...)
    self.obj = obj
    self.del_fun = del_fun
    self.check_fun = check_func
    self.args = {...}
end
function c:dtor()
end
---@type fun() @判断链接是否存在
---@return boolean
function c:IsConnected()
    return self.check_fun(self.obj,table.unpack(self.args))
end
---@type fun() @断开链接
function c:Disconnect()
    return self.del_fun(self.obj,table.unpack(self.args))
end
return c