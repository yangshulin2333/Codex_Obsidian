---@class plugin:Instance
---@field CollisionEnabled boolean @返回用户是否在 Studio 的 Model （模型）选项卡中启用了 Collisions （碰撞）。
---@field GridSize number @返回用户在 Studio 的 Model（模型）选项卡下设置的网格尺寸。
---@field Deactivation RBXScriptSignal @插件停用时触发
---@field Unloading RBXScriptSignal @在 Plugin 停止运行前立即触发
plugin = {}
---@type fun(exclusiveMouse:boolean) @将调用插件的状态设置为激活
---@param exclusiveMouse boolean
function plugin:Activate(exclusiveMouse) end
---@type fun(pluginGuiId:string,dockWidgetPluginGuiInfo:DockWidgetPluginGuiInfo):DockWidgetPluginGui @该函数会使用给定的 DockWidgetPluginGuiInfo 创建一个 DockWidgetPluginGui
---@param pluginGuiId string
---@param dockWidgetPluginGuiInfo DockWidgetPluginGuiInfo
---@return DockWidgetPluginGui
function plugin:CreateDockWidgetPluginGui(pluginGuiId ,dockWidgetPluginGuiInfo) end
---@type fun(action_id:string,text:string,status_tip:string,icon_name:string,allow_binding:string):PluginAction @创建 PluginAction，也就是在 Roblox Studio 中表示通用可执行动作的对象。与 Toolbar 或 Button 并无直接关联
---@param action_id string
---@param text string
---@param status_tip string
---@param icon_name string
---@param allow_binding boolean
---@return PluginAction
function plugin:CreatePluginAction(action_id,text,status_tip,icon_name,allow_binding) end
---@type fun(id:string,title:string,icon:string):PluginMenu @创建一个新的插件菜单
---@param id string
---@param title string
---@param icon string
---@return PluginMenu
function plugin:CreatePluginMenu(id,title,icon) end
---@type fun(name:string):PluginToolbar @创建一个使用指定名称的新 PluginToolbar。
---@param name string
---@return PluginToolbar
function plugin:CreateToolbar(name) end
---@type fun() @停用插件
function plugin:Deactivate() end
---@type fun():JointCreationMode
---@return JointCreationMode
function plugin:GetJoinMode() end
---@type fun():Mouse @返回一个能与插件配合使用的 Mouse。
---@return Mouse
function plugin:GetMouse() end
---@type fun():RibbonTool @返回当前选择的 RibbonTool。
---@return RibbonTool
function plugin:GetSelectedRibbonTool() end
---@type fun(key:string):table @检索给定键中先前存储的值，如果给定的键不存在，则返回 nil。
---@param key string
---@return table
function plugin:GetSetting(key) end
---@type fun(rig_model:Instance,is_r15:boolean):KeyframeSequence @提示用户打开一个能加载到 rigModel 上的 .fbx 动画文件，然后继续将动画作为 KeyframeSequence 插入 Workspace
---@param rig_model Instance
---@param is_r15 boolean
---@return KeyframeSequence
function plugin:ImportFbxAnimation(rig_model,is_r15) end
---@type fun(is_r15:boolean):Model @提示用户打开一个 .fbx 文件、以网格的形式上传模型的个别组件，然后生成一个可供在动画中使用的角色框架，该框架会加载到 Workspace。
---@param is_r15 boolean
---@return Model
function plugin:ImportFbxRig(is_r15) end
---@type fun():boolean @如果该插件在通过 plugin:Activate 函数激活后，当前处于活动状态，则该函数会返回 true。
---@return boolean
function plugin:IsActivated() end
---@type fun():boolean @如果该插件在通过 plugin:Activate 函数激活后，当前对某一独占鼠标处于活动状态，则该函数会返回 true。如果该函数返回 true，则可以通过 plugin:GetMouse 检索 PluginMouse
---@return boolean
function plugin:IsActivatedWithExclusiveMouse() end
---@type fun(objects:table):table @抵消指定部件，并返回得到的 NegateOperation。
---@param objects table
---@return table
function plugin:Negate(objects) end
---@type fun(script:LuaSourceContainer,line_number:number) @用于在 Roblox Studio 的编辑器窗口当中，打开给定行的给定脚本实例。如果没有给定行作为参数，则会默认为 0。
---@param script LuaSourceContainer
---@param line_number number
function plugin:OpenScript(script,line_number) end
---@type fun(url:string) @打开上下文帮助窗口并访问 url 链接的 wiki 页面。
---@param url string
function plugin:OpenWikiPage(url) end
---@type fun(asset_type:string):number @在 Roblox Studio 中打开一个窗口，窗口会提示用户根据指定的 assetType 选择一种资源。返回所选的 assetId，如果窗口已关闭，则返回 -1。
---@param asset_type string
---@return number
function plugin:PromptForExistingAssetId(asset_type) end
---@type fun(suggested_file_name:string):boolean @提示用户以指定的文件名保存其当前选择。如果用户保存了文件，则返回 true。
---@param suggested_file_name string
---@return boolean
function plugin:PromptSaveSelection(suggested_file_name) end
---@type fun() @打开用户当前选择项的上传窗口。
function plugin:SaveSelectedToRoblox() end
---@type fun(tool:RibbonTool,position:UDim2) @激活指定的 Roblox Studio 工具。 如果工具打开一个窗口，位置参数会指定其应当显示在屏幕的哪个位置。
---@param tool RibbonTool
---@param position UDim2
function plugin:SelectRibbonTool(tool,position) end
---@type fun(objects:table):table @分离指定的 UnionOperation，并返回得到的部件
---@param objects table
---@return table
function plugin:Separate(objects) end
---@type fun(key:string,key:any) @在给定的键下存储一个可供稍后使用的给定值。该值在 Studio 关闭后仍将继续存在。
---@param key string
---@param value any
function plugin:SetSetting(key,value) end
---@type fun(drag_data:table) @给定参数字典后开始拖拽动作
---@param drag_data table
function plugin:StartDrag(drag_data) end
---@type fun(objects:table):Instance @组合指定的部件，并返回得到的 UnionOperation。
---@param objects table
---@return Instance
function plugin:Union(objects) end
