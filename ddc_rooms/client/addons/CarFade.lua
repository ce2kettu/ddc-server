CarFade = {}

function CarFade:constructor()
	self.isEnabled = false
	self.distanceToFadeIn = 10 -- GTA units
	
	self._doCheck = function() self:doCheck() end
end

function CarFade:toggle(state)
	if (type(state) ~= "boolean" or state == self:isEnabled()) then
		return false
	end
	
	self.isEnabled = state
	
	if (state) then
		addEventHandler("onClientRender", root, self._doCheck)
	else
		removeEventHandler("onClientRender", root, self._doCheck)
	end
end

function CarFade:doCheck()
	local currentCameraTarget = getCameraTarget()
	
	-- ensure the camera target is a player
	if (currentCameraTarget and currentCameraTarget:getType() == "vehicle") then
		currentCameraTarget = currentCameraTarget:getController()
	end
	
	-- nothing to do; abort
	if (not currentCameraTarget) then
		return
	end
	
	local distance = -1;
	local element = false
	local alpha = -1
	local localPosition = currentCameraTarget:getPosition()
	
	for _, player in ipairs(self:getStreamedinPlayers()) do
		element = (player.vehicle or player)
		distance = getDistanceBetweenPoints3D(localPosition, element:getPosition())
			
		if (distance <= self.distanceToFadeIn) then
			alpha = (distance / self.distanceToFadeIn) * 255
			
			element:setAlpha(alpha)
			
			-- ensure to fade player alpha aswell
			if (element ~= player) then
				player:setAlpha(alpha)
			end
		end
	end
end

function CarFade:getStreamedinPlayers()
	local players = {}
	local roomPlayers = Element.getAllByType("player", localPlayer:getParent(), true)
	
	for _, player in ipairs(roomPlayers) do
		if (player ~= localPlayer and player:getHealth() >= 1 and player:getData("state") == "alive") then
			table.insert(players, player)
		end
	end
	
	return players
end

function CarFade:isEnabled()
	return self.isEnabled
end