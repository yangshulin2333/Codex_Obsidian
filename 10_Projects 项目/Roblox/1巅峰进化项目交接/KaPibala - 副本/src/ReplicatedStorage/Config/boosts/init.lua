---@class Config_boosts
---@field time_ number
---@field per number
---@field stop number
---@field id number
---@field name string
---@field icon string
---@field desc string
---@type boosts[]
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
