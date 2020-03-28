
local initializedClasses = {}
Autoloader = {}

function Autoloader:initAllClasses()
    local loadTime = getTickCount()
    local currentLoadTime = loadTime
    local loadedClasses = {}

    for className, classIntance in pairs(initializedClasses) do
        if (classIntance.i) then
            classIntance:i()
            table.insert(loadedClasses, className)
        else
            outputDebug("warning", "Unable to initialize class '%s' (not an Instance class)", className)
        end

        -- debug performance
        if (classIntance.i) then
            local currentTick = getTickCount()
            local elapsedTime = currentTick - currentLoadTime
            currentLoadTime = currentTick

            outputDebug("debug", "Successfully loaded class '%s' in %dms!", className, elapsedTime)
        end
    end

    initializedClasses = loadedClasses

	local currentTick = getTickCount()
	local elapsedTime = currentTick - loadTime
	local classesLoaded = #loadedClasses
    local suffix = (classesLoaded == 0 or classesLoaded >= 2) and "es" or ''

	outputDebug("debug", "Successfully loaded %d class%s in %dms!", classesLoaded, suffix, elapsedTime)
end

function Autoloader:destroyAllClasses()
    local startTime = getTickCount()
    local currentDestructTime = startTime
	
    for _, className in ipairs(initializedClasses) do
        if (_G[className] and _G[className].i) then
            delete(_G[className]:i())

			local currentTick = getTickCount()
			local elapsedTime = (currentTick - currentDestructTime)
			currentDestructTime = currentTick

			outputDebug("debug", "Unloaded class '%s' in %dms!", className, elapsedTime)
        end
    end

	local elapsedTime = getTickCount() - startTime
    local totalInstances = #initializedClasses
    local suffix = (totalInstances == 0 or totalInstances >= 2) and "es" or ''

	outputDebug("debug", "Unloaded %d class%s in %dms!", totalInstances, suffix, elapsedTime)
end

function preInitializeClass(className)
    if (not checkArguments("s", className)) then
        outputDebug("warning", "Bad arguments @preInitializeClass(%s)", type(className))
        return
    end
	
	if (initializedClasses[className]) then
		return
	end
	
	local newClass = rawget(_G, className)
	
    if (type(newClass) == "table") then
		initializedClasses[className] = newClass
    end
end