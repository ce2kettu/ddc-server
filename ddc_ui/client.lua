--local window = DxWindow:new(200, 200, 600, 400)
--local button = DxButton:new(300, 300, 200, 50, "hey")
local font = dxStyles.FONTS.FONT_SEMIBOLD_SMALL
local REL = math.floor(g_vScreenSize.y / 1080)
local mapName = "[DM]Vortex_-Vol11-Time_Vortex's"
local padding = math.floor((g_vScreenSize.y / 1080) * 8)
local PADDING_LEFT = REL * 6
local PADDING_BOTTOM = PADDING_LEFT
local IMAGE_PADDING_LEFT = REL * 8
local width = dxGetTextWidth(mapName, 1, font) + padding * 2 + 18 + IMAGE_PADDING_LEFT
local height = 30
local TEXT_PADDING_LEFT = REL * 4
local posX, posY = PADDING_LEFT, (g_vScreenSize.y - PADDING_BOTTOM - height)
local rect = DxRoundedRect:new(posX, posY, width, height, height / 2, tocolor(0, 0, 0, 150))

--showCursor(true)

local function drawUI()
    dxDrawImage(posX + IMAGE_PADDING_LEFT, posY + (height - 18) / 2, 18, 18, "files/images/current_map.png", 0, 0, 0, tocolor(74, 198, 240, 255))
    dxDrawText(mapName, posX + TEXT_PADDING_LEFT + IMAGE_PADDING_LEFT + 18, posY, posX + TEXT_PADDING_LEFT + IMAGE_PADDING_LEFT + 18 + width, posY + height, tocolor(255, 255, 255, 255), 1, font, "left", "center")
    --window:draw()
    --button:draw()
end
addEventHandler("onClientRender", root, drawUI)


addCommandHandler("move", function()
    --window:resizeWindow(800, 600)
    --window:moveTo(200 + 100, 200 + 100)
end)