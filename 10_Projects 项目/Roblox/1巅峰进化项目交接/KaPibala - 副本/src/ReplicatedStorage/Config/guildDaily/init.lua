---@class Config_guildDaily
---@field guildCoin number
---@field id number
---@field reward table
---@field contribute number
---@field guildExp number
---@type guildDaily[]
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
