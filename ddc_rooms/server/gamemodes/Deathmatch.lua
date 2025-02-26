Deathmatch = {}

function Deathmatch:constructor(room, mapPrefix, settings)
    -- general stuffs
    self.roomElement = room
    self.mapPrefix = mapPrefix
    self.currentRaceState = "none"
    self.isWFFMode = settings.WFFMode == true

    -- current / nextmap resource names
    self.currentMapName = false
    self.currentMapResource = false
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

    self._onPlayerMapDownloadComplete = bind(self.onPlayerMapDownloadComplete, self)
    self._onPlayerWasted = bind(self.onPlayerWasted, self)
    self._onVehicleStartExit = bind(self.onVehicleStartExit, self)
    self._onPlayerVehicleChange = bind(self.onPlayerVehicleChange, self)
    self._onCountdownCount = bind(self.onCountdownCount, self)
    self._killPlayer = bind(self.killPlayer, self)

    addEvent("onPlayerMapDownloadComplete", true)
    addEvent("Race:onPlayerRequestDeath", true)

    addEventHandler("onPlayerMapDownloadComplete", self:getRoomElement(), self._onPlayerMapDownloadComplete)
    addEventHandler("onPlayerWasted", self:getRoomElement(), self._onPlayerWasted)
    addEventHandler("onVehicleStartExit", self:getRoomElement(), self._onVehicleStartExit)

    addEventHandler("Race:onPlayerRequestDeath", self:getRoomElement(), self._killPlayer)
    addEventHandler("Race:onVehicleModelChange", self:getRoomElement(), self._onPlayerVehicleChange)
end

function Deathmatch:destructor()
    -- TODO: remove event handlers
end

function Deathmatch:onPlayerJoin(player)
    -- max out drive stats
    setPedStat(player, 160, 1000)
    setPedStat(player, 229, 1000)
    setPedStat(player, 230, 1000)

    setElementDimension(player, getElementDimension(self:getRoomElement()))

    setPlayerNametagShowing(player, false)

    spawnPlayer(player, 0, 0, 0)
    setElementFrozen(player, true)
    setElementHealth(player, 100)

    exports.ddc_core:setData(player, "state", "waiting", true)

    -- TODO: bind b for admins

    if (self:getRaceState() == "none") then
        self:startMap()
    elseif (self.currentMapResource) then
        exports.ddc_mapmanager:sendMapToClient(player, self.currentMapResource)
        triggerClientEvent(player, "Race:onClientPlayerStartSpectate", player)
    end
end

function Deathmatch:onPlayerLeave(player)
    local index = self:isPlayerAlive(player)

    exports.ddc_core:setData(player, "state", false, true)

    if (not index) then
        return
    end

    table.remove(self.playersAlive, index)
    table.insert(self.playersDead, player)

    self:removePlayerVehicle(player)
end

function Deathmatch:onPlayerMapDownloadComplete()
    -- invalid argument or player is in another room
    if (not client or getElementParent(client) ~= self:getRoomElement()) then
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

    exports.ddc_core:setData(client, "state", "ready", true)

    -- all alive players have downloaded the map, start countdown
    if (#self.playersDownloading == 0) then
        self:startCountdown()
    end
end

function Deathmatch:onWasted(player, reason)
    if (not player) then
        return
    end

    local index = self:isPlayerAlive(player)

    if (not index) then
        return
    end

    table.remove(self.playersAlive, index)
    table.insert(self.playersDead, player)

    self:removePlayerVehicle(player)
    setElementPosition(player, 0, 0, 3.5)
    setElementFrozen(player, true)

    triggerClientEvent(player, "Race:onClientPlayerWasted", player)

    outputChatBox(getPlayerName(player).." #ffffffhas died", self:getRoomElement(), 255, 255, 255, true)

    exports.ddc_core:setData(player, "state", "dead", true)

    if (#self:getAlivePlayers() >= 1) then
        -- TODO: spectating
        triggerClientEvent(player, "Race:onClientPlayerStartSpectate", player)

        -- move spectators to another player
        for _, spectator in ipairs(self:getPlayers()) do
            if (getElementData(spectator, "cameraTarget") == player) then
                triggerClientEvent(spectator, "Race:spectateRandomTarget", resourceRoot)
            end
        end
    else
        self:stopMap()
    end
end

function Deathmatch:onPlayerWasted()
    self:onWasted(source)
end

function Deathmatch:killPlayer(reason)
    if (client and self:isPlayerInCurrentRoom(client)) then
        self:onWasted(client, reason)
    end
end

function Deathmatch:onVehicleStartExit()
    cancelEvent(true)
end

function Deathmatch:onPlayerVehicleChange(modelId)
    if (self:isWFFModeEnabled() and modelId == 425) then
        setElementHealth(source, 0)
    end
end

function Deathmatch:startRound()
    self:triggerRoomEvent("Race:onClientRoundStart")

    -- unfreeze all players
    for _, player in ipairs(self:getAlivePlayers()) do
        exports.ddc_core:setData(player, "state", "alive", true)

        local vehicle = getPedOccupiedVehicle(player)

        if (vehicle) then
            setVehicleDamageProof(vehicle, false)
            setElementFrozen(vehicle, false)
        end

        setElementFrozen(player, false)
    end
end

function Deathmatch:startCountdown()
    -- if theres a countdown running, abort it
    if (self.countdownTimer and isTimer(self.countdownTimer)) then
        killTimer(self.countdownTimer)
    end

    self.currentCountdownTick = 4
    self.countdownTimer = setTimer(self._onCountdownCount, 1000, self.currentCountdownTick)
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

    self.currentMapResource = mapData.resourceName
    self.currentMapName = mapData.info.name or "Unknown"

    for _, player in ipairs(self:getPlayers()) do
        table.insert(self.playersAlive, player)
        table.insert(self.playersDownloading, player)

        exports.ddc_core:setData(player, "state", "downloading", true)

        self:spawnPlayer(player)
    end

    self:setRaceState("WaitingForPlayers")
    self:onMapStarting()
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
        mapName = maps[index].resourceName
        --mapName = "$modern-[DM][T]riXvol6-ForTheLoveOfCresheZ"
    end

    -- TODO: check hunter pickup

    -- repeat until we find a map - giving it max 5 tries to find a map
    repeat
        mapData = exports.ddc_mapmanager:startMap(self:getRoomElement(), mapName)

        if (not mapData) then
            local index = math.random(1, #maps)
            mapName = maps[index].resourceName

            self:sendMessage("Unable to load map, starting random map!")
        else
            if (not mapData.hasHunterPickup) then
                mapData = nil
            end
        end

        attempts = attempts + 1
    until(mapData or attempts >= 5)

    -- still couldn't load a map - are maps present?
    if (not mapData) then
        self:stopMap()

        -- TODO: kick players to lobby
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
    if (self.countdownTimer and isTimer(self.countdownTimer)) then
        killTimer(self.countdownTimer)
    end

    -- unload the map
    exports.ddc_mapmanager:stopMap(self:getRoomElement(), self.currentMapResource)

    -- reset all variables
    if (not isRedo) then
        self.currentMapName = false
        self.currentMapResource = false
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

    self:triggerRoomEvent("Race:onClientPlayerStopSpectate")

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
        local team = getPlayerTeam(player)
        local dimension = getElementDimension(self:getRoomElement())

        if (team) then
            r, g, b = getTeamColor(team)
        end

        self.vehicles[player] = vehicle

        setElementDimension(vehicle, dimension)
        setVehicleDamageProof(vehicle, true)
        setVehicleColor(vehicle, r, g, b, 16, 16, 16)
        setElementFrozen(vehicle, true)
        setElementParent(vehicle, self.roomElement)

        fadeCamera(player, true)
        setCameraTarget(player, player)

        spawnPlayer(player, spawnInfo.posX, spawnInfo.posY, spawnInfo.posZ, 0, 188, 0, dimension)
        warpPedIntoVehicle(player, vehicle)
    end
end

function Deathmatch:removePlayerVehicle(player)
    local vehicle = (player and self.vehicles[player]) or false

    if (vehicle) then
        if (isElement(vehicle)) then
            destroyElement(vehicle)
        end

        self.vehicles[player] = nil
    end
end


function Deathmatch:removeAllPlayerVehicles()
    for _, vehicle in ipairs(self.vehicles) do
        if (vehicle and isElement(vehicle)) then
            destroyElement(vehicle)
        end
    end

    self.vehicles = {}
end

function Deathmatch:onMapStarting()
    self:sendMessage("#00d07c[Room] #FFFFFFStarting "..self.currentMapName, 255, 255, 255, true)
    --self.roomElement:setData("currentMap", self.currentMapName)
    --self:getToptimes()
    --self:updateMapLabel()
    --self:updateRoundTime()
    --self:getMapInformations()
    --self:decreaseMapBuyerCooldown()

    -- if self.nextMapRandom then
    -- 	self.nextMapRandom = false
    -- end
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

function Deathmatch:isPlayerInCurrentRoom(player)
    return (player and getElementParent(player) == self:getRoomElement())
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
    return getElementChildren(self.roomElement, "player")
end

function Deathmatch:getRoomElement()
    return self.roomElement
end

function Deathmatch:isWFFModeEnabled()
    return self.isWFFMode
end