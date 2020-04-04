
loadstring(exports.ddc_ui:uiLoadLibrary())()
local t = DxRoundedRectDetail:new(200, 200, 300, 30, 15, tocolor(0, 0, 0, 150), "[DM]Vortex_-Vol11-Time_Vortex's",
"files/images/current_map.png", 18, 18, tocolor(74, 198, 240, 255))

addCommandHandler("test2", function(c, val)
    --t._text = "kekw"
    exports.ddc_notifications:displayNotification("info", "Notice", "Map is starting!")
end)