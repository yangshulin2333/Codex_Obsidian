local _G = _G
local warn = warn
local wait = wait
local xpcall = xpcall
local debug = debug
local script = script
local assert = assert
local hotpot = _G.ServerHotpot
local ProxyNode = hotpot.load.ProxyNode()
local hotpot_enum = hotpot.load.HotpotEnum()
local data_base = hotpot.load.DataBaseManager()
data_base:CreateDataBase(hotpot_enum.data_base.player_data)
local player_data = hotpot.load.PlayerData()
---@class Server_PlayerDataComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
---@param component Server_PlayerDataCompnent
---@param player Server_Player
local function GetInitData(component,player)
    -- print("get data")
    local save_data = player.__init_save_data
    if not save_data then
        local user_id = player:GetUserId()
        -- local r,e = component:WaitForFunc(data_base.Load,data_base,hotpot_enum.data_base.player_data,user_id)
        local r,e = data_base:Load(hotpot_enum.data_base.player_data,user_id)
        local count = 0
        while not r do
            wait(10)
            if not player:IsExist() then
                return
            end
            count = count + 1
            if count > 5 then
                player:Kick("roblox error,get save data field,please retry!")
                return
            end
            warn(e)
            -- r,e = component:WaitForFunc(data_base.Load,data_base,hotpot_enum.data_base.player_data,user_id)
            print("error try load data again")
            r,e = data_base:Load(hotpot_enum.data_base.player_data,user_id)
        end
        save_data = e
        if not save_data then
            -- print("no data ,retry")
            player.__new_player = true
            save_data = player_data.GetInitData()
        end
    end
    -- print("load data over")
    return save_data
end
local function UpdateData(data)
    local version = data.version
    local if_changed = false
    for i = version+1,#player_data.version_update,1 do
        local update_func = player_data.version_update[i]
        update_func(data)
        data.version = i
        if_changed = true
    end
    return if_changed
end
---@param parent Server_Player
function c:ctor(parent)
    c.super.ctor(self,parent)
    local user_id = parent:GetUserId()
    self.user_id = user_id
    --拿到存档以后对版本进行比对，并对存档版本进行升级
    local save_data = GetInitData(self,parent)
    if not save_data then
        return
    end
    -- local save_data = self:WaitForFunc(GetInitData,self,parent)
    local if_changed = UpdateData(save_data)
    --创建代理存档代理
    self.__save_data = ProxyNode.new(save_data)
    --如果出现的存档变更，那么就进行存储
    data_base:Save(hotpot_enum.data_base.player_data,user_id,function()
        return self.__save_data.__real
    end)
end
---@return ProxyNode
function c:GetData(data_name)
    assert(data_name,"param data name is nil")
    local data = self.__save_data[data_name]
    assert(data,"no save data named "..data_name)
    return self.__save_data[data_name]
end
function c:Execut(func,...)
    if not self:IsExist() or not self.parent:IsExist() then
        -- self:dtor()
        return false
    end
    -- if not self.parent.main_inst
    -- or not self.parent.main_inst.Parent then
    --     -- self:dtor()
    --     return false
    -- end
    local r,e = xpcall(func,debug.traceback,...)
    local save_data = self.__save_data
    local is_dirty = save_data:Isdirty()
    if is_dirty then
        if not r then
            save_data:Revert()
        else
            save_data:Update()
            data_base:Save(hotpot_enum.data_base.player_data,self.parent:GetUserId(),function()
                return save_data.__real
            end)
        end
        save_data:Clean()
    end
    if not r then
        warn(e)
        return false
    end
    return true
end
function c:IsSaving()
    return data_base:IsDataSaving(hotpot_enum.data_base.player_data,self.user_id)
end

function c:Clean()
    data_base:Save(hotpot_enum.data_base.player_data,self.parent:GetUserId(),function()
        return
    end)
    print('clean data!')
end

function c:dtor()
    local save_data = self.__save_data
    if save_data then
        if save_data:Isdirty() then
            data_base:Save(hotpot_enum.data_base.player_data,self.parent:GetUserId(),function()
                return save_data.__real
            end)
            save_data:Clean()
        end
    end
    c.super.dtor(self)
end
return c