Core = inherit(Singleton)
inherit(Autoloader, Core)

function Core:constructor()
    -- TODO: implement database check

    -- initialize all classes
    self:initAllClasses()

    setFPSLimit(g_serverFPSLimit)
    setGameType(g_serverName.." "..g_serverVersion)
end

function Core:destructor()
    self:destroyAllClasses()

    -- reset all element datas (client handles these on their own)
    for _, element in ipairs(getElementChildren(root)) do
        local data = getAllElementData(element)

        if (data) then
            for field, _ in pairs(data) do
                setElementData(element, field, false, false)
            end
        end
    end
end