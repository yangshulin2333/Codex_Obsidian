--!strict

-- 用真实 task 调度和临时门闩验证单次等待；不调用 Remote，也不执行业务操作。
return function(testContext)
	local netFolder = game.ReplicatedStorage.Framework.Shared.Net
	local RequestWait = require(netFolder.RequestWait)
	local RemoteGuards = require(netFolder.RemoteGuards)
	local NetResult = require(netFolder.NetResult)
	local expect = testContext.expect

	testContext.test("accepts an omitted or positive finite response timeout", function()
		RemoteGuards.AssertResponseTimeout(nil)
		for _, value in ipairs({ 0.001, 1, 1000000 }) do
			RemoteGuards.AssertResponseTimeout(value)
		end
	end)

	testContext.test("rejects invalid response timeout values", function()
		local calls = 0
		for _, value in ipairs({ 0, -1, math.huge, -math.huge, 0 / 0, false, "1", {} }) do
			expect.throws(function()
				RemoteGuards.AssertResponseTimeout(value)
			end)
			expect.throws(function()
				RequestWait.Run(function()
					calls += 1
				end, value)
			end)
		end
		expect.equal(calls, 0)
	end)

	local values = {
		{ Name = "nil" },
		{ Name = "false", Value = false },
		{ Name = "zero", Value = 0 },
		{ Name = "table", Value = { Value = 1 } },
		{ Name = "success result", Value = NetResult.Ok(0) },
		{ Name = "failure result", Value = NetResult.Err("DENIED", "Denied", { Scope = "Game" }) },
	}
	for _, sample in ipairs(values) do
		testContext.test("keeps an immediate " .. sample.Name .. " value", function()
			local calls = 0
			local completed, invokeOk, value = RequestWait.Run(function()
				calls += 1
				return sample.Value
			end, 1)
			expect.equal(completed, true)
			expect.equal(invokeOk, true)
			expect.equal(value, sample.Value)
			expect.equal(calls, 1)
		end)
	end

	testContext.test("keeps the direct pcall path when timeout is omitted", function()
		local caller = coroutine.running()
		local completed, invokeOk, value = RequestWait.Run(function()
			expect.equal(coroutine.running(), caller)
			return false
		end)
		expect.equal(completed, true)
		expect.equal(invokeOk, true)
		expect.equal(value, false)
	end)

	testContext.test("preserves an immediate error object", function()
		local failure = { Code = "TEST_FAILURE" }
		local completed, invokeOk, value = RequestWait.Run(function()
			error(failure)
		end, 1)
		expect.equal(completed, true)
		expect.equal(invokeOk, false)
		expect.equal(value, failure)
	end)

	testContext.test("preserves the old failure path without a timeout", function()
		local failure = { Code = "TEST_FAILURE" }
		local completed, invokeOk, value = RequestWait.Run(function()
			error(failure)
		end)
		expect.equal(completed, true)
		expect.equal(invokeOk, false)
		expect.equal(value, failure)
	end)

	-- 门闩在下一次调度释放，验证等待中的成功和失败都能正常交付。
	for _, failAfterWait in ipairs({ false, true }) do
		testContext.test("delivers a yielding " .. (if failAfterWait then "failure" else "success"), function()
			local gate = Instance.new("BindableEvent")
			local value = { Value = 2 }
			task.defer(function()
				gate:Fire()
			end)
			local completed, invokeOk, result = RequestWait.Run(function()
				gate.Event:Wait()
				if failAfterWait then
					error(value)
				end
				return value
			end, 1)
			gate:Destroy()
			expect.equal(completed, true)
			expect.equal(invokeOk, not failAfterWait)
			expect.equal(result, value)
		end)
	end

	testContext.test("settles a waiting call once and discards a late response", function()
		local gate = Instance.new("BindableEvent")
		local calls = 0
		local deliveries = 0
		local outcome = nil
		task.spawn(function()
			local completed, invokeOk, value = RequestWait.Run(function()
				calls += 1
				gate.Event:Wait()
				return { Value = "Late" }
			end, 0.01)
			outcome = { Completed = completed, InvokeOk = invokeOk, Value = value }
			deliveries += 1
		end)
		while outcome == nil do
			task.wait()
		end
		gate:Fire()
		task.wait(0.03)
		gate:Destroy()
		expect.equal(outcome.Completed, false)
		expect.equal(outcome.InvokeOk, nil)
		expect.equal(outcome.Value, nil)
		expect.equal(calls, 1)
		expect.equal(deliveries, 1)
	end)

	testContext.test("rejects a non-yielding result that already exceeded its deadline", function()
		local calls = 0
		local completed, _, value = RequestWait.Run(function()
			calls += 1
			local finishAt = os.clock() + 0.006
			local now = os.clock()
			while now < finishAt do
				-- 短忙循环仅验证实际期限，不模拟可被抢占的长计算。
				now = os.clock()
			end
			return "Late"
		end, 0.002)
		expect.equal(completed, false)
		expect.equal(value, nil)
		expect.equal(calls, 1)
	end)

	testContext.test("keeps concurrent calls and their outcomes independent", function()
		local successGate = Instance.new("BindableEvent")
		local timeoutGate = Instance.new("BindableEvent")
		local outcomes = {}
		local calls = { 0, 0 }
		task.spawn(function()
			outcomes[1] = table.pack(RequestWait.Run(function()
				calls[1] += 1
				successGate.Event:Wait()
				return 0
			end, 1))
		end)
		task.spawn(function()
			outcomes[2] = table.pack(RequestWait.Run(function()
				calls[2] += 1
				timeoutGate.Event:Wait()
				return false
			end, 0.01))
		end)
		successGate:Fire()
		while outcomes[1] == nil or outcomes[2] == nil do
			task.wait()
		end
		timeoutGate:Fire()
		successGate:Destroy()
		timeoutGate:Destroy()
		expect.equal(outcomes[1][1], true)
		expect.equal(outcomes[1][2], true)
		expect.equal(outcomes[1][3], 0)
		expect.equal(outcomes[2][1], false)
		expect.equal(outcomes[2][3], nil)
		expect.equal(calls[1], 1)
		expect.equal(calls[2], 1)
	end)
end
