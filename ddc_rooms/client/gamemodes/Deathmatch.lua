Deathmatch = {}

function Deathmatch:constructor()
	localPlayer:setCanBeKnockedOffBike(false)
	setAmbientSoundEnabled("general", false)
	
	g_Waterkiller:toggle(true)
	g_CarFade:toggle(true)
	
	outputChatBox("Clientsided Deathmatch constructor")
end

function Deathmatch:destructor()
	localPlayer:setCanBeKnockedOffBike(true)
	setAmbientSoundEnabled("general", true)
	
	g_Waterkiller:toggle(true)
	g_CarFade:toggle(true)
	
	outputChatBox("Clientsided Deathmatch destructor")
end

-- called when room was changed BUT gamemode actually was the same
function Deathmatch:reset()

end

function Deathmatch:onPlayerJoinRoom(player)

end

function Deathmatch:onPlayerQuitRoom(player)

end
