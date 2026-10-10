local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()
---@type ContextActionService
local ContextActionService = game:GetService('ContextActionService')

local skillCfg = hotpot.config.skill
local addIcon = 'rbxassetid://91691923914388'


---@class Client_SkillComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.skill_list = {}
    self.data = self.parent.save_data:GetData('skill')
    self.ui = ui_manager.ui_list.skill_gui
    self.ui:BindLeftItemClickHandle(self,self.ClickItem)
    self.ui:BindUnlockBtnClickHandle(self,self.ClickUnlock) 
    self.ui:BindEquipBtnClickHandle(self,self.ClickEquip)
    self.ui:BindUnequipBtnClickHandle(self,self.ClickUnEquip)
    self.ui:BindUpgradeBtnClickHandle(self,self.ClickUpgrade)

    ui_manager.ui_list.hud_gui:BindSkillItemClickHandle(self,self.ClickHudSkill)

    self:InitUi()
    self:AddRenderUpdate('render',self.SkillCdUpdate,0.1)
    self:BindKey()
    self:AddUpdate(self.UpdateAutoSkill,1)
end

function c:BindKey()
    ContextActionService:BindAction('skillQ',function(actionName,inputState,inputObject)
        if inputState == Enum.UserInputState.Begin then
            self:UseSkill(1)
        end
    end,false,Enum.KeyCode.Q)
    ContextActionService:BindAction('skillE',function(actionName,inputState,inputObject)
        if inputState == Enum.UserInputState.Begin then
            self:UseSkill(2)
        end
    end,false,Enum.KeyCode.E)
    ContextActionService:BindAction('skillR',function(actionName,inputState,inputObject)
        if inputState == Enum.UserInputState.Begin then
            self:UseSkill(3)
        end
    end,false,Enum.KeyCode.R)

    ContextActionService:BindAction('skillQ1',function(actionName,inputState,inputObject)
        if inputState == Enum.UserInputState.Begin then
            self:UseSkill(1)
        end
    end,false,Enum.KeyCode.ButtonX)
    ContextActionService:BindAction('skillE1',function(actionName,inputState,inputObject)
        if inputState == Enum.UserInputState.Begin then
            self:UseSkill(2)
        end
    end,false,Enum.KeyCode.ButtonY)
    ContextActionService:BindAction('skillR1',function(actionName,inputState,inputObject)
        if inputState == Enum.UserInputState.Begin then
            self:UseSkill(3)
        end
    end,false,Enum.KeyCode.ButtonB)
end

function c:InitUi()
    for k,v in ipairs(skillCfg)do
        self.ui:AddItemInScoll(v.id,v.icon,v.name)
        self.ui:SetItemEquipVisible(v.id,self.data.list[v.id].equip)
    end

    self:ClickItem(1)

    --hud
    for k,v in ipairs(self.data.equiped)do
        if v.unlock then
            ui_manager.ui_list.hud_gui:SetSkillItemLockVisible(k,false)
            if v.skill_id then
                ui_manager.ui_list.hud_gui:SetSkillItemIcon(k,skillCfg[v.skill_id].icon)
            else
                ui_manager.ui_list.hud_gui:SetSkillItemIcon(k,addIcon)
            end
        else
            ui_manager.ui_list.hud_gui:SetSkillItemLockVisible(k,true)
            ui_manager.ui_list.hud_gui:SetSkillItemIcon(k,'')
        end
    end

    self:CheckRed()
end

function c:LoadSkill()
    for k,v in ipairs(self.data.equiped)do
        if v.unlock then
            if v.skill_id then
                self:AddSkill(v.skill_id,k)
            end
        end
    end
end

function c:AddSkillChip(id,num)
    self.data.list[id].chip = self.data.list[id].chip + num

    if self.click_id == id then
        self:ClickItem(id,true)
    end

    self:CheckRed()
end

function c:ClickItem(id)
    if self.click_id then
        self.ui:SetItemSelectVisible(self.click_id,false)
    end
    self.click_id = id
    self.ui:SetItemSelectVisible(id,true)
    local cfg = skillCfg[id]
    self.ui:SetRightSkillIcon(cfg.icon)
    self.ui:SetUnlockDesc(cfg.need_lv)
    local skill_lv = self.data.list[cfg.id].lv
    if skill_lv == 0 then
        self.ui:SetSkillDesc(string.format(cfg.desc,cfg['lv'..(skill_lv + 1)..'_value'] * 100))
    else
        self.ui:SetSkillDesc(string.format(cfg.desc,cfg['lv'..skill_lv..'_value'] * 100))
    end
    self.ui:SetSkillLv(skill_lv)
    self.ui:SetCostIcon(cfg.shardsIcon)
    local need_str = 'lv'..(skill_lv + 1)..'_need'
    local need = cfg[need_str] or 'MAX'
    self.ui:SetCostNum(self.data.list[cfg.id].chip,need)

    if skill_lv == 0 then
        self.ui:SetUnlockBtnVisible(true)
        self.ui:SetUnequipBtnVisible(false)
        self.ui:SetEquipBtnVisible(false)
        self.ui:SetUpgradeBtnVisible(false)
    else
        self.ui:SetUnlockBtnVisible(false)
        self.ui:SetUnequipBtnVisible(self.data.list[cfg.id].equip)
        self.ui:SetEquipBtnVisible(not self.data.list[cfg.id].equip)
        self.ui:SetUpgradeBtnVisible(true)
    end
end

function c:ClickUnlock()
    local id = self.click_id
    if not id then
        return
    end
    local cfg = skillCfg[id]
    if self.data.list[cfg.id].lv > 0 then
        return
    end
    if self.data.list[cfg.id].chip < cfg.lv1_need then
        ui_manager.ui_list.tips_gui:TipsMessage('Not enough Skill Shards','fail')
        return
    end
    local needLv = cfg.need_lv
    if self.parent.prop_cmp:GetLv() < needLv then
        ui_manager.ui_list.tips_gui:TipsMessage(string.format('Need lv %d to unlock',needLv),'fail')
        return
    end
    local re = self:Invoke('unlockSkill',id)
    if re then
        self.data.list[cfg.id].chip = self.data.list[cfg.id].chip - cfg.lv1_need
        self.data.list[cfg.id].lv = 1
        self:ClickItem(id)

        self:CheckRed()
    end
end

function c:ClickEquip()
    local id = self.click_id
    if not id then
        return
    end
    local cfg = skillCfg[id]
    if self.data.list[cfg.id].lv == 0 then
        return
    end
    if self.data.list[cfg.id].equip then
        return
    end
    local solt = nil
    for k,v in ipairs(self.data.equiped)do
        if v.unlock and v.skill_id == nil then
            solt = k
            break
        end
    end
    if not solt then
        ui_manager.ui_list.tips_gui:TipsMessage('No empty slot','fail')
        return
    end
    local re,Slot = self:Invoke('equipSkill',id)
    if re then
        ui_manager.ui_list.tips_gui:TipsMessage('Equip Success','success')
        self.data.equiped[Slot].skill_id = id
        self.data.list[cfg.id].equip = true
        self.ui:SetItemEquipVisible(id,true)
        self:ClickItem(id)
        ui_manager.ui_list.hud_gui:SetSkillItemIcon(solt,skillCfg[id].icon)
        self:AddSkill(id,solt)
    end
end

function c:ClickUnEquip()
    local id = self.click_id
    if not id then
        return
    end
    local cfg = skillCfg[id]
    if not self.data.list[cfg.id].equip then
        return
    end
    local re,slot = self:Invoke('unequipSkill',id)
    if re then
        ui_manager.ui_list.tips_gui:TipsMessage('UnEquip Success','success')
        self.data.equiped[slot].skill_id = nil
        self.data.list[cfg.id].equip = false
        self.ui:SetItemEquipVisible(id,false)
        self:ClickItem(id)
        ui_manager.ui_list.hud_gui:SetSkillItemIcon(slot,addIcon)
        self:RemoveSkill(id,slot)
    end
end

function c:ClickUpgrade()
    local id = self.click_id
    if not id then
        return
    end
    local cfg = skillCfg[id]
    local now_lv = self.data.list[cfg.id].lv
    if now_lv == 0 then
        return
    end
    local need_str = 'lv'..(now_lv + 1)..'_need'
    if not cfg[need_str] then
        ui_manager.ui_list.tips_gui:TipsMessage('Max Level','fail')
        return
    end
    if self.data.list[cfg.id].chip < cfg[need_str] then
        ui_manager.ui_list.tips_gui:TipsMessage('Not enough Skill Shards','fail')
        return
    end
    local re = self:Invoke('upgradeSkill',id)
    if re then
        self.data.list[cfg.id].chip = self.data.list[cfg.id].chip - cfg[need_str]
        self.data.list[cfg.id].lv = now_lv + 1
        self:ClickItem(id)
    end
end

function c:AddSkill(skill_id,solt)
    local str = 'Client_Skill_'..skill_id
    local skill = hotpot.load[str]().new(self.parent.character)
    skill.id = skill_id
    skill.solt = solt
    self.skill_list[solt] = {skill = skill,cd = skillCfg[skill_id].cold,skill_id = skill_id,max_cd = skillCfg[skill_id].cold}
end

function c:RemoveSkill(skill_id,solt)
    skill_id = 1
    self.skill_list[solt].skill:dtor()
    self.skill_list[solt] = nil
end

function c:ClickHudSkill(solt)
    if self.parent.prop_cmp:GetLv() < 8 then
        ui_manager.ui_list.tips_gui:TipsMessage('Need lv 8 to unlock skill','fail')
        return
    end
    local tab = self.data.equiped[solt]
    if not tab.unlock then
        local goodsId = 0
        if solt == 2 then
            goodsId = 88
        elseif solt == 3 then
            goodsId = 89
        end
        local re = self:Invoke('buy_goods',goodsId)
        if re then
            self.parent.shop_cmp:PlayPurchaseSound()
            ui_manager.ui_list.tips_gui:TipsMessage('Purchase successfully','success')
            self.data.equiped[solt].unlock = true
            ui_manager.ui_list.hud_gui:SetSkillItemLockVisible(solt,false)
            ui_manager.ui_list.hud_gui:SetSkillItemIcon(solt,'rbxassetid://91691923914388')
        end
        return
    end
    if not self.skill_list[solt] then
        ui_manager.ui_list.skill_gui:Show()
        return
    end
    self:UseSkill(solt,self.skill_list[solt].skill_id)
end

function c:UseSkill(solt,skill_id)

    if not self.skill_list[solt] then
        return
    end
    skill_id = self.skill_list[solt].skill_id
    if self.skill_list[solt].cd > 0 then
        return
    end

    local re = self:Invoke('useSkill',solt,skill_id)
    if not re then
        return
    end

    self.skill_list[solt].skill:Start()
    self.skill_list[solt].cd = skillCfg[skill_id].cold
end

function c:SkillCdUpdate(dt)
    for slot,v in pairs(self.skill_list)do
        v.cd = math.max(0,v.cd - dt)
        ui_manager.ui_list.hud_gui:SetSkillItemCD(slot,v.cd,v.cd/v.max_cd)
    end
end

function c:CheckRed()
    local red = false
    for k,v in pairs(skillCfg)do
        local id = v.id
        if self.data.list[id].lv == 0 then
            local chip = self.data.list[id].chip
            if chip >= v.lv1_need then
                red = true
                self.ui:SetRedVisible(id,true)
            else
                self.ui:SetRedVisible(id,false)
            end
        else
            self.ui:SetRedVisible(id,false)
        end
    end

    -- ui_manager.ui_list.hud_gui:SetSkillRedVisible(red)
end

function c:AutoSkill()
    for k,v in ipairs(self.data.equiped)do
        if v.unlock then
            if v.skill_id then
                self:UseSkill(k,v.skill_id)
            end
        end
    end 
end

function c:UpdateAutoSkill()
    if self.parent.afk then
        for solt,data in pairs(self.skill_list)do
            self:UseSkill(solt)
        end
    end
end

c:RegistEvent('AddSkillChip',c.AddSkillChip)

return c