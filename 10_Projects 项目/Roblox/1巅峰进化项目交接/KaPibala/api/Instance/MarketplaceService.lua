
---@class MarketplaceService @用于支付 
---@field PromptProductPurchaseFinished RBXScriptSignal
---@field PromptGamePassPurchaseFinished RBXScriptSignal
local module = {}

---@type function @客户端调用支付函数
---@param player Player @购买产品的玩家
---@param productId int @产品的ID
function module:PromptProductPurchase(player,productId)
end

---@type function @检查玩家是否购买通行证
---@param uid number @玩家uid
---@param game_pass_id number @通行证id
function module:UserOwnsGamePassAsync(uid,game_pass_id)
end

---@type function @调用支付通行证函数
---@param player Player @购买通行证的玩家
---@param game_pass_id number @通行证的id
function module:PromptGamePassPurchase(player,game_pass_id)
end

return module