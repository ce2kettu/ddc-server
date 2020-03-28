local HUNTER_MODEL_ID = 425

CarHide = {}

function CarHide:constructor()
	self.isEnabled = false
end

function CarHide:destructor()
	if (self.hideTimer and self.hideTimer:isValid()) then
		self.hideTimer:kill()
	end
	
	self.hideTimer = false
end

function CarHide:stateChanged(newState)
	self.isEnabled = not newState
	
	self:toggle()
end

function CarHide:toggle()
    local text = ""
	
	self.isEnabled = not self.isEnabled
	
	if (self.isEnabled) then
		text = "Other cars will be invisible for you."
		
		self:hideCars()
	else
		if (self.hideTimer and self.hideTimer:isValid()) then
			self.hideTimer:kill()
		end
		
		self.hideTimer = false
		text = "Other cars will not be invisible for you."
	
		self:restoreHiddenPlayers()
	end
	
	local r, g, b = exports.ddc_core:getServerInfo().color.rgb
    outputChatBox(text, r, g, b)
end

function CarHide:restoreHiddenPlayers()
    local dimension = localPlayer:getDimension()
    
	for _, player in pairs(Element.getAllByType("player")) do
		if (isElement(player)) then
			if player:getOccupiedVehicle() then
				player:getOccupiedVehicle():setDimension(dimension)
			end
			
			player:setDimension(dimension)
		end
	end
end

function CarHide:hideCars(target)
    local dimension = localPlayer:getDimension()
    local spectatingPlayer = target or getCameraTarget()

    if (not self.isEnabled) then
        return
    end

    for _, player in pairs(getAlivePlayers()) do 
        if (isElement(player) and isElement(player:getOccupiedVehicle())) then
            if (player ~= spectatingPlayer and player ~= localPlayer) then
                if (player:getOccupiedVehicle()) then
                    if (player:getOccupiedVehicle() and player:getOccupiedVehicle():getModel() ~= HUNTER_MODEL_ID) then
                        player:setDimension(localPlayer:getDimension() + 1) 
                        player:getOccupiedVehicle():setDimension(dimension + 1)
                    else
                        player:setDimension(dimension)
                        player:getOccupiedVehicle():setDimension(dimension)
                    end
                end
            else
                player:setDimension(dimension) 
                player:getOccupiedVehicle():setDimension(dimension)
            end
        end
    end
end