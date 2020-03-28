local function onResourceStart()
	g_RoomManager = new(RoomManager)
end


local function onResourceStop()
	delete(g_RoomManager)
end

addEventHandler("onResourceStart", resourceRoot, onResourceStart)
addEventHandler("onResourceStop", resourceRoot, onResourceStop)