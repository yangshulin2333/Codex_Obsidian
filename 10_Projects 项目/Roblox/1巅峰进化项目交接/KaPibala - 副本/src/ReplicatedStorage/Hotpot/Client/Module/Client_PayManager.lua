local _G = _G
local script = script
---@type MarketplaceService
local MarketplaceService = game:GetService("MarketplaceService")
---@type Players
local Players = game:GetService("Players")
local hotpot = _G.ClientHotpot
local inst_manager = hotpot.load.InstanceManager()
local event_list = hotpot.event_list
local event_manger = hotpot.event_manager
local function_list = hotpot.function_list
local function_manager = hotpot.function_manager
event_list.premium_purchase = true
function_list.buy_premium = true
function_list.buy_product = true
---@class Client_PayManager
local c = hotpot.class.new(script)
MarketplaceService.PromptPremiumPurchaseFinished:Connect(function()
    local player_inst = Players.LocalPlayer
    ---@type Client_Player
    local player_obj = inst_manager:FindObject(player_inst)
    if player_obj then
        event_manger:Fire(event_list.premium_purchase)
    end
end)
function c:BuyPremium()
    local player_inst = Players.LocalPlayer
    local player_object = inst_manager:FindObject(player_inst)
    if not player_object then
        return false
    end
    assert(player_object.main_inst,"player object main instance is lost")
    assert(player_object:IsA("Client_PlayerObject","object must be a client player object"))
    if player_object:IsPremium() then
        return false
    end
    return function_manager:Invoke(function_list.buy_premium)
end
function c:BuyProduct(product_id)
    local player_inst = Players.LocalPlayer
    local player_object = inst_manager:FindObject(player_inst)
    if not player_object then
        return false
    end
    assert(player_object.main_inst,"player object main instance is lost")
    assert(product_id,"param product id is nil")
    assert(player_object:IsA("Client_PlayerObject","object must be a client player object"))
    return function_manager:Invoke(function_list.buy_product,product_id)
end
function c:GetProductInfo(id)
    return MarketplaceService:GetProductInfo(id,Enum.InfoType.Product)
end
function c:GetAllProductInfo()
    ---@type Pages
    local pages = MarketplaceService:GetDeveloperProductsAsync()
    local products = {}
    while true do
        local page = pages:GetCurrentPage()
        for idx,info in pairs(page) do
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
return c