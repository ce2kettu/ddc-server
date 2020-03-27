local function onResourceStart()
	if (Core) then
		Core:new()
	end
end

local function onResourceStop()
	if (Core) then
		delete(Core:i())
	end
end

addEventHandler((g_isServer and "onResourceStart" or "onClientResourceStart"), resourceRoot, onResourceStart)
addEventHandler((g_isServer and "onResourceStop" or "onClientResourceStop"), resourceRoot, onResourceStop)