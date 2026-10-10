---@class Config_EternalShop
---@field id number
---@field layout number
---@field price number
---@field reward table
---@type EternalShop[]
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
