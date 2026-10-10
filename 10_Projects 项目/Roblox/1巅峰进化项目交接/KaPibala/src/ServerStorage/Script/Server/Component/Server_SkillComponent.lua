local hotpot = _G.ServerHotpot
---@type PlaceManager
local place_manager = hotpot.load.PlaceManager()

local skillCfg = hotpot.config.skill

---@class Server_SkillComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.skill_list = {}
    self.data = self.parent.save_data:GetData('skill')

    local fol = Instance.new('Folder',self.parent.main_inst)
    fol.Name = 'Skill'
    self.skill_fol = fol

    self:InitData()

    -- self:AddSkillChip(1,200)
    -- self:AddSkillChip(2,200)
    -- self:AddSkillChip(3,200)
end

function c:InitData()
    for skill_id,v in ipairs(skillCfg)do
        if not self.data.__real.list[v.id] then
            self.parent.save_data:Execut(function()
                self.data.list[v.id] = {
                    lv = 0,--等级
                    chip = 0,--碎片
                    equip = false,--是否装备
                }
            end)
        end
    end

    for solt,tab in ipairs(self.data.__real.equiped)do
        if tab.unlock and tab.skill_id then
            self.skill_list[solt] = {
                skill_id = tab.skill_id,
                lv = self.data.__real.list[tab.skill_id].lv,
                cd = skillCfg[tab.skill_id].cold,
                cd_time = 0,--cd时间
            }
            local intValue = Instance.new('IntValue',self.skill_fol)
            intValue.Name = solt
            intValue.Value = tab.skill_id
        end
    end

    local guide2 = self.parent.save_data:GetData('guide2')
    if not guide2.__real.first_send_skill then
        self.parent.save_data:Execut(function()
            guide2.first_send_skill = true
        end)
        self:AddSkillChip(2,50)
    end
end

function c:UnlockSlot(slot)
    self.parent.save_data:Execut(function()
        self.data.equiped[slot].unlock = true
    end)

    return true
end

function c:AddSkillChip(id,num)
    self.parent.save_data:Execut(function()
        self.data.list[id].chip = self.data.list[id].chip + num
    end)

    self:Fire('AddSkillChip',id,num)
    return true
end

function c:UnlockSkill(id)
    local cfg = skillCfg[id]
    if self.data.__real.list[cfg.id].lv > 0 then
        return false
    end
    if self.data.__real.list[cfg.id].chip < cfg.lv1_need then
        return false
    end
    local needLv = cfg.need_lv
    if self.parent.prop_cmp:GetLv() < needLv then
        return false
    end
    self.parent.save_data:Execut(function()
        self.data.list[cfg.id].lv = 1
        self.data.list[cfg.id].chip = self.data.list[cfg.id].chip - cfg.lv1_need
    end)

    self:Fire('guild_skill_end')

    return true
end

function c:EquipSkill(id)
    local cfg = skillCfg[id]
    if self.data.__real.list[cfg.id].lv == 0 then
        return false
    end
    if self.data.__real.list[cfg.id].equip then
        return false
    end
    local solt = nil
    for k,v in ipairs(self.data.__real.equiped)do
        if v.unlock and v.skill_id == nil then
            solt = k
            break
        end
    end
    if not solt then
        return false
    end
    self.parent.save_data:Execut(function()
        self.data.equiped[solt].skill_id = id
        self.data.list[cfg.id].equip = true
    end)

    self.skill_list[solt] = {
        skill_id = id,
        lv = self.data.__real.list[cfg.id].lv,
        cd = cfg.cold,
        cd_time = 0,--cd时间
    }
    local intValue = Instance.new('IntValue',self.skill_fol)
    intValue.Name = solt
    intValue.Value = id

    return true,solt
end

function c:UnequipSkill(id)
    local cfg = skillCfg[id]
    if self.data.__real.list[cfg.id].lv == 0 then
        return false
    end
    if not self.data.__real.list[cfg.id].equip then
        return false
    end
    local solt = nil
    for k,v in ipairs(self.data.__real.equiped)do
        if v.unlock and v.skill_id == id then
            solt = k
            break
        end
    end
    if not solt then
        return false
    end
    self.parent.save_data:Execut(function()
        self.data.equiped[solt].skill_id = nil
        self.data.list[cfg.id].equip = false
    end)

    self.skill_list[solt] = nil
    local intValue = self.skill_fol:FindFirstChild(solt)
    if intValue then
        intValue:Destroy()
    end

    return true,solt
end

function c:UpgradeSkill(id)
    local cfg = skillCfg[id]
    if self.data.__real.list[cfg.id].lv == 0 then
        return false
    end
    local now_lv = self.data.__real.list[cfg.id].lv
    local need_str = 'lv'..(now_lv + 1)..'_need'
    if not cfg[need_str] then
        return false
    end
    if self.data.__real.list[cfg.id].chip < cfg[need_str] then
        return false
    end
    self.parent.save_data:Execut(function()
        self.data.list[cfg.id].lv = now_lv + 1
        self.data.list[cfg.id].chip = self.data.list[cfg.id].chip - cfg[need_str]
    end)
    return true
end

function c:UseSkill(solt)
    local skill = self.skill_list[solt]
    if not skill then
        return false
    end
    local now = os.clock()
    if now - skill.cd_time < skill.cd then
        return false
    end

    if self.parent.character.is_die then
        return false
    end

    skill.cd_time = now

    self:AddProcess(function()
        local stage = self.parent.now_stage
        if not stage then
            return
        end
        stage:SendAllPlayer('playerUseSkill',{
            player = self.parent.main_inst,
            solt = solt,
        })
    end)
    if place_manager:GetIdByName('guildsence') == game.PlaceId then
        hotpot.event_manager:FireAll('playerUsePKSkill',{
            player = self.parent.main_inst,
            solt = solt,
        })
    elseif place_manager:GetIdByName('pvpsence') == game.PlaceId then
        hotpot.event_manager:FireAll('playerUsePvpSkill',{
            player = self.parent.main_inst,
            solt = solt,
        })
    end

    return true
end

function c:GetSkillPer(solt)
    local skill = self.skill_list[solt]
    if not skill then
        return 0
    end
    
    local lv = self.data.__real.list[skill.skill_id].lv
    local lv_str = 'lv'..lv..'_value'
    if not skillCfg[skill.skill_id][lv_str] then
        return 0
    end

    return skillCfg[skill.skill_id][lv_str]
end

c:RegistFunction('unlockSkill',c.UnlockSkill)
c:RegistFunction('equipSkill',c.EquipSkill)
c:RegistFunction('unequipSkill',c.UnequipSkill)
c:RegistFunction('upgradeSkill',c.UpgradeSkill)
c:RegistFunction('useSkill',c.UseSkill)

return c