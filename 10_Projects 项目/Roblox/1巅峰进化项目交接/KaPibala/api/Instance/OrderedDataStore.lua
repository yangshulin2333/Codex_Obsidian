---@class OrderedDataStore:GlobalDataStore @OrderedDataStore 本质上是一个 GlobalDataStore，只是存储的值必须是正整数。它公开方法GetSortedAsync()，该方法允许开发者使用 DataStorePages 对象按排序顺序检查条目。
local module = {}
---@type fun(param:boolean,param:number,param:any,param:any):DataStorePages @一个基于提供参数已排序好的 DataStorePages 对象
---@param isAscending boolean @一个表示返回的数据页是否按升序排列的布尔值
---@param pageSize number @每页的长度
---@param minValue any @可选参数。如果设置，数据页小于 minValue 的会被排除。
---@param maxValue any @可选参数。如果设置，数据页大于 maxValue 的会被排除。
---@return DataStorePages @一个基于提供参数已排序好的 DataStorePages 对象。
function module:GetSortedAsync()
end