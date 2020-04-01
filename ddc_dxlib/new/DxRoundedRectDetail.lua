DxRoundedRectDetail = inherit(DxElement)

local CORNER_TEXTURE = false
local REL_SIZE = math.floor(SCREEN_HEIGHT / 1080)
local RECT_PADDING = REL_SIZE * 8
local MARGIN_LEFT = REL_SIZE * 6
local MARGIN_BOTTOM = MARGIN_LEFT
local IMAGE_MARGIN_LEFT = 0
local TEXT_MARGIN_LEFT = REL_SIZE * 4
local font = dxCreateFont("files/fonts/font_opensans_semibold.ttf", REL_SIZE * 12, false, "cleartype_natural")

function DxRoundedRectDetail:constructor(x, y, width, height, cornerSize, backgroundColor, text, texture, textureWidth, textureHeight, textureColor)
    self.type = "dx-rounded-rect-detail"
    self._texture = texture

	if (type(cornerSize) ~= "number") then
		return false
	end

	if (cornerSize > 20) then
        self:destroy()
        outputDebugString("[DxRoundedRectDetail] Corner size can't be more than 20")
        return false
    end

    if (height < cornerSize * 2) then
        self:destroy()
        outputDebugString("[DxRoundedRectDetail] Rectangle height must be at least twice the size of corner size")
        return false
    end

    if (texture) then
        self.width = dxGetTextWidth(text, 1, font) + (RECT_PADDING * 2) + TEXT_MARGIN_LEFT + textureWidth + IMAGE_MARGIN_LEFT

        if (type(self._texture) == "string") then
            self._texture = dxCreateTexture(texture)
        end

        if (not isElement(self._texture)) then
            self:destroy()
            return error("[DxRoundedRectDetail] Texture creation failed (constructor)")
        end

        self._textureColor = textureColor or tocolor(255, 255, 255, 255)
        self._textureWidth = textureWidth
        self._textureHeight = textureHeight
    else
        self.width = dxGetTextWidth(text, 1, font) + (RECT_PADDING * 2) + TEXT_MARGIN_LEFT
    end

    if (not CORNER_TEXTURE) then
        CORNER_TEXTURE = dxCreateTexture("files/images/rounded_corner.png", "argb", false, "clamp")
    end

    self._text = text
    self._cornerSize = cornerSize
    self._backgroundColor = backgroundColor or tocolor(255, 255, 255, 255)
end

function DxRoundedRectDetail:dxDraw()
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

    if (self._texture) then
        local textX = self.x + TEXT_MARGIN_LEFT + RECT_PADDING + IMAGE_MARGIN_LEFT + self._textureWidth
        dxDrawImage(self.x + IMAGE_MARGIN_LEFT + RECT_PADDING, self.y + (self.height - self._textureHeight) / 2, self._textureWidth, self._textureHeight, self._texture, 0, 0, 0, self._textureColor)
        dxDrawText(self._text, textX, self.y, textX + self.width, self.y + self.height, tocolor(255, 255, 255, 255), 1, font, "left", "center")
    else
        local textX = self.x + TEXT_MARGIN_LEFT + RECT_PADDING
        dxDrawText(self._text, textX, self.y, textX + self.width, self.y + self.height, tocolor(255, 255, 255, 255), 1, font, "left", "center")
    end
end