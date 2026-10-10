local _G = _G
local script = script
local pairs = pairs
---@type Players
local Players = game:GetService("Players")
---@type Player
local local_player = Players.LocalPlayer
local hotpot = _G.ClientHotpot
---@class UIManager
local c = hotpot.class.new(script)
---@type UIList
c.ui_list = {}
function c:InstallUIList()
    local player_gui = hotpot:GetPath_Loop("PlayerGui", local_player)
    local ui_list = hotpot.load.UIList()
    for name, ui_class in pairs(ui_list) do
        if name ~= "group" then
            ---@type HotpotScreenBase
            local ui = ui_class.new()
            ui:SetParentInstance(player_gui)
            self.ui_list[name] = ui
        end
    end
    if ui_list.group then
        self.group = {}
        for group_name, group_list in pairs(ui_list.group) do
            self.group[group_name] = {}
            for name, __ in pairs(group_list) do
                self.group[group_name][name] = self.ui_list[name]
            end
        end
    end
end
return c
