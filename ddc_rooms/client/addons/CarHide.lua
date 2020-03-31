local HUNTER_MODEL_ID = 425

CarHide = {}

function CarHide:constructor()
    self._isEnabled = false
end

function CarHide:destructor()
    if (self.hideTimer and isTimer(self.hideTimer)) then
        killTimer(self.hideTimer)
    end

    self.hideTimer = false
end

function CarHide:stateChanged(newState)
    self._isEnabled = not newState

    self:toggle()
end

function CarHide:toggle()
    local text = ""

    self._isEnabled = not self._isEnabled

    if (self._isEnabled) then
        text = "Other cars will be invisible for you."

        self:hideCars()
    else
        if (self.hideTimer and isTimer(self.hideTimer)) then
            killTimer(self.hideTimer)
        end

        self.hideTimer = false
        text = "Other cars will not be invisible for you."

        self:restoreHiddenPlayers()
    end

    local r, g, b = exports.ddc_core:getServerInfo().color.rgb
    outputChatBox(text, r, g, b)
end

function CarHide:restoreHiddenPlayers()
    local dimension = getElementDimension(localPlayer)

    for _, player in ipairs(getElementsByType("player")) do
        local vehicle = getPedOccupiedVehicle(player)

        if (vehicle) then
            setElementDimension(vehicle, dimension)
        end

        setElementDimension(player, dimension)
    end
end

function CarHide:hideCars(target)
    if (not self._isEnabled) then
        return
    end

    -- local dimension = getElementDimension(localPlayer)
    -- local spectatingPlayer = target or getCameraTarget()

    -- for _, player in ipairs(getAlivePlayers()) do
    --     local vehicle = getPedOccupiedVehicle(player)

    --     if (isElement(player) and isElement(vehicle)) then
    --         if (player ~= spectatingPlayer and player ~= localPlayer) then
    --             if (spectatingPlayer) then
    --                 if (player:getOccupiedVehicle() and player:getOccupiedVehicle():getModel() ~= HUNTER_MODEL_ID) then
    --                     player:setDimension(localPlayer:getDimension() + 1)
    --                     player:getOccupiedVehicle():setDimension(dimension + 1)
    --                 else
    --                     player:setDimension(dimension)
    --                     player:getOccupiedVehicle():setDimension(dimension)
    --                 end
    --             end
    --         else
    --             setElementDimension(player, dimension)
    --             setElementDimension(vehicle, dimension)
    --         end
    --     end
    -- end
end