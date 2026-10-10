---@class Config_mount
---@field offset number
---@field lockCondition number
---@field order number
---@field hipHight number
---@field args string
---@field quality number
---@field id number
---@field lockNum number
---@field name string
---@field model string
---@field speed number
---@field goods_id number
---@field icon string
---@field Yoffset number
---@type mount[]
local module = {}
for __,cfg in ipairs(script:GetChildren()) do
	if cfg.ClassName == "ModuleScript" then
		local tab = require(cfg)
		for i,v in pairs(tab) do
			module[i] = v
		end
	end
end
return module
