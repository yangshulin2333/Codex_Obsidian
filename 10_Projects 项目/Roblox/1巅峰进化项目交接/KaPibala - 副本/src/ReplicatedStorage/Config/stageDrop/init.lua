---@class Config_stageDrop
---@field boss_id table
---@field per table
---@field relics_id table
---@field id number
---@field boss_per table
---@type stageDrop[]
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
