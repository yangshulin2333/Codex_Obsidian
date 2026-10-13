--!strict

-- 框架通用服务的显式清单；具体游戏服务放 GameServiceList，避免污染可复用底座。
-- 列表顺序同时用于 Init 与 Start；Net 在前，后面的服务才能在 Start 中注册请求。
local ServerRoot = script.Parent.Parent.Parent
local FrameworkServices = ServerRoot.Framework.Services

-- require 返回服务表；服务必须有唯一 Name，此处不直接调用服务方法。
return {
	require(FrameworkServices.NetService),
	require(FrameworkServices.ResourceService),
	require(FrameworkServices.StorageService),
}
