local hotpot = _G.ServerHotpot
---@type Server_PumpkinMonsterObj
local monster_obj = hotpot.load.Server_PumpkinMonsterObj()
local Debris = game:GetService('Debris')

local monster_model = hotpot:GetPath_Loop('monster.PumpkinBoss',hotpot.Resource)
local monster_model2 = hotpot:GetPath_Loop('weather.w6',hotpot.Resource)
local monster_model3 = hotpot:GetPath_Loop('weather.107',hotpot.Resource)
local eff = hotpot:GetPath_Loop('pfb.PumpkinEff',hotpot.Resource)
local INTERVAL = 4*3600
local BOSSCD = 60*15

---@class Server_WSJManager:BaseObject
local c = hotpot.class.new(script,hotpot.files.BaseObject())
function c.new()
    return c()
end
function c:ctor()
    c.super.ctor(self)

    self.bossExist = false--boss是否存在
    self.bossCd = BOSSCD

    self:AddUpdate(self.Update,1)

    self.bossNum = 0

    -- self:AddProcess(function()
    --     self:Wait(15)
    --     self:CreateBoss()
    -- end)
end

local function CheckTimeOrNextInterval(timestamp, intervalMinutes)
    local now = os.time()
    local interval = now % INTERVAL
    interval = INTERVAL - interval
    if interval - 1 == 0 then
        return true
    else
        return interval
    end
end

function c:Update()
    local result = CheckTimeOrNextInterval(os.time())
    if result == true then
        if self.bossExist == false and self.bossNum == 0 then
            self:CreateBoss()
            self:StartBossCd()
        end
    else
        if self.bossExist then
            return
        end
        if self.bossNum > 0 then
            return
        end
        hotpot.event_manager:FireAll('SyncPumpkinBuffCd',result)
    end
end

function c:CreateBoss()
    self.bossExist = true
    self.bossNum = self.bossNum + 1
    local model 
    if self.bossNum == 1 then
        model = hotpot:CloneInst_Loop(monster_model)
    elseif self.bossNum == 2 then
        model = hotpot:CloneInst_Loop(monster_model2)
    elseif self.bossNum == 3 then
        model = hotpot:CloneInst_Loop(monster_model3)
    end
    local eff_model = hotpot:CloneInst_Loop(eff)
    eff_model.Parent = workspace.Pumpkin
    eff_model:SetPrimaryPartCFrame(workspace.Pumpkin.root.CFrame)

    workspace.Pumpkin:SetAttribute('stage',1)

    Debris:AddItem(eff_model,10)
    
    hotpot.event_manager:FireAll('PumpkinBossCreate',self.bossNum)

    delay(2,function()
        self.monster_obj = monster_obj.new(model,self,self.bossNum)
        self.guid_monster = self.monster_obj.guid
        self.collider_monster = self.monster_obj.collider
    end)

end

function c:StartBossCd()
    self.bossCd = BOSSCD
    if self.bossNum == 3 then
        self.bossCd = self.bossCd 
    end
    if self.__boss_co then
        return
    end
    self.__boss_co = self:AddUpdate(self.BossCd,1)
end

function c:StopBossCd()
    if self.__boss_co then
        self.__boss_co:Disconnect()
        self.__boss_co = nil
    end
end

function c:BossCd()
    self.bossCd = self.bossCd - 1

    hotpot.event_manager:FireAll('SyncPumpkinBuffCd',self.bossCd,true,self.bossNum)

    if self.bossCd <= 0 then
        self:StopBossCd()
        self:BossDie()
    end
end

function c:StartBoss2CD()
    self.boss2_cd = 20
    if self.__boss2_co then
        return
    end
    self.__boss2_co = self:AddUpdate(self.Boss2CD,1)
end

function c:StopBoss2CD()
    if self.__boss2_co then
        self.__boss2_co:Disconnect()
        self.__boss2_co = nil
    end
end

function c:Boss2CD()
    self.boss2_cd = self.boss2_cd - 1
    hotpot.event_manager:FireAll('SyncPumpkinBuffCd',self.boss2_cd)
    if self.boss2_cd <= 0 then
        self:StopBoss2CD()
        self:CreateBoss()
        self:StartBossCd()
    end
end

function c:StartBoss3CD()
    self.boss3_cd = 20
    if self.__boss3_co then
        return
    end
    self.__boss3_co = self:AddUpdate(self.Boss3CD,1)
end

function c:StopBoss3CD()
    if self.__boss3_co then
        self.__boss3_co:Disconnect()
        self.__boss3_co = nil
    end
end

function c:Boss3CD()
    self.boss3_cd = self.boss3_cd - 1
    hotpot.event_manager:FireAll('SyncPumpkinBuffCd',self.boss3_cd)
    if self.boss3_cd <= 0 then
        self:StopBoss3CD()
        self:CreateBoss()
        self:StartBossCd()
    end
end

function c:BossDie()
    hotpot.event_manager:FireAll('PumpkinBossDie')
    self:StopBossCd()
    local boss = self.monster_obj
    self.bossExist = false
    self.guid_monster = nil
    self.collider_monster = nil
    self.monster_obj = nil
    boss:dtor()
    if self.bossNum == 1 then
        self.boss2_cd = 20
        self:StartBoss2CD()
    elseif self.bossNum == 2 then
        self.boss3_cd = 20
        self:StartBoss2CD()
    elseif self.bossNum == 3 then
        self.bossNum = 0
    end

    workspace.Pumpkin:SetAttribute('stage',nil)
end

return c