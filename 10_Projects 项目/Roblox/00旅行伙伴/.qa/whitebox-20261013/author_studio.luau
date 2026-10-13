local studioHistory=game:GetService("ChangeHistoryService")
pcall(function() studioHistory:SetWaypoint("白模样板调整前") end)
local island=workspace.Game.World.TravelIsland
local plot=island.Plots.Plot1
assert(not plot:FindFirstChild("SampleFixtures"),"SampleFixtures already exists")
plot.HomeAnchor.CFrame=CFrame.new(-54,2.04,-19)
local rows={-6,2,10}
for i=1,6 do
 local x=if i<=3 then -64 else -44
 plot.ContainerSlots["Slot"..i].CFrame=CFrame.new(x,2.12,rows[(i-1)%3+1])
end
local models=game.ServerStorage.Game.Resources.Models.TravelBuddy
for level=1,2 do
 local h=models["HomeLv"..level]
 local z=if level==1 then 8 else 9
 h.FrogSeat.CFrame=CFrame.new(6.1,0.65,z)
 h.FrogAnchor.CFrame=CFrame.new(6.1,1.3,z)
end
local fixtures=Instance.new("Folder")
fixtures.Name="SampleFixtures"
fixtures:SetAttribute("SceneStage","PersonalPlotSample")
local function part(name,pos,size,color,collide)
 local p=Instance.new("Part")
 p.Name=name
 p.Size=size
 p.CFrame=CFrame.new(pos)
 p.Color=color or Color3.fromRGB(230,225,210)
 p.Anchored=true
 p.CanCollide=collide==true
 p.CanTouch=false
 p.TopSurface=Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth
 p.Material=Enum.Material.SmoothPlastic
 p.Parent=fixtures
 return p
end
local function anchor(name,pos)
 local p=part(name,pos,Vector3.new(0.1,0.1,0.1),nil,false)
 p.Transparency=1
 p.CanQuery=false
 return p
end
local function label(p,text,face)
 local gui=Instance.new("SurfaceGui")
 gui.Name="SignGui"
 gui.Face=face or Enum.NormalId.Back
 gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
 gui.PixelsPerStud=45
 gui.Parent=p
 local textLabel=Instance.new("TextLabel")
 textLabel.Name="Label"
 textLabel.Size=UDim2.fromScale(1,1)
 textLabel.BackgroundTransparency=1
 textLabel.Text=text
 textLabel.TextScaled=true
 textLabel.TextWrapped=true
 textLabel.AutoLocalize=false
 textLabel.TextColor3=Color3.fromRGB(48,61,65)
 textLabel.Font=Enum.Font.SourceSansBold
 textLabel.Parent=gui
end
part("HomeToHarborPath",Vector3.new(-54,2.08,2),Vector3.new(6,0.08,23),Color3.fromRGB(225,216,194),false)
part("PrepTableTop",Vector3.new(-49,4.1,-2),Vector3.new(4,0.3,2.5),nil,true)
for _,x in ipairs({-50.5,-47.5}) do
 for _,z in ipairs({-2.8,-1.2}) do
  part("PrepLeg_"..x.."_"..z,Vector3.new(x,3,z),Vector3.new(0.3,1.9,0.3),Color3.fromRGB(184,181,169),true)
 end
end
part("PackedBagPreview",Vector3.new(-49,4.85,-2),Vector3.new(1.6,1.2,1.4),Color3.fromRGB(163,176,157),false)
local prepSign=part("PrepSign",Vector3.new(-49,6.15,-2.9),Vector3.new(5.4,2,0.2),nil,false)
label(prepSign,"行囊准备\n装补给 · 愿望 · 暂缓\n功能待接入")
anchor("PreparationAnchor",Vector3.new(-49,4.4,-2))
anchor("CompanionPrepareAnchor",Vector3.new(-49,2.12,-4.7))
anchor("CompanionRestAnchor",Vector3.new(-47.9,3.34,-10))
anchor("BoardingAnchor",Vector3.new(-54,2.7,56))
part("MailboxPost",Vector3.new(-58.6,3.1,-5.3),Vector3.new(0.35,2,0.35),Color3.fromRGB(184,181,169),true)
part("MailboxBox",Vector3.new(-58.6,4.25,-5.3),Vector3.new(1.6,1.1,1.3),nil,true)
local mailSign=part("TravelRecordSign",Vector3.new(-58.6,5.65,-5.4),Vector3.new(4.2,1.4,0.2),nil,false)
label(mailSign,"旅行记录\n功能待接入")
anchor("TravelRecordAnchor",Vector3.new(-58.6,4,-4.5))
for i=1,6 do
 local slot=plot.ContainerSlots["Slot"..i]
 local pad=part("BoxFootprint"..i,Vector3.new(slot.Position.X,2.065,slot.Position.Z),Vector3.new(4.8,0.1,4),if i<=3 then Color3.fromRGB(221,208,171) else Color3.fromRGB(181,192,195),false)
 label(pad,if i<=3 then "箱位 "..i else "箱位 "..i.."\n住宅 Lv2",Enum.NormalId.Top)
end
fixtures.Parent=plot
pcall(function() studioHistory:SetWaypoint("个人区白模样板") end)
local function vec(v) return {v.X,v.Y,v.Z} end
local function encode(node)
 local out={class=node.ClassName,name=node.Name,attrs=node:GetAttributes(),children={}}
 if node:IsA("BasePart") then
  out.pos={node.CFrame:GetComponents()}
  out.size=vec(node.Size)
  out.color={node.Color.R,node.Color.G,node.Color.B}
  out.collide=node.CanCollide
  out.touch=node.CanTouch
  out.query=node.CanQuery
  out.transparency=node.Transparency
  out.material=node.Material.Value
 elseif node:IsA("SurfaceGui") then
  out.face=node.Face.Value
  out.sizing=node.SizingMode.Value
  out.pixels=node.PixelsPerStud
 elseif node:IsA("TextLabel") then
  out.text=node.Text
  out.font=node.Font.Value
  out.textColor={node.TextColor3.R,node.TextColor3.G,node.TextColor3.B}
 end
 for _,child in ipairs(node:GetChildren()) do table.insert(out.children,encode(child)) end
 return out
end
local changes={world={},home1={},home2={},new=encode(fixtures)}
changes.world["Plots.Plot1.HomeAnchor"]={plot.HomeAnchor.CFrame:GetComponents()}
for i=1,6 do changes.world["Plots.Plot1.ContainerSlots.Slot"..i]={plot.ContainerSlots["Slot"..i].CFrame:GetComponents()} end
-- 保留当前 Studio 中已有的沙地高度。
changes.world["Ground.HarborSand"]={island.Ground.HarborSand.CFrame:GetComponents()}
for level=1,2 do for _,name in ipairs({"FrogSeat","FrogAnchor"}) do changes["home"..level][name]={models["HomeLv"..level][name].CFrame:GetComponents()} end end
return game:GetService("HttpService"):JSONEncode(changes)
