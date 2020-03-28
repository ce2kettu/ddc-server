local resources = {
	"ddc_core",
	"ddc_mapmanager",
	"ddc_sandbox",
	"ddc_pickups",
	"ddc_ui",
	"ddc_rooms",
}

local resource = false

-- Starts all resource dependencies
local function resourceSetup()
    for _, resourceName in ipairs(resources) do
        resource = Resource.getFromName(resourceName)

		if (resource) then
			resource:start()
		end
	end
end
addEventHandler("onResourceStart", resourceRoot, resourceSetup)