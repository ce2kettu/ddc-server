local pickupIds = { repair = 2222, nitro = 2221, vehiclechange = 2223 }
local pickupStartTick = getTickCount()
local visiblePickups = {}
local pickups = {}
local helicopterIds = { 417, 425, 447, 465, 469, 487, 488, 497, 501, 548, 563 }
local airplaneIds = { 592, 577, 511, 512, 593, 520, 553, 476, 519, 460, 513, 539 }
local useClassicChangeZ = true
local pickupLODDistance = 90

local math_atan2 = math.atan2
local math_fmod = math.fmod
local table_find = table.find

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
	return rem(math_atan2(b, a) * (360 / 6.28) - 90, 360)
end

local function unloadPickups()
	for _, id in pairs(pickupIds) do
		Engine.restoreModel(id)
		Engine.setModelLODDistance(id, 30)
	end
end

local function onResourceStart()
	local txd, dff = false, false
	
	for modelType, modelId in pairs(pickupIds) do
		txd = EngineTXD("files/"..modelType..".txd")
		dff = EngineDFF("files/"..modelType..".dff")
		
		if (txd and dff) then
			txd:import(modelId)
			dff:replace(modelId)
			
			-- increase draw distance for pickups
			Engine.setModelLODDistance(modelId, pickupLODDistance)
		end
	end
end

function createPickup(type, posX, posY, posZ, vehicle)
	if (not pickupIds[type]) then
		return
	end

	local pickup = Object(pickupIds[type], posX, posY, posZ)
	local colshape = ColShape.Sphere(posX, posY, posZ, 3.5)
    local dimension = localPlayer:getDimension()

	pickup:setCollisionsEnabled(false)
	colshape:setDimension(dimension)
	pickup:setDimension(dimension)
	colshape:setData("type", type, false)
	colshape:setData("object", pickup, false)
	
	if (type == "vehiclechange") then
		colshape:setData("vehicle", vehicle, false)
	end

	pickups[colshape] = pickup
end

function resetPickups()
	for colshape, pickup in pairs(pickups) do
		if (isElement(pickup)) then
			pickup:destroy()
		end

		if (isElement(colshape)) then
			colshape:destroy()
		end
	end

	visiblePickups = {}
	pickups = {}
end

local function onClientRender()
	local pickupRotation = math_fmod((getTickCount() - pickupStartTick) * 360 / 2000, 360)

	for _, pickup in pairs(visiblePickups) do
		if (not isElement(pickup)) then
			visiblePickups[pickup] = nil
		end

		local colshape = table_find(pickups, pickup)

		if (pickup:getDimension() == localPlayer:getDimension()) then
			pickup:setRotation(0, 0, pickupRotation)

			if (colshape:getData("type") == "vehiclechange") then
				local pickupPos = pickup:getPosition()
				local _, _, _, _, _, hz = pickup:getBoundingBox()
				local x, y, z = getScreenFromWorldPosition(pickupPos.x, pickupPos.y, pickupPos.z + 2)

				if (x and y) then
					local targetVehicle = getCameraTarget()
					local targetPlayer = nil

					if (isElement(targetVehicle)) then
						if (targetVehicle:getType() == "vehicle") then
							targetPlayer = targetVehicle:getOccupant()
						else
							targetPlayer = getCameraTarget()
							targetVehicle = targetPlayer:getOccupiedVehicle()
						end

						if (targetVehicle) then
							local vehiclePos = targetVehicle:getPosition()
                            local distance = getDistanceBetweenPoints3D(vehiclePos.x, vehiclePos.y, vehiclePos.z + hz + 0.1, pickupPos.x, pickupPos.y, pickupPos.z, hz + 0.5)

							if (distance <= 120) then
								local scale = 1 - distance / 120
								local pickupText = getVehicleNameFromModel(colshape:getData("vehicle"))
								local textLength = dxGetTextWidth(pickupText, 1 * scale, "default-bold") / 2
								local ccX, ccY, ccZ = getCameraMatrix()

								if (isLineOfSightClear(ccX, ccY, ccZ, pickupPos.x, pickupPos.y, pickupPos.z, true, false, false, true, false)) then
									dxDrawText(pickupText, x - textLength - 1, y - 1, x + textLength, 27, tocolor(0, 0, 0, 255), 1.5 * scale, "default-bold", "center", "top",false, false, true, true)
									dxDrawText(pickupText, x - textLength, y, x + textLength, 27, tocolor(255, 255, 255, 255), 1.5 * scale, "default-bold", "center", "top", false, false, true, true)
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
    local vehicle = localPlayer:getOccupiedVehicle()

    if (vehicle) then
        removeVehicleUpgrade(vehicle, 1010)
    end
end

local function alignVehicle(vehicle)
	if (not vehicle) then
		return
	end

	local matrix, rotZ = vehicle:getMatrix(), nil
	local forward, upward, velocity = matrix:getForward(), matrix:getUp(), Vector3(vehicle:getVelocity())

	if (velocity:getLength() > 0.05 and upward.z < 0.001) then
		rotZ = directionToRotation2D(velocity.x, velocity.y)
	else
		rotZ = directionToRotation2D(forward.x, forward.y)
	end

	vehicle:setRotation(0, 0, rotZ)
end

local function checkVehicleIsHelicopter(vehicle)
	if (table_find(helicopterIds, tonumber(vehicle:getModel()))) then
		vehicle:setHelicopterRotorSpeed(0.2)
	end
end

local function checkModelIsAirplane(model)
	return table_find(airplaneIds, model)
end

local function vehicleChanging(vehicle, isClassicChangeZ, ispreviousVehicleHeight)
	local newVehicleHeight = vehicle:getDistanceFromCentreOfMassToBaseOfModel()
	local vehiclePos = vehicle:getPosition()

	if (previousVehicleHeight and newVehicleHeight > previousVehicleHeight) then
		vehiclePos.z = vehiclePos.z - previousVehicleHeight + newVehicleHeight
	end

    if (isClassicChangeZ) then
        vehiclePos.z = vehiclePos.z + 1
    end

    vehicle:setPosition(vehiclePos.x, vehiclePos.y, vehiclePos.z)
    checkVehicleIsHelicopter(vehicle)
end

local function onPickupHit(element)
	local vehicle = localPlayer:getOccupiedVehicle()
	local elementType = source:getData("type")

	if (element ~= localPlayer or not vehicle) then
		return
	end

	if (not localPlayer:getData("alive")) then
		--return
	end

	if (elementType == "nitro") then
		playSoundFrontEnd(46)
		vehicle:addUpgrade(1010)
		triggerServerEvent("Race:syncNitro", resourceRoot)
	elseif (elementType == "repair") then
		playSoundFrontEnd(46)
		vehicle:fix()
	elseif (elementType == "vehiclechange") then
		local newModel = source:getData("vehicle")
        
		if (newModel == vehicle:getModel()) then
			return
        end
        
        local previousVehicleHeight = vehicle:getDistanceFromCentreOfMassToBaseOfModel()
        local health = nil
		
        alignVehicle(vehicle)

        -- Hack fix for Issue #4104
        if (checkModelIsAirplane(newModel)) then
			health = vehicle:getHealth()
        end
        
        vehicle:setModel(newModel)
        
        if (health) then
            vehicle:fix()
            vehicle:setHealth(health)
        end
		
		-- TODO: set a timer if players get stuck?
        vehicleChanging(vehicle, useClassicChangeZ, previousVehicleHeight)
        triggerServerEvent("Race:vehicleModelChange", resourceRoot, newModel)
		playSoundFrontEnd(46)
	end
end

local function addVisiblePickup()
	if (isPickupValid(source:getModel()) and table_find(pickups, source)) then
		visiblePickups[source] = source
	end
end

local function removeVisiblePickup()
	local pickup = table_find(pickups, source)

	if (pickup) then
		visiblePickups[pickup] = nil
	end
end

local function checkSpawnedOnPickup()
	for _, colshape in ipairs(pickups) do
		if (localPlayer:isWithinColShape(colshape)) then
			onPickupHit(colshape)
		end
	end
end

addEvent("Race:removeClientNitro", true)
addEvent("Race:checkSpawnedOnPickup", true)

addEventHandler("Race:checkSpawnedOnPickup", localPlayer, checkSpawnedOnPickup)
addEventHandler("Race:removeClientNitro", localPlayer, removeVehicleNitro)
addEventHandler("onClientElementStreamIn", root, addVisiblePickup)
addEventHandler("onClientElementStreamOut", root, removeVisiblePickup)
addEventHandler("onClientColShapeHit", root, onPickupHit)
addEventHandler("onClientResourceStop", resourceRoot, unloadPickups)
addEventHandler("onClientResourceStart", resourceRoot, onResourceStart)
addEventHandler("onClientRender", root, onClientRender)