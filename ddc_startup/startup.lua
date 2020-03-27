local resources = {
	"ddc_core",
	"ddc_sandbox",
	"ddc_mapmanager",
	"ddc_pickups",
}

-- Starts all resource dependencies
local function resourceSetup()
    for _, resourceName in ipairs(resources) do
        local resource = Resource.getFromName(resourceName)

		if (resource) then
			resource:start()
		end
	end
end
addEventHandler("onResourceStart", resourceRoot, resourceSetup)