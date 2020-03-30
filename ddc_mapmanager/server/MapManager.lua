local table_insert = table.insert

MapManager = {}

function MapManager:constructor()
    self.mapList = {}
    self.mapTypes = {"DM", "Shooter", "Race"}

    self:loadMapList()
end

function MapManager:loadMapList()
    local resourceList = getResources()
    local mapName, resourceName = false, false
    local mapPrefix, mapAuthor = false, false
    local startTick = getTickCount()
    local mapCounter = 0

    self.mapList = {}

    for _, resource in ipairs(resourceList) do
        if (getResourceState(resource) == "loaded" and getResourceInfo(resource, "type") == "map") then
            resourceName = getResourceName(resource)
            mapName = getResourceInfo(resource, "name") or "Unknown"
            mapPrefix = mapName:match("%[(%w+)%]")
            mapAuthor = getResourceInfo(resource, "author") or "Unknown"

            if (mapPrefix and exports.ddc_core:table_find(self.mapTypes, mapPrefix)) then
                mapCounter = mapCounter + 1

                if (not self.mapList[mapPrefix]) then
                    self.mapList[mapPrefix] = {}
                end

                table_insert(self.mapList[mapPrefix], {
                    resourceName = resourceName,
                    name = mapName,
                    author = mapAuthor
                })
            end
        end
    end

    for _, prefix in ipairs(self.mapTypes) do
        local count = self.mapList[prefix] and #self.mapList[prefix] or 0

        exports.ddc_core:outputDebug("info", "Loaded %d [%s] map%s!", count, prefix, (count == 0 or count >= 2) and "s" or "")
    end

    exports.ddc_core:outputDebug("info", "Loaded %d map%s total in %dms!", mapCounter, (mapCounter == 0 or mapCounter >= 2) and "s" or "", getTickCount() - startTick);
end

function MapManager:getMapList(mapPrefix)
    if (mapPrefix and self.mapList[mapPrefix]) then
        return self.mapList[mapPrefix]
    elseif (not mapPrefix) then
        return self.mapList
    end

    return false
end