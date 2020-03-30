local function syncNitro()
    if (not client) then
        return
    end

    local vehicle = getPedOccupiedVehicle(client)

    if (vehicle) then
        addVehicleUpgrade(vehicle, 1010)
    end
end

local function syncVehicleModel(modelId)
    if (not client) then
        return
    end

    local vehicle = getPedOccupiedVehicle(client)

    if (vehicle and getElementModel(vehicle) ~= modelId) then
        setElementModel(vehicle, modelId)

        triggerClientEvent(client, "Race:removeClientPlayerNitro", client)
        triggerEvent("Race:onVehicleModelChange", client, modelId)
    end
end

addEvent("Race:syncNitro", true)
addEvent("Race:onVehicleModelChange", true)

addEventHandler("Race:syncNitro", resourceRoot, syncNitro)
addEventHandler("Race:onVehicleModelChange", resourceRoot, syncVehicleModel)