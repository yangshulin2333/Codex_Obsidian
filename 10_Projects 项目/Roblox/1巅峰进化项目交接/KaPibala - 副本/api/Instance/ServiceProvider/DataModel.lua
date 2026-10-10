---@class DataModel:ServiceProvider @返回具有所请求类名的服务，如果该服务不存在，则创建该服务。
---@field CreatorId number @描述拥有场景的用户或组的 ID
---@field CreatorType CreatorType @描述场景的 CreatorType，该场景是属于用户还是属于某个群组
---@field GameId number @描述在服务器上运行的场景所属的游戏的 ID
local module = {}