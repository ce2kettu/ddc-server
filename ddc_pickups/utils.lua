function table.find(tbl, value)
    if (not tbl or type(tbl) ~= "table" or value == nil) then
        return false
    end

    for index, _value in pairs(tbl) do
        if (_value == value) then
            return index
        end
    end

    return false
end