local function onClientResourceStart()
    g_RoomManager = newClass(RoomManager)

    -- addons
    g_Spectators = newClass(Spectators)
    g_WaterKiller = newClass(WaterKiller)
    g_CarFade = newClass(CarFade)
    g_CarHide = newClass(CarHide)
end

local function onClientResourceStop()
    deleteClass(g_RoomManager)

    -- addons
    deleteClass(g_Spectators)
    deleteClass(g_WaterKiller)
    deleteClass(g_CarFade)
    deleteClass(g_CarHide)
end

addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart)
addEventHandler("onClientResourceStop", resourceRoot, onClientResourceStop)