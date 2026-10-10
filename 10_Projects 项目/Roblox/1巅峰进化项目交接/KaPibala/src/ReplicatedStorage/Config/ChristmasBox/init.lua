---@class Config_ChristmasBox
---@field id number
---@field reward string
---@field name string
---@field weight number
---@type ChristmasBox[]
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
