local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()

---@class Client_StatsComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end

function c:ctor(parent)
    c.super.ctor(self,parent)

    self.ui = ui_manager.ui_list.stats_gui
    ui_manager.ui_list.hud_gui:BindStatsBtnClickHandle(self,self.Init)
end

function c:Init()
    local re = self:Invoke('get_stats')
    if not re then
        return
    end
    self.data = re
    self.ui:SetRightHp(re.hp)
    self.ui:SetRightDmg(re.atk)
    self.ui:SetRightSpeed(re.speed)
    self.ui:SetRightPlayTime(re.playTime)
    self.ui:SetRightMonsterKill(re.kill)
    self.ui:SetRightTotalDmg(re.tDmg)
    self.ui:SetRightOpenEgg(re.egg)

    self.show_self = true
    if not self.update_co then
        self.update_co = self:AddUpdate(self.Update,1)
    end
end

function c:Update()
    if self.show_self then
        self.data.playTime = self.data.playTime + 1
        self.ui:SetRightPlayTime(self.data.playTime)
    end
end

function c:SyncSpeed(speed)
    self.ui:SetRightSpeed(speed)
end

function c:SyncDmg(dmg,speed,hp)
    self.ui:SetRightDmg(dmg)
    self.ui:SetRightSpeed(speed)
    self.ui:SetRightHp(hp)
end

function c:SyncKill(kill)
    self.ui:SetRightMonsterKill(kill)
end

function c:SyncTotalDmg(tDmg)
    self.ui:SetRightTotalDmg(tDmg)
end

function c:SyncEgg(egg)
    self.ui:SetRightOpenEgg(egg)
end

function c:SyncChaName(name)
    self.ui:SetRightCharName(name)
end

c:RegistEvent('stats_speed',c.SyncSpeed)
c:RegistEvent('stats_dmg',c.SyncDmg)
c:RegistEvent('stats_kill',c.SyncKill)
c:RegistEvent('stats_total_dmg',c.SyncTotalDmg)
c:RegistEvent('stats_egg',c.SyncEgg)
c:RegistEvent('stats_chaName',c.SyncChaName)

return c
