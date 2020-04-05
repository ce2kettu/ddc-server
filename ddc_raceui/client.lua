
loadstring(exports.ddc_ui:uiLoadLibrary())()
local SCREEN_WIDTH, SCREEN_HEIGHT = guiGetScreenSize()
local MAP_INFO_MARGIN = 10
local MAP_BAR_HEIGHT = 30
local NEXT_MAP_MARGIN_BOTTOM = 8

local UICurrentMap = DxRoundedRectDetail:new(MAP_INFO_MARGIN, SCREEN_HEIGHT - MAP_INFO_MARGIN - MAP_BAR_HEIGHT, 0, MAP_BAR_HEIGHT, MAP_BAR_HEIGHT / 2, tocolor(0, 0, 0, 150), "[DM]Vortex_-Vol11-Time_Vortex's",
    "files/images/current_map.png", 15, 15, tocolor(74, 198, 240, 255))

local UINextMap = DxRoundedRectDetail:new(MAP_INFO_MARGIN, SCREEN_HEIGHT - MAP_INFO_MARGIN - (MAP_BAR_HEIGHT * 2) - NEXT_MAP_MARGIN_BOTTOM, 0, MAP_BAR_HEIGHT, MAP_BAR_HEIGHT / 2, tocolor(0, 0, 0, 150), "[DM]What a time to be alive",
    "files/images/next_map.png", 15, 15, tocolor(198, 240, 74, 255))

addCommandHandler("test2", function(c, val)
    --t._text = "kekw"
    --uiCallMethod(UICurrentMap, "moveTo", 400, 200)
    --uiCallMethod(UICurrentMap, )
    --exports.ddc_notifications:displayNotification("info", "Notice", "Map is starting!")
end)