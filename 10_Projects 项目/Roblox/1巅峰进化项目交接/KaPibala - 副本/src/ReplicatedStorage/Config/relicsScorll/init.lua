---@class Config_relicsScorll
---@field name string
---@field desc string
---@field id number
---@field quality number
---@field icon string
---@field add number
---@type relicsScorll[]
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
