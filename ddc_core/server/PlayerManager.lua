PlayerManager = inherit(Singleton)
preInitializeClass("PlayerManager")

function PlayerManager:constructor()
    self.idList = {}

    self:addEvents()
end

function PlayerManager:onPlayerJoin()
    local r, g, b = unpack(g_serverColor.rgb)

    outputChatBox((" * #FFFFFF%s %shas joined the game."):format(getPlayerName(source), g_serverColor.hex), root, r, g, b, true)

    self:assgnId(source)
end

function PlayerManager:onPlayerQuit(quitType, kickOrBanReason, responsibleElement)
    local r, g, b = unpack(g_serverColor.rgb)

    outputChatBox((" * #FFFFFF%s %shas left the game (%s)."):format(getPlayerName(source), g_serverColor.hex, quitType), root, r, g, b, true)

    local id = getElementData(source, "id")

    -- free id
    if (id and self.idList[source]) then
        self.idList[source] = nil
    end
end

function PlayerManager:onPlayerChangeNick(oldNick, newNick)
    local r, g, b = unpack(g_serverColor.rgb)

    outputChatBox((" * #FFFFFF%s %sis now known as %s#FFFFFF."):format(oldNick, g_serverColor.hex, newNick), root, r, g, b, true)
end

function PlayerManager:assgnId(player)
    local id = self:getFreeId()

    setData(player, "id", id, true)
    self.idList[id] = player
end

function PlayerManager:getFreeId()
    local list = self.idList

    for i, player in ipairs(list) do
        if (not isElement(player)) then
            return i
        end
    end

    return #list + 1
end

function PlayerManager:getPlayerById(id)
    if (not checkArguments("i", id)) then
        outputDebug("warning", "Bad argument @ PlayerManager.getPlayerById(%s)", type(id))
        return false
    end

    local player = self.idList[id]

    return (player or false)
end

-- Called once the client-sided core resource is loaded
function PlayerManager:onPlayerCoreResourceStarted()
    if (not client) then
        return
    end

    SyncManager:i():sendInitialSyncToPlayer(client)
end

function PlayerManager:addEvents()
    addEventHandler("onPlayerQuit", root, bind(self.onPlayerQuit, self))
    addEventHandler("onPlayerJoin", root, bind(self.onPlayerJoin, self))
    addEventHandler("onPlayerChangeNick", root, bind(self.onPlayerChangeNick, self))

    addEvent("onPlayerCoreResourceStarted", true)
    addEventHandler("onPlayerCoreResourceStarted", resourceRoot, bind(self.onPlayerCoreResourceStarted, self))
end