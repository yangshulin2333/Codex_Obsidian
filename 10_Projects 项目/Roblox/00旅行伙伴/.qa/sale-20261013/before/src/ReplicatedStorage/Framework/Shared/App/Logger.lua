--!strict
-- 统一日志入口：按等级和来源筛选消息，并附带调用位置，方便从 Output 定位问题。
-- Debug/Info/Warn 只输出消息；Error 会抛异常，不受日志等级过滤，也不是普通的错误日志。
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LogConfig = require(ReplicatedStorage.Module.Shared.Config.LogConfig)

local Logger = {}

-- 数值越大越重要；最低等级为 Warn 时，会过滤 Debug 和 Info。
local LEVEL_VALUES = {
	Debug = 10,
	Info = 20,
	Warn = 30,
	Error = 40,
}

-- require 后保留当前环境中的配置状态；服务器和各客户端不会共享这里的运行时修改。
local currentLevel = LogConfig.DefaultLevel or "Warn"
local scopeLevels = LogConfig.ScopeLevels or {}

-- level 是等级，scope 是来源名称，message 是消息；source/line 可选，表示脚本和行号。
-- 只返回格式化字符串，不输出；string.format 中 %s 代入文字，%d 代入整数。
local function formatMessage(level, scope, message, source, line)
	local callerSuffix = ""
	if type(source) == "string" and type(line) == "number" then
		callerSuffix = string.format(" [%s:%d]", source, line)
	end

	return string.format("[YanzoFrame_V2][%s][%s] %s%s", level, scope, message, callerSuffix)
end

-- 将等级名换算为优先级；未知配置按 Warn 处理，避免无效配置放开全部日志。
local function getLevelValue(level)
	local value = LEVEL_VALUES[level]
	if value == nil then
		return LEVEL_VALUES.Warn
	end
	return value
end

-- 返回消息是否达到输出门槛；指定来源的设置优先于全局设置。
local function shouldLog(level, scope)
	local scopeLevel = scopeLevels[scope]
	local minLevel = currentLevel

	if scopeLevel ~= nil then
		minLevel = scopeLevel
	end

	return getLevelValue(level) >= getLevelValue(minLevel)
end

-- 设置当前环境的全局最低等级，例如 Logger.SetLevel("Info")；未知等级抛异常。
-- 使用点号调用，不传 self；不会改写 LogConfig.lua 文件。
function Logger.SetLevel(level)
	if LEVEL_VALUES[level] == nil then
		error("Unknown log level: " .. tostring(level), 2)
	end

	currentLevel = level
end

-- 单独设置某个来源的门槛，例如 ("NetService", "Debug")；其他来源保持原设置。
function Logger.SetScopeLevel(scope, level)
	if LEVEL_VALUES[level] == nil then
		error("Unknown log level: " .. tostring(level), 2)
	end

	scopeLevels[scope] = level
end

-- 返回 boolean（布尔值）；可先判断，再计算耗时的调试文字。未知等级返回 false。
function Logger.IsEnabled(level, scope)
	if LEVEL_VALUES[level] == nil then
		return false
	end

	return shouldLog(level, scope)
end

-- 输出详细调试消息；被过滤时直接返回，不再读取调用栈或格式化文字。
function Logger.Debug(scope, message)
	if not shouldLog("Debug", scope) then
		return
	end

	-- debug.info 的 "sl" 分别取来源和行号；第 2 层指向调用 Logger.Debug 的代码。
	local source, line = debug.info(2, "sl")
	print(formatMessage("Debug", scope, message, source, line))
end

-- 输出正常流程信息，例如模块完成启动；没有返回值。
function Logger.Info(scope, message)
	if not shouldLog("Info", scope) then
		return
	end

	-- 第 2 层是调用 Logger.Info 的业务代码；第 1 层仍会指向 Logger 自己。
	local source, line = debug.info(2, "sl")
	print(formatMessage("Info", scope, message, source, line))
end

-- 通过 Roblox warn 输出警告；不会像 error 那样主动中断当前调用。
function Logger.Warn(scope, message)
	if not shouldLog("Warn", scope) then
		return
	end

	-- 第 2 层是调用 Logger.Warn 的业务代码；第 1 层仍会指向 Logger 自己。
	local source, line = debug.info(2, "sl")
	warn(formatMessage("Warn", scope, message, source, line))
end

-- 抛出异常并中断当前调用，除非外层使用 pcall 捕获；始终执行，不检查日志门槛。
function Logger.Error(scope, message)
	-- error 的第 2 个参数为调用层级；2 将报错位置指向 Logger.Error 的调用方。
	error(formatMessage("Error", scope, message), 2)
end

return Logger
