local function onClientResourceStart()
    g_MapLoader = newClass(MapLoader)
end

local function onClientResourceStop()
    deleteClass(g_MapLoader)
end

addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart)
addEventHandler("onClientResourceStop", resourceRoot, onClientResourceStop)