--!strict

-- 两端共用的完整复制检查；不修模板、缓存副本或管理运行对象的生命周期。
-- 输入模板、范围、路径和 parent 已由 ResourceService/ResourceClient 定位及校验。
local ResourceResolver = require(script.Parent.ResourceResolver)

local ResourceCloner = {}

-- 只读检查整个请求树；返回首个不可复制节点的问题，不按内部节点名解析资源路径。
function ResourceCloner.CheckTemplate(template, scope, resourcePath)
	local function check(instance)
		if not instance.Archivable then
			return ResourceResolver.NewFailure(
				"RESOURCE_NOT_ARCHIVABLE",
				scope,
				resourcePath,
				instance.Name,
				instance.Parent
			)
		end
		return nil
	end

	local failure = check(template)
	if failure ~= nil then
		return failure
	end
	for _, descendant in ipairs(template:GetDescendants()) do
		failure = check(descendant)
		if failure ~= nil then
			return failure
		end
	end
	return nil
end

-- 成功副本交给调用方；内部引用重映射与外部引用保留遵循原生 Clone。
function ResourceCloner.Clone(template, scope, resourcePath, parent)
	local failure = ResourceCloner.CheckTemplate(template, scope, resourcePath)
	if failure ~= nil then
		return nil, failure.Code, failure
	end

	local clone = template:Clone()
	if clone == nil then
		failure =
			ResourceResolver.NewFailure("RESOURCE_CLONE_FAILED", scope, resourcePath, template.Name, template.Parent)
		return nil, failure.Code, failure
	end

	-- Parent 原生异常继续抛出，但不能遗留本次尚未交给调用方的新副本。
	local attached, attachError = pcall(function()
		clone.Parent = parent
	end)
	if not attached then
		clone:Destroy()
		error(attachError, 0)
	end
	return clone, nil, nil
end

return ResourceCloner
