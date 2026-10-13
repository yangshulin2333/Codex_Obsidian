--!strict

-- Net 内部等待工具：只隔离一次调用的结果与本地线程，不发送网络、不处理业务或 UI。
local RemoteGuards = require(script.Parent.RemoteGuards)

local RequestWait = {}

-- 返回 completed, invokeOk, value；超时为 false, nil, nil，只接收回调的首个返回值。
function RequestWait.Run(invoke, responseTimeoutSeconds)
	assert(type(invoke) == "function", "invoke must be a function")
	RemoteGuards.AssertResponseTimeout(responseTimeoutSeconds)
	if responseTimeoutSeconds == nil then
		local ok, value = pcall(invoke)
		return true, ok, value
	end

	local caller = coroutine.running()
	local deadline = os.clock() + responseTimeoutSeconds
	local settled = false
	local waiting = false
	local completed = false
	local invokeOk = nil
	local value = nil
	local timer = nil

	local function finish(didComplete, ok, result)
		if settled then
			return
		end
		settled = true
		completed, invokeOk, value = didComplete, ok, result
		-- 下一恢复点再唤醒，避免调用方清理时仍同步运行在当前 worker/timer 栈上。
		if waiting then
			task.defer(function()
				if waiting and coroutine.status(caller) == "suspended" then
					task.spawn(caller)
				end
			end)
		end
	end

	local worker = coroutine.create(function()
		local ok, result = pcall(invoke)
		if settled then
			return
		end
		-- 以实际返回时刻判断；即使计时线程晚获得执行机会，也不能接收过期结果。
		if os.clock() >= deadline then
			finish(false, nil, nil)
		else
			finish(true, ok, result)
		end
		pcall(task.cancel, timer)
	end)

	timer = task.delay(responseTimeoutSeconds, function()
		if settled then
			return
		end
		finish(false, nil, nil)
		-- 只尝试关闭本地失者；服务器执行和引擎内部传输不由此取消。
		pcall(task.cancel, worker)
	end)

	-- spawn 可立即完成；检查 settled 后再等待，避免丢失立即返回的结果。
	task.spawn(worker)
	while not settled do
		waiting = true
		coroutine.yield()
		waiting = false
	end
	return completed, invokeOk, value
end

return RequestWait
