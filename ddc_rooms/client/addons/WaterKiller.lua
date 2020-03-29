WaterKiller = {}

function WaterKiller:constructor()
	self._isEnabled = false
	self.waterCheckTimer = false
	self.waterCraftIds = { 539, 460, 417, 447, 472, 473, 493, 595, 484, 430, 453, 452, 446, 454 }
	
	self._doPulse = function() self:doPulse() end
end

function WaterKiller:toggle(state)
	if (type(state) ~= "boolean" or state == self:isEnabled()) then
		return false
	end
	
	self._isEnabled = state
	
	if (state) then
		self.waterCheckTimer = Timer(self._doPulse, 1000, 0)
	else
		if (self.waterCheckTimer and self.waterCheckTimer:isValid()) then
			self.waterCheckTimer:destroy()
		end
		
		self.waterCheckTimer = false
	end
end

function WaterKiller:doPulse()
	-- player is already dead
	if (localPlayer:getHealth() <= 0) then
		return
	end
	
	-- get current vehicle's model
	local currentVehicle = localPlayer:getOccupiedVehicle()
	local modelId = (currentVehicle and currentVehicle:getModel() or false)
	
	-- player is not in water
	if (not (currentVehicle or localPlayer):isInWater()) then
		return
	end
	
	-- check against watercrafts
	if (not modelId or not exports.ddc_core:table_find(self.waterCraftIds, modelId)) then
		-- kill player
		localPlayer:setHealth(0)
	end
end

function WaterKiller:isEnabled()
	return self._isEnabled
end