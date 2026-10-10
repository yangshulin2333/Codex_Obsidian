local hotpot = _G.ServerHotpot

local upgrade_cfg = hotpot.config.upgrade

---@class Server_UpgradeComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('upgrade')
end

function c:Unlock(id)
    local cfg = upgrade_cfg[id]
    if not cfg then
        return
    end
    local need = cfg.price
    if not self.parent.prop_cmp:CostGems(need) then
        return
    end

    self.parent.save_data:Execut(function()
        self.data.list[id] = true
    end)

    if cfg.prop == 'pet' then
        self.parent.pet_cmp:AddEquipedNum(1)
    end

    if cfg.prop == 'relics' then
        self.parent.relics_cmp:UnlockSolt()
    end

    self.parent.stats_cmp:SyncAttack()
    local hp = self.parent.prop_cmp:GetHp()
    self.parent.character.hp = hp
    self.parent.character.max_hp = hp
    self.parent.sync_cmp:Add('sync_hp',{
        hp = hp,
        max_hp = hp,
    })
    
    self.parent.relics_cmp:RefrehPower()
    return true
end

function c:GetValue(str)
    local val = 0
    for id,v in pairs(self.data.__real.list)do
        local cfg = upgrade_cfg[id]
        if cfg and cfg.prop == str then
            val = val + cfg.value * 0.01
        end
    end
    return val
end

c:RegistFunction('unlockUpgrade',c.Unlock)

return c