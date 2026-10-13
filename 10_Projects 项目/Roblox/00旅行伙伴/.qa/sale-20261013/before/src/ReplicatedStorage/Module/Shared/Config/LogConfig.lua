--!strict

-- Logger 加载时读取的初始配置；这里不输出日志，不会同步运行中各客户端的等级设置。
-- 默认 Warn：正常启动只显示警告和错误，避免 Roblox 输出窗口被启动流程刷屏。
-- 调试时可改成 "Info" 或 "Debug"；也可以只打开某个 scope 的日志。
-- 等级由低到高为 Debug / Info / Warn / Error；Logger.Error 始终抛异常，不受过滤控制。
local LogConfig = {
	DefaultLevel = "Warn",
	ScopeLevels = {
		-- scope 是 Logger 调用时传入的来源名；同名设置覆盖 DefaultLevel，下面取消注释即可启用。
		-- NetService = "Debug",
		-- ServiceRegistry = "Info",
	},
}

return LogConfig
