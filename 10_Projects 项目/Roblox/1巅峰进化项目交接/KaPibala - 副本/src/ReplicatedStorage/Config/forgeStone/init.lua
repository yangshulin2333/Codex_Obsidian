---@class Config_forgeStone
---@field name string
---@field id number
---@field desc string
---@field icon string
---@field quality number
---@type forgeStone[]
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
