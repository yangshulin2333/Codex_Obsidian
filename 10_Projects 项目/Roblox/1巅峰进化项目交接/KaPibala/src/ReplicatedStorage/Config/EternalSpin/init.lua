---@class Config_EternalSpin
---@field show string
---@field weight number
---@field id number
---@field icon string
---@field reward table
---@type EternalSpin[]
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
