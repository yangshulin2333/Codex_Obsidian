local _G = _G
local script = script
local table = table
local ipairs = ipairs
local pairs = pairs
local game = game
local hotpot = _G.ServerHotpot
---@type Server_PayManager
local pay_manager = hotpot.load.Server_PayManager()
local products_cfg = hotpot.config.products
---@class ServerEventManager
local c = hotpot.class.new(script)
---@type fun()
function c:Init()
    self.inquire_list = {}
    self.event_list = {}
    if not next(products_cfg) then
        return
    end
    for id,p_id in ipairs(products_cfg)  do
        self.inquire_list[id] = p_id
    end
end
---@type fun(id:number):number|boolean
---@param id number
---@return number|boolean
function c:GetProductId(id)
    assert(id,"id is nil")
    if not self.inquire_list[id] then
       return false
    end
    return self.inquire_list[id]
end
-- ---@type fun(p_id:number):function|boolean
-- ---@param p_id number
-- ---@return function|boolean
-- function c:GetProductEvent(p_id)
--     assert(p_id,"id is nil")
--     if not self.event_list[p_id] then
--        return false
--     end
--     return self.event_list[p_id]
-- end
---@type fun(p_id:number,check_fun:function,handle:function,...):boolean
---@param p_id number
---@param check_fun function
---@param handle function
---@return boolean
function c:BindProductEvent(p_id,check_fun,handle,...)
    assert(p_id,"id is nil")
    assert(check_fun,"check_fun is nil")
    assert(handle,"handle is nil")
    if self.event_list[p_id] then
       return false
    end
    pay_manager:RegistProduct(p_id,check_fun,handle,...)
    return true
end
c:Init()
return c