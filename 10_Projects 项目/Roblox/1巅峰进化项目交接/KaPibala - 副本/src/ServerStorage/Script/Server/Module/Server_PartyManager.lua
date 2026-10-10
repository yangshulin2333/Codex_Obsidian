local hotpot = _G.ServerHotpot
---@type PlaceManager
local place_manager = hotpot.load.PlaceManager()

local partyCfg = hotpot.config.Party
local ROOMID = 0
local loadingGui = hotpot:GetPath_Loop('ui.LoadingGui',hotpot.Resource)

---@class Server_PartyManager:BaseObject
local c = hotpot.class.new(script,hotpot.files.BaseObject())
function c.new(parent)
    return c(parent)
end
function c:ctor(parent)
    c.super.ctor(self,parent)

    self.room_list = {}
end

function c:GetRoomId()
    ROOMID = ROOMID + 1
    return ROOMID
end

---@param player Server_Player
function c:CreateRoom(player,cfgid,roomName,pType,difficulty)
    if player.roomId then
        return false
    end
    if player.join_roomId then
        return false
    end

    local cfg = partyCfg[cfgid]
    if not cfg then
        return false
    end
    local need_lv = cfg['lv'..difficulty]
    local now_lv = player.prop_cmp:GetLv()
    if now_lv < need_lv then
        return false
    end

    local roomId = self:GetRoomId()
    local room = {}
    room.id = roomId
    room.owner = player
    room.cfgid = cfgid
    room.roomName = roomName
    room.pType = pType
    room.difficulty = difficulty
    room.player_list = {}
    room.player_count = 1
    self.room_list[roomId] = room

    hotpot.event_manager:FireAll('CreateRoom',{
        id = roomId,
        roomName = roomName,
        difficulty = difficulty,
        player_count = 1,
        cfgid = cfgid,
        pType = pType,
        uid = player.user_id,
    })

    player.roomId = roomId

    return room
end

function c:RemoveRoom(player,roomId)
    local room = self.room_list[roomId]
    if not room then
        return
    end

    if room.owner ~= player then
        return
    end

    self.room_list[roomId] = nil

    player.roomId = nil

    hotpot.event_manager:FireAll('RemoveRoom',{
        id = roomId,
    })
end

---@param player Server_Player
function c:GetRoomByCfgId(player)
    local list = {}
    for _,v in pairs(self.room_list) do
        table.insert(list,{
            roomId = v.id,
            roomName = v.roomName,
            difficulty = v.difficulty,
            player_count = v.player_count,
            cfgid = v.cfgid,
            pType = v.pType,
            uid = v.owner.user_id,
        })
    end
    return list
end

---@param player Server_Player
function c:PlayerJoinRoom(player,roomId)
    local room = self.room_list[roomId]
    if not room then
        return false,1
    end
    if room.is_teleport then
        return false,2
    end

    local cfgid = room.cfgid
    local difficulty = room.difficulty
    local cfg = partyCfg[cfgid]
    local need_lv = cfg['lv'..difficulty]
    local now_lv = player.prop_cmp:GetLv()
    if now_lv < need_lv then
        return false,3
    end

    ---@type Server_Player
    local roomPlayer = room.owner

    if room.pType == 3 then
        return false,4
    end

    if roomPlayer == player then
        return false,5
    end

    if room.pType == 2 then
        if not player.main_inst:IsFriendsWith(roomPlayer.user_id) then
            return false,6
        end
    end

    if room.player_count >= 4 then
        return false,7
    end

    room.player_count = room.player_count + 1
    room.player_list[player.user_id] = player

    player.join_roomId = roomId

    local players = {}

    table.insert(players,{
        uid = room.owner.user_id,
        name = room.owner:GetDisplayName(),
        lv = room.owner.prop_cmp:GetLv(),
    })

    for k,v in pairs(room.player_list)do
        table.insert(players,{
            uid = v.user_id,
            name = v:GetDisplayName(),
            lv = v.prop_cmp:GetLv(),
        })
    end
    local info = {
        roomId = roomId,
        owner = room.owner.user_id,
        difficulty = room.difficulty,
        cfgid = room.cfgid,
        players = players
    }

    hotpot.event_manager:FireAll('joinRoom',{
        roomId = roomId,
        uid = player.user_id,
        player_count = room.player_count,
        players = players
    })

    return true,info
end

---@param player Server_Player
function c:PlayerLeaveRoom(player,roomId)
    local room = self.room_list[roomId]
    if not room then
        return false
    end

    if room.owner == player then
        return false
    end

    if not room.player_list[player.user_id] then
        return false
    end

    room.player_count = room.player_count - 1
    room.player_list[player.user_id] = nil

    hotpot.event_manager:FireAll('leaveRoom',{
        roomId = roomId,
        uid = player.user_id,
        player_count = room.player_count,
    })

    player.join_roomId = nil

    return true
end

---@param player Server_Player
function c:StartGame(player)
    local room_id = player.roomId
    if not room_id then
        return
    end
    local room = self.room_list[room_id]
    if not room then
        return
    end
    room.is_teleport = true

    local playerCount = 1
    local player_list = {player}
    for k,v in pairs(room.player_list) do
        table.insert(player_list,v)
        playerCount = playerCount + 1
    end

    local place_id = place_manager:GetIdByName('partysence')
    local privatePlaceCode = place_manager:CreatePlaceCode(place_id)


    local r,e = place_manager:TeleportPlayerToPrivatePlace(
        player_list,
        place_id,
        privatePlaceCode,
        {
            cfgid = room.cfgid,
            playerCount = playerCount,
            difficulty = room.difficulty,
        },
        loadingGui
    )
    if not r then
        warn(e)
    end
end

hotpot.function_manager:SetHandle('getRoomList',function(player,cfgId)
    ---@type GameServer
    local server = _G.server

    ---@type Server_PartyManager
    local party_manager = server.party_manager

    return party_manager:GetRoomByCfgId(player,cfgId)
end)

hotpot.function_manager:SetHandle('clientCreateRoom',function(player,roomName,cfgId,pType,difficulty)
    ---@type GameServer
    local server = _G.server

    ---@type Server_PartyManager
    local party_manager = server.party_manager

    local room = party_manager:CreateRoom(player,cfgId,roomName,pType,difficulty)
    return {
        id = room.id,
        roomName = room.roomName,
        difficulty = room.difficulty,
        player_count = room.player_count,
        cfgid = room.cfgid,
        pType = room.pType,
        uid = room.owner.user_id,
    }
end)

hotpot.function_manager:SetHandle('clientDelRoom',function(player,roomId)
    ---@type GameServer
    local server = _G.server

    ---@type Server_PartyManager
    local party_manager = server.party_manager

    local roomId = player.roomId
    if not roomId then
        return
    end
    party_manager:RemoveRoom(player,roomId)

    return true
end)

hotpot.function_manager:SetHandle('clientJoinRoom',function(player,roomId)
    ---@type GameServer
    local server = _G.server

    ---@type Server_PartyManager
    local party_manager = server.party_manager

    if player.roomId then
        return false
    end
    if player.join_roomId then
        return false
    end

    return party_manager:PlayerJoinRoom(player,roomId)
end)

hotpot.function_manager:SetHandle('clientLeaveRoom',function(player)
    ---@type GameServer
    local server = _G.server

    ---@type Server_PartyManager
    local party_manager = server.party_manager

    local roomId = player.join_roomId
    if not roomId then
        return
    end

    return party_manager:PlayerLeaveRoom(player,roomId)
end)

hotpot.function_manager:SetHandle('startPartyGame',function(player)
    ---@type GameServer
    local server = _G.server
    ---@type Server_PartyManager
    local party_manager = server.party_manager
    party_manager:StartGame(player)
end)

return c