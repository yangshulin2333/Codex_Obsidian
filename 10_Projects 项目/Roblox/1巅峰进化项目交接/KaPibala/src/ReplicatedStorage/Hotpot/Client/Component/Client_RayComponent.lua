---@type ClientHotpot
local hotpot = _G.ClientHotpot
---@type RayManager
local ray_manager = hotpot.load.RayManager()
local collider_group = hotpot.load.ColliderGroup()

local dir = Vector3.new(0, -1, 0)
local now_cast_result
local raycastResult

---@class Client_RayComponent:BaseComponent
local c = hotpot.class.new(script, hotpot.files.BaseComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self, parent)

    self.raycastParams = RaycastParams.new()
    self.raycastParams.CollisionGroup = collider_group.ray_cast_part
    self.root = self.parent:GetRootPart()
    -- self:Init()

    self.list = ray_manager:GetRayCastList()

    self:StartUpdate()
end
function c:dtor()
    c.super.dtor(self)
end

function c:UpdateRay()
    raycastResult = workspace:Raycast(self.root.Position, dir * 30, self.raycastParams)
    if raycastResult then
        if now_cast_result ~= raycastResult.Instance then
            local lastInst = now_cast_result
            --触发上一个的退出
            if self.list[lastInst] then
                local lastObj = self.list[lastInst].obj
                local handle = self.list[lastInst].out_handle
                if lastObj then
                    if handle then
                        pcall(function()
                            self:AddProcess(function()
                                handle(lastObj, lastInst)
                            end)
                        end)
                    end
                end
            end
            now_cast_result = raycastResult.Instance
            -- 触发进入
            local part = now_cast_result
            if not now_cast_result then
                return
            end
            if self.list[now_cast_result] then
                local obj = self.list[now_cast_result].obj
                local handle = self.list[now_cast_result].in_handle
                if obj then
                    if handle then
                        pcall(function()
                            self:AddProcess(function()
                                handle(obj, part)
                            end)
                        end)
                    end
                end
            end
        end
    else
        if now_cast_result then
            local part = now_cast_result
            now_cast_result = nil
            -- 触发退出
            if self.list[part] then
                local obj = self.list[part].obj
                if obj then
                    local handle = self.list[part].out_handle
                    if handle then
                        self:AddProcess(function()
                            handle(obj, part)
                        end)
                    end
                end
            end
        end
    end
end

---开启更新
function c:StartUpdate()
    if self.__ray_update then
        return
    end
    self.__ray_update = self:AddUpdate(self.UpdateRay)
end
---停止更新
function c:StopUpdate()
    if self.__ray_update then
        self.__ray_update:Disconnect()
        self.__ray_update = nil
    end
end

return c
