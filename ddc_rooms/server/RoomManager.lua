RoomManager = {}

function RoomManager:constructor()
	self._onElementDestroy = function() self:onElementDestroy() end
	self._onPlayerQuit = function() self:onPlayerLeave(source) end
	self._onPlayerRequestRoomJoin = function(...) self:onPlayerRequestRoomJoin(...) end
	
	self.roomInstances = {}
	self.defaultRooms = {
		{
			name = "Solo Tournament",
			description = "test description",
			password = md5("unison50k"),
			icon = "",
			gamemode = "Deathmatch",
			mapPrefix = "DM",
		},
		{
			name = "Training",
			description = "Start training and prepare yourself for the tournament!",
			icon = "",
			gamemode = "Deathmatch",
			mapPrefix = "DM"
		},
		{
			name = "Fun Deathmatch",
			description = "test description",
			icon = "",
			gamemode = "Deathmatch",
			mapPrefix = "DM",
			settings = {
				WFFMode	= true
			}
		}
	}
	
	-- create all rooms
	for _, roomInfo in ipairs(self.defaultRooms) do
		self:addRoom(roomInfo)
	end
	
	-- remove table as we dont need it anymore
	self.defaultRooms = nil
	
	addEvent("onPlayerRequestRoomJoin", true)
	addEventHandler("onPlayerRequestRoomJoin", root, self._onPlayerRequestRoomJoin)
	addEventHandler("onPlayerQuit", root, self._onPlayerQuit)
end

function RoomManager:addRoom(roomInfo)
	local gamemodeClassName = roomInfo.gamemode
	
	if (not gamemodeClassName or type(_G[gamemodeClassName]) ~= "table") then
		return false
	end
	
	local room = Element("room")
	
	-- add destroy handle to kick players back to lobby
	addEventHandler("onElementDestroy", room, self._onElementDestroy)

	self.roomInstances[room] = new(_G[gamemodeClassName], room, roomInfo.mapPrefix, (roomInfo.settings or {}))
	
	-- apply element data
	for _, field in ipairs({"name", "description", "password", "icon", "gamemode", "settings"}) do
		if (roomInfo[field]) then
			-- Ensure elements are created firstly on the client
			Timer(function()
				exports.ddc_core:setData(room, field, roomInfo[field], true)
			end, 50, 1)
		end
	end
end

function RoomManager:onPlayerLeave(player)
	local room = player:getParent()

	if (not room or room:getType() ~= "room") then
		return
	end
	
	local roomInstance = self:getRoomInstance(room)

	if (roomInstance and roomInstance.onPlayerLeave) then
		roomInstance:onPlayerLeave(player)
	end
		
	player:setParent(root)
	
	triggerClientEvent(room, "onClientPlayerLeaveRoom", resourceRoot, player)
end

function RoomManager:onPlayerRequestRoomJoin(room, password)
	-- variable mismatch
	if (not client or not room or room:getType() ~= "room") then
		return
	end
	
	-- -- provided password is invalid, reset it
	-- if (password and type(password) ~= "string") then
	-- 	password = nil
	-- end
	
	-- local strHashedPassword = room:getData("password")

	-- outputChatBox("ehre3")
	
	-- -- provided password is invalid
	-- if (strHashedPassword and strHashedPassword ~= md5((password or '?'))) then
	-- 	-- TODO: Tell the client that the provided password is incorrect
	-- 	return
	-- end
	
	local roomInstance = self:getRoomInstance(room)
	
	-- there was an error creating the room class, shouldnt really happen at all
	if (not roomInstance) then
		-- TODO: Tell the client that there was an internal error
		return
	end
	
	local gamemode = room:getData("gamemode")
	
	-- already in the same arena
	local prevRoom = client:getParent()

	if (prevRoom and prevRoom:getType() == "room" and room == prevRoom) then
		return
	end

	-- leave previous arena if set
	self:onPlayerLeave(client)
	
	-- set players parent to the room
	client:setParent(room)
	
	-- inform client about the gamemode change and also inform all room players about him joining
	triggerClientEvent(room, "onClientPlayerJoinRoom", resourceRoot, client)
	client:triggerEvent("onClientGamemodeSwitch", resourceRoot, gamemode)
	
	-- call onPlayerJoin method
	if (roomInstance and roomInstance.onPlayerJoin) then
		roomInstance:onPlayerJoin(client)
	end
end

function RoomManager:sendPlayerToLobby(player)
	-- notify room that he left the room
	self:onPlayerLeave(player)
	
	-- send player back to lobby
	player:triggerEvent("onClientGamemodeSwitch", resourceRoot)
end

function RoomManager:onElementDestroy()
	local roomInstance = self:getRoomInstance(source)
	
	-- kick all players to lobby
	for _, player in ipairs(source:getChildren("player")) do
		self:sendPlayerToLobby(player)
	end
	
	-- destroy class object
	delete(roomInstance)
end

function RoomManager:getRoomInstance(value)
	if (value and self.roomInstances[value]) then
		return self.roomInstances[value]
	end
	
	return false
end