function uiRegisterComponent(componentType, componentPath)
    return import(componentPath)
end

function uiImportScript(path)
    return import(path)
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
    if (uiIsElement(element)) then
        return uiCallMethod(element, "destroy")
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