local _G = _G
local script = script
local WAIT_TIME = 30
local hotpot = _G.ClientHotpot
local SocialService = game:GetService('SocialService')
local HttpService = game:GetService('HttpService')
---@class Client_PlayerInviteComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
---@param parent Client_Player
function c:ctor(parent)
    c.super.ctor(self,parent)
end
function c:dtor()
    c.super.dtor(self)
end
function c:InviteUser(user_id,message_id,prompt_message)
    if not self:CheckInviteEnable() then
        --warn("can't invite player now!")
        return false,"in_cd"
    end
    local player = self.parent
    local player_inst = player.main_inst
    local invite_options = hotpot.instance.ExperienceInviteOptions
    local launch_data = {
        sender_id = player:GetUserId(),
    }
    invite_options.LaunchData = HttpService:JSONEncode(launch_data)
    invite_options.InviteUser = user_id
    --//TODO:记得更新邀请信息id
    invite_options.InviteMessageId = message_id or "4505488f-502b-2344-bddf-d149473c90ab"
    invite_options.PromptMessage = prompt_message or "invite friend to this game"
    local r,e = xpcall(SocialService.PromptGameInvite,debug.traceback,SocialService,player_inst,invite_options)
    -- local r,e = xpcall(SocialService.PromptGameInvite,debug.traceback,SocialService,player_inst)
    if not r then
        --warn(e)
        return false,"unknown"
    end
    return true
end
function c:CheckInviteEnable()
    ---@type Client_Player
    local player = self.parent
    local player_inst = player.main_inst
    local r,e = xpcall(SocialService.CanSendGameInviteAsync,debug.traceback,SocialService,player_inst)
    if not r then
        --warn(e)
        return
    end
    return e
end
function c:OpenInviteList()
    if not self:CheckInviteEnable() then
        --warn("can't invite player now!")
        return false,"in_cd"
    end
    local player = self.parent
    local player_inst = player.main_inst
    local r,e = xpcall(SocialService.PromptGameInvite,debug.traceback,SocialService,player_inst)
    if not r then
        --warn(e)
    end
end
return c