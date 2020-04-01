-- *************************************************************************************** --
-- File: 		:uni\client\dxlib_utils.lua
-- Type:		Client
-- Author:		LopSided
-- *************************************************************************************** --
-- © Unison - All rights reserved
-- *************************************************************************************** --

function center2D(x, y, width, height)
	return (x) - (width / 2), (y) - (height / 2)
end

local iCurrentCursor = 2

function nextCursor()
	iCurrentCursor = iCurrentCursor + 1
	if iCurrentCursor > #DxCursor.tblCursorTypes then
		iCurrentCursor = 1
	end
	DxCursor.strCursorType = DxCursor.tblCursorTypes[iCurrentCursor]
end

function countDxObjects()
	local iCount = 0
	for i,obj in pairs(DxObjects) do
		iCount = iCount + 1
	end
	return iCount
end

function imerge(t1, t2)
	for k,v in ipairs(t2) do
		table.insert(t1, v)
	end
	return t1
end

function argvf(args, required, optional) --argument verifier & formatter for tables (args). This checks if (required) arguments are provided. This will also format the arguments into a table with the respective key (argument name) and values for required and/or optional parameters, with nil or false arguments being set to their default value (much like the way MTA's functions work).
	local tblCallerStack = debug.getinfo(2)
	if type(args) ~= "table" then 
		outputDebugString("Arguments list passed to argvf not typeof 'table' ["..tblCallerStack.short_src..":"..tblCallerStack.currentline.."]")
		return false
	elseif #args < #required then
		outputDebugString("Not enough arguments supplied to "..tblCallerStack.namewhat.." '"..tblCallerStack.name.."' ["..tblCallerStack.short_src..":"..tblCallerStack.currentline.."]")
		return false
	end
	
	local tblFormattedArgs = {}
	local tblMergedArgs = {}
	
	if optional then
		tblMergedArgs = imerge(required, optional)
	else
		tblMergedArgs = required
	end
	
	for i, vrtArg in ipairs(tblMergedArgs) do
		if args[i] then
			if type(args[i]) == vrtArg.typeof then
				tblFormattedArgs[vrtArg.name] = args[i]
			else
				tblFormattedArgs[vrtArg.name] = vrtArg.default
			end
		else
			tblFormattedArgs[vrtArg.name] = vrtArg.default
		end
	end

	return tblFormattedArgs
end
