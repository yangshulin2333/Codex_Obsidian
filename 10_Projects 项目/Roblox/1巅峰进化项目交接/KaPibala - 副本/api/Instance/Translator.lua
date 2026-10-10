---@class Translator:Instance @Translator 的职责是为玩家制作/返回本地化的字符串。它可被用来从 LocalizationTable 中检索已做好本地化工作、可供显示的文本。Translator.LocaleId 属性的来源、它将搜索的表集、以及搜索它们的顺序取决于创建 Translator 实例的方法。Translator 的“关键材料”是开发时使用的源语言字符串，以及一组 context（上下文），其全部或部分可用于为原字符串寻找更为准确/恰当的译文。它还允许制作带有 insert（嵌入）（数据替换）的字符串译文，这些字符串可根据目标语言改变顺序。
---@field LocaleId string @已翻译字符串的区域设置[readonly]  [notreplicated]
local module={}
---@type fun(param:string,param:Variant):string @在 LocalizationTable 中，根据其 Translator 的区域设置，按键值返回本地化的文本字符串。args（参数）表可用于在匹配的文本条目中填入格式参数（可选）。请注意，在下列情况中，此方法会报错：如果此 Translator 可用的 LocalizationTable 均不包含指定键的值。如果键的格式字符串使用的是编号参数，且参数不是数组。如果格式字符串使用的是命名参数，且参数不是包含键-值配对的表。如果参数缺少对应的格式字符串中所使用的参数的值。
---@param string string @要查找并翻译的 Key 值。
---@param Variant Variant @如果 Source（源文本）及翻译包含格式字符串，则为 Lua 值表或键-值配对 Lua 表。具体取决于格式字符串使用的是编号还是命名。
---@return string @本地化的文本字符串
function module:FormatByKey()
end
---@type fun(param:Instance,param:string):string @在 LocalizationTable 中，根据其 Translator 的区域设置，返回本地化的文本字符串。根据给定的源文本，此字符串将被放入提供对象的上下文中。
---@param context Instance @有效的游戏内 Instance，用于上下文覆盖，如上所标示。注意：在不需要上下文覆盖时，此参数可为任意值（比如 game）。
---@param text string @要查找并翻译的 Source（源文本）值。
---@return string @本地化的文本字符串
function module:Translate()
end