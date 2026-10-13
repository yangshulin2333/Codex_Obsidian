--!strict

-- 开发期检查目录位置、路径命名与整体模板可复制性，不修改资源或输出日志。
-- ResourceService 只在 Studio 启动时调用；本模块本身不限制运行环境，测试也可直接调用。
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ResourceResolver = require(ReplicatedStorage.Framework.Shared.Resource.ResourceResolver)
local ResourceCloner = require(ReplicatedStorage.Framework.Shared.Resource.ResourceCloner)

local ResourceValidator = {}

-- 将问题追加到调用方的数组中；使用统一 failure 结构，便于与运行时查找错误使用同一套日志格式。
local function appendIssue(issues, code, scope, resourcePath, missing, foundParent)
	table.insert(issues, ResourceResolver.NewFailure(code, scope, resourcePath, missing, foundParent))
end

-- scope 已在入口校验；检查实际层级必须是指定容器/Game/Resources，而非只检查文件夹名字。
local function validateLocation(scope, root, issues)
	-- Luau 的 if 表达式会返回所选分支的值，这里按 scope 选择预期的 Roblox 容器。
	local expectedContainer = if scope == "Shared" then ReplicatedStorage else ServerStorage
	local gameFolder = root.Parent
	if
		root.Name ~= "Resources"
		or gameFolder == nil
		or gameFolder.Name ~= "Game"
		or gameFolder.Parent ~= expectedContainer
	then
		appendIssue(issues, "RESOURCE_SCOPE_MISMATCH", scope, "<root>", "Game.Resources", root.Parent)
	end
end

-- Folder 默认是分类目录；其他对象及 Template=true Folder 是整体模板。
-- 模板内部命名归自身实现，完整复制检查仍覆盖内部所有节点。
local function validateChildren(scope, current, parentPath, issues)
	-- 每层单独记录名称，所以不同父对象下同名合法，只有同一个父对象下重名才报错。
	local firstChildByName = {}

	for _, child in ipairs(current:GetChildren()) do
		local childPath = if parentPath == "" then child.Name else parentPath .. "." .. child.Name

		-- string.find 的最后一个 true 表示按普通文字找点号，不把 "." 当成模式通配符。
		if child.Name == "" then
			appendIssue(issues, "INVALID_RESOURCE_PATH", scope, childPath, "<empty name>", current)
		elseif string.find(child.Name, ".", 1, true) ~= nil then
			appendIssue(issues, "RESOURCE_NAME_CONTAINS_DOT", scope, childPath, child.Name, current)
		elseif string.match(child.Name, "^%s") ~= nil or string.match(child.Name, "%s$") ~= nil then
			appendIssue(issues, "INVALID_RESOURCE_PATH", scope, childPath, child.Name, current)
		end

		if firstChildByName[child.Name] ~= nil then
			appendIssue(issues, "RESOURCE_DUPLICATE_NAME", scope, childPath, child.Name, current)
		else
			firstChildByName[child.Name] = child
		end

		if child:IsA("Folder") and child:GetAttribute("Template") ~= true then
			validateChildren(scope, child, childPath, issues)
		else
			local cloneIssue = ResourceCloner.CheckTemplate(child, scope, childPath)
			if cloneIssue ~= nil then
				table.insert(issues, cloneIssue)
			end
		end
	end
end

-- Studio 验证只检查确定可判断的结构问题，不猜测普通字符串是否为资源路径。
-- 返回 issues 数组，空表表示通过；无效 scope/root 记录一个问题后返回，不继续递归。
function ResourceValidator.ValidateRoot(scope, root)
	local issues = {}

	if not ResourceResolver.IsValidScope(scope) then
		appendIssue(issues, "INVALID_RESOURCE_SCOPE", scope, "<root>", "<scope>", root)
		return issues
	end

	if typeof(root) ~= "Instance" or not root:IsA("Folder") then
		appendIssue(issues, "RESOURCE_ROOT_MISSING", scope, "<root>", "Resources", root)
		return issues
	end

	validateLocation(scope, root, issues)
	validateChildren(scope, root, "", issues)
	return issues
end

-- 检查并合并 Shared、Server 两组问题，按此顺序返回；不因第一组有问题就跳过第二组。
function ResourceValidator.ValidateRoots(sharedRoot, serverRoot)
	local issues = ResourceValidator.ValidateRoot("Shared", sharedRoot)
	for _, issue in ipairs(ResourceValidator.ValidateRoot("Server", serverRoot)) do
		table.insert(issues, issue)
	end
	return issues
end

-- 将问题列表转换为文字，每项之间空一行；空列表返回空字符串，不负责打印或抛异常。
function ResourceValidator.FormatIssues(issues)
	local messages = {}
	for _, issue in ipairs(issues) do
		table.insert(messages, ResourceResolver.FormatFailure(issue))
	end
	return table.concat(messages, "\n\n")
end

return ResourceValidator
