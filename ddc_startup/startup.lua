local resources = {
    "ddc_core",
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