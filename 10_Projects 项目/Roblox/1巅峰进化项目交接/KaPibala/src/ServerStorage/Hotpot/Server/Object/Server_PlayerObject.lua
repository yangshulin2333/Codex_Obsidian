local _G = _G
local assert = asser
local script = script
local xpcall = xpcall
local debug = debug
local warn = warn
local wait = wait
local hotpot = _G.ServerHotpot
---@class Server_PlayerObject:PlayerObject
---@field main_inst Player
local c = hotpot.class.new(script,hotpot.files.PlayerObject())
local event_list = hotpot.event_list
event_list.server_player_character = true
local function_list = hotpot.function_list
local event_manager = hotpot.event_manager
local function_manager = hotpot.function_manager
local instance_manager = hotpot.load.InstanceManager()
---@param player_object Server_PlayerObject
---@param character_inst Model
local function CharacterAdd(player_object,character_inst)
    local character_class_name = player_object:GetServerCharacter()
    local character_class = hotpot.load[character_class_name]()
    ---@type Server_PlayerCharacter
    local character_object = character_class.new(character_inst,player_object)
    player_object.character = character_object
    player_object:CharacterIn(character_object)
    event_manager:Fire(player_object,event_list.server_player_character,character_inst,player_object:GetClientCharacter())
end
---@param player_object Server_PlayerObject
---@param character_inst Model
local function CharacterRemove(player_object,character_inst)
    player_object.character = nil
    local character_object = instance_manager:FindObject(character_inst)
    if character_object then
        player_object:CharacterOut(character_object)
        character_object:dtor()
    end
end
function c:ctor(player_inst)
    c.super.ctor(self,player_inst)
end
function c:dtor()
    c.super.dtor(self)
end
function c:Fire(event,...)
    event_manager:Fire(self,event,...)
end
function c:Invoke(function_name,...)
    function_manager:Invoke(self,function_name,...)
end
function c:Login()
    ---@type Server_PlayerDataComponent
    self.save_data = self:AddComponent(hotpot.load.Server_PlayerDataComponent())
    -- print("data get!")
    ---@type Server_PayLogComponent
    self.pay_log = self:AddComponent(hotpot.load.Server_PayLogComponent())
    -- print("pay log get!")
    if self.OnLogin then
        local r,e = xpcall(self.OnLogin,debug.traceback,self)
        if not r then
            warn(e)
        end
    end
    return self.save_data.__save_data.__real
end
function c:LoginOver()
    if self.OnLoginOver then
        local r,e = xpcall(self.OnLoginOver,debug.traceback,self)
        if not r then
            warn(e)
        end
    end
    self.main_inst.CharacterAdded:Connect(function(character_inst)
        self.__character_creating = true
        if character_inst.Parent then
            local r,e = xpcall(CharacterAdd,debug.traceback,self,character_inst)
            if not r then
                warn(e)
            end
            self.__character_creating = nil
        else
            local cnnt
            cnnt = character_inst.Changed:Connect(function(prop_name)
                if prop_name == "Parent" and character_inst.Parent then
                    cnnt:Disconnect()
                    local r,e = xpcall(CharacterAdd,debug.traceback,self,character_inst)
                    if not r then
                        warn(e)
                    end
                    self.__character_creating = nil
                end
            end)
        end
    end)
    self.main_inst.CharacterRemoving:Connect(function(character_inst)
        local r,e = xpcall(CharacterRemove,debug.traceback,self,character_inst)
        if not r then
            warn(e)
        end
    end)
    local character_inst = self.main_inst.Character
    if character_inst and not self.__character_creating and not self.character then
        self.__character_creating = true
        local r,e = xpcall(CharacterAdd,debug.traceback,self,character_inst)
        if not r then
            warn(e)
        end
        self.__character_creating = nil
    end
end
function c:CreateCharacter()
    self:AddCo()
    self.main_inst:LoadCharacter()
    while not self.character do
        self:Wait()
    end
    wait()
    return self.character
end
function c:RemoveCharacter()
    if self.main_inst and self.main_inst.Character then
        self.main_inst.Character:Destroy()
        self.main_inst.Character = nil
    end
end
function c:SetServerCharacter(class_name)
    assert(class_name,"param class name is nil")
    self.attribute.server_character_name = class_name
end
function c:SetClientCharacter(class_name)
    assert(class_name,"param class name is nil")
    self.attribute.client_character_class = class_name
end
function c:GetServerCharacter()
    return self.attribute.server_character_class or "Server_PlayerCharacter"
end
function c:GetClientCharacter()
    return self.attribute.client_character_class or "Client_PlayerCharacter"
end
function c:CharacterIn(character_object)
    if self.OnCharacterIn then
        self:AddProcess(self.OnCharacterIn,character_object)
    end
end
function c:CharacterOut(character_object)
    if self.OnCharacterOut then
        local co = coroutine.create(self.OnCharacterOut)
        coroutine.resume(co,self,character_object)
        -- self:AddProcess(self.OnCharacterOut,character_object)
    end
end
function_manager:SetHandle(function_list.player_login,c.Login)
function_manager:SetHandle(function_list.player_login_over,c.LoginOver)
return c