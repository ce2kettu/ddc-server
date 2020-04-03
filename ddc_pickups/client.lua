local pickupIds = { repair = 2222, nitro = 2221, vehiclechange = 2223 }
local pickupStartTick = getTickCount()
local visiblePickups = {}
local pickups = {}
local helicopterIds = { 417, 425, 447, 465, 469, 487, 488, 497, 501, 548, 563 }
local airplaneIds = { 592, 577, 511, 512, 593, 520, 553, 476, 519, 460, 513, 539 }
local useClassicChangeZ = true
local pickupLODDistance = 90

local function isPickupValid(pickupId)
    for _, id in pairs(pickupIds) do
        if (tonumber(id) == tonumber(pickupId)) then
            return true
        end
    end

    return false
end

local function rem(a, b)
    local result = a - b * math.floor(a / b)

    if (result >= b) then
        result = result - b
    end

    return result
end

local function directionToRotation2D(a, b)
    return rem(math.atan2(b, a) * (360 / 6.28) - 90, 360)
end

local function unloadPickups()
    for _, id in pairs(pickupIds) do
        engineRestoreModel(id)
        engineSetModelLODDistance(id, 30)
    end
end

local function onResourceStart()
    local txd, dff = false, false

    for modelType, modelId in pairs(pickupIds) do
        txd = engineLoadTXD("files/"..modelType..".txd")
        dff = engineLoadDFF("files/"..modelType..".dff")

        if (txd and dff) then
            engineImportTXD(txd, modelId)
            engineReplaceModel(dff, modelId)

            -- increase draw distance for pickups
            engineSetModelLODDistance(modelId, pickupLODDistance)
        end
    end
end

local function onClientRender()
    local pickupRotation = math.fmod((getTickCount() - pickupStartTick) * 360 / 2000, 360)

    for _, pickup in pairs(visiblePickups) do
        if (not isElement(pickup)) then
            visiblePickups[pickup] = nil
        end

        local colshape = table.find(pickups, pickup)

        if (getElementDimension(pickup) == getElementDimension(localPlayer)) then
            setElementRotation(pickup, 0, 0, pickupRotation)

            if (getElementData(colshape, "type") == "vehiclechange") then
                local pickupPosX, pickupPosY, pickupPosZ = getElementPosition(pickup)
                local _, _, _, _, _, hz = getElementBoundingBox(pickup)
                local x, y, z = getScreenFromWorldPosition(pickupPosX, pickupPosY, pickupPosZ + 2)

                if (x and y) then
                    local targetVehicle = getCameraTarget()
                    local targetPlayer = false

                    if (isElement(targetVehicle)) then
                        if (getElementType(targetVehicle) == "vehicle") then
                            targetPlayer = getVehicleOccupant(targetVehicle)
                        else
                            targetPlayer = getCameraTarget()
                            targetVehicle = getPedOccupiedVehicle(targetPlayer)
                        end

                        if (targetVehicle) then
                            local vehiclePosX, vehiclePosY, vehiclePosZ = getElementPosition(targetVehicle)
                            local distance = getDistanceBetweenPoints3D(vehiclePosX, vehiclePosY, vehiclePosZ + hz + 0.1, pickupPosX, pickupPosY, pickupPosZ, hz + 0.5)

                            if (distance <= 120) then
                                local scale = (1 - distance / 120) * 1.5
                                local pickupText = getVehicleNameFromModel(getElementData(colshape, "vehicle"))
                                local textLength = dxGetTextWidth(pickupText, 1 * scale, "default-bold") / 2
                                local ccX, ccY, ccZ = getCameraMatrix()

                                if (isLineOfSightClear(ccX, ccY, ccZ, pickupPosX, pickupPosY, pickupPosZ, true, false, false, true, false)) then
                                    dxDrawText(pickupText, x - textLength - 1, y - 1, x + textLength, 27, tocolor(0, 0, 0, 255), scale, "default", "center", "top",false, false, true, true)
                                    dxDrawText(pickupText, x - textLength, y, x + textLength, 27, tocolor(255, 255, 255, 255), scale, "default", "center", "top", false, false, true, true)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local function removeVehicleNitro()
    local vehicle = getPedOccupiedVehicle(localPlayer)

    if (vehicle) then
        removeVehicleUpgrade(vehicle, 1010)
    end
end

local function alignVehicleWithUp(vehicle)
    if (not vehicle) then
        return
    end

    local matrix, rotZ = getElementMatrix(vehicle), nil
    local forward = Vector3D:new(matrix[2][1], matrix[2][2], matrix[2][3])
    local upward = Vector3D:new(matrix[3][1], matrix[3][2], matrix[3][3])
    local velocity = Vector3D:new(getElementVelocity(vehicle))

    if (velocity:Length() > 0.05 and upward.z < 0.001) then
        rotZ = directionToRotation2D(velocity.x, velocity.y)
    else
        rotZ = directionToRotation2D(forward.x, forward.y)
    end

    setElementRotation(vehicle, 0, 0, rotZ)
end

local function checkVehicleIsHelicopter(vehicle)
    if (table.find(helicopterIds, tonumber(getElementModel(vehicle)))) then
        setHelicopterRotorSpeed(vehicle, 0.2)
    end
end

local function checkModelIsAirplane(model)
    return table.find(airplaneIds, model)
end

local function vehicleChanging(vehicle, isClassicChangeZ, ispreviousVehicleHeight)
    local newVehicleHeight = getElementDistanceFromCentreOfMassToBaseOfModel(vehicle)
    local vehX, vehY, vehZ = getElementPosition(vehicle)

    if (previousVehicleHeight and newVehicleHeight > previousVehicleHeight) then
        vehZ = vehZ - previousVehicleHeight + newVehicleHeight
    end

    if (isClassicChangeZ) then
        vehZ = vehZ + 1
    end

    setElementPosition(vehicle, vehX, vehY, vehZ)
    checkVehicleIsHelicopter(vehicle)
end

-- handling copied from the default race resource shipped with MTA
local function onPickupHit(element)
    local vehicle = getPedOccupiedVehicle(localPlayer)
    local elementType = getElementData(source, "type")

    if (element ~= localPlayer or not vehicle) then
        return
    end

    if (not getElementData(localPlayer, "alive")) then
        --return
    end

    if (elementType == "nitro") then
        playSoundFrontEnd(46)
        addVehicleUpgrade(vehicle, 1010)
        triggerServerEvent("Race:syncNitro", resourceRoot)
    elseif (elementType == "repair") then
        playSoundFrontEnd(46)
        fixVehicle(vehicle)
    elseif (elementType == "vehiclechange") then
        local newModel = getElementData(source, "vehicle")

        if (newModel == getElementModel(vehicle)) then
            return
        end

        -- set a small timer so players don't get stuck
        setTimer(function()
            local previousVehicleHeight = getElementDistanceFromCentreOfMassToBaseOfModel(vehicle)
            local health = nil

            alignVehicleWithUp(vehicle)

            -- Hack fix for Issue #4104
            if (checkModelIsAirplane(newModel)) then
                health = getElementHealth(vehicle)
            end

            setElementModel(vehicle, newModel)

            if (health) then
                fixVehicle(vehicle)
                setElementHealth(vehicle, health)
            end

            vehicleChanging(vehicle, useClassicChangeZ, previousVehicleHeight)
            triggerServerEvent("Race:onVehicleModelChange", resourceRoot, newModel)
            playSoundFrontEnd(46)
        end, 140, 1)
    end
end

local function addVisiblePickup()
    if (isPickupValid(getElementModel(source)) and table.find(pickups, source)) then
        visiblePickups[source] = source
    end
end

local function removeVisiblePickup()
    local pickup = table.find(pickups, source)

    if (pickup) then
        visiblePickups[pickup] = nil
    end
end

-- exports
function createPickup(type, posX, posY, posZ, vehicle)
    if (not pickupIds[type]) then
        return
    end

    local pickup = createObject(pickupIds[type], posX, posY, posZ)
    local colshape = createColSphere(posX, posY, posZ, 3.5)
    local dimension = getElementDimension(localPlayer)

    setElementCollisionsEnabled(pickup, false)
    setElementDimension(colshape, dimension)
    setElementDimension(pickup, dimension)
    setElementData(colshape, "type", type, false)
    setElementData(colshape, "object", pickup, false)

    if (type == "vehiclechange") then
        setElementData(colshape, "vehicle", vehicle, false)
    end

    pickups[colshape] = pickup

    local vehicle = getPedOccupiedVehicle(localPlayer)

    -- check if player spawned on the pickup
    if (vehicle and isElementWithinColShape(vehicle, colshape)) then
        onPickupHit(colshape)
    end
end

function resetPickups()
    for colshape, pickup in pairs(pickups) do
        if (isElement(pickup)) then
            destroyElement(pickup)
        end

        if (isElement(colshape)) then
            destroyElement(colshape)
        end
    end

    visiblePickups = {}
    pickups = {}
end

addEvent("Race:removeClientPlayerNitro", true)

addEventHandler("Race:removeClientPlayerNitro", localPlayer, removeVehicleNitro)
addEventHandler("onClientElementStreamIn", resourceRoot, addVisiblePickup)
addEventHandler("onClientElementStreamOut", resourceRoot, removeVisiblePickup)
addEventHandler("onClientColShapeHit", resourceRoot, onPickupHit)
addEventHandler("onClientResourceStop", resourceRoot, unloadPickups)
addEventHandler("onClientResourceStart", resourceRoot, onResourceStart)
addEventHandler("onClientRender", root, onClientRender)