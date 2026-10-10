local _G = _G
local script = script
local workspace = workspace
local game = game
---@type Players
local Players = game:GetService("Players")
local local_player = Players.LocalPlayer
---@type Player
local local_player = Players.LocalPlayer
local hotpot = _G.ClientHotpot
local pay_manager = hotpot.load.Client_PayManager()
local instance_manager = hotpot.load.InstanceManager()
local audio_manager = hotpot.load.Client_AudioManager()
local event_manager = hotpot.load.ClientEventManager()
local function_manager = hotpot.load.ClientFunctionManager()
local event_trigger = hotpot.load.ClientEventTriggerManager()
local localization_helper = hotpot.load.LocalizationHelper()
local TeleportService = game:GetService("TeleportService")
---@class ClientBase:GameObject
---@field main_inst Workspace
local c = hotpot.class.new(script,hotpot.files.GameObject())
function c:ctor()
    c.super.ctor(self,workspace)
    localization_helper:SetTranslatorByPlayer(local_player)
    if self.OnTeleportFailed then
        self:AddRbxCallBack(TeleportService.TeleportInitFailed,self.OnTeleportFailed)
    end
    if self.OnTeleportArrived then
        self:AddRbxCallBack(TeleportService.LocalPlayerArrivedFromTeleport,self.OnTeleportArrived)
    end
end
function c:Start()
    if self.OnStart then
        self:AddProcess(self.OnStart)
    end
end
function c:dtor()
    c.super.dtor(self)
end
function c:CreateLoaclPlayer()
    ---@type Client_Player
    self.local_player = hotpot.load.Client_Player().new(local_player)
    self:PlayerIn(self.local_player)
end
function c:PlayerIn(player_object)
    event_trigger:DelayGet(player_object)
    event_manager:DelayGet(player_object)
    function_manager:DelayGet(player_object)
    
    if self.OnPlayerIn then
        self:AddProcess(self.OnPlayerIn,player_object)
    end
end
function c:PlayerOut(player_object)
    if self.OnPlayerOut then
        self:AddProcess(self.OnPlayerOut,player_object)
    end
end
---@return Server_Player
function c:GetPlayerObjectByUserId(id)
    assert(id,"param id is nil")
    ---@type Player
    local player_inst = Players:GetPlayerByUserId(id)
    local player_object = instance_manager:FindObject(player_inst)
    return player_object
end
---@return Player
function c:GetPlayerInstanceByUserId(id)
    assert(id,"param id is nil")
    return Players:GetPlayerByUserId(id)
end
return c