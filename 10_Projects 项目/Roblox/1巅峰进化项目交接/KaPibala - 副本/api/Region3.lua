---@class Region3
---@field CFrame CFrame
---@field Size Vector3
Region3 = {}
---@type fun() @构建一个给定的区域,起点与终点之间的差值构成矩形(x2-x1)(y2-y1)(z2-z1)
---@param min Vector3 起始点位置
---@param max Vector3 终点负责region3的size属性
function Region3.new(min,max)
end
---@type fun():Region3 @将区膨胀至与网格对其
---@param region integer
function Region3:ExpandToGrid(region)
end

