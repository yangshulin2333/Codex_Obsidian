local Hotpot = _G.ServerHotpot
---@type GameAnalytics
local GameAnalytics = Hotpot.load.GameAnalytics()
---@type GAConfig
local GAConfig = Hotpot.load.GAConfig()
_G.GameAnalytics = GameAnalytics
---@type GameAnalyticsServiceInit
local module = {}
GameAnalytics:initialize({
    build = GAConfig.Build,
    gameKey = GAConfig.GameKey,  ---游戏键
	secretKey = GAConfig.SecretKey, ---游戏密钥

	enableInfoLog = true,
	enableVerboseLog = false,
	useCustomUserId = true,  ---自定义Id开关
	--debug is by default enabled in studio only
	enableDebugLog = nil,

	automaticSendBusinessEvents = true,
	reportErrors = true,
	----可用的（允许的）自定义衣服，外形，资源货币，资源项目类型和可用的游戏通行证

	availableCustomDimensions01 = {},
	availableCustomDimensions02 = {},
	availableCustomDimensions03 = {},
	availableResourceCurrencies = {"Gold"}, ---游戏货币
	availableResourceItemTypes = {},  ---游戏里的一下类型
	availableGamepasses = {}
})


-- local OnPlayerReadyEvent
-- OnPlayerReadyEvent = OnPlayerReadyEvent or game:GetService("ReplicatedStorage"):WaitForChild("OnPlayerReadyEvent") ---玩家准备完成事件

-- local function onPlayerReady(Player)
-- 	--Do stuff in here
-- end

-- OnPlayerReadyEvent.Event:connect(onPlayerReady) ---玩家准备执行方法

GameAnalytics:setEnabledInfoLog(true) ---信息日志开关，启用后将输出短消息，说明SDK何时执行某些操作。
GameAnalytics:setEnabledVerboseLog(true) ---详细日志开关，对事件进行故障排除时，启用详细日志。
---GameAnalytics：setEnabledEventSubmission（false）  启用和禁用事件
---local isPlayerReady = GameAnalytics:isPlayerReady(玩家Id)  --- 询问玩家是否准备完成
return module