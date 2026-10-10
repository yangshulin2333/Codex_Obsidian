---@class Config_forgeCost
---@field per number
---@field gold number
---@field id number
---@field forgeStone number
---@field big number
---@type forgeCost[]
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
