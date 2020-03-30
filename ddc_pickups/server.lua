local function syncNitro()
	if (not client) then
		return
	end
	
	local vehicle = client:getOccupiedVehicle()
	
	if (vehicle) then
		vehicle:addUpgrade(1010)
	end
end

local function syncVehicleModel(modelId)
	if (not client) then
		return
	end
		
	local vehicle = client:getOccupiedVehicle()
	
	if (vehicle and vehicle:getModel() ~= modelId) then
		vehicle:setModel(modelId)

		client:triggerEvent("Race:removeClientPlayerNitro", client)
		triggerEvent("Race:onVehicleModelChange", client, modelId)
	end
end

addEvent("Race:syncNitro", true)
addEvent("Race:onVehicleModelChange", true)

addEventHandler("Race:syncNitro", resourceRoot, syncNitro)
addEventHandler("Race:onVehicleModelChange", resourceRoot, syncVehicleModel)