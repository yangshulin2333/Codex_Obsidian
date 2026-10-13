local history=game:GetService("ChangeHistoryService")
pcall(function() history:SetWaypoint("伙伴准备面板前") end)
local pane=game.ReplicatedStorage.Game.Resources.UI.TravelBuddy.TravelWindow.Root.Panel.Content.Bag
assert(not pane:FindFirstChild("Plan"))
local plan=pane.Hint:Clone()
plan.Name="Plan";plan.LayoutOrder=2;plan.Size=UDim2.new(.98,0,0,100)
plan.Text="装入补给后，伙伴会自行选择目的地与航程。\n准备完成后自动出发；可暂缓，或收回行囊补给。"
plan:SetAttribute("AutonomyUiDraft",true);plan.Parent=pane
pane.Actions.LayoutOrder=3;pane.SecondaryActions.LayoutOrder=4;pane.Info.LayoutOrder=6
local travel=pane.Actions:Clone();travel.Name="TravelActions";travel.LayoutOrder=5;travel:SetAttribute("AutonomyUiDraft",true)
travel.PackOne.Name="Pause";travel.Pause.Text="暂缓出发";travel.PackFull.Name="Resume";travel.Resume.Text="恢复准备";travel.Parent=pane
pane.Info.Size=UDim2.new(.98,0,0,100)
pane.Info.Text="出发前暂缓必定生效，恢复后会重新等待。\n本阶段已接入自主出发；归航收获暂按旧流程领取。"
local out={planText=plan.Text,infoText=pane.Info.Text,planHeight=plan.Size.Y.Offset,infoHeight=pane.Info.Size.Y.Offset,orders={Actions=3,SecondaryActions=4,TravelActions=5,Info=6}}
local resources=game.ServerStorage.Game.Resources.Models.TravelBuddy
for level=1,2 do local prompt=resources["ShipLv"..level].ShipControl.VoyagePrompt;prompt.Enabled=false;prompt.ActionText="旧派遣入口（停用）" end
resources.PreparationStation.Appearance.PrepSign.SignGui.Label.Text="伙伴准备桌\n查看计划 · 行囊 · 暂缓"
out.stationText=resources.PreparationStation.Appearance.PrepSign.SignGui.Label.Text
pcall(function() history:SetWaypoint("伙伴计划与暂缓入口") end)
return game:GetService("HttpService"):JSONEncode(out)
