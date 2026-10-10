---@class ContentProvider:Instance
---@field BaseUrl string @要用 ContentProvider 从 Roblox 网站下载的资源的基础 URL。
---@field RequestQueueSize number @RequestQueueSize 给出 ContentProvider 的请求队列中要加载的项目的数量。
local module = {}
---@type fun(content_id_list:Instance[],call_back_func:function) @此函数以 Instances 数组为参数，会保持暂停直到这些实例关联的所有资产都加载完毕。这可用于暂停脚本，并在确定内容都已加载到游戏之前不去使用特定内容。 调用该函数时，引擎将遍历传入数组中的所有实例（以及这些实例的所有子代）。如果任一实例包括有定义一个连接到内容的属性，例如 Decal 或 Sound，则该函数将尝试从 Roblox 网站加载资产。如果某资产加载失败，places 输出中将显示一条错误消息，但 PreloadAsync 函数本身不会报错，并将继续执行，直到它处理完所有传入的实例。
---@param content_id_list Instance[]
---@param call_back_func function
function module:PreloadAsync(content_id_list,call_back_func)
end
---@type fun(url:string) @设置 ContentProvider.BaseUrl，CoreScripts 使用该参数与 web API 交互。 此函数受限，仅供内部 Roblox 脚本使用。虽然从 Roblox Studio 的命令行可以使用它，但我们建议开发人员不要这样做，因为这可能会阻止资产的加载。
---@param url string
function module:SetBaseUrl(string)
end