--!strict

-- 普通表的通用工具；不依赖 Roblox 服务，也不管理对象生命周期。
local TableUtil = {}

-- 递归复制表的键和值，返回独立副本；数字、字符串等非表值原样返回。
-- 用于存档数据隔离：修改 Get 返回的嵌套表，不会直接改变存储内部数据。
-- 不支持循环引用，不复制元表；Instance 等非表对象仍是原引用，不会被 Clone。
function TableUtil.DeepCopy(value)
	if type(value) ~= "table" then
		return value
	end

	local copy = {}
	-- pairs 同时遍历字典键和数组项；这里不依赖遍历顺序。
	for key, item in pairs(value) do
		copy[TableUtil.DeepCopy(key)] = TableUtil.DeepCopy(item)
	end

	return copy
end

return TableUtil
