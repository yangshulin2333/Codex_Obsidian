---@class ContextActionService:Instance @ContextActionService是一项游戏服务，允许游戏将用户输入绑定到上下文操作或仅在某些条件或一段时间内启用的操作。 例如，允许玩家仅在附近时才打开门。 在代码中，一个动作只是服务用来区分唯一动作的字符串（动作的名称）。 除其他成员函数外，操作字符串还提供给BindAction和UnbindAction。 如果将两个动作绑定到同一输入，则以最近绑定为准。 当最新动作未绑定时，之前的绑定将再次获得控制。 由于ContextActionService处理用户输入，因此只能在客户端上运行的LocalScripts中使用它。
---@field LocalToolEquipped  RBXScriptSignal @当前玩家装备工具时触发。
---@field LocalToolUnequipped RBXScriptSignal @当前玩家取消装备工具时触发。
local module = {}
---@type fun(param:string,param:function,param:boolean,param:InputType,param:Tuple) @BindAction将给定操作处理功能的操作绑定到用户输入。 在执行匹配的输入后，将使用下面列出的参数调用动作处理函数。 有效的输入枚举项包括以下各项：KeyCode，UserInputType或PlayerAction。 当玩家进入可以执行动作的上下文时，调用此函数。 当玩家离开上下文时，使用相同的actionName调用UnbindAction。 您可以使用CallFunction手动调用动作的动作处理功能。
---@param actionName string @代表正在执行的动作的字符串（例如“ HonkHorn”或“ OpenDoor”）
---@param functionToBind string @触发绑定的输入时，使用以下参数调用操作处理函数：字符串（actionName），Enum.UserInputState和InputObject
---@param createTouchButton boolean @是否应为触摸输入设备上的操作创建GUI按钮
---@param inputTypes Tuple @任意数量的Enum.KeyCode或Enum.UserInputType表示要绑定到操作的输入
function module:BindAction(actionName,functionToBind,createTouchButton,inputTypes)
end
---@type fun(param:string,param:function,param:boolean,param:number,param:Tuple) @BindActionAtPriority的行为类似于BindAction，但也允许将优先级分配给绑定的动作。 如果将多个动作绑定到同一输入，则无论绑定动作的顺序如何，都将调用较高优先级的函数。 换句话说，此函数将覆盖BindAction的常规“堆栈”行为。
---@param actionName string @代表正在执行的动作的字符串（例如“ HonkHorn”或“ OpenDoor”）
---@param functionToBind string @触发绑定的输入时，使用以下参数调用操作处理函数：字符串（actionName），Enum.UserInputState和InputObject
---@param createTouchButton boolean @是否应为触摸输入设备上的操作创建GUI按钮
---@param priorityLevel number @绑定操作的优先级（高优先级，低优先级）
---@param inputTypes Tuple @任意数量的Enum.KeyCode或Enum.UserInputType表示要绑定到操作的输入
function module:BindActionAtPriority(actionName,functionToBind,createTouchButton,priorityLevel,inputTypes)
end
---@type fun(param:UserInputType,param:KeyCode) @绑定可与UserInputType一起使用的KeyCode来激活ClickDetector事件和Tool对象。 当给定键
---@param userInputTypeForActivation UserInputType @必须是Keyboard或Gamepad1至Gamepad8
---@param keyCodeForActivation KeyCode @要绑定的KeyCode（例如ButtonX）
function module:BindActivate(userInputTypeForActivation,keyCodeForActivation)
end
---@type fun():table @GetAllBoundActioninfo返回一个表，该表映射所有动作的名称（最初传递给ContextActionService的名称）
---@return table
function module:GetAllBoundActionInfo()
end
---@type fun(param:string):Instance @如果GetButton返回第三个参数为true且设备为TouchEnabled，则返回由BindAction创建的ImageButton。 此函数的唯一参数必须与最初发送给BindAction的动作名称完全匹配。 如果未绑定任何此类操作或未创建按钮，则此函数返回nil。
---@param actionName string @最初传递给BindAction的操作的名称
---@return Instance @由BindAction创建的ImageButton
function module:GetButton(actionName)
end
---@type fun():string @GetCurrentLocalToolIcon将返回播放器当前配备的工具的BackpackItem.TextureId；如果没有此类工具或播放器缺少角色，则返回nil
---@return string @工具的TextureId中的内容字符串；如果找不到，则为nil
function module:GetCurrentLocalToolIcon()
end
---@type fun(param:string,param:string) SetDescription将设置由BindAction绑定的动作的描述。 在可用动作列表中，这将是描述给定动作的文本。 尽管该名称可能暗示此方法与为创建触摸按钮的动作（SetTitle，SetImage和SetPosition）自定义触摸按钮的功能家族有关，但是此方法不会影响这种按钮。 此方法仅设置动作的文本描述，仅此而已。
---@param actionName string @最初传递给BindAction的操作的名称
---@param description string @动作的文字说明，例如“鸣喇叭”或“打开库存”
function module:SetDescription(actionName,description)
end
---@type fun(param:string,param:string) @SetPosition将设置由BindAction创建的触摸按钮上显示的文本。 具体来说，这将在GetButton返回的ImageButton中设置ImageLabel的ImageLabel.Image属性。 如果不存在这样的绑定动作（例如，GetButton不返回任何内容），则此函数不执行任何操作，也不会引发任何错误。 此功能是自定义动作的触摸按钮的方法系列的一部分。 这个家族中的其他人包括SetPosition和SetTitle。
---@param actionName string @最初传递给BindAction的操作的名称
---@param image string @Image属性应设置的值
function module:SetImage(actionName,image)
end
---@type fun(param:string,param:string) @SetTitle将设置BindAction创建的触摸按钮上显示的文本。 具体来说，这将在ImageButton中设置TextLabel的TextLabel.Text属性，该属性将由GetButton返回。 如果不存在这样的绑定动作（例如，GetButton不返回任何内容），则此函数不执行任何操作，也不会引发任何错误。 此功能是自定义动作的触摸按钮的方法系列的一部分。 这个家族中的其他人包括SetImage和SetPosition。
---@param actionName string @最初传递给BindAction的操作的名称
---@param title string @显示在按钮上的文字
function module:SetTitle(actionName,title)
end
---@type fun(param:string,param:UDim2) @SetPosition将设置由BindAction创建的触摸按钮上显示的文本。 具体来说，这将设置GetButton返回的ImageButton的GuiObject.Position属性。 如果不存在这样的绑定动作（例如，GetButton不返回任何内容），则此函数不执行任何操作，也不会引发任何错误。 此功能是自定义动作的触摸按钮的方法系列的一部分。 这个家族中的其他人包括SetImage和SetTitle。
---@param actionName string @最初传递给BindAction的操作的名称
---@param position UDim2 @ContextButtonFrame中的位置 
function module:SetPosition(actionName,position)
end
---@type fun(param:string) @UnbindAction将按名称从用户输入中取消绑定操作，以便不再调用操作处理函数。 当某些操作的上下文不再适用（例如关闭用户界面，下车或不配备工具）时，请调用此函数。 有关绑定操作如何操作的更多信息，请参见BindAction。 如果给定的字符串没有绑定此类操作，则此函数不会引发错误。 使用GetAllBoundActionInfo或开发者控制台的“动作绑定”标签，您可以找出当前绑定的动作。
---@param actionName string
function module:UnbindAction(actionName)
end
---@type fun() @删除所有绑定的函数。不会保留任何actionNames。所有触摸按钮将被删除。如果手动操作了按钮，则不能保证将其清除。
function module:UnbindActivate()
end