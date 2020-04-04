DxNotificationProvider = {}

local queue = {}
local notifications = {}
local prevTick = getTickCount()
local MAX_NOTIFICATIONS_AT_ONCE = 3
local REL_SIZE = SCREEN_HEIGHT / 1080
local function REL(a) return math.floor(a * REL_SIZE) end
local START_Y = REL(16)
local NOTIFICATIONS_MARGIN = REL(16)
local NOTIFICATION_MARGIN_TOP = REL(10)
local ANIMATION_DURATION = 300

-- Adds a new notification to the queue to be presented.
function DxNotificationProvider:enqueueNotification(notification)
    notification._open = true
    notification._entered = false
    notification._requestClose = false
    notification._isClosing = false
    notification._isHandled = false
    table.insert(queue, notification)
    self:handleDisplayNotification()
end

-- Display notification if there's space for it. Otherwise, immediately
-- begin dismissing the oldest notification to start showing the new one.
function DxNotificationProvider:handleDisplayNotification()
    if (#notifications >= MAX_NOTIFICATIONS_AT_ONCE) then
        return self:handleDismissOldest()
    end

    self:processQueue()
end

-- Display items (notifications) in the queue if there's space for them.
function DxNotificationProvider:processQueue()
    if (#queue > 0) then
        table.insert(notifications, queue[1])
        table.remove(queue, 1)
    end
end

-- Hide oldest notifications on the screen because there exists a new one which we have to display.
function DxNotificationProvider:handleDismissOldest()
    --  If there is already a message leaving the screen, no new messages are dismissed.
    if (self:isAnyItemLeaving()) then
        return
    end

    local popped = false

    for _, item in ipairs(notifications) do
        if (not popped) then
            popped = true

            if (not item._entered) then
                item._requestClose = true
                break
            end

            item._open = false
        end
    end
end

-- Set the entered state of the notification with the object.
function DxNotificationProvider:handleEnteredNotification(item)
    item._entered = true
    item._isHandled = true
end

-- When we set open attribute of a notification to false (i.e. after we hide a notification),
-- it leaves the screen and immediately after leaving animation is done, this method
-- gets called. We remove the hidden notification from state and then display notifications
-- waiting in the queue (if any). If after this process the queue is not empty, the
-- oldest message is dismissed.
function DxNotificationProvider:handleExitedNotification(notification)
    self:removeNotification(notification)
    self:processQueue()

    if (#queue > 0) then
        return self:handleDismissOldest()
    end
end

-- Hide a snackbar after its timeout.
function DxNotificationProvider:handleCloseNotification(notification)
    if (notification._entered) then
        notification._open = false
    else
        notification._requestClose = true
    end

    for i, item in ipairs(queue) do
        if (item == notification) then
            table.remove(queue, i)
        end
    end
end

-- Returns whether any notification is leaving the screen
function DxNotificationProvider:isAnyItemLeaving()
    for _, item in ipairs(notifications) do
        if (not item._open or item._requestClose) then
            return true
        end
    end

    return false
end

-- Removes an item from the notification table.
function DxNotificationProvider:removeNotification(notification)
    for i, item in ipairs(notifications) do
        if (item == notification) then
            table.remove(notifications, i)
            delete(item)
            return true
        end
    end

    return false
end

local function renderNotifications()
    local currentY = NOTIFICATIONS_MARGIN
    local newTime = getTickCount()
    local deltaTime = newTime - prevTick
    local len = #notifications

    -- render notifications from the most recent one to oldest
    for i = len, 1, -1 do
        local item = notifications[i]

        -- animate position change in stack
        if (item._stackPos and i ~= item._stackPos or item._oldSize ~= len) then
            local moveX = (item._isClosing) and (SCREEN_WIDTH + NOTIFICATIONS_MARGIN) or (SCREEN_WIDTH - item.width - NOTIFICATIONS_MARGIN)
            item:moveTo(moveX, currentY, ANIMATION_DURATION, "OutQuad")
        end

        -- open notification
        if (not item._isHandled) then
            DxNotificationProvider:handleEnteredNotification(item)
            item.y = currentY
            item.x = SCREEN_WIDTH + NOTIFICATIONS_MARGIN
            item:moveTo(SCREEN_WIDTH - item.width - NOTIFICATIONS_MARGIN, currentY, ANIMATION_DURATION, "OutQuad")
        end

        item._duration = item._duration - deltaTime

        -- close notification
        if ((item._duration <= 0 or item._requestClose) and not item._isClosing or (not item._open and not item._isClosing)) then
            DxNotificationProvider:handleCloseNotification(item)
            item._isClosing = true
            item:moveTo(SCREEN_WIDTH + NOTIFICATIONS_MARGIN, currentY, ANIMATION_DURATION, "OutQuad")

            setTimer(function()
                DxNotificationProvider:handleExitedNotification(item)
            end, ANIMATION_DURATION, 1)
        end

        item:customRenderer()
        item._stackPos = i
        item._oldSize = len
        currentY = currentY + item.height + NOTIFICATION_MARGIN_TOP
    end

    prevTick = newTime
end
addEventHandler("onClientRender", root, renderNotifications)

function DxNotificationProvider:destroy()
    removeEventHandler("onClientRender", root, renderNotifications)
end