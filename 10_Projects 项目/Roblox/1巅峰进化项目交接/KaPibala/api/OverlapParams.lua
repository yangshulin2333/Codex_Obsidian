---@class OverlapParams
---@field FilterDescendantsInst Instance[] @其后代用于筛选候选项的对象数组。
---@field FilterType string | " Enum.RaycastFilterType.Blacklist" | " Enum.RaycastFilterType.Whitelist" @确定如何使用“筛选器子体实例”列表。
---@field MaxParts number @查询要返回的最大部件数。默认值 为零 (0) 表示无限制。
---@field CollisionGroup string @指定操作的冲突组。碰撞组中的零件 设置为不与此组冲突的将被忽略。如果这个 属性被省略，操作假定默认冲突 群。
---@field RespectCanCollide boolean @此属性(如果为 true)使边界查询操作使用 在确定零件是否为 包含在空间查询结果数组中。
OverlapParams = {}
---@type fun():OverlapParams
---@return OverlapParams
function OverlapParams.new()
end