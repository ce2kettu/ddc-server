CarFade = {}

function CarFade:constructor()
    self._isEnabled = false
    self.distanceToFadeIn = 10 -- GTA units

    self._doCheck = bind(self.doCheck, self)
end

function CarFade:toggle(state)
    if (type(state) ~= "boolean" or state == self:isEnabled()) then
        return false
    end

    self._isEnabled = state

    if (state) then
        addEventHandler("onClientRender", root, self._doCheck)
    else
        removeEventHandler("onClientRender", root, self._doCheck)
    end
end

function CarFade:doCheck()
    local currentCameraTarget = getCameraTarget()

    -- ensure the camera target is a player
    if (currentCameraTarget and getElementType(currentCameraTarget) == "vehicle") then
        currentCameraTarget = getVehicleController(currentCameraTarget)
    end

    -- nothing to do; abort
    if (not currentCameraTarget) then
        return
    end

    local distance = -1;
    local element = false
    local alpha = -1
    local x, y, z = getElementPosition(currentCameraTarget)

    for _, player in ipairs(self:getStreamedinPlayers()) do
        element = getPedOccupiedVehicle(player) or player
        distance = getDistanceBetweenPoints3D(x, y, z, getElementPosition(element))

        if (distance <= self.distanceToFadeIn) then
            alpha = (distance / self.distanceToFadeIn) * 255

            setElementAlpha(element, alpha)

            -- ensure to fade player alpha aswell
            if (element ~= player) then
                setElementAlpha(player, alpha)
            end
        end
    end
end

function CarFade:getStreamedinPlayers()
    local players = {}
    local roomPlayers = getElementsByType("player", getElementParent(localPlayer), true)

    for _, player in ipairs(roomPlayers) do
        if (player ~= localPlayer and getElementHealth(player) >= 1 and getElementData(player, "state") == "alive") then
            table.insert(players, player)
        end
    end

    return players
end

function CarFade:isEnabled()
    return self._isEnabled
end