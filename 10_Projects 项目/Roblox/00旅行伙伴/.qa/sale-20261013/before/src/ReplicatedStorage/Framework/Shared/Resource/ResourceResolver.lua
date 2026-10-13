--!strict

-- 从指定根目录解析 "Egg.Basic" 这样的资源路径；只查找和组织错误信息，不克隆、不输出日志。
-- 公开函数使用点号，不传 self；这里只管理相对目录路径，不把路径当作独立于目录结构的资源 ID。
local ResourceResolver = {}

local VALID_SCOPES = {
	Shared = true,
	Server = true,
}

-- 获取完整层级名用于错误详情；无效对象返回占位文字。
local function getFullName(instance)
	-- typeof 可识别 Roblox 的 Instance 类型。
	if typeof(instance) ~= "Instance" then
		return "<none>"
	end

	-- GetFullName() 例如返回 "ServerStorage.Game.Resources.Stage"。
	return instance:GetFullName()
end

-- 构造错误详情，不抛异常。missing 是失败节点，foundParent 是查找它时所在的父对象。
-- 例如 Stage.Stage01 缺失：missing = "Stage01"，foundParent = Stage 文件夹。
function ResourceResolver.NewFailure(code, scope, resourcePath, missing, foundParent)
	return {
		Code = code,
		Scope = tostring(scope),
		Path = tostring(resourcePath),
		Missing = missing or "<none>",
		FoundParent = getFullName(foundParent),
	}
end

-- 只检查范围名称是否合法，不核对目录的实际位置。
function ResourceResolver.IsValidScope(scope)
	return type(scope) == "string" and VALID_SCOPES[scope] == true
end

-- 拆分 "Egg.Basic" -> { "Egg", "Basic" }；拒绝空节点及节点首尾空白。
-- 成功返回 segments, nil；失败返回 nil, errorCode。节点名称本身不能含点号。
function ResourceResolver.SplitPath(resourcePath)
	if type(resourcePath) ~= "string" or resourcePath == "" then
		return nil, "INVALID_RESOURCE_PATH"
	end

	-- string.split 按指定文字拆分；这里的 "." 是普通分隔符，不是模式通配符。
	local segments = string.split(resourcePath, ".")
	-- ipairs 按数组顺序遍历；_ 表示这里不使用序号。
	for _, segment in ipairs(segments) do
		-- string.match 使用 Lua 模式，未匹配返回 nil。
		-- ^ / $ 表示首尾，%s 表示空白，* 表示零次或多次；"^%s*$" 匹配空串或全空白。
		if segment == "" or string.match(segment, "^%s*$") ~= nil then
			return nil, "INVALID_RESOURCE_PATH"
		end
		-- 分别检查开头、结尾空白；名称中间的空格允许保留。
		if string.match(segment, "^%s") ~= nil or string.match(segment, "%s$") ~= nil then
			return nil, "INVALID_RESOURCE_PATH"
		end
	end

	return segments, nil
end

-- 只查直接子对象，拒绝同级重名；成功返回对象，失败返回 nil, errorCode, failure。
-- scope/resourcePath 用于诊断；可选 notFoundCode 区分根目录缺失与普通资源缺失。
function ResourceResolver.FindUniqueChild(parent, childName, scope, resourcePath, notFoundCode)
	if typeof(parent) ~= "Instance" then
		local code = notFoundCode or "RESOURCE_NOT_FOUND"
		return nil, code, ResourceResolver.NewFailure(code, scope, resourcePath, childName, parent)
	end

	local match = nil
	local matchCount = 0
	-- 遍历完直接子对象再判断数量；不能找到第一个就返回，否则会漏掉同名资源歧义。
	for _, child in ipairs(parent:GetChildren()) do
		if child.Name == childName then
			match = child
			matchCount += 1
		end
	end

	if matchCount == 0 then
		local code = notFoundCode or "RESOURCE_NOT_FOUND"
		return nil, code, ResourceResolver.NewFailure(code, scope, resourcePath, childName, parent)
	end

	if matchCount > 1 then
		return nil,
			"RESOURCE_DUPLICATE_NAME",
			ResourceResolver.NewFailure("RESOURCE_DUPLICATE_NAME", scope, resourcePath, childName, parent)
	end

	return match, nil, nil
end

-- 从 Resources 文件夹逐层查找；成功返回模板，失败返回 nil, errorCode, failure。
-- 这里只验证 scope 名称；真实目录位置由调用方和 ResourceValidator 保证。
function ResourceResolver.Resolve(root, scope, resourcePath)
	if not ResourceResolver.IsValidScope(scope) then
		return nil,
			"INVALID_RESOURCE_SCOPE",
			ResourceResolver.NewFailure("INVALID_RESOURCE_SCOPE", scope, resourcePath, "<scope>", root)
	end

	-- IsA 检查对象类型；先检查 Instance，避免对无效值调用对象方法。
	if typeof(root) ~= "Instance" or not root:IsA("Folder") then
		return nil,
			"RESOURCE_ROOT_MISSING",
			ResourceResolver.NewFailure("RESOURCE_ROOT_MISSING", scope, resourcePath, "Resources", root)
	end

	local segments, pathError = ResourceResolver.SplitPath(resourcePath)
	if segments == nil then
		return nil, pathError, ResourceResolver.NewFailure(pathError, scope, resourcePath, "<path segment>", root)
	end

	-- 逐层推进，例如 Resources -> Stage -> Stage01；任一层失败即返回。
	local current = root
	for _, segment in ipairs(segments) do
		local nextInstance, childError, childFailure =
			ResourceResolver.FindUniqueChild(current, segment, scope, resourcePath)
		if nextInstance == nil then
			return nil, childError, childFailure
		end

		current = nextInstance
	end

	return current, nil, nil
end

-- 将错误详情表整理成多行日志文字，只返回字符串，不负责输出。
function ResourceResolver.FormatFailure(failure)
	-- table.concat(列表, 分隔符) 是标准库拼接函数；这里用 "\n" 将各项拼成多行文字。
	-- .. 连接字符串；tostring 将字段转为文字，nil 也能显示为 "nil"。
	return table.concat({
		tostring(failure.Code),
		"Scope: " .. tostring(failure.Scope),
		"Path: " .. tostring(failure.Path),
		"Missing: " .. tostring(failure.Missing),
		"Found parent: " .. tostring(failure.FoundParent),
	}, "\n")
end

return ResourceResolver
