---@class Config_relics_gacha
---@field character number
---@field name string
---@field weight table
---@field id number
---@field relics_id table
---@field icon string
---@field quality number
---@type relics_gacha[]
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
