---@class Config_pvpMonster
---@field id number
---@field gems table
---@field hp number
---@field boss_eff string
---@field name string
---@field gold table
---@field is_boss number
---@field model string
---@field pvpCoin table
---@type pvpMonster[]
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
