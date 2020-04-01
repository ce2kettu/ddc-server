DxRoundedRect = inherit(DxElement)

local CORNER_TEXTURE = false

function DxRoundedRect:constructor(x, y, width, height, cornerSize, backgroundColor)
    self.type = "dx-rounded-rect"

	if (type(cornerSize) ~= "number") then
		return false
	end

	if (cornerSize > 20) then
        self:destroy()
        outputDebugString("[DxRoundedRect] Corner size can't be more than 20")
        return false
    end

    if (height < cornerSize * 2) then
        self:destroy()
        outputDebugString("[DxRoundedRect] Rectangle height must be at least twice the size of corner size")
        return false
    end

    if (not CORNER_TEXTURE) then
        CORNER_TEXTURE = dxCreateTexture("files/images/rounded_corner.png", "argb", false, "clamp")
    end

    self._cornerSize = cornerSize
    self._backgroundColor = (backgroundColor and backgroundColor) or tocolor(255, 255, 255, 255)
end

function DxRoundedRect:dxDraw()
    -- top left corner
    dxDrawImage(self.x, self.y, self._cornerSize, self._cornerSize, CORNER_TEXTURE, 0, 0, 0, self._backgroundColor)

    -- top right corner
    dxDrawImage(self.x + self.width - self._cornerSize, self.y, self._cornerSize, self._cornerSize, CORNER_TEXTURE, 90, 0, 0, self._backgroundColor)

    -- bottom left corner
    dxDrawImage(self.x, self.y + self.height - self._cornerSize, self._cornerSize, self._cornerSize, CORNER_TEXTURE, -90, 0, 0, self._backgroundColor)

    -- bottom right corner
    dxDrawImage(self.x + self.width - self._cornerSize, self.y + self.height - self._cornerSize, self._cornerSize, self._cornerSize, CORNER_TEXTURE, 180, 0, 0, self._backgroundColor)

    -- fill gap between top corners
    dxDrawRectangle(self.x + self._cornerSize, self.y, self.width - 2 * self._cornerSize, self._cornerSize, self._backgroundColor)

    -- fill gap between bottom corners
    dxDrawRectangle(self.x + self._cornerSize, self.y + self.height - self._cornerSize, self.width - 2 * self._cornerSize, self._cornerSize, self._backgroundColor)

    -- fill middle
    dxDrawRectangle(self.x, self.y + self._cornerSize, self.width, self.height - self._cornerSize * 2, self._backgroundColor)
end