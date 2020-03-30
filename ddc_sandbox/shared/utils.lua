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

function checkArguments(format, ...)
    local isValid = false

    if (type(format) == "string") then
        local arguments = {...}
        local formatToType = {
            ["s"] = "string",
            ["i"] = "number",
            ["t"] = "table",
            ["u"] = "userdata",
            ["b"] = "boolean",
            ["f"] = "function"
        }

        -- length mismatch
        if (format:len() ~= #arguments) then
            return false
        end

        -- validate all arguments
        for i = 1, format:len() do
            isValid = type(arguments[i]) == formatToType[format:sub(i, i)]

            -- return when one mismatch occurs
            if (not isValid) then
                return isValid
            end
        end
    end

    return isValid
end