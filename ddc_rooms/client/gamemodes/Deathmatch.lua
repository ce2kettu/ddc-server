Deathmatch = {}

function Deathmatch:constructor()
	self._onClientPlayerWasted = bind(self.onClientPlayerWasted, self)
	self._requestSuicide = bind(self.requestSuicide, self)
	self._onClientRoundStart = bind(self.onClientRoundStart, self)
	self._onClientPlayerStartSpectate = bind(self.onClientPlayerStartSpectate, self)
	self._onClientPlayerStopSpectate = bind(self.onClientPlayerStopSpectate, self)

	localPlayer:setCanBeKnockedOffBike(false)
	setAmbientSoundEnabled("general", false)
	toggleControl("enter_exit", false)
	setBlurLevel(0)
	
	g_WaterKiller:toggle(true)
	g_CarFade:toggle(true)
	--g_Spectators:toggle(true)
	--g_CarHide:toggle()
	
	local roomElement = localPlayer:getParent()

	bindKey("enter", "down", self._requestSuicide)
	
	addEvent("Race:onClientPlayerWasted", true)
	addEvent("Race:onClientRoundStart", true)
	addEvent("Race:onClientPlayerStartSpectate", true)
	addEvent("Race:onClientPlayerStopSpectate", true)

	addEventHandler("Race:onClientPlayerWasted", localPlayer, self._onClientPlayerWasted)
	addEventHandler("Race:onClientRoundStart", localPlayer, self._onClientRoundStart)
	addEventHandler("Race:onClientPlayerStartSpectate", localPlayer, self._onClientPlayerStartSpectate)
	addEventHandler("Race:onClientPlayerStopSpectate", localPlayer, self._onClientPlayerStopSpectate)
end

function Deathmatch:destructor()
	localPlayer:setCanBeKnockedOffBike(true)
	setAmbientSoundEnabled("general", true)
	toggleControl("enter_exit", false)
	
	g_WaterKiller:toggle(false)
	g_CarFade:toggle(false)
	setBlurLevel(0)
	--g_Spectators:toggle(false)

	unbindKey("enter", "down", self._requestSuicide)
end

function Deathmatch:onClientPlayerStartSpectate()
	g_Spectators:toggle(true)
end

function Deathmatch:onClientPlayerStopSpectate()
	g_Spectators:toggle(false)
end

function Deathmatch:onClientPlayerWasted()
	-- reset the game speed
	setGameSpeed(1)
end

function Deathmatch:onClientRoundStart()
	triggerEvent("Race:checkSpawnedOnPickup", localPlayer)
end

function Deathmatch:requestSuicide()
	if (localPlayer:getData("state") == "alive") then
		triggerServerEvent("Race:onPlayerRequestDeath", localPlayer:getParent(), reason or "has died")
	end
end

-- called when room was changed BUT gamemode actually was the same
function Deathmatch:reset()

end

function Deathmatch:onPlayerJoinRoom(player)

end

function Deathmatch:onPlayerQuitRoom(player)

end
