local function onResourceStart()
    g_RoomManager = newClass(RoomManager)
end

local function onResourceStop()
    deleteClass(g_RoomManager)
end

addEventHandler("onResourceStart", resourceRoot, onResourceStart)
addEventHandler("onResourceStop", resourceRoot, onResourceStop)