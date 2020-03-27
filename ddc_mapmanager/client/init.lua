local function onClientResourceStart()
	g_MapLoader = new(MapLoader)
end

local function onClientResourceStop()
	delete(g_MapLoader)
end

addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart)
addEventHandler("onClientResourceStop", resourceRoot, onClientResourceStop)