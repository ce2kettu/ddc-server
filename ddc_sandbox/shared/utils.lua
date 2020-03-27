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