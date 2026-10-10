local _G = _G
local warn = warn
local script = script
local xpcall = xpcall
local debug = debug
local hotpot = _G.ClientHotpot
---@class Client_PlayerObject:PlayerObject
---@field main_inst Player
local c = hotpot.class.new(script,hotpot.files.PlayerObject())
local instance_manager = hotpot.load.InstanceManager()
local event_list = hotpot.event_list
local function_list = hotpot.function_list
function_list.player_login = true
function_list.player_login_over = true
local function_manager = hotpot.function_manager()
local event_manager = hotpot.event_manager()
function c.new(player_inst)
    return c(player_inst)
end
function c:ctor(player_inst)
    c.super.ctor(self,player_inst)
    -- print("login")
    self:Login()
    -- print("login done")
end
function c:dtor()
    c.super.dtor(self)
end
function c:Login()
    ---@type Client_PlayerDataComponent
    self.save_data = self:AddComponent(hotpot.load.Client_PlayerDataComponent())
    local save_data = function_manager:Invoke(function_list.player_login)
    self.save_data:SetData(save_data)
    if self.OnLogin then
        local r,e = xpcall(self.OnLogin,debug.traceback,self)
        if not r then
            warn(e)
        end
    end
    function_manager:Invoke(function_list.player_login_over)
    if self.OnLoginOver then
        local r,e = xpcall(self.OnLoginOver,debug.traceback,self)
        if not r then
            warn(e)
        end
    end
    self.main_inst.CharacterRemoving:Connect(function(character_inst)
        local character_object = instance_manager:FindObject(character_inst)
        if character_object then
            self:CharacterOut(character_object)
        end
    end)
end
function c:Fire(event,...)
    event_manager:Fire(event,...)
end
function c:Invoke(function_name,...)
    function_manager:Invoke(function_name,...)
end
function c:CharacterIn(character_object)
    ---@type Client_PlayerCharacter
    self.character = character_object
    if self.OnCharacterIn then
        self:AddProcess(self.OnCharacterIn,character_object)
    end
end
function c:CharacterOut(character_object)
    if self.OnCharacterOut then
        self:AddProcess(self.OnCharacterOut,character_object)
    end
    if self.character == character_object then
        self.character = nil
    end
    character_object:AddProcess(character_object.dtor)
end
---@param player_object Client_PlayerObject
event_manager:RegistHandle(event_list.server_player_character,function(player_object,character_inst,character_class_name)
    local character_class = hotpot.load[character_class_name]()
    local character_object = character_class.new(character_inst,player_object)
    player_object:CharacterIn(character_object)
end)
return c