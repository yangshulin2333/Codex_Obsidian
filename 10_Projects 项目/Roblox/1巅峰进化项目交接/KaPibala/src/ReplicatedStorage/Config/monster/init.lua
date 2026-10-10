---@class Config_monster
---@field per number
---@field eternalCoins number
---@field id number
---@field gems number
---@field hp number
---@field boss_eff string
---@field attack number
---@field is_boss number
---@field name string
---@field model string
---@field exp number
---@field wins number
---@field stage number
---@field size number
---@type monster[]
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
