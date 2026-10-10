---@class PhysicsService:Instance @PhysicsService 是一项含有使用碰撞组时会用到函数的游戏服务。碰撞组定义一组部件，并控制其是否与其它碰撞组中的部件进行碰撞。使用 SetPartCollisionGroup 可以向碰撞组添加部件。碰撞组及其之间的关系可以通过文件进行存储与加载。
local module = {}
---@type fun(param:string,param:BasePart):boolean @返回部件是否存在于碰撞组中。
---@param name string
---@param part BasePart
---@return boolean
function module:CollisionGroupContainsPart(name,part)
end
---@type fun(param:string,param:string,param:boolean) @设置两个群组之间的碰撞状态。
---@param name1 string
---@param name2 string
---@param collidable boolean
function module:CollisionGroupSetCollidable(name1,name2,collidable)
end
---@type fun(param:string,param:string):boolean @返回两个碰撞组是否会进行碰撞。
---@param name1 string
---@param name2 string
---@return boolean
function module:CollisionGroupsAreCollidable(name1,name2)
end
---@type fun(param:string):number @创建一个指定名称的碰撞组，并返回已创建组的 ID。
---@param name string
---@return number
function module:CreateCollisionGroup(name)
end
---@type fun(param:string):number @返回指定名称群组的 ID。
---@param name string
---@return number
function module:GetCollisionGroupId(name)
end
---@type fun(param:number):string @返回相应碰撞组 ID 的名称。
---@param id number
---@return string
function module:GetCollisionGroupName(id)
end
---@type fun():table @返回包括该场景所有碰撞组信息的表。
---@return table @id int 碰撞组的ID，mask（掩码） 整数 碰撞组的掩码，name(名称) 字符串 碰撞组的名称
function module:GetCollisionGroups()
end
---@type fun():number @返回碰撞群组的最大数量。
---@return number
function module:GetMaxCollisionGroups()
end
---@type fun(param:string) @移除指定名称的碰撞组。
---@param name string
function module:RemoveCollisionGroup(name)
end
---@type fun(param:string,param:string) @对指定碰撞组进行重命名。
---@param old_name string
---@param new_name string
function module:RenameCollisionGroup(old_name,new_name)
end
---@type fun(param:BasePart,param:string) @设置一个部件的碰撞群组。
---@param part BasePart
---@param name string
function module:SetPartCollisionGroup(part,name)
end