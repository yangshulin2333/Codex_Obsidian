---@class Config_pvpshop
---@field limit number
---@field id number
---@field price number
---@field icon string
---@field reward table
---@type pvpshop[]
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
