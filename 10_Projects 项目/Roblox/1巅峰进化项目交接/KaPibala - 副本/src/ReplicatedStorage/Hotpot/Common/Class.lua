--[[
●该类用于申明类或者创建类实例
]]
---@class Class
local module = {}
---@type fun(param:LuaSourceContainer,param:LuaSourceContainer):Class
---@param classScript LuaSourceContainer
---@param baseClassScript LuaSourceContainer
---@return Class @用于定义类的Class,用于不继承的定义
function module.new(classScript,baseClassScript)
	---@type table
	local c = {}
	---@type BaseObject
	if baseClassScript then
		c.super = require(baseClassScript)
	end
	---@type string
	c.class = classScript.Name
	local meta = {__index = c}
	return setmetatable(c,{
		__index = c.super,
		__call = function(_,...)
			local obj = setmetatable({},meta)
			if c.ctor then
				local arg = {...}
				local r,e = xpcall(function()
					c.ctor(obj,table.unpack(arg))
				end,debug.traceback)
				if not r then
					warn(e)
				else
					return obj
				end
			end
			return obj
		end
	})
end
return module