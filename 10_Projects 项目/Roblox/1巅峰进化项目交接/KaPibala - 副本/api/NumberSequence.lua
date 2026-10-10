---@class NumberSequence @数字序列表示从 0 到 1 的一系列数字值。数字值使用数字序列键点类型表示。此类型用于粒子微器的属性，以指示粒子在其生存期内的属性。在 Studio 中，使用线图编辑此数据类型
---@field Keypoints table @一个包含完整合法的NumberSequenceKeypoint的数组
NumberSequence = {}
---@param NumberSequenceKeypointList table<number,NumberSequenceKeypoint>
function NumberSequence.new(NumberSequenceKeypointList)
end