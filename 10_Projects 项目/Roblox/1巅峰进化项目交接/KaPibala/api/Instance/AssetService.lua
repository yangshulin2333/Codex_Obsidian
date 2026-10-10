---@class AssetService:Instance
local module = {}
---@type fun(placeName:string,templatePlaceID:number,description:string):number @description
---@param placeName string
---@param templatePlaceID number
---@param description string
---@return number
function module:CreatePlaceAsync(placeName,templatePlaceID,description)
end
---@type fun(player:Player,placeName:string,templatePlaceID:number,description:string):number @用placeID克隆一个与给定 templatePlaceID 相同的场景并将其放入给定玩家的物品栏中。
---@param player Player
---@param placeName string
---@param templatePlaceID number
---@param description string
---@return number
function module:CreatePlaceInPlayerInventoryAsync( player , placeName , templatePlaceID ,description)
end
---@type fun(packageAssetId:number):table @返回一个包含在指定包中的 assetIds 数组。
---@param packageAssetId number
---@return table
function module:GetAssetIdsForPackage(packageAssetId)
end
---@type fun(bundleId:number):table @返回指定捆绑包内容的详细信息
---@param bundleId number
---@return table
function module:GetBundleDetailsAsync(bundleId)
end
---@type fun():StandardPages @返回 StandardPages 对象，该对象包含当前“游戏”（也称为“宇宙”）中场景的名称和 placeId。
---@return StandardPages
function module:GetGamePlacesAsync()
end
---@type fun() @保存当前场景的状态。
function module:SavePlaceAsync()
end