---@class Config_challengeMonster
---@field boss_hp number
---@field id number
---@field m1_hp number
---@field boss_atk number
---@field m3_atk number
---@field m1_atk number
---@field m2_atk number
---@field monster_id number
---@field m3_hp number
---@field m2_hp number
---@type challengeMonster[]
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
