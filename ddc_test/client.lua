loadstring(exports.ddc_ui:uiLoadLibrary())()
local uiLib = uiClass


-- ui:createComponent("DxImage2", "ddc_test/DxImage2.lua")

-- local img = ui:uiCreateElement("DxImage2", 500, 500, 100, 100, ":ddc_ui/files/images/next_map.png")

-- addCommandHandler("test2", function()
--     ui:uiCallMethod(img, "moveTo", 100, 100)
-- end)

exports.ddc_core:var_dump("-v", DxImage)

--uiLib:uiRegisterComponent("DxImage2", "ddc_test/DxImage2.lua")

DxImage:new(500, 500, 100, 100, ":ddc_test/biblethump.png")

-- DxImage2.tt = "het"

-- test = {
--     hey = "k",
--     moi = "t"
-- }

-- local a = exports.ddc_ui:createElement(0, 0, 200, 100)
-- a:moveTo(50, 50)
-- exports.ddc_core:var_dump("-v", a)
--local t = exports.ddc_ui:createComponent(DxImage2, 0, 0, 200, 100)
--exports.ddc_core:var_dump("-v", t)