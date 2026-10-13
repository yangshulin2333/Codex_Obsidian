--!strict

-- 轻量测试入口：发现并运行 ServerStorage.UnitTest.Cases 下的测试模块。
-- 测试模块返回 function(testContext)，通过 testContext.test 注册并立即执行用例；普通 Play 不应自动运行。
local ServerStorage = game:GetService("ServerStorage")

-- 将断言中的值转成易读文字；%q 会给字符串加引号并转义，便于分辨空串、换行等差异。
local function formatValue(value)
	if type(value) == "string" then
		return string.format("%q", value)
	end
	return tostring(value)
end

local expect = {}

-- 比较实际值和期望值，不相等则抛异常；表只比较引用，不做递归内容比较。
function expect.equal(actual, expected)
	if actual ~= expected then
		error(string.format("expected %s, got %s", formatValue(expected), formatValue(actual)), 2)
	end
end

-- 断言值为“真值”；Luau 只有 false 和 nil 为假，0 与空字符串也能通过本断言。
function expect.truthy(value)
	if not value then
		error(string.format("expected truthy, got %s", formatValue(value)), 2)
	end
end

-- 断言值为 false 或 nil；不要用它判断数字是否为 0 或容器是否为空。
function expect.falsy(value)
	if value then
		error(string.format("expected falsy, got %s", formatValue(value)), 2)
	end
end

-- 保护性执行 callback，要求它抛异常并返回捕获到的错误；不会自动检查错误码/错误文字。
function expect.throws(callback)
	local ok, result = pcall(callback)
	if ok then
		error("expected the function to throw, but it returned normally", 2)
	end
	return result
end

-- 在独立协程中运行单个用例，返回状态、耗时秒数、可选错误文字；异常计为 fail。
-- 超时只报告 timeout，不取消用例协程，也无法抢占无让出的死循环；测试需要自行管理清理。
local function runOne(callback, timeoutSeconds)
	local done = false
	local ok = false
	local result = nil
	local startedAt = os.clock()

	task.spawn(function()
		ok, result = pcall(callback)
		done = true
	end)

	while not done and os.clock() - startedAt < timeoutSeconds do
		task.wait()
	end

	local elapsed = os.clock() - startedAt
	if not done then
		return "timeout", elapsed, string.format("exceeded %.1fs", timeoutSeconds)
	end
	if not ok then
		return "fail", elapsed, tostring(result)
	end
	return "pass", elapsed, nil
end

-- 执行测试套件并返回 { run, passed, failed }；filter 可选，按模块名做普通子串筛选。
-- timeoutSeconds 默认每用例 5 秒，不是整套测试总超时；目录发现顺序没有排序保证。
return function(filter, timeoutSeconds)
	timeoutSeconds = timeoutSeconds or 5
	local totals = { run = 0, passed = 0, failed = 0 }
	local casesFolder = ServerStorage.UnitTest.Cases

	for _, module in ipairs(casesFolder:GetDescendants()) do
		if module:IsA("ModuleScript") and (filter == nil or string.find(module.Name, filter, 1, true)) then
			-- require 加载失败与模块返回值不正确都计入失败，避免坏模块被静默跳过。
			local required, caseFunction = pcall(require, module)
			if not required or type(caseFunction) ~= "function" then
				totals.run += 1
				totals.failed += 1
				warn(
					string.format("[FAIL] %s | case did not return a function: %s", module.Name, tostring(caseFunction))
				)
			else
				local testContext = { expect = expect }
				-- name 是报告中的用例名称；调用 test 即运行回调并累计结果，不另建待执行队列。
				function testContext.test(name, callback)
					totals.run += 1
					local status, elapsed, message = runOne(callback, timeoutSeconds)
					if status == "pass" then
						totals.passed += 1
						print(string.format("[PASS] %s > %s (%.3fs)", module.Name, name, elapsed))
					else
						totals.failed += 1
						warn(
							string.format(
								"[%s] %s > %s (%.3fs) | %s",
								string.upper(status),
								module.Name,
								name,
								elapsed,
								message
							)
						)
					end
				end

				-- 除了单个用例，还捕获构造/登记用例时的异常；不让一个模块打断其余模块的发现。
				local ran, runError = pcall(caseFunction, testContext)
				if not ran then
					totals.run += 1
					totals.failed += 1
					warn(string.format("[FAIL] %s | error while building cases: %s", module.Name, tostring(runError)))
				end
			end
		end
	end

	print(string.format("[SUMMARY] %d run, %d passed, %d failed", totals.run, totals.passed, totals.failed))
	return totals
end
