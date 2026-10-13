--!strict

-- 服务器侧验证客户端包装逻辑；独立模块和模拟 Remote 不代表真实网络联调。
return function(testContext)
	local netFolder = game.ReplicatedStorage.Framework.Shared.Net
	local NetResult = require(netFolder.NetResult)
	local expect = testContext.expect

	-- 只替换新副本的目录入口，不修改已 require 的正式模块或生产 Remote。
	local function withClient(callback)
		local folder = Instance.new("Folder")
		folder.Name = "NetRequestTest"
		for _, name in ipairs({ "NetClient", "NetResult", "RemoteGuards", "RemoteNames", "RequestWait" }) do
			local module = netFolder[name]:Clone()
			module.Parent = folder
		end
		local ok, failure = pcall(function()
			callback(require(folder.NetClient))
		end)
		folder:Destroy()
		if not ok then
			error(failure, 0)
		end
	end

	local function setRemote(client, invoke, validType)
		local observation = { Lookups = 0, Calls = 0 }
		local remote = {
			IsA = function(_, className)
				return validType ~= false and className == "RemoteFunction"
			end,
			InvokeServer = function(_, payload)
				observation.Calls += 1
				observation.Payload = payload
				return invoke(payload)
			end,
		}
		client.GetRequestFolder = function()
			return {
				WaitForChild = function(_, name, timeoutSeconds)
					observation.Lookups += 1
					observation.Name = name
					observation.LookupTimeout = timeoutSeconds
					return remote
				end,
			}
		end
		return observation
	end

	local values = {
		{ Name = "nil" },
		{ Name = "false", Value = false },
		{ Name = "zero", Value = 0 },
		{ Name = "plain data", Value = { Value = 1 } },
	}
	for _, sample in ipairs(values) do
		testContext.test("wraps a plain " .. sample.Name .. " response with and without timeout", function()
			withClient(function(client)
				local payload = { Value = "Payload" }
				local observation = setRemote(client, function()
					return sample.Value
				end)
				for _, timeoutSeconds in ipairs({ false, 1 }) do
					local timeout = if timeoutSeconds == false then nil else timeoutSeconds
					local result = client.Request("Game.Test", payload, timeout)
					expect.equal(result.Ok, true)
					expect.equal(result.Data, sample.Value)
				end
				expect.equal(observation.Payload, payload)
				expect.equal(observation.Name, "Game.Test")
				expect.equal(observation.LookupTimeout, 10)
				expect.equal(observation.Calls, 2)
			end)
		end)
	end

	testContext.test("returns server success and failure results without repackaging", function()
		withClient(function(client)
			local results = {
				NetResult.Ok(false),
				NetResult.Err("DENIED", "Permission denied", { Scope = "Game", Message = "Keep" }),
			}
			for _, serverResult in ipairs(results) do
				local observation = setRemote(client, function()
					return serverResult
				end)
				expect.equal(client.Request("Game.Test", nil), serverResult)
				expect.equal(client.Request("Game.Test", nil, 1), serverResult)
				expect.equal(observation.Calls, 2)
			end
		end)
	end)

	testContext.test("returns INVOKE_FAILED for immediate and yielding invocation errors", function()
		withClient(function(client)
			local observation = setRemote(client, function()
				error("Expected invocation failure")
			end)
			local oldFailure = client.Request("Game.Test", nil)
			local immediateFailure = client.Request("Game.Test", nil, 1)
			local gate = Instance.new("BindableEvent")
			local waited = setRemote(client, function()
				gate.Event:Wait()
				error("Expected waited invocation failure")
			end)
			task.defer(function()
				gate:Fire()
			end)
			local waitedFailure = client.Request("Game.Test", nil, 1)
			gate:Destroy()
			for _, result in ipairs({ oldFailure, immediateFailure, waitedFailure }) do
				expect.equal(result.Ok, false)
				expect.equal(result.Code, "INVOKE_FAILED")
				expect.equal(result.Message, "Remote request failed")
				expect.equal(result.Data.RemoteName, "Game.Test")
			end
			expect.equal(observation.Calls, 2)
			expect.equal(waited.Calls, 1)
		end)
	end)

	testContext.test("returns REMOTE_NOT_FOUND for a missing or wrong type Remote", function()
		withClient(function(client)
			local lookups = 0
			client.GetRequestFolder = function()
				return {
					WaitForChild = function()
						lookups += 1
						return nil
					end,
				}
			end
			local missing = client.Request("Game.Test", nil, 1)
			local observation = setRemote(client, function()
				error("Wrong type Remote must not be invoked")
			end, false)
			local wrongType = client.Request("Game.Test", nil)
			for _, result in ipairs({ missing, wrongType }) do
				expect.equal(result.Ok, false)
				expect.equal(result.Code, "REMOTE_NOT_FOUND")
				expect.equal(result.Data.RemoteName, "Game.Test")
			end
			expect.equal(lookups, 1)
			expect.equal(observation.Calls, 0)
		end)
	end)

	testContext.test("keeps missing folder exceptions on the old and timed paths", function()
		withClient(function(client)
			local failure = { Code = "MISSING_FOLDER" }
			client.GetRequestFolder = function()
				error(failure)
			end
			expect.equal(
				expect.throws(function()
					client.Request("Game.Test", nil)
				end),
				failure
			)
			expect.equal(
				expect.throws(function()
					client.Request("Game.Test", nil, 1)
				end),
				failure
			)
		end)
	end)

	testContext.test("rejects invalid parameters before Remote lookup", function()
		withClient(function(client)
			local observation = setRemote(client, function()
				return true
			end)
			for _, timeout in ipairs({ 0, -1, math.huge, -math.huge, 0 / 0, false, "1", {} }) do
				expect.throws(function()
					client.Request("Game.Test", nil, timeout)
				end)
			end
			for _, name in ipairs({ "", "Bad/Name", string.rep("A", 81) }) do
				expect.throws(function()
					client.Request(name, nil, 1)
				end)
			end
			expect.equal(observation.Lookups, 0)
			expect.equal(observation.Calls, 0)
		end)
	end)

	testContext.test("returns REQUEST_TIMEOUT once without retrying the invocation", function()
		withClient(function(client)
			local gate = Instance.new("BindableEvent")
			local observation = setRemote(client, function()
				gate.Event:Wait()
				return NetResult.Ok("Late")
			end)
			local result = client.Request("Game.Test", nil, 0.01)
			gate:Fire()
			task.wait(0.03)
			gate:Destroy()
			expect.equal(result.Ok, false)
			expect.equal(result.Code, "REQUEST_TIMEOUT")
			expect.equal(result.Data.RemoteName, "Game.Test")
			expect.equal(result.Data.ResponseTimeoutSeconds, 0.01)
			expect.equal(observation.Calls, 1)
			expect.equal(observation.Lookups, 1)
		end)
	end)
end
