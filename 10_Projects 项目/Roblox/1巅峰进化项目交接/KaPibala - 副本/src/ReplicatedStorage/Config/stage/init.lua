---@class Config_stage
---@field egg_id number
---@field name string
---@field model string
---@field id number
---@field need number
---@field icon string
---@type stage[]
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
