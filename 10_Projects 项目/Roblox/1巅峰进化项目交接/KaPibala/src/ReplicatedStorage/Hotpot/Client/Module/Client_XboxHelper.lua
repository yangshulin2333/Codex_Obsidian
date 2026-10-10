---@type ClientHotpot
local hotpot = _G.ClientHotpot
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
---@class Client_XboxHelper
local c = hotpot.class.new(script)
local XBOX_ICON_LIST = {
    y = "rbxassetid://12710283228",
    x = "rbxassetid://12710283041",
    a = "rbxassetid://12710282923",
    b = "rbxassetid://12710282749",
    lb = "rbxassetid://12710282749",
    rb = "rbxassetid://12710282749",
    lt = "rbxassetid://12710282749",
    rt = "rbxassetid://12710282749"
}
---@type fun(inst:Instance,handle:function,btn:KeyCode):function|boolean
---@param inst Instance
---@param handle function
---@param btn KeyCode
---@return function|boolean
function c:BindEvent(inst,handle,btn)
    assert(inst,"inst is nil")
    assert(handle,"handle is nil")
    assert(btn,"btn is nil")
    if not self:Check(inst) then
        return false
    end
    local keycode = btn or  Enum.KeyCode.ButtonA
    inst.Selectable = true
    local r = inst.InputBegan:Connect(function(input)
        if input.KeyCode == keycode then
            handle()
        end
    end)
    return r
end
---@type fun(handle:function,btn:KeyCode,name:string):function|boolean
---@param handle function
---@param btn KeyCode
---@param name string
---@return function|boolean
function c:BindBtnEvent(handle,btn,name)
    assert(handle,"handle is nil")
    assert(btn,"btn is nil")
    local keycode = btn or  Enum.KeyCode.ButtonA
    local function openSpellBook(actionName, inputState, inputObject)
        if inputState == Enum.UserInputState.Begin then
            handle()
        end
    end
    local r =  ContextActionService:BindAction(name, openSpellBook, false,keycode)
    return r
end
---@type fun(inst:Instance):boolean
---@param inst Instance
---@return boolean
function c:XboxGuiEnabledManager(inst)
    assert(inst,"inst is nil")
    if self.gui_list[inst] then
        return false
    end
    self.gui_list[inst] = true
    if self:IsXbox() then
        inst.Visible = true
    else
        inst.Visible = false
    end
    return true
end
---@type fun(name:string):string|boolean
---@param name string 
---@return string|boolean
function c:GetXboxIcomImage(name)
    assert(name,"name is nil")
    if not XBOX_ICON_LIST[name] then
        warn("传入的name错误！")
        return false
    end 
    return XBOX_ICON_LIST[name]
end
---@type fun(name:string,size:UDim2,pos:UDim2,parent:Instance):Instance
---@param name string @X、Y、A、B、LT、RT、LB、RB 大小写都行
---@param size UDim2
---@param pos UDim2
---@param parent Instance
---@return Instance
function c:CreateXboxIcon(name,size,pos,parent)
    assert(name,"name is nil")
    local str = string.lower(name)
    ---@type ImageLabel
    local image_ = Instance.new("ImageLabel")
    image_.Name = "xobx" ..str
    image_.AnchorPoint = UDim2.fromScale(0.5,0.5)
    image_.BackgroundTransparency = 1
    image_.Size = size or UDim2.fromScale(0.5,0.5)
    image_.Position =  pos or UDim2.fromScale(0.5,0.5)
    local image = self:GetXboxIcomImage(str)
    if image then
        image_.Image = image
    end
    if parent then
        image_.Parent = parent
    end
    self:XboxGuiEnabledManager(image_)
    return image_
end
---@type fun()
function c.new()
    return c()
end
function c:ctor()
    --转换表
    self.convert_list = {}
    --事件表
    self.event_list = {}
    --ui管理表
    self.gui_list = {}
    self:Init()
end
---@type fun(self:Client_XboxHelper)
---@param self Client_XboxHelper
local function XboxConnect(self)
    for inst,_ in pairs(self.gui_list) do
        inst.Visible = true
    end
end
---@type fun(self:Client_XboxHelper)
---@param self Client_XboxHelper
local function XboxDisconnect(self)
    for inst,_ in pairs(self.gui_list) do
        inst.Visible = false
    end
end
---@type fun()
function c:Init()
    UserInputService.GamepadConnected:Connect(function(gamepad)
        XboxConnect(self)
    end)
     
    UserInputService.GamepadDisconnected:Connect(function(gamepad)
        XboxDisconnect(self)
    end)
end
---@type fun():boolean
---@return boolean
function c:IsXbox()
    if UserInputService.GamepadEnabled then
       return true
    end
    return false
end 
---@type fun(inst:Instance):boolean
---@param inst Instance.
---@return boolean
function c:Check(inst)
    assert(inst,"inst is nil")
    if not inst:IsA("GuiButton") then
        return false
    end
    return true
end 
return c
