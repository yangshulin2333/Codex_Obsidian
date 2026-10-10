---@class Config_playerLv
---@field id number
---@field reward number
---@field icon string
---@field exp number
---@type playerLv[]
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
