---@class Config_suit
---@field set2 table
---@field set6 table
---@field name string
---@field relics_id table
---@field max number
---@field id number
---@field set4 table
---@type suit[]
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
