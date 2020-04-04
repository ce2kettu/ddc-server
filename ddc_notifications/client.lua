loadstring(exports.ddc_ui:uiLoadLibrary())()
local RESOURCE_NAME = getResourceName(getThisResource())

uiImportScript(RESOURCE_NAME.."/NotificationProvider.lua")
uiRegisterComponent("DxNotification", RESOURCE_NAME.."/Notification.lua")