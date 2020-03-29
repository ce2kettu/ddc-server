local resources = {
	"ddc_core",
	"ddc_mapmanager",
	"ddc_sandbox",
	"ddc_pickups",
	"ddc_ui",
	"ddc_rooms",
}

-- Starts all resource dependencies
local function resourceSetup()
	for _, resourceName in ipairs(resources) do
        local resource = Resource.getFromName(resourceName)

		if (resource and resource:getState() == "running") then
			resource:stop()
		end
	end

	Timer(function()
		for _, resourceName in ipairs(resources) do
			local resource = Resource.getFromName(resourceName)

			if (resource) then
				resource:start()
			end
		end
	end, 1000, 1)
end
addEventHandler("onResourceStart", resourceRoot, resourceSetup, true, "high")

local function onResourceStop()
	for _, resourceName in ipairs(resources) do
		local resource = Resource.getFromName(resourceName)

		if (resource) then
			resource:stop()
		end
	end
end
addEventHandler("onResourceStart", resourceRoot, onResourceStop)