local hotpot = _G.ServerHotpot

local weather_cfg = hotpot.config.Weather
local monster_cfg = hotpot.config.monster
local newCfg = {}
for k,v in ipairs(monster_cfg)do
    newCfg[v.stage] = newCfg[v.stage] or {}
    table.insert(newCfg[v.stage],v)
end

---@class Server_WeatherMonsterObj:BaseObject
local c = hotpot.class.new(script,hotpot.files.BaseObject())
function c.new(stage,part,weather_id)
    return c(stage,part,weather_id)
end
function c:ctor(stage,part,weather_id)
    c.super.ctor(self)
    
    self.weather_id = weather_id
    self.guid = hotpot.pro_cfg:GetGuid()
    self.is_boss = weather_cfg[self.weather_id].is_big

    ---@type Server_StageObj
    self.stage = stage
    ---@type Part
    self.part = part
    ---@type Humanoid
    -- self.humanoid = self.main_inst:WaitForChild('Humanoid')

    self.id = tonumber(part.Name)
    self.cfg = monster_cfg[self.id]

    self.dmg_list = {}
    self.recover_time = 5
    self.move_cold = math.random(40,60)/10
    self.cold_cd = 0

    self:Init()
    -- if not self.cfg.is_boss then
    -- end
    if not self.is_boss then
        self:AddUpdate(self.Move)
    end
end

function c:Updata()
    self.recover_time = self.recover_time - 1
    if self.recover_time <= 0 then
        self.recover_time = 5
        self.hp = self.max_hp
        self.dmg_list = {}
        self.stage:SendAllPlayer('monster_recover',{
            guid = self.guid,
            stage_id = self.stage.id,
        })
        self:StopUpdate()
        self.__dmg = false
    end
end

function c:GetRandomPos()
    local pos = self.part.Position
    local random_x,random_y
    if self.cfg.is_boss then
        random_x = math.random(-1000,1000)/100
        random_y = math.random(-1000,1000)/100
    else
        random_x = math.random(-500,500)/100
        random_y = math.random(-500,500)/100
    end
    return pos + Vector3.new(random_x,3,random_y)
end

function c:Move(step)
    if self.__dmg then
        return
    end
    self.move_cold = self.move_cold - step
    if self.move_cold <= 0 then
        self.move_cold = math.random(20,60)/10
        local pos = self:GetRandomPos()
        self.stage:SendAllPlayer('monster_move',{
            guid = self.guid,
            pos = pos,
            stage_id = self.stage.id,
        })
    end
end

--开始更新
function c:StartUpdate()
    if self.__update_co then
        return
    end
    self.__update_co = self:AddUpdate(self.Updata,1)
end

--停止更新
function c:StopUpdate()
    if self.__update_co then
        self.__update_co:Disconnect()
        self.__update_co = nil
    end
end

function c:Init()
    local stage = self.stage.id
    self.cfg = newCfg[stage][2]

    local weather_id = self.weather_id
    local cfg = weather_cfg[weather_id]
    if cfg.is_big then
        self.is_big = true
        self.max_hp = cfg.hp
        self.hp = self.max_hp
    else
        self.max_hp = self.cfg.hp * 1.5
        self.hp = self.max_hp
    end
end

--开始攻击更新
function c:StartAttackUpdate()
    if self.atk_co then
        return
    end
    self.atk_co = self:AddUpdate(self.Attack)
end

--停止攻击更新
function c:StopAttackUpdate()
    if self.atk_co then
        self.atk_co:Disconnect()
        self.atk_co = nil
    end
end

function c:BeDamage(source,dmg)
    if self.is_die then
        return
    end
    self.__dmg = true
    local old_hp = self.hp
    self.hp = math.max(0,self.hp - dmg)
    dmg = math.min(old_hp,dmg)
    self.recover_time = 5
    self:StartUpdate()
    if self.cfg.attack then
        self:StartAttackUpdate()
    end
    self.dmg_list[source] = self.dmg_list[source] or 0
    self.dmg_list[source] = self.dmg_list[source] + dmg
    if self.hp <= 0 then
        self:StopUpdate()
        self:StopAttackUpdate()
        self:Die(source)
        return true
    end
    return false
end

function c:Attack(step)
    self.cold_cd = self.cold_cd - step
    if self.cold_cd <= 0 then
        self.cold_cd = self.cfg.is_boss and 4 or 1.5
    else
        return
    end
    local player_guid
    local DIS = 12
    if self.cfg.is_boss then
        DIS = 40
    end

    local players = {}

    for guid,_ in pairs(self.dmg_list)do
        if self.stage then
            ---@type Server_Player
            local player = self.stage.guid_to_player[guid]
            if player and player.character and not player.character.is_die then
                local pos = player.character:GetPosition()
                local dis = (self.part.Position - pos).Magnitude
                if dis <= DIS then
                    -- player_guid = guid
                    -- break
                    players[guid] = true
                end
            end
        end
    end
    -- if not player_guid then
    --     return
    -- end

    if not next(players) then
        return
    end

    self.recover_time = 5
    self.stage:MonsterAttackPlayer(self.guid,players,self.cfg.attack)
end

function c:Die(source)
    self.is_die = true
    self.source = source
    self.stage:MonsterDie(self,source)
    self:StopUpdate()

    local r,e = pcall(function()
        self.stage:GiveReward(self,source)   
        
        -- if self.weather_id > 3 then
        --     for guid,dmg in pairs(self.dmg_list)do
        --         local player = self.stage.guid_to_player[guid]
        --         if player and player.character and player.character.main_inst then
        --             player.reward_cmp:AddReward({{11,1,2}})
        --             local num = math.random()
        --             if num <= 0.05 then
        --                 player.reward_cmp:AddReward({{11,2,1}})
        --             else
        --                 if num <= 0.01 then
        --                     player.reward_cmp:AddReward({{11,3,1}})
        --                 end
        --             end
        --         end
        --     end
        -- end
    end)
    if not r then
        warn(e)
    end
    self.stage:DestroyMonster(self.guid)
end

return c