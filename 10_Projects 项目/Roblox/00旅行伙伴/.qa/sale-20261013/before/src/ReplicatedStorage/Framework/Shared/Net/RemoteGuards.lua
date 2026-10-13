--!strict
-- 校验 Remote 名称和可选响应等待期限；不验证业务内容、玩家权限或发送频率。
local RemoteGuards = {}

-- #string 按字节计长度；这里的名称约定使用英文、数字与少量标点。
local MAX_REMOTE_NAME_LENGTH = 80
-- 这是 Lua 模式，不是完整正则：^/$ 限定首尾，%w 表示字母数字，+ 表示至少一个。
-- 字符集合中的 _、%.、%- 允许下划线、点号和连字符，例如 "Framework.Ping"。
local REMOTE_NAME_PATTERN = "^[%w_%.%-]+$"

-- 成功返回原始名称，不做截断或清洗；失败抛异常。argumentName 可选，只用于报错标签。
function RemoteGuards.AssertRemoteName(remoteName, argumentName)
	local label = argumentName or "remoteName"

	if type(remoteName) ~= "string" or remoteName == "" then
		error(label .. " 必须是不为空的字符串", 3)
	end

	if #remoteName > MAX_REMOTE_NAME_LENGTH then
		error(label .. " 太长", 3)
	end

	if string.match(remoteName, REMOTE_NAME_PATTERN) == nil then
		-- 未匹配返回 nil；不要把格式正确误认为该 Remote 已在服务器注册。
		error(label .. "只能使用字母、数字、点号、下划线和连字符。", 3)
	end

	return remoteName
end

-- nil 保留原生响应等待；提供时必须为正有限秒数，不代替目录查找的等待上限。
function RemoteGuards.AssertResponseTimeout(responseTimeoutSeconds)
	if responseTimeoutSeconds == nil then
		return nil
	end
	if
		type(responseTimeoutSeconds) ~= "number"
		or responseTimeoutSeconds <= 0
		or responseTimeoutSeconds ~= responseTimeoutSeconds
		or responseTimeoutSeconds == math.huge
	then
		error("responseTimeoutSeconds must be a positive finite number", 3)
	end
	return responseTimeoutSeconds
end

return RemoteGuards
