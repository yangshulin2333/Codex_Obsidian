local history=game:GetService("ChangeHistoryService")
pcall(function() history:SetWaypoint("行囊入口制作前") end)
local island=workspace.Game.World.TravelIsland
local sample=island.Plots.Plot1.SampleFixtures
local resources=game.ServerStorage.Game.Resources.Models.TravelBuddy
assert(not resources:FindFirstChild("PreparationStation"))
local model=Instance.new("Model")
model.Name="PreparationStation"
model:SetAttribute("Template",true)
model:SetAttribute("BagResourceVersion","v1")
local origin=Vector3.new(-49,2.12,-2)
local root=Instance.new("Part")
root.Name="Root";root.Size=Vector3.new(.1,.1,.1);root.Anchored=true;root.Transparency=1;root.CanCollide=false;root.CanTouch=false;root.CanQuery=false;root.CFrame=CFrame.new(origin);root.Parent=model;model.PrimaryPart=root
local visual=Instance.new("Folder");visual.Name="Appearance";visual.Parent=model
local names={"PrepTableTop","PrepLeg_-50.5_-2.8","PrepLeg_-50.5_-1.2","PrepLeg_-47.5_-2.8","PrepLeg_-47.5_-1.2","PackedBagPreview","PrepSign"}
local removeNames={}
for _,name in ipairs(names) do local item=sample:FindFirstChild(name);assert(item,name);local copy=item:Clone();copy.Parent=visual;table.insert(removeNames,name) end
visual.PrepSign.SignGui.Label.Text="伙伴行囊\n装入 · 收回补给"
local control=Instance.new("Part")
control.Name="ControlAnchor";control.Size=Vector3.new(.1,.1,.1);control.Anchored=true;control.Transparency=1;control.CanCollide=false;control.CanTouch=false;control.CanQuery=false;control.CFrame=CFrame.new(-49,4.4,-2);control.Parent=model
local prompt=Instance.new("ProximityPrompt")
prompt.Name="BagPrompt";prompt:SetAttribute("TravelAction","Bag");prompt.ActionText="整理伙伴行囊";prompt.ObjectText="准备桌";prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX;prompt.MaxActivationDistance=10;prompt.HoldDuration=.1;prompt.RequiresLineOfSight=false;prompt.Parent=control
model:PivotTo(CFrame.identity)
model.Parent=resources
local anchors={}
for i=1,4 do
 local plot=island.Plots["Plot"..i];assert(not plot:FindFirstChild("PreparationAnchor"))
 local home=plot.HomeAnchor.Position;local a=Instance.new("Part");a.Name="PreparationAnchor";a.Size=Vector3.new(.1,.1,.1);a.Anchored=true;a.Transparency=1;a.CanCollide=false;a.CanTouch=false;a.CanQuery=false;a.CFrame=CFrame.new(home.X+5,2.12,home.Z+17);a:SetAttribute("InteractionPoint","Bag");a:SetAttribute("BagAnchorVersion","v1");a.Parent=plot
 anchors["Plots.Plot"..i..".PreparationAnchor"]=a
end
-- 桌子外观改由运行时按地块归属克隆，保留样板箱位与路径。
for _,name in ipairs(removeNames) do sample[name]:Destroy() end
sample.PreparationAnchor:Destroy()
local window=game.ReplicatedStorage.Game.Resources.UI.TravelBuddy.TravelWindow
local content=window.Root.Panel.Content
assert(not content:FindFirstChild("Bag"))
local bag=content.Status:Clone();bag.Name="Bag";bag.Visible=false;bag:SetAttribute("BagPanelVersion","v1")
bag.Detail.Name="Hint";bag.PrimaryActions.Name="Actions"
bag.Actions.BuySupply.Name="PackOne";bag.Actions.ClaimReturn.Name="PackFull"
bag.SecondaryActions.ClaimRelief.Name="UnpackOne";bag.SecondaryActions.Refresh.Name="UnpackAll"
bag.Retry.Name="Info"
local oldInfo=bag.Info
local info=Instance.new("TextLabel");info.Name="Info";info.Size=oldInfo.Size;info.Position=oldInfo.Position;info.LayoutOrder=oldInfo.LayoutOrder;info.BackgroundTransparency=1;info.TextColor3=bag.Hint.TextColor3;info.Font=bag.Hint.Font;info.TextSize=bag.Hint.TextSize;info.TextWrapped=true;info.TextXAlignment=Enum.TextXAlignment.Left;info.TextYAlignment=Enum.TextYAlignment.Center;info.AutoLocalize=false;info.Parent=bag;oldInfo:Destroy()
bag.Summary.Text="仓库补给 0 份\n行囊 0 / 3 份";bag.Summary.Size=UDim2.new(.98,0,0,72)
bag.Hint.Text="伙伴在家时可整理，旅行及未靠岸时只读。";bag.Hint.Size=UDim2.new(.98,0,0,72)
bag.Info.Text="每趟出发消耗 1 份行囊补给。\n购买只增加仓库，装入后才能用于出航。";bag.Info.Size=UDim2.new(.98,0,0,88)
bag.Actions.PackOne.Text="装入 1 份";bag.Actions.PackFull.Text="装满行囊"
bag.SecondaryActions.UnpackOne.Text="收回 1 份";bag.SecondaryActions.UnpackAll.Text="全部收回"
bag.Parent=content
local function v3(v) return {v.X,v.Y,v.Z} end
local function encode(node)
 local out={class=node.ClassName,name=node.Name,attrs=node:GetAttributes(),children={}}
 if node:IsA("BasePart") then out.frame={node.CFrame:GetComponents()};out.size=v3(node.Size);out.color={node.Color.R,node.Color.G,node.Color.B};out.collide=node.CanCollide;out.touch=node.CanTouch;out.query=node.CanQuery;out.transparency=node.Transparency;out.material=node.Material.Value
 elseif node:IsA("ProximityPrompt") then out.action=node.ActionText;out.subject=node.ObjectText;out.keyboard=node.KeyboardKeyCode.Value;out.gamepad=node.GamepadKeyCode.Value;out.distance=node.MaxActivationDistance;out.hold=node.HoldDuration;out.enabled=node.Enabled;out.lineOfSight=node.RequiresLineOfSight
 elseif node:IsA("SurfaceGui") then out.face=node.Face.Value;out.sizing=node.SizingMode.Value;out.pixels=node.PixelsPerStud
 elseif node:IsA("TextLabel") then out.text=node.Text;out.font=node.Font.Value;out.textColor={node.TextColor3.R,node.TextColor3.G,node.TextColor3.B}
 end
 for _,child in ipairs(node:GetChildren()) do table.insert(out.children,encode(child)) end
 return out
end
local data={model=encode(model),anchors={},remove=removeNames}
for path,a in pairs(anchors) do data.anchors[path]=encode(a) end
pcall(function() history:SetWaypoint("行囊准备点与原生面板") end)
return game:GetService("HttpService"):JSONEncode(data)
