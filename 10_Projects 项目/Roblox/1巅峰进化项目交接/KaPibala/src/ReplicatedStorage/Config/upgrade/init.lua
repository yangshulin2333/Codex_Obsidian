---@class Config_upgrade
---@field name string
---@field world number
---@field id number
---@field price number
---@field value number
---@field prop string
---@type upgrade[]
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
