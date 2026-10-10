local hotpot = _G.ServerHotpot
local INTERVAL = 86400
local BASETIME = 1755561600

local shopCfg = hotpot.config.pvpshop

---@class Server_PvpShopComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end

function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('pvp_shop')

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
        return true 
    end
end

function c:BuyPvpShop(id)
    local cfg = shopCfg[id]
    
    local limit = self.data.__real.list[id] or 0
    if limit >= cfg.limit then
        return false
    end

    if not self.parent.prop_cmp:CostPvpCoin(cfg.price) then
        return false
    end

    self.parent.save_data:Execut(function()
        self.data.list[id] = limit + 1
    end)

    self.parent.reward_cmp:AddReward({cfg.reward})

    return true
end

c:RegistFunction('buyPvpShop',c.BuyPvpShop)

return c