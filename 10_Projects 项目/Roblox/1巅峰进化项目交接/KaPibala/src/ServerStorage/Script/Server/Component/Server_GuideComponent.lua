local hotpot = _G.ServerHotpot

---@class Server_GuideComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('guide')
    self.data2 = self.parent.save_data:GetData('guide2')

    local petData = self.parent.pet_cmp.data.__real
    if self.data.__real.num == 0 and next(petData.list) then
        self.parent.save_data:Execut(function()
            self.data.num = 1
        end)
    end

    if self.parent.prop_cmp.data.__real.reborn > 0 then
        self.parent.save_data:Execut(function()
            self.data2.stage[2] = true
            self.data2.stage[3] = true
            self.data2.stage[4] = true
        end)
        self.parent.save_data:Execut(function()
            self.data2.guild_skill = true
        end)
    else
        local stage = self.parent.stage_cmp:GetMaxStage()
        self.parent.save_data:Execut(function()
            if stage >= 2 then
                self.data2.stage[2] = true
            end
            if stage >= 3 then
                self.data2.stage[3] = true
            end
            if stage >= 4 then
                self.data2.stage[4] = true
            end
        end)

        local lv = self.parent.prop_cmp:GetLv()
        if lv < 8 then
            if self.data2.__real.guild_skill == nil then
                self.parent.save_data:Execut(function()
                    self.data2.guild_skill = false
                end)
            end
        else
            if self.data2.__real.guild_skill == nil then
                self.parent.save_data:Execut(function()
                    self.data2.guild_skill = true
                end)
            end
        end
    end
end

function c:ChangeNum(num)
    self.parent.save_data:Execut(function()
        self.data.num = num
    end)
    self:Fire('GuideChangeNum',num)
end

function c:GetNum()
    return self.data.__real.num
end

function c:InStage(id)
    if self.data2.__real.stage[id] then
        return
    end
    self.parent.save_data:Execut(function()
        self.data2.stage[id] = true
    end)

    self:Fire('GuideInStage',id)
end

function c:Reborn()
    self.parent.save_data:Execut(function()
        self.data2.stage[2] = nil
        self.data2.stage[3] = nil
        self.data2.stage[4] = nil
    end)
end

return c
