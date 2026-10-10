local hotpot = _G.ClientHotpot
---@type Players
local Players = game:GetService('Players')
---@type BigNumberHelper
local big_number = hotpot.load.BigNumberHelper()

local uidList = require(game.ReplicatedStorage:WaitForChild('Resource'):WaitForChild('BlackList'))
local day10 = 86400 

---@param val number @秒数
local function GetTime(val)
    --将val转换为x Day y Hour
    local days = math.floor(val / 86400)    -- 1天=86400秒，取整天数
    local remaining = val % 86400           -- 剩余秒数
    local hours = math.floor(remaining / 3600) -- 1小时=3600秒，取整小时数
    
    return string.format("%d Day %d Hour", days, hours)
end

---@class Client_RankObj:ModelObject
local c = hotpot.class.new(script,hotpot.files.ModelObject())
function c.new(model)
    return c(model)
end
function c:ctor(model)
    c.super.ctor(self,model)

    self.scroll = hotpot:GetPath_Loop('root.SurfaceGui.Frame.ScrollingFrame',self.main_inst)

    self.show_list = {}

    self:SetRank({})
end

function c:CheckBlack(list)
    for uid,v in uidList do
        for k,tab in ipairs(list)do
            if tonumber(tab.key) == uid then
                table.remove(list,k)
                break
            end
        end
    end
end

function c:SetRank(list)
    self:CheckBlack(list)

    local isTime = (self.main_inst.Name == 'time') or (self.main_inst.Name == 'christmas_time')
    for i = 1,50 do
        local ui = self.scroll:FindFirstChild(tostring(i))
        if list[i] and ui then
            ui.Visible = true
            local uid = list[i].key

            if not self.show_list[uid] then
                self.show_list[uid] = true
                local value = list[i].value
    
                local r,e = pcall(function()
                    return Players:GetNameFromUserIdAsync(uid)
                end)
                local name = ui:FindFirstChild('name')
                if name then
                    if not r then
                        name.Text = 'UnkownName'
                    else
                        name.Text = e
                    end
                end
                local valueText = ui:FindFirstChild('value')
                if valueText then
                    if isTime then
                        if value > day10 then
                            valueText.Text = GetTime(value)
                        else
                            valueText.Text = big_number:GetTime(value)
                        end
                    else
                        valueText.Text = big_number:ToString(value)
                    end
                end
            end

        else
            if ui then
                ui.Visible = false
            end
        end
    end
end

return c