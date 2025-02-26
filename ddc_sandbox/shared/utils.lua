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