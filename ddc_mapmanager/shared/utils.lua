function new(classObj, ...)
	-- invalid table was provided
	if (not classObj or type(classObj) ~= "table") then
		return false
	end
	
	local newObj = setmetatable({}, {__index = classObj})
	
	-- call constructor
	if (newObj.constructor) then
		newObj:constructor(...)
		newObj.constructor = nil
	end
	
	return newObj
end

function delete(classObj, ...)
	-- invalid class was provided
	if (not classObj or type(classObj) ~= "table") then
		return false
	end
	
	-- call destructor
	if (classObj.destructor) then
		classObj:destructor(...)
		classObj.destructor = nil
	end
	
	-- remove metatable
	setmetatable(classObj, nil)
	
	return true
end

function getFileChecksum(fileName)
	-- invalid argument was provided or the given file does not exist
	if (type(fileName) ~= "string" or not fileExists(fileName)) then
		return false
	end
	
	local file = File(fileName)
	
	if (file) then
		local fileContent = file:read(file:getSize())
		file:close()
		
		return md5(fileContent)
	end
	
	return false
end

function bind(func, ...)
	if (not func) then
		error("Bad function pointer @ bind. See console for more details")
	end

	local boundParams = {...}
	return 
		function(...) 
			local params = {}
			local boundParamSize = select("#", unpack(boundParams))
			for i = 1, boundParamSize do
				params[i] = boundParams[i]
			end

			local funcParams = {...}
			for i = 1, select("#", ...) do
				params[boundParamSize + i] = funcParams[i]
			end
			return func(unpack(params)) 
		end 
end

function table.copy(tbl, recursive)
	local ret = {}
	
    for key, value in pairs(tbl) do
        if (type(value) == "table") and recursive then ret[key] = table.copy(value)
        else ret[key] = value end
	end
	
    return ret
end