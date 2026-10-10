local hotpot = _G.ServerHotpot
---@type CurveHelper
local curveHelper = hotpot.load.CurveHelper()
---@type Players
local Players = game:GetService('Players')
---@type Server_RankManager
local rank_manager = hotpot.load.Server_RankManager()
local Debris = game:GetService('Debris')
---@type InstanceManager
local inst_manager = hotpot.load.InstanceManager()
---@type DataStoreService
local DataStoreService = game:GetService('DataStoreService')
local MessagingService = game:GetService('MessagingService')

local monsterFol = hotpot:GetPath_Loop('monster',hotpot.Resource)
local dropFol = hotpot:GetPath_Loop('Drop',hotpot.Resource)
local boss1Part = hotpot:GetPath_Loop('Stage.monsterPos.8',workspace)
local boss2Part = hotpot:GetPath_Loop('Stage.monsterPos.9',workspace)
local boss1Interval = 3600
local boss2Interval = 3600 * 8
local eff = hotpot:GetPath_Loop('pfb.PumpkinEff',hotpot.Resource)
local Event = game.ReplicatedStorage:WaitForChild('Event')
local spawn = workspace:FindFirstChild('SpawnLocation')
local BASETIME = 1769644800
local INTERVAL = 86400 * 7

---@class Server_PvpStageObj:ModelObject
local c = hotpot.class.new(script,hotpot.files.ModelObject())
function c.new(model)
    return c(model)
end
function c:ctor(model)
    c.super.ctor(self,model)

    self.player_list = {}
    self.guid_to_player = {}
    self.guid_to_monster = {}
    ---@type table<Part,table>
    self.point_list = {}

    self.monster_fol = hotpot:GetPath_Loop('Stage.monster',workspace)

    self:LoadMonster()
    self:LoadRank()
    self:GetChallengeRank()
    self:AddUpdate(self.LoadRank,600)
    self:AddUpdate(self.UpdateBoss,1)
    self:AddUpdate(self.UpdateRefresh,0.5)
    self:AddUpdate(self.GetChallengeRank,200)

    Event.Event:Connect(function(str,guid,part)
        if str == 'pvpDropTouched' then
            self:PlayerTouchDrop(guid,part)
        end
    end)
end

function c:UpdateBoss()
    --第一个
    local now = os.time()
    local interval = now % boss1Interval
    interval = boss1Interval - interval
    if interval - 1 == 0 then
        self:LoadBoss1()
    end

    --第2个
    local interval2 = now % boss2Interval
    interval2 = boss2Interval - interval2
    if interval2 - 1 == 0 then
        self:LoadBoss2()
    end
end

function c:LoadMonster()
    local monsterPos = hotpot:GetPath_Loop('Stage.monsterPos',workspace)
    for _,part in ipairs(monsterPos:getChildren()) do
        if not part:GetAttribute('is_boss') then

            self.point_list[part] = {}

            local id = tonumber(part.Name)
            local cfg = hotpot.config.pvpMonster[id]
            local model = monsterFol:FindFirstChild(cfg.model)
            model = model:Clone()
            local monster = hotpot.load.Server_PvpMonsterObj().new(model,self,cfg,part)
            monster:Init()
            self.guid_to_monster[monster.guid] = monster

            self.point_list[part] = {
                is_alive = true,
            }
        end
    end
end

function c:LoadBoss1()
    self:AddProcess(function()
        if self.boss1_obj then
            return
        end
        local id = 8
        local cfg = hotpot.config.pvpMonster[id]
        local model = monsterFol:FindFirstChild(cfg.model)
        model = model:Clone()
        local boss = hotpot.load.Server_PvpMonsterObj().new(model,self,cfg,boss1Part)
        boss:Init()
        boss:InitPool(false)
        hotpot.event_manager:FireAll('pvp_boss_spawn',cfg.name)
        hotpot.event_manager:FireAll('pvp_boss_hp_change',{
            id = id,
            hp = boss.hp,
            max_hp = boss.max_hp,
        })
        
        local eff_model = hotpot:CloneInst_Loop(eff)
        eff_model.Parent = workspace
        eff_model:SetPrimaryPartCFrame(boss1Part.CFrame)
        
        Debris:AddItem(eff_model,10)
        
        self.boss1_obj = boss

        self:Wait(10)
        self.guid_to_monster[boss.guid] = boss
    end)
end

function c:LoadBoss2()
    self:AddProcess(function()
        if self.boss2_obj then
            return
        end
        local id = 9
        local cfg = hotpot.config.pvpMonster[id]
        local model = monsterFol:FindFirstChild(cfg.model)
        model = model:Clone()
        local boss = hotpot.load.Server_PvpMonsterObj().new(model,self,cfg,boss2Part)
        boss:Init()
        boss:InitPool(true)
        hotpot.event_manager:FireAll('pvp_boss_spawn',cfg.name)
        hotpot.event_manager:FireAll('pvp_boss_hp_change',{
            id = id,
            hp = boss.hp,
            max_hp = boss.max_hp,
        })
        
        local eff_model = hotpot:CloneInst_Loop(eff)
        eff_model.Parent = workspace
        eff_model:SetPrimaryPartCFrame(boss2Part.CFrame)
        Debris:AddItem(eff_model,10)
        
        self.boss2_obj = boss
        
        self:Wait(10)
        self.guid_to_monster[boss.guid] = boss
    end)
end

function c:LoadRank()
    local blackList = {}
    self:AddProcess(function()
        local kill = rank_manager:GetRankList('pvp_kill',false,60)

        for k,v in ipairs(kill)do
            if blackList[tonumber(v.key)] then
                table.remove(kill,k)
            end
        end

        local ScrollingFrame = hotpot:GetPath_Loop('Stage.rank.kill.root.SurfaceGui.Frame.ScrollingFrame',workspace)
        for i = 1,50 do
            local item = ScrollingFrame:FindFirstChild(tostring(i))
            if kill[i] then
                item.rank.Text = i
                local r,e = pcall(function()
                    return Players:GetNameFromUserIdAsync(kill[i].key)
                end)
                if not r then
                    e = 'UnknownName'
                end
                item.name.Text = e
                item.name.TextScaled = true
                item.value.Text = kill[i].value
                item.Visible = true
            else
                item.Visible = false
            end
        end
    end)
    self:AddProcess(function()
        local kill = rank_manager:GetRankList('pvp_score',false,50)
        for k,v in ipairs(kill)do
            if blackList[tonumber(v.key)] then
                table.remove(kill,k)
            end
        end
        local ScrollingFrame = hotpot:GetPath_Loop('Stage.rank.coin.root.SurfaceGui.Frame.ScrollingFrame',workspace)
        for i = 1,50 do
            local item = ScrollingFrame:FindFirstChild(tostring(i))
            if kill[i] then
                item.rank.Text = i
                local r,e = pcall(function()
                    return Players:GetNameFromUserIdAsync(kill[i].key)
                end)
                if not r then
                    e = 'UnknownName'
                end
                item.name.Text = e
                item.name.TextScaled = true
                item.value.Text = kill[i].value
                item.Visible = true
            else
                item.Visible = false
            end
        end
    end)
end

---@param player Server_Player
function c:PlayerIn(player)
    self.player_list[player] = true
    self.guid_to_player[player.guid] = player

    player.atkCount = 0

    player.pvp_stage_obj = self

    player.sync_cmp:AddHandle('pvp_player_atk',self,self.PlayerAtk)
    player.sync_cmp:AddHandle('pvp_skill',self,self.PlayerSkill)

    ---@type Server_PlayerCharacter
    local cha = player.character
    if cha then
        local pos = spawn.Position
        local size = spawn.Size
        local ran = pos + Vector3.new(math.random(-size.X/2,size.X/2),0,math.random(-size.Z/2,size.Z/2))
        cha:SetBottomPosition(ran)
    end
end

---@param player Server_Player
function c:PlayerOut(player)
    player.ConsecutiveKill = 0

    if self.player_list[player] then
        self.player_list[player] = nil
    end
    if self.guid_to_player[player.guid] then
        self.guid_to_player[player.guid] = nil
    end
end

function c:PlayerAtk(info)
    local atkPlayerGuid = info.player_guid
    ---@type Server_Player
    local atkPlayer = self.guid_to_player[atkPlayerGuid]
    if not atkPlayer then
        return
    end
    if atkPlayer.safeValue.Value then
        return 
    end
    local monsterResult = info.monster
    local playerResult = info.player

    --检测
    if not next(playerResult) then
        atkPlayer.atkCount = 0
    end
    local collider = playerResult[1]
    if #playerResult == 1 and collider == atkPlayer.character.collider then
        atkPlayer.atkCount = 0
    end

    atkPlayer.atkCount = atkPlayer.atkCount + 1

    self:AddProcess(function()
        self:Wait(.3)
        for _,collider in pairs(monsterResult)do
            local guid = collider:GetAttribute('guid')
            if guid then
                ---@type Server_PvpMonsterObj
                local monster = self.guid_to_monster[guid]
                if monster then
                    if not monster.is_die then
                        monster:BeDamage(atkPlayer.guid)
                        hotpot.event_manager:FireAll('show_dmg',{
                            pos = monster:GetPosition(),
                            dmg = 1,
                        })
                    end

                end
            end
        end
    end)

    self:AddProcess(function()
        self:Wait(.3)
        for _,collider in pairs(playerResult)do
            local guid = collider:GetAttribute('guid')
            if guid then
                if guid ~= atkPlayer.guid then
                    ---@type Server_Player
                    local target = self.guid_to_player[guid]
                    if target then

                        local team_id = atkPlayer.team_id
                        if team_id then
                            if team_id == target.team_id then
                                return
                            end
                        end

                        if not (target.safeValue and target.safeValue.Value) then
                            self:PlayerAtkPlayer(atkPlayer,target)
                        end

                    end
                end
            end
        end
    end)
end

---@param player Server_Player
---@param target Server_Player
function c:PlayerAtkPlayer(player,target)
    if player.safeValue.Value then
        return
    end
    if target.safeValue.Value then
        return
    end
    local atk = player.prop_cmp:GetPKAtk()
    if not target then
        return
    end
    if not target.character then
        return
    end
    if not player.character then
        return
    end
    if target.character.is_die then
        return
    end
    if player.character.is_die then
        return
    end

    if hotpot.pro_cfg.IsInGuildBattleTime() then
        local guildId1 = player.guild_cmp:GetGuildId()
        local guildId2 = target.guild_cmp:GetGuildId()
        if guildId1 == guildId2 then
            return
        end
    end

    -- atk = 1000000000

    -- local atkCount = player.atkCount
    -- if atkCount > 1 then
    --     atk = atk * (1.1 ^ (atkCount - 1))
    -- end
    pcall(function()
        target.character:BeDamage(player.main_inst,atk)
        local pos = target.character and target.character:GetPosition() or Vector3.new()
        hotpot.event_manager:FireAll('show_dmg',{
            pos = pos,
            dmg = math.floor(atk),
        })
    end)
end

---@param monster Server_PvpMonsterObj
---@param source number
function c:MonsterDie(monster,source)
    local player = self.guid_to_player[source]
    if player then
        -- player.prop_cmp:AddPKExp(monster.cfg.exp)
    end

    local part = monster.part
    if part then
        if self.point_list[part] then
            self.point_list[part].is_alive = false
            self.point_list[part].time_ = 10
        end
    end

    local cfg = monster.cfg

    local cf = monster:GetCFrame()
    local bottom = monster:GetBottomPosition()

    if cfg.is_boss then
        local r,e = pcall(function()
            local startPos = cf.Position
            for k,reward in ipairs(monster.pool) do
                local overPos = startPos + Vector3.new(
                    math.random(-40,40),
                    0,
                    math.random(-40,40)
                )
                overPos = Vector3.new(overPos.X,bottom.Y,overPos.Z)
                local centerPos = (startPos + overPos) / 2 + Vector3.new(0,20,0)
                self:AddHeartBeatProcess(function()
                    self:Wait(.3)

                    local part
                    if reward[1] == 1 then
                        part = dropFol:FindFirstChild('PvpDrop')
                    elseif reward[1] == 4 then
                        if reward[2] == 71 or reward[2] == 36 then
                            part = dropFol:FindFirstChild('relicsDrop2')
                        else
                            part = dropFol:FindFirstChild('relicsDrop1')
                        end
                    else
                        if reward[2] == 1 then
                            part = dropFol:FindFirstChild('forgeDrop1')
                        elseif reward[2] == 2 then
                            part = dropFol:FindFirstChild('forgeDrop2')
                        else
                            part = dropFol:FindFirstChild('forgeDrop3')
                        end
                    end

                    part = part:Clone()
                    part:SetAttribute('r1',reward[1])
                    part:SetAttribute('r2',reward[2])
                    part:SetAttribute('r3',reward[3])
                    part.CanTouch = false

                    local icon = player.reward_cmp:GetIcon(reward)
                    local img = hotpot:GetPath_Loop('a.Frame.ImageLabel',part)
                    img.Image = icon or ''

                    part.Parent = workspace.Drop
                    local time_len = 1
                    local interval = 0
                    local pos
                    while true do
                        interval = interval + self:Wait()
                        interval = math.min(interval,time_len)
                        pos = curveHelper:BezierCurve(startPos,centerPos,overPos,interval/time_len)
                        part.Position = pos
                        if interval >= time_len then
                            break
                        end
                    end
                    self:Wait(.2)
                    part.CanTouch = true
                end)
            end
        end)
        if not r then
            warn(e)
        end

        pcall(function()
            ---@type Server_Player
            local player_obj = self.guid_to_player[source]
            if not player_obj then
                return
            end
            local guild_name = player_obj.guild_cmp:GetGuildName()
            local bossName = cfg.name
            local playerName = player_obj.main_inst.Name
            MessagingService:PublishAsync('pvpkillmsg',
                {
                    guild_name = guild_name,
                    bossName = bossName,
                    playerName = playerName,
                }
            )
        end)
        
        self:CheckGuildWar(player,30)
    else
        self:CheckGuildWar(player,1)
        for guid,dmg in pairs(monster.dmg_list)do
            local r,e = pcall(function()
                ---@type Server_Player
                local player = self.guid_to_player[guid]
                if player then
                    --金币钻石
                    local wins = monster.gold
                    local gems = monster.gems
                    local per = dmg / monster.max_hp
                    player.reward_cmp:AddReward({{1,3,math.ceil(wins * per)}})
                    player.reward_cmp:AddReward({{1,2,math.ceil(gems * per)}})
                    --pvp币
                    local per = monster.pvpCoinPer
                    local num = monster.pvpCoin
                    if math.random() <= per then
                        player.reward_cmp:AddReward({{1,12,num}})
                    end
                end
            end)
            if not r then
                warn(e)
            end
        end
    end

    if monster == self.boss1_obj then
        self.boss1_obj = nil
    end
    if monster == self.boss2_obj then
        self.boss2_obj = nil
    end

    monster:dtor()

end

function c:PlayerSkill(info)
    local playerGuid = info.player_guid
    ---@type Server_Player
    local player = self.guid_to_player[playerGuid]
    if not player then
        return
    end

    if player.safeValue.Value then
        return
    end
    local skillId = info.skill_id
    local solt = info.solt
    local playerList = info.playerList
    local monsterList = info.monsterList

    self:AddProcess(function()
        for _,collider in ipairs(playerList)do
            local guid = collider:GetAttribute('guid')
            if guid then
                if guid ~= playerGuid then
                    ---@type Server_Player
                    local target = self.guid_to_player[guid]
                    if target then

                        if hotpot.pro_cfg.IsInGuildBattleTime() then
                            local guildId1 = player.guild_cmp:GetGuildId()
                            local guildId2 = target.guild_cmp:GetGuildId()
                            if guildId1 == guildId2 then
                                break
                            end
                        end

                        if target.safeValue and target.safeValue.Value == false then
                            local atk = player.prop_cmp:GetPKAtk()
                            local skill_per = player.skill_cmp:GetSkillPer(solt)
                            local dmg = atk * skill_per
                            if target.character then
                                target.character:BeDamage(player.main_inst,dmg)
                                pcall(function()
                                    local pos = target.character and target.character:GetPosition() or Vector3.new()
                                    hotpot.event_manager:FireAll('show_dmg',{
                                        pos = pos,
                                        dmg = math.floor(dmg),
                                    })
                                end)
                            end
                        end
                    end
                end
            end
        end
    end)

    self:AddProcess(function()
        for _,collider in ipairs(monsterList)do
            local guid = collider:GetAttribute('guid')
            if guid then
                ---@type Server_PvpMonsterObj
                local monster = self.guid_to_monster[guid]
                if monster then
                    if not monster.is_die then
                        monster:BeDamage(player.guid)
                        hotpot.event_manager:FireAll('show_dmg',{
                            pos = monster:GetPosition(),
                            dmg = 1,
                        })
                    end
                end
            end
        end
    end)
end

---@param player Player
---@param target Server_Player
function c:PlayerKillPlayer(player,target)
    pcall(function()
        rank_manager:IncrementRankValue('pvp_kill',player.UserId,1)
    end)

    if not player then
        return
    end

    ---@type Server_Player
    local obj = inst_manager:FindObject(player)
    if obj then
        obj.title_cmp:AddPoint(11,1)
    end

    hotpot.event_manager:FireAll('pvp_kill',{
        killer = player,
        target = target.main_inst,
    })
end

--判断公会战
---@param player Server_Player
function c:CheckGuildWar(player,score)
    --判断是否在规定时间内
    if not hotpot.pro_cfg.IsInGuildBattleTime() then
        return
    end
    local week = hotpot.pro_cfg.GetWeek()
    --判断是否报名
    if not player.guild_cmp then
        return
    end
    local guildInfo = player.guild_cmp.guildInfo
    if not guildInfo then
        return
    end
    if not guildInfo.warInfo then
        return
    end
    if not (guildInfo.warInfo.is_join and week == guildInfo.warInfo.week) then
        return
    end
    self:AddProcess(function()
        player.guild_cmp:AddKillInWarRank(score)
    end)
end

function c:PlayerTouchDrop(guid,part)
    local player = self.guid_to_player[guid]
    if not player then
        return
    end
    local r1 = part:GetAttribute('r1')
    local r2 = part:GetAttribute('r2')
    local r3 = part:GetAttribute('r3')

    part:Destroy()

    player.reward_cmp:AddReward({{r1,r2,r3}})
end

--更新怪物刷新逻辑
function c:UpdateRefresh(step)
    for part,tab in pairs(self.point_list)do
        if not tab.is_alive then
            tab.time_ = tab.time_ - step
            if tab.time_ <= 0 then
                self:MonsterReborn(part)
            end
        end
    end
end

--怪物复活
function c:MonsterReborn(part)
    local tab = self.point_list[part]
    tab.is_alive = true
    local id = tonumber(part.Name)
    local cfg = hotpot.config.pvpMonster[id]
    local model = monsterFol:FindFirstChild(cfg.model)
    model = model:Clone()
    local monster = hotpot.load.Server_PvpMonsterObj().new(model,self,cfg,part)
    monster:Init()
    self.guid_to_monster[monster.guid] = monster
end

--获取挑战排名
function c:GetChallengeRank()
    local now = os.time()
    local mark = math.floor((now - BASETIME) / INTERVAL)

    mark = mark - 1--获取上周的排名
    if mark < 0 then
        return false
    end

    local sortName = 'challenge_stage_' .. mark
    local DataStore = DataStoreService:GetOrderedDataStore(sortName)

    local list = DataStore:GetSortedAsync(false,30)
    if not list then
        return false
    end
    list = list:GetCurrentPage()
    self.challenge_rank_list = list
    self.challenge_rank_mark = mark
end

---@param player Server_Player
hotpot.function_manager:SetHandle('challengeClaim',function(player)
    ---@type Server_PvpStageObj
    local stage = player.pvp_stage_obj
    if not stage then
        return
    end
    local list = stage.challenge_rank_list
    if not list then
        return
    end
    local rank = 0
    for rank_,item in ipairs(list)do
        if tonumber(item.key) == tonumber(player.user_id) then
            rank = rank_
            break
        end
    end

    if rank == 0 then
        return
    end

    if rank > 10 then
        return false,1
    end
    local mark = stage.challenge_rank_mark
    if not mark then
        return
    end
    if not player.challenge_cmp:CanClaimRank(mark,rank) then
        return false,2
    end
    player.challenge_cmp:GetRankReward()

    return true
end)

return c
