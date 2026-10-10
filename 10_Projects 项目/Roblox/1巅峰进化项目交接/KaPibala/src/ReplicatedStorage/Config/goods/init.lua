---@class Config_goods
---@field goods_id number
---@field g_type string
---@field isGamePass number
---@field price number
---@field desc string
---@field limit number
---@field args table
---@field id number
---@field name string
---@field icon string
---@field reward table
---@type goods[]
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
