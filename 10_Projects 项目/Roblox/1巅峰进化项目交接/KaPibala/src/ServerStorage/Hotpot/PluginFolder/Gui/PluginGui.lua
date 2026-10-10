local _shared = shared
local script = script
local xpcall  = xpcall
local require = require
local game    = game
local debug   = debug
local wait    = wait
local warn    = warn 
local plugin  = plugin
local DockWidgetPluginGuiInfo = DockWidgetPluginGuiInfo
local Enum = Enum
local utf8 = utf8
local UDim2 = UDim2
local Vector2 = Vector2
local Instance = Instance
local Color3 = Color3
local print = print
---@class PluginGui
local c = _shared.Class.new(script,_shared.BaseGui)
---@type fun(main_inst:Instance,parent:Instance)
function c.new(main_inst,parent)
    return c(main_inst,parent)
end
---@type fun()
function c:ctor(main_inst,parent)
    c.super.ctor(self)
    self.main_inst = main_inst
    self.parent = parent
    --ui表
    self.insts = {}

    self:CreatMain()

    self:InitPerfab()
    self:CreatDataFrame()
    self:AddBtn()
    
    self:BindEvent()
end
---@param scorlling_frame ScrollingFrame
---@param ui_grid_layout UIGridLayout
---@param show_scrollbar boolean @传入真时自判定是否不管scroll的滑动条维度
local function InitUIGridLay(scorlling_frame,ui_grid_layout,show_scrollbar)
    assert(scorlling_frame,"param scorlling frame is nil")
    assert(ui_grid_layout,"param ui grid layout is nil")
    --检查类型
    assert(scorlling_frame:IsA("ScrollingFrame"),"param scorlling frame must be a ScorllingFrame")
    assert(ui_grid_layout:IsA("UIGridLayout"),"param ui grid layout must be a UIGridLayout")
    local org_cell = ui_grid_layout.CellSize
    local org_padding = ui_grid_layout.CellPadding
    local org_canvas = scorlling_frame.CanvasSize
    ui_grid_layout.Changed:Connect(function(__,param)
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
            local cell_y = cell.Y.Scale / y_per
            local padding_x = padding.X.Scale / x_per
            local padding_y = padding.Y.Scale / y_per
            if show_scrollbar then
                --横向滑动
                if scorlling_frame.ScrollingDirection == Enum.ScrollingDirection.X then
                    canvas_y = org_canvas.Y.Scale
                    cell_y = org_cell.Y.Scale
                    padding_y = org_padding.Y.Scale
                    --垂直滑动
                elseif scorlling_frame.ScrollingDirection == Enum.ScrollingDirection.Y then
                    canvas_x = org_canvas.X.Scale
                    cell_x = org_cell.X.Scale
                    padding_x = org_padding.X.Scale
                end
            end
            scorlling_frame.CanvasSize = UDim2.fromScale(canvas_x,canvas_y)
            ui_grid_layout.CellSize = UDim2.fromScale(cell_x,cell_y)
            ui_grid_layout.CellPadding = UDim2.fromScale(padding_x,padding_y)
        end
    end)
end
---@type fun()
function c:BindEvent()
    local parent = self.parent
    parent:BindToClose(function()
        if self.insts.main_scroll.Visible then
            self.main_inst.Enabled = false
        else
            self:CloseAllFrame()
            self.insts.main_scroll.Visible = true
        end
    end)
    self.main_inst.Click:Connect(function()
        if self.parent.Enabled then
            self.parent.Enabled = false
        else
            self:CloseAllFrame()
            self.insts.main_scroll.Visible = true
            self.parent.Enabled = true
        end
    end)
    self.data_btn.MouseButton1Click:Connect(function()
        self.insts.main_scroll.Visible = false
        self.insts.data_scroll.Visible = true
    end)
end
---@type fun()
function c:CloseAllFrame()
    self.insts.data_scroll.Visible = false
end
---@type fun()
function c:CreatMain()
    local parent = self.parent
    ---@type ImageLabel
    self.insts.main_bg = self:InstanceNew("ImageLabel",parent,"Bg")
    print(self.insts.main_bg)
    self.insts.main_bg.BorderSizePixel = 2
    self.insts.main_bg.Size = UDim2.new(1,0,1,0)
    ---@type ScrollingFrame
    self.insts.main_scroll = self:InstanceNew("ScrollingFrame",self.insts.main_bg,"Main_Bg")
    self.insts.main_scroll.AnchorPoint = Vector2.new(0.5,0)
    self.insts.main_scroll.BackgroundTransparency = 1
    self.insts.main_scroll.Position = UDim2.new(0.513,0,0.103,0)
    self.insts.main_scroll.Size = UDim2.new(0.974,0,0.897,0)
    ---@type UIGridLayout
    self.insts.main_grid_layout = Instance.new("UIGridLayout")
    self.insts.main_grid_layout.CellPadding = UDim2.new(0.04,0,0.1,0)
    self.insts.main_grid_layout.CellSize = UDim2.new(0,50,0,50)
    self.insts.main_grid_layout.Parent = self.insts.main_scroll
    ---@type TextLabel
    local inst = self:InstanceNew("TextLabel",self.insts.main_bg)
    inst.AnchorPoint = Vector2.new(1,0.5)
    inst.BackgroundColor3 = Color3.fromRGB(41,41,41)
    inst.Position = UDim2.new(1,0,0.5,0)
    inst.Size = UDim2.new(0.059,0,1,0)
    inst.ZIndex = 0
    inst.TextTransparency = 1
    InitUIGridLay(self.insts.main_scroll,self.insts.main_grid_layout)
end
---@type fun()
function c:CreatDataFrame()
    ---@type ScrollingFrame
    self.insts.data_scroll = self:InstanceNew("ScrollingFrame",self.insts.main_bg,"Data_Bg")
    self.insts.data_scroll.AnchorPoint = Vector2.new(0.5,0)
    self.insts.data_scroll.BackgroundTransparency = 1
    self.insts.data_scroll.Position = UDim2.new(0.513,0,0.103,0)
    self.insts.data_scroll.Size = UDim2.new(0.974,0,0.897,0)
    self.insts.data_scroll.Visible = false
    ---@type UIGridLayout
    self.insts.data_grid_layout = Instance.new("UIGridLayout")
    self.insts.data_grid_layout.CellPadding = UDim2.new(0.04,0,0.1,0)
    self.insts.data_grid_layout.CellSize = UDim2.new(0.2,0,0.15,0)
    self.insts.data_grid_layout.Parent = self.insts.data_scroll
    InitUIGridLay(self.insts.data_scroll,self.insts.data_grid_layout)
end
---@type fun()
function c:AddBtn()
    --data
    ---@type ImageButton
    self.data_btn = self.main_perfab:Clone()
    self.data_btn.Image = "rbxassetid://10620836366"
    local txt = self.data_btn:WaitForChild("TextLabel",1)
    txt.Text = utf8.char(23384,26723,25805,20316)
    self.data_btn.Parent = self.insts.main_scroll
end
---@type fun()
function c:InitPerfab()
    ---@type ImageButton
    self.main_perfab = Instance.new("ImageButton")
    self.main_perfab.AutoButtonColor = false
    local txt = Instance.new("TextLabel")
    txt.AnchorPoint = Vector2.new(0.5,0)
    txt.BackgroundTransparency = 1
    txt.Position = UDim2.new(0.5,0,1.1,0)
    txt.Size = UDim2.new(1.1,0,0.4,0)
    txt.TextScaled = true
    txt.TextColor3 =  Color3.fromRGB(194, 194, 194)
    txt.Parent = self.main_perfab
end
---@type fun(str:string,parent:Instance,name:string):Instance
---@param str string
---@param parent Instance
---@param name string
---@return Instance
function c:InstanceNew(str,parent,name)
    local inst = Instance.new(str)
    if not inst then
        print("str is error!")
        return
    end
    inst.AnchorPoint = Vector2.new(0.5,0.5)
    inst.BackgroundColor3 = Color3.fromRGB(63,63,63)
    inst.BackgroundTransparency = 0
    inst.BorderSizePixel = 0
    inst.Position = UDim2.fromScale(0.5,0.5)
    inst.Size = UDim2.new(1,0,1,0)
    if inst:IsA("TextLabel") or inst:IsA("TextButton") then
        inst.TextColor3 = Color3.fromRGB(194, 194, 194)
        inst.TextScaled = true
    elseif inst:IsA("ImageLabel") or inst:IsA("ImageButton")  then
        inst.ImageTransparency = 1
    elseif inst:IsA("ScrollingFrame") then
        inst.CanvasSize = UDim2.fromScale(0,0,1,0)
        inst.BottomImage = ""
        inst.TopImage = ""
        inst.ScrollBarImageColor3 = Color3.fromRGB(85,85,85)
    end
    if name then
        inst.Name = name
    end
    if parent then
        inst.Parent = parent
    end
    return inst
end
return c