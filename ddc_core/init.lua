local function onResourceStart(uResource)
	if(Core) then
		Core:new()
	end
end


local function onResourceStop()
	if (Core) then
		delete(Core:i())
	end
end

addEventHandler((g_bServer and "onResourceStart" or "onClientResourceStart"), resourceRoot, onResourceStart)
addEventHandler((g_bServer and "onResourceStop" or "onClientResourceStop"), resourceRoot, onResourceStop)