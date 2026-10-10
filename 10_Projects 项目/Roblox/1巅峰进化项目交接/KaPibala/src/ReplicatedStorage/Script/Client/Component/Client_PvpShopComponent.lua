local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local shopCfg = hotpot.config.pvpshop

---@class Client_PvpShopComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end

function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('pvp_shop')
    self.ui = ui_manager.ui_list.pvp_shop_gui
    self.ui:BindItemBtnClickHandle(self,self.ClickItem)

    self:InitUi()
end

function c:InitUi()
    for k,v in ipairs(shopCfg)do
        self.ui:AddItemInScroll(
            v.id,
            self.parent.reward_cmp:GetName(v.reward),
            v.icon or self.parent.reward_cmp:GetIcon(v.reward),
            self.parent.reward_cmp:GetQulity(v.reward),
            v.price,
            v.reward[3]
        )
        self.ui:SetItemLimit(v.id,self.data.list[v.id] or 0,v.limit)
    end

    self.ui:SetCoin(self.parent.prop_cmp:GetPvpCoin())
end

function c:ClickItem(id)
    local limit = self.data.list[id] or 0
    local cfg = shopCfg[id]
    if limit >= cfg.limit then
        ui_manager.ui_list.tips_gui:TipsMessage('Limited','fail')
        return
    end

    if self.parent.prop_cmp:GetPvpCoin() < cfg.price then
        ui_manager.ui_list.tips_gui:TipsMessage('Not enough coin','fail')
        return
    end

    local re = self:Invoke('buyPvpShop',id)
    if re then
        self.data.list[id] = limit + 1
        self.ui:SetItemLimit(id,limit + 1,cfg.limit)
    end
end

return c