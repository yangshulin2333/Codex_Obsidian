---@class RaycastResult @RaycastResult存储由WorldRoot：Raycast（）执行的成功的射线广播操作的结果。它包含下面列出的属性。
---@field Instance Instance @光线相交的BasePart或Terrain单元。
---@field Position Vector3 @相交发生的世界空间点，通常是直接在实例表面上的点。
---@field Material Material @交点处的材质。对于普通零件，这是BasePart.Material；对于地形，这可能会根据地形数据而有所不同。
---@field Normal Vector3 @相交面的法线向量。
local module = {}