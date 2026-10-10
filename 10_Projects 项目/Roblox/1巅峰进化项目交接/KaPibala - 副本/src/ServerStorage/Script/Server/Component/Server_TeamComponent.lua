local hotpot = _G.ServerHotpot
---@type InstanceManager
local inst_manager = hotpot.load.InstanceManager()
---@type GameServer
local server = _G.server

local character_cfg = hotpot.config.character
local charcter_fol = hotpot:GetPath_Loop('character',hotpot.Resource)

---@class Server_TeamComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)
end

---@param player Player
function c:ViewPlayerInfo(player)
    if not player then
        return
    end
    ---@type Server_Player
    local p = inst_manager:FindObject(player)
    if not p then
        return
    end
    local info = {}
    if not p.prop_cmp then
        return
    end
    info.hp = p.prop_cmp:GetHp()
    info.atk = p.prop_cmp:GetAttack()
    info.speed = p.prop_cmp:GetSpeed()
    info.kill = p.stats_cmp.killMonster or 0
    local r,e = pcall(function()
        info.playTime = p.stats_cmp.playTime + (os.clock() - p.stats_cmp.now_clock)
    end)
    if not r then
        info.playTime = 0
    end

    info.egg = p.stats_cmp:GetEgg()
    info.tDmg = p.stats_cmp:GetTotalDmg()
    info.team_id = p.team_id

    local character = p.character_cmp:GetEquiped()
    info.equipedChar = character
    info.lv = p.prop_cmp:GetLv()
    info.exp = p.prop_cmp:GetExp()

    self:AddProcess(function()
        local name = character_cfg[character].model
        local model = charcter_fol:FindFirstChild(name)
        if model then
            local mmm = hotpot:CloneInst_Loop(model)
            mmm.Name = character_cfg[character].name
            self.parent.stats_cmp:ChangeCharacter(mmm)
        end
    end)

    return info
end

---@param player Player
function c:InvitePlayer(player)
    if self.invite_player then
        return
    end
    if not player then
        return
    end
    ---@type Server_Player
    local p = inst_manager:FindObject(player)
    if not p then
        return
    end
    
    local wait_time = 6
    self.invite_player = player
    hotpot.event_manager:Fire(p,'p_invite_team',self.parent.main_inst)
    while true do
        wait_time = wait_time - wait(.1)
        if wait_time <= 0 then
            break
        end
        if self.replay_invite then
            break
        end
    end
    self.invite_player = nil
    if self.invite_player_agree then
        if self.parent.team_id then
            ---@type Server_TeamManager
            local team_manager = server.team_manager
            team_manager:JoinTeam(self.parent.team_id,p)
        else
            ---@type Server_TeamManager
            local team_manager = server.team_manager 
            local team = team_manager:CreateTeam()
            team_manager:JoinTeam(team.id,self.parent)
            team_manager:JoinTeam(team.id,p)
        end
    else

    end
    return self.invite_player_agree
end

function c:ReplyInvitePlayer(player,agree)
    if not player then
        return
    end
    ---@type Server_Player
    local p = inst_manager:FindObject(player)
    if not p then
        return
    end

    if player ~= self.invite_player then
        return false
    end
    self.invite_player_agree = agree
    self.replay_invite = true
end

function c:ExitTeam()
    if not self.parent.team_id then
        return
    end
    ---@type Server_TeamManager
    local team_manager = server.team_manager
    team_manager:LeaveTeam(self.parent)
    return true
end

function c:SetTeamCanJoin(canJoin)
    if not self.parent.team_id then
        return
    end
    ---@type Server_TeamManager
    local team_manager = server.team_manager
    local team = team_manager:GetTeam(self.parent.team_id)
    if not team then
        return
    end
    team.canJoin = canJoin
end

---@param player Player
function c:RequestJoinTeam(player)
    if self.parent.team_id then
        return false,0
    end

    ---@type Server_Player
    local p = inst_manager:FindObject(player)
    if not p then
        return false,1
    end

    ---@type Server_TeamManager
    local team_manager = server.team_manager
    local team = team_manager:GetTeam(p.team_id)
    if not team then
        return false,1
    end
    if not team.canJoin then
        return false,2
    end
    if team.player_count >= 4 then
        return false,3
    end
    
    local p = team.owner
    hotpot.event_manager:Fire(p,'p_apply_join_team',self.parent.main_inst)
    local wait_time = 6
    while true do
        wait_time = wait_time - wait(.1)
        if wait_time <= 0 then
            break
        end
        if self.replay_join then
            break
        end
    end
    return self.apply_join_player_agree
end

function c:ApplyJoinTeam(player,agree)
    if not player then
        return
    end
    ---@type Server_Player
    local p = inst_manager:FindObject(player)
    if not p then
        return
    end
    p.team_cmp.apply_join_player_agree = agree
    p.team_cmp.replay_join = true

    ---@type Server_TeamManager
    local team_manager = server.team_manager
    if agree then
        team_manager:JoinTeam(self.parent.team_id,p)
    end
end

function c:SetTeamOwner(uid)
    if not self.parent.team_id then
        return
    end
    ---@type Server_TeamManager
    local team_manager = server.team_manager
    local team = team_manager:GetTeam(self.parent.team_id)
    if not team then
        return
    end

    local isIn = false
    local player = nil
    for p,_ in pairs(team.player)do
        if p.user_id == uid then
            isIn = true
            player = p
        end
    end
    if not isIn then
        return
    end
    team.owner = player
    for k,v in pairs(team.player) do
        hotpot.event_manager:Fire(k,'TeamOwnerChange',player.main_inst)
    end
end

function c:KickTeamPlayer(uid)
    if not self.parent.team_id then
        return
    end
    ---@type Server_TeamManager
    local team_manager = server.team_manager
    local team = team_manager:GetTeam(self.parent.team_id)
    if not team then
        return
    end

    local isIn = false
    local player = nil
    for p,_ in pairs(team.player)do
        if p.user_id == uid then
            isIn = true
            player = p
        end
    end
    if not isIn then
        return
    end
    team_manager:LeaveTeam(player)
    hotpot.event_manager:Fire(player,'kickPlayer',self.parent.main_inst)
    return true
end

c:RegistFunction('viewPlayerInfo',c.ViewPlayerInfo)
c:RegistFunction('invitePlayerToTeam',c.InvitePlayer)
c:RegistFunction('exitTeam',c.ExitTeam)
c:RegistFunction('p_joinTeam',c.RequestJoinTeam)
c:RegistEvent('setTeamOwner',c.SetTeamOwner)
c:RegistFunction('kickTeamPlayer',c.KickTeamPlayer)

hotpot.event_manager:RegistHandle('ReplyInvitePlayer',function(p,player,agree)
    ---@type Server_Player
    local obj = inst_manager:FindObject(player)
    if not obj then
        return
    end
    obj.team_cmp:ReplyInvitePlayer(p.main_inst,agree)
end)

hotpot.event_manager:RegistHandle('ReplyJoinPlayer',function(p,player,agree)
    ---@type Server_Player
    local obj = inst_manager:FindObject(player)
    if not obj then
        return
    end
    p.team_cmp:ApplyJoinTeam(player,agree)
end)

return c
