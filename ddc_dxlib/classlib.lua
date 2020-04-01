-- returns a new object instance
function new(classObj, ...)
    if (not classObj or type(classObj) ~= "table") then
        return false
    end

    local newObj = setmetatable({}, {__index = classObj, __class = classObj})

    -- call derived constructors
    local callDerivedConstructor
    callDerivedConstructor = function(self, newObj, ...)
        for _, v in pairs(self) do
            if (rawget(v, "virtual_constructor")) then
                rawget(v, "virtual_constructor")(newObj, ...)
            end

            local inherited = superMultiple(v)
            callDerivedConstructor(inherited, newObj, ...)
        end
    end

    callDerivedConstructor(superMultiple(classObj), newObj, ...)

    -- call constructor
    if (newObj.constructor) then
        newObj:constructor(...)
        newObj.constructor = false
    end

    return newObj
end

-- returns a new object instance without inheritance
function newClass(classObj, ...)
    if (not classObj or type(classObj) ~= "table") then
        return false
    end

    local newObj = setmetatable({}, {__index = classObj})

    -- call constructor
    if (newObj.constructor) then
        newObj:constructor(...)
        newObj.constructor = false
    end

    return newObj
end

-- deletes an object instance
function delete(obj, ...)
    -- invalid class was provided
    if (not obj or type(obj) ~= "table") then
        return false
    end

    -- call destructor
    if (obj.destructor) then
        obj:destructor(...)
        obj.destructor = false
    end

    -- call derived destructors
    local callDerivedDestructor
    callDerivedDestructor = function(parentClasses, obj, ...)
        for _, v in pairs(parentClasses) do
            if (rawget(v, "virtual_destructor")) then
                rawget(v, "virtual_destructor")(obj, ...)
            end

            local inherited = superMultiple(v)
            callDerivedDestructor(inherited, obj, ...)
        end
    end

    callDerivedDestructor(superMultiple(obj), obj, ...)

    -- remove existing data
    if (type(obj) == "table") then
        for index, _ in pairs(obj) do
            obj[index] = nil
        end
    end

    -- remove metatable
    setmetatable(obj, nil)
end

-- deletes an object instance without inheritance
function deleteClass(obj, ...)
    -- invalid class was provided
    if (not obj or type(obj) ~= "table") then
        return false
    end

    -- remove existing data
    if (type(obj) == "table") then
        for index, _ in pairs(obj) do
            obj[index] = nil
        end
    end

    -- remove metatable
    setmetatable(obj, nil)
end

-- returns possible inherited classes
function superMultiple(obj)
    local metatable = getmetatable(obj)

    if (not metatable) then
        return {}
    end

    -- class object
    if (metatable.__class) then
        return superMultiple(metatable.__class)
    end

    -- class
    if (metatable.__super) then
        return metatable.__super or {}
    end
end

-- returns base class
function super(obj)
    return superMultiple(obj)[1]
end

-- returns a new inherited object
function inherit(fromObj, toObj)
    if (not fromObj or type(fromObj) ~= "table") then
        return false
    end

    -- inherit from a single object with no derived classes
    if (not toObj) then
        return setmetatable({}, {__index = _inheritIndex, __super = {fromObj}})
    end

    -- inherit from a class with derived classes
    local metatable = getmetatable(toObj) or {}
    local oldSuper = metatable and metatable.__super or {}
    table.insert(oldSuper, 1, fromObj)
    metatable.__super = oldSuper
    metatable.__index = _inheritIndex

    return setmetatable(toObj, metatable)
end

-- returns inherited indices
function _inheritIndex(obj, key)
    for k, v in pairs(superMultiple(obj)) do
        if (v[key]) then
            return v[key]
        end
    end

    return nil
end

-- binds a function to a class instance
function bind(func, ...)
    if (not func) then
        return false
    end

    local boundParams = {...}
    return (
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
    )
end