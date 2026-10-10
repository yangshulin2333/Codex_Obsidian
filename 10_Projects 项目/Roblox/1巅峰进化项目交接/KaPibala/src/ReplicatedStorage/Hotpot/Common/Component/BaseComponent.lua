local _G = _G
local hotpot = _G.CommonHotpot
---@class BaseComponent:BaseObject
local c = hotpot.class.new(script,hotpot.files.BaseObject())
---@param parent GameObject
function c:ctor(parent)
    c.super.ctor(self,parent)
    self.parent = parent
    parent.__components[self.class] = self
end
function c:dtor()
    local parent = self.parent
    if parent then
        parent.__components[self.class] = nil
    end
    c.super.dtor(self)
end
return c