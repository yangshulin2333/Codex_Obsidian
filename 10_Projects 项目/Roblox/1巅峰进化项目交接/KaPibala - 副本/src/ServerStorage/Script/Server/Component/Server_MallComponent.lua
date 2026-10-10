local _G = _G
local script = script
local hotpot = _G.ServerHotpot
local function_list = hotpot.function_list
function_list.buy_goods = true
local function_manager = hotpot.function_manager
local pay_manager = hotpot.load.Server_PayManager()
local goods_config = hotpot.config.goods
---@type BadgeHelper
local BadgeHelper = hotpot.load.BadgeHelper()
---@type Server_RankManager
local rankManager = hotpot.load.Server_RankManager()
---@type InstanceManager
local inst_manager = hotpot.load.InstanceManager()

local BindableEvent = game.ServerStorage:WaitForChild('Event')

---@class Server_MallComponent:BaseComponent
local c = hotpot.class.new(script, hotpot.files.BaseComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self, parent)
    self:InitGoods()
    self:InitHandleOnBuyPremium()
end

---@param player_object Server_Player
local function SavePurchase(player_object,price)
    local r,e = pcall(function()
        rankManager:IncrementRankValue('purchase',player_object.user_id,price)

        player_object.title_cmp:AddPoint(3,price)
    end)
    if not r then
        warn(e)
    end
end

--------------------------------------购买方法
local buy_funcs = {}
---@param player_object Server_Player
buy_funcs.gamepass = function(player_object, product_id, cfg_id)

    SavePurchase(player_object,goods_config[cfg_id].price)

    local shop_cmp = player_object.shop_cmp

    return shop_cmp:BuyGamePass(cfg_id)
end
---@param player_object Server_Player
buy_funcs.shop_gift = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    local shop_cmp = player_object.shop_cmp

    return shop_cmp:BuyShopGift(cfg_id)
end
---@param player_object Server_Player
buy_funcs.starter_pack = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        pay.pay_list[cfg_id] = 1
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    local shop_cmp = player_object.shop_cmp

    return shop_cmp:BuyStarterPack(cfg_id)
end
---@param player_object Server_Player
buy_funcs.shop_box = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    local shop_cmp = player_object.shop_cmp

    return shop_cmp:BuyShopBox(cfg_id)
end
---@param player_object Server_Player
buy_funcs.limit_pet = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        pay.pay_list[cfg_id] = 1
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    local shop_cmp = player_object.shop_cmp

    return shop_cmp:BuyLimitPet(cfg_id)
end
---@param player_object Server_Player
buy_funcs.boosts = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    local shop_cmp = player_object.shop_cmp

    return shop_cmp:BuyBoosts(cfg_id)
end
---@param player_object Server_Player
buy_funcs.wins = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    local shop_cmp = player_object.shop_cmp

    return shop_cmp:BuyWins(cfg_id)
end
---@param player_object Server_Player
buy_funcs.shop_lucky = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    ---@type Server_ShopComponent
    local shop_cmp = player_object.shop_cmp

    return shop_cmp:BuyLucky(cfg_id)
end
---@param player_object Server_Player
buy_funcs.gamepass_1 = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        pay.pay_list[cfg_id] = 1
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    local shop_cmp = player_object.shop_cmp

    return shop_cmp:BuyGamePass1(cfg_id)
end
---@param player_object Server_Player
buy_funcs.pet = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    player_object.pet_cmp:AddPet(goods_config[cfg_id].args[1])

    return true
end
---@param player_object Server_Player
buy_funcs.bp = function(player_object, product_id, cfg_id)
    if not player_object.battle_pass_cmp then
        return false
    end
    if player_object.battle_pass_cmp.gift_player then
        SavePurchase(player_object,goods_config[cfg_id].price)
        ---@type Server_Player
        local obj = inst_manager:FindObject(player_object.battle_pass_cmp.gift_player)
        if not obj then
            return false
        end
        local save_data = obj.save_data
        local pay = save_data:GetData('pay')
        save_data:Execut(function()
            if pay.pay_list[cfg_id] then
                pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
            else
                pay.pay_list[cfg_id] = 1
            end
        end)
        obj.battle_pass_cmp:BuyPrimium()
        hotpot.event_manager:Fire(obj,'sendBattlePassPrimium',player_object:GetName())

        pcall(function()
            local now = os.time()
            local uid = obj.user_id
            local gift_list = player_object.save_data:GetData('gift_list')
            player_object.save_data:Execut(function()
                gift_list[now] = {
                    uid = uid,
                    cfg_id = cfg_id,
                }
            end)
        end)

        return true
    end
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    player_object.battle_pass_cmp:BuyPrimium()

    return true
end
---@param player_object Server_Player
buy_funcs.inventory = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    player_object.pet_cmp:AddCapacityNum(50)

    return true
end
---@param player_object Server_Player
buy_funcs.eternalBP = function(player_object, product_id, cfg_id)
    if not player_object.eternal_cmp then
        return false
    end
    if player_object.eternal_cmp.gift_player then
        SavePurchase(player_object,goods_config[cfg_id].price)
        ---@type Server_Player
        local obj = inst_manager:FindObject(player_object.eternal_cmp.gift_player)
        if not obj then
            return false
        end
        local save_data = obj.save_data
        local pay = save_data:GetData('pay')
        save_data:Execut(function()
            if pay.pay_list[cfg_id] then
                pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
            else
                pay.pay_list[cfg_id] = 1
            end
        end)
        obj.eternal_cmp:BuyPrimium()
        hotpot.event_manager:Fire(obj,'sendEternalPrimium',player_object:GetName(),'Primium')

        pcall(function()
            local now = os.time()
            local uid = obj.user_id
            local gift_list = player_object.save_data:GetData('gift_list')
            player_object.save_data:Execut(function()
                gift_list[now] = {
                    uid = uid,
                    cfg_id = cfg_id,
                }
            end)
        end)

        return true
    end

    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    player_object.eternal_cmp:BuyPrimium()

    return true
end
---@param player_object Server_Player
buy_funcs.eternalCoins = function(player_object, product_id, cfg_id)
    if not player_object.eternal_cmp then
        return false
    end
    if player_object.eternal_cmp.gift_player then
        SavePurchase(player_object,goods_config[cfg_id].price)
        ---@type Server_Player
        local obj = inst_manager:FindObject(player_object.eternal_cmp.gift_player)
        if not obj then
            return false
        end
        local save_data = obj.save_data
        local pay = save_data:GetData('pay')
        save_data:Execut(function()
            if pay.pay_list[cfg_id] then
                pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
            else
                pay.pay_list[cfg_id] = 1
            end
        end)
        -- obj.eternal_cmp:()
        hotpot.event_manager:Fire(obj,'sendEternalPrimium',player_object:GetName(),'doubleCoins')
        pcall(function()
            local now = os.time()
            local uid = obj.user_id
            local gift_list = player_object.save_data:GetData('gift_list')
            player_object.save_data:Execut(function()
                gift_list[now] = {
                    uid = uid,
                    cfg_id = cfg_id,
                }
            end)
        end)
        return true
    end
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)

    return true
end
---@param player_object Server_Player
buy_funcs.refreshtask = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    player_object.eternal_cmp:RefreshTask()

    return true
end
---@param player_object Server_Player
buy_funcs.scroll = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    
    player_object.relics_cmp:AddScroll(5,1)

    return true
end
---@param player_object Server_Player
buy_funcs.halloweenPack = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')

    if player_object.shop_cmp and player_object.shop_cmp.giftPlayer then
        ---@type Server_Player
        local p = player_object.shop_cmp.giftPlayer
        ---@type Server_Player
        local obj = inst_manager:FindObject(p)
        if not (obj and obj.IsExist and obj:IsExist()) then
            return false
        end
        if not (obj and obj.main_inst and obj.main_inst.Parent) then
            return false
        end
        local p_data = obj.save_data:GetData('pay')
        obj.save_data:Execut(function()
            if p_data.pay_list[cfg_id] then
                p_data.pay_list[cfg_id] = p_data.pay_list[cfg_id] + 1
            else
                p_data.pay_list[cfg_id] = 1
            end
        end)
        SavePurchase(player_object,goods_config[cfg_id].price)
        obj.reward_cmp:AddReward(goods_config[cfg_id].reward)
        pcall(function()
            hotpot.event_manager:Fire(obj,'OtherSendGift',player_object:GetName(),cfg_id)
        end)

        pcall(function()
            local now = os.time()
            local uid = obj.user_id
            local gift_list = player_object.save_data:GetData('gift_list')
            player_object.save_data:Execut(function()
                gift_list[now] = {
                    uid = uid,
                    cfg_id = cfg_id,
                }
            end)
        end)

        return true
    end

    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    
    player_object.reward_cmp:AddReward(goods_config[cfg_id].reward)

    return true
end
---@param player_object Server_Player
buy_funcs.gems = function(player_object, product_id, cfg_id)
    if player_object.shop_cmp and player_object.shop_cmp.giftPlayer then
        ---@type Server_Player
        local p = player_object.shop_cmp.giftPlayer
        ---@type Server_Player
        local obj = inst_manager:FindObject(p)
        if not (obj and obj.IsExist and obj:IsExist()) then
            return false
        end
        if not (obj and obj.main_inst and obj.main_inst.Parent) then
            return false
        end
        local p_data = obj.save_data:GetData('pay')
        obj.save_data:Execut(function()
            if p_data.pay_list[cfg_id] then
                p_data.pay_list[cfg_id] = p_data.pay_list[cfg_id] + 1
            else
                p_data.pay_list[cfg_id] = 1
            end
        end)
        SavePurchase(player_object,goods_config[cfg_id].price)
        obj.shop_cmp:BuyGems(cfg_id)
        pcall(function()
            hotpot.event_manager:Fire(obj,'OtherSendGift',player_object:GetName(),cfg_id)
        end)

        pcall(function()
            local now = os.time()
            local uid = obj.user_id
            local gift_list = player_object.save_data:GetData('gift_list')
            player_object.save_data:Execut(function()
                gift_list[now] = {
                    uid = uid,
                    cfg_id = cfg_id,
                }
            end)
        end)

        return true
    end
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    local shop_cmp = player_object.shop_cmp

    return shop_cmp:BuyGems(cfg_id)
end
---@param player_object Server_Player
buy_funcs.chainsawPack = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')

    if player_object.shop_cmp and player_object.shop_cmp.giftPlayer then
        ---@type Server_Player
        local p = player_object.shop_cmp.giftPlayer
        ---@type Server_Player
        local obj = inst_manager:FindObject(p)
        if not (obj and obj.IsExist and obj:IsExist()) then
            return false
        end
        if not (obj and obj.main_inst and obj.main_inst.Parent) then
            return false
        end
        local p_data = obj.save_data:GetData('pay')
        obj.save_data:Execut(function()
            if p_data.pay_list[cfg_id] then
                p_data.pay_list[cfg_id] = p_data.pay_list[cfg_id] + 1
            else
                p_data.pay_list[cfg_id] = 1
            end
        end)
        SavePurchase(player_object,goods_config[cfg_id].price)
        obj.reward_cmp:AddReward(goods_config[cfg_id].reward)
        pcall(function()
            hotpot.event_manager:Fire(obj,'OtherSendGift',player_object:GetName(),cfg_id)
        end)
        return true
    end

    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    
    player_object.reward_cmp:AddReward(goods_config[cfg_id].reward)

    return true
end
---@param player_object Server_Player
buy_funcs.ChristmasCoins = function(player_object, product_id, cfg_id)
    if not player_object.eternal_cmp then
        return false
    end
    if player_object.eternal_cmp.gift_player then
        SavePurchase(player_object,goods_config[cfg_id].price)
        ---@type Server_Player
        local obj = inst_manager:FindObject(player_object.eternal_cmp.gift_player)
        if not obj then
            return false
        end
        local save_data = obj.save_data
        local pay = save_data:GetData('pay')
        save_data:Execut(function()
            if pay.pay_list[cfg_id] then
                pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
            else
                pay.pay_list[cfg_id] = 1
            end
        end)
        -- obj.eternal_cmp:()
        obj.reward_cmp:AddReward(goods_config[cfg_id].reward)
        hotpot.event_manager:Fire(obj,'sendEternalPrimium',player_object:GetName(),'Coins')
        pcall(function()
            local now = os.time()
            local uid = obj.user_id
            local gift_list = player_object.save_data:GetData('gift_list')
            player_object.save_data:Execut(function()
                gift_list[now] = {
                    uid = uid,
                    cfg_id = cfg_id,
                }
            end)
        end)
        return true
    end
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    
    player_object.reward_cmp:AddReward(goods_config[cfg_id].reward)

    return true
end
---@param player_object Server_Player
buy_funcs.skillSlot = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    
    player_object.skill_cmp:UnlockSlot(goods_config[cfg_id].args[1])

    return true
end
---@param player_object Server_Player
buy_funcs.skillBox = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    
    player_object.open_skill_cmp:OpenSkill(goods_config[cfg_id].args[1])

    return true
end
---@param player_object Server_Player
buy_funcs.mount = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    
    player_object.mount_cmp:UnlockMount(goods_config[cfg_id].args[1])
    return true
end
---@param player_object Server_Player
buy_funcs.luckyStone = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    
    player_object.reward_cmp:AddReward(goods_config[cfg_id].reward)
    return true
end
---@param player_object Server_Player
buy_funcs.forgeStone = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    
    player_object.reward_cmp:AddReward(goods_config[cfg_id].reward)
    return true
end
---@param player_object Server_Player
buy_funcs.pvpBuff = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    
    local args = goods_config[cfg_id].args
    player_object.pvp_buff_cmp:BuyBuff(args[1],args[2]) 
    
    return true
end
---@param player_object Server_Player
buy_funcs.revenge = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    
    -- local plr = player_object.kill_player
    -- if plr then
    --     ---@type Server_Player
    --     local obj = inst_manager:FindObject(plr)
    --     if obj then
    --         obj.character:RevengeDie(player_object.main_inst)
    --         pcall(function()
    --             hotpot.event_manager:FireAll('pvprevengetip',{player1 = player_object.main_inst,player2 = plr})
    --         end)
    --     end
    -- end

    return true
end
---@param player_object Server_Player
buy_funcs.transfer = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    
    player_object.relics_cmp:Transfer(cfg_id)

    return true
end
---@param player_object Server_Player
buy_funcs.recover = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    
    player_object.new_daily_cmp:Recover()

    return true
end
---@param player_object Server_Player
buy_funcs.relics = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    
    player_object.shop_cmp:BuySuit(cfg_id)

    return true
end
---@param player_object Server_Player
buy_funcs.skipOnline = function(player_object, product_id, cfg_id)
    local save_data = player_object.save_data
    local pay = save_data:GetData('pay')
    save_data:Execut(function()
        if pay.pay_list[cfg_id] then
            pay.pay_list[cfg_id] = pay.pay_list[cfg_id] + 1
        else
            pay.pay_list[cfg_id] = 1
        end
    end)
    SavePurchase(player_object,goods_config[cfg_id].price)
    
    player_object.online_cmp:SkipAll()
    return true
end
--------------------------------------检测方法
local check_funcs = {}
---@param player_object Server_Player
check_funcs.gamepass = function(player_object, product_id, cfg_id)
    if player_object.shop_cmp and player_object.shop_cmp.giftPlayer then
        ---@type Server_Player
        local p = player_object.shop_cmp.giftPlayer
        ---@type Server_Player
        local obj = inst_manager:FindObject(p)
        if not (obj and obj.IsExist and obj:IsExist()) then
            return false
        end
        if not (obj and obj.main_inst and obj.main_inst.Parent) then
            return false
        end
        
        local data = obj.save_data:GetData('pay').__real.pay_list
        if data[cfg_id] then
            return false
        end

        return true
    end
    local pay_list = player_object.save_data:GetData('pay').__real.pay_list
    if pay_list[cfg_id] then
        return false
    end
    return true
end
---@param player_object Server_Player
check_funcs.shop_gift = function(player_object, product_id, cfg_id)
    return true
end
---@param player_object Server_Player
check_funcs.starter_pack = function(player_object, product_id, cfg_id)
    local pay_list = player_object.save_data:GetData('pay').__real.pay_list
    if pay_list[cfg_id] then
        return false
    end
    return true
end
---@param player_object Server_Player
check_funcs.shop_box = function(player_object, product_id, cfg_id)
    if player_object.shop_cmp and player_object.shop_cmp.giftPlayer then
        ---@type Server_Player
        local p = player_object.shop_cmp.giftPlayer
        local obj = inst_manager:FindObject(p)
        if not (obj and obj.IsExist and obj:IsExist()) then
            return false
        end
        if not (obj and obj.main_inst and obj.main_inst.Parent) then
            return false
        end
        return true
    end
    return true
end
---@param player_object Server_Player
check_funcs.limit_pet = function(player_object, product_id, cfg_id)
    if player_object.shop_cmp and player_object.shop_cmp.giftPlayer then
        ---@type Server_Player
        local p = player_object.shop_cmp.giftPlayer
        local obj = inst_manager:FindObject(p)
        if not (obj and obj.IsExist and obj:IsExist()) then
            return false
        end
        if not (obj and obj.main_inst and obj.main_inst.Parent) then
            return false
        end
        return true
    end
    return true
end
---@param player_object Server_Player
check_funcs.boosts = function(player_object, product_id, cfg_id)
    if player_object.shop_cmp and player_object.shop_cmp.giftPlayer then
        ---@type Server_Player
        local p = player_object.shop_cmp.giftPlayer
        local obj = inst_manager:FindObject(p)
        if not (obj and obj.IsExist and obj:IsExist()) then
            return false
        end
        if not (obj and obj.main_inst and obj.main_inst.Parent) then
            return false
        end
        return true
    end
    return true
end
---@param player_object Server_Player
check_funcs.wins = function(player_object, product_id, cfg_id)
    return true
end
---@param player_object Server_Player
check_funcs.shop_lucky = function(player_object, product_id, cfg_id)
    return true
end
---@param player_object Server_Player
check_funcs.gamepass_1 = function(player_object, product_id, cfg_id)
    if player_object.shop_cmp and player_object.shop_cmp.giftPlayer then
        ---@type Server_Player
        local p = player_object.shop_cmp.giftPlayer
        local obj = inst_manager:FindObject(p)
        if not (obj and obj.IsExist and obj:IsExist()) then
            return false
        end
        if not (obj and obj.main_inst and obj.main_inst.Parent) then
            return false
        end
        return true
    end
    local pay_list = player_object.save_data:GetData('pay').__real.pay_list
    if pay_list[cfg_id] then
        return false
    end
    return true
end
---@param player_object Server_Player
check_funcs.pet = function(player_object, product_id, cfg_id)
    return true
end
---@param player_object Server_Player
check_funcs.bp = function(player_object, product_id, cfg_id)
    if not player_object.battle_pass_cmp then
        return false
    end
    if player_object.battle_pass_cmp.gift_player then
        return true
    end
    local pay_list = player_object.save_data:GetData('pay').__real.pay_list
    if pay_list[cfg_id] then
        return false
    end
    return true
end
---@param player_object Server_Player
check_funcs.inventory = function(player_object, product_id, cfg_id)
    return true
end
---@param player_object Server_Player
check_funcs.eternalBP = function(player_object, product_id, cfg_id)
    if not player_object.eternal_cmp then
        return false
    end
    if player_object.eternal_cmp.gift_player then
        local p = player_object.eternal_cmp.gift_player
        ---@type Server_Player
        local obj = inst_manager:FindObject(p)
        if not (obj and obj.IsExist and obj:IsExist()) then
            return false
        end
        if not (obj and obj.main_inst and obj.main_inst.Parent) then
            return false
        end
        
        local data = obj.save_data:GetData('pay').__real.pay_list
        if data[cfg_id] then
            return false
        end

        return true
    end
    local pay_list = player_object.save_data:GetData('pay').__real.pay_list
    if pay_list[cfg_id] then
        return false
    end
    return true
end
---@param player_object Server_Player
check_funcs.eternalCoins = function(player_object, product_id, cfg_id)
    if not player_object.eternal_cmp then
        return false
    end
    if player_object.eternal_cmp.gift_player then
        local p = player_object.eternal_cmp.gift_player
        ---@type Server_Player
        local obj = inst_manager:FindObject(p)
        if not (obj and obj.IsExist and obj:IsExist()) then
            return false
        end
        if not (obj and obj.main_inst and obj.main_inst.Parent) then
            return false
        end
        
        local data = obj.save_data:GetData('pay').__real.pay_list
        if data[cfg_id] then
            return false
        end

        return true
    end
    local pay_list = player_object.save_data:GetData('pay').__real.pay_list
    if pay_list[cfg_id] then
        return false
    end
    return true
end
---@param player_object Server_Player
check_funcs.refreshtask = function(player_object, product_id, cfg_id)
    return true
end
---@param player_object Server_Player
check_funcs.scroll = function(player_object, product_id, cfg_id)
    return true
end
---@param player_object Server_Player
check_funcs.halloweenPack = function(player_object, product_id, cfg_id)
    if player_object.shop_cmp and player_object.shop_cmp.giftPlayer then
        ---@type Server_Player
        local p = player_object.shop_cmp.giftPlayer
        local obj = inst_manager:FindObject(p)
        if not (obj and obj.IsExist and obj:IsExist()) then
            return false
        end
        if not (obj and obj.main_inst and obj.main_inst.Parent) then
            return false
        end
        return true
    end
    local pay_list = player_object.save_data:GetData('pay').__real.pay_list
    if pay_list[cfg_id] then
        return false
    end
    return true
end
---@param player_object Server_Player
check_funcs.gems = function(player_object, product_id, cfg_id)
    return true
end
---@param player_object Server_Player
check_funcs.chainsawPack = function(player_object, product_id, cfg_id)
    if player_object.shop_cmp and player_object.shop_cmp.giftPlayer then
        ---@type Server_Player
        local p = player_object.shop_cmp.giftPlayer
        ---@type Server_Player
        local obj = inst_manager:FindObject(p)
        if not (obj and obj.IsExist and obj:IsExist()) then
            return false
        end
        if not (obj and obj.main_inst and obj.main_inst.Parent) then
            return false
        end
        
        local data = obj.save_data:GetData('pay').__real.pay_list
        if data[cfg_id] then
            return false
        end

        return true
    end
    local pay_list = player_object.save_data:GetData('pay').__real.pay_list
    if pay_list[cfg_id] then
        return false
    end
    return true
end
---@param player_object Server_Player
check_funcs.ChristmasCoins = function(player_object, product_id, cfg_id)
    return true
end
---@param player_object Server_Player
check_funcs.skillSlot = function(player_object, product_id, cfg_id)
    local pay_list = player_object.save_data:GetData('pay').__real.pay_list
    if pay_list[cfg_id] then
        return false
    end
    return true
end
---@param player_object Server_Player
check_funcs.skillBox = function(player_object, product_id, cfg_id)
    return true
end
---@param player_object Server_Player
check_funcs.mount = function(player_object, product_id, cfg_id)
    local pay_list = player_object.save_data:GetData('pay').__real.pay_list
    if pay_list[cfg_id] then
        return false
    end
    return true
end
---@param player_object Server_Player
check_funcs.luckyStone = function(player_object, product_id, cfg_id)
    return true
end
---@param player_object Server_Player
check_funcs.forgeStone = function(player_object, product_id, cfg_id)
    return true
end
---@param player_object Server_Player
check_funcs.pvpBuff = function(player_object, product_id, cfg_id)
    return true
end
---@param player_object Server_Player
check_funcs.revenge = function(player_object, product_id, cfg_id)
    return true
end
---@param player_object Server_Player
check_funcs.transfer = function(player_object, product_id, cfg_id)
    return player_object.relics_cmp:CheckTransfer(cfg_id)
end
---@param player_object Server_Player
check_funcs.recover = function(player_object, product_id, cfg_id)
    return true
end
---@param player_object Server_Player
check_funcs.relics = function(player_object, product_id, cfg_id)
    return true
end
---@param player_object Server_Player
check_funcs.skipOnline = function(player_object, product_id, cfg_id)
    return true
end

function c:InitGoods()
    for id, cfg in ipairs(goods_config) do
        local product_type = cfg.g_type
        local product_id = cfg.goods_id
        if not product_id then
            continue
        end
        local check_func = check_funcs[product_type]
        local handle = function(...)
            local re = buy_funcs[product_type](...)
            if re then
                local list = {...}
                return true
            end
        end
        assert(buy_funcs[product_type], "not handle for type " .. product_type)
        pay_manager:RegistProduct(product_id, check_func, handle, id)
    end
end

function c:InitHandleOnBuyPremium()
    pay_manager:RegistHandleOnBuyPremium(self, self.OnBuyPremium)
end
---@param player Server_Player
function c:OnBuyPremium(player)
    --玩家购买成功进行打点
    ---@type Server_ShopComponent

end
function c:dtor()
    c.super.dtor(self)
end
---@param player Server_Player
function c:BuyGoods(player, id)
    assert(id, "param id is nil")
    assert(player, "param player is nil")
    local cfg = goods_config[id]
    assert(cfg, "no cfg for goods id = " .. id)
    local product_id = cfg.goods_id
    local result, num = pay_manager:BuyProduct(player, product_id)
    return result, num
end

---@param player Server_Player
function c:BuyGamePass(player, id)
    assert(id, "param id is nil")
    assert(player, "param player is nil")
    local cfg = goods_config[id]
    assert(cfg, "no cfg for goods id = " .. id)
    local product_id = cfg.goods_id
    local result, num = pay_manager:BuyGamePass(player, product_id)
    print(result, num)
    if result then
        
    end
    return result, num
end

function c:SyncBuyGamepass(player_object, cfg_id)
    local pass_id = goods_config[cfg_id].goods_id
    BindableEvent:Fire(player_object.main_inst, pass_id)
    player_object.gamepassList = player_object.gamepassList or {}
    player_object.gamepassList[pass_id] = {
        isPurchase = false,
        back = false,
    }
    repeat wait() until player_object.gamepassList[pass_id].back
    -- print(player_object.gamepassList[pass_id])
    local isPurchase = player_object.gamepassList[pass_id].isPurchase
    player_object.gamepassList[pass_id] = nil

    if isPurchase then
        SavePurchase(player_object,goods_config[cfg_id].price)
    end

    return isPurchase
end

function_manager:SetHandle(function_list.buy_goods, function(player_object, goods_id)
    ---@type GameServer
    local server = _G.server
    ---@type Server_MallComponent
    local mall_component = server:GetComponent(hotpot.load.Server_MallComponent())
    if not mall_component then
        return false
    end
    return mall_component:BuyGoods(player_object, goods_id)
end)

function_manager:SetHandle('buy_gamepass', function(player_object, goods_id)
    ---@type GameServer
    local server = _G.server
    ---@type Server_MallComponent
    local mall_component = server:GetComponent(hotpot.load.Server_MallComponent())
    if not mall_component then
        return false
    end
    return mall_component:SyncBuyGamepass(player_object, goods_id)
end)

return c
