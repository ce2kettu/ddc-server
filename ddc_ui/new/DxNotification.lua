DxNotification = inherit(DxAnimator)

NOTIFICATION_CURRENT_Y = 0

local CORNER_TEXTURE = false
--local function REL(a) return a * RELATIVE_SCALE end
local font = dxCreateFont("files/fonts/font_opensans_semibold.ttf", FONT_SIZE(12), false, "cleartype_natural") or "default"
local fontDetail = dxCreateFont("files/fonts/font_opensans_regular.ttf", FONT_SIZE(12), false, "cleartype_natural") or "default"

local RECT_PADDING_H = REL(16)
local RECT_PADDING_V = REL(8)
local DETAIL_MARGIN_LEFT = REL(7)
local DETAIL_MARGIN_TOP = REL(3)
local MIN_WIDTH = REL(375)
local CORNER_SIZE = 6
local ICON_SIZE = FONT_SIZE(24)
local DESCRIPTION_MAX_LINE_COUNT = 3
local FONT_DETAIL_HEIGHT = dxGetFontHeight(1, fontDetail)
local RECT_MARGIN_RIGHT = REL(16)
local RECT_MARGIN_TOP = RECT_MARGIN_RIGHT
local NOTIFICATION_ALPHA = 215

function DxNotification:new(type, title, description, duration)
    self = new(self)

    self.type = "dx-notification"
    self._type = type or "info"
    self._duration = duration or 5000
    self._hasTitle = false

    if (title and title ~= "") then
        self._title = title
        self._hasTitle = true
    end

    if (type == "success") then
        self._backgroundColor = tocolor(194, 247, 194, NOTIFICATION_ALPHA)
        self._iconColor = tocolor(76, 176, 80)
        self._textColor = tocolor(30, 70, 32)
    elseif (type == "error") then
        self._backgroundColor = tocolor(253, 193, 191, NOTIFICATION_ALPHA)
        self._iconColor = tocolor(244, 67, 54)
        self._textColor = tocolor(97, 26, 21)
    elseif (type == "warning") then
        self._backgroundColor = tocolor(249, 214, 167, NOTIFICATION_ALPHA)
        self._iconColor = tocolor(255, 152, 0)
        self._textColor = tocolor(102, 60, 0)
    elseif (type == "info") then
        self._backgroundColor = tocolor(145, 203, 247, NOTIFICATION_ALPHA)
        self._iconColor = tocolor(33, 150, 243)
        self._textColor = tocolor(13, 60, 97)
    end

    -- MTA doesn't calculate width correctly so we add some offset padding
    local offset = 0.07425
    local lineCount = math.ceil((dxGetTextWidth(description, 1, fontDetail) / (MIN_WIDTH - (RECT_PADDING_H * 2) - ICON_SIZE - DETAIL_MARGIN_LEFT) + offset))
    local lineCount = (lineCount > DESCRIPTION_MAX_LINE_COUNT) and DESCRIPTION_MAX_LINE_COUNT or lineCount
    local totalHeight = ((self._hasTitle and (lineCount + 1) or lineCount) * FONT_DETAIL_HEIGHT) + (RECT_PADDING_V * 2)

    self.width = MIN_WIDTH
    self.height = totalHeight
    self.x = SCREEN_WIDTH - MIN_WIDTH - RECT_MARGIN_RIGHT
    self.y = NOTIFICATION_CURRENT_Y + RECT_MARGIN_TOP
    NOTIFICATION_CURRENT_Y = self.y + totalHeight

    local contentWidth = MIN_WIDTH - (RECT_PADDING_H * 2) - ICON_SIZE - DETAIL_MARGIN_LEFT

    -- wrap text to lines
    if (lineCount > 1) then
        local prevLine = ""
        local lines = {}

        for i = 1, lineCount do
            local text = description:gsub(escapePattern(prevLine), "")
            local line = ""

            if (i ~= lineCount) then
                line = textOverflow(text, 1, fontDetail, contentWidth)
                line = line:gsub("(.*)%s.*$", "%1") ~= line and line:gsub("(.*)%s.*$", "%1").." " or line
            else
                line = textOverflow(text, 1, fontDetail, contentWidth, true)
            end

            table.insert(lines, line)
            prevLine = prevLine..line
        end

        description = table.concat(lines, "\n")
    else
        description = textOverflow(description, 1, fontDetail, contentWidth, true)
    end

    self._description = description

    if (not CORNER_TEXTURE) then
        CORNER_TEXTURE = dxCreateTexture("files/images/rounded_corner.png", "argb", false, "clamp")
    end

    self:createCachedTexture()

    DxNotificationProvider:enqueueNotification(self)
end

function DxNotification:destructor()
    destroyElement(self.cachedTexture)
end

function DxNotification:createCachedTexture()
    self.cachedTexture = dxCreateRenderTarget(self.width, self.height, true)

    dxSetRenderTarget(self.cachedTexture, true)

    -- top left corner
    dxDrawImage(0, 0, CORNER_SIZE, CORNER_SIZE, CORNER_TEXTURE, 0, 0, 0, self._backgroundColor)

    -- top right corner
    dxDrawImage(0 + self.width - CORNER_SIZE, 0, CORNER_SIZE, CORNER_SIZE, CORNER_TEXTURE, 90, 0, 0, self._backgroundColor)

    -- bottom left corner
    dxDrawImage(0, 0 + self.height - CORNER_SIZE, CORNER_SIZE, CORNER_SIZE, CORNER_TEXTURE, -90, 0, 0, self._backgroundColor)

    -- bottom right corner
    dxDrawImage(0 + self.width - CORNER_SIZE, 0 + self.height - CORNER_SIZE, CORNER_SIZE, CORNER_SIZE, CORNER_TEXTURE, 180, 0, 0, self._backgroundColor)

    -- fill gap between top corners
    dxDrawRectangle(0 + CORNER_SIZE, 0, self.width - 2 * CORNER_SIZE, CORNER_SIZE, self._backgroundColor)

    -- fill gap between bottom corners
    dxDrawRectangle(0 + CORNER_SIZE, 0 + self.height - CORNER_SIZE, self.width - 2 * CORNER_SIZE, CORNER_SIZE, self._backgroundColor)

    -- fill middle
    dxDrawRectangle(0, 0 + CORNER_SIZE, self.width, self.height - CORNER_SIZE * 2, self._backgroundColor)

    local startX = 0 + RECT_PADDING_H
    local startY = 0 + RECT_PADDING_V
    dxDrawImage(startX, startY, ICON_SIZE, ICON_SIZE, "files/images/notification_"..self._type..".png", 0, 0, 0, self._iconColor)

    local detailStartX = startX + ICON_SIZE + DETAIL_MARGIN_LEFT
    local detailStartY = startY + REL(1)
    local contentSizeX = detailStartX - RECT_PADDING_H
    local contentSizeY = detailStartY - RECT_PADDING_V

    dxSetBlendMode("modulate_add")
    if (self._hasTitle) then
        dxDrawText(self._title, detailStartX, detailStartY, contentSizeX, contentSizeY, self._textColor, 1, font)
        dxDrawText(self._description, detailStartX, detailStartY + FONT_DETAIL_HEIGHT + DETAIL_MARGIN_TOP, contentSizeX, contentSizeY - FONT_DETAIL_HEIGHT - DETAIL_MARGIN_TOP, self._textColor, 1, fontDetail)
    else
        dxDrawText(self._description, detailStartX, detailStartY, contentSizeX, contentSizeY, self._textColor, 1, fontDetail)
    end
    dxSetBlendMode("blend")

    dxSetRenderTarget()
end

function DxNotification:dxDraw()
    if (self.cachedTexture) then
        dxSetBlendMode("add")
        dxDrawImage(self.x, self.y, self.width, self.height, self.cachedTexture)
        dxSetBlendMode("blend")
    end

    -- -- top left corner
    -- dxDrawImage(self.x, self.y, CORNER_SIZE, CORNER_SIZE, CORNER_TEXTURE, 0, 0, 0, self._backgroundColor)

    -- -- top right corner
    -- dxDrawImage(self.x + self.width - CORNER_SIZE, self.y, CORNER_SIZE, CORNER_SIZE, CORNER_TEXTURE, 90, 0, 0, self._backgroundColor)

    -- -- bottom left corner
    -- dxDrawImage(self.x, self.y + self.height - CORNER_SIZE, CORNER_SIZE, CORNER_SIZE, CORNER_TEXTURE, -90, 0, 0, self._backgroundColor)

    -- -- bottom right corner
    -- dxDrawImage(self.x + self.width - CORNER_SIZE, self.y + self.height - CORNER_SIZE, CORNER_SIZE, CORNER_SIZE, CORNER_TEXTURE, 180, 0, 0, self._backgroundColor)

    -- -- fill gap between top corners
    -- dxDrawRectangle(self.x + CORNER_SIZE, self.y, self.width - 2 * CORNER_SIZE, CORNER_SIZE, self._backgroundColor)

    -- -- fill gap between bottom corners
    -- dxDrawRectangle(self.x + CORNER_SIZE, self.y + self.height - CORNER_SIZE, self.width - 2 * CORNER_SIZE, CORNER_SIZE, self._backgroundColor)

    -- -- fill middle
    -- dxDrawRectangle(self.x, self.y + CORNER_SIZE, self.width, self.height - CORNER_SIZE * 2, self._backgroundColor)

    -- local startX = self.x + RECT_PADDING_H
    -- local startY = self.y + RECT_PADDING_V
    -- dxDrawImage(startX, startY, ICON_SIZE, ICON_SIZE, "files/images/notification_"..self._type..".png", 0, 0, 0, self._iconColor)

    -- local detailStartX = startX + ICON_SIZE + DETAIL_MARGIN_LEFT
    -- local detailStartY = startY + REL(1)
    -- local contentSizeX = detailStartX - RECT_PADDING_H
    -- local contentSizeY = detailStartY - RECT_PADDING_V

    -- if (self._hasTitle) then
    --     dxDrawText(self._title, detailStartX, detailStartY, contentSizeX, contentSizeY, self._textColor, 1, font)
    --     dxDrawText(self._description, detailStartX, detailStartY + FONT_DETAIL_HEIGHT + DETAIL_MARGIN_TOP, contentSizeX, contentSizeY - FONT_DETAIL_HEIGHT - DETAIL_MARGIN_TOP, self._textColor, 1, fontDetail)
    -- else
    --     dxDrawText(self._description, detailStartX, detailStartY, contentSizeX, contentSizeY, self._textColor, 1, fontDetail)
    -- end
end