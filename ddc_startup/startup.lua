local resources = {
    "ddc_core",
    "ddc_mapmanager",
    "ddc_sandbox",
    "ddc_pickups",
    "ddc_ui",
    "ddc_rooms",
    "ddc_anticheat",
}

-- Starts all resource dependencies
local function resourceSetup()
    for _, resourceName in ipairs(resources) do
        local resource = getResourceFromName(resourceName)

        if (resource and getResourceState(resource) == "running") then
            stopResource(resource)
        end
    end

    setTimer(function()
        for _, resourceName in ipairs(resources) do
            local resource = getResourceFromName(resourceName)

            if (resource) then
                startResource(resource)
            end
        end
    end, 1000, 1)
end
addEventHandler("onResourceStart", resourceRoot, resourceSetup, true, "high")

local function onResourceStop()
    for _, resourceName in ipairs(resources) do
        local resource = getResourceFromName(resourceName)

        if (resource) then
            stopResource(resource)
        end
    end
end
addEventHandler("onResourceStart", resourceRoot, onResourceStop)