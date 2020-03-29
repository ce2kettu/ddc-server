-- Helper function to log and revert changes
local function reportAndRevertDataChange(dataName, oldValue, source, client)
    -- Report
    outputConsole("Possible rouge client!"
        .. " client:" .. tostring(client:getName())
        .. " dataName:" .. tostring(dataName)
        .. " oldValue:" .. tostring(oldValue)
        .. " newValue:" .. tostring(source:getData(dataName))
        .. " source:" .. tostring(source))
    
    -- revert
    source:setData(dataName, oldValue)               
end

local function onElementDataChange(dataName, oldValue)
    -- check data is coming from a client
    if (client) then
        outputChatBox("here :)")
        if (client ~= source) then
            -- illegal activity here, so log and revert the change
            reportAndRevertDataChange(dataName, oldValue, source, client)
        end
    end
end
addEventHandler("onElementDataChange", root, onElementDataChange)


addEvent("onPlayerCheat", true)
addEventHandler("onPlayerCheat", root, function(cheatCode, args)
    outputChatBox("Cheat code #" .. cheatCode .. " triggered:")

	for index, value in pairs(args) do
		outputChatBox(index .. " = " .. value)
	end
end)