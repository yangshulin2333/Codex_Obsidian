local hotpot = _G.ServerHotpot

local expList = {
    [0] = {1,1},
    [1] = {1,1},
    [2] = {0.7,0.6},--1.3
    [3] = {0.5,0.4},--1.3
    [4] = {0.4,0.3},--1.3
    [5] = {0.3,0.2},--1.3
}

---@class Server_TeamManager:BaseObject
local c = hotpot.class.new(script,hotpot.files.BaseObject())
function c.new()
    return c()
end
function c:ctor()
    c.super.ctor(self)

    self.teamId = 0

    self.team_list = {}
end

function c:GetTeam(id)
    return self.team_list[id]
end

function c:CreateTeam()
    local team = {}
    self.teamId = self.teamId + 1
    team.id = self.teamId
    team.player_count = 0
    team.owner = nil
    team.player = {}
    team.canJoin = true

    self.team_list[team.id] = team
    return team
end

---@param player Server_Player
function c:JoinTeam(id,player)
    local team = self.team_list[id]
    if not team then
        return
    end

    if team.player_count >= 5 then
        return
    end

    team.player_count = team.player_count + 1
    team.player[player] = true

    if team.player_count == 1 then
        team.owner = player
    end

    player.team_id = id


    local pInfo = {}
    for k,v in pairs(team.player) do
        local r,e = pcall(function()
            ---@type Server_PlayerCharacter
            local character = k.character
            pInfo[k.user_id] = {hp = character.hp,max_hp = character.max_hp}
        end)
        if not r then
            warn(e)
        end
    end

    for k,_ in pairs(team.player) do
        hotpot.event_manager:Fire(k,'TeamJoin',{
            team_id = team.id,
            owner = team.owner.main_inst,
            join_player = player.main_inst,
            info = pInfo,
        })
    end
end

function c:LeaveTeam(player)
    if not player.team_id then
        return
    end
    local team = self.team_list[player.team_id]
    if not team then
        return
    end

    for k,v in pairs(team.player) do
        hotpot.event_manager:Fire(k,'TeamLeave',{
            team_id = team.id,
            owner = team.owner.main_inst,
            leave_player = player.main_inst,
        })
    end

    team.player_count = team.player_count - 1
    team.player[player] = nil
    player.team_id = nil

    local owner = team.owner
    if owner == player then
        local p = next(team.player)
        if p then
            team.owner = p
            for k,v in pairs(team.player) do
                hotpot.event_manager:Fire(k,'TeamOwnerChange',p.main_inst)
            end
        end
    end  

    if team.player_count <= 1 then
        local owner = team.owner
        if owner then
            self:LeaveTeam(owner)
        end
        self:DestroyTeam(team.id)
    end
end

function c:DestroyTeam(id)
    local team = self.team_list[id]
    if not team then
        return
    end
    team.owner = nil
    team.player_count = 0
    team.player = {}
    self.team_list[id] = nil
end

function c:SyncPlayerData(player)
    local team_id = player.team_id
    if not team_id then
        return
    end
    local team = self.team_list[team_id]
    if not team then
        return
    end
    if not player.character then
        return
    end
    local hp = player.character.hp
    local max_hp = player.character.max_hp
    for k,v in pairs(team.player) do
        hotpot.event_manager:Fire(k,'TeamSyncPlayerData',{
            uid = player.user_id,
            hp = hp,
            max_hp = max_hp,
        })
    end
end

---@param player Server_Player
function c:GetPlayerCountWithStage(player)
    local team_id = player.team_id
    if not team_id then
        return 0
    end
    local team = self.team_list[team_id]
    if not team then
        return 0
    end
    local stageId = player.now_stage.id
    local count = 0
    for k,v in pairs(team.player) do
        if k.now_stage.id == stageId then
            count = count + 1
        end
    end
    return count
end

function c:PlayerChangeStage(player,stageId)
    local team_id = player.team_id
    if not team_id then
        return
    end
    local team = self.team_list[team_id]
    if not team then
        return
    end
    local sInfo = {}
    for k,v in pairs(team.player) do
        sInfo[k.user_id] = k.now_stage.id
    end
    for k,v in pairs(team.player) do
        hotpot.event_manager:Fire(k,'TeamPlayerChangeStage',sInfo)
    end
end

function c:AddExpByTeam(player,exp)
    local team_id = player.team_id
    if not team_id then
        return
    end
    local team = self.team_list[team_id]
    if not team then
        return
    end
    local stageId = player.now_stage.id
    if stageId == 'christmas' then
        player.prop_cmp:AddExp(exp)
        return
    end
    local count = self:GetPlayerCountWithStage(player)
    local expPer = expList[count] or expList[3]
    for k,v in pairs(team.player) do
        if k.now_stage.id == stageId then
            if k.user_id == player.user_id then
                k.prop_cmp:AddExp(exp * expPer[1])
            else
                k.prop_cmp:AddExp(exp * expPer[2])
            end
        end
    end
end

return c