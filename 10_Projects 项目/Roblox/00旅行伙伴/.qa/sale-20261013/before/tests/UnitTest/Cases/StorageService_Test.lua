--!strict

-- 验证同一 UserId 快速重进时，新的玩家加载不会永久等待已经结束的旧加载。
-- 使用服务替身、假玩家与内存标记，不触发真实玩家进入或 ProfileStore 读写。
return function(testContext)
	local Players = game:GetService("Players")
	local StorageService = require(game.ServerScriptService.Server.Framework.Services.StorageService)
	local expect = testContext.expect

	testContext.test("retries after an interrupted previous open", function()
		local key = "42"
		local openCalls = 0
		local isOpen = false
		-- 预置“旧请求仍在加载”的标记；通过 __index 只借用待测的 OpenPlayer 实现。
		local service = setmetatable({
			_openingByKey = {
				[key] = true,
			},
			_cancelOpenByKey = {},
			_playerDataStatusByKey = {},
			_logger = {
				Debug = function() end,
				Warn = function() end,
			},
		}, {
			__index = StorageService,
		})

		-- 覆盖底层 key 接口，记录是否打开以及打开次数，用于断言只补发一次加载。
		function service:IsKeyOpen(_key)
			return isOpen
		end

		function service:GetKey(_key)
			return {
				Source = "replacement open",
			}
		end

		function service:OpenKey(_key, _options)
			openCalls += 1
			isOpen = true
			return self:GetKey(_key)
		end

		local newPlayer = {
			UserId = 42,
			Name = "RejoinedPlayer",
			Parent = Players,
		}

		-- 延后清除旧请求标记，让 OpenPlayer 真正经过等待分支，再尝试新的 OpenKey。
		task.delay(0.05, function()
			service._openingByKey[key] = nil
		end)

		local data, openError = service:OpenPlayer(newPlayer)

		expect.equal(openError, nil)
		expect.equal(data.Source, "replacement open")
		expect.equal(openCalls, 1)
	end)
end
