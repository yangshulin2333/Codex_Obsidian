local hotpot = _G.ServerHotpot

local INTERVAL = 86400
local BASETIME = 1755561600
local PRICE = {
    {price = 30000000,t = 1,id = 2},
    {price = 30000000,t = 1,id = 2},
    {price = 100,t = 2,id = 3},
    {price = 150,t = 2,id = 5},
}
local scrollPrice = {
    {price = 1000000000000,t = 1,id = 1},
    {price = 1000000000000,t = 1,id = 1},
    {price = 2500000000000,t = 1,id = 2},
    {price = 5000000000000,t = 1,id = 3},
}

---@class Server_MapShopComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)
    self.data = self.parent.save_data:GetData('map_shop')

    self.relics_data = self.parent.save_data:GetData('relics')

    self.prop_data = self.parent.save_data:GetData('prop')

    self:Init()
end

function c:Init()
    local now = os.time()
    local sub = now - BASETIME
    local day = math.floor(sub / INTERVAL)
    local mark = self.data.__real.mark
    if day > mark then
        self.parent.save_data:Execut(function()
            self.data.mark = day
            self.data.list = {}
        end)

        self.parent.save_data:Execut(function()
            self.relics_data.mapScrollShop.mark = day
            self.relics_data.mapScrollShop.list = {}

            self.relics_data.smelt_shop.mark = day
            self.relics_data.smelt_shop.list = {}
        end)

        self.parent.save_data:Execut(function()
            self.prop_data.potion.num = 0
            self.prop_data.potion.mark = day
        end)

        return true 
    end
end

function c:Refresh()
    if self:Init() then
        return 
            true,
            self.data.__real.mark,
            self.relics_data.__real.mapScrollShop.mark,
            self.relics_data.__real.smelt_shop.mark,
            self.prop_data.__real.potion.mark
    end
end

function c:Buy(id)
    local cfg = PRICE[id]

    if self.data.__real.list[id] then
        return false
    end

    if cfg.t == 1 then
        if not self.parent.prop_cmp:CostWins(cfg.price) then
            return false
        end
    elseif cfg.t == 2 then
        if not self.parent.prop_cmp:CostGems(cfg.price) then
            return false
        end
    end

    self.parent.save_data:Execut(function()
        self.data.list[id] = true
    end)

    self.parent.bag_cmp:AddBox(cfg.id,1)
    return true
end

function c:BuyScroll(id)
    local cfg = scrollPrice[id]

    if self.relics_data.__real.mapScrollShop.list[id] then
        return false
    end

    if cfg.t == 1 then
        if not self.parent.prop_cmp:CostWins(cfg.price) then
            return false
        end
    elseif cfg.t == 2 then
        if not self.parent.prop_cmp:CostGems(cfg.price) then
            return false
        end
    end

    self.parent.save_data:Execut(function()
        self.relics_data.mapScrollShop.list[id] = true
    end)

    self.parent.relics_cmp:AddScroll(cfg.id,1)
    return true
end

function c:BuySmeltScroll(id)
    local price = 750

    if self.relics_data.__real.smelt_shop.list[id] then
        return false
    end

    if not self.parent.relics_cmp:UseSmeltCoin(price) then
        return false
    end

    self.parent.save_data:Execut(function()
        self.relics_data.smelt_shop.list[id] = true
    end)

    self.parent.relics_cmp:AddScroll(4,1)
    return true
end

c:RegistFunction('refreshMapShop',c.Refresh)
c:RegistFunction('buyMapShopItem',c.Buy)
c:RegistFunction('buyMapScrollItem',c.BuyScroll)
c:RegistFunction('buySmeltShopItem',c.BuySmeltScroll)



return c

