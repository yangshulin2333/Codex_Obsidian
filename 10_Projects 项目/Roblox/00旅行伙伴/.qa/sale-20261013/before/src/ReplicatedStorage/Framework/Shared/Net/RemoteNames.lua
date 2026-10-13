--!strict

-- 客户端与服务器共用的目录名、请求名；集中定义可避免两端拼写不一致。
-- 名称只是约定，不会自动创建或注册 Remote；注册工作由 NetService 完成。
local RemoteNames = {
	-- Requests 使用 RemoteFunction 等待响应；Events 使用 RemoteEvent 单向通知。
	RootFolder = "TravelBuddy_Remotes",
	ClientToServerFolder = "ClientToServer",
	ServerToClientFolder = "ServerToClient",
	RequestFolder = "Requests",
	EventFolder = "Events",

	-- 点号属于 Remote 对象名称本身，不代表 Roblox 层级，也不是资源路径分隔规则。
	FrameworkPing = "Framework.Ping",
}

return RemoteNames
