DxNotificationProvider = {}

local queue = {}
local notifications = {}
local prevTick = getTickCount()
local MAX_NOTIFICATIONS_AT_ONCE = 3
local REL_SIZE = math.floor(SCREEN_HEIGHT / 1080)
local START_Y = REL_SIZE * 16
local NOTIFICATION_MARGIN_TOP = REL_SIZE * 10
local ANIMATION_DURATION = 300

-- Adds a new notification to the queue to be presented.
function DxNotificationProvider:enqueueNotification(notification)
    --local notification = DxNotifications[#DxNotifications]
    --outputChatBox(notification._description)
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
        table.remove(queue, #queue)
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
                return
            end

            item._open = false
            break
        end
    end
end

-- Set the entered state of the notification with the object.
function DxNotificationProvider:handleEnteredNotification(item)
    item._entered = true
end

function DxNotificationProvider:handleExitedNotification(item)
    self:removeNotification(item)
    self:processQueue()

    if (#queue > 0) then
        return self:handleDismissOldest()
    end
end

-- Hide a snackbar after its timeout.
function DxNotificationProvider:handleCloseNotification(item)
    if (item._entered) then
        item._open = false
    else
        item._requestClose = true
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
    local currentY = START_Y
    local newTime = getTickCount()
    local deltaTime = newTime - prevTick

    for i = #notifications, 1, -1 do
        local item = notifications[i]

        if (not item._entered and not item._requestClose) then
            DxNotificationProvider:handleEnteredNotification(item)
            item.x = SCREEN_WIDTH + 16
            item:moveTo(SCREEN_WIDTH - item.width - 16, item.y, ANIMATION_DURATION, "OutQuad")
            item._open = true
        end

        item._duration = item._duration - deltaTime

        if ((item._duration <= 0 or item._requestClose) and not item._isClosing or not item._open) then
            DxNotificationProvider:handleCloseNotification(item)
            item._requestClose = true
            item._isClosing = true
            item._open = false
            item:moveTo(SCREEN_WIDTH + 16, item.y, ANIMATION_DURATION, "OutQuad")

            setTimer(function()
                DxNotificationProvider:handleExitedNotification(item)
            end, ANIMATION_DURATION, 1)
        end

        item.y = currentY
        item:dxDraw()
        currentY = currentY + item.height + NOTIFICATION_MARGIN_TOP
    end

    prevTick = newTime
end

addEventHandler("onClientRender", root, renderNotifications)