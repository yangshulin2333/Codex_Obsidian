local hotpot = _G.ClientHotpot
---@type UIManager
local ui_manager = hotpot.load.UIManager()

local INTERVAL = 86400
local BASETIME = 1755561600
local PRICE = {
    {price = 30000000,t = 1},
    {price = 30000000,t = 1},
    {price = 100,t = 2},
    {price = 150,t = 2},
}
local scrollPrice = {
    {price = 1000000000000,t = 1,id = 1},
    {price = 1000000000000,t = 1,id = 1},
    {price = 2500000000000,t = 1,id = 2},
    {price = 5000000000000,t = 1,id = 3},
}

---@class Client_MapShopComponent:Client_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Client_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('map_shop')
    self.scrollData = self.parent.save_data:GetData('relics').mapScrollShop
    self.smeltData = self.parent.save_data:GetData('relics').smelt_shop
    self.propData = self.parent.save_data:GetData('prop')
    self.ui = ui_manager.ui_list.map_shop_gui
    self.ui:BindItemBtnClickHandle(self,self.ClickItemBtn)

    ui_manager.ui_list.map_scroll_shop_gui:BindItemBtnClickHandle(self,self.ClickBuyScroll) 
    ui_manager.ui_list.relics_smelter_gui:BindShopItemClickHandle(self,self.ClickSmeltItem)

    self:InitUi()
    self:AddUpdate(self.Update,1)
end

function c:InitUi()
    for i = 1,4 do
        self.ui:SetItemBtnVisible(i,not self.data.list[i])
        ui_manager.ui_list.map_scroll_shop_gui:SetItemBtnVisible(i,not self.scrollData.list[i])
        ui_manager.ui_list.relics_smelter_gui:SetShopItemBtnVisible(i,not self.smeltData.list[i])
    end

    ui_manager.ui_list.buy_posion_gui:SetLimited(self.propData.potion.num)
end

function c:Update()
    local now = workspace:GetServerTimeNow()
    local mark = self.data.mark
    local overTime = (mark + 1) * INTERVAL + BASETIME
    local cd = overTime - now
    self.ui:SetCD(cd)
    ui_manager.ui_list.map_scroll_shop_gui:SetCD(cd)
    ui_manager.ui_list.relics_smelter_gui:SetCd(cd)
    ui_manager.ui_list.buy_posion_gui:SetCd(cd)

    if cd <= 0 then
        local re,mark,mark2,mark3,mark4 = self:Invoke('refreshMapShop')
        if re then
            self.data.list = {}
            self.data.mark = mark
            self.scrollData.mark = mark2
            self.scrollData.list = {}
            self.smeltData.mark = mark3
            self.smeltData.list = {}
            self.propData.potion.mark = mark4
            self.propData.potion.num = 0
            self:InitUi()
        end
    end
end

function c:ClickItemBtn(id)
    if self.data.list[id] then
        return
    end
    local cfg = PRICE[id]
    if cfg.t == 1 then
        if self.parent.prop_cmp:GetWins() < cfg.price then
            ui_manager.ui_list.tips_gui:TipsMessage('Not enough Coins!','fail')
            return
        end
    elseif cfg.t == 2 then
        if self.parent.prop_cmp:GetGems() < cfg.price then
            ui_manager.ui_list.tips_gui:TipsMessage('Not enough Gems!','fail')
            return
        end
    end
    local re = self:Invoke('buyMapShopItem',id)
    if re then
        ui_manager.ui_list.tips_gui:TipsMessage('Buy Success!','success')
        self.data.list[id] = true
        self.ui:SetItemBtnVisible(id,false)
    end
end

function c:ClickBuyScroll(id)
    if self.scrollData.list[id] then
        return
    end
    local cfg = scrollPrice[id]
    if cfg.t == 1 then
        if self.parent.prop_cmp:GetWins() < cfg.price then
            ui_manager.ui_list.tips_gui:TipsMessage('Not enough Coins!','fail')
            return
        end
    elseif cfg.t == 2 then
        if self.parent.prop_cmp:GetGems() < cfg.price then
            ui_manager.ui_list.tips_gui:TipsMessage('Not enough Gems!','fail')
            return
        end
    end
    local re = self:Invoke('buyMapScrollItem',id)
    if re then
        ui_manager.ui_list.tips_gui:TipsMessage('Buy Success!','success')
        self.scrollData.list[id] = true
        ui_manager.ui_list.map_scroll_shop_gui:SetItemBtnVisible(id,false)
    end
end

function c:ClickSmeltItem(id)
    if self.smeltData.list[id] then
        return
    end
    local price = 750
    if self.parent.relics_cmp:GetSmeltCoin() < price then
        ui_manager.ui_list.tips_gui:TipsMessage('Not enough Smelt Coin!','fail')
        return
    end
    
    local re = self:Invoke('buySmeltShopItem',id)
    if re then
        ui_manager.ui_list.tips_gui:TipsMessage('Buy Success!','success')
        self.smeltData.list[id] = true
        ui_manager.ui_list.relics_smelter_gui:SetShopItemBtnVisible(id,false)
    end
end

return c

