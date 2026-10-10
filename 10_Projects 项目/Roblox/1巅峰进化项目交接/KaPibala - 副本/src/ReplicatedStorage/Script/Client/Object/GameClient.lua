local _G = _G
local script = script
local game = game
local wait = wait
---@type ContentProvider
local ContentProvider = game:GetService("ContentProvider")
---@type StarterGui
local StarterGui = game:GetService("StarterGui")
-- StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,false)

local hotpot = _G.ClientHotpot
local hotpot_enum = hotpot.load.HotpotEnum()
local ui_manager = hotpot.load.UIManager()
local loading_gui = hotpot.load.LoadingGui()
---@type PlaceManager
local place_manager = hotpot.load.PlaceManager()

local joinStr = '<font color = "rgb(0,255,0)">The guild battle is currently accepting registrations. Please go to the guild island and find the NPC to sign up.</font>'
local battleStr = '<font color = "rgb(0,255,0)">The guild battle is currently underway. Please join us in the PVP area..</font>'

---@class GameClient:ClientBase
local c = hotpot.class.new(script,hotpot.files.ClientBase())
function c.new()
    local client = c()
    return client
end
function c:ctor()
    _G.client = self
    c.super.ctor(self)


end
function c:OnStart()
    ui_manager:InstallUIList()
    -- self.loading_gui = loading_gui.new()
    -- self.loading_gui:SetStepFunc(1,function()
    -- end)
    -- self.loading_gui:SetStepFunc(2,function()
    -- end)
    -- self.loading_gui:SetStepFunc(3,function()
    -- end)
    -- self.loading_gui:SetStepFunc(4,function()
    -- end)
    -- self.loading_gui:SetStepFunc(5,function()

    -- end)
    -- self.loading_gui:StartLoading()
    self:StartGame() 

    if place_manager:GetIdByName('partysence') == game.PlaceId then
    elseif place_manager:GetIdByName('guildsence') == game.PlaceId then
        ---@type Client_GuildStageObj
        self.guild_stage_obj = hotpot.load.Client_GuildStageObj().new()
    elseif place_manager:GetIdByName('pvpsence') == game.PlaceId then
        local model = workspace:WaitForChild('pvpModel')
        ---@type Client_PvpStageObj
        self.pvp_stage_obj = hotpot.load.Client_PvpStageObj().new(model)
    elseif place_manager:GetIdByName('challengesence') == game.PlaceId then
        ---@type Client_ChallengeStageObj
        self.challenge_stage_obj = hotpot.load.Client_ChallengeStageObj().new()
    else
        self.rank_manager = hotpot.load.Client_RankManager().new()
    end
end
function c:dtor()
    c.super.dtor(self)
end
function c:StartGame()
    self:CreateLoaclPlayer()
end

local function SystemTips(info)
    local TextChatService = game:GetService("TextChatService")

    local channel = TextChatService.TextChannels:WaitForChild("RBXGeneral")

    if channel then
        channel:DisplaySystemMessage(info)
    end
end

local function UpdateGuildWarTips()
    spawn(function()
        while true do
            wait(3600)
            local isbattle = hotpot.pro_cfg.IsInGuildBattleTime()
            local isjoin = hotpot.pro_cfg.IsInGuildJoinTime()
            if isjoin then
                SystemTips(joinStr)
            elseif isbattle then
                SystemTips(battleStr)
            end
        end
    end)
end
UpdateGuildWarTips()

hotpot.event_manager:RegistHandle('ClientchannelInfo',function(_,info)
    SystemTips(info)
end)

hotpot.event_manager:RegistHandle('ClientMsgInfo',function(_,info)
    ui_manager.ui_list.tips_gui:TipsMessage(info,'success')
end)

return c