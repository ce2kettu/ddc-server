local events = {}
local commands = {}
local binds = {}
local xmlFiles = {}
local loadedDff = {}
local loadedCol = {}
local checkArguments = function(...) return exports.ddc_core:checkArguments(...) end

SandboxHooks = {}

function _unloadEverything()
	-- unload all events
	for _, tblEventInfo in ipairs(events) do
		removeEventHandler(unpack(tblEventInfo))
	end
	
	-- unload all commands
	for _, tblCommandInfo in ipairs(commands) do
		removeCommandHandler(unpack(tblCommandInfo))
	end
	
	-- unload all binds
	for _, tblBindInfo in ipairs(binds) do
		unbindKey(unpack(tblBindInfo))
	end
	
	-- unload all xml files
	for _, uXML in ipairs(xmlFiles) do
		xmlUnloadFile(uXML)
	end
	
	-- restore all models
	for iModelID, _ in pairs(loadedDff) do
		engineRestoreModel(iModelID)
	end
	
	-- restore all collisions
	for iModelID, _ in pairs(loadedCol) do
		engineRestoreCOL(iModelID)
	end
	
	-- reset variables
	events = {}
	commands = {}
	binds = {}
	xmlFiles = {}
	loadedDff = {}
	loadedCol = {}
end

function SandboxHooks.addEventHandler(eventName, attachedToElement, handler, ...)
	if (not checkArguments("suf", eventName, attachedToElement, handler)) then
		return false
	end
	
	if (addEventHandler(eventName, attachedToElement, handler, ...)) then
		table.insert(events, {eventName, attachedToElement, handler})
		return true
	end
	
	return false
end

function SandboxHooks.removeEventHandler(eventName, attachedToElement, handler)
	if (not checkArguments("suf", eventName, attachedToElement, handler)) then
		return false
	end
	
	if (removeEventHandler(eventName, attachedToElement, handler)) then
		for i, eventInfo in ipairs(binds) do
			if (eventName == eventInfo[1] and attachedToElement == eventInfo[2] and handler == eventInfo[3]) then
				table.remove(events, i)
				break
			end
		end
		
		return true
	end
	
	return false
end

function SandboxHooks.addCommandHandler(commandName, handler, ...)
	if (not checkArguments("sf", commandName, handler)) then
		return false
	end
	
	if (addCommandHandler(commandName, handler, ...)) then
		table.insert(commands, {commandName, handler})
		return true
	end
	
	return false
end

function SandboxHooks.removeCommandHandler(commandName, handler)
	if (not checkArguments("sf", commandName, handler)) then
		return false
	end
	
	if (removeCommandHandler(commandName, handler)) then
		for i, commandInfo in ipairs(commands) do
			if (commandName == commandInfo[1] and handler == commandInfo[2]) then
				table.remove(commands, i)
				break
			end
		end
		
		return true
	end
	
	return false
end

function SandboxHooks.bindKey(key, keyState, handler, ...)
	if (not checkArguments("ss", key, keyState)) then
		return false
	end
	
	if (type(handler) ~= "function" and type(handler) ~= "string") then
		return false
	end
	
	if (bindKey(key, keyState, handler, ...)) then
		table.insert(binds, {key, keyState, handler})
		return true
	end
	
	return false
end

function SandboxHooks.unbindKey(key, keyState, handler)
	if (not checkArguments("ss", key, keyState)) then
		return false
	end
	
	if (type(handler) ~= "function" and type(handler) ~= "string") then
		return false
	end
	
	if (unbindKey(key, keyState, handler)) then
		for i, bindInfo in ipairs(binds) do
			if (key == bindInfo[1] and keyState == bindInfo[2] and handler == bindInfo[3]) then
				table.remove(binds, i)
				break
			end
		end
		
		return true
	end
	
	return false
end

function SandboxHooks.playSound(filePath, isLooped, isThrottled)
	if (not checkArguments("s", filePath)) then
		return false
	end
	
	local filePath = tostring(g_Sandbox:getDownloadURL())..tostring(g_Sandbox:getResourceName())..'/'..tostring(filePath)
	local sound = playSound(filePath, isLooped, isThrottled)
	
	if (sound) then
		sound:setParent(g_Sandbox:getMapElement())
		
		return sound
	end
	
	return false
end

function SandboxHooks.playSound3D(filePath, x, y, z, ...)
	if (not checkArguments("siii", filePath, x, y, z)) then
		return false
	end
	
	local filePath = tostring(g_Sandbox:getDownloadURL())..tostring(g_Sandbox:getResourceName())..'/'..tostring(filePath)
	local sound = playSound3D(filePath, x, y, z, ...)
	
	if (sound) then
		sound:setParent(g_Sandbox:getMapElement())
		
		return sound
	end
	
	return false
end

function SandboxHooks.createColCircle(x, y, z, radus)
	if (not checkArguments("iiii", x, y, z, radus)) then
		return false
	end
	
	local colshape = createColCircle(x, y, z, radus)
	
	if (colshape) then
		colshape:setParent(g_Sandbox:getMapElement())
		colshape:setDimension(localPlayer:getDimension())
		
		return colshape
	end
	
	return false
end

function SandboxHooks.createColCuboid(x, y, z, width, depth, height)
	if (not checkArguments("iiiiii", x, y, z, width, depth, height)) then
		return false
	end
	
	local colshape = createColCuboid(x, y, z, width, depth, height)
	
	if (colshape) then
		colshape:setParent(g_Sandbox:getMapElement())
		colshape:setDimension(localPlayer:getDimension())
		
		return colshape
	end
	
	return false
end

function SandboxHooks.createColPolygon(x, y, x2, y2, x3, y3, x4, y4, ...)
	if (not checkArguments("iiiiiiii", x, y, z, width, depth, height)) then
		return false
	end
	
	local colshape = createColPolygon(x, y, x2, y2, x3, y3, x4, y4, ...)
	
	if (colshape) then
		colshape:setParent(g_Sandbox:getMapElement())
		colshape:setDimension(localPlayer:getDimension())
		
		return colshape
	end
	
	return false
end

function SandboxHooks.createColRectangle(x, y, width, height)
	if (not checkArguments("iiii", x, y, width, height)) then
		return false
	end
	
	local colshape = createColRectangle(x, y, width, height)
	
	if (colshape) then
		colshape:setParent(g_Sandbox:getMapElement())
		colshape:setDimension(localPlayer:getDimension())
		
		return colshape
	end
	
	return false
end

function SandboxHooks.createColSphere(x, y, z, radus)
	if (not checkArguments("iiii", x, y, z, radus)) then
		return false
	end
	
	local colshape = createColSphere(x, y, z, radus)
	
	if (colshape) then
		colshape:setParent(g_Sandbox:getMapElement())
		colshape:setDimension(localPlayer:getDimension())
		
		return colshape
	end
	
	return false
end

function SandboxHooks.createColTube(x, y, z, radus, height)
	if (not checkArguments("iiiii", x, y, z, radus, height)) then
		return false
	end
	
	local colshape = createColTube(x, y, z, radus, height)
	
	if (colshape) then
		colshape:setParent(g_Sandbox:getMapElement())
		colshape:setDimension(localPlayer:getDimension())
		
		return colshape
	end
	
	return false
end

function SandboxHooks.dxCreateFont(filePath, ...)
	local filePath = g_Sandbox:getFileHashFromName(filePath)
	local font = (filePath and dxCreateFont(filePath, ...) or false)
	
	if (font) then
		font:setParent(g_Sandbox:getMapElement())
		
		return font
	end
	
	return false
end

function SandboxHooks.dxCreateShader(filePath, ...)
	local filePath = g_Sandbox:getFileHashFromName(filePath)
	local shader, technique = false, false
	
	if (filePath) then		
		shader, technique = dxCreateShader(filePath, ...)
		
		if (shader) then
			shader:setParent(g_Sandbox:getMapElement())
		end
	end

	return shader, technique
end

function SandboxHooks.dxCreateTexture(filePath, ...)
	local filePath = g_Sandbox:getFileHashFromName(filePath) or filePath
	local uTexture = dxCreateTexture(filePath, ...)
	
	if(uTexture) then
		uTexture:setParent(g_Sandbox:getMapElement())
		
		return uTexture
	end
	
	return false
end

function SandboxHooks.dxDrawImage(x, y, width, height, filePath, ...)
	if (not checkArguments("iiii", x, y, width, height)) then
		return false
	end
	
	if (type(filePath) ~= "number" or type(filePath) ~= "userdata") then
		return false
	end
	
	local filePath = g_Sandbox:getFileHashFromName(filePath) or filePath
	
	return dxDrawImage(x, y, width, height, filePath, ...)
end

function SandboxHooks.dxDrawImageSection(x, y, width, height, u, v, uSze, vSze, filePath, ...)
	if (not checkArguments("iiiiiiii", x, y, width, height, u, v, uSze, vSze)) then
		return false
	end
	
	if (type(filePath) ~= "number" or type(filePath) ~= "userdata") then
		return false
	end
	
	local filePath = (g_Sandbox:getFileHashFromName(filePath) or filePath)
	
	return dxDrawImageSection(x, y, width, height, u, v, uSze, vSze, filePath, ...)
end

function SandboxHooks.createEffect(...)
	local effect = createEffect(...)
	
	if (effect) then
		effect:setParent(g_Sandbox:getMapElement())
		
		return effect
	end
	
	return false
end

function SandboxHooks.createElement(...)
	local element = createElement(...)
	
	if (element) then
		element:setParent(g_Sandbox:getMapElement())
		
		return element
	end
	
	return false
end

function SandboxHooks.engineLoadCOL(filePath)
	local filePath = g_Sandbox:getFileHashFromName(filePath)
	local col = filePath and engineLoadCOL(filePath) or false
	
	if (col) then
		col:setParent(g_Sandbox:getMapElement())
		
		return col
	end
	
	return false
end

function SandboxHooks.engineReplaceCOL(col, modelId)
	if (engineReplaceCOL(col, modelId)) then
		loadedCol[modelId] = true
		
		return true
	end
	
	return false
end

function SandboxHooks.engineLoadDFF(filePath)
	local filePath = g_Sandbox:getFileHashFromName(filePath)
	local dff = filePath and engineLoadDFF(filePath) or false
	
	if (dff) then
		dff:setParent(g_Sandbox:getMapElement())
		
		return dff
	end
	
	return false
end

function SandboxHooks.engineReplaceModel(dff, modelId, useAlpha)
	if (engineReplaceModel(dff, modelId, useAlpha)) then
		loadedDff[modelId] = true
		
		return true
	end
	
	return false
end

function SandboxHooks.engineLoadTXD(filePath, ...)
	local filePath = g_Sandbox:getFileHashFromName(filePath)
	local txd = filePath and engineLoadTXD(filePath, ...) or false
	
	if (txd) then
		txd:setParent(g_Sandbox:getMapElement())
		
		return txd
	end
	
	return false
end

function SandboxHooks.createMarker(...)
	local marker = createMarker(...)
	
	if (marker) then
		marker:setParent(g_Sandbox:getMapElement())
		marker:setDimension(localPlayer:getDimension())
		
		return marker
	end
	
	return false
end

function SandboxHooks.createObject(...)
	local object = createObject(...)
	
	if (object) then
		object:setParent(g_Sandbox:getMapElement())
		object:setDimension(localPlayer:getDimension())
		
		return object
	end
	
	return false
end

function SandboxHooks.createPed(...)
	local ped = createPed(...)
	
	if (ped) then
		ped:setParent(g_Sandbox:getMapElement())
		ped:setDimension(localPlayer:getDimension())
		
		return ped
	end
	
	return false
end

function SandboxHooks.createPickup(...)
	local pickup = createPickup(...)
	
	if (pickup) then
		pickup:setParent(g_Sandbox:getMapElement())
		pickup:setDimension(localPlayer:getDimension())
		
		return pickup
	end
	
	return false
end

function SandboxHooks.createLight(...)
	local light = createLight(...)
	
	if (light) then
		light:setParent(g_Sandbox:getMapElement())
		light:setDimension(localPlayer:getDimension())
		
		return light
	end
	
	return false
end

function SandboxHooks.createSearchLight(...)
	local searchLight = createSearchLight(...)
	
	if (searchLight) then
		searchLight:setParent(g_Sandbox:getMapElement())
		searchLight:setDimension(localPlayer:getDimension())
		
		return searchLight
	end
	
	return false
end

function SandboxHooks.createVehicle(...)
	local vehicle = createVehicle(...)
	
	if (vehicle) then
		vehicle:setParent(g_Sandbox:getMapElement())
		vehicle:setDimension(localPlayer:getDimension())
		
		return vehicle
	end
	
	return false
end

function SandboxHooks.createWater(...)
	local water = createWater(...)
	
	if (water) then
		water:setParent(g_Sandbox:getMapElement())
		water:setDimension(localPlayer:getDimension())
		
		return water
	end
	
	return false
end

function SandboxHooks.xmlLoadFile(filePath)
	local filePath = g_Sandbox:getFileHashFromName(filePath) or false
	
	if (not filePath) then
		return false
	end
	
	local xml = xmlLoadFile(filePath)
	
	if (xml) then
		table.insert(xmlFiles, xml)
		
		return xml
	end
	
	return false
end

function SandboxHooks.xmlUnloadFile(xml)
	if (xmlUnloadFile(xml)) then
		for i, xml_ in ipairs(xmlFiles) do
			if (xml_ == xml) then
				table.remove(xmlFiles, i)
				break
			end
		end
		
		return true
	end
	
	return false
end