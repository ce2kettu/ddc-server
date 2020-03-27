function getMaps(...)
	return g_MapManager:getMapList(...)
end

function sendMapToClient(element, resourceName)
	return g_MapLoader:sendMapToClient(element, resourceName)
end

function startMap(room, resourceName)
	return g_MapLoader:startMap(room, resourceName)
end

function stopMap(room, resourceName)
	return g_MapLoader:stopMap(room, resourceName)
end