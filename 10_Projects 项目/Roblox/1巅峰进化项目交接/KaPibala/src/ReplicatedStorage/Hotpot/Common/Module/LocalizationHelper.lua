local _G = _G
local xpcall = xpcall
local debug = debug
local script = script
local require = require
local game = game
local Instance = Instance
local hotpot = _G.CommonHotpot
local localization_file = require(hotpot:GetPath_Loop("ReplicatedStorage.Localization", game))
---@type LocalizationTable
local localization_table = Instance.new("LocalizationTable")
localization_table:SetEntries(localization_file)
-- 准备默认翻译
local default_translator = localization_table:GetTranslator("en")
local translator
---@class LocalizationHelper
local c = hotpot.class.new(script)
function c:SetTranslatorByPlayer(player)
    local localization_id = player.LocaleId
    translator = localization_table:GetTranslator(localization_id)
end
function c:Translate(str)
    local r, e = xpcall(translator.FormatByKey, debug.traceback, translator, str)
    if r then
        return e
    end
    if translator then
        r, e = xpcall(default_translator.FormatByKey, debug.traceback, default_translator, str)
        if r then
            return e
        end
    end
    return str
end
return c

