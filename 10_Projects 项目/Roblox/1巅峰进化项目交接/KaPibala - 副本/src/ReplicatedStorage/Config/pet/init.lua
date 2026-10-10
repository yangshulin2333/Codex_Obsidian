---@class Config_pet
---@field value_per number
---@field name string
---@field model string
---@field value number
---@field id number
---@field icon string
---@field quality number
---@type pet[]
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
