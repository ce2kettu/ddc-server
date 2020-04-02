DxRoundedRect = inherit(DxElement)

local CORNER_TEXTURE = dxCreateTexture("files/images/rounded_corner.png", "argb", false, "clamp")

function DxRoundedRect:new(...)
	if not self then 
		return false 
	end
	
	self = new(self)
	
	local tblRequiredArgs = {
		{name="iBaseX", default=0, typeof="number"},
		{name="iBaseY", default=0, typeof="number"},
		{name="iWidth", default=0, typeof="number"},
        {name="iHeight", default=0, typeof="number"},
        {name="iCornerSize", default=20, typeof="number"}
    }

    local tblOptionalArgs = {
		{name="backgroundColor", default=tocolor(255,255,255,255), typeof="number"},
	}
	
	local vrtArgumentCheck, tblRemainingArgs = argvf({...}, tblRequiredArgs, tblOptionalArgs) --vrt = variable return type
	if not vrtArgumentCheck then return false end
	
	for argKey, vrtArg in pairs(vrtArgumentCheck) do --Traverse the formatted argument table and add them to our object.
		self["m_"..argKey] = vrtArg
    end

    if (self.m_iCornerSize > 20) then
        self = nil
        outputDebugString("DxRoundedRect: corner size can't be more than 20")
        return false
    end
    
    if (self.m_iHeight < self.m_iCornerSize * 2) then
        self = nil
        outputDebugString("DxRoundedRect: rectangle height must be at least twice the size of corner size")
        return false
    end
	
	--Core vars & functionality added here.
	self.m_strTypeOf = "dx-rounded-rect"

	self:constructGlobalDefaults()
	DxObjects[self] = self
	DxObjects[self]:setIndex(1)
	return DxObjects[self]
end

function DxRoundedRect:draw()
	if not self.m_bDisplay then 
		return false 
	end

    -- top left corner
    dxDrawImage(self.m_iX, self.m_iY, self.m_iCornerSize, self.m_iCornerSize, CORNER_TEXTURE, 0, 0, 0, self.m_backgroundColor)

    -- top right corner
    dxDrawImage(self.m_iX + self.m_iWidth - self.m_iCornerSize, self.m_iY, self.m_iCornerSize, self.m_iCornerSize, CORNER_TEXTURE, 90, 0, 0, self.m_backgroundColor)

    -- bottom left corner
    dxDrawImage(self.m_iX, self.m_iY + self.m_iHeight - self.m_iCornerSize, self.m_iCornerSize, self.m_iCornerSize, CORNER_TEXTURE, -90, 0, 0, self.m_backgroundColor)

    -- bottom right corner
    dxDrawImage(self.m_iX + self.m_iWidth - self.m_iCornerSize, self.m_iY + self.m_iHeight - self.m_iCornerSize, self.m_iCornerSize, self.m_iCornerSize, CORNER_TEXTURE, 180, 0, 0, self.m_backgroundColor)

    -- fill gap between top corners
    dxDrawRectangle(self.m_iX + self.m_iCornerSize, self.m_iY, self.m_iWidth - 2 * self.m_iCornerSize, self.m_iCornerSize, self.m_backgroundColor)

    -- fill gap between bottom corners
    dxDrawRectangle(self.m_iX + self.m_iCornerSize, self.m_iY + self.m_iHeight - self.m_iCornerSize, self.m_iWidth - 2 * self.m_iCornerSize, self.m_iCornerSize, self.m_backgroundColor)

    -- fill middle
    dxDrawRectangle(self.m_iX, self.m_iY + self.m_iCornerSize, self.m_iWidth, self.m_iHeight - self.m_iCornerSize * 2, self.m_backgroundColor)
end