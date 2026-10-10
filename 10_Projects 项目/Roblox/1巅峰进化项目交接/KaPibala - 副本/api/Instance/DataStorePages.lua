---@class DataStorePages:Instance @一种特殊类型的 Pages 对象，其页包含一个 OrderedDataStore 的键值对。在此对象中， GetCurrentPage() 返回一个表的数组，每个表都包含名为 key（键） 和 value（值） 的键，反映了键值对的数据。
---@field IsFinished boolean @当前页面是否为最后一个可用页。
local module = {}
---@type fun() @迭代到 Pages 对象的下一页（若有）。
function module:AdvanceToNextPageAsync()
end
---@type fun():table @返回当前页面中的项目。项目中的键由该对象的来源决定。
---@return table
function module:GetCurrentPage()
end