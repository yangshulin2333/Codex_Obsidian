local hotpot = _G.ServerHotpot
---@type PlaceManager
local place_manager = hotpot.load.PlaceManager()

local BASETIME = 1769904000
local pvpEff = nil
if place_manager:GetIdByName('pvpsence') == game.PlaceId then
    pvpEff = hotpot:GetPath_Loop('pvpEff',hotpot.Resource)
end
local funs = {
    atk = 'SetAtkEnabled',
    speed = 'SetMoveSpeedEnabled',
    hp = 'SetHpEnabled',
    atkspeed = 'SetAtkSpeedEnabled',
}
local AddTime = 1800
local AddVector = Vector3.new(0,0.2,0)

---@class Server_PvpBuffComponent:Server_PlayerComponent
local c = hotpot.class.new(script,hotpot.files.Server_PlayerComponent())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.data = self.parent.save_data:GetData('pvp_buff')
    self:InitData()

    self.__is_pvp = (place_manager:GetIdByName('pvpsence') == game.PlaceId)

end

function c:InitEff()
    if self.__is_pvp then
        self:AddUpdate(self.Update,1)
    end
end

function c:InitData()
    local now = os.time()
    local mark = math.floor((now - BASETIME) / 86400)
    if mark > self.data.__real.mark then
        self.parent.save_data:Execut(function()
            self.data.mark = mark
            self.data.free = {}
        end)
    end
    return mark
end

function c:GetFreeBuff(str)
    if self.data.__real.free[str] then
        return false,1
    end
    self.parent.save_data:Execut(function()
        self.data.free[str] = true
        self.data.list[str].small = os.time() + AddTime
    end)

    pcall(function()
        if str == 'speed' then
            self.parent.character:SetWalkSpeed(self.parent.prop_cmp:GetPKSpeed())
        end
        if str == 'hp' then
            self.parent.character:RefreshHp()
        end
    end)

    return true,self.data.__real.list[str].small
end

function c:BuyBuff(str,id)
    if id == 1 then
        self.parent.save_data:Execut(function()
            local now = os.time()
            if self.data.list[str].small >= now then
                self.data.list[str].small = self.data.list[str].small + AddTime
            else
                self.data.list[str].small = now + AddTime
            end
        end)
    elseif id == 2 then
        self.parent.save_data:Execut(function()
            local now = os.time()
            if self.data.list[str].big >= now then
                self.data.list[str].big = self.data.list[str].big + AddTime
            else
                self.data.list[str].big = now + AddTime
            end
        end)
    end

    pcall(function()
        if str == 'speed' then
            self.parent.character:SetWalkSpeed(self.parent.prop_cmp:GetPKSpeed())
        end
        if str == 'hp' then
            self.parent.character:RefreshHp()
        end

        self:Fire('syncPvpBuff',self.data.__real.list)
    end)
end

function c:GetAtkPer()
    if not self.__is_pvp then
        return 1
    end
    local now = os.time()
    local big = self.data.__real.list.atk.big
    if big >= now then
        return 2
    end
    local small = self.data.__real.list.atk.small
    if small >= now then
        return 1.5
    end
    return 1
end

function c:GetHPPer()
    if not self.__is_pvp then
        return 1
    end
    local now = os.time()
    local big = self.data.__real.list.hp.big
    if big >= now then
        return 2
    end
    local small = self.data.__real.list.hp.small
    if small >= now then
        return 1.5
    end
    return 1
end

function c:GetMoveSpeedPer()
    if not self.__is_pvp then
        return 1
    end
    local now = os.time()
    local big = self.data.__real.list.speed.big
    if big >= now then
        return 2
    end
    local small = self.data.__real.list.speed.small
    if small >= now then
        return 1.5
    end
    return 1
end

function c:Update()
    local now = os.time()
    for str,data in pairs(self.data.__real.list) do
        if data.big >= now then
            self[funs[str]](self,true)
        else
            if data.small >= now then
                self[funs[str]](self,true,true)
            else
                self[funs[str]](self,false)
            end
        end
    end
end

function c:SetAtkEnabled(enabled)
    if self.atk_enabled == enabled then
        return
    end
    self.atk_enabled = enabled

    if not (self.parent.character and self.parent.character.root_part) then
        return
    end

    if enabled then
        local atk_part = pvpEff:FindFirstChild('atk')
        self.atk_part = hotpot:CloneInst_Loop(atk_part)
        self.atk_part.Parent = self.parent.character.main_inst
        self.atk_part.Position = self.parent.character:GetBottomPosition() + AddVector
        local weld = self.atk_part:FindFirstChild('WeldConstraint')
        if weld then
            weld.Part1 = self.parent.character.root_part
            weld.Part0 = self.atk_part
            weld.Enabled = true
        end
        
    else
        if self.atk_part then
            self.atk_part:Destroy()
            self.atk_part = nil
        end
    end
end

function c:SetMoveSpeedEnabled(enabled,ischange)
    if ischange then
        pcall(function()
            self.parent.character:SetWalkSpeed(self.parent.prop_cmp:GetPKSpeed())
        end)
    end
    if self.move_speed_enabled == enabled then
        return
    end
    self.move_speed_enabled = enabled
    if enabled then
        pcall(function()
            self.parent.character:SetWalkSpeed(self.parent.prop_cmp:GetPKSpeed())
        end)
        local speed_part = pvpEff:FindFirstChild('speed')
        self.speed_part = hotpot:CloneInst_Loop(speed_part)
        self.speed_part.Parent = self.parent.character.main_inst
        self.speed_part.Position = self.parent.character:GetBottomPosition() + AddVector
        local weld = self.speed_part:FindFirstChild('WeldConstraint')
        if weld then
            weld.Part1 = self.parent.character.root_part
            weld.Part0 = self.speed_part
            weld.Enabled = true
        end
    else
        pcall(function()
            self.parent.character:SetWalkSpeed(self.parent.prop_cmp:GetPKSpeed())
        end)
        if self.speed_part then
            self.speed_part:Destroy()
            self.speed_part = nil
        end
    end
end

function c:SetHpEnabled(enabled,ischange)
    if ischange then
        pcall(function()
            self.parent.character:RefreshHp()
        end)
    end
    if self.hp_enabled == enabled then
        return
    end
    self.hp_enabled = enabled
    if enabled then
        pcall(function()
            self.parent.character:RefreshHp()
        end)
        local hp_part = pvpEff:FindFirstChild('hp')
        self.hp_part = hotpot:CloneInst_Loop(hp_part)
        self.hp_part.Parent = self.parent.character.main_inst
        self.hp_part.Position = self.parent.character:GetBottomPosition() + AddVector
        local weld = self.hp_part:FindFirstChild('WeldConstraint')
        if weld then
            weld.Part1 = self.parent.character.root_part
            weld.Part0 = self.hp_part
            weld.Enabled = true
        end
    else
        pcall(function()
            self.parent.character:RefreshHp()
        end)
        if self.hp_part then
            self.hp_part:Destroy()
            self.hp_part = nil
        end
    end
end

function c:SetAtkSpeedEnabled(enabled)
    if self.atk_speed_enabled == enabled then
        return
    end
    self.atk_speed_enabled = enabled
    if enabled then
        local atk_speed_part = pvpEff:FindFirstChild('atkspeed')
        self.atk_speed_part = hotpot:CloneInst_Loop(atk_speed_part)
        self.atk_speed_part.Parent = self.parent.character.main_inst
        self.atk_speed_part.Position = self.parent.character:GetBottomPosition() + AddVector
        local weld = self.atk_speed_part:FindFirstChild('WeldConstraint')
        if weld then
            weld.Part1 = self.parent.character.root_part
            weld.Part0 = self.atk_speed_part
            weld.Enabled = true
        end
    else
        if self.atk_speed_part then
            self.atk_speed_part:Destroy()
            self.atk_speed_part = nil
        end
    end
end

c:RegistFunction('refreshPvpTime',c.InitData)
c:RegistFunction('getFreePvpBuff',c.GetFreeBuff)

return c
