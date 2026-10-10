local hotpot = _G.ServerHotpot
---@type InstanceManager
local inst_manager = hotpot.load.InstanceManager()
---@type MarketplaceService
local MarketplaceService = game:GetService('MarketplaceService')

local GIFT_VERSION = 3
local goods_cfg = hotpot.config.goods
local shop_gift_cfg = hotpot.config.shop_gift
local buff_cfg = hotpot.config.boosts

local LuckyList = {}
for k,v in ipairs(goods_cfg)do
    if v.g_type == 'shop_lucky' then
        table.insert(LuckyList,v.args[1])
    end
end

---@class Server_ShopComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('shop')
    self.pay_data = self.parent.save_data:GetData('pay')
    self.gift_list = self.parent.save_data:GetData('gift_list')

    self:CheckLucky()
    self:CheckGiftVersion()
end

--检查giftVersion
function c:CheckGiftVersion()
    local data = self.data.__real.gift_list
    if data.version < GIFT_VERSION then
        self.parent.save_data:Execut(function()
            data.version = GIFT_VERSION
            data.get = 0
        end)
    end
end

--检查lucky
function c:CheckLucky()
    local data = self.data.__real.lucky
    local num = data.num
    local time_ = data.time_
    local now = os.time()
    if now - time_ >= 43200 then
        self.parent.save_data:Execut(function()
            self.data.lucky.num = 0
        end)
    end
end

--购买gamepass
function c:BuyGamePass(cfg_id,isGift)
    if self.giftPlayer and not isGift then
        ---@type Server_Player
        local obj = inst_manager:FindObject(self.giftPlayer)
        if not obj then
            return false
        end
        obj.shop_cmp:BuyGamePass(cfg_id,true)
        obj:Fire('OtherSendGift',self.parent:GetName(),cfg_id)

        local save_data = obj.save_data
        local pay = save_data:GetData('pay')
        save_data:Execut(function()
            pay.pay_list[cfg_id] = 1
        end)

        pcall(function()
            local now = os.time()
            local uid = self.giftPlayer.UserId
            self.parent.save_data:Execut(function()
                self.gift_list[now] = {
                    uid = uid,
                    cfg_id = cfg_id,
                }
            end)
        end)

        return true
    end

    if not self.giftPlayer then
        local save_data = self.parent.save_data
        local pay = save_data:GetData('pay')
        save_data:Execut(function()
            pay.pay_list[cfg_id] = 1
        end)
    end
    
    local cfg = goods_cfg[cfg_id]
    if not cfg then
        return false
    end
    
    if cfg_id == 26 then
        self.parent.pet_cmp:AddEquipedNum(2)
    end
    if cfg_id == 27 then
        self.parent.pet_cmp:AddEquipedNum(4)
    end
    if cfg_id == 28 or cfg_id == 64 then
        self.parent.stats_cmp:SyncAttack()
        self.parent.relics_cmp:RefrehPower()
        local hp = self.parent.prop_cmp:GetHp()
        self.parent.character.hp = hp
        self.parent.character.max_hp = hp
        self.parent.sync_cmp:Add('sync_hp',{
            hp = hp,
            max_hp = hp,
        })
    end

    return true   
end
   
--购买gamepass
function c:BuyGamePass1(cfg_id)
    local cfg = goods_cfg[cfg_id]
    if not cfg then
        return false
    end

    -- if cfg_id == 63 then
    --     self.parent.relics_cmp:UnlockAll()
    -- end

    if cfg_id >=69 and cfg_id <= 71 then
        self.parent.relics_cmp:BuyUnlockSolt(goods_cfg[cfg_id].args[1])
    end

    return true
end

--购买ShopGift
function c:BuyShopGift(cfg_id)
    local cfg = goods_cfg[cfg_id]
    local gift_id = cfg.args[1]
    self:GetPayGift(gift_id)
    return true
end

--购买新手礼包
function c:BuyStarterPack(cfg_id)
    local cfg = goods_cfg[cfg_id]
    local reward = cfg.reward
    self.parent.reward_cmp:AddReward(reward)
    return true
end

--购买箱子
function c:BuyShopBox(cfg_id,isGift)
    if self.giftPlayer and not isGift then
        ---@type Server_Player
        local obj = inst_manager:FindObject(self.giftPlayer)
        if not obj then
            return false
        end
        obj.shop_cmp:BuyShopBox(cfg_id,true)
        obj:Fire('OtherSendGift',self.parent:GetName(),cfg_id)

        pcall(function()
            local now = os.time()
            local uid = self.giftPlayer.UserId
            self.parent.save_data:Execut(function()
                self.gift_list[now] = {
                    uid = uid,
                    cfg_id = cfg_id,
                }
            end)
        end)

        return true
    end
    local cfg = goods_cfg[cfg_id]
    local args = cfg.args
    local id = args[1]
    local num = args[2]
    self.parent.bag_cmp:AddBox(id,num)
    return true
end

--购买limitPet
function c:BuyLimitPet(cfg_id,isGift)
    if self.giftPlayer and not isGift then
        ---@type Server_Player
        local obj = inst_manager:FindObject(self.giftPlayer)
        if not obj then
            return false
        end
        obj.shop_cmp:BuyLimitPet(cfg_id,true)
        obj:Fire('OtherSendGift',self.parent:GetName(),cfg_id)
        pcall(function()
            local now = os.time()
            local uid = self.giftPlayer.UserId
            self.parent.save_data:Execut(function()
                self.gift_list[now] = {
                    uid = uid,
                    cfg_id = cfg_id,
                }
            end)
        end)

        return true
    end
    local cfg = goods_cfg[cfg_id]
    local pet_id = cfg.args[1]
    self.parent.pet_cmp:AddPet(pet_id)
    return true
end

--购买buff
function c:BuyBoosts(cfg_id,isGift)
    if self.giftPlayer and not isGift then
        ---@type Server_Player
        local obj = inst_manager:FindObject(self.giftPlayer)
        if not obj then
            return false
        end
        obj.shop_cmp:BuyBoosts(cfg_id,true)
        obj:Fire('OtherSendGift',self.parent:GetName(),cfg_id)
        pcall(function()
            local now = os.time()
            local uid = self.giftPlayer.UserId
            self.parent.save_data:Execut(function()
                self.gift_list[now] = {
                    uid = uid,
                    cfg_id = cfg_id,
                }
            end)
        end)
        return true
    end
    local cfg = goods_cfg[cfg_id]
    local id = cfg.args[1]
    self.parent.bag_cmp:AddBuff(id,5)

    return true
end

--购买wins
function c:BuyWins(cfg_id)
    local cfg = goods_cfg[cfg_id]
    local num = cfg.args[1]
    -- self.parent.prop_cmp:AddWins(num)
    self.parent.reward_cmp:AddReward(cfg.reward)
    return true
end

--购买gems
function c:BuyGems(cfg_id)
    local cfg = goods_cfg[cfg_id]
    local num = cfg.args[1]
    self.parent.reward_cmp:AddReward({{1,2,num}})
    return true
end

--购买幸运
function c:BuyLucky(cfg_id)
    self:CheckLucky()
    self.parent.save_data:Execut(function()
        self.data.lucky.num = self.data.lucky.num + 1
        self.data.lucky.time_ = os.time()
    end)

    self:Fire('buyShopLucky',self.data.__real.lucky)

    return true
end

--购买suit
function c:BuySuit(cfg_id)
    local cfg = goods_cfg[cfg_id]
    local reward = cfg.reward

    self.parent.reward_cmp:AddReward(reward)
end

--领取免费gift
function c:GetFreeGift(id)
    local data = self.data.__real.gift_list.get
    if id ~= data + 1 then
        return false
    end
    local cfg = shop_gift_cfg[id]
    if not cfg then
        return false
    end
    if cfg.price ~= 0 then
        return false
    end

    local reward = cfg.reward
    self.parent.save_data:Execut(function()
        self.data.gift_list.get = id
    end)
    self.parent.reward_cmp:AddReward(reward)

    return true
end

--领取付费gift
function c:GetPayGift(id)
    local data = self.data.__real.gift_list.get
    if id ~= data + 1 then
        return false
    end
    local cfg = shop_gift_cfg[id]
    if not cfg then
        return false
    end

    local reward = cfg.reward
    self.parent.save_data:Execut(function()
        self.data.gift_list.get = id
    end)
    self.parent.reward_cmp:AddReward(reward)

    return true
end

--获取付费幸运值
function c:GetLucky()
    self:CheckLucky()
    local num = self.data.__real.lucky.num
    if num == 0 then
        return 1
    end
    if LuckyList[num] then
        return LuckyList[num]
    end
    return 1
end

--赠送玩家
function c:GiftPlayer(player)
    if player then
        if not inst_manager:FindObject(player) then
            self.giftPlayer = nil
        end
    end
    self.giftPlayer = player
end

--兑换码购买
function c:CodeBuyGoods(cfg_id)
    local cfg = goods_cfg[cfg_id]
    local g_type = cfg.g_type
    if g_type == 'limit_pet' then
        self:BuyLimitPet(cfg_id)
    elseif g_type == 'gamepass' then
        self:BuyGamePass(cfg_id)
    elseif g_type == 'shop_box' then
        self:BuyShopBox(cfg_id)
    elseif g_type == 'gamepass_1' then
        self:BuyGamePass1(cfg_id)
    end

    if cfg_id == 65 then
        self.parent.eternal_cmp:BuyPrimium()
        self:Fire('eternalCodePurchase')
    end

    if cfg_id >=69 and cfg_id <= 71 then
        self:Fire('codeUnlockSolt',goods_cfg[cfg_id].args[1])
    end
end

--检查赠送玩家是否拥有商品
function c:CheckGiftPlayerHasGoods(cfg_id)
    if not self.giftPlayer then
        return false
    end
    ---@type Server_Player
    local obj = inst_manager:FindObject(self.giftPlayer)
    if not obj then
        return false
    end
    return obj.shop_cmp:CheckGoods(cfg_id)
end

function c:CheckGoods(cfg_id)
    local data = self.parent.save_data:GetData('pay')
    data = data.__real.pay_list
    if data[cfg_id] then
        return true
    end
    return false
end

function c:PromptGamePassPurchase(cfg_id)
    local cfg = goods_cfg[cfg_id]
    self.parent.save_data:Execut(function()
        self.pay_data.pay_list[cfg_id] = true
    end)

    if cfg_id == 26 then
        self.parent.pet_cmp:AddEquipedNum(2)
    end
    if cfg_id == 27 then
        self.parent.pet_cmp:AddEquipedNum(4)
    end
end

function c:CheckGamePass()
    for k,v in pairs(goods_cfg)do
        if v.isGamePass then
            if not self.pay_data.__real.pay_list[v.id] then
                local r,e = pcall(function()
                    if MarketplaceService:UserOwnsGamePassAsync(self.parent.user_id,v.goods_id) then
                        self:PromptGamePassPurchase(v.id)
                    end
                end)
                if not r then
                    warn(e)
                end
            end
        end
    end
end

c:RegistFunction('get_gift_reward',c.GetFreeGift)
c:RegistEvent('GiftPlayer',c.GiftPlayer)
c:RegistFunction('check_goods',c.CheckGiftPlayerHasGoods)

return c