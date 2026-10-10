local hotpot = _G.ServerHotpot

local times = {300,3600}
local freeId = {61,62}

---@class Server_FreePetComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('free_pet')

    self:Init()

    self.mark = os.time()
end

function c:Init()
    if self.data.__real.num == 2 then
        return
    end

end

function c:GetPet()
    if self.data.__real.num == 2 then
        return false
    end
    local need_time,pet_id
    if self.data.__real.num == 0 then
        need_time = times[1]
        pet_id = freeId[1]
    else
        need_time = times[2]
        pet_id = freeId[2]
    end

    local time_ = os.time() - self.mark
    if time_ < need_time then
        return false
    end
    self.mark = os.time()
    self.parent.save_data:Execut(function()
        self.data.num = self.data.num + 1
    end)

    self.parent.pet_cmp:AddPet(pet_id)

    return true,self.data.__real.num
end

c:RegistFunction('getFreePet',c.GetPet)

return c