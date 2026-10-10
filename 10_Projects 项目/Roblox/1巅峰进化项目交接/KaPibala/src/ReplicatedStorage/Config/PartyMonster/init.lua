---@class Config_PartyMonster
---@field per number
---@field exp number
---@field id number
---@field gems number
---@field hp number
---@field boss_eff string
---@field name string
---@field model string
---@field is_boss number
---@field wins number
---@field attack number
---@type PartyMonster[]
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
