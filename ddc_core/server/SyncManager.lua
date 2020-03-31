SyncManager = inherit(Singleton)
preInitializeClass("SyncManager")

function SyncManager:constructor()
    self.storedElementData = {}
    self.allowedClientSyncFields = {
        player = { "mapDownloading", "cameraTarget" },
    }

    -- these fields are only sent to the player whos value been changed
    self.playerSyncFields = {
        -- field1, field2, field3, ...
    }

    -- these fields are synced to all players
    self.globalSyncFields = {
        player = { "id", "state" },
        room = { "name", "description", "icon", "gamemode" }
    }

    addEvent("onServerReceiveClientElementSync", true)
    addEventHandler("onServerReceiveClientElementSync", resourceRoot, bind(self.onServerReceiveClientElementSync, self))
end

function SyncManager:setData(element, field, value, shouldSync)
    -- invalid arguments provided
    if (not checkArguments("us", element, field) or not isElement(element)) then
        return false
    end

    if (not setElementData(element, field, value, false)) then
        -- error is thrown by mta itself. we return here because the value hasnt changed
        return false
    end

    if (shouldSync) then
        if (not self.storedElementData[element]) then
            self.storedElementData[element] = {}

            addEventHandler("onElementDestroy", element, bind(self.onElementDestroy, self))
        end

        self.storedElementData[element][field] = value

        -- private player sync fields
        local elementType = getElementType(element)

        if (elementType == "player" and table.find(self.playerSyncFields, field)) then
            triggerClientEvent(element, "onClientReceiveElementSync", resourceRoot, element, field, (value or false))
            return
        end

        -- global sync fields
        if (self.globalSyncFields[elementType] and table.find(self.globalSyncFields[elementType], field)) then
            triggerClientEvent("onClientReceiveElementSync", resourceRoot, element, field, (value or false))
            return
        end

        -- send element to players parent which will always be a room
        local elementParent = getElementParent(element)

        -- do not send element data to EVERYONE on the server
        if (elementParent ~= root) then
            triggerClientEvent(getElementChildren(elementParent, "player"), "onClientReceiveElementSync", resourceRoot, element, field, value or false)
        end
    end
end

function SyncManager:onServerReceiveClientElementSync(element, field, value)
    -- manipulated client, invalid arguments provided or incorrect element
    if (not client or not checkArguments("us", element, field) or not isElement(element)) then
        return
    end

    -- modified client / mistake from dev
    -- NOTE: players are only allowed to sync their own fields to keep security!
    if (getElementType(element) == "player" and not table.find(self.allowedClientSyncFields.player, field)) then
        triggerEvent("onPlayerCheat", client, 2, {element = element, field = field, value = value})
        return
    end

    self:setData(element, field, value, true)
end

function SyncManager:sendInitialSyncToPlayer(player)
    local syncTable = {}
    local value	= false

    for elementType, fields in pairs(self.globalSyncFields) do
        for _, element in ipairs(getElementsByType(elementType)) do
            for _, field in ipairs(fields) do
                value = getElementData(element, field)

                if (value) then
                    if (not syncTable[element]) then
                        syncTable[element] = {}
                    end

                    syncTable[element][field] = value
                end
            end
        end
    end

    triggerClientEvent(player, "onClientReceiveInitialElementSync", resourceRoot, syncTable)
end

function SyncManager:onElementDestroy()
    if (self.storedElementData[source]) then
        self.storedElementData[source] = nil
    end
end
