local _G = _G
local os = os
local wait = wait
local print = print
local warn = warn
local debug = debug
local game = game
local table = table
local script = script
local ipairs = ipairs
local workspace = workspace
local xpcall = xpcall
local pairs = pairs
local next = next
local coroutine = coroutine
local StarterPlayer = game:GetService("StarterPlayer")
---@type Players
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
-- Players.CharacterAutoLoads = false
local hotpot = _G.ServerHotpot
local pay_manager = hotpot.load.Server_PayManager()
local instance_manager = hotpot.load.InstanceManager()
local data_base_manager = hotpot.load.DataBaseManager()
local event_manager = hotpot.load.ServerEventManager()
local function_manager = hotpot.load.ServerFunctionManager()
local audio_manager = hotpot.load.Server_AudioManager()
local TeleportService = game:GetService("TeleportService")
local place_manager = hotpot.load.PlaceManager()
---@class ServerBase:GameObject
---@field main_inst Workspace
local c = hotpot.class.new(script, hotpot.files.GameObject())
--本地变量
--本地函数申明
--本地函数定义
function c:ctor()
    c.super.ctor(self, workspace)
    ---@type table<Server_Player,boolean>
    self.player_list = {}
    self.player_num = 0
    self.close_wait_list = {}
    --添加关服逻辑
    --需要等待服务器析构
    self:AddCloseWaitHandle("server dtor",function()
        self:dtor()
    end)
    --需要等待所有玩家退出
    self:AddCloseWaitHandle("player out",function()
        while self.player_num > 0 do
            -- print("wait for player out,now num is ",self.player_num)
            wait()
        end
    end)
    --需要处理所有的存档
    self:AddCloseWaitHandle("data base save",function()
        while data_base_manager:IsSaving() do
            -- print("wait for data saving")
            wait()
        end
    end)
    --注册传送相关内容
    if self.OnTeleportFailed then
        self:AddRbxCallBack(TeleportService.TeleportInitFailed,self.OnTeleportFailed)
    end
end
function c:dtor()
    -- print("server close")
    for player_object,__ in pairs(self.player_list) do
        player_object:AddProcess(function()
            self:PlayerOut(player_object)
        end)
    end
    c.super.dtor(self)
end
function c:AddCloseWaitHandle(name,handle)
    -- local no = #self.close_wait_list + 1
    self.close_wait_list[name] = coroutine.create(function()
        local mark = os.clock()
        local r,e = xpcall(handle,debug.traceback)
        -- print(name," used ",os.clock() - mark)
        self.close_wait_list[name] = nil
        if not r then
            warn(e)
        end
    end)
end
function c:Start()
    if self.OnStart then
        -- self:AddProcess(self.OnStart)
        local r, e = xpcall(self.OnStart, debug.traceback, self)
        if not r then
            warn(e)
        end
    end
    --初始化已有玩家角色
    for __, player_inst in ipairs(Players:GetChildren()) do
        self:AddProcess(self.PlayerInstIn, player_inst)
    end
    --监听玩家进入
    Players.PlayerAdded:Connect(
        function(player_inst)
            self:AddProcess(self.PlayerInstIn, player_inst)
        end
    )
    --监听玩家退出
    Players.PlayerRemoving:Connect(
        function(player_inst)
            -- print("inst out")
            self:AddProcess(self.PlayerInstOut, player_inst)
        end
    )
    --监听服务器关闭，并尽量进行延迟关闭，让所有类都完整析构，并且进行存档
    if not RunService:IsStudio() then
        game:BindToClose(
            function()
                --开始运行所有在关闭时需要处理的内容
                for no,co in pairs(self.close_wait_list) do
                    coroutine.resume(co)
                end
                --等待所有关闭处理流程处理完
                local clock = os.clock()
                while next(self.close_wait_list) do
                    wait()
                end
                wait()
                -- print("close server in ", os.clock() - clock, "s")
            end
        )
    end
end
function c:SetAutoCreateCharacter(switch)
    Players.CharacterAutoLoads = switch
end
function c:GetAutoCrteateCharacter()
    return Players.CharacterAutoLoads
end
---@param player_inst Player
function c:PlayerInstIn(player_inst)
    if self.OnPlayerInstIn then
        local r,e = xpcall(self.OnPlayerInstIn,debug.traceback,self,player_inst)
        if not r then
            warn(e)
        end
    end
    local player_object
    local r, e =
        xpcall(
        function()
            player_object = hotpot.load.Server_Player().new(player_inst)
        end,
        debug.traceback
    )
    if not r then
        warn(e)
        player_inst:Kick(e)
    else
        self:PlayerIn(player_object)
    end
end
---@param player_inst Player
function c:PlayerInstOut(player_inst)
    if self.OnPlayerInstOut then
        local r,e = xpcall(self.OnPlayerInstOut,debug.traceback,self,player_inst)
        if not r then
            warn(e)
        end
    end
    hotpot.encryption_manager:PlayerLogout(player_inst)
    pay_manager:DelPayingInfo(player_inst.UserId)
    local player_object = instance_manager:FindObject(player_inst)
    if player_object then
        self:PlayerOut(player_object)
    end
end
---@param player_object Server_Player
function c:PlayerIn(player_object)
    event_manager:DelayGet(player_object)
    function_manager:DelayGet(player_object)
    self.player_list[player_object] = true
    if self.OnPlayerIn then
        self:OnPlayerIn(player_object)
    end
    self.player_num = self.player_num + 1
end
---@param player_object Server_Player
function c:PlayerOut(player_object)
    if self.OnPlayerOut then
        local r,e = xpcall(self.OnPlayerOut,debug.traceback,self,player_object)
        if not r then
            warn(e)
        end
        -- self:OnPlayerOut(player_object)
    end
    -- player_object:dtor()
    local r,e = xpcall(player_object.dtor,debug.traceback,player_object)
    if not r then
        warn(e)
    end
    self.player_list[player_object] = nil
    self.player_num = self.player_num - 1
end
function c:SetEnableMouseLockOption(swtich)
    StarterPlayer.EnableMouseLockOption = swtich
end
---@return Server_Player
function c:GetPlayerObjectByUserId(id)
    local player_inst = Players:GetPlayerByUserId(id)
    local player_object = instance_manager:FindObject(player_inst)
    return player_object
end
---@return Player
function c:GetPlayerInstanceByUserId(id)
    assert(id, "param id is nil")
    return Players:GetPlayerByUserId(id)
end
---@type fun() @根据配置表初始化碰撞组及关系
function c:InitColliderGroup()
    local collider_manager = hotpot.load.ColliderManager()
    local collider_group = hotpot.load.ColliderGroup()
    local collider_config = hotpot.config.collider_group
    if not collider_config then
        warn("no collider config!")
        return
    end
    --创建所有的碰撞组
    for collider_group_name,__ in pairs(collider_config) do
        if collider_group_name ~= "Default" then
            collider_group[collider_group_name] = true
        end
    end
    --创建碰撞组的关系
    for collider_group_name,tab in pairs(collider_config) do
        for tag_group,result in pairs(tab) do
            local group_a = collider_group[collider_group_name]
            local group_b = collider_group[tag_group]
            collider_manager:SetGroupCollidable(group_a,group_b,result)
        end
    end
end
function c:GetPlaceId()
    return game.PlaceId
end
function c:GetPlaceName()
    return place_manager:GetNameById(self:GetPlaceId())
end
return c
