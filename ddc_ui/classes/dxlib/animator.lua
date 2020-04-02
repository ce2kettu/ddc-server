DxAnimate = {}
DxAnimations = {}

function DxAnimate:moveTo(x, y, duration, easingType)
    if (not x or not y) then
        return false
    end

    if (self.isMoving) then
        return false
    end

    local duration = duration or 1000
    local easingType = easingType or "InOutQuad"
    local currentTime = getTickCount()

    if (not DxAnimations[self]) then
        DxAnimations[self] = {}
    end

    if (DxAnimations[self].moveTo) then
        return false
    end

    local startX, startY = self.m_iBaseX, self.m_iBaseY
    local iEndX, iEndY = x, y

    if self.m_tblParent then
        startX, startY = self.ms_iOriginalBaseX, self.ms_iOriginalBaseY
        iEndX, iEndY = x, y
    end

    DxAnimations[self].moveTo = {
        iStartTime = currentTime,
        iEndTime = currentTime + duration,
        tblStartPos = {x=startX, y=startY},
        tblEndPos = {x=iEndX, y=iEndY},
        easingType = easingType
    }

    self.ms_bIsAnimating = true

    if(not self.ms_eRenderAnimation) then
        self.ms_eRenderAnimation = bind(self.renderAnimation, self)
    end

    addEventHandler("onClientRender", root, self.ms_eRenderAnimation)
end

function DxAnimate:resizeWindow(iWidth, iHeight, duration, easingType, bCentered, bIgnoreMinimums) --bCentered: Should the window scale whilst keeping a central position? (if not, the window will appear to scale from the top-left)
    if self.m_strTypeOf ~= "dx-window" then
        return false
    end

    if not iWidth or not iHeight then
        return false
    end

    local duration = duration or 1000
    local easingType = easingType or "InOutQuad"
    local currentTime = getTickCount()

    local iMinPadding = 75

    if not bIgnoreMinimums then --Checks if width/height are below minimum, if so > set minimum. bIgnoreMinimums should be set to false if you want to do an effect such as starting with 0 width & height and then animating to full size, or vice versa.
        if (iWidth < (dxGetTextWidth(self.m_strTitleBarText, self.m_iTitleBarScale, self.m_fntTitleBar) + self.m_iCloseButtonWidth + iMinPadding) ) then
            iWidth = dxGetTextWidth(self.m_strTitleBarText, self.m_iTitleBarScale, self.m_fntTitleBar) + self.m_iCloseButtonWidth + iMinPadding
        end

        if (iHeight < self.m_iTitleBarHeight) then
            iHeight = self.m_iTitleBarHeight
        end
    end

    if not DxAnimations[self] then
        DxAnimations[self] = {}
    end

    if DxAnimations[self].resizeWindow then
        return false
    end

    DxAnimations[self].resizeWindow = {
        iStartTime = currentTime,
        iEndTime = currentTime + duration,
        tblStartSize = {width=self.m_iWidth, height=self.m_iHeight},
        tblEndSize = {width=iWidth, height=iHeight},
        easingType = easingType,
        bCentered = bCentered
    }

    self.ms_bIsAnimating = true

    if not self.ms_eRenderResize then
        self.ms_eRenderResize = bind(DxAnimate.renderResize, self)
    end
    addEventHandler("onClientRender", root, self.ms_eRenderResize)
end

function DxAnimate:renderResize()
    self.ms_bIsAnimating = true
    local tblAnimData = DxAnimations[self].resizeWindow
    local iCurrentTick = getTickCount()
    local iElapsedTime = iCurrentTick - tblAnimData.iStartTime
    local duration = tblAnimData.iEndTime - tblAnimData.iStartTime
    local iProgress = iElapsedTime / duration

    local iWidth, iHeight, _ = interpolateBetween(tblAnimData.tblStartSize.width, tblAnimData.tblStartSize.height, 0, tblAnimData.tblEndSize.width, tblAnimData.tblEndSize.height, 0, iProgress, tblAnimData.easingType)

    if self:isOutOfBounds() then
        self:forceInBounds()
        DxAnimations[self].renderResize = nil
        self.ms_bIsAnimating = false
        removeEventHandler("onClientRender", root, self.ms_eRenderResize)
        return true
    end

    self.m_iWidth, self.m_iHeight = iWidth, iHeight

    if iProgress > 1 then
        DxAnimations[self].resizeWindow = nil
        self.ms_bIsAnimating = false
        removeEventHandler("onClientRender", root, self.ms_eRenderResize)
    end

end


function DxAnimate:renderAnimation()
    self.ms_bIsAnimating = true --Make sure this is set to true during animation (otherwise multitple animations would conflict when they ended)

    local tblAnimData = DxAnimations[self].moveTo
    local iCurrentTick = getTickCount()
    local iElapsedTime = iCurrentTick - tblAnimData.iStartTime
    local duration = tblAnimData.iEndTime - tblAnimData.iStartTime
    local iProgress = iElapsedTime / duration

    local x, y, _ = interpolateBetween(tblAnimData.tblStartPos.x, tblAnimData.tblStartPos.y, 0, tblAnimData.tblEndPos.x, tblAnimData.tblEndPos.y, 0, iProgress, tblAnimData.easingType)

    if not self.m_tblParent then
        if self:isOutOfBounds(x, y) then
            self:forceInBounds()
            DxAnimations[self].moveTo = nil
            self.ms_bIsAnimating = false
            removeEventHandler("onClientRender", root, self.ms_eRenderAnimation)
            return true
        end
        self.m_iX, self.m_iY = x, y
    else
        self.ms_iOriginalBaseX, self.ms_iOriginalBaseY = x, y
        x, y = self:calculateRelatives(x, y)
        self.m_iBaseX, self.m_iBaseY = x, y
    end

    if iProgress > 1 then
        DxAnimations[self].moveTo = nil
        self.ms_bIsAnimating = false
        removeEventHandler("onClientRender", root, self.ms_eRenderAnimation)
    end
end


function DxAnimate:isOutOfBounds(x, y)
    x, y = x or self.m_iX, y or self.m_iY

    --Make sure the window doesn't go out of the screen on any side.
    if (x-(self.m_iBorderThickness*2)) <= 0 then
        return true
    end

    if (y-(self.m_iBorderThickness*2)) <= 0 then
        return true
    end

    if (x + self.m_iWidth + (self.m_iBorderThickness*2)) >= g_vScreenSize.x  then
        return true
    end

    if (y + self.m_iHeight + (self.m_iBorderThickness*2)) >= g_vScreenSize.y then
        return true
    end

    return false
end

function DxAnimate:forceInBounds()
    --Make sure the window doesn't go out of the screen on any side.
    if (self.m_iX+(self.m_iBorderThickness*2)) <= 0 then
        self.m_iX = self.m_iBorderThickness * 2
    end

    if (self.m_iY+(self.m_iBorderThickness*2)) <= 0 then
        self.m_iY = self.m_iBorderThickness * 2
    end

    if (self.m_iX + self.m_iWidth + (self.m_iBorderThickness*2)) >= g_vScreenSize.x  then
        self.m_iX = self.m_iX - ((self.m_iX + self.m_iWidth + (self.m_iBorderThickness*2)) - g_vScreenSize.x)
    end

    if (self.m_iY + self.m_iHeight + (self.m_iBorderThickness*2)) >= g_vScreenSize.y then
        self.m_iY = self.m_iY - ((self.m_iY + self.m_iHeight + (self.m_iBorderThickness*2)) - g_vScreenSize.x)
    end
end
