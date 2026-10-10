---@class Config_skillBox
---@field id number
---@field quality number
---@field reward table
---@field weight number
---@type skillBox[]
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
