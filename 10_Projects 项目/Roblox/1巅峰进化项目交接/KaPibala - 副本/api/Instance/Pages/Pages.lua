---@class Pages:Instance @一种本质上为页面表格的对象，其中每个页面都是键/值对的排序列表。 当每个页面都包含一个多项目列表时，该迭代器函数使用起来会十分方便：
---@field IsFinished boolean @当前页面是否为最后一个可用页。
local module = {}
---@type fun() @迭代到 Pages 对象的下一页（若有）。
function module:AdvanceToNextPageAsync()
end
---@type fun():table @返回当前页面中的项目。项目中的键由该对象的来源决定。
---@return table
function module:GetCurrentPage()
end