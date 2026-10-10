local hotpot = _G.ServerHotpot
---@type Server_PartyMonsterObj
local monster_obj = hotpot.load.Server_PartyMonsterObj()
---@type Server_RankManager
local rankManager = hotpot.load.Server_RankManager()
---@type InstanceManager
local inst_manager = hotpot.load.InstanceManager()
---@type PlaceManager
local place_manager = hotpot.load.PlaceManager()

local PartyCfg = hotpot.config.Party
local MonsterCfg = hotpot.config.PartyMonster
local TIME_1 = 20
local TIME_2 = 15*60
local monster_fol = hotpot:GetPath_Loop('monster',hotpot.Resource)
local ov = OverlapParams.new()
ov.CollisionGroup = 'check_monster'
local loadingGui = hotpot:GetPath_Loop('ui.LoadingGui',hotpot.Resource)

---@class Server_PartyStageObj:ModelObject
local c = hotpot.class.new(script,hotpot.files.ModelObject())
function c.new(model,cfg_id,difficulty)
    return c(model,cfg_id,difficulty)
end

function c:ctor(model,cfg_id,difficulty)
    c.super.ctor(self,model)

    self.cfg_id = cfg_id
    self.difficulty = difficulty

    ---@type table<Server_Player,boolean>
    self.player_list = {}
    ---@type table<number,Server_Player>
    self.guid_to_player = {}
    self.die_player = {}

    self.pass_area = 0--已通过的区域

    self.monster_fol = self.main_inst:WaitForChild('monster')
    self.spawn_part = self.main_inst:WaitForChild('spawn')

    self:LoadMonster()

    self.cd_Text = hotpot:GetPath_Loop('cdGui.SurfaceGui.cd',self.main_inst)

    self.spawn_idx = 1

    self.resetList = {}
end

--加载怪物信息
function c:LoadMonster()
    ---@type table<Part,Server_MonsterObj>
    self.monster_list = {}
    ---@type table<number,Server_MonsterObj>
    self.guid_to_monster = {}
    ---@type table<number,table<number,Part>>
    self.area_list = {}
    ---@type table<Part,table>
    self.point_list = {}
    local fol = self.main_inst:WaitForChild('monsterPos')
    local num = (self.cfg_id - 1) * 3 + self.difficulty

    if not self.deal then
        --提前处理
        for k,v in ipairs(fol:GetChildren())do
            local name = tonumber(v.Name)
            name = name + (num - 1) * 4
            v.Name = name
        end
        self.deal = true
    end

    for k,v in ipairs(fol:GetChildren())do
        local part = v
        local id = tonumber(v.Name)
        local cfg = MonsterCfg[id]
        local model = monster_fol:FindFirstChild(cfg.model)
        model = hotpot:CloneInst_Loop(model)
        local obj = monster_obj.new(model,self,cfg,part)
        local guid = obj.guid
        model:SetAttribute('guid',guid)
        self.guid_to_monster[guid] = obj
        self.monster_list[v] = obj
        self.point_list[v] = {
            obj = obj,
            time_ = 0,
            is_alive = true,
        }

        if cfg.is_boss then
            self.boss_name = cfg.name
            self.boos_hp = cfg.hp
        end

        local area = v:GetAttribute('area')
        if area then
            self.area_list[area] = self.area_list[area] or {}
            table.insert(self.area_list[area],v)
        end
    end
end

--玩家进入
---@param player Server_Player
function c:PlayerIn(player)
    self.player_list[player] = true
    self.guid_to_player[player.guid] = player

    self:Sync(player)

    player.now_stage = self
    player.rebornCount = 2
    player.partyKillNum = 0
    player.partyDmg = 0

    self:StartRun()
end

--玩家退出
---@param player Server_Player
function c:PlayerOut(player)
    self.player_list[player] = nil
    self.guid_to_player[player.guid] = nil

    player.now_stage = nil
end

--注册事件
---@param player Server_Player
function c:Sync(player)
    player:AddProcess(function()
        while true do
            player:Wait(1)
            if player.sync_cmp then
                break
            end
        end
        player.sync_cmp:AddHandle('party_player_attack_monster',self,self.PlayerAttackMonster)
        player.sync_cmp:AddHandle('party_player_skill_monster',self,self.PlayerSkillMonster)
    end)
end

--向所有玩家发送消息
function c:SendAllPlayer(name,info)
    for player,_ in pairs(self.player_list)do
        if player and player.sync_cmp and player.sync_cmp.IsExist and player.sync_cmp:IsExist()then
            player.sync_cmp:Add(name,info)
        end
    end
end

--玩家攻击怪物
function c:PlayerAttackMonster(info)
    ---@type Server_Player
    local player = self.guid_to_player[info.player_guid]
    if not player then
        return false
    end
    if player and player.character and player.character.is_die then
        return
    end
    ---@type Server_PlayerCharacter
    local character = player.character

    local atk = math.floor(player.prop_cmp:GetAttack())

    local dir = character:GetCFrame().LookVector
    local result = workspace:GetPartsInPart(character.attackCheck,ov)
    --local result = workspace:GetPartBoundsInRadius(character:GetPosition() + dir * 2,10,ov)
    -- print(result)
    if result then
        for k,collider in ipairs(result)do
            local model = collider.Parent
            if model and model:IsA('Model') then
                local guid = model:GetAttribute('guid')
                guid = guid or 0
                ---@type Server_PartyMonsterObj
                local obj = self.guid_to_monster[guid]
                if obj then
                    local pos = obj:GetPosition()
                    local max_hp = obj.max_hp
                    local now_hp = obj.hp
                    local is_boss = obj.cfg.is_boss
                    local is_die = obj:BeDamage(info.player_guid,atk)

                    player.stats_cmp:AddTotalDmg(atk)

                    if is_die then
                        now_hp = 0
                    else
                        now_hp = obj.hp
                    end
                    self:SendAllPlayer('party_monster_be_dmg',{
                        is_boss = is_boss,
                        max_hp = max_hp,
                        now_hp = now_hp,
                        dmg = atk,
                        player_guid = info.player_guid,
                        pos = pos,
                    })
                    player.partyDmg = player.partyDmg + atk
                end
            end
        end
    end
end

--玩家技能攻击怪物
function c:PlayerSkillMonster(info)
    ---@type Server_Player
    local player = self.guid_to_player[info.player_guid]
    if not player then
        return false
    end
    if player and player.character and player.character.is_die then
        return
    end

    local atk = math.floor(player.prop_cmp:GetAttack())
    local per = player.skill_cmp:GetSkillPer(info.slot)
    atk = atk * per
    local guid = info.monster_guid
    ---@type Server_PartyMonsterObj
    local obj = self.guid_to_monster[guid]
    if obj then
        local pos = obj:GetPosition()
        local max_hp = obj.max_hp
        local now_hp = obj.hp
        local is_boss = obj.cfg.is_boss
        local is_die = obj:BeDamage(info.player_guid,atk)
        player.stats_cmp:AddTotalDmg(atk)

        if is_die then
            now_hp = 0
        else
            now_hp = obj.hp
        end
        self:SendAllPlayer('party_monster_be_dmg',{
            is_boss = is_boss,
            max_hp = max_hp,
            now_hp = now_hp,
            dmg = atk,
            player_guid = info.player_guid,
            pos = pos,
        })
        player.partyDmg = player.partyDmg + atk
    end
end

--怪物死亡
function c:MonsterDie(obj,source)
    local player = self.guid_to_player[source]
    if player then
        player.partyKillNum = player.partyKillNum + 1
        pcall(function()
            rankManager:IncrementRankValue('party_kill',player.user_id,1)
        end)
    end

    local list = obj.dmg_list
    local monster_guid = obj.guid
    local per = obj.cfg.per
    local gems = obj.cfg.gems
    if per then
        -- 结算钻石
        pcall(function()
            for guid,_ in pairs(list)do
                ---@type Server_Player
                local player = self.guid_to_player[guid]
                if player then
                    local random = math.random(1,100)
                    if random <= per then
                        --获得钻石
                        -- player.prop_cmp:AddGems(gems)
                        player.reward_cmp:AddReward({{1,2,gems}})
                    end
                    player.title_cmp:AddPoint(1,1)
                    if obj.cfg.is_boss then
                        player.title_cmp:AddPoint(8,1)
                    end
                end
            end
        end)
    end

    if list then
        for guid,_ in pairs(list)do
            ---@type Server_Player
            local player = self.guid_to_player[guid]
            if player then
                player:KillMonster()
                local r,e = pcall(function()
                    rankManager:IncrementRankValue('kill',player.user_id,1)
                end)
                if not r then
                    warn(e)
                end
            end
        end
    end

    self:SendAllPlayer('party_monster_die',{
        monster_guid = monster_guid,
        stage_id = self.id,
        monster_id = obj.id,
    })
end

function c:DestroyMonster(guid)
    local obj = self.guid_to_monster[guid]
    if not obj then
        return
    end
    local part = obj.part
    local tab = self.point_list[part]
    if not part then
        return
    end

    tab.obj = nil
    tab.time_ = 9999999
    tab.is_alive = false

    self.monster_list[obj] = nil
    self.guid_to_monster[obj.guid] = nil
    obj:dtor()

    self:SendAllPlayer('party_monster_destroy',{
        monster_guid = guid,
        stage_id = self.id,
        part = part,
    })

    self:CheckAreaPass()
end

--怪物攻击玩家
function c:MonsterAttackPlayer(monster_guid,players,dmg)
    for player_guid,_ in pairs(players)do
        local r,e = pcall(function()
            local player = self.guid_to_player[player_guid]
            if not player then
                return
            end
            ---@type Server_PlayerCharacter
            local character = player.character
            if not (character and character.IsExist and character:IsExist()) then
                return
            end
            character:BeDamage(monster_guid,dmg)
            self:SendAllPlayer('party_monster_atk_player',{
                pos = character:GetPosition(),
                dmg = dmg,
            })
        end)
        if not r then
            warn(e)
        end
    end
end

--死亡立即结算奖励
---@param obj Server_MonsterObj
function c:GiveReward(obj)
    if self.game_over then
        return
    end
    local exp = obj.cfg.exp

    for guid,dmg in pairs(obj.dmg_list)do
        local obj_ = self.guid_to_player[guid]
        if obj_ then
            -- obj_.prop_cmp:AddExp(math.floor(dmg / obj.max_hp * exp))
            local exp = math.floor(dmg / obj.max_hp * exp)
            obj_.reward_cmp:AddReward({{1,1,exp}})
        end
    end

    local wins = obj.cfg.wins
    for guid,dmg in pairs(obj.dmg_list)do
        local obj_ = self.guid_to_player[guid]
        if obj_ then
            -- obj_.prop_cmp:AddWins(math.floor(dmg / obj.max_hp * wins))
            local gold = math.floor(dmg / obj.max_hp * wins)
            obj_.reward_cmp:AddReward({{1,3,gold}})
        end
    end
end

function c:StartRun()
    self.waitTime = TIME_1
    self.state = 1
    self:StartUpdate()
end

function c:StartUpdate()
    if self.__update_co then
        return
    end
    self.__update_co = self:AddUpdate(self.Update,1)
end

function c:StopUpdate()
    if self.__update_co then
        self.__update_co:Disconnect()
        self.__update_co = nil
    end
end

function c:Update()
    self.waitTime = self.waitTime - 1
    hotpot.event_manager:FireAll('partyStageUpdate',self.state,self.waitTime)
    if self.state == 1 then
        if self.cd_Text then
            if self.waitTime > 0 then
                self.cd_Text.Text = self.waitTime
            else
                self.cd_Text.Text = ''
            end
        end
    else
        if self.cd_Text then
            self.cd_Text.Text = ''
        end
    end
    if self.waitTime <= 0 then
        self.state = self.state + 1
        if self.state == 2 then
            self:DestroyDoor(1)
            self.waitTime = TIME_2
        end
        if self.state == 3 then
            self:GameOver(false)
        end
    end
end

function c:DestroyDoor(id)
    local Art = self.main_inst:FindFirstChild('Art')
    if Art then
        ---@type Model
        local fol = Art:FindFirstChild('door'..id)
        if fol then
            -- fol:Destroy()
            fol:PivotTo(fol:GetPivot() + Vector3.new(0,100,0))
        end
        self.spawn_idx = id
    end
end

function c:ResetDoor()
    local Art = self.main_inst:FindFirstChild('Art')
    if Art then
        for i = 1,6 do
            local model = Art:FindFirstChild('door'..i)
            if model then
                model:PivotTo(model:GetPivot() - Vector3.new(0,100,0))
            end
        end
    end
end

function c:CheckAreaPass()
    if self.game_over then
        return
    end
    local now = self.pass_area

    local nextArea = now + 1

    local tab = self.area_list[nextArea]

    if not tab then
        return
    end

    local pass = true
    for k,part in pairs(tab)do
        local tab = self.point_list[part]
        if tab then
            if tab.is_alive then
                pass = false
                break
            end
        end
    end
    if pass then
        self.pass_area = nextArea
        self:DestroyDoor(nextArea + 1)

        if nextArea + 1 == 6 then--出现boss
            hotpot.event_manager:FireAll('partyStageBossAppear')
        end

        if nextArea + 1 == 7 then
            self:GameOver(true)
        end
    end
end

function c:PlayerDie(player)
    self.die_player[player] = true
end

function c:GameOver(isWin)
    if self.game_over then
        return
    end
    self.reset = false
    self.game_over = true
    self:StopUpdate()
    self:AddProcess(function()
        for guid,v in pairs(self.guid_to_monster)do
            self:DestroyMonster(guid)
        end
    end)
    if isWin then
        local difficulty = self.difficulty
        local cfg_id = self.cfg_id
        local cfg = PartyCfg[cfg_id]
        local total = 0
        local per_cfg = cfg['lv'..difficulty..'Per']
        local re_cfg = cfg['lv'..difficulty..'Reward']
        for k,v in pairs(per_cfg)do
            total = total + v
        end
        for player,_ in pairs(self.player_list)do
            pcall(function()
                player.character:SetWalkSpeed(0)
            end)
            if not self.die_player[player] then
                local reward = {}

                for i = 1,difficulty do
                    local r = math.random(1,total)
                    for k,v in pairs(per_cfg)do
                        r = r - v
                        if r <= 0 then
                            table.insert(reward,re_cfg[k])
                            break
                        end
                    end
                end
                table.insert(reward,re_cfg[4])

                player.reward_cmp:AddReward(reward)
                local info = {
                    reward = reward,
                    kill = player.partyKillNum,
                    dmg = player.partyDmg,
                    time = 15*60 - self.waitTime,
                }
                hotpot.event_manager:Fire(player,'party_stage_win',info)
            end
        end
    else
        for player,_ in pairs(self.player_list)do
            local info = {
                reward = {},
                kill = player.partyKillNum,
                dmg = player.partyDmg,
            }
            hotpot.event_manager:Fire(player,'party_stage_lose',info)
        end
    end

    self.overTime = 15
end

function c:StartOverUpdate()
    if self.over_co then
        return
    end
    self.over_co = self:AddUpdate(self.OverUpdate,1)
end

function c:StopOverUpdate()
    if self.over_co then
        self.over_co:Disconnect()
        self.over_co = nil
    end
end

function c:OverUpdate()
    self.overTime = self.overTime - 1

    local uidList = {}
    for player,_ in pairs(self.resetList)do
        table.insert(uidList,player.user_id)
    end

    hotpot.event_manager:FireAll('partyStageOverUpdate',self.overTime,uidList)
    if self.overTime <= 0 then
        self:StopOverUpdate()
        local tList = {}
        for player,_ in pairs(self.resetList)do
            table.insert(tList,player)
        end
        spawn(function()
            self:ResetTeleport(tList)
        end)
        -- local bList = {}
        local id = place_manager:GetStartPlaceId()
        if id == 73444429398530 then
            id = 140209136165491
        end
        for player,_ in pairs(self.player_list)do
            if not self.resetList[player] then
                spawn(function()
                    place_manager:TeleportPlayerToPublicPlace(
                        player,
                        id,
                        loadingGui
                    )
                end)
            end
        end
    end
end

--重置
---@param player Server_Player
function c:Reset(player)
    --先判断玩家数量
    local num = 0
    for p,_ in pairs(self.player_list)do
        if p and p.main_inst and p.main_inst.Parent then
            num = num + 1
        end
    end
    if num == 1 then
        self:ResetTeleport({player})
        return
    end

    self.resetList[player] = true

    local vNum = 0
    for uid,_ in pairs(self.resetList)do
        vNum = vNum + 1
    end

    if vNum == num then
        self:StopOverUpdate()
        local tList = {}
        for player,_ in pairs(self.resetList)do
            table.insert(tList,player)
        end
        self:ResetTeleport(tList)
    end

    self:StartOverUpdate()
end

function c:ResetTeleport(player_list)
    local place_id = place_manager:GetIdByName('partysence')
    local privatePlaceCode = place_manager:CreatePlaceCode(place_id)

    local playerCount = #player_list
    -- print('teleportAgain')
    -- print(self.cfg_id,self.difficulty)
    local cfg_id = self.cfg_id
    local difficulty = self.difficulty
    local r,e = place_manager:TeleportPlayerToPrivatePlace(
        player_list,
        place_id,
        privatePlaceCode,
        {
            cfgid = cfg_id,
            playerCount = playerCount,
            difficulty = difficulty,
        },
        loadingGui
    )
    if not r then
        warn(e)
    end
end

return c