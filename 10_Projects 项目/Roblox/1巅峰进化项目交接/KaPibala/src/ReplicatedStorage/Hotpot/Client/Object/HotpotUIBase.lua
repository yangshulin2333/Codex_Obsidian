local _G = _G
local assert = assert
local script = script
local type = type
local pairs = pairs
local hotpot = _G.ClientHotpot
local callback_manager = hotpot.load.CallBackManager()
---@class HotpotUIBase:GameObject
---@field main_inst GuiObject
local c = hotpot.class.new(script,hotpot.files.GameObject())
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
function c.new(gui)
    return c(gui)
end
function c:ctor(gui)
    c.super.ctor(self,gui)
    --初始化拿资源
    if self.insts then
        self.insts = lfunc.GetInst(self,self.insts)
    end
    if self.OnInputBegan then
        callback_manager:AddRbxConnect(self,self.main_inst.InputBegan,self.OnInputBegan)
    end
    if self.OnInputChanged then
        callback_manager:AddRbxConnect(self,self.main_inst.InputChanged,self.OnInputChanged)
    end
    if self.OnInputEnded then
        callback_manager:AddRbxConnect(self,self.main_inst.InputEnded,self.OnInputEnded)
    end
    if self.OnMouseEnter then
        callback_manager:AddRbxConnect(self,self.main_inst.MouseEnter,self.OnMouseEnter)
    end
    if self.OnMouseLeave then
        callback_manager:AddRbxConnect(self,self.main_inst.MouseLeave,self.OnMouseLeave)
    end
    if self.OnMouseMoved then
        callback_manager:AddRbxConnect(self,self.main_inst.MouseMoved,self.OnMouseMoved)
    end
    if self.OnMouseWheelBackward then
        callback_manager:AddRbxConnect(self,self.main_inst.MouseWheelBackward,self.OnMouseWheelBackward)
    end
    if self.OnMouseWheelForward then
        callback_manager:AddRbxConnect(self,self.main_inst.MouseWheelForward,self.OnMouseWheelForward)
    end
    if self.OnTouchLongPress then
        callback_manager:AddRbxConnect(self,self.main_inst.TouchLongPress,self.OnTouchLongPress)
    end
    if self.OnTouchPinch then
        callback_manager:AddRbxConnect(self,self.main_inst.TouchPinch,self.OnTouchPinch)
    end
    if self.OnTouchRotate then
        callback_manager:AddRbxConnect(self,self.main_inst.TouchRotate,self.OnTouchRotate)
    end
    if self.OnTouchSwipe then
        callback_manager:AddRbxConnect(self,self.main_inst.TouchSwipe,self.OnTouchSwipe)
    end
    if self.OnTouchTap then
        callback_manager:AddRbxConnect(self,self.main_inst.TouchTap,self.OnTouchTap)
    end
end
function c:dtor()
    self.main_inst:Destroy()
    c.super.dtor(self)
end
function c:Show()
    if self.OnShow then
        self:OnShow()
    end
    self.main_inst.Visible = true
end
function c:Hide()
    if self.OnHide then
        self:OnHide()
    end
    self.main_inst.Visible = false
end
---@param scorlling_frame ScrollingFrame
---@param ui_grid_layout UIGridLayout
function c:InitUIGridLay(scorlling_frame,ui_grid_layout)
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
                -- print(org_canvas.X.Scale,org_canvas.Y.Scale)
                -- print(canvas_x,canvas_y)
            -- or cell_x <= org_cell.X.Scale
            -- or cell_y <= org_cell.Y.Scale
            -- or padding_x <= org_padding.X.Scale
            -- or padding_y <= org_padding.Y.Scale
            -- then
            --     print(1,canvas_x <= org_canvas.X.Scale)
            --     print(2,canvas_y <= org_canvas.Y.Scale)
            --     print(3,cell_x <= org_cell.X.Scale)
            --     print(4,cell_y <= org_cell.Y.Scale)
            --     print(5,padding_x <= org_padding.X.Scale)
            --     print(6,padding_y <= org_padding.Y.Scale)
                return 
            end
            local cell_x = cell.X.Scale / x_per
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
return c