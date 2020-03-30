function getFileChecksum(fileName)
    -- invalid argument was provided or the given file does not exist
    if (type(fileName) ~= "string" or not fileExists(fileName)) then
        return false
    end

    local file = fileCreate(fileName)

    if (file) then
        local fileContent = fileRead(file, fileGetSize(file))
        fileClose(file)

        return md5(fileContent)
    end

    return false
end

function table.copy(tbl, recursive)
    local ret = {}

    for key, value in pairs(tbl) do
        if (type(value) == "table") and recursive then ret[key] = table.copy(value)
        else ret[key] = value end
    end

    return ret
end