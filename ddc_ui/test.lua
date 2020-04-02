-- images = {}
-- local texture = dxCreateTexture("files/images/emotes/4head.png")
-- local x = 300
-- for i = 1, 1000 do
--     table.insert(images, {
--         x = x,
--         y = 300,
--         w = 48,
--         h = 48
--     })
--     x = x + 1
-- end

-- local function test()
--     for k, v in pairs(images) do
--         dxDrawImage(v.x, v.y, v.w, v.h, texture)
--     end
-- end
-- addEventHandler("onClientRender", root, test)

--DxRoundedRect:new(200, 100, 300, 30, 15)

-- DGS = exports.dgs --get exported functions from dgs

-- local rndRect = DGS:dgsCreateRoundRect(6, false, tocolor(194, 247, 194, 215))  --Create Rounded Rectangle with 50 pixels radius 
-- local image1 = DGS:dgsCreateImage(200,200,400,100,rndRect,false)  --Apply it to the dgs image

displayNotification("success", "Success", "This is a success alert — check it out! What the fuck is wrong with me? I don't know. But today is a good day!", 5000)
-- DxNotification:new("warning", "Warning", "This is a warning alert — check it out!", 5000)
-- DxNotification:new("success", "Success", "This is a success alert — check it out! What the fuck is wrong with me? I don't know. But today is a good day!", 5000)
-- DxNotification:new("error", "Error", "This is an error alert — check it out!", 5000)
--DxNotification:new("info", "Info", "This is an info alert — check it out!")
-- DxNotification:new("warning", "", "This is a warning alert — check it out!")
-- DxNotification:new("info", "", "This is an info alert — check it out! mate you didnt explain him lucian meme?")


addCommandHandler("notif", function()
    DxNotification:new("info", "", "This is an info alert — check it out! mate you didnt explain him lucian meme?", 5000)
end)

addCommandHandler("notif2", function()
    DxNotification:new("error", "", "This is an info alert — check it out!", 2000)
end)


-- DxRoundedRectDetail:new(200, 200, 300, 30, 15, tocolor(0, 0, 0, 150), "[DM]Vortex_-Vol11-Time_Vortex's",
--     "files/images/current_map.png", 18, 18, tocolor(74, 198, 240, 255))

-- DxRoundedRectDetail:new(200, 250, 300, 30, 15, tocolor(0, 0, 0, 150), "[DM]What the fuck Ludi is a jew",
--     "files/images/next_map.png", 18, 18, tocolor(240, 198, 74, 255))

-- local x = 300
-- for i = 1, 200 do
--     local img = DxImage:new(x, 300, 48, 48, "files/images/emotes/4head.png")
--     x = x + 48
-- end