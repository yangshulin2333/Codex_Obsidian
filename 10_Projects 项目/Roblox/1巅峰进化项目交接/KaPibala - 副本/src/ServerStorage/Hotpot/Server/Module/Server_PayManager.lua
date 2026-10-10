local PRODUCT_NAME_FORMAT = "%s_%s"
local os = os
local _G = _G
local assert = assert
local game = game
local table = table
local xpcall = xpcall
local debug = debug
local warn = warn
local pcall = pcall
local print = print
local Enum = Enum
local string = string
local script = script
local coroutine = coroutine
local pairs = pairs
local error = error
local wait = wait
---@type MarketplaceService
local MarketplaceService = game:GetService("MarketplaceService")
---@type Players
local Players = game:GetService("Players")
local hotpot = _G.ServerHotpot
local hotpot_enum = hotpot.load.HotpotEnum()
local function_list = hotpot.function_list
local function_manager = hotpot.function_manager
local event_list = hotpot.event_list
local event_manger = hotpot.event_manager
local inst_manager = hotpot.load.InstanceManager()
local data_base = hotpot.load.DataBaseManager()
data_base:CreateDataBase(hotpot_enum.data_base.product_failed)
local handles = {}
local product_paying = {}
local premium_paying = {}
local game_pass_paying = {}
local on_premium_payed_handle = {}
local pay_action_mark = {}
---@class Server_PayManager
local c = hotpot.class.new(script)
-- 注册回调
MarketplaceService.ProcessReceipt = function(receipt_info)
    local product_id = receipt_info.ProductId
    local user_id = receipt_info.PlayerId
    local player_inst = Players:GetPlayerByUserId(user_id)
    local result, err = true
    if not player_inst then
        result = false
    else
        local player_object = inst_manager:FindObject(player_inst)
        if not player_object then
            result = false
        else
            local handle_info = handles[product_id]
            local check = handle_info.check
            local handle = handle_info.handle
            local args = handle_info.args
            if check and not check(player_object, product_id, table.unpack(args)) then
                result = false
            else
                local r, e = xpcall(handle, debug.traceback, player_object, product_id, table.unpack(args))
                if not r then
                    warn(e)
                    result = false, "registed handle error id " .. product_id
                end
            end
        end
    end
    if not result then
        c:AddProductFailedInfo(user_id, product_id)
    else
        c:DelProductFailedInfo(user_id, product_id)
    end
    local pay_info = product_paying[user_id]
    if pay_info then
        pay_info.receipt = result
    end
    pcall(function()
         _G.GameAnalytics:ProcessReceiptCallback(receipt_info)
    end)
    return Enum.ProductPurchaseDecision.PurchaseGranted
end
MarketplaceService.PromptProductPurchaseFinished:Connect(function(user_id, product_id, result)
    local pay_info = product_paying[user_id]
    product_paying[user_id] = nil
    if not pay_info then
        warn("no pay info for user id = " .. user_id .. ",product id = " .. product_id)
        return
    end
    pay_info.result = result
    coroutine.resume(pay_info.co, pay_info.receipt and pay_info.result)
end)
function c:CheckProductFailedInfo(user_id, product_id)
    assert(user_id, "param user id is nil")
    assert(product_id, "parm product id is nil")
    local key = string.format(PRODUCT_NAME_FORMAT, user_id, product_id)
    local r, e = data_base:Load(hotpot_enum.data_base.product_failed, key)
    print(r, e)
    if not r then
        error(e)
    end
    return e
end
function c:AddProductFailedInfo(user_id, product_id)
    local data_name = string.format(PRODUCT_NAME_FORMAT, user_id, product_id)
    data_base:Save(hotpot_enum.data_base.product_failed, data_name, function()
        return 1
    end)
end
function c:DelProductFailedInfo(user_id, product_id)
    local data_name = string.format(PRODUCT_NAME_FORMAT, user_id, product_id)
    data_base:Save(hotpot_enum.data_base.product_failed, data_name, function()
        print("del history")
        return
    end)
end
---@param player_object Server_Player
---@param product_id number
function c:DeliverProduct(player_object, product_id)
    if not player_object:IsExist() then
        local log = "player object is not exist"
        warn(log)
        return false, log
    end
    if not player_object.main_inst then
        local log = "player object lost main instance"
        warn(log)
        return false, log
    end
    -- 再次检查是否可进行购买
    local handle_info = handles[product_id]
    local check_func = handle_info.check
    local args = handle_info.args
    local user_id = player_object:GetUserId()
    local handle = handle_info.handle
    if check_func and not check_func(player_object, product_id, table.unpack(args)) then
        local log = "user id = " .. user_id .. " can't buy product id = " .. product_id .. " with check function"
        warn(log)
        return false, log
    end
    -- 进行交货
    local r, e, log = xpcall(handle, debug.traceback, player_object, product_id, table.unpack(args))
    if not r then
        warn(e)
        return false, e
    end
    return e, log
end
function c:RegistProduct(product_id, check_func, handle, ...)
    local handle_info = {
        check = check_func,
        handle = handle,
        args = {...}
    }
    handles[product_id] = handle_info
end
---@param player_object Server_Player
function c:BuyProduct(player_object, product_id)
    assert(player_object, "param player object is nil")
    assert(player_object.main_inst, "player object main instance is lost")
    assert(product_id, "param product id is nil")
    assert(player_object:IsA("Server_PlayerObject", "object must be a server player object"))
    local user_id = player_object:GetUserId()
    -- 进行检查，如果不符合购买条件则不进行购买
    local handle_info = handles[product_id]
    assert(handle_info, "not regist product handle")
    ---@type Server_PayLogComponent
    local pay_log = player_object:GetComponent(hotpot.load.Server_PayLogComponent())
    local log
    if pay_action_mark[player_object] then
        log = "in pay action"
        pay_log:AddLog("buy_product",false,{
            id = product_id,
            log = log
        })
        return false, log
    end
    pay_action_mark[player_object] = "product"
    if handle_info.check and not handle_info.check(player_object, product_id, table.unpack(handle_info.args)) then
        log = "user id = " .. user_id .. " can't buy product id = " .. product_id
        warn(log)
        pay_action_mark[player_object] = nil
        pay_log:AddLog("buy_product",false,{
            id = product_id,
            log = log
        })
        return false, log
    end
    if product_paying[user_id] then
        log = "user id = " .. user_id .. " is product_paying,retry later"
        warn(log)
        pay_action_mark[player_object] = nil
        pay_log:AddLog("buy_product",false,{
            id = product_id,
            log = log
        })
        return false,log
    end
    local check_r, check_e = xpcall(self.CheckProductFailedInfo, debug.traceback, self, user_id, product_id)
    if not check_r then
        log = "data base error" .. check_e
        warn(log)
        pay_action_mark[player_object] = nil
        pay_log:AddLog("buy_product",false,{
            id = product_id,
            log = log
        })
        return false,log
    end
    if check_e then
        ---先检查是否有失败
        local r, e = self:DeliverProduct(player_object, product_id)
        if not r then
            log = e
            warn(log)
            self:AddProductFailedInfo(user_id, product_id)
            pay_action_mark[player_object] = nil
            pay_log:AddLog("deliver_product",false,{
                id = product_id,
                log = log
            })
            return r,log
        else
            self:DelProductFailedInfo(user_id, product_id)
            pay_action_mark[player_object] = nil
            pay_log:AddLog("deliver_product",true,{
                id = product_id,
                log = log
            })
            return true
        end
    else
        -- 发起购买
        local r, e = xpcall(MarketplaceService.PromptProductPurchase, debug.traceback, MarketplaceService,
            player_object.main_inst, product_id)
        if not r then
            log = e
            warn(log)
            pay_action_mark[player_object] = nil
            pay_log:AddLog("buy_product",false,{
                id = product_id,
                log = log
            })
            return false,log
        end
        local now_co = coroutine.running()
        product_paying[user_id] = {
            co = now_co,
            id = product_id
        }
        -- 挂起当前协程，等待付费结果
        local result = coroutine.yield()
        wait()
        pay_action_mark[player_object] = nil
        if result then
            pay_log:AddLog("buy_product",true,{
                id = product_id,
            })
        else
            pay_log:AddLog("buy_product",false,{
                id = product_id,
                log = "cancel"
            })
        end
        -- pay_log:AddLog("product",result,{
        --     product_id = product_id
        -- })
        return result
    end
    pay_action_mark[player_object] = nil
end
function c:BuyGamePass(player_object, game_pass_id)
    ---先检查是否有失败
end
function c:GetProductInfo(id)
    return MarketplaceService:GetProductInfo(id, Enum.InfoType.Product)
end
function c:GetAllProductInfo()
    ---@type Pages
    local pages = MarketplaceService:GetDeveloperProductsAsync()
    local products = {}
    while true do
        local page = pages:GetCurrentPage()
        for idx, info in pairs(page) do
            local product_id = info.ProductId
            products[product_id] = info
        end
        if pages.IsFinished then
            break
        else
            pages:AdvanceToNextPageAsync()
        end
    end
    return products
end
function c:RegistHandleOnBuyPremium(object, handle)
    assert(object, "param object is nil")
    assert(handle, "param handle is nil")
    on_premium_payed_handle[handle] = object
end
---@param player_object Server_Player
function c:BuyPremium(player_object)
    assert(player_object, "param player object is nil")
    assert(player_object.main_inst, "player object main instance is lost")
    assert(player_object:IsA("Server_PlayerObject", "object must be a server player object"))
    ---@type Server_PayLogComponent
    local pay_log = player_object:GetComponent(hotpot.load.Server_PayLogComponent())
    if pay_action_mark[player_object] then
        return false, "in pay action"
    end
    pay_action_mark[player_object] = "premium"
    local user_id = player_object:GetUserId()
    if premium_paying[user_id] then
        local log = "is paying for premium"
        warn(log)
        pay_action_mark[player_object] = nil
        pay_log:AddLog("buy_premium",false,{
            log = log,
        })
        return false,log
    end
    if player_object:IsPremium() then
        local log = "already premium"
        warn(log)
        pay_action_mark[player_object] = nil
        pay_log:AddLog("buy_premium",false,{
            log = log,
        })
        return false,log
    end
    MarketplaceService:PromptPremiumPurchase(player_object.main_inst)
    premium_paying[user_id] = coroutine.running()
    local result = coroutine.yield()
    if result then
        for handle, object in pairs(on_premium_payed_handle) do
            handle(object, player_object)
        end
    end
    wait()
    pay_action_mark[player_object] = nil
    if result then
        pay_log:AddLog("buy_premium",true)
    else
        pay_log:AddLog("buy_premium",false,{
            log = "cancel"
        })
    end
    pay_log:AddLog("premium",result)
    return result
end
function c:DelPayingInfo(user_id)
    product_paying[user_id] = nil
    premium_paying[user_id] = nil
end
event_manger:RegistHandle(event_list.premium_purchase, function(player_object, result)
    local user_id = player_object:GetUserId()
    local count = 0
    while not player_object:IsPremium() do
        count = count + wait()
        if count >= 1 then
            break
        end
    end
    local result = player_object:IsPremium()
    local co = premium_paying[user_id]
    premium_paying[user_id] = nil
    if co then
        coroutine.resume(co, result)
    end
end)
function_manager:SetHandle(function_list.buy_product, function(player, id)
    return c:BuyProduct(player, id)
end)
function_manager:SetHandle(function_list.buy_premium, function(player)
    return c:BuyPremium(player)
end)
return c
