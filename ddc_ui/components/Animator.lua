DxAnimator = {}

local moveAnimations = {}
local alphaAnimations = {}
local colorAnimations = {}
local sizeAnimations = {}

local tickCount = getTickCount()
local getEasingValue_ = getEasingValue

-- Returns animation value interpolated between a and b
local function getAnimationEasingValue(a, b, progress, easingType)
    if (progress >= 1) then
        return b
    else
        return (getEasingValue_(progress, easingType) * (b - a) + a)
    end
end

local function updateAnimations()
    local tick = getTickCount()
    local timeDelta = tick - tickCount
    tickCount = tick
    local progress

    local x, y

    for obj, anim in pairs(moveAnimations) do
        progress = (tickCount - anim.startTime) / anim.duration
        x = getAnimationEasingValue(anim.startX, anim.endX, progress, anim.easingType)
        y = getAnimationEasingValue(anim.startY, anim.endY, progress, anim.easingType)
        obj.x, obj.y = x, y

        -- stop animation
        if (progress >= 1) then
            moveAnimations[obj] = nil
            obj._isMoveAnimating = false
        end
    end

    local width, height

    for obj, anim in pairs(sizeAnimations) do
        progress = (tickCount - anim.startTime) / anim.duration
        width = getAnimationEasingValue(anim.startWidth, anim.endWidth, progress, anim.easingType)
        height = getAnimationEasingValue(anim.startHeight, anim.endHeight, progress, anim.easingType)
        obj.width, obj.height = width, height

        -- stop animation
        if (progress >= 1) then
            sizeAnimations[obj] = nil
            obj._isSizeAnimating = false
        end
    end

    local alpha

    for obj, anim in pairs(alphaAnimations) do
        progress = (tickCount - anim.startTime) / anim.duration
        alpha = getAnimationEasingValue(anim.alpha, anim.toAlpha, progress, anim.easingType)
        obj.alpha = alpha

        -- stop animation
        if (progress >= 1) then
            alphaAnimations[obj] = nil
            obj._isAlphaAnimating = false
        end
    end

    local r, g, b, a

    for obj, anim in pairs(colorAnimations) do
        progress = (tickCount - anim.startTime) / anim.duration
        r = getAnimationEasingValue(anim.startColor.r, anim.endColor[1], progress, anim.easingType)
        g = getAnimationEasingValue(anim.startColor.g, anim.endColor[2], progress, anim.easingType)
        b = getAnimationEasingValue(anim.startColor.b, anim.endColor[3], progress, anim.easingType)
        a = getAnimationEasingValue(anim.startColor.a, anim.endColor[4], progress, anim.easingType)
        obj[anim.propertyName] = {
            r = r,
            g = g,
            b = b,
            a = a,
        }

        -- stop animation
        if (progress >= 1) then
            colorAnimations[obj] = nil
            obj._isColorAnimating = false
        end
    end
end
addEventHandler("onClientRender", root, updateAnimations)

-- Resets animation variables.
function DxAnimator:virtual_destructor()
    moveAnimations[self] = nil
    alphaAnimations[self] = nil
    colorAnimations[self] = nil
    sizeAnimations[self] = nil

    self._isMoveAnimating = false
    self._isAlphaAnimating = false
    self._isColorAnimating = false
    self._isSizeAnimating = false
end

function DxAnimator:moveTo(x, y, duration, easingType)
    if (not x or not y) then
        return false
    end

    local duration = duration or 1000
    local easingType = easingType or "InOutQuad"
    local currentTime = getTickCount()

    -- create table entry if it doesn't already exist
    if (not moveAnimations[self]) then
        moveAnimations[self] = {}
    end

    moveAnimations[self] = {
        startTime = currentTime,
        duration = duration,
        startX = self.x,
        startY = self.y,
        endX = x,
        endY = y,
        easingType = easingType
    }

    -- update state
    self._isMoveAnimating = true
end

function DxAnimator:alphaTo(alpha, duration, easingType)
    if (not alpha) then
        return false
    end

    local duration = duration or 1000
    local easingType = easingType or "InOutQuad"
    local currentTime = getTickCount()
    local alpha = (alpha > 255 and 255) or (alpha < 0 and 0) or alpha

    -- create table entry if it doesn't already exist
    if (not alphaAnimations[self]) then
        alphaAnimations[self] = {}
    end

    alphaAnimations[self] = {
        startTime = currentTime,
        duration = duration,
        alpha = self.alpha,
        toAlpha = alpha,
        easingType = easingType
    }

    -- update state
    self._isAlphaAnimating = true
end

function DxAnimator:colorTo(propertyName, r, g, b, a, duration, easingType)
    if (type(propertyName) ~= "string" or not self[propertyName]) then
        return false
    end

    if (not r or not g or not b) then
        return false
    end

    local duration = duration or 1000
    local easingType = easingType or "InOutQuad"
    local currentTime = getTickCount()
    local a = (not a and 255) or (a > 255 and 255) or (a < 0 and 0) or a
    local r = (r > 255 and 255) or (r < 0 and 0) or r
    local g = (g > 255 and 255) or (g < 0 and 0) or g
    local b = (b > 255 and 255) or (b < 0 and 0) or b

    -- create table entry if it doesn't already exist
    if (not colorAnimations[self]) then
        colorAnimations[self] = {}
    end

    colorAnimations[self] = {
        startTime = currentTime,
        duration = duration,
        propertyName = propertyName,
        startColor = self[propertyName],
        endColor = { r, g, b, a },
        easingType = easingType
    }

    -- update state
    self._isColorAnimating = true
end

function DxAnimator:sizeTo(width, height, duration, easingType)
    if (not width or not height) then
        return false
    end

    local duration = duration or 1000
    local easingType = easingType or "InOutQuad"
    local currentTime = getTickCount()

    -- create table entry if it doesn't already exist
    if (not sizeAnimations[self]) then
        sizeAnimations[self] = {}
    end

    sizeAnimations[self] = {
        startTime = currentTime,
        duration = duration,
        startWidth = self.width,
        startHeight = self.height,
        endWidth = width,
        endHeight = height,
        easingType = easingType
    }

    -- update state
    self._isSizeAnimating = true
end

function DxAnimator:stopMoveAnimation()
    if (self:isMoveAnimating()) then
        moveAnimations[self] = nil
        return true
    end

    return false
end

function DxAnimator:stopAlphaAnimation()
    if (self:isAlphaAnimating()) then
        alphaAnimations[self] = nil
        return true
    end

    return false
end

function DxAnimator:stopSizeAnimation()
    if (self:isSizeAnimating()) then
        sizeAnimations[self] = nil
        return true
    end

    return false
end

function DxAnimator:stopColorAnimation()
    if (self:isColorAnimating()) then
        colorAnimations[self] = nil
        return true
    end

    return false
end

function DxAnimator:isMoveAnimating()
    return self._isMoveAnimating
end

function DxAnimator:isAlphaAnimating()
    return self._isAlphaAnimating
end

function DxAnimator:isSizeAnimating()
    return self._isSizeAnimating
end

function DxAnimator:isColorAnimating()
    return self._isColorAnimating
end