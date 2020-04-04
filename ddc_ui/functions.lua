function uiRegisterComponent(componentType, componentPath)
    if (_G[componentType]) then
        _G[componentType] = nil
    end

    local result = import(componentPath)
    collectgarbage()
    return result
end

function uiImportScript(scriptClass, path)
    -- If class already exists, destroy it and release memory
    if (_G[scriptClass]) then
        if (_G[scriptClass].destroy) then
            _G[scriptClass]:destroy()
        end

        _G[scriptClass] = nil
    end

    local result = import(path)
    collectgarbage()
    return result
end

function uiCreateElement(classType, ...)
    if (not _G[classType]) then
        return false
    end

    local element = _G[classType]:new(...)

    if (not element) then
        return false
    end

    DxHostedElements[element.uid] = element

    return element
end

function uiDestroyElement(element, ...)
    local uid = (type(element) == "table") and element.uid or element

    element = DxHostedElements[uid]

    if (uiIsElement(element)) then
        uiCallMethod(element, "destroy")
        DxHostedElements[uid] = nil
        return true
    end

    return false
end

function uiIsElement(element)
    if (not element) then
        return false
    end

    if (type(element) ~= "table") then
        return false
    end

    if (not element.uid) then
        return false
    end

    if (not string.match(element.type, "dx")) then
        return false
    end

    return true
end

function uiCallMethod(element, methodName, ...)
    local uid = (type(element) == "table") and element.uid or element

    element = DxHostedElements[uid]

    if (not uiIsElement(element)) then
        return false
    end

    if (not element[methodName]) then
        return false
    end

    local args = {...}

    for i, arg in ipairs(args) do
        if (type(arg) == "table" and arg.uid) then
            args[i] = DxHostedElements[arg.uid]
        end
    end

    return element[methodName](element, unpack(args))
end

function uiSetProperty(element, ...)
	return uiCallMethod(element, "setProperty", ...)
end

function uiGetProperty(element, ...)
	return uiCallMethod(element, "getProperty", ...)
end