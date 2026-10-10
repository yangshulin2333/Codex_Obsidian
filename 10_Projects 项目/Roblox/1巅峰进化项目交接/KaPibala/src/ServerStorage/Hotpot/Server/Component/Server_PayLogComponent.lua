local _G = _G
local tostring = tostring
local assert = assert
local table = table
local debug = debug
local xpcall = xpcall
local os = os
local wait = wait
local script = script
local warn = warn
local hotpot = _G.ServerHotpot
local ProxyNode = hotpot.load.ProxyNode()
local data_base = hotpot.load.DataBaseManager()
--定义常量
-- local LOG_LIMIT_NUM = 9999
-- data_base:CreateDataBase("pay_log")
---@class Server_PayLogComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
local GetLogData
local SaveLog
---@param self Server_PayLogComponent
---@param player Server_Player
function GetLogData(self,player)
    local user_id = player:GetUserId()
    local r,e = data_base:Load(self.data_base_name,"no_count")
    local count = 0
    while not r do
        wait(10)
        if not player:IsExist() then
            warn("player is not exist")
            return
        end
        count = count + 1
        if count > 5 then
            warn("can't get player pay log!")
            player:Kick("roblox error,get data field,please retry later!")
            return
        end
    end
    self.no_count = e or 0
    -- if not self.no_count then
    --     self.no_count = 0
    --     data_base:Save(self.data_base_name,"no_count",function()
    --         return self.no_count
    --     end)
    -- end
end
function c.new(parent)
    return c(parent)
end
---@param parent Server_Player
function c:ctor(parent)
    c.super.ctor(self,parent)
    self.user_id = parent:GetUserId()
    self.data_base_name = "pay_log_"..tostring(self.user_id)
    data_base:CreateDataBase(self.data_base_name)
    GetLogData(self,parent)
end
function c:dtor()
    c.super.dtor(self)
end
function c:AddLog(pay_type,result,info)
    assert(pay_type,"param pay type is nil")
    if result == nil then
        result = false
    end
    local time = os.date("!*t",os.time())
    if not self:IsExist() or not self.parent:IsExist() then
        warn("player is not exist")
        return
    end
    self.no_count = self.no_count + 1
    data_base:Save(self.data_base_name,"no_count",function()
        return self.no_count
    end)
    data_base:Save(self.data_base_name,tostring(i),function()
        return {
            pay_type = pay_type,
            time = time,
            result = result,
            info = info,
        }
    end)
    -- print("add over",self:GetLog())
    -- for i = 1,10,1 do
    --     local co = coroutine.create(function()
    --         self:GetLog()
    --     end)
    --     coroutine.resume(co)
    -- end
end
function c:GetLog(start,over)
    local list = {}
    -- local count = self.no_count
    -- local main_co = coroutine.running()
    for i = start or 1,over or self.no_count,1 do
        -- local co = coroutine.create(function()
            local r,e = data_base:Load(self.data_base_name,tostring(i))
            if not r then
                warn(e)
            else
                table.insert(list,e)
            end
        --     count = count + 1
        --     if count < 1 then
        --         coroutine.resume(main_co)
        --     end
        -- end)
        -- coroutine.resume(co)
    end
    -- coroutine.yield()
    -- print(list)
    return list
end
return c