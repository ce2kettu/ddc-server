local function onResourceStart()
	g_MapLoader = new(MapLoader)
	g_MapManager = new(MapManager)
end

local function onResourceStop()
	delete(g_MapManager)
	delete(g_MapLoader)
end

addEventHandler("onResourceStart", resourceRoot, onResourceStart)
addEventHandler("onResourceStop", resourceRoot, onResourceStop)