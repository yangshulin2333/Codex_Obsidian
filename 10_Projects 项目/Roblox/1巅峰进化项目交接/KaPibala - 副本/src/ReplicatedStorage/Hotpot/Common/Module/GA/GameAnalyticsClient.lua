local GS = game:GetService("GuiService")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Hotpot = _G.CommonHotpot
local ScriptContext = game:GetService("ScriptContext")
local player = game:GetService("Players").LocalPlayer
local Postie = Hotpot.load.Postie()
local module = {}
---自定义用户Id
local function getCustomUserId()
	return player.DisplayName
end

ScriptContext.Error:Connect(function(...)
	ReplicatedStorage.GameAnalyticsError:FireServer(...)
end)

--Functions
local function getPlatform()

	if GS:IsTenFootInterface() then
		return "Console"
	elseif UIS.TouchEnabled and not UIS.MouseEnabled then
		return "Mobile"
	else
		return "Desktop"
	end
end

--Filtering
Postie.SetCallback("getPlatform", getPlatform)
return module
