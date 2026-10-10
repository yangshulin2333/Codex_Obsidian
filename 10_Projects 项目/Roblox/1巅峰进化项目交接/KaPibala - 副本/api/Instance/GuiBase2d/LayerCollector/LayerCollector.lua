---@class LayerCollector:GuiBase2d
---@field Enabled boolean @切换LayerCollector的可见性。
---@field ResetOnSpawn boolean @控制当其关联的Player重生时此LayerCollector的行为。
---@alias ZIndexBehavior number | '0' | '1'
---@field ZIndexBehavior ZIndexBehavior @更改ZIndex在LayerCollector的所有后代上的行为方式,0=Global,ZIndex 属性将会覆盖根据层次结构深度计算的默认值。1=Sibling,ZIndex 属性将会控制 GuiObject 相对其同级的渲染顺序。
local module = {}