--!strict

-- Service 与 Controller 共用的清单、结构检查与错误格式；不负责注册或执行生命周期。
local Lifecycle = {}

-- 在 ipairs 合并前检查原始清单；固定成员和顺序，模块表仍由调用方维护。
function Lifecycle.CopyList(modules, owner)
	if type(modules) ~= "table" then
		error(owner .. " must be a dense array", 3)
	end

	local count = 0
	for key in next, modules do
		if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then
			error(owner .. " must contain only positive integer keys", 3)
		end
		count += 1
	end

	local snapshot = {}
	for index = 1, count do
		local module = rawget(modules, index)
		if module == nil then
			error(owner .. " must be a dense array; missing index " .. tostring(index), 3)
		end
		snapshot[index] = module
	end
	return snapshot
end

-- 从 xpcall 的错误处理函数调用；错误对象无法转成文字时仍保留阶段、模块和调用栈。
function Lifecycle.FormatError(owner, phase, moduleName, problem)
	local ok, description = pcall(tostring, problem)
	if not ok then
		description = "unprintable " .. type(problem) .. " error"
	end
	local moduleInfo = if type(moduleName) == "string" then " in module " .. moduleName else ""
	return debug.traceback(owner .. ":" .. phase .. "() failed" .. moduleInfo .. ": " .. description, 3)
end

-- 检查 module 是否为带 Name 的表；owner 是报错时显示的类别，例如 "Service"。
-- Assert 表示断言：符合规则时无返回值，不符合时抛异常；不要求必须同时提供 Init 和 Start。
function Lifecycle.AssertModule(module, owner)
	if type(module) ~= "table" then
		-- 第 3 层通常是调用 Registry:Init 的入口，便于定位谁启动了不合法的模块。
		error(owner .. " 必须返回一个表", 3)
	end

	-- Name 用作注册表的索引；这里只检查非空字符串，重名由各 Registry 处理。
	if type(module.Name) ~= "string" or module.Name == "" then
		error(owner .. "这个模块没有提供有效的 Name。", 3)
	end

	-- nil 表示未提供该阶段；存在但不是函数时，后续调用必然失败，因此提前报错。
	if module.Init ~= nil and type(module.Init) ~= "function" then
		error(owner .. " module " .. module.Name .. " 有一个不是函数的 Init", 3)
	end
	-- Start 同样可省略；只有初始化工作的模块也可以合法注册。
	if module.Start ~= nil and type(module.Start) ~= "function" then
		error(owner .. " module " .. module.Name .. " 有一个不是函数的 Start", 3)
	end
end

return Lifecycle
