RoomManager = {}

function RoomManager:constructor()
	self.currentGamemodeClassName = false
	self.gamemodeInstance = false
	
	self._onClientGamemodeSwitch = bind(self.onClientGamemodeSwitch, self)
	self._cnClientPlayerJoinRoom = bind(self.onClientPlayerJoinRoom, self)
	self._onClientPlayerLeaveRoom = bind(self.onClientPlayerLeaveRoom, self)
	
	addEvent("onClientGamemodeSwitch", true)
	addEvent("onClientPlayerJoinRoom", true)
	addEvent("onClientPlayerLeaveRoom", true)
	
	addEventHandler("onClientGamemodeSwitch", resourceRoot, self._onClientGamemodeSwitch)
	addEventHandler("onClientPlayerJoinRoom", resourceRoot, self._cnClientPlayerJoinRoom)
	addEventHandler("onClientPlayerLeaveRoom", resourceRoot, self._onClientPlayerLeaveRoom)
	
	-- show lobby
	self:onClientGamemodeSwitch("Lobby")
end

function RoomManager:onClientGamemodeSwitch(gamemodeClassName)
	local gamemodeClassName = gamemodeClassName
	
	-- there was no classname provided, lets assume he got kicked / joined the Lobby
	if (not gamemodeClassName) then
		gamemodeClassName = "Lobby"
	end
	
	-- Gamemode class couldn't be found
	if (not _G[gamemodeClassName] or type(_G[gamemodeClassName]) ~= "table") then
		return
	end
	
	-- player has joined the same gamemode which has been loaded
	if (self:getGamemodeClassName() == gamemodeClassName) then
		if (self:getGamemodeInstance().reset) then
			self:getGamemodeInstance():reset()
		end
	elseif (self:getGamemodeInstance()) then
		-- player switched to a new gamemode
		deleteClass(self:getGamemodeInstance())
	end
	
	-- create gamemode instance and set variables
	self.gamemodeInstance = newClass(_G[gamemodeClassName])
	self.currentGamemodeClassName = gamemodeClassName
end

function RoomManager:onClientPlayerJoinRoom(player)
	if (not self:getGamemodeInstance() or player == localPlayer) then
		return
	end
	
	if (self:getGamemodeInstance().onPlayerJoinRoom) then
		self:getGamemodeInstance():onPlayerJoinRoom(player)
	end
end

function RoomManager:onClientPlayerLeaveRoom(player)
	if (not self:getGamemodeInstance() or player == localPlayer) then
		return
	end
	
	if (self:getGamemodeInstance().onPlayerLeaveRoom) then
		self:getGamemodeInstance():onPlayerLeaveRoom(player)
	end
end

function RoomManager:getGamemodeClassName()
	return self.currentGamemodeClassName
end

function RoomManager:getGamemodeInstance()
	return self.gamemodeInstance
end