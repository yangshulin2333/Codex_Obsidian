--!strict
-- 统一网络结果表：调用方先看 Ok，再读取 Data 或 Code/Message。
-- 这里只包装数据，不发送 Remote、不抛业务异常，也不深拷贝 data。
local NetResult = {}

-- 构造成功结果，例如 Ok({ Value = 1 })；data 可省略，此时没有 Data 字段。
function NetResult.Ok(data)
	return {
		Ok = true,
		Data = data,
	}
end

-- 构造失败结果：code 供代码分支判断，message 供阅读，data 保存可选诊断信息。
-- 返回 Ok = false 不等于抛异常；调用方需要主动检查结果。
function NetResult.Err(code, message, data)
	return {
		Ok = false,
		Code = code,
		Message = message,
		Data = data,
	}
end

-- 只检查 value 为表且 Ok 为布尔值；不检查 Code、Message 或 Data 的内容。
-- 网络层据此避免重复包装；业务普通数据不要用布尔字段 Ok 冒充结果结构。
function NetResult.IsResult(value)
	return type(value) == "table" and type(value.Ok) == "boolean"
end

return NetResult
