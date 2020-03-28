local function onClientResourceStart()
	g_RoomManager = new(RoomManager)
	
	-- addons
	g_Spectators = new(Spectators)
	g_WaterKiller = new(WaterKiller)
	g_CarFade = new(CarFade)
	g_CarHide = new(CarHide)
end

local function onClientResourceStop()
	delete(g_RoomManager)
	
	-- addons
	delete(g_Spectators)
	delete(g_Waterkiller)
	delete(g_CarFade)
	delete(g_CarHide)
end

addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart)
addEventHandler("onClientResourceStop", resourceRoot, onClientResourceStop)