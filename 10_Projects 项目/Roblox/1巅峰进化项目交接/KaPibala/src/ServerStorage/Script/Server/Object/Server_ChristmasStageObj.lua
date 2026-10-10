local hotpot = _G.ServerHotpot
---@type Server_MonsterObj
local monster_obj = hotpot.load.Server_MonsterObj()
---@type Server_RankManager
local rankManager = hotpot.load.Server_RankManager()

local REFRESH_TIME = 10
local monster_cfg = hotpot.config.ChristmasMonster

---@class Server_ChristmasStageObj:ModelObject
local c = hotpot.class.new(script,hotpot.files.ModelObject())
function c.new(model,id)
    return c(model,id)
end
function c:ctor(model,id)
    c.super.ctor(self,model)

    self.id = id

    ---@type table<Server_Player,boolean>
    self.player_list = {}
    ---@type table<number,Server_Player>
    self.guid_to_player = {}

    self.guid_to_Wmonetr = {}

    self:Init()
    self:LoadMonster()
end

function c:Init()
    self.monster_fol = self.main_inst:WaitForChild('monster')

    self:AddUpdate(self.UpdateRefresh,1)

    self.monsterPos = self.main_inst:WaitForChild('monsterPos')
    self.points = {}
    local max = 0
    for k,v in ipairs(self.monsterPos:GetChildren())do
        table.insert(self.points,v)
        max = math.max(max,tonumber(v.Name))
    end
    for k,v in ipairs(self.points)do
        if v.Name == tostring(max) then
            table.remove(self.points,k)
        end
    end
    Random.new():Shuffle(self.points)
    self.max_len = #self.points
    self.now_len = 1

end

--加载怪物信息
function c:LoadMonster()
    ---@type table<Part,Server_MonsterObj>
    self.monster_list = {}
    ---@type table<number,Server_MonsterObj>
    self.guid_to_monster = {}
    ---@type table<Part,table>
    self.point_list = {}

    local fol = self.main_inst:WaitForChild('monsterPos')
    for k,v in ipairs(fol:GetChildren())do
        local obj = monster_obj.new(self,v)
        obj.christmas = true
        local guid = obj.guid
        self.guid_to_monster[guid] = obj
        self.monster_list[v] = obj
        self.point_list[v] = {
            obj = obj,
            time_ = 0,
            is_alive = true,
        }
    end
end

--玩家进入
---@param player Server_Player
function c:PlayerIn(player)
    self.player_list[player] = true
    self.guid_to_player[player.guid] = player

    player.now_stage = self
end

--玩家退出
---@param player Server_Player
function c:PlayerOut(player)
    self.player_list[player] = nil
    self.guid_to_player[player.guid] = nil

    player.now_stage = nil
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
    local monster_guid = info.monster_guid
    ---@type Server_MonsterObj
    local monster = self.guid_to_monster[monster_guid]
    if not monster then
        return false
    end
    ---@type Server_Player
    local player = self.guid_to_player[info.player_guid]
    if not player then
        return false
    end
    if player and player.character and player.character.is_die then
        return
    end

    local cPos = player.character:GetBottomPosition()
    local mPos = monster.part.Position
    local dis = (cPos - mPos).Magnitude
    if dis > 20 then
        return
    end

    local atk = math.floor(player.prop_cmp:GetAttack())
    if monster.is_big then
        atk = 1
    end

    local is_die = monster:BeDamage(info.player_guid,atk)
    self:SendAllPlayer('monster_be_dmg',{
        monster_guid = monster_guid,
        dmg = atk,
        player_guid = info.player_guid,
        stage_id = self.id,
    })
end

--玩家技能攻击怪物
function c:PlayerSkillMonster(info)
    local monster_guid = info.monster_guid
    ---@type Server_MonsterObj
    local monster = self.guid_to_monster[monster_guid]
    if not monster then
        return false
    end
    ---@type Server_Player
    local player = self.guid_to_player[info.player_guid]
    if not player then
        return false
    end
    if player and player.character and player.character.is_die then
        return
    end

    local atk = math.floor(player.prop_cmp:GetAttack())

    local skill_per = player.skill_cmp:GetSkillPer(info.slot)
    atk = math.floor(atk * skill_per)

    local is_die = monster:BeDamage(info.player_guid,atk)
    self:SendAllPlayer('monster_be_dmg',{
        monster_guid = monster_guid,
        dmg = atk,
        player_guid = info.player_guid,
        stage_id = self.id,
    })
end

--怪物死亡
function c:MonsterDie(obj,source)
    -- print(source)
    local list = obj.dmg_list
    local is_boss = obj.cfg.is_boss
    self:AddProcess(function()
        ---@type Server_Player
        local player = self.guid_to_player[source]
        if player then
            player.task_cmp:AddPoint(2,1)
            player.task_cmp:AddPoint(3,1)
            player.title_cmp:AddPoint(1,1)
            if is_boss then
                player.title_cmp:AddPoint(6,1)
            end
        end
        if list then
            for guid,_ in pairs(list)do
                ---@type Server_Player
                local player = self.guid_to_player[guid]
                if player then
                    player:KillMonster()
                    local r,e = pcall(function()
                        rankManager:IncrementRankValue('kill',player.user_id,1)
                        rankManager:IncrementRankValue('christmas_kill',player.user_id,1)
                    end)
                    if not r then
                        warn(e)
                    end

                    if is_boss then
                        player.battle_pass_cmp:AddPoint(2,1)
                        player.eternal_cmp:AddTaskPoint(2,1)
                    else
                        player.battle_pass_cmp:AddPoint(3,1)
                        player.battle_pass_cmp:AddPoint(5,1)
                        player.eternal_cmp:AddTaskPoint(3,1)
                        player.eternal_cmp:AddTaskPoint(5,1)
                        player.eternal_cmp:AddTaskPoint(7,1)
                        player.eternal_cmp:AddTaskPoint(8,1)
                        player.eternal_cmp:AddTaskPoint(9,1)
                    end
                end
            end
        end
    end)

    local per = obj.cfg.per
    local gems = obj.cfg.gems
    local monster_guid = obj.guid
    if per then
        --结算钻石
        pcall(function()
            for guid,_ in pairs(list)do
                ---@type Server_Player
                local player = self.guid_to_player[guid]
                if player then
                    local random = math.random(1,100)
                    if random <= per then
                        --获得钻石
                        player.prop_cmp:AddGems(gems)
                        hotpot.event_manager:Fire(player,'dropGems',monster_guid)
                    end
                end
            end
        end)
    end
    self:SendAllPlayer('monster_die',{
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
    local weather_id = obj.weather_id
    local part = obj.part
    if not weather_id then
        local tab = self.point_list[part]
        if not part then
            return
        end
        tab.obj = nil
        tab.time_ = REFRESH_TIME
        tab.is_alive = false
        self.monster_list[obj] = nil
    end
    

    if weather_id then
        pcall(function()
            self.wMonsterNum = self.wMonsterNum - 1
        end)
        self:SendAllPlayer('monster_destroy',{
            monster_guid = guid,
            stage_id = self.id,
            part = part,
        })
    end

    self.guid_to_monster[obj.guid] = nil
    obj:dtor()

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
            self:SendAllPlayer('monster_atk_player',{
                stage_id = self.id,
                monster_guid = monster_guid,
                player_guid = player_guid,
                cha_pos = character:GetPosition(),
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
    -- print(111)
    local weather_id = obj.weather_id
    local exp = monster_cfg[obj.id].exp
    for guid,dmg in pairs(obj.dmg_list)do
        local obj_ = self.guid_to_player[guid]
        if obj_ then
            obj_.prop_cmp:AddExpByTeam(math.floor(dmg / obj.max_hp * exp))
        end
    end

    local wins = obj.cfg.wins
    for guid,dmg in pairs(obj.dmg_list)do
        local obj_ = self.guid_to_player[guid]
        if obj_ then
            obj_.prop_cmp:AddWins(math.floor(dmg / obj.max_hp * wins))
            hotpot.event_manager:Fire(obj_,'drop_gold',obj.guid)
            local coins = obj.cfg.eternalCoins
            local double = obj_.eternal_cmp:GetDouble()
            if double then
                coins = coins * 2
            end
            obj_.eternal_cmp:AddCoins(coins)
            -- print(coins)

            pcall(function()
                if obj.cfg.is_boss then
                    local ran = math.random(1,10000)
                    if ran <= 10 then
                        obj_.reward_cmp:AddReward({{1,6,1}})
                    end
                end
            end)
        end
    end
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
    local obj = monster_obj.new(self,part)
    obj.christmas = true
    local guid = obj.guid
    self.guid_to_monster[guid] = obj
    self.monster_list[part] = obj
    tab.obj = obj

    self:SendAllPlayer('monster_reborn',{
        monster_guid = guid,
        hp = obj.hp,
        max_hp = obj.max_hp,
        stage_id = self.id,
        part = part,
    })
end

return c