function displayNotification(type, title, description, duration)
    if (not type or not description) then
        return false
    end

    DxNotification:new(type, title, description, duration)

    return true
end