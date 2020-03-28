local tonumber_ = tonumber
local table_insert = table.insert

MapLoader = {}

function MapLoader:constructor()
	self.disabledFileExtensions = {"mp3", "wav", "ogg", "riff", "mod", "xm", "it", "s3m", "pls"}
	self.loadedMaps = {}
end

function MapLoader:startMap(room, resourceName)
	-- no arguments were passed
	if (not room or not resourceName) then
		return
	end
	
	-- map with that resource name was already cached; return it instead
	if (self.loadedMaps[resourceName]) then
		self.loadedMaps[resourceName]._inUse = (self.loadedMaps[resourceName]._inUse or 0) + 1
		
		self:sendMapToClient(room, resourceName)
		
		return {
			resourceName = self.loadedMaps[resourceName].resourceName,
			info = self.loadedMaps[resourceName].info or {},
			settings = self.loadedMaps[resourceName].settings or {},
			spawnPoints = self.loadedMaps[resourceName].spawnPoints or {}
		}
	end
	
	local resource = getResourceFromName(resourceName)
	
	-- no resource was found - it has most likely been removed
	if (not resource) then
		return
	end
	
	local mapData, errorMessage  = self:loadMap(resourceName)
	
	-- unable to load the map and print error
	if (not mapData) then
		return exports.ddc_core:outputDebug("error", "Unable to load map resource '%s' (%s)", resourceName, errorMessage)
	end
	
	self.loadedMaps[resourceName] = {
		_inUse = 1,
		resourceName = mapData.resourceName,
		info = mapData.info,
		settings = mapData.settings,
		files = mapData.files,
		mapElements	= mapData.mapElements,
		spawnPoints	= mapData.spawnPoints,
		scripts	= mapData.scripts
	}
	
	self:sendMapToClient(room, resourceName)
	
	return {
		resourceName = mapData.resourceName,
		info = self.loadedMaps[resourceName].info or {},
		settings = self.loadedMaps[resourceName].settings or {},
		spawnPoints = self.loadedMaps[resourceName].spawnPoints or {}
	}
end

function MapLoader:stopMap(room, resourceName)
	-- no arguments were passed
	if (not resourceName or not room or (room:getType() ~= "room")) then
		return
	end
	
	-- map hasn't been loaded
	if (not self.loadedMaps[resourceName]) then
		return
	end
	
	self.loadedMaps[resourceName]._inUse = self.loadedMaps[resourceName]._inUse - 1

	if (self.loadedMaps[resourceName]._inUse == 0) then
		self.loadedMaps[resourceName] = nil
	end
	
	-- unload map on client-side
	triggerClientEvent(room, "onClientReceiveMapUnloadRequest", resourceRoot)
end

function MapLoader:loadMap(resourceName)
	local metaFile = ':'..resourceName.."/meta.xml"
	
	-- couldn't find meta - invalid map
	if (not fileExists(metaFile)) then
		return false, "'"..metaFile.."' doesnt exist"
	end
	
	local xml = XML.load(metaFile)
	
	-- unable to open XML file - the file is corrupted or has incorrect read permissions
	if (not xml) then
		return false, "Unable to load '"..metaFile.."'"
	end
	
	local nodeName = false
	local nodeAttributes, subnodeAttributes = false, false
	local isInvalid, errorMessage = isInvalid, errorMessage
	local startTick = getTickCount()
	local mapData = {
		resourceName = resourceName,
		info = {},
		settings = {},
		files = {},
		mapElements = {},
		spawnPoints = {},
		scripts = {
			client = {},
			server = {}
		},
	}
	
	for _, node in ipairs(xml:getChildren()) do
		if (not isInvalid) then
			nodeName = node:getName()
			
			-- load info
			if (nodeName == "info") then
				mapData.info = node:getAttributes()
				
			-- load settings
			elseif (nodeName == "settings") then
				for _, uSubnode in ipairs(node:getChildren()) do
					subnodeAttributes = uSubnode:getAttributes()
					
					mapData.settings[subnodeAttributes.name:gsub('#', '')] = (fromJSON(subnodeAttributes.value) or subnodeAttributes.value)
				end
				
			-- load script
			elseif (nodeName == "script") then
				nodeAttributes = node:getAttributes()
				
				local fileChecksum = getFileChecksum(':' .. resourceName .. '/' .. nodeAttributes.src)
				
				if (fileChecksum) then
					-- server-sided scripts
					if (nodeAttributes.type == "server" or nodeAttributes.type == "shared") then
						table_insert(mapData.scripts.server, nodeAttributes.src)
					end
					
					-- client-sided scripts
					if (nodeAttributes.type == "client" or nodeAttributes.type == "shared") then	
						table_insert(mapData.scripts.client, {
							name 		= nodeAttributes.src,
							checksum 	= fileChecksum,
							cache		= nodeAttributes.cache == "true" or nil
						})
					end
				else
					isInvalid = true
					errorMessage = ("Unable to get file checksum of ':%s/%s'"):format(resourceName, nodeAttributes.src)
				end
			
			-- load files
			elseif (nodeName == "file") then
				nodeAttributes = node:getAttributes()
				
				local fileExtension = nodeAttributes.src:match("%.([0-9a-zA-Z]+)")
				
				if (not exports.ddc_core:table_find(self.disabledFileExtensions, fileExtension)) then
					local fileChecksum = getFileChecksum(':' .. resourceName .. '/' .. nodeAttributes.src)
					
					if (fileChecksum) then
						table_insert(mapData.files, {
							name = nodeAttributes.src,
							checksum = fileChecksum
						})
					else
						isInvalid = true
						errorMessage = ("Unable to get file checksum of ':%s/%s'"):format(resourceName, nodeAttributes.src)
					end
				end
				
			-- load map elements
			elseif (nodeName == "map") then
				nodeAttributes = node:getAttributes()
				
				local mapElements, spawnPoints, mapLoadError = self:loadMapFile(':' .. resourceName .. '/' .. nodeAttributes.src)
				
				if (mapElements) then
					for _, elementInfo in ipairs(mapElements) do
						table_insert(mapData.mapElements, elementInfo)
					end
					
					for _, spawnInfo in ipairs(spawnPoints) do
						table_insert(mapData.spawnPoints, spawnInfo)
					end
				else
					isInvalid = true
					errorMessage = mapLoadError
				end
			else
				exports.ddc_core:outputDebug("debug", "[MapLoader] Unknown node name (%s) found in %s!", nodeName, resourceName)
			end
		end
	end
		
	xml:unload()
	
	exports.ddc_core:outputDebug("debug", "Loaded map %s in %dms! (elements: %d - spawns: %d)", resourceName, getTickCount() - startTick, #mapData.mapElements, #mapData.spawnPoints)
	
	if (isInvalid) then
		return isInvalid, errorMessage
	end
	
	return mapData
end

function MapLoader:loadMapFile(mapFile)
	if (type(mapFile) ~= "string" or not fileExists(mapFile)) then
		return nil, nil, "Unable to access map file('"..mapFile.."')"
	end
	
	local xml = XML.load(mapFile)
	
	if (not xml) then
		return nil, nil, "Unable to load map file('"..mapFile.."')"
	end
	
	local nodeName, subnodeName = false, false
	local nodeAttributes, subnodeAttributes = false, false
	local mapElements, spawnPoints = {}, {}
	
	for _, node in ipairs(xml:getChildren()) do
		nodeName = node:getName()
		nodeAttributes = node:getAttributes()

		if (nodeName == "object") then
			table_insert(mapElements, {
				name = "object",
				model = tonumber_(nodeAttributes.model),
				posX = tonumber_(nodeAttributes.posX) or 0,
				posY = tonumber_(nodeAttributes.posY) or 0,
				posZ = tonumber_(nodeAttributes.posZ) or 0,
				rotX = tonumber_(nodeAttributes.rotX) or 0,
				rotY = tonumber_(nodeAttributes.rotY) or 0,
				rotZ = tonumber_(nodeAttributes.rotZ) or 0,
				doublesided = (nodeAttributes.doublesided or "true") == "true",
				collisions = (nodeAttributes.collisions or "true") == "true",
				scale = tonumber_(nodeAttributes.scale) or 1,
				breakable = (nodeAttributes.breakable or "true") == "true",
				alpha = tonumber_(nodeAttributes.alpha) or 255
			})
		elseif (nodeName == "vehicle") then
			table_insert(mapElements, {
				name = "vehicle",
				model = tonumber_(nodeAttributes.model),
				posX = tonumber_(nodeAttributes.posX) or 0,
				posY = tonumber_(nodeAttributes.posY) or 0,
				posZ = tonumber_(nodeAttributes.posZ) or 0,
				rotX = tonumber_(nodeAttributes.rotX) or 0,
				rotY = tonumber_(nodeAttributes.rotY) or 0,
				rotZ = tonumber_(nodeAttributes.rotZ) or 0,
				alpha = tonumber_(nodeAttributes.alpha) or 255,
				paintjob = (nodeAttributes.paintjob or "3") ~= "3" and tonumber_(nodeAttributes.paintjob) or false,
				sirens = nodeAttributes.sirens == "true",
				upgrades = nodeAttributes.upgrades and split(nodeAttributes.upgrades, ',') or false,
				color = nodeAttributes.color and split(nodeAttributes.color, ',') or false
			})
		elseif (nodeName == "racepickup") then
			table_insert(mapElements, {
				name = "racepickup",
				type = nodeAttributes.type,
				posX = tonumber_(nodeAttributes.posX) or 0,
				posY = tonumber_(nodeAttributes.posY) or 0,
				posZ = tonumber_(nodeAttributes.posZ) or 0,
				rotX = tonumber_(nodeAttributes.rotX) or 0,
				rotY = tonumber_(nodeAttributes.rotY) or 0,
				rotZ = tonumber_(nodeAttributes.rotZ) or 0,
				alpha = tonumber_(nodeAttributes.alpha) or 255,
				vehicle = tonumber_(nodeAttributes.vehicle) or false,
				respawn = tonumber_(nodeAttributes.respawn) or false
			})
		elseif (nodeName == "spawnpoint") then
			table_insert(spawnPoints, {
				vehicle = tonumber_(nodeAttributes.vehicle),
				posX = tonumber_(nodeAttributes.posX) or 0,
				posY = tonumber_(nodeAttributes.posY) or 0,
				posZ = tonumber_(nodeAttributes.posZ) or 0,
				rotX = tonumber_(nodeAttributes.rotX) or 0,
				rotY = tonumber_(nodeAttributes.rotY) or 0,
				rotZ = tonumber_(nodeAttributes.rotZ) or 0
			})
		elseif (nodeName == "marker") then
			table_insert(mapElements, {
				name = "marker",
				type = nodeAttributes.type,
				posX = tonumber_(nodeAttributes.posX) or 0,
				posY = tonumber_(nodeAttributes.posY) or 0,
				posZ = tonumber_(nodeAttributes.posZ) or 0,
				rotX = tonumber_(nodeAttributes.rotX) or 0,
				rotY = tonumber_(nodeAttributes.rotY) or 0,
				rotZ = tonumber_(nodeAttributes.rotZ) or 0,
				size = tonumber_(nodeAttributes.size) or 1,
				color = tonumber_(nodeAttributes.color) and {getColorFromString(nodeAttributes.color)} or false,
				alpha = tonumber_(nodeAttributes.alpha) or 255
			})
		elseif (nodeName == "ped") then
			table_insert(mapElements, {
				name = "ped",
				model = tonumber_(nodeAttributes.model),
				posX = tonumber_(nodeAttributes.posX) or 0,
				posY = tonumber_(nodeAttributes.posY) or 0,
				posZ = tonumber_(nodeAttributes.posZ) or 0,
				rot = tonumber_(nodeAttributes.rotZ) or 0,
				alpha = tonumber_(nodeAttributes.alpha) or 255
			})
		elseif (nodeName == "removeWorldObject") then
			table_insert(mapElements, {
				name = "removeWorldObject",
				model = tonumber_(nodeAttributes.model),
				lodModel = tonumber_(nodeAttributes.lodModel),
				radius = tonumber_(nodeAttributes.radius),
				posX = tonumber_(nodeAttributes.posX) or 0,
				posY = tonumber_(nodeAttributes.posY) or 0,
				posZ = tonumber_(nodeAttributes.posZ) or 0
			})
		elseif (nodeName == "pickup") then
			table_insert(mapElements, {
				name = "pickup",
				type = nodeAttributes.type,
				posX = tonumber_(nodeAttributes.posX) or 0,
				posY = tonumber_(nodeAttributes.posY) or 0,
				posZ = tonumber_(nodeAttributes.posZ) or 0,
				rotX = tonumber_(nodeAttributes.rotX) or 0,
				rotY = tonumber_(nodeAttributes.rotY) or 0,
				rotZ = tonumber_(nodeAttributes.rotZ) or 0,
				amount = tonumber_(nodeAttributes.amount) or 100,
				respawn = tonumber_(nodeAttributes.respawn) or 30000,
				alpha = tonumber_(nodeAttributes.alpha) or 255
			})
		else
			outputDebugString("Invalid node: "..nodeName)
		end
	end

	xml:unload()

	return mapElements, spawnPoints, nil
end

function MapLoader:sendMapToClient(element, resourceName)
	if (not element or not resourceName or not isElement(element)) then
		return
	end
	
	if (element:getType() ~= "room" and element:getType() ~= "player") then
		return
	end
	
	local mapData = table.copy(self.loadedMaps[resourceName], true)
	
	if (not mapData) then
		return
	end
	
	mapData._inUse = nil
	mapData.spawnPoints = nil
	mapData.scripts = mapData.scripts.client or {}
	
	triggerClientEvent(element, "onClientReceiveMapData", resourceRoot, mapData)
end

function MapLoader:unloadClientMap(element)
	if (not element or not resourceName or not isElement(element)) then
		return
	end
	
	if (element:getType() ~= "room" and element:getType() ~= "player") then
		return
	end
	
	triggerClientEvent(element, "onClientReceiveMapUnloadRequest", resourceRoot, mapData)
end