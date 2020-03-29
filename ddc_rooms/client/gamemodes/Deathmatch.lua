Deathmatch = {}

function Deathmatch:constructor()
	localPlayer:setCanBeKnockedOffBike(false)
	setAmbientSoundEnabled("general", false)
	toggleControl("enter_exit", false)
	
	g_WaterKiller:toggle(true)
	g_CarFade:toggle(true)
	--g_Spectators:toggle(true)
	--g_CarHide:toggle()

	self._suicide = bind(self.suicide, self)

	bindKey("space", "down", self._suicide)
	
	outputChatBox("Client-sided Deathmatch constructor")
end

function Deathmatch:destructor()
	localPlayer:setCanBeKnockedOffBike(true)
	setAmbientSoundEnabled("general", true)
	toggleControl("enter_exit", false)
	
	g_WaterKiller:toggle(false)
	g_CarFade:toggle(false)
	--g_Spectators:toggle(false)

	unbindKey("space", "down", self._suicide)

	outputChatBox("Client-sided Deathmatch destructor")
end

function Deathmatch:suicide()
	if (localPlayer:getData("state") == "alive") then
		triggerServerEvent("Race:killPlayer", localPlayer:getParent(), reason or "has died")
	end
end

-- TODO: triggerEvent("Race:checkSpawnedOnPickup", localPlayer)

-- called when room was changed BUT gamemode actually was the same
function Deathmatch:reset()

end

function Deathmatch:onPlayerJoinRoom(player)

end

function Deathmatch:onPlayerQuitRoom(player)

end
