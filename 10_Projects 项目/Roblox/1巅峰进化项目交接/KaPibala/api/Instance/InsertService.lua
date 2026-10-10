---@class InsertService:Instance
---@field AllowClientInsertModels boolean
local module = {}
---@type fun(meshId:number,collisionFidelity:CollisionFidelity,renderFidelity:RenderFidelity)
---@param meshId number
---@param collisionFidelity CollisionFidelity
---@param renderFidelity RenderFidelity
---@return Instance
function module:CreateMeshPartAsync(meshId , collisionFidelity ,renderFidelity)
end
---@type fun():table @返回字典数组，其中包含有关各种Roblox批准的集合的信息
---@return table
function module:GetBaseSets()
end
---@type fun(categoryId:number):table @返回指定类别中最新上传的模型。
---@param categoryId number
---@return table
function module:GetCollection(categoryId)
end
---@type fun(serachText:string,pageNum:number):table @从目录中检索免费贴花的列表
---@param searchText string
---@param pageNum number
---@return table
function module:GetFreeDecals(searchText,pageNum)
end
---@type fun(searchText:string,pageNum:number) @从目录中检索免费模型的列表
---@param searchText string
---@param pageNum number
---@return table
function module:GetFreeModels(searchText,pageNum)
end
---@type fun(assetId:number):number @返回由场所创建者创建的资产的资产的最新AssetVersionId。 可以与LoadAssetVersion结合使用，以加载模型的最新版本，即使在游戏运行时对其进行了更新。
---@param assetId number
---@return number
function module:GetLatestAssetVersionAsync(assetId)
end
---@type fun(userId:number):table @返回字典数组，其中包含有关用户拥有的集合的信息。
---@param userId number
---@return table
function module:GetUserSets(userId)
end
---@type fun(assetId:number):Model @返回包含资产的模型
---@param assetId number
---@return Model
function module:LoadAsset(assetId)
end
---@type fun(assetVersionId:number):Model @返回插入到InsertService中的模型，该模型包含具有给定assetVersionId的资产。
---@param assetVersionId number
---@return Model
function module:LoadAssetVersion(assetVersionId)
end