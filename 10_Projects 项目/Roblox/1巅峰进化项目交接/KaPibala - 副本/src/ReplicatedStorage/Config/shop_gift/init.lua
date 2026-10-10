---@class Config_shop_gift
---@field goods_id number
---@field id number
---@field price number
---@field reward table
---@field quality number
---@type shop_gift[]
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
