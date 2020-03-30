local function onClientResourceStart()
    if (CALLED_FROM_SANDBOX) then
        return
    end

    g_Sandbox = new(Sandbox)
end

local function onClientResourceStop()
    if (CALLED_FROM_SANDBOX) then
        return
    end

    delete(g_Sandbox)
end

addEventHandler("onClientResourceStart", resourceRoot, onClientResourceStart)
addEventHandler("onClientResourceStop", resourceRoot, onClientResourceStop)