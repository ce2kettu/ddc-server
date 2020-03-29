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
	outputChatBox("Spectators:spectateNewTarget")
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
		outputChatBox("invalid target")
		outputChatBox(currentCameraTarget:getData("state"))
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

function Spectators:isEnabled()
	return self._isEnabled
end