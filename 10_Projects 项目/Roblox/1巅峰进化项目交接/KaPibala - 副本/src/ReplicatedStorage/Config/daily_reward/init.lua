---@class Config_daily_reward
---@field id number
---@field desc string
---@field quality number
---@field reward table
---@type daily_reward[]
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
