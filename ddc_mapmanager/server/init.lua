local function onResourceStart()
    g_MapLoader = newClass(MapLoader)
    g_MapManager = newClass(MapManager)
end

local function onResourceStop()
    deleteClass(g_MapManager)
    deleteClass(g_MapLoader)
end

addEventHandler("onResourceStart", resourceRoot, onResourceStart)
addEventHandler("onResourceStop", resourceRoot, onResourceStop)