---@class Tool:BackpackItem @Tool（工具）是可被 Humanoid 装备的对象（例如武器等）。对玩家来说，工具储存在 Player 对象的子项 Backpack 对象中。在游戏里，玩家可以有多件工具，显示为屏幕下方的图标。装备一件工具会将其从 Backpack（背包）移动到玩家在 Workspace 中的 Character|Character（角色）模型。在默认情况下，工具拿在右手并有一个握柄，也就是工具中一个名为 “Handle” 的部件（当 Tool.RequiresHandle 关闭时则不需要）。（重新）生成的玩家自带的工具应置于 StarterPack 中
---@field CanBeDropped boolean @控制玩家可否丢弃工具
---@field Enabled boolean @决定工具能否被使用
---@field Grip CFrame @将 Tool 的 Grip 属性存储为单个的 CFrame
---@field GripForward Vector3 @指定工具在角色手中的方向的属性之一。这代表了 Grip（手柄）CFrame 的旋转矩阵的 R02、R12 和 R22 值
---@field GripPos Vector3 @Tool（工具）接合矩阵的位置偏移
---@field GripRight Vector3 @指定工具在角色手中的方向的属性之一。这代表了 Grip（手柄）CFrame 的旋转矩阵的 R00、R10 和 R20 值
---@field GripUp Vector3 @指定工具在角色手中的方向的属性之一。这代表了 Grip（手柄）CFrame 的旋转矩阵的 R01、R11 和 R21 值
---@field ManualActivationOnly boolean @ManualActivationOnly 属性控制 Tool（工具）能否在未执行 Tool:Activate 的情况下被激活
---@field RequiresHandle boolean @决定工具能否在没有握柄的情况下使用
---@field ToolTip string @控制玩家鼠标悬停在背包中的工具上时显示的信息
---@field Activated RBXScriptSignal @玩家装备工具点击时触发
---@field Deactivated RBXScriptSignal @当鼠标左键松开时触发。
---@field Equipped RBXScriptSignal @工具被装备时触发
---@field Unequipped RBXScriptSignal @工具被卸下时触发
local module = {}
---@type fun() @模拟工具上的点击
function module:Activate()
end
---@type fun() @模拟工具的停用

function module:Deactivate()
end