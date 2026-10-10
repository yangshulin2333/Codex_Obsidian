local _G = _G
local script = script
local type = type
local assert = assert
local math = math  
local pairs = pairs
local UDim2 = UDim2

local hotpot = _G.ClientHotpot
local callback_manager = hotpot.load.CallBackManager()
---@type BtnHelper
local btnHelper = hotpot.load.BtnHelper()
---@class HotpotScreenBase:GameObject
---@field main_inst LayerCollector
local c = hotpot.class.new(script,hotpot.files.GameObject())
local myFunc = {}
local group = {}
local function CreatOww()
    ---@type ImageButton
    local inst = Instance.new("TextButton")
    inst.AutoButtonColor = false
    inst.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
    inst.BackgroundTransparency = 0.6
    inst.AnchorPoint = Vector2.new(0.5,0.5)
    inst.Position = UDim2.fromScale(0.5,0.5)
    inst.Size = UDim2.fromScale(1,1)
    inst.ZIndex = -1
    inst.TextStrokeTransparency = 1
    inst.TextTransparency = 1
    inst:SetAttribute("ignore_btn_init",true)
    return inst
end
---@type TextButton @外层黑色模糊
local oowPrefab = CreatOww()
---@type TextButton @ui底部大小的防击穿
local clickWall = oowPrefab:Clone()
clickWall.Transparency = 1
clickWall.AutoButtonColor = false
local __strokes,__screen_listen = {}
local screenSize,xScale,yScale = 0,0,0
local lfunc = {}
---@param self HotpotUIBase
function lfunc.GetInst(self,var)
    if type(var) == "table" then
        local new_tab = {}
        for i,v in pairs(var) do
            new_tab[i] = lfunc.GetInst(self,v)
        end
        return new_tab
    elseif type(var) == "string" then
        return self:WaitForChild_Loop(var)
    end
end
function c.new(screen)
    return c(screen)
end
---@param screen ScreenGui
local function InitScreen(screen)
    screen.IgnoreGuiInset = true
    screen.ResetOnSpawn = false
end
function c:ctor(screen,is_group,layout)
    c.super.ctor(self,screen)
    InitScreen(screen)
    if self.insts then
        self.insts = lfunc.GetInst(self,self.insts)
    end
    self.__strokes = {}
    myFunc.InitUIChilds(self)
    self.group = is_group
    if is_group then
        group[self] = true
    end
end
function c:dtor()
    self.main_inst:Destroy()
    c.super.dtor(self)
end
function c:Show()
    if self.group then
        for obj,_ in pairs(group)do
            if obj ~= self then
                obj:Hide()
            end
        end
    end
    if self.OnShow then
        self:OnShow()
    end
    self.main_inst.Enabled = true
end
function c:Hide()
    if self.OnHide then
        self:OnHide()
    end
    self.main_inst.Enabled = false
end
function c:IsVisible()
    return self.main_inst.Enabled
end
function c:InitButton(btn)
    btnHelper:InitButton(btn)
end
---@return nil @创建防击穿底板
function c:CreatOOW(mainFrame,justCloseSelf,closeBtn)
    assert(mainFrame,"no frame")
    if not self.main_inst then
        warn("no main_inst!pls check",self.ClassName)
        return
    end
    ---@type TextButton @关闭底板
    local tempOOw = oowPrefab:Clone()
    tempOOw.ZIndex = mainFrame.ZIndex - 2
    tempOOw.Parent = mainFrame.Parent
    self.__oow = tempOOw
    --防击穿底板
    local tempClickWall = clickWall:Clone()
    tempClickWall.SizeConstraint = mainFrame.SizeConstraint
    tempClickWall.Size = mainFrame.Size
    tempClickWall.Position = mainFrame.Position
    tempClickWall.ZIndex = mainFrame.ZIndex - 1
    tempClickWall.Parent = mainFrame.Parent
    --加入sizeConstraint
    local uiaspectratio = mainFrame:FindFirstChildWhichIsA("UIAspectRatioConstraint")
    if uiaspectratio then
        uiaspectratio = uiaspectratio:Clone()
        uiaspectratio.Parent = tempClickWall
    end
    --关闭方法
    local closeFunc = function()
        tempClickWall.Visible = false
        mainFrame.Visible = false
        tempOOw.Visible = false
    end
    tempOOw.MouseButton1Click:Connect(function()
        if not justCloseSelf then
            self:Hide() 
        else
            --只关闭自己
            closeFunc()
        end
    end)
    if justCloseSelf then
        local openFunc = function()
            tempClickWall.Visible = true
            mainFrame.Visible = true
            tempOOw.Visible = true
        end
        closeFunc()
        if closeBtn then
            callback_manager:AddRbxConnect(self,closeBtn.MouseButton1Click,function()
                closeFunc()
            end)
        end
        return openFunc,closeFunc,tempClickWall,tempOOw
    end
end
---@return nil 默认遍历所有子对象进行动画
function myFunc.InitUIChilds(self)
    local GuiButton = 'GuiButton'
    local OutOfWindow = 'OutOfWindow'
    local UIStroke = 'UIStroke'
    local ImageButton = 'ImageButton'
    local ImageLabel = 'ImageLabel'
    self:AddProcess(function()
        for __, child in pairs(self.main_inst:GetDescendants()) do
            if child:IsA(GuiButton) and child.Name ~= OutOfWindow then
                btnHelper:InitButton(child)
            elseif child:IsA(UIStroke) then
                self:ListenUIStroke(child)
            end
        end
    end)
end
---@param scorlling_frame ScrollingFrame
---@param ui_grid_layout UIGridLayout
function c:InitUIGridLay(scorlling_frame,ui_grid_layout,bool)
    assert(scorlling_frame,"param scorlling frame is nil")
    assert(ui_grid_layout,"param ui grid layout is nil")
    --检查类型
    assert(scorlling_frame:IsA("ScrollingFrame"),"param scorlling frame must be a ScorllingFrame")
    assert(ui_grid_layout:IsA("UIGridLayout"),"param ui grid layout must be a UIGridLayout")
    local org_cell = ui_grid_layout.CellSize
    local org_padding = ui_grid_layout.CellPadding
    local org_canvas = scorlling_frame.CanvasSize
    callback_manager:AddRbxConnect(self,ui_grid_layout.Changed,function(__,param)
        if param == "AbsoluteCellCount" then
            local canvas = scorlling_frame.CanvasSize
            local canvas_size = scorlling_frame.AbsoluteCanvasSize
            local cell = ui_grid_layout.CellSize
            local padding = ui_grid_layout.CellPadding
            local content_size = ui_grid_layout.AbsoluteContentSize
            local x_per = content_size.X / canvas_size.X
            local y_per = content_size.Y / canvas_size.Y
            local canvas_x = canvas.X.Scale * x_per
            local canvas_y = canvas.Y.Scale * y_per
            if canvas_x <= org_canvas.X.Scale
            and canvas_y <= org_canvas.Y.Scale
            then
                return 
            end
            local cell_x = cell.X.Scale / x_per
            cell_x = bool and cell_x - 0.015 or cell_x
            local cell_y = cell.Y.Scale / y_per
            local padding_x = padding.X.Scale / x_per
            local padding_y = padding.Y.Scale / y_per
            scorlling_frame.CanvasSize = UDim2.fromScale(canvas_x,canvas_y)
            ui_grid_layout.CellSize = UDim2.fromScale(cell_x,cell_y)
            ui_grid_layout.CellPadding = UDim2.fromScale(padding_x,padding_y)
        end
    end)
end
---@param scorlling_frame ScrollingFrame
---@param ui_grid_layout UIGridLayout
function c:InitUIListLay(scorlling_frame,ui_grid_layout)
    assert(scorlling_frame,"param scorlling frame is nil")
    assert(ui_grid_layout,"param ui grid layout is nil")
    --检查类型
    assert(scorlling_frame:IsA("ScrollingFrame"),"param scorlling frame must be a ScorllingFrame")
    assert(ui_grid_layout:IsA("UIGridLayout"),"param ui grid layout must be a UIGridLayout")
    local org_cell = ui_grid_layout.CellSize
    local org_padding = ui_grid_layout.CellPadding
    local org_canvas = scorlling_frame.CanvasSize
    callback_manager:AddRbxConnect(self,ui_grid_layout.Changed,function(__,param)
        if param == "AbsoluteCellCount" then
            local canvas = scorlling_frame.CanvasSize
            local canvas_size = scorlling_frame.AbsoluteCanvasSize
            local cell = ui_grid_layout.CellSize
            local padding = ui_grid_layout.CellPadding
            local content_size = ui_grid_layout.AbsoluteContentSize
            -- local x_per = content_size.X / canvas_size.X
            local y_per = content_size.Y / canvas_size.Y
            -- local canvas_x = canvas.X.Scale * x_per
            local canvas_y = canvas.Y.Scale * y_per
            -- if canvas_x <= org_canvas.X.Scale
            if canvas_y <= org_canvas.Y.Scale
            then
                return 
            end
            -- local cell_x = cell.X.Scale / x_per
            local cell_y = cell.Y.Scale / y_per
            -- local padding_x = padding.X.Scale / x_per
            local padding_y = padding.Y.Scale / y_per
            scorlling_frame.CanvasSize = UDim2.fromScale(canvas.X.Scale,canvas_y)
            ui_grid_layout.CellSize = UDim2.fromScale(cell.X.Scale,cell_y)
            ui_grid_layout.CellPadding = UDim2.fromScale(padding.X.Scale,padding_y)
        end
    end)
end
---@type fun() @所有变化都是基于1920*1080变化，
local function ScreenScaleChange()
    screenSize = workspace.CurrentCamera.ViewportSize
    xScale = screenSize.X/1920
    yScale = screenSize.Y/1080
    --变化倍数
    local min_ratio = xScale < yScale and xScale or yScale
    for stroke,thick in pairs(__strokes) do
        stroke.Thickness = thick * min_ratio
    end
end
---@type fun() @监听描边
---@param uiStroke UIStroke
function c:ListenUIStroke(uiStroke)
    __strokes[uiStroke] = uiStroke.Thickness
    if not __screen_listen then
        screenSize = workspace.CurrentCamera.ViewportSize
        xScale = screenSize.X/1920
        yScale = screenSize.Y/1080
        __screen_listen = self:AddRbxCallBack(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"),ScreenScaleChange)
    end
    --变化倍数
    local min_ratio = xScale < yScale and xScale or yScale
    uiStroke.Thickness = math.max(1,uiStroke.Thickness * min_ratio)
end
return c
