---@class GlobalDataStore:Instance @GlobalDataStore 公开 DataStoreService 用于保存和加载数据的函数
local module = {}
---@type fun(param:string):any @返回具有指定键的数据存储中的条目的值
---@param key string @识别从数据存储中检索的条目的键
---@return any @具有指定键的数据存储中的条目的值
function module:GetAsync()
end
---@type fun(param:string,param:number):any @增加特定键的值并返回增量值
---@param key string @识别从数据存储中检索的条目的键
---@param delta number @增量
---@return any @具有指定键的数据存储中的条目的值
function module:IncrementAsync()
end
---@type fun(param:string):any @从数据存储中移除指定键并返回与该键相关联的值
---@param key string @识别从数据存储中检索的条目的键
---@return any @与数据存储键相关联的值或为 nil（如果未找到该键）
function module:RemoveAsync()
end
---@type fun(param:string,param:any) @设置键的值，覆盖存储在键中的现有数据。
---@param key string @识别从数据存储中检索的条目的键
---@param value any @具有指定键的数据存储中的条目的值
function module:SetAsync()
end
---@type fun(param:string,param:function):Tuple @从数据存储中检索一个指定键值并更新为一个新的值
---@param key string @识别从数据存储中检索的条目的键。
---@param transformFunction function @一个您应当提供的函数。该函数会将旧的键值作为输入，并返回新值
---@return Tuple @具有指定键的数据存储中的条目的值
function module:UpdateAsync()
end