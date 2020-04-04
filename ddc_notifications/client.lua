loadstring(exports.ddc_ui:uiLoadLibrary())()
local RESOURCE_NAME = getResourceName(getThisResource())

uiImportScript(RESOURCE_NAME.."/NotificationProvider.lua")
uiRegisterComponent("DxNotification", RESOURCE_NAME.."/Notification.lua")

local t = DxRoundedRectDetail:new(200, 200, 300, 30, 15, tocolor(0, 0, 0, 150), "[DM]Vortex_-Vol11-Time_Vortex's",
    "files/images/current_map.png", 18, 18, tocolor(74, 198, 240, 255))

addCommandHandler("test2", function(c, t)
    local notif = uiCreateElement("DxNotification", "success", "Success", 
    "This is a success alert — check it out! What the fuck is wrong with me? I don't know. But today is a good day!", 5000)
end)