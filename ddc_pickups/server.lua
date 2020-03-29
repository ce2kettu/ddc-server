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

		client:triggerEvent("Race:removeClientNitro", client)
		triggerEvent("Race:vehicleModelChange", client, modelId)
	end
end

addEvent("Race:syncNitro", true)
addEvent("Race:vehicleModelChange", true)

addEventHandler("Race:syncNitro", resourceRoot, syncNitro)
addEventHandler("Race:vehicleModelChange", resourceRoot, syncVehicleModel)