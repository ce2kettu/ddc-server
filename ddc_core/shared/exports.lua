local availableDebugLevels = {
    ["debug"] = {81, 210, 252},
    ["info"] = {94, 250, 62},
    ["warning"] = {255, 167, 43},
    ["error"] = {255, 78, 43},
    ["fatal"] = {255, 0, 0}
}

function outputDebug(debugLevel, message, ...)
	-- no available debug level provided
	if (not debugLevel or not availableDebugLevels[debugLevel]) then
		return
	end
	
	-- format the message when there's an argument
	if (#{...} >= 1) then
		message = message:format(...)
	end
	
	-- suffix type
	message = (g_isServer and "[S]" or "[C]") .. ' ' .. message
	
	outputDebugString(message, 0, unpack(availableDebugLevels[debugLevel]))
end

function getServerInfo()
	return {
		name = g_strServerName,
		isDev = g_isDevelopmentMode,
		downloadUrl = g_downloadUrl,
		version = g_strServerVersion,
		color = g_strServerColor
	}
end

function setData(element, ...)	
	return SyncManager:i():setData(element, ...)
end

function getPlayerById(id)
	return PlayerManager:getPlayerById(id)
end