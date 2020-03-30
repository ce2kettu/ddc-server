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

Vector3D = {
    new = function(self, _x, _y, _z)
        local newVector = {
            x = _x or 0,
            y = _y or 0,
            z = _z or 0
        }

        return setmetatable(newVector, {__index = Vector3D})
    end,

    Length = function(self)
        return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
    end
}