Spectators = {}

function Spectators:constructor()
	self._isEnabled = false
	self.checkCameraTargetTimer = false
	
	self._spectateNextPlayer = function() self:spectateNewTarget(1) end
	self._spectatePreviousPlayer = function() self:spectateNewTarget(-1) end
	self._checkCurrentCameraTarget = function() self:checkCurrentCameraTarget() end
end

function Spectators:toggle(state)
	if (type(state) ~= "boolean" or state == self:isEnabled()) then
		return false
	end
	
	self._isEnabled = state
	
	if (state) then
		bindKey("arrow_l", "up", self._spectatePreviousPlayer)
		bindKey("arrow_r", "up", self._spectateNextPlayer)
		
		self.checkCameraTargetTimer = Timer(self._checkCurrentCameraTarget, 500, 0)
	else
		unbindKey("arrow_l", "up", self._spectatePreviousPlayer)
		unbindKey("arrow_r", "up", self._spectateNextPlayer)
		
		-- destroy our timer
		if (self.checkCameraTargetTimer and self.checkCameraTargetTimer:isValid()) then
			self.checkCameraTargetTimer:destroy()
		end
		
		self.checkCameraTargetTimer = false
	end
end

function Spectators:spectateNewTarget(direction)
	outputChatBox("checking spec target")
	local currentCameraTarget = getCameraTarget()
	
	-- ensure that the camera target is a player
	if (currentCameraTarget and currentCameraTarget:getType() == "vehicle") then
		currentCameraTarget = currentCameraTarget:getController()
	end
	
	local players = self:getSpectateablePlayers()	
	local currentPosition = (exports.ddc_core:table_find(players, currentCameraTarget) or 1) + direction
	
	-- ensure position is not going out of the current index
	if (currentPosition > #players) then
		currentPosition = 1
	elseif (currentPosition < 1) then
		currentPosition = #players
	end
	
	-- change our camera target once a target has been found
	if (players[currentPosition] and players[currentPosition] ~= currentCameraTarget) then
		-- ensure to stream player BEFORE changing the camera target - it wont change otherwise
		if (not isElementStreamedIn(players[currentPosition])) then
			localPlayer:setPosition(players[currentPosition]:getPosition())
		end
		
		setCameraTarget(players[currentPosition])
	end
end

function Spectators:checkCurrentCameraTarget()
	local currentCameraTarget = getCameraTarget()
	
	-- ensure that the camera target is a player
	if (currentCameraTarget and currentCameraTarget:getType() == "vehicle") then
		currentCameraTarget = currentCameraTarget:getController()
	end
	
	-- currently spectated player is invalid, spectate another one
	if (not currentCameraTarget or (currentCameraTarget:getHealth() == 0 or currentCameraTarget:getData("state") ~= "alive")) then
		self:spectateNewTarget(1)
	end
end

function Spectators:getSpectateablePlayers()
	local spectateablePlayers = {}
	
	for _, player in ipairs(localPlayer:getParent():getChildren("player")) do
		if (player ~= localPlayer and player:getHealth() >= 1 and player:getData("state") == "alive") then
			table.insert(spectateablePlayers, player)
		end
	end
	
	return spectateablePlayers
end

function Spectators:spectateRandomTarget(ignoredPlayer)
	local players = self:getSpectateablePlayers()

	if (#players > 0) then
		local target = players[math.random(1, #players)]
		local tries = 0
		local found = false

		if (target and target ~= ignoredPlayer) then
			found = true
		end

		while (not target or target == ignoredPlayer and tries <= 5 and not found) do
			target = players[math.random(1, #players)]

			if (target and target ~= ignoredPlayer) then
				found = true
				break
			end

			tries = tries + 1
		end

		if (found) then
			exports.ddc_core:setData(localPlayer, "cameraTarget", target, true)
			setCameraTarget(target)
		else
			self:noTargetFound()
		end
	else
		self:noTargetFound()
	end
end

function Spectators:checkIsTargetValid()
	local element = getCameraTarget()
	
	if (not element or element:getData("state") ~= "alive" and element:getData("state") ~= "ready") then
		self:spectateRandomTarget()
	end
end

function Spectators:noTargetFound()
	exports.ddc_core:setData(localPlayer, "cameraTarget", "none", true)
	setCameraMatrix(getCameraMatrix())
end

function Spectators:setTarget(target)
	exports.ddc_core:setData(localPlayer, "cameraTarget", target, true)
	setCameraTarget(target)
end

function Spectators:isEnabled()
	return self._isEnabled
end