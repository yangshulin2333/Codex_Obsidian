local _G = _G
local script = script
local game = game
local assert = assert
local coroutine = coroutine
local ipairs = ipairs
local Enum = Enum
local warn = warn
local hotpot = _G.CommonHotpot
---@type AssetService
local AssetService = game:GetService("AssetService")
---@type TeleportService
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
---@type CallBackManager
local CallBackManager = hotpot.load.CallBackManager()
---@class PlaceManager
local c = hotpot.class.new(script)
-----------------------------------------------------
---@type table<number,string> @场景id到场景名称的印射
local place_to_name = {}
---@type table<string,number> @场景名称到场景id的印射
local name_to_place = {}
---@type table<Player,thread> @存储玩家传送携程，player inst to 携程co
local player_teleport_co = {}
---@type number[]
local place_array = {}
-----------------------------------------------------
--监听传送错误输出
TeleportService.TeleportInitFailed:Connect(function(player_inst,teleport_result,error_message)
    local co = player_teleport_co[player_inst]
    if not co then
        return
    end
    coroutine.resume(co,teleport_result,error_message)
end)
--先拿到宇宙中的信息，并声称对行的数据
local function init()
    local page = AssetService:GetGamePlacesAsync()
    while true do
        for __,info in ipairs(page:GetCurrentPage()) do
            place_to_name[info.PlaceId] = info.Name
            name_to_place[info.Name] = info.PlaceId
            place_array[#place_array+1] = info.PlaceId
        end
        if page.IsFinished then
            break
        else
            page:AdvanceToNextPageAsync()
        end
    end
end
init()

---@type fun(place_id:number):string @根据place id得到场景对应的名称
---@param place_id number
---@return string
function c:GetNameById(place_id)
    return place_to_name[place_id]
end
---@type fun(place_name:string):number @根据place的名称得到场景对应的place_id
---@param place_name string
---@return string
function c:GetIdByName(place_name)
    return name_to_place[place_name]
end
function c:GetPlaceName()
    local place_id = game.PlaceId
    return self:GetNameById(place_id)
end
function c:IsPlayerTeleporting(player)
    assert(player,"param player is nil")
    local player_inst = player.main_inst
    assert(player_inst,"player have no main inst")
    assert(player_inst.ClassName == "Player","player main inst is not a player")
    return player_teleport_co[player]
end
function c:GetStartPlaceId()
    return place_array[1]
end
function c:ReturnStartPlace(player,loading_screen,...)
    local place_id = self:GetStartPlaceId()
    self:TeleportPlayerToPublicPlace(player,place_id,loading_screen,...)
end
---@param player PlayerObject
---@param place_id number
---@param loading_screen ScreenGui
---@vararg any
---@return boolean,Enum.TeleportResult
function c:TeleportPlayerToPublicPlace(player,place_id,loading_screen,...)
    if RunService:IsStudio() then
        return
    end
    assert(player,"param player is nil")
    local player_inst = player.main_inst
    if not player_inst then
        return false
    end
    assert(player_inst,"player have no main inst")
    assert(player_inst.ClassName == "Player","player main inst is not a player")
    assert(place_id,"param place id is nil")
    if player_teleport_co[player_inst] then
        return false,"teleporting"
    end
    player_teleport_co[player_inst] = coroutine.running()
    local r,e = xpcall(TeleportService.Teleport,debug.traceback,TeleportService,place_id,player_inst,{...},loading_screen)
    -- TeleportService:Teleport(place_id,player_inst,{...},loading_screen)
    if not r then
        warn(e)
        return false,e
    end
    local rr,ee = coroutine.yield()
    player_teleport_co[player_inst] = nil
    if r == Enum.TeleportResult.Success then
        return true
    else
        warn(e)
        return false,Enum.TeleportResult
    end
end
---@type fun() @传入到一个指定(place_code)的私人服务器
---@param player_list table @玩家数组{player1,player2}
---@param place_id number @目标placeid
---@param place_code number @CreatePlaceCode函数返回的指定服务器id
---@param teleportData table @传送数据
function c:TeleportPlayerToPrivatePlace(player_list,place_id,place_code,teleportData,loading_screen)
    if RunService:IsStudio() then
        return
    end
    assert(player_list,"param player_list is nil")
    assert(place_id,"param place_id is nil")
    assert(place_code,"param place_code is nil")
    --存放玩家表
    local tele_player_list = {}
    for k,player_obj in ipairs(player_list) do
        ---@type Player
        local player_inst = player_obj.main_inst
        if player_teleport_co[player_inst] then
            warn(string.format("%s is teleporting",player_inst.DisplayName))
            continue
        end
        player_teleport_co[player_inst] = coroutine.running()
        table.insert(tele_player_list,player_inst)
    end
    if not next(tele_player_list) then
        warn("no player dont repeat teleport!!")
        return
    end

    --进行单独传送
    local r,e
    for __,playerInst in pairs(tele_player_list) do
        r,e = xpcall(TeleportService.TeleportToPrivateServer,debug.traceback,TeleportService,place_id,place_code,{playerInst},nil,teleportData,loading_screen)
        print(r,e)
        if not r then
            warn(e)
            return
        end
    end
    --如果有传送失败的就会唤醒
    local rr,ee = coroutine.yield()
    if r == Enum.TeleportResult.Success then
        return true
    else
        warn(e)
        return false,Enum.TeleportResult
    end
    return true
end
function c:CreatePlaceCode(place_id)
    assert(place_id,"param place id is nil")
    local r,e = xpcall(TeleportService.ReserveServer,debug.traceback,TeleportService,place_id)
    if not r then
        return 0
    end
    return e
end
return c