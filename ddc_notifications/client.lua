loadstring(exports.ddc_ui:uiLoadLibrary())()
local RESOURCE_NAME = getResourceName(getThisResource())

uiImportScript("DxNotificationProvider", RESOURCE_NAME.."/NotificationProvider.lua")
uiRegisterComponent("DxNotification", RESOURCE_NAME.."/Notification.lua")