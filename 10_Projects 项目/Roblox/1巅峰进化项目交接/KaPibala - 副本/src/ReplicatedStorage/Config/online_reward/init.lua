---@class Config_online_reward
---@field id number
---@field times number
---@field reward table
---@type online_reward[]
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
