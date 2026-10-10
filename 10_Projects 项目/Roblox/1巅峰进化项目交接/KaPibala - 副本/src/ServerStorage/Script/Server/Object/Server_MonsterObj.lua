local hotpot = _G.ServerHotpot

local monster_cfg = hotpot.config.monster
local ChristmasMonster_Cfg = hotpot.config.ChristmasMonster

---@class Server_MonsterObj:BaseObject
local c = hotpot.class.new(script,hotpot.files.BaseObject())
function c.new(stage,part)
    return c(stage,part)
end
function c:ctor(stage,part)
    c.super.ctor(self)

    self.guid = hotpot.pro_cfg:GetGuid()

    ---@type Server_StageObj
    self.stage = stage
    ---@type Part
    self.part = part
    ---@type Humanoid
    -- self.humanoid = self.main_inst:WaitForChild('Humanoid')

    self.id = tonumber(part.Name)
    if stage.id == 'christmas' then
        self.cfg = ChristmasMonster_Cfg[self.id]
        self.is_christmas = true
    else
        self.cfg = monster_cfg[self.id]
    end

    self.dmg_list = {}
    self.recover_time = 5
    self.move_cold = math.random(40,60)/10
    self.cold_cd = 0

    self:Init()
    -- if not self.cfg.is_boss then
    -- end
    self:AddUpdate(self.Move)
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
    self.max_hp = self.cfg.hp
    self.hp = self.max_hp
    self.atk = self.cfg.attack

    -- local humanoid = self.humanoid
    -- if humanoid then
    --     local hight = humanoid.HipHeight + self.root_part.Size.Y/2
    --     local cf = self.part.CFrame
    --     local pos = cf.Position + Vector3.new(0,hight,0) + Vector3.new(0,self.part.Size.Y/2,0)
    --     self.main_inst:PivotTo(
    --         CFrame.new(pos,pos + cf.LookVector)
    --     )
    -- else
    --     local cf,size = self:GetBoundingBox()
    --     self:PivotTo(CFrame.new(self.part.Position + Vector3.new(0,size.Y/2,0)))
    -- end
    -- self.main_inst.Parent = self.stage.monster_fol
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
    if self.is_die then
        return
    end
    self.is_die = true
    self.source = source
    self.stage:MonsterDie(self,source)
    self:StopUpdate()

    local r,e = pcall(function()
        self.stage:GiveReward(self,source)    
    end)
    if not r then
        warn(e)
    end
    self.stage:DestroyMonster(self.guid)
end

return c