local events = {}
local commands = {}
local timers = {}
local binds = {}
local xmlFiles = {}
local loadedDff = {}
local loadedCol = {}
local checkArguments_ = checkArguments

SandboxHooks = {}

function _unloadEverything()
    -- unload all events
    for _, eventInfo in ipairs(events) do
        removeEventHandler(unpack(eventInfo))
    end

    -- unload all commands
    for _, commandInfo in ipairs(commands) do
        removeCommandHandler(unpack(commandInfo))
    end

    -- destroy all timers
    for _, timer in ipairs(timers) do
        if (isTimer(timer)) then
            killTimer(timer)
        end
    end

    -- unload all binds
    for _, bindInfo in ipairs(binds) do
        unbindKey(unpack(bindInfo))
    end

    -- unload all xml files
    for _, xml in ipairs(xmlFiles) do
        xmlUnloadFile(xml)
    end

    -- restore all models
    for modelId, _ in pairs(loadedDff) do
        engineRestoreModel(modelId)
    end

    -- restore all collisions
    for modelId, _ in pairs(loadedCol) do
        engineRestoreCOL(modelId)
    end

    -- reset variables
    events = {}
    commands = {}
    timers = {}
    binds = {}
    xmlFiles = {}
    loadedDff = {}
    loadedCol = {}
end

-- can be replaced with getTimers()
function SandboxHooks.setTimer(...)
    local timer = setTimer(...)

    if (timer) then
        table.insert(timers, timer)
        return
    end

    return false
end

function SandboxHooks.setElementData(element, key, value)
    -- don't sync data
    setElementData(element, key, value, false)
end

function SandboxHooks.addEventHandler(eventName, attachedToElement, handler, ...)
    if (not checkArguments_("suf", eventName, attachedToElement, handler)) then
        return false
    end

    -- TODO: check if eventHandler is already added to prevent errors from being logged

    if (addEventHandler(eventName, attachedToElement, handler, ...)) then
        table.insert(events, {eventName, attachedToElement, handler})
        return true
    end

    return false
end

function SandboxHooks.removeEventHandler(eventName, attachedToElement, handler)
    if (not checkArguments_("suf", eventName, attachedToElement, handler)) then
        return false
    end

    if (removeEventHandler(eventName, attachedToElement, handler)) then
        for i, eventInfo in ipairs(binds) do
            if (eventName == eventInfo[1] and attachedToElement == eventInfo[2] and handler == eventInfo[3]) then
                table.remove(events, i)
                break
            end
        end

        return true
    end

    return false
end

function SandboxHooks.addCommandHandler(commandName, handler, ...)
    if (not checkArguments_("sf", commandName, handler)) then
        return false
    end

    if (addCommandHandler(commandName, handler, ...)) then
        table.insert(commands, {commandName, handler})
        return true
    end

    return false
end

function SandboxHooks.removeCommandHandler(commandName, handler)
    if (not checkArguments_("sf", commandName, handler)) then
        return false
    end

    if (removeCommandHandler(commandName, handler)) then
        for i, commandInfo in ipairs(commands) do
            if (commandName == commandInfo[1] and handler == commandInfo[2]) then
                table.remove(commands, i)
                break
            end
        end

        return true
    end

    return false
end

function SandboxHooks.bindKey(key, keyState, handler, ...)
    if (not checkArguments_("ss", key, keyState)) then
        return false
    end

    if (type(handler) ~= "function" and type(handler) ~= "string") then
        return false
    end

    if (exports.ddc_core:table_find(g_Sandbox:getReservedBinds(), key:lower())) then
        return false
    end

    if (bindKey(key, keyState, handler, ...)) then
        table.insert(binds, {key, keyState, handler})
        return true
    end

    return false
end

function SandboxHooks.unbindKey(key, keyState, handler)
    if (not checkArguments_("ss", key, keyState)) then
        return false
    end

    if (type(handler) ~= "function" and type(handler) ~= "string") then
        return false
    end

    if (exports.ddc_core:table_find(g_Sandbox:getReservedBinds(), key:lower())) then
        return false
    end

    if (unbindKey(key, keyState, handler)) then
        for i, bindInfo in ipairs(binds) do
            if (key == bindInfo[1] and keyState == bindInfo[2] and handler == bindInfo[3]) then
                table.remove(binds, i)
                break
            end
        end

        return true
    end

    return false
end

-- does not allow remote paths
function SandboxHooks.playSound(filePath, isLooped, isThrottled)
    if (not checkArguments_("s", filePath)) then
        return false
    end

    local filePath = tostring(g_Sandbox:getDownloadUrl())..tostring(g_Sandbox:getResourceName()).."/"..tostring(filePath)
    local sound = playSound(filePath, isLooped, isThrottled)

    if (sound) then
        setElementParent(sound, g_Sandbox:getMapElement())

        return sound
    end

    return false
end

-- does not allow remote paths
function SandboxHooks.playSound3D(filePath, x, y, z, ...)
    if (not checkArguments_("siii", filePath, x, y, z)) then
        return false
    end

    local filePath = tostring(g_Sandbox:getDownloadUrl())..tostring(g_Sandbox:getResourceName()).."/"..tostring(filePath)
    local sound = playSound3D(filePath, x, y, z, ...)

    if (sound) then
        setElementParent(sound, g_Sandbox:getMapElement())

        return sound
    end

    return false
end

function SandboxHooks.createColCircle(x, y, z, radus)
    if (not checkArguments_("iiii", x, y, z, radus)) then
        return false
    end

    local colshape = createColCircle(x, y, z, radus)

    if (colshape) then
        setElementParent(colshape, g_Sandbox:getMapElement())
        setElementDimension(colshape, getElementDimension(localPlayer))

        return colshape
    end

    return false
end

function SandboxHooks.createColCuboid(x, y, z, width, depth, height)
    if (not checkArguments_("iiiiii", x, y, z, width, depth, height)) then
        return false
    end

    local colshape = createColCuboid(x, y, z, width, depth, height)

    if (colshape) then
        setElementParent(colshape, g_Sandbox:getMapElement())
        setElementDimension(colshape, getElementDimension(localPlayer))

        return colshape
    end

    return false
end

function SandboxHooks.createColPolygon(x, y, x2, y2, x3, y3, x4, y4, ...)
    if (not checkArguments_("iiiiiiii", x, y, z, width, depth, height)) then
        return false
    end

    local colshape = createColPolygon(x, y, x2, y2, x3, y3, x4, y4, ...)

    if (colshape) then
        setElementParent(colshape, g_Sandbox:getMapElement())
        setElementDimension(colshape, getElementDimension(localPlayer))

        return colshape
    end

    return false
end

function SandboxHooks.createColRectangle(x, y, width, height)
    if (not checkArguments_("iiii", x, y, width, height)) then
        return false
    end

    local colshape = createColRectangle(x, y, width, height)

    if (colshape) then
        setElementParent(colshape, g_Sandbox:getMapElement())
        setElementDimension(colshape, getElementDimension(localPlayer))

        return colshape
    end

    return false
end

function SandboxHooks.createColSphere(x, y, z, radus)
    if (not checkArguments_("iiii", x, y, z, radus)) then
        return false
    end

    local colshape = createColSphere(x, y, z, radus)

    if (colshape) then
        setElementParent(colshape, g_Sandbox:getMapElement())
        setElementDimension(colshape, getElementDimension(localPlayer))

        return colshape
    end

    return false
end

function SandboxHooks.createColTube(x, y, z, radus, height)
    if (not checkArguments_("iiiii", x, y, z, radus, height)) then
        return false
    end

    local colshape = createColTube(x, y, z, radus, height)

    if (colshape) then
        setElementParent(colshape, g_Sandbox:getMapElement())
        setElementDimension(colshape, getElementDimension(localPlayer))

        return colshape
    end

    return false
end

function SandboxHooks.dxCreateFont(filePath, ...)
    local filePath = g_Sandbox:getFileHashFromName(filePath)
    local font = filePath and dxCreateFont(filePath, ...) or false

    if (font) then
        setElementParent(font, g_Sandbox:getMapElement())

        return font
    end

    return false
end

function SandboxHooks.dxCreateShader(filePath, ...)
    local filePath = g_Sandbox:getFileHashFromName(filePath)
    local shader, technique = false, false

    if (filePath) then
        shader, technique = dxCreateShader(filePath, ...)

        if (shader) then
            setElementParent(shader, g_Sandbox:getMapElement())
        end
    end

    return shader, technique
end

function SandboxHooks.dxCreateTexture(filePath, ...)
    local filePath = g_Sandbox:getFileHashFromName(filePath)

    local texture = filePath and dxCreateTexture(filePath, ...) or false

    if (texture) then
        setElementParent(texture, g_Sandbox:getMapElement())

        return texture
    end

    return false
end

function SandboxHooks.dxDrawImage(x, y, width, height, filePath, ...)
    if (not checkArguments_("iiii", x, y, width, height)) then
        return false
    end

    if (type(filePath) ~= "number" or type(filePath) ~= "userdata") then
        return false
    end

    local filePath = g_Sandbox:getFileHashFromName(filePath) or filePath

    return dxDrawImage(x, y, width, height, filePath, ...)
end

function SandboxHooks.dxDrawImageSection(x, y, width, height, u, v, uSze, vSze, filePath, ...)
    if (not checkArguments_("iiiiiiii", x, y, width, height, u, v, uSze, vSze)) then
        return false
    end

    if (type(filePath) ~= "number" or type(filePath) ~= "userdata") then
        return false
    end

    local filePath = g_Sandbox:getFileHashFromName(filePath) or filePath

    return dxDrawImageSection(x, y, width, height, u, v, uSze, vSze, filePath, ...)
end

function SandboxHooks.createEffect(...)
    local effect = createEffect(...)

    if (effect) then
        setElementParent(effect, g_Sandbox:getMapElement())

        return effect
    end

    return false
end

function SandboxHooks.createElement(...)
    local element = createElement(...)

    if (element) then
        setElementParent(element, g_Sandbox:getMapElement())

        return element
    end

    return false
end

function SandboxHooks.engineLoadCOL(filePath)
    local filePath = g_Sandbox:getFileHashFromName(filePath)
    local col = filePath and engineLoadCOL(filePath) or false

    if (col) then
        setElementParent(col, g_Sandbox:getMapElement())

        return col
    end

    return false
end

function SandboxHooks.engineReplaceCOL(col, modelId)
    if (not col or type(col) ~= "userdata") then
        return false
    end

    if (engineReplaceCOL(col, modelId)) then
        loadedCol[modelId] = true

        return true
    end

    return false
end

function SandboxHooks.engineLoadDFF(filePath)
    local filePath = g_Sandbox:getFileHashFromName(filePath)
    local dff = filePath and engineLoadDFF(filePath) or false

    if (dff) then
        setElementParent(dff, g_Sandbox:getMapElement())

        return dff
    end

    return false
end

function SandboxHooks.engineReplaceModel(dff, modelId, useAlpha)
    if (not dff or type(dff) ~= "userdata") then
        return false
    end

    if (engineReplaceModel(dff, modelId, useAlpha)) then
        loadedDff[modelId] = true

        return true
    end

    return false
end

function SandboxHooks.engineLoadTXD(filePath, ...)
    local filePath = g_Sandbox:getFileHashFromName(filePath)
    local txd = filePath and engineLoadTXD(filePath, ...) or false

    if (txd) then
        setElementParent(txd, g_Sandbox:getMapElement())

        return txd
    end

    return false
end

function SandboxHooks.engineImportTXD(txd, modelId)
    if (not txd or type(txd) ~= "userdata") then
        return false
    end

    return engineImportTXD(txd, modelId)
end

function SandboxHooks.createMarker(...)
    local marker = createMarker(...)

    if (marker) then
        setElementParent(marker, g_Sandbox:getMapElement())
        setElementDimension(marker, getElementDimension(localPlayer))

        return marker
    end

    return false
end

function SandboxHooks.createObject(...)
    local object = createObject(...)

    if (object) then
        setElementParent(object, g_Sandbox:getMapElement())
        setElementDimension(object, getElementDimension(localPlayer))

        return object
    end

    return false
end

function SandboxHooks.createPed(...)
    local ped = createPed(...)

    if (ped) then
        setElementParent(ped, g_Sandbox:getMapElement())
        setElementDimension(ped, getElementDimension(localPlayer))

        return ped
    end

    return false
end

function SandboxHooks.createPickup(...)
    local pickup = createPickup(...)

    if (pickup) then
        setElementParent(pickup, g_Sandbox:getMapElement())
        setElementDimension(pickup, getElementDimension(localPlayer))

        return pickup
    end

    return false
end

function SandboxHooks.createLight(...)
    local light = createLight(...)

    if (light) then
        setElementParent(light, g_Sandbox:getMapElement())
        setElementDimension(light, getElementDimension(localPlayer))

        return light
    end

    return false
end

function SandboxHooks.createSearchLight(...)
    local searchLight = createSearchLight(...)

    if (searchLight) then
        setElementParent(searchLight, g_Sandbox:getMapElement())
        setElementDimension(searchLight, getElementDimension(localPlayer))

        return searchLight
    end

    return false
end

function SandboxHooks.createVehicle(...)
    local vehicle = createVehicle(...)

    if (vehicle) then
        setElementParent(vehicle, g_Sandbox:getMapElement())
        setElementDimension(vehicle, getElementDimension(localPlayer))

        return vehicle
    end

    return false
end

function SandboxHooks.createWater(...)
    local water = createWater(...)

    if (water) then
        setElementParent(water, g_Sandbox:getMapElement())
        setElementDimension(water, getElementDimension(localPlayer))

        return water
    end

    return false
end

function SandboxHooks.xmlLoadFile(filePath)
    local filePath = g_Sandbox:getFileHashFromName(filePath) or false

    if (not filePath) then
        return false
    end

    local xml = xmlLoadFile(filePath)

    if (xml) then
        table.insert(xmlFiles, xml)

        return xml
    end

    return false
end

function SandboxHooks.xmlUnloadFile(xml)
    if (xmlUnloadFile(xml)) then
        for i, xml_ in ipairs(xmlFiles) do
            if (xml_ == xml) then
                table.remove(xmlFiles, i)
                break
            end
        end

        return true
    end

    return false
end