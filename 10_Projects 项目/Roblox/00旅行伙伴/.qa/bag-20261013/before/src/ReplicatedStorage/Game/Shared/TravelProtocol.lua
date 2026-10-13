--!strict

-- 请求只表达意图；价格、奖励、时间和所属关系均由 Game 服务端决定。
return table.freeze({
	Request = "TravelBuddy.Request",
	StateEvent = "TravelBuddy.State",
	Actions = table.freeze({
		ReadState = "ReadState",
		BuySupply = "BuySupply",
		StartJourney = "StartJourney",
		ClaimReturn = "ClaimReturn",
		OpenContainer = "OpenContainer",
		SellItem = "SellItem",
		SellAll = "SellAll",
		Upgrade = "Upgrade",
		ClaimRelief = "ClaimRelief",
	}),
})
