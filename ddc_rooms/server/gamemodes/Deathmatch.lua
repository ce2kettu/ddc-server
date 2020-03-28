Deathmatch = {}

function Deathmatch:constructor(room, mapPrefix, settings)
	-- general stuffs
	self.roomElement = room
	self.mapPrefix = mapPrefix
	self.currentRaceState = "none"
	self.isWFFMode = settings.WFFMode == true
	
	-- current / nextmap resource names
	self.currentMapName = false
	self.nextMapName = false
	
	-- countdown releated stuff
	self.currentCountdownTick = false
	self.countdownTimer = false
	
	-- map releated
	self.mapInfo = {}
	self.mapSettings = {}
	
	-- spawn releated stuff
	self.spawnpoints = {}
	self.currentSpawnIndex = 1
	
	self.playersDownloading = {}
	self.playersAlive = {}
	self.playersDead = {}	
	self.vehicles = {}
	
	self._onPlayerMapDownloadComplete = function() self:onPlayerMapDownloadComplete() end
	self._onPlayerWasted = function(...) self:onPlayerWasted(...) end
	self._onVehicleStartExit = function(...) self:onVehicleStartExit(...) end
	self._onPlayerVehicleChange = function(...) self:onPlayerVehicleChange(...) end
	self._onCountdownCount = function() self:onCountdownCount() end
	
	addEvent("onPlayerMapDownloadComplete", true)
		
	addEventHandler("onPlayerMapDownloadComplete", self:getRoomElement(), self._onPlayerMapDownloadComplete)
	addEventHandler("onPlayerWasted", self:getRoomElement(), self._onPlayerWasted)
	addEventHandler("onVehicleStartExit", self:getRoomElement(), self._onVehicleStartExit)
	
	addEventHandler("onPlayerVehicleChange", self:getRoomElement(), self._onPlayerVehicleChange)
end


function Deathmatch:destructor()

end

function Deathmatch:onPlayerJoin(player)
	-- max out drive stats
	player:setStat(160, 1000)
	player:setStat(229, 1000)
	player:setStat(230, 1000)	
	
	player:setDimension(self:getRoomElement():getDimension())
	
	if (self:getRaceState() == "none") then
		self:startMap()
	elseif (self.currentMapName) then
		exports.ddc_mapmanager:sendMapToClient(player, self.currentMapName)
		
		-- TODO spectating
	end
end

function Deathmatch:onPlayerLeave(player)
	local index = self:isPlayerAlive(player)
	
	exports.ddc_core:setData(player, "state", false)
	
	if (not index) then
		return
	end
	
	table.remove(self.playersAlive, index)
	table.insert(self.playersDead, player)
	
	self:removePlayerVehicle(player)
end

function Deathmatch:onPlayerMapDownloadComplete()
	-- invalid argument or player is in another room
	if (not client or client:getParent() ~= self:getRoomElement()) then
		return
	end
	
	local index = self:isPlayerAlive(client)
	
	-- player was not alive
	if (not index) then
		return
	end	
	
	-- remove player from download list
	for index, player in ipairs(self.playersDownloading) do
		if (player == client) then
			table.remove(self.playersDownloading, index)
			break
		end
	end
	
	exports.ddc_core:setData(client, "state", "ready")
	
	-- all alive players have downloaded the map, start countdown
	if (#self.playersDownloading == 0) then
		self:startCountdown()
	end
end

function Deathmatch:onPlayerWasted()
	local index = self:isPlayerAlive(source)
	
	if (not index) then
		return
	end
	
	table.remove(self.playersAlive, index)
	table.insert(self.playersDead, source)
	
	self:removePlayerVehicle(source)
	source:setPosition(0, 0, 3.5)
	
	exports.ddc_core:setData(source, "state", "dead")
	
	if (#self:getAlivePlayers() >= 1) then
		-- TODO: spectating
	else
		self:stopMap()
	end
end

function Deathmatch:onVehicleStartExit()
	cancelEvent(true)
end

function Deathmatch:onPlayerVehicleChange(modelId)
	if (self:isWFFModeEnabled() and modelId == 425) then
		source:setHealth(0)
	end
end

function Deathmatch:startRound()
	-- unfreeze all players
	for _, player in ipairs(self:getAlivePlayers()) do
		exports.ddc_core:setData(player, "state", "alive")
		
		local vehicle = player:getOccupiedVehicle()
		
		if (vehicle) then
			vehicle:setDamageProof(false)
			vehicle:setFrozen(false)
		end
		
		player:setFrozen(false)
	end
end

function Deathmatch:startCountdown()	
	-- if theres a countdown running, abort it
	if (self.countdownTimer and self.countdownTimer:isValid()) then
		killTimer(self.countdownTimer)
	end
	
	self.currentCountdownTick = 4
	self.countdownTimer = Timer(self._onCountdownCount, 1000, self.currentCountdownTick)
end

function Deathmatch:onCountdownCount()
	self.currentCountdownTick = self.currentCountdownTick - 1

	self:sendMessage("Countdown: "..self.currentCountdownTick)

	if (self.currentCountdownTick >= 1) then
		return
	end
	
	-- countdown is over
	self:startRound()
end

function Deathmatch:onMapLoaded(mapName, mapData)	
	self.mapInfo = mapData.info
	self.mapSettings = mapData.settings
	
	self.spawnpoints = mapData.spawnPoints
	self.currentSpawnIndex = 1
	
	self.currentMapName = mapName
	
	for _, player in ipairs(self:getPlayers()) do
		table.insert(self.playersAlive, player)
		table.insert(self.playersDownloading, player)
		
		exports.ddc_core:setData(player, "state", "downloading")
		
		self:spawnPlayer(player)
	end
	
	self:setRaceState("WaitingForPlayers")
end

function Deathmatch:startMap(isRedo)
	local mapName = false
	local mapData = false
	local attempts = 0
	local maps = exports.ddc_mapmanager:getMaps(self.mapPrefix)

	self:setRaceState("LoadingMap")
	
	if (isRedo and self.currentMapName) then
		mapName = self.currentMapName
	elseif (not isRedo and self.nextMapName) then
		mapName = self.nextMapName
	else
		-- start a random map
		local index = math.random(1, #maps)
		mapName = maps[index].resname
	end
	
	-- repeat until we find a map - giving it max 5 tries to find a map
	repeat
		mapData = exports.ddc_mapmanager:startMap(self:getRoomElement(), mapName)
		
		if (not mapData) then
			local index = math.random(1, #maps)
			mapName = maps[index].resname
			
			self:sendMessage("Unable to load map, starting random map!")
		end
		
		attempts = attempts + 1
	until(mapData or attempts >= 5)
	
	-- still couldn't load a map - are maps present?
	if (not mapData) then
		self:stopMap()
		
		self:sendMessage("Critical error occured - please inform a developer!")
		return
	end
	
	self:onMapLoaded(mapName, mapData)
end

function Deathmatch:stopMap(isRedo, isForced)
	if (not self.currentMapName) then
		return
	end
	
	-- abort countdown if running
	if (self.countdownTimer and self.countdownTimer:isValid()) then
		killTimer(self.countdownTimer)
	end
	
	-- unload the map
	exports.ddc_mapmanager:stopMap(self:getRoomElement(), self.currentMapName)
	
	-- reset all variables
	if (not isRedo) then
		self.currentMapName = false
	end
	
	-- countdown releated stuff
	self.currentCountdownTick = false
	self.countdownTimer = false
	
	-- map releated
	self.mapInfo = {}
	self.mapSettings = {}
	
	-- spawn releated stuff
	self.spawnpoints = {}
	self.currentSpawnIndex = 1
	
	self.playersDownloading = {}
	self.playersAlive = {}
	self.playersDead = {}
	self.vehicles = {}
	
	-- remove all remaining vehicles
	self:removeAllPlayerVehicles()
	
	self:setRaceState("none")
	
	-- are there players left ? if so, start map
	if (#self:getPlayers() >= 1) then
		-- forced by /redo, /random or when all players left the room
		if (isForced) then
			self:startMap(isRedo)
			return
		end
		
		-- start next map
		self:startMap(isRedo)
	end
end

function Deathmatch:spawnPlayer(player)	
	local spawnInfo = self.spawnpoints[self.currentSpawnIndex]
	self.currentSpawnIndex = self.currentSpawnIndex + 1
	
	if (self.currentSpawnIndex > #self.spawnpoints) then
		self.currentSpawnIndex = 1
	end
		
	local vehicle = createVehicle(spawnInfo.vehicle, spawnInfo.posX, spawnInfo.posY, spawnInfo.posZ, spawnInfo.rotX, spawnInfo.rotY, spawnInfo.rotZ)
	
	if (vehicle) then
		local r, g, b = 255, 123, 161		
		
		if (player:getTeam()) then
			r, g, b = player:getTeam():getColor()
		end
		
		self.vehicles[player] = vehicle
		
		vehicle:setDimension(self:getRoomElement():getDimension())
		vehicle:setDamageProof(true)
		vehicle:setColor(r, g, b, 16, 16, 16)
		vehicle:setFrozen(true)
		vehicle:setParent(self.roomElement)
		
		player:fadeCamera(true)
		player:setCameraTarget(player)
		
		player:spawn(spawnInfo.posX, spawnInfo.posY, spawnInfo.posZ, 0, 188, 0, self:getRoomElement():getDimension())
		player:warpIntoVehicle(vehicle)
	end
end

function Deathmatch:removePlayerVehicle(player)
	local vehicle = (player and self.vehicles[player] or false)
	
	if (vehicle) then
		if (isElement(vehicle)) then
			vehicle:destroy()
		end
		
		self.vehicles[player] = nil
	end
end


function Deathmatch:removeAllPlayerVehicles()
	for player, vehicle in pairs(self.vehicles) do
		if (vehicle and isElement(vehicle)) then
			vehicle:destroy()
		end
	end
	
	self.vehicles = {}
end

function Deathmatch:triggerRoomEvent(eventName, ...)
	return triggerClientEvent(self:getRoomElement(), eventName, resourceRoot, ...)
end

function Deathmatch:sendMessage(message, ...)
	return outputChatBox(message, self:getRoomElement(), ...)
end

function Deathmatch:isPlayerAlive(player)
	if (not player or not isElement(player)) then
		return false
	end
	
	for index, player_ in ipairs(self:getAlivePlayers()) do
		if (player_ == player) then
			return index
		end
	end
	
	return false
end

function Deathmatch:getAlivePlayers()
	return self.playersAlive
end

function Deathmatch:isPlayerDead()
	return self.playersDead
end

function Deathmatch:getRaceState()
	return self.currentRaceState
end

function Deathmatch:setRaceState(state)
	if (not state or type(state) ~= "string") then
		return false
	end
	
	local strPreviousState = self:getRaceState()
	self.currentRaceState = state
	
	--return self:triggerRoomEvent("onClientRaceStateChange", state, strPreviousState)
end

function Deathmatch:getPlayers()
	return self.roomElement:getChildren("player")
end

function Deathmatch:getRoomElement()
	return self.roomElement
end

function Deathmatch:isWFFModeEnabled()
	return self.isWFFMode
end