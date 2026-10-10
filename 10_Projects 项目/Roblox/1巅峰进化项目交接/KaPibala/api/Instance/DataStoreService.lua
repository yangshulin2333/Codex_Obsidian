---@class DataStoreService:Instance @DataStoreService 公开那些用来获取 GlobalDataStore 和 OrderedDataStore 对象的方法。由于数据存储只能通过游戏服务器进行访问，因此开发者只能使用 Script 内或 Script 正在使用的 ModuleScript 内的 DataStoreService
---@field AutomaticRetry boolean @设置数据存储函数是否该自动重试。由于技术方面的原因，自动重试已被禁用，因此 DataStoreService 并不支持此属性。如果开发者想进行重试操作，就必须自己实现重试系统。 
local module = {}
---@type fun(param:string,param:string):Instance @根据名称和作用域（选填）来获取 GlobalDataStore
---@param name string @
---@param scope string @
---@return GlobalDataStore
function module:GetDataStore()
end
---@type fun():Instance @返回默认数据存储
---@return GlobalDataStore @默认 GlobalDataStore 实例
function module:GetGlobalDataStore()
end
---@type fun(param:string,param:string) :Instance
---@param name string 
---@param scope string 
---@return OrderedDataStore
function module:GetOrderedDataStore()
end
---@type fun(param:DataStoreRequestType):number @返回给定请求类型可提出的请求数。
---@param requestType DataStoreRequestType
---@return number
function module:GetRequestBudgetForRequestType()
end