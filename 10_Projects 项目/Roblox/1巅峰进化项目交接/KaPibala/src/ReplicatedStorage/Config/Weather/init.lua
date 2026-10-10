---@class Config_Weather
---@field hp number
---@field is_big number
---@field name string
---@field weight number
---@field id number
---@field model string
---@field icon string
---@field reward table
---@type Weather[]
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
