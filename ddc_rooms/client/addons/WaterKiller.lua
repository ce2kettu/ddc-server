WaterKiller = {}

function WaterKiller:constructor()
    self._isEnabled = false
    self.waterCheckTimer = false
    self.waterCraftIds = { 539, 460, 417, 447, 472, 473, 493, 595, 484, 430, 453, 452, 446, 454 }

    self._doPulse = bind(self.doPulse, self)
end

function WaterKiller:toggle(state)
    if (type(state) ~= "boolean" or state == self:isEnabled()) then
        return false
    end

    self._isEnabled = state

    if (state) then
        self.waterCheckTimer = setTimer(self._doPulse, 1000, 0)
    else
        if (self.waterCheckTimer and isTimer(self.waterCheckTimer)) then
            killTimer(self.waterCheckTimer)
        end

        self.waterCheckTimer = false
    end
end

function WaterKiller:doPulse()
    -- player is already dead
    if (getElementHealth(localPlayer) <= 0) then
        return
    end

    -- get current vehicle's model
    local currentVehicle = getPedOccupiedVehicle(localPlayer)
    local modelId = (currentVehicle and getElementModel(currentVehicle)) or false

    -- player is not in water
    if (not isElementInWater(currentVehicle or localPlayer)) then
        return
    end

    -- check against watercrafts
    if (not modelId or not exports.ddc_core:table_find(self.waterCraftIds, modelId)) then
        -- kill player
        setElementHealth(localPlayer, 0)
    end
end

function WaterKiller:isEnabled()
    return self._isEnabled
end