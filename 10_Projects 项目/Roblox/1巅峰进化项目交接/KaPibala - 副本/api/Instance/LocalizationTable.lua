---@class LocalizationTable:Instance @LocalizationTable 是一个翻译的数据库，里面含有源字符串和其对应的多国语言翻译。它和 Translator 以及 LocalizationService 自动翻译系统一起使用来控制游戏中的文本翻译。
---@field SourceLocaleId string @源字符串的区域设置
local module = {}
---@type fun():table @返回一个字典数组，其中每一个字典代表着一个装有本地化数据的条目。
---@return table
function module:GetEntries()
end
---@type fun(param:string):Translator @以指定的语言为 LocalizationTable 中的键返回一个 Translator。
---@param localeId string
---@return Translator
function module:GetTranslator(localeId)
end
---@type fun(param:string,param:string,param:string) @从 LocalizationTable 中移除一个条目，根据指定的键，源和内容来选定要移除的条目。
---@param key string
---@param source string
---@param context string
function module:RemoveEntry(key,source,context)
end
---@type fun(param:string,param:string,param:string,param:string) @从 LocalizationTable 中移除一个语言的翻译，根据提供的键，源，内容和 localeId 来选定要移除的条目。
---@param key string
---@param source string
---@param context string
---@param localeId string
function module:RemoveEntryValue(key,source,context,localeId)
end
---@type fun(param:string) @根据指定的 localeId 从 LocalizationTable 中移除所有翻译。
---@param localeId string
function module:RemoveTargetLocale(localeId)
end
---@type fun(param:table) @设置 LocalizationTable 的内容。 条目参数的格式应当为字典数组，与 `LocalizationTable/GetEntries` 函数返回的数组格式相同。
---@param entries table
function module:SetEntries(entries)
end
---@type fun(param:string,param:string,param:string,param:string) @将 LocalizationTable 条目的 Context 字段设为 newContext ，使用特定的键、源和上下文来缩小范围寻找需要进行改动的条目。
---@param key string
---@param source string
---@param context string
---@param newContext string
function module:SetEntryContext(key,source,context,newContext)
end
---@type fun(param:string,param:string,param:string,param:string) @将 LocalizationTable 条目的 Example 字段设为 example ，使用特定的键、源和上下文来缩小范围寻找需要进行改动的条目。
---@param key string
---@param source string
---@param context string
---@param example string
function module:SetEntryExample(key,source,context,example)
end
---@type fun(param:string,param:string,param:string,param:string) @将 LocalizationTable 条目的 Key 字段设为 newKey ，使用特定的键、源和上下文来缩小范围寻找需要进行改动的条目。
---@param key string
---@param source string
---@param context string
---@param newKey string
function module:SetEntryKey(key,source,context,newKey)
end
---@type fun(param:string,param:string,param:string,param:string) @将 LocalizationTable 条目的 Source 字段设为 newSource ，使用特定的键、源和上下文来缩小范围寻找需要进行改动的条目。
---@param key string
---@param source string
---@param context string
---@param newSource string
function module:SetEntrySource(key,source,context,newSource)
end
---@type fun(param:string,param:string,param:string,param:string,param:string)
---@param key string
---@param source string
---@param context string
---@param localeId string
---@param text string
function module:SetEntryValue(key,source,context,localeId,text)
end