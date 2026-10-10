---@class Instance @Instance 是 Roblox 类层次结构中所有类的基类。Roblox 引擎定义的每个其他类都继承 Instance 的所有成员。无法直接创建 Instance 对象。Instance 具有称为 Instance.new 的特殊函数，用于通过代码创建对象。此函数采用类的名称作为参数并返回创建的对象。无法使用 Instance.new 函数创建抽象类和服务。
---@field Achievable boolean @确定是否可以使用Instance:Clone克隆实例或将其保存到文件
---@field ClassName string @readonly，表示此Instance所属类的只读字符串
---@field Name string @实例的非唯一标识符
---@field Parent Instance @确定实例的层次父级
---@field RobloxLocked boolean @如果为true，则Script或LocalScript不能索引或编辑Instance及其后代，如果尝试则将引发错误 事件
---@field AncestryChanged RBXScriptSignal @当对象或其祖先之一的Instance.Parent属性更改时触发。
---@field AttributeChanged RBXScriptSignal @
---@field Changed RBXScriptSignal @对象属性更改后立即触发f
---@field ChildAdded RBXScriptSignal @当对象作为该实例的父对象时触发
---@field ChildRemoved RBXScriptSignal @从该 Instance 中移除某一子项时触发
---@field DescendantAdded RBXScriptSignal @向 Instance 中添加某一子项时触发
---@field DescendantRemoving RBXScriptSignal @在 Instance 的子类遭移除前立即触发
local module = {}
---函数
---@type fun() @此功能销毁实例的所有子代
function module:ClearAllChildren()
end
---@type fun():Instance @创建一个Roblox实例和其后代的深层副本，其中Archivable = true。
---@return Instance
function module:Clone()
end
---@type fun() @将Instance.Parent属性设置为nil，锁定Instance.Parent属性，断开所有连接并在所有子项上调用Destroy。
function module:Destroy()
end
---@type fun(name:Instance):Instance @返回其Instance.Name等于给定名称的Instance的第一个祖先。
---@param name string @要查找的Instance.Name
---@return Instance @已找到的 Instance。
function module:FindFirstAncestor(name)
end
---@type fun(param:string):Instance @返回 Instance.ClassName 等于给定 className 的 Instance 的第一个父类。
---@param className string @要查找的 Instance.ClassName。
---@return Instance @已找到的 Instance。
function module:FindFirstAncestorOfClass(className)
end
---@type fun(className:string):Instance @返回某一 Instance 的第一个父类，Instance:IsA 用于该 Instance 时对于给定的 className 会返回 true。
---@param className string @要查找的 Instance.ClassName
---@return Instance @已找到的 Instance
function module:FindFirstAncestorWhichIsA(className)
end
---@type fun(name:string,recursive:boolean):Instance @返回具有给定名称的Instance的第一个子代
---@param name string @要搜索的Instance.Name
---@param recursive boolean @默认为flase,搜索是否应该递归进行。
---@return Instance @已找到的 Instance
function module:FindFirstChild(name,recursive)
end
---@type fun(className:string):Instance @返回其ClassName等于给定className的Instance的第一个孩子
---@param className string @要查找的Instance.ClassName
---@return Instance @已找到的 Instance。
function module:FindFirstChildOfClass(className)
end
---@type fun(className:string,recursive:boolean):Instance @返回实例的第一个子对象，对于给定的className，Instance：IsA返回true。
---@param className string @要搜索的Instance.ClassName
---@param recursive boolean @默认为false,搜索是否应该递归进行
---@return Instance @已找到的 Instance。
function module:FindFirstChildWhichIsA(className,recursive)
end
---@type fun(attribute:string):any @
---@param attribute string @
---@return any @
function module:GetAttribute(attribute)
end
---@type fun(attribute:string):RBXScriptSignal @
---@param attribute string @要为其返回更改信号的指定属性的名称
---@return RBXScriptSignal @给定属性更改时触发的事件
function module:GetAttributeChangedSignal(attribute)
end
---@type fun():table<string,any> @该函数为每个属性返回一个字符串→变体对的字典，其中字符串是属性的名称，而变体是非nil值
---@return table<string,any> @每个属性的字符串→变量对的字典，其中字符串是属性的名称，变量是非nil值
function module:GetAttributes()
end
---@type fun():Instance[] @返回包含实例的所有子代的数组
---@return Instance[] @包含实例的子代的数组
function module:GetChildren()
end
---@type fun(scopeLength:number):string @返回供 Roblox 内部使用的 Instance DebugId 的编码字符串
---@param scopeLength string @默认为4,长度范围
---@return string @DebugID字符串
function module:GetDebugId(scopeLength)
end
---@type fun():Instance[] @返回包含实例的所有后代的数组
---@return Instance[] @包含实例的后代的数组
function module:GetDescendants()
end
---@type fun():string @返回描述实例祖先的字符串
---@return string @实例的全名
function module:GetFullName()
end
---@type fun(property:string):RBXScriptSignal @获取一个事件，该事件在对象的给定属性更改时触发
---@param property string @
---@return RBXScriptSignal @
function module:GetPropertyChangedSignal(property)
end
---@type fun(className:string):boolean @如果实例的类与给定类匹配或继承，则返回true
---@param className string | " 'BasePart' " | " 'ParticleEmitter' " @将根据其实例检查类别的类别。区分大小写。
---@return boolean @描述实例的类是否匹配或是给定类的子类
function module:IsA(className)
end
---@type fun(descendant:Instance):boolean @如果某一 Instance 是给定子类的父类，则返回 true
---@param descendant Instance @子类 Instance
---@return boolean @如果 Instance 是给定子类的父类，则返回 true
function module:IsAncestorOf(descendant)
end
---@type fun(ancestor:Instance):boolean @如果Instance是给定祖先的后代，则返回true
---@param ancestor Instance @祖先实例
---@return boolean @如果Instance是给定祖先的后代，则为True
function module:IsDescendantOf(ancestor)
end
---@type fun(attribute:string,value:any) @
---@param attribute string @设置的属性名称
---@param value any @将指定属性设置为的值
function module:SetAttribute(attribute,value)
end
---@type fun(childName:string,timeOut:number):Instance @返回具有给定名称的Instance的子级。如果子代不存在，它将产生当前线程，直到存在为止
---@param childName string @要查找的Instance.Name
---@param timeOut number @可选的超时参数
---@return Instance @找到实例
function module:WaitForChild(childName,timeOut)
end
