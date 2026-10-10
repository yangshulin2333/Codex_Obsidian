---@type fun(param:number,param:function) @设定一个函数在 delayTime 秒后执行，不暂停当前线程。此函数允许同一堆栈中的多个 Lua 线程并行执行。最低延迟持续时间为 29 毫秒，但受目标帧率和其他限流情况影响，此最低数值可能会更高。若未指定 delayTime 参数，将使用最小值。
---@param delayTime number
---@param callback function
function delay(delayTime, callback)
end
---@type fun():DebuggerManager
function DebuggerManager()
end
---@type fun():number @返回自当前 Roblox 实例启动后所经过的总时长。 在 Roblox Studio 中，该数值是从 Roblox Studio 开始运行起计算，而非从打开场景起计算
function elapsedTime()
end
---@type fun():PluginManager @返回之前创造插件时必须的单例 PluginManager，目前已被弃用。其现在仍然有一些实际用途（如需要从 Roblox Studio 的命令栏里创建一个插件对象时）。
function PluginManager()
end
---@type fun(param:string)
---@param perfix string @向输出窗口打印 Current identity is [ID] ，其中 [ID] 对应着当前线程的安全上下文级别。
function printidentity(perfix)
end
---@type fun(param:ModuleScript):any
---@param module ModuleScript
---@return any
function require(module)
end
---@type fun():GlobalSettings @返回 GlobalSettings 对象，可用于访问 Roblox Studio 设置菜单中所使用的设置对象。
---@return GlobalSettings
function settings()
end
---@type fun(param:function) @在一个独立线程中运行指定的回调函数，不暂停当前线程。 该函数会在 Roblox 的 *Task Scheduler（任务排程器）*下次运行更新循环时执行。此延迟至少为 29 毫秒，但受目标帧率和其他限流情况影响，也有可能需要更长时间。
---@param func function
function spawn(func)
end
---@type fun():Stats @返回 Stats 服务。 建议开发者改为使用 ServiceProvider:GetService 来取回该服务
---@return Stats
function stats()
end
---@type fun():number @返回当前本地会话所在的电脑自 UNIX Epoch（UNIX 纪元）开始所经过的时间（以秒为单位）。 UNIX 纪元的开始日期为 1970 年 1 月 1 日。
---@return number
function tick()
end
---@type fun():number @返回自当前游戏实例开始运行起所经过的时间（单位为秒）。 若当前游戏实例未运行，此值为 0。
---@return number
function time()
end
---@type fun(param:any):string @以字符串形式返回指定对象的类型。 此函数比 Lua 的原生 type 函数更准确，因为它不会将 Roblox 特定类型标记为 userdata（用户数据）。
function typeof()
end
---@type fun():UserSettings @返回用于从当前用户的游戏菜单设置中读取信息的 UserSettings 对象。
---@return UserSettings
function UserSettings()
end
---@type fun():string @以字符串形式返回 Roblox 的当前版本。版本字符串中的整数以半角句号分隔，每个整数依次代表以下内容： Generation（世代） - 客户端所在的应用程序壳的当前世代。 Version（版本） - Roblox 的当前发布版本。 Patch（补丁） - 此 Roblox 版本的当前补丁编号。 Commit（提交） - 此客户端版本已接受的最后内部提交 ID。
function version()
end
---@type fun(param:number):number,number @暂停当前线程，在指定秒数之后恢复。 延迟的最短持续时间为 29 毫秒，但受目标帧率和其他限流情况影响，该最短持续时间可能会更高。如果未指定 seconds 参数，将使用最短持续时间。 此函数将返回： 实际暂停时间（以秒为单位） 自软件初始化起所经过的总时间（以秒为单位）
---@param time number
---@return number,number @实际暂定时间、自软件初始化起经过的总时间
function wait(time)
end
---@type fun(param:Tuple)
---@param params Tuple
function warn(params)
end
---@class Plugin @对 Plugin 对象的引用，代表从该 Script 中运行的插件。 此引用仅在脚本作为插件执行的环境中存在。
plugin = {}
---@type table @在所有共享同一执行环境等级的脚本之间共享的表单。 用途同 _G。
shared = {}
---@type LuaSourceContainer @对正在执行您所编写的代码脚本对象的一个引用。 可以为 Script、LocalScript 或 ModuleScript（有时也可为 CoreScript） 当从 Roblox Studio 命令栏执行代码时，此变量不可用。
script = {}
---@type Workspace @对 Workspace 服务的引用，内含一个 Roblox 世界中的所有物理组件。
-- workspace = {}
---@type boolean
continue = {}
---@class InstanceGlobal
Instance = {}
---@type DataModel
game = {}
---@type fun(param:string):Instance
---@param className string | " 'Attachment' " | " 'BodyGyro' " | " 'Folder' " | " 'AnimationController' " | " 'Animation' " | " 'Part' " | " 'NumberValue' " | " 'BoolValue' " | " 'BrickColorValue' " | " 'CFrameValue' " | " 'Color3Value' " | " 'DoubleConstrainedValue' " | " 'IntValue' " | " 'ObjectValue' " | " 'RayValue' " | " 'StringValue' " | " 'Vector3Value' " | " 'Highlight' " | " 'TextButton' " | " 'TextLabel' " | " 'ImageLabel' " | " 'ImageButton' " | " 'WeldConstraint' "
---@param parent Instance
function Instance.new(className,parent)
end