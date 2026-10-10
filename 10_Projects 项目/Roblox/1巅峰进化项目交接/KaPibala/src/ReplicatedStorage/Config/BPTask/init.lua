---@class Config_BPTask
---@field id number
---@field num number
---@field desc string
---@field exp number
---@type BPTask[]
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
