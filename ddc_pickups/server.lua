local function onPlayerGotNitro()
	if (not client) then
		return
	end
	
	local vehicle = client:getOccupiedVehicle()
	
	if (vehicle) then
		vehicle:addUpgrade(1010)
	end
end

local function onPlayerVehicleChange(modelId)
	if (not client) then
		return
	end
		
	local vehicle = client:getOccupiedVehicle()
	
	if (vehicle and vehicle:getModel() ~= modelId) then
		vehicle:setModel(modelId)

		client:triggerEvent("onRemoveClientNitro", client)
		triggerEvent("onPlayerVehicleChange", client, modelId)
	end
end

addEvent("onPlayerGotNitro", true)
addEvent("onPlayerVehicleChange", true)

addEventHandler("onPlayerGotNitro", resourceRoot, onPlayerGotNitro)
addEventHandler("onPlayerVehicleChange", resourceRoot, onPlayerVehicleChange)