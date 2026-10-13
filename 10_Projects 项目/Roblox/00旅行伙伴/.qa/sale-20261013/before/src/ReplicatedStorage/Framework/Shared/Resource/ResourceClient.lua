--!strict

-- 客户端资源入口：固定读取 ReplicatedStorage.Game.Resources，不通过 Remote 请求服务器资源。
-- Get/Clone 成功返回对象；显式处理的失败返回 nil, errorCode, failure。
-- 资源应已复制到客户端；这里不等待资源出现，也不缓存查找结果，缺失时本次调用立即返回失败。

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Logger = require(ReplicatedStorage.Framework.Shared.App.Logger)
local ResourceResolver = require(ReplicatedStorage.Framework.Shared.Resource.ResourceResolver)
local ResourceCloner = require(ReplicatedStorage.Framework.Shared.Resource.ResourceCloner)

local ResourceClient = {}

-- 将错误详情格式化后输出警告。
local function warnFailure(failure)
	Logger.Warn("ResourceClient", ResourceResolver.FormatFailure(failure))
end

-- 逐层定位 Game.Resources 并检查重名；resourcePath 仅用于错误详情。
local function getSharedRoot(resourcePath)
	local gameFolder, gameError, gameFailure =
		ResourceResolver.FindUniqueChild(ReplicatedStorage, "Game", "Shared", resourcePath, "RESOURCE_ROOT_MISSING")
	if gameFolder == nil then
		return nil, gameError, gameFailure
	end

	local resources, resourcesError, resourcesFailure =
		ResourceResolver.FindUniqueChild(gameFolder, "Resources", "Shared", resourcePath, "RESOURCE_ROOT_MISSING")
	if resources == nil then
		return nil, resourcesError, resourcesFailure
	end

	if not resources:IsA("Folder") then
		local failure =
			ResourceResolver.NewFailure("RESOURCE_ROOT_MISSING", "Shared", resourcePath, "Resources", gameFolder)
		return nil, "RESOURCE_ROOT_MISSING", failure
	end

	return resources, nil, nil
end

-- 返回原版模板，例如 "Demo.Cube" 对应 Resources/Demo/Cube；调用方应视为只读。
-- 冒号调用示例 ResourceClient:Get("Demo.Cube")；移动或重命名资源会使相对路径失效。
function ResourceClient:Get(resourcePath)
	local root, rootError, rootFailure = getSharedRoot(resourcePath)
	if root == nil then
		warnFailure(rootFailure)
		return nil, rootError, rootFailure
	end

	local template, resolveError, resolveFailure = ResourceResolver.Resolve(root, "Shared", resourcePath)
	if template == nil then
		warnFailure(resolveFailure)
		return nil, resolveError, resolveFailure
	end

	return template, nil, nil
end

-- 复制模板到 parent 下；parent 必须是 Instance，不能传路径字符串。
-- 整树完整复制；位置、销毁和事件解绑由调用方负责，原生 Clone/Parent 异常仍抛出。
function ResourceClient:Clone(resourcePath, parent)
	if typeof(parent) ~= "Instance" then
		local failure = ResourceResolver.NewFailure("INVALID_PARENT", "Shared", resourcePath, "<parent>", parent)
		warnFailure(failure)
		return nil, "INVALID_PARENT", failure
	end

	-- 复用本模块的 Get；冒号调用会自动传入 self。
	local template, getError, getFailure = self:Get(resourcePath)
	if template == nil then
		-- Get 已输出警告，这里只返回错误，避免重复日志。
		return nil, getError, getFailure
	end

	local clone, cloneError, cloneFailure = ResourceCloner.Clone(template, "Shared", resourcePath, parent)
	if clone == nil then
		warnFailure(cloneFailure)
		return nil, cloneError, cloneFailure
	end
	return clone, nil, nil
end

return ResourceClient
