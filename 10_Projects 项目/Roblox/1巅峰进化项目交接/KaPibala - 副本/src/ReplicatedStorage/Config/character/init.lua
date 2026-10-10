---@class Config_character
---@field w_type number
---@field per number
---@field eff string
---@field id number
---@field hp number
---@field order number
---@field stage string
---@field icon string
---@field name string
---@field model string
---@field value number
---@field lv number
---@field delay number
---@field quality number
---@type character[]
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
