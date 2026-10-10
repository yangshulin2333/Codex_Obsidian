local hotpot = _G.ClientHotpot
---@type PlaceManager 
local place_manager = hotpot.load.PlaceManager()
---@type UIManager
local uimanager = hotpot.load.UIManager()

---@class Client_GuideComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('guide')
    self.data2 = self.parent.save_data:GetData('guide2')
    
    self:Init()
end

function c:ChangeNum(num)
    self.data.num = num
    self:Init()
end

function c:Init()
    if place_manager:GetIdByName('guildsence') == game.PlaceId then
        return
    end
    if place_manager:GetIdByName('partysence') == game.PlaceId then
        return
    end
    if place_manager:GetIdByName('pvpsence') == game.PlaceId then
        return
    end

    if place_manager:GetIdByName('challengesence') == game.PlaceId then
        return
    end

    self:AddProcess(function()
        repeat self:Wait() until (self.parent.character and self.parent.character.beam)

        self.beam = self.parent.character.beam

        local num = self.data.num
        local fun = self['Guide'..num]
        if fun then
            fun(self)
        end

        self:Wait(3)
        self:GuideSkill()
    end)

    uimanager.ui_list.hud_gui:SetSKillBtnVisible(self.data2.stage[2])
    uimanager.ui_list.hud_gui:SetGuildBtnVisible(self.data2.stage[3])
    uimanager.ui_list.hud_gui:SetPVPBtnVisible(self.data2.stage[4])
    uimanager.ui_list.hud_gui:SetStatsBtnVisible(self.data2.stage[4])
end

function c:ConnectBeam(att)
    if att and self.beam then
        self.beam.Attachment0 = att
        self.beam.Attachment1 = self.parent.character.root_part:FindFirstChildOfClass('Attachment')
    end
end

function c:DisconnectBeam()
    if self.beam then
        self.beam.Attachment1 = nil
    end
end

function c:Guide1()
    local stage = self.parent.now_stage
    local Gacha = stage.main_inst:FindFirstChild('Gacha')
    if not Gacha then
        return
    end
    local collider = Gacha:FindFirstChild('collider')
    if not collider then
        return
    end
    local part = collider:FindFirstChild('1')
    if not part then
        return
    end
    local att = part:FindFirstChildOfClass('Attachment')
    if not att then
        return
    end
    self:ConnectBeam(att)
end

function c:Guide2()
    self:DisconnectBeam()
end

function c:GuideInStage(id)
    self.data2.stage[id] = true

    spawn(function()
        wait(2)
        local list = {}
        if id == 2 then
            -- list['skill'] = true
            uimanager.ui_list.tips_gui:TipsMessage('Skill has been unlocked','success')
        elseif id == 3 then
            list['guild'] = true
        elseif id == 4 then
            list['pvp'] = true
            list['stats'] = true
        end
        uimanager.ui_list.new_guide_gui:Play(list)
    end)
    uimanager.ui_list.hud_gui:SetSKillBtnVisible(self.data2.stage[2])
    uimanager.ui_list.hud_gui:SetGuildBtnVisible(self.data2.stage[3])
    uimanager.ui_list.hud_gui:SetPVPBtnVisible(self.data2.stage[4])
    uimanager.ui_list.hud_gui:SetStatsBtnVisible(self.data2.stage[4])
end

function c:Reborn()
    self.data2.stage[2] = nil
    self.data2.stage[3] = nil
    self.data2.stage[4] = nil
    uimanager.ui_list.hud_gui:SetSKillBtnVisible(false)
    uimanager.ui_list.hud_gui:SetGuildBtnVisible(false)
    uimanager.ui_list.hud_gui:SetPVPBtnVisible(false)
    uimanager.ui_list.hud_gui:SetStatsBtnVisible(false)
end

function c:GuideSkill()
    if self.data2.guild_skill then
        return
    end

    if self.parent.prop_cmp:GetLv() < 8 then
        return
    end

    if self.parent.stage_cmp.now_stage.id ~= 'base' then
        return
    end
    local fol = self.parent.now_stage.main_inst:FindFirstChild('Function')
    if not fol then
        return
    end
    local skill = fol:FindFirstChild('skill')
    if not skill then
        return
    end
    local att = skill:FindFirstChildOfClass('Attachment')
    if not att then
        return
    end
    self:ConnectBeam(att)
end

function c:GuideSkillEnd()
    self:DisconnectBeam()
end

c:RegistEvent('guild_skill_end',c.GuideSkillEnd)
c:RegistEvent('GuideChangeNum',c.ChangeNum)
c:RegistEvent('GuideInStage',c.GuideInStage)

return c
