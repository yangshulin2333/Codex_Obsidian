---@class LocalizationService:Instance @本地化服务，为进行自动本地化的服务，其用途为存储用于自动文本替换的 LocalizationTable 对象。
---@field ForForcePlayModeGameLocaleId string @该属性不能被复制[notreplicated]，
---@field ForcePlayModeRobloxLocaleId string @当设为非空白的字符串时，此属性在单人游戏模式中覆盖 LocalizationService.RobloxLocaleId 的值,[notreplicated]
---@field RobloxLocaleId string @本地玩家为其 Roblox 账户所设置的区域设置 id,只读属性，[readonly] [notreplicated]
---@field SystemLocaleId string @本地玩家为其操作系统所设置的区域设置 id,[readonly] [notreplicated]
local module={}
---@type fun():table  @返回 LocalizationService 的子项 LocalizationTable 对象列表。
---@return table  @LocalizationTable 对象列表
function module:GetCorescriptLocalizations()
end
---@type fun(param:Instance):string @根据玩家客户端的 IP 地理位置返回国家/地区代码字符串[yields]
---@param Instance Instance @传入玩家player
---@return string  @国家/地区代码字符串
function module:GetCountryRegionForPlayerAsync()
end
---@type fun(param:Instance):array @获取当前游戏设置本地化所有的Translator与文本
---@param Instance Instance @Translator实例，为空返回所有的Translator
---@return array @返回一个特定的本地化语言数组，数组包含所有本地化文本，
function module:GetTableEntries()
end
---@type fun(param:string):Instance @[yields]该函数会将语言代码作为参数，并直到该区域设置的云本地化资源被加载为止都会暂停。之后会返回 Translator 对象，可以用于为该区域设置提供已有的翻译。该函数可能会发生错误，因此应该被打包至 pcall 中。
---@param string string @传入Roblox 支持的语言代码。当前支持的语言代码有 “en” （英语）、 “fr” （法语）、 “de” （德语）、 “ko” （韩语）、 “pt” （葡萄牙语）以及 “es” （西班牙语）等
---@return Instance @返回一个特定区域设置的 Translator 实例
function module:GetTranslatorForLocaleAsync()
end
---@type fun(param:Instance):Instance @该函数会将玩家作为参数，返回该(Player)玩家的区域设置云本地化数据加载完成，然后返回 Translator 对象，可以用于为该区域设置提供已有的翻译。只会返回内嵌本地化表格中的数据，不会包括任何基于网络的表格数据。
---@param Instance Instance @设为玩家player实例
---@return Instance @返回一个特定区域设置的 Translator 实例
function module:GetTranslatorForPlayer()
end
---@type fun(param:Instance):Instance@[yields]该函数会将玩家作为参数，并直到该玩家的区域设置云本地化数据加载完成为止都会暂停。之后会返回 Translator 对象，可以用于为该区域设置提供已有的翻译。该函数可能会发生错误，因此应该被打包至 pcall 中。
---@param Instance Instance @设为玩家player实例
---@return Instance @返回一个特定区域设置的 Translator 实例
function module:GetTranslatorForPlayerAsync()
end