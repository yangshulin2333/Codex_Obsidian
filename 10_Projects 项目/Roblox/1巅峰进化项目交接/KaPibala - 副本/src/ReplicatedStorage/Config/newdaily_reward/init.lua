---@class Config_newdaily_reward
---@field id number
---@field quality number
---@field reward table
---@type newdaily_reward[]
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
