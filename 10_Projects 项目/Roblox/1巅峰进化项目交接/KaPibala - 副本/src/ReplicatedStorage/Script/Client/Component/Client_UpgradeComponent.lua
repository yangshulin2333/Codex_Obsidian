local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local upgrade_cfg = hotpot.config.upgrade

---@class Client_UpgradeComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('upgrade')
end

function c:Unlock(id)
    local data = self.data
    if data.list[id] then
        return
    end
    local cfg = upgrade_cfg[id]
    if self.parent.prop_cmp:GetGems() < cfg.price then
        ui_manager.ui_list.tips_gui:TipsMessage('Not Enough Gems','fail')
        return
    end
    local re = self:Invoke('unlockUpgrade',id)
    if re then
        data.list[id] = true
        self.parent.now_stage:SetUpgradeOwned(id,true)
        self.parent.now_stage:PlayUpgradeEff(id)
        ui_manager.ui_list.tips_gui:TipsMessage('Success!','success')
    end
end

return c