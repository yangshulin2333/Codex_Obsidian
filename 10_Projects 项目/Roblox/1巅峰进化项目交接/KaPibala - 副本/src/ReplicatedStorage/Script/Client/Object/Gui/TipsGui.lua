---@type ClientHotpot
local hotpot = _G.ClientHotpot
---@type DataBroadCenter
local data_broad_center = hotpot.load.DataBroadCenter()
local TweenHelper = hotpot.load.TweenHelper()
---@type CallBackManager
local CallBackManager = hotpot.load.CallBackManager()
---@type LocalizationHelper
local LocalizationHelper = hotpot.load.LocalizationHelper()
---@type Client_AudioManager
local audio_player = hotpot.load.Client_AudioManager()
---@class TipsGui:HotpotScreenBase
local c = hotpot.class.new(script,hotpot.files.HotpotScreenBase())
function c.new()
    return c()
end 
c.insts = {}
---@type Frame
c.insts.frame = "Frame"
---@type TextLabel
c.insts.tips_pfb = 'Frame.TipsPfb'
function c:ctor()
    local main_inst = hotpot:GetPath_Loop("ReplicatedStorage.Resource.ui.TipsGui")
    c.super.ctor(self,main_inst,false,true)
    self.show_list = {}
    self:WatchGlobal("tip_show",self.WatchTipMessage)
end
function c:Hide()
    c.super.Hide(self)
end
function c:Show()
    c.super.Show(self)
end
local colorTable = {
    ["success"] = Color3.fromHex("#3bec2b"),
    ["warn"] = Color3.fromHex("#fb9b04"),
    ["fail"] = Color3.fromHex("#ff4f4f"),
    ["normal"] = Color3.fromHex("#bfcedf")
}
local soundTable = {
    ["warn"] = "notice_propfail",
    ["fail"] = "notice_propfail",
    ["normal"] = "notice_prop",
}
---@type fun(msg:string,color:string)
---@param msg string
---@param color string
function c:WatchTipMessage(__,msg,color)
    self:TipsMessage(msg, color)
end
---@type fun(msg:string,color:string,timer:number)
---@param msg string
---@param color string | "'success'" | "'warn'" | "'fail'" | "'normal'"
---@param timer number
function c:TipsMessage(msg, color , timer)
    assert(msg,"msg is nil")
    self:Show()

    pcall(function()
        if color == 'fail' then
            audio_player:PlayGloble('errorMsg')
        end
    end)

    local colorStr = color
    self.insts.frame.Visible = true
    ---@type TextLabel
    local temp = self.insts.tips_pfb:Clone()
    if color and not colorTable[color] then
        temp.TextColor3 = color
    else
        if not color then
            color = "normal"
        end
        color = colorTable[color]
        temp.TextColor3 = color
    end
    colorStr = soundTable[colorStr]
    if colorStr then
        audio_player:PlayGloble(colorStr)
    end
    local tween_time = timer or 1.5
    local info1 = TweenInfo.new(tween_time,3,0,0,false,0.5)
    self.show_list[temp] = true
    temp.Position = UDim2.fromScale(0.5,0.75)
    temp.Text = msg
    temp.Parent = self.insts.frame
    temp.Visible = true
    -- temp.TextSize = 100
    TweenHelper:PlayTween(temp, info1, {
        TextSize = 14,
        TextTransparency = 1,
        TextStrokeTransparency = 1
    }, function()
        self.show_list[temp] = nil
        temp:Destroy()
    end)
    self:StartUpdataShow()
end
---@type fun()
function c:UpdataShow()
    if not next(self.show_list) then
        self:Hide()
        return true
    end
end
---@type fun() 
function c:StartUpdataShow()
    if self.__updata_show_cnnt then
        return
    end
    self.__updata_show_cnnt = self:AddUpdate(self.UpdataShow)
end
---@type fun()
function c:StopUpdataShow()
    if self.__updata_show_cnnt then
        self.__updata_show_cnnt:Disconnect()
        self.__updata_show_cnnt = nil
    end
end
return c