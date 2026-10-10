---@class Config_relics
---@field w_type number
---@field score number
---@field eff string
---@field id number
---@field delay number
---@field suit number
---@field icon string
---@field MaxHp number
---@field DMG number
---@field name string
---@field model string
---@field Speed number
---@field EXP number
---@field type_ number
---@field quality number
---@type relics[]
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
