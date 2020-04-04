function displayNotification(type, title, description, duration)
    if (not type or not description) then
        return false
    end

    uiCreateElement("DxNotification", type, title, description, duration)

    return true
end