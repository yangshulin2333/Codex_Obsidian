---@class Config_EternalTask
---@field num number
---@field exp number
---@field id number
---@field type_ number
---@field desc string
---@type EternalTask[]
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
