--!strict

-- 服务器资源入口：访问 ReplicatedStorage.Game.Resources（Shared）和 ServerStorage.Game.Resources（Server）。
-- 只管理已导入 Roblox 的 Instance 模板，不下载外部文件、不预加载、不自动回收克隆对象。
-- Init 目录错误会抛异常；Get/Clone 显式处理的失败返回 nil, errorCode, failure，并输出诊断日志。
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local ResourceResolver = require(ReplicatedStorage.Framework.Shared.Resource.ResourceResolver)
local ResourceCloner = require(ReplicatedStorage.Framework.Shared.Resource.ResourceCloner)
local ResourceValidator = require(script.Parent.Parent.Resource.ResourceValidator)

local ResourceService = {
	Name = "ResourceService",
}

ResourceService._logger = nil
-- 仅缓存两份根目录引用，不缓存每个路径的查找结果；运行中不应销毁并替换根目录。
ResourceService._roots = nil

-- 从 container 逐层定位唯一的 Game/Resources，成功返回 Folder, nil，失败返回 nil, failure。
-- 不用 WaitForChild；服务器资源应在启动前已映射好，缺失时尽早暴露配置问题。
local function findResourcesRoot(container, scope)
	local gameFolder, _, gameFailure =
		ResourceResolver.FindUniqueChild(container, "Game", scope, "<root>", "RESOURCE_ROOT_MISSING")
	if gameFolder == nil then
		return nil, gameFailure
	end

	local resources, _, resourcesFailure =
		ResourceResolver.FindUniqueChild(gameFolder, "Resources", scope, "<root>", "RESOURCE_ROOT_MISSING")
	if resources == nil then
		return nil, resourcesFailure
	end

	if not resources:IsA("Folder") then
		return nil, ResourceResolver.NewFailure("RESOURCE_ROOT_MISSING", scope, "<root>", "Resources", gameFolder)
	end

	return resources, nil
end

-- 兼容旧接口的斜杠路径，例如 "Stage/Stage01" -> "Stage.Stage01"；非字符串交给解析器报错。
-- string.gsub 同时返回替换后字符串和替换次数，这里只接收字符串，避免多返回值向外泄漏。
local function convertLegacyPath(resourcePath)
	if type(resourcePath) ~= "string" then
		return resourcePath
	end

	local dottedPath = string.gsub(resourcePath, "/", ".")
	return dottedPath
end

-- 格式化错误并记录警告；尚未注入 Logger 时跳过输出，不改变调用方收到的错误结果。
function ResourceService:_warnFailure(failure)
	if self._logger ~= nil then
		self._logger.Warn(self.Name, ResourceResolver.FormatFailure(failure))
	end
end

-- 取得 Init 保存的根目录；本函数不验证 scope 名称，公开入口会先检查。未初始化直接抛异常。
function ResourceService:_getRoot(scope)
	if self._roots == nil then
		error("ResourceService 尚未初始化", 2)
	end

	return self._roots[scope]
end

-- 同时初始化客户端可见和服务器私有资源根目录；不从 Workspace 反向查找模板。
-- context 来自 ServiceRegistry；根目录缺失/重名会阻止启动，不能靠创建空文件夹掩盖错误。
function ResourceService:Init(context)
	self._logger = context.Logger

	local sharedRoot, sharedFailure = findResourcesRoot(ReplicatedStorage, "Shared")
	if sharedRoot == nil then
		error(ResourceResolver.FormatFailure(sharedFailure), 2)
	end

	local serverRoot, serverFailure = findResourcesRoot(ServerStorage, "Server")
	if serverRoot == nil then
		error(ResourceResolver.FormatFailure(serverFailure), 2)
	end

	self._roots = {
		Shared = sharedRoot,
		Server = serverRoot,
	}

	-- Studio 启动检查目录与整体模板；正式服每次 Clone 仍检查实际请求树能否完整复制。
	if RunService:IsStudio() then
		local issues = ResourceValidator.ValidateRoots(sharedRoot, serverRoot)
		if #issues > 0 then
			error("Resource validation failed:\n" .. ResourceValidator.FormatIssues(issues), 2)
		end
	end

	self._logger.Info(self.Name, "Shared 与 Server 资源根目录已就绪")
end

-- Get 返回资源库中的原始模板。调用方应把模板视为只读，需要修改时使用 Clone。
-- scope 只能是 "Shared"/"Server"；resourcePath 是相对点分路径，例 Get("Server", "Stage.Stage01")。
-- 成功返回 template, nil, nil；路径不是独立资源 ID，移动或重命名目录会让原路径失效。
function ResourceService:Get(scope, resourcePath)
	if not ResourceResolver.IsValidScope(scope) then
		local failure = ResourceResolver.NewFailure("INVALID_RESOURCE_SCOPE", scope, resourcePath, "<scope>", nil)
		self:_warnFailure(failure)
		return nil, "INVALID_RESOURCE_SCOPE", failure
	end

	local template, resolveError, resolveFailure = ResourceResolver.Resolve(self:_getRoot(scope), scope, resourcePath)
	if template == nil then
		self:_warnFailure(resolveFailure)
		return nil, resolveError, resolveFailure
	end

	return template, nil, nil
end

-- 克隆模板并挂到明确的 parent Instance 下，成功返回 clone, nil, nil；不设置位置或生命周期。
-- 整树必须 Archivable=true；原生 Clone/Parent 异常仍抛出，不一律转成返回错误码。
function ResourceService:Clone(scope, resourcePath, parent)
	if not ResourceResolver.IsValidScope(scope) then
		-- 复用 Get 的非法范围诊断，避免两个入口维护不同的错误格式。
		return self:Get(scope, resourcePath)
	end

	if typeof(parent) ~= "Instance" then
		local failure = ResourceResolver.NewFailure("INVALID_PARENT", scope, resourcePath, "<parent>", parent)
		self:_warnFailure(failure)
		return nil, "INVALID_PARENT", failure
	end

	local template, getError, getFailure = self:Get(scope, resourcePath)
	if template == nil then
		-- Get 已记过日志，此处只透传失败，避免一次操作出现两条相同警告。
		return nil, getError, getFailure
	end

	local clone, cloneError, cloneFailure = ResourceCloner.Clone(template, scope, resourcePath, parent)
	if clone == nil then
		self:_warnFailure(cloneFailure)
		return nil, cloneError, cloneFailure
	end
	return clone, nil, nil
end

-- 兼容旧版服务器接口；新代码统一使用 Get("Server", path)。
-- 只访问 Server，接受旧斜杠分隔并透传新版返回值；不会从 Shared 回退查找。
function ResourceService:FindServerTemplate(resourcePath)
	return self:Get("Server", convertLegacyPath(resourcePath))
end

-- 兼容旧版服务器接口；新代码统一使用 Clone("Server", path, parent)。
-- parent 仍必须是 Instance；兼容的是路径写法，不放宽校验或创建缺失目录。
function ResourceService:CloneServerTemplate(resourcePath, parent)
	return self:Clone("Server", convertLegacyPath(resourcePath), parent)
end

return ResourceService
