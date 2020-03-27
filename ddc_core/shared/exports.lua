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