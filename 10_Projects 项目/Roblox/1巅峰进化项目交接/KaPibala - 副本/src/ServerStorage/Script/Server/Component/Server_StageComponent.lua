local hotpot = _G.ServerHotpot
---@type GameServer
local server = _G.server

local upgrade_cfg = hotpot.config.upgrade
local stage_cfg = hotpot.config.stage
local FREEPOTIONCD = 7200
local STARTFREEPOTION = 1763942400

---@class Server_StageComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.upgrade_data = self.parent.save_data:GetData('upgrade')
    self.data = self.parent.save_data:GetData('stage')
    self.free_potion_data = self.parent.save_data:GetData('free_potion')

    self:Sync()
end

function c:LoadStage(id)
    ---@type GameServer
    local server = _G.server
    ---@type Server_StageManager
    local stage_manager = server.stage_manager

    if not stage_manager then
        return
    end

    ---@type Server_StageObj
    local obj = stage_manager.stage_list[id]

    ---@type Server_StageObj
    local old = self.now_stage
    if old then
        old:PlayerOut(self.parent)
    end

    if obj then
        obj:PlayerIn(self.parent)

        self.parent.guide_cmp:InStage(id)

        self.now_stage = obj
        local info = stage_manager:GetStageData(id)
        info.player_guid = self.parent.guid
        return info
    end
end

function c:Sync()
    self.parent.sync_cmp:AddHandle('player_attack_monster',self,self.PlayerAttackMonster)
    self.parent.sync_cmp:AddHandle('player_attack_pumpkin',self,self.PlayerAttackPumpkin)
    self.parent.sync_cmp:AddHandle('player_attack_weather',self,self.PlayerAttackWeather)
    self.parent.sync_cmp:AddHandle('player_skill_monster',self,self.PlayerSkillMonster)
end

--玩家攻击怪物
function c:PlayerAttackMonster(info)
    local stage_id = info.stage_id
    if stage_id ~= self.now_stage.id then
        return
    end
    self.now_stage:PlayerAttackMonster(info)

    self.parent.stats_cmp:AddTotalDmg(self.parent.prop_cmp:GetAttack())

    self.parent.task_cmp:AddPoint(4,1)
end

--玩家攻击南瓜
function c:PlayerAttackPumpkin(info)
    ---@type GameServer
    local server = _G.server
    ---@type Server_WSJManager
    local wsj_manager = server.wsj_manager

    local collider = wsj_manager.collider_monster
    if not collider then
        return
    end
    if collider ~= info.collider then
        return
    end
    ---@type Server_PumpkinMonsterObj
    local monster = wsj_manager.monster_obj
    if not monster then
        return
    end
    if monster.is_die then
        return
    end
    monster:BeDamage(self.parent,1)
end

--玩家攻击天气怪物
function c:PlayerAttackWeather(info)
    ---@type Server_WeatherBossObj
    local obj = self.now_stage.weather_boss
    if not obj then
        return
    end
    if obj.is_die then
        return
    end

    if obj.collider ~= info.collider then
        return
    end

    obj:BeDamage(self.parent,1)
end

--玩家技能攻击怪物
function c:PlayerSkillMonster(info)
    local stage_id = info.stage_id
    if stage_id ~= self.now_stage.id then
        return
    end

    local part = info.root
    -- if not part then
    --     return
    -- end

    if info.is_pumpkin then
        ---@type GameServer
        local server = _G.server
        ---@type Server_WSJManager
        local wsj_manager = server.wsj_manager
    
        local collider = wsj_manager.collider_monster
        if not collider then
            return
        end
        if collider == part then
            ---@type Server_PumpkinMonsterObj
            local monster = wsj_manager.monster_obj
            if not monster then
                return
            end
            if monster.is_die then
                return
            end
            monster:BeDamage(self.parent,1)
            return
        end
    elseif info.is_weather then
        ---@type Server_WeatherBossObj
        local obj = self.now_stage.weather_boss
        if not obj then
            return
        end
        if obj.is_die then
            return
        end
        if obj.collider ~= part then
            return
        end
        obj:BeDamage(self.parent,1)
        return
    end


    self.now_stage:PlayerSkillMonster(info)
end

--升级
function c:Upgrade(id)
    if self.upgrade_data.__real.list[id] then
        return false
    end
    local cfg = upgrade_cfg[id]
    if not cfg then
        return false
    end
    if not self.parent.prop_cmp:CostGems(cfg.price) then
        return
    end
    self.parent.save_data:Execut(function()
        self.upgrade_data.list[id] = true
    end)

    return true
end

--解锁关卡
function c:UnlockStage(id)
    local lv = self.parent.prop_cmp:GetLv()
    local need = stage_cfg[id].need
    if lv < need then
        return false
    end
    self.parent.save_data:Execut(function()
        self.data.list[id] = true
    end)

    return true
end

function c:LockStage(id)
    self.parent.save_data:Execut(function()
        self.data.list[id] = nil
    end)

    self:Fire('lockStage',id)
end

--获取已解锁的最大关卡
function c:GetMaxStage()
    return #self.data.__real.list
end

--领取免费药水
function c:GetFreePotion()
    local mark = self.free_potion_data.__real.mark
    local now = os.time()
    local sub = now - mark
    if sub < FREEPOTIONCD then
        return
    end
    self.parent.save_data:Execut(function()
        self.free_potion_data.mark = now
    end)

    self.parent.reward_cmp:AddReward({{1,8,1}})

    return true,now
end

c:RegistFunction('in_stage',c.LoadStage)
c:RegistFunction('catch_monster',c.Catch)
c:RegistFunction('sell_monster',c.Sell)
c:RegistFunction('upgrade',c.Upgrade)
c:RegistFunction('unlockStage',c.UnlockStage)
c:RegistFunction('getFreePotion',c.GetFreePotion)

return c