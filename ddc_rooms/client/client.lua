local screenX, screenY = guiGetScreenSize()
local relX, relY = (screenX / 1920), (screenY / 1080)
local currentPage = 1
local roomChunks = {}
local cameraPosition = {1881.2105712891, -2154.0209960938, 90.420677185059, 1842.4438476563, -2061.8564453125, 88.730598449707}

-- design constants
local ICON_MARGIN_LARGE = math.floor(15 * relY)
local ICON_MARGIN_SMALL = math.floor(10 * relY)
local LOGO_MARGIN_TOP = math.floor(60 * relY)
local WEBSITE_MARGIN_BOTTOM = math.floor(54 * relY)
local FONT_SIZE_DEFAULT = math.floor(15 * relY)
local FONT_SIZE_ICONS = math.floor(13 * relY)
local FONT_SIZE_LARGE = math.floor(59 * relY)
local FONT_SIZE_SMALL = math.floor(13 * relY)
local FONT_SIZE_SMALLISH = math.floor(12 * relY)
local COLOR_WHITE = tocolor(255, 255, 255, 255)
local COLOR_DARK = tocolor(16, 16, 16, 255)
local UNISON_PINK = tocolor(255, 124, 162, 255)
local BACKGROUND_WHITE = tocolor(255, 255, 255, 217)
local BACKGROUND_DARK = tocolor(16 , 16, 16, 217)
local ROOM_WIDTH = math.floor(275 * relY)
local ROOM_HEIGHT = math.floor(275 * relY)
local ROOM_OFFSET = math.floor(30 * relY)
local ROOM_PADDING = math.floor(20 * relY)
local MAX_ROOMS_SHOWN = screenX > 4 * (ROOM_WIDTH + ROOM_OFFSET) - ROOM_OFFSET and 4 or 3
local DESCRIPTION_MAX_LINE_COUNT = 4

-- animation variables
local currentlyHovered = nil
local animTransformStartTime = nil
local animTransformEndTime = nil
local isAnimating = false
local backgroundColorR, backgroundColorG, backgroundColorB = 16, 16, 16
local accentColorR, accentColorG, accentColorB = 255, 255, 255
local roomIconPosY = nil
local roomIconPosStart = nil
local roomIconPosEnd = nil
local roomTitlePosY = nil
local roomTitlePosStart = nil
local roomTitlePosEnd = nil
local roomArrowPosY = nil
local roomArrowPosStart = nil
local roomArrowPosEnd = nil
local fadeOutAlphaAmount = 255
local fadeInAlphaAmount = 0
local ANIMATION_EASING_TYPE = "InOutQuad"
local ANIMATION_TRANSFORM_TIMING = 185
local ANIMATION_FADE_TIMING = 585

setPlayerHudComponentVisible("all", false)
setTime(21, 40)
setWeather(13)
setAmbientSoundEnabled("general", false)
fadeCamera(true)
setCameraMatrix(unpack(cameraPosition))
showCursor(true)

function main()
    FONT_ICON_REGULAR = dxCreateFont(":ddc_ui/files/fonts/font_icon_regular.otf", FONT_SIZE_ICONS, false, "cleartype_natural")
    FONT_ICON_SMALL = dxCreateFont(":ddc_ui/files/fonts/font_icon_regular.otf", FONT_SIZE_SMALL, false, "cleartype_natural")
    FONT_ICON_LARGE = dxCreateFont(":ddc_ui/files/fonts/font_icon_light.otf", FONT_SIZE_LARGE, false, "cleartype_natural")
    FONT_SEMIBOLD = dxCreateFont(":ddc_ui/files/fonts/font_opensans_semibold.ttf", FONT_SIZE_DEFAULT, false, "cleartype_natural")
    FONT_SMALL = dxCreateFont(":ddc_ui/files/fonts/font_opensans_regular.ttf", FONT_SIZE_SMALLISH, false, "cleartype_natural")
    FONT_REGULAR = dxCreateFont(":ddc_ui/files/fonts/font_opensans_regular.ttf", FONT_SIZE_SMALL, false, "cleartype_natural")
    FONT_BOLD = dxCreateFont(":ddc_ui/files/fonts/font_opensans_bold.ttf", FONT_SIZE_DEFAULT, false, "cleartype_natural")

    -- g_uBackgroundMusic = playSound("files/sounds/lobby.mp3", true)
    -- setSoundVolume(g_uBackgroundMusic, 0.5)

    addEventHandler("onClientRender", root, render)
    addEventHandler("onClientKey", root, keyHandler)
end
addEventHandler("onClientResourceStart", resourceRoot, main)

function destroy()
    if (g_uBackgroundMusic and isElement(g_uBackgroundMusic))then
        stopSound(g_uBackgroundMusic)
    end

    removeEventHandler("onClientRender", root, render)
    removeEventHandler("onClientKey", root, keyHandler)
end
addEventHandler("onClientResourceStop", resourceRoot, destroy)

function render()
    dxSetBlendMode("modulate_add")

    local iCursorX, iCursorY 	= getCursorPosition()
    local iScreenX, iScreenY 	= getScreenFromWorldPosition(cameraPosition[4], cameraPosition[5], cameraPosition[6])
    local iParallexFactor 		= 30

    if iScreenX and iScreenY then
        iCursorX = ((iCursorX - 0.5) * iParallexFactor) * 2
        iCursorY = ((iCursorY - 0.5) * iParallexFactor) * 2

        iScreenX = iScreenX + iCursorX
        iScreenY = iScreenY + iCursorY

        local x, y, z = getWorldFromScreenPosition(iScreenX, iScreenY, 1)
        setCameraMatrix(cameraPosition[1], cameraPosition[2], cameraPosition[3], x, y, z)
    end

    -- background
    dxDrawImage(0, 0, screenX, screenY, "files/images/bg.jpg", 0, 0, 0, BACKGROUND_WHITE)

    -- logo
    local logoWidth = math.floor(195 * relY)
    local logoHeight = math.round(49 / 195 * logoWidth)

    dxDrawImage(math.floor(screenX / 2 - logoWidth / 2), LOGO_MARGIN_TOP, logoWidth, logoHeight, ":ddc_ui/files/images/logo.png", 0, 0, 0, COLOR_WHITE, false)

    -- website text and icon
    local websiteTextWidth = dxGetTextWidth("visit unisonchampionships.com", 1, FONT_SEMIBOLD)
    local websiteIconWidth = dxGetTextWidth("", 1, FONT_ICON_REGULAR)

    dxDrawText("", screenX / 2 - websiteTextWidth / 2 - websiteIconWidth / 2 - ICON_MARGIN_LARGE / 2, screenY - WEBSITE_MARGIN_BOTTOM + 3 * relY, screenX, screenY, UNISON_PINK, 1, FONT_ICON_REGULAR)
    dxDrawText("visit unisonchampionships.com", screenX / 2 - websiteTextWidth / 2 + websiteIconWidth / 2 + ICON_MARGIN_LARGE / 2, screenY - WEBSITE_MARGIN_BOTTOM, screenX, screenY, COLOR_WHITE, 1, FONT_SEMIBOLD)

    local temp = getElementsByType("room")
    rooms = {}

    for _, uRoom in ipairs(temp) do
        table.insert(rooms, {
            element = uRoom,
            name = getElementData(uRoom, "name"),
            description = getElementData(uRoom, "description"),
            icon = getElementData(uRoom, "icon"),
            password = getElementData(uRoom, "password")
        })
    end

    paginationHandler()
    structureRooms()

    dxSetBlendMode("blend")
end

function paginationHandler()
    if #rooms == 0 then return end

    roomChunks = {}

    for i = 1, #rooms, MAX_ROOMS_SHOWN do
        roomChunks[#roomChunks + 1] = table.slice(rooms, i, i + MAX_ROOMS_SHOWN - 1)
    end

    if #roomChunks == 0 then return end

    local imageSize = math.floor(10 * relY)
    local totalWidth = #roomChunks * (imageSize + ICON_MARGIN_SMALL) - ICON_MARGIN_SMALL
    local startX = screenX / 2 - totalWidth / 2
    local startY = screenY / 2 + ROOM_HEIGHT / 2 + ROOM_OFFSET
    local currentX = startX
    local currentY = startY

    for i = 1, #roomChunks, 1 do
        dxDrawImage(math.floor(currentX), math.floor(currentY), imageSize, imageSize, "files/images/pagination.png", 0, 0, 0, i == currentPage and BACKGROUND_WHITE or BACKGROUND_DARK)
        currentX = currentX + imageSize + ICON_MARGIN_SMALL
    end
end

function structureRooms()
    if #rooms == 0 then return end

    local page = roomChunks[currentPage]
    local totalWidth = #page * (ROOM_WIDTH + ROOM_OFFSET) - ROOM_OFFSET
    local startX = screenX / 2 - totalWidth / 2
    local startY = screenY / 2
    local currentX = math.floor(startX)
    local currentY = math.floor(startY)

    for _, room in ipairs(page) do
        -- mouse hover stuff
        room.active = mouseCheck(currentX, currentY - ROOM_HEIGHT / 2, ROOM_WIDTH, ROOM_HEIGHT)

        -- fix stupid errors for now
        if not room.name or not room.description or not room.icon then return end

        local backgroundColor = room.active and tocolor(backgroundColorR, backgroundColorG, backgroundColorB, 217) or BACKGROUND_DARK
        local accentColor = room.active and tocolor(accentColorR, accentColorG, accentColorB, 217) or COLOR_WHITE
        local accentColorFadeOut = room.active and tocolor(255, 255, 255, fadeOutAlphaAmount) or COLOR_WHITE
        local accentColorFadeIn = room.active and tocolor(16, 16, 16, fadeInAlphaAmount) or COLOR_WHITE
        local unisonPinkFade = room.active and tocolor(255, 124, 162, fadeOutAlphaAmount) or UNISON_PINK

        -- cancel animation execution when mouse leaves
        if currentlyHovered == room.name and isAnimating and not room.active then
            isAnimating = false
            removeEventHandler("onClientRender", root, roomAnimationTransformIn)
        end

        -- reset animation variables, launch exit animation
        if currentlyHovered == room.name and not room.active and not isAnimating then
            --[[ isAnimating = true
            animTransformStartTime = getTickCount()
            animTransformEndTime = animTransformStartTime + ANIMATION_TRANSFORM_TIMING ]]
            currentlyHovered = nil
            --r, g, b = 16, 16, 16
            backgroundColorR, backgroundColorG, backgroundColorB = 16, 16, 16
            accentColorR, accentColorG, accentColorB = 255, 255, 255
            roomIconPosY = nil
            roomTitlePosY = nil
            roomArrowPosY = nil
            fadeOutAlphaAmount = 255
            fadeInAlphaAmount = 0

            --addEventHandler("onClientRender", root, roomAnimationTransformOut)
        end

        -- entry animation on hover
        if room.active and not isAnimating and currentlyHovered ~= room.name then
            isAnimating = true
            currentlyHovered = room.name
            animTransformStartTime = getTickCount()
            animTransformEndTime = animTransformStartTime + ANIMATION_TRANSFORM_TIMING

            addEventHandler("onClientRender", root, roomAnimationTransformIn)
        end

        -- room background
        dxDrawRectangle(currentX, currentY - ROOM_HEIGHT / 2, ROOM_WIDTH, ROOM_HEIGHT, backgroundColor)

        -- icon animation variables
        roomIconPosStart = currentY - ROOM_HEIGHT / 2 + ROOM_HEIGHT / 2 - dxGetFontHeight(1, FONT_ICON_LARGE) / 2
        roomIconPosEnd = currentY - ROOM_HEIGHT / 2 + ROOM_HEIGHT / 2 - dxGetFontHeight(1, FONT_ICON_LARGE) / 2 - math.floor(60 * relY)

        -- room icon
        if room.icon then
            dxDrawText(room.icon, currentX + ROOM_WIDTH / 2 - dxGetTextWidth(room.icon, 1, FONT_ICON_LARGE) / 2, room.active and roomIconPosY or roomIconPosStart, currentX + ROOM_WIDTH, currentY - ROOM_HEIGHT / 2 + ROOM_HEIGHT, UNISON_PINK, 1, FONT_ICON_LARGE)
        end

        if room.password then
            -- lock icon and text
            local lockTextWidth = dxGetTextWidth("Unlocked in 1h, 20m", 1, FONT_REGULAR)
            local lockIconWidth = dxGetTextWidth("", 1, FONT_ICON_SMALL)

            dxDrawText("", currentX + ROOM_WIDTH / 2 - lockTextWidth / 2 - lockIconWidth / 2 - ICON_MARGIN_SMALL / 2, currentY - ROOM_HEIGHT / 2 + ROOM_PADDING / 2 - 1 * relY, currentX + ROOM_WIDTH, currentY - ROOM_HEIGHT / 2 + ROOM_HEIGHT, unisonPinkFade, 1, FONT_ICON_SMALL, "left", "top", true)
            dxDrawText("Unlocked in 1h, 20m", currentX + ROOM_WIDTH / 2 - lockTextWidth / 2 + lockIconWidth / 2 + ICON_MARGIN_SMALL / 2, currentY - ROOM_HEIGHT / 2 + ROOM_PADDING / 2, currentX + ROOM_WIDTH, currentY - ROOM_HEIGHT / 2 + ROOM_HEIGHT, accentColorFadeOut, 1, FONT_REGULAR, "left", "top", true)
        else
            -- players text and icon
            local playersTextWidth = dxGetTextWidth("5 players online", 1, FONT_REGULAR)
            local playersIconWidth = dxGetTextWidth("", 1, FONT_ICON_SMALL)

            dxDrawText("", currentX + ROOM_WIDTH / 2 - playersTextWidth / 2 - playersIconWidth / 2 - ICON_MARGIN_SMALL / 2, currentY - ROOM_HEIGHT / 2 + ROOM_PADDING / 2, currentX + ROOM_WIDTH, currentY - ROOM_HEIGHT / 2 + ROOM_HEIGHT, unisonPinkFade, 1, FONT_ICON_SMALL, "left", "top", true)
            dxDrawText("5 players online", currentX + ROOM_WIDTH / 2 - playersTextWidth / 2 + playersIconWidth / 2 + ICON_MARGIN_SMALL / 2, currentY - ROOM_HEIGHT / 2 + ROOM_PADDING / 2, currentX + ROOM_WIDTH, currentY - ROOM_HEIGHT / 2 + ROOM_HEIGHT, accentColorFadeOut, 1, FONT_REGULAR, "left", "top", true)
        end

        -- show description on hover
        if room.active and room.description then
            -- line wrap for description
            local description = room.description
            local lineCount = math.ceil(dxGetTextWidth(description, 1, FONT_SMALL) / (ROOM_WIDTH - ROOM_PADDING * 2))
            local totalHeight = lineCount > DESCRIPTION_MAX_LINE_COUNT and DESCRIPTION_MAX_LINE_COUNT * dxGetFontHeight(1, FONT_SMALL) + ROOM_PADDING or lineCount * dxGetFontHeight(1, FONT_SMALL) + ROOM_PADDING
            lineCount = lineCount > DESCRIPTION_MAX_LINE_COUNT and DESCRIPTION_MAX_LINE_COUNT or lineCount

            -- title animation variables
            roomTitlePosEnd = currentY - ROOM_HEIGHT / 2 + ROOM_HEIGHT - dxGetFontHeight(1, FONT_SEMIBOLD) - ROOM_PADDING - totalHeight + 22 * relY
            -- arrow icon animation variables
            roomArrowPosEnd = currentY - ROOM_HEIGHT / 2 + ROOM_HEIGHT - dxGetFontHeight(1, FONT_SEMIBOLD) - ROOM_PADDING - totalHeight + 24 * relY

            if lineCount > 1 then
                local prevLine = ""
                local lines = {}

                for i = 1, lineCount, 1 do
                    local text = description:gsub(prevLine, "")
                    local line = ""

                    if i ~= lineCount then
                        line = textOverflow(text, 1, FONT_SMALL, ROOM_WIDTH - ROOM_PADDING * 2)
                        line = line:gsub("(.*)%s.*$", "%1") ~= line and line:gsub("(.*)%s.*$", "%1").." " or line
                    else
                        line = textOverflow(text, 1, FONT_SMALL, ROOM_WIDTH - ROOM_PADDING * 2, true)
                    end

                    table.insert(lines, line)
                    prevLine = prevLine..line
                end

                description = table.concat(lines, "\n")
            else
                description = textOverflow(description, 1, FONT_SMALL, ROOM_WIDTH - (ROOM_PADDING * 2), true)
            end

            dxDrawText(description, currentX + ROOM_PADDING - 1 * relY, currentY - ROOM_HEIGHT / 2 + ROOM_HEIGHT - totalHeight - ROOM_PADDING + ROOM_PADDING / 2 + 16 * relY, currentX + ROOM_WIDTH - ROOM_PADDING * 2 - 1 * relY, currentY - ROOM_HEIGHT / 2 + ROOM_HEIGHT, accentColorFadeIn, 1, FONT_SMALL)
        end

        -- room title
        roomTitlePosStart = currentY - ROOM_HEIGHT / 2 + ROOM_HEIGHT - dxGetFontHeight(1, FONT_SEMIBOLD) - ROOM_PADDING + 6 * relY
        dxDrawText(textOverflow(room.name, 1, FONT_SEMIBOLD, ROOM_WIDTH - dxGetTextWidth("", 1, FONT_ICON_REGULAR), true, ROOM_PADDING * 2.5), currentX + ROOM_PADDING - 1 * relY, room.active and roomTitlePosY or roomTitlePosStart, currentX + ROOM_WIDTH, currentY - ROOM_HEIGHT / 2 + ROOM_HEIGHT, accentColor, 1, FONT_SEMIBOLD)

        -- arrow icon
        roomArrowPosStart = currentY - ROOM_HEIGHT / 2 + ROOM_HEIGHT - dxGetFontHeight(1, FONT_SEMIBOLD) - ROOM_PADDING + 8 * relY
        dxDrawText("", currentX + ROOM_WIDTH - dxGetTextWidth("", 1, FONT_ICON_REGULAR) - ROOM_PADDING, room.active and roomArrowPosY or roomArrowPosStart, currentX + ROOM_WIDTH, currentY - ROOM_HEIGHT / 2 + ROOM_HEIGHT, accentColor, 1, FONT_ICON_REGULAR)

        currentX = currentX + ROOM_WIDTH + ROOM_OFFSET
    end
end

function roomAnimationTransformIn()
    local now = getTickCount()
    local elapsedTime = now - animTransformStartTime
    local duration = animTransformEndTime - animTransformStartTime
    local progress = elapsedTime / duration
    local s1, s2, s3 = 16, 16, 16
    local e1, e2, e3 = 255, 255, 255

    -- TODO: add checks for no icon, no desc,

    -- transform
    roomIconPosY = interpolateBetween(roomIconPosStart, 0, 0, roomIconPosEnd, 0, 0, progress, ANIMATION_EASING_TYPE)
    roomTitlePosY = interpolateBetween(roomTitlePosStart, 0, 0, roomTitlePosEnd, 0, 0, progress, ANIMATION_EASING_TYPE)
    roomArrowPosY = interpolateBetween(roomArrowPosStart, 0, 0, roomArrowPosEnd, 0, 0, progress, ANIMATION_EASING_TYPE)

    -- fade
    backgroundColorR, backgroundColorG, backgroundColorB = interpolateBetween(s1, s2, s3, e1, e2, e3, progress, ANIMATION_EASING_TYPE)
    accentColorR, accentColorG, accentColorB = interpolateBetween(e1, e2, e3, s1, s2, s3, progress, ANIMATION_EASING_TYPE)
    fadeOutAlphaAmount = interpolateBetween(255, 0, 0, 0, 0, 0, progress, ANIMATION_EASING_TYPE)
    fadeInAlphaAmount = interpolateBetween(0, 0, 0, 255, 0, 0, progress, ANIMATION_EASING_TYPE)

    if progress >= 1 then
        removeEventHandler("onClientRender", root, roomAnimationTransformIn)
        isAnimating = false
    end
end

function roomAnimationTransformOut()
    local now = getTickCount()
    local elapsedTime = now - animTransformStartTime
    local duration = animTransformEndTime - animTransformStartTime
    local progress = elapsedTime / duration
    local s1, s2, s3 = 255, 255, 255
    local e1, e2, e3 = 16, 16, 16

    --if not isAnimating then return end

    --r, g, b = interpolateBetween(s1, s2, s3, e1, e2, e3, progress, "Linear")
    --roomIconPosY = interpolateBetween(roomIconPosEnd, 0, 0, roomIconPosStart, 0, 0, progress, ANIMATION_EASING_TYPE)

    if progress >= 1 then
        isAnimating = false
        removeEventHandler("onClientRender", root, roomAnimationTransformOut)
    end
end

function roomHoverIn(room)
end

function roomHoverOut()
end

-- client mouse click
function keyHandler(key, press)
    if not press then return end

    if key == "mouse1" then
        if not isCursorShowing() then return end

        local imageSize = math.floor(10 * relY)
        local totalWidth = #roomChunks * (imageSize + ICON_MARGIN_SMALL) - ICON_MARGIN_SMALL
        local startX = screenX / 2 - totalWidth / 2
        local startY = screenY / 2 + ROOM_HEIGHT / 2 + ROOM_OFFSET

        -- bigger click area
        local currentX = startX - ICON_MARGIN_SMALL * 2
        local currentY = startY - ROOM_OFFSET / 2

        -- pagination circles
        for i = 1, #roomChunks, 1 do
            if mouseCheck(currentX, currentY, imageSize + ICON_MARGIN_SMALL * 2, imageSize + ROOM_HEIGHT / 2) then
                currentPage = i
            end

            currentX = currentX + imageSize + ICON_MARGIN_SMALL * 2
        end

        for _, room in ipairs(rooms) do
            if room.active then
                showCursor(false)
                removeEventHandler("onClientRender", root, render)
                triggerServerEvent("onPlayerRequestRoomJoin", root, room.element)
            end
        end
    end
end

function mouseCheck(posX, posY, width, height)
    if not isCursorShowing() then return false end

    local mouseX, mouseY = getCursorPosition()
    mouseX = mouseX * screenX
    mouseY = mouseY * screenY

    if mouseX < posX or mouseX > posX + width then return false end
    if mouseY < posY or mouseY > posY + height then return false end

    return true
end

function textFit(text, size, font, width, padding)
    local fontSize = size
    padding = padding or 10
    width = width - padding

    while dxGetTextWidth(text, fontSize, font, true) > width do
        fontSize = fontSize - 0.1
    end

    return fontSize
end

function textOverflow(text, size, font, width, ellipsis, padding)
    local ellipsis = ellipsis or false
    local padding = padding or 0

    while dxGetTextWidth(text, size, font, true) > width - padding do
        if ellipsis then
            text = text:sub(1, text:len()-4).."..."
        else
            text = text:sub(1, text:len()-1)
        end
    end

    return text
end

function math.round(n)
    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end

function table.slice(tbl, first, last, step)
    local sliced = {}

    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced + 1] = tbl[i]
    end

    return sliced
end