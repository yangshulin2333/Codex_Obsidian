local _shared = shared
local xpcall  = xpcall
local require = require
local game    = game
local debug   = debug
local wait    = wait
local warn    = warn 
local folder = script.Parent.Parent
---@type fun(parent_name:string,script_name:string):LuaSourceContainer
---@param parent_name string
---@param script_name string
---@return LuaSourceContainer
local function ErrorProcess(parent_name,script_name)
    local r,e = true
    while r do
        r,e = xpcall(function()
            require(folder:WaitForChild(parent_name,10):WaitForChild(script_name,10))
        end,debug.traceback)
        wait()
    end
    return e
end
---@type fun(parent_name:string,script_name:string):LuaSourceContainer
---@param parent_name string
---@param script_name string
---@return LuaSourceContainer
local function LoadPlugin(parent_name,script_name)
    local r,e = xpcall(function()
        return require(folder:WaitForChild(parent_name,10):WaitForChild(script_name,10))
    end,debug.traceback)
    if not r  then
        warn(e)
        wait()
        e = ErrorProcess(parent_name,script_name)
    end
    return e
end

---@type fun(parent_name:string,script_name:string):LuaSourceContainer
---@param parent_name string
---@param script_name string
---@return LuaSourceContainer
local function GetModuleScript(parent_name,script_name)
    local r,e = xpcall(function()
        return folder:WaitForChild(parent_name,10):WaitForChild(script_name,10)
    end,debug.traceback)
    if not r  then
        warn(e)
        wait()
    end
    return e
end
------------------------------加载服务----------------------------
_shared.Selection 			    = game:GetService("Selection")
_shared.ChangeHistoryService 	= game:GetService("ChangeHistoryService")
_shared.DataStoreService 		= game:GetService("DataStoreService")
_shared.PluginGuiService        = game:GetService("PluginGuiService")
------------------------------加载类-------------------------------
--类  
_shared.Class = LoadPlugin("Object","PluginClass")
--插件类
local base_plugin = LoadPlugin("Object","BasePlugin")
_shared.BasePlugin   = GetModuleScript("Object","BasePlugin")
--配置表
_shared.PluginConfig = LoadPlugin("Object","PluginConfig")
--插件ui
_shared.BaseGui    = GetModuleScript("Gui","BaseGui")
--插件ui
local plugin_gui = LoadPlugin("Gui","PluginGui")
_shared.PluginGui  = plugin_gui


---@type fun()
local function InitPluginGui()
    local config = _shared.PluginConfig
    --创建插件菜单
    local toolbar 	= plugin:CreateToolbar(config.plugin_name)
    --创建插件按钮
    local main_inst  = toolbar:CreateButton(config.plugin_btn_name,config.plugin_btn_tips,config.plugin_btn_icon)
    --创建新的“DockWidgetPluginGuiInfo”对象
    local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,  -- 控件将在浮动面板中初始化
	false,   -- 控件在初始时将启用
	false,  -- 不要覆盖之前的启用状态
	230,    -- 浮窗的默认宽度
	300,    -- 浮窗的默认高度
	230,    -- 浮窗的最小宽度
	300     -- 浮窗的最小高度
    )
    local parent = plugin:CreateDockWidgetPluginGui("TestWidget", widgetInfo)
    parent.Title = utf8.char(36877,36965,23567,21161,25163)

    _shared.PluginGui.new(main_inst,parent)
end
InitPluginGui()