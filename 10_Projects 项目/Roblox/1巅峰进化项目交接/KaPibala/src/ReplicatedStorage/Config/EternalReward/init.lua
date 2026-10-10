---@class Config_EternalReward
---@field id number
---@field reward1 table
---@field reward2 table
---@field exp number
---@type EternalReward[]
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
