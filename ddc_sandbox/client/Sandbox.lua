Sandbox = {}

function Sandbox:constructor()
	self.resourceName = false
	self.downloadUrl = false
	self.sandboxEnv	= {}
	self.fileHashList = {}
	self.mutedSounds = {}
	
	self.reservedBinds = {
		-- common binds
		"f1", "f2", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10", "f11", "f12",
		"tab",
		
		-- gameplay
		"r", "enter", "space",

		-- chat
		"t", "g", "l",
		
		-- music
		--"m",

		-- spectator binds
		"arrow_l", "arrow_r", "b",
	}

	-- TODO: disable commandHandlers? What is the usage for them?
	self.disabledDictionary = {
		"triggerServerEvent", "triggerLatentServerEvent",
		"createBlip", "createBlipAttachedTo",
		"createBrowser", "guiCreateBrowser",
		"addPedClothes", "removePedClothes",
		"fileOpen", "fileCreate", "fileDelete",
		"output(.*)",
		"createRadarArea",
		"createWeapon", "createSWATRope",
		"xmlCreateFile",
		"engineLoadIFP",
		"setFPSLimit",

		"gui(.*)",
		
		-- disable local variables and functions
		"_unloadEverything",
		"checkArguments",
		"loadScript",
		"unloadScripts",
		"triggerResourceStart",
		"toggleSounds",
		"setMapData",
		"g_Sandbox",
		"SandboxHooks",
		"Sandbox",
		"events",
		"commands",
		"binds",
		"xmlFiles",
		"loadedDff",
		"loadedCol",
		"checkArguments_",

		-- these might break stuff
		"call",
		"exports",
		"addEvent",
		"triggerEvent",
		"fetchRemote",

		"_G", "collectgarbage", "getfenv", "setfenv", "load", "loadstring", "getmetatable", "setmetatable", "raw(.*)", "string.dump", "debug", 
		"math.randomseed", "newproxy",
		
		"setCameraClip",
		"setAmbientSoundEnabled", "setWorldSoundEnabled",
		"setBirdsEnabled", "setCloudsEnabled",
		"engineSetAsynchronousLoading"
	}

	self.mapRootElement = getElementByIndex("maproot", 0)
	
	self:setupSandbox()
	
	setAmbientSoundEnabled("general", false)
	setBirdsEnabled(false)
	setCloudsEnabled(false)
	
	setWorldSoundEnabled(0, 6, false, true) --- rain sounds
	setWorldSoundEnabled(0, 17, false, true) --- horn sounds
	setWorldSoundEnabled(0, 21, false, true) --- speech 1
	setWorldSoundEnabled(0, 22, false, true) --- speech 2
	setWorldSoundEnabled(0, 23, false, true) --- speech 3
	setWorldSoundEnabled(0, 24, false, true) --- speech 4
	setWorldSoundEnabled(0, 25, false, true) --- player speech
end

function Sandbox:destructor()
	self:unloadScripts()
end

function Sandbox:loadScript(fileContent)
	if (not fileContent or type(fileContent) ~= "string") then
		return
	end
	
	local byte = fileContent:byte(1)
	
	-- byte code is not supported
	if (byte == 16 or byte == 22) then
		return
	end
	
	local func, errorMessage = loadstring(fileContent)
	
	if (func) then
		setfenv(func, self.sandboxEnv)
	
		func, errorMessage = pcall(func)
	end
	
	if (not func) then
		exports.ddc_core:outputDebug("error", "Unable to load script: %s", errorMessage)
	end
end

function Sandbox:unloadScripts()
	-- call stop event
	CALLED_FROM_SANDBOX = true
	triggerEvent("onClientResourceStop", resourceRoot)
	CALLED_FROM_SANDBOX = nil
	
	_unloadEverything()
	
	self.fileHashList = {}
	self.mutedSounds = {}
	self.resourceName = false
	
	for index, _ in pairs(self.sandboxEnv) do
		self.sandboxEnv[index] = nil
	end
	
	resetWaterColor()
	resetWaterLevel()
	resetSkyGradient()
	resetRainLevel()
	resetSunSize()
	resetSunColor()
	resetWindVelocity()
	resetFarClipDistance()
	resetFogDistance()
	resetHeatHaze()
	setMinuteDuration(600000)
	setBlurLevel(0)
	restoreAllWorldModels()
	setGameSpeed(1)
	setTime(12, 0)
	setWeather(0)
	setGravity(0.008)
	setWaveHeight(0)
	
	setWorldSpecialPropertyEnabled("hovercars", false)
	setWorldSpecialPropertyEnabled("aircars", false)
	setWorldSpecialPropertyEnabled("extrajump", false)
	setWorldSpecialPropertyEnabled("randomfoliage", true)
	setWorldSpecialPropertyEnabled("snipermoon", false)
	setWorldSpecialPropertyEnabled("extraairresistance", true)
	setWorldSpecialPropertyEnabled("underworldwarp", true)

	collectgarbage()
end

function Sandbox:triggerResourceStart()
	CALLED_FROM_SANDBOX = true
	triggerEvent("onClientResourceStart", resourceRoot)
	CALLED_FROM_SANDBOX = nil
end

function Sandbox:setupSandbox()
	self.sandboxEnv = setmetatable({}, {
		__index = function(self, index)
			local isBlocked = false

			if (index == "triggerEvent") then
				outputChatBox("script tried to trigger event")
			end
			
			-- check for disabled keywords
			for _, keyword in ipairs(g_Sandbox.disabledDictionary) do
				if (index:find(keyword)) then
					isBlocked = true
					break
				end
			end
			
			if (SandboxHooks[index]) then
				return SandboxHooks[index]
			end
			
			if (not isBlocked and _G[index]) then
				return _G[index]
			end

			local type_ = type(_G[index]);
			
			if (type_ == "function") then
				return function() end
			elseif (type_ == "string") then
				return '';
			elseif (type_ == "number") then
				return 0;
			elseif (type_ == "boolean" or type_ == "userdata") then
				return false;
			elseif (type_ == "table") then
				return {};
			end
			
			return false
		end
	})
end

function Sandbox:setMapData(resourceName, downloadUrl, fileHashList)
	if (not exports.ddc_core:checkArguments("sst", resourceName, downloadUrl, fileHashList)) then
		exports.ddc_core:outputDebug("warning", "Bad argument @ Sandbox.setMapData(%s, %s, %s)", type(strResourceName), type(strdownloadUrl), type(tblFileHashList))
		return false
	end
	
	self.resourceName = resourceName
	self.downloadUrl = downloadUrl
	self.fileHashList = fileHashList
	self.mutedSounds = {}
	return true
end

function Sandbox:getFileHashFromName(fileName)
	if (not fileName or type(fileName) ~= "string") then
		return false
	end
	
	if (self.fileHashList[fileName]) then
		return ":ddc_mapmanager/cache/" .. self.fileHashList[fileName]
	end
	
	return false
end

function Sandbox:getResourceName()
	return self.resourceName
end

function Sandbox:getReservedBinds()
	return self.reservedBinds
end

function Sandbox:getDownloadUrl()
	return self.downloadUrl
end

function Sandbox:getMapElement()
	if (not self.mapRootElement or not isElement(self.mapRootElement)) then
		self.mapRootElement = getElementByIndex("maproot", 0)
	end
	
	return self.mapRootElement
end

function Sandbox:toggleSounds(state)
	for _, sound in ipairs(Element.getAllByType("sound", self:getMapElement())) do
		if (state) then
			for _, sound in ipairs(self.mutedSounds) do
				local soundElement = sound.element

				if (isElement(soundElement)) then
					soundElement:setVolume(sound.volume)
				else
					table.remove(self.mutedSounds, i)
				end
			end
		else
			self.mutedSounds[#self.mutedSounds + 1] = { element = sound, volume = sound:getVolume() }
			sound:setVolume(0)
		end
	end
end