local metaFile = false
local metaNodes = false

local funcInjectCode = ""

function uiInitializeExporter()
    if (funcInjectCode ~= "") then
        return false
    end

    funcInjectCode = [[
        uiClass = {}

        uiClass.resourceName = "]]..RESOURCE_NAME..[["
        uiClass.resource = getResourceFromName(uiClass.resourceName)

        uiClass.elements = {}

        uiClass.types = ']]..toJSON(DxTypes)..[['
        uiClass.types = fromJSON(uiClass.types)

        uiClass.mt = {
            __index = function(obj, key)
                return call(uiClass.resource, "uiGetProperty", obj.uid, key)
            end,
            __newindex = function(obj, key, value)
                return call(uiClass.resource, "uiSetProperty", obj.uid, key, value)
            end,
            __metatable = true
        }

        uiClass.init = function()
            local resource = getResourceFromName(uiClass.resourceName)

            if (not resource) then
                return
            end

            uiClass.resource = resource
        end
        addEventHandler("onClientResourceStart", root, uiClass.init)

        uiClass.exit = function()
            if (getResourceFromName(uiClass.resourceName)) then
                for _, element in ipairs(uiClass.elements) do
                    call(uiClass.resource, "uiDestroyElement", element.uid)
                end
            end
        end
        addEventHandler("onClientResourceStop", resourceRoot, uiClass.exit)

        for _, class in ipairs(uiClass.types) do
            _G[class] = {
                new = function(self, ...)
                    local element = call(uiClass.resource, "uiCreateElement", class, ...)
                    local returnElement = { uid = element.uid, type = element.type }

                    uiClass.elements[#uiClass.elements + 1] = returnElement

                    setmetatable(returnElement, uiClass.mt)

                    return returnElement
                end
            }
        end
    ]]

    metaFile = xmlLoadFile("meta.xml")
    metaNodes = xmlNodeGetChildren(metaFile)

    for i, node in ipairs(metaNodes) do
        if (xmlNodeGetName(node) == "export") then
            local funcName = xmlNodeGetAttribute(node, "function")
            local typeof = xmlNodeGetAttribute(node, "type")
            local metatable = string.find(funcName, "Create") or false

            if (typeof == "client" or typeof == "shared") then
                if (not metatable) then
                    funcInjectCode = funcInjectCode..[[
                        function ]]..funcName..[[(...)
                            return exports.]]..RESOURCE_NAME..":"..funcName..[[(...)
                        end
                    ]]
                else
                    funcInjectCode = funcInjectCode..[[
                        function ]]..funcName..[[(...)
                            local element = exports.]]..RESOURCE_NAME..":"..funcName..[[(...)
                            local returnElement = { uid = element.uid, type = element.type }

                            uiClass.elements[#uiClass.elements + 1] = returnElement

                            setmetatable(returnElement, uiClass.mt)

                            return returnElement
                        end
                    ]]
                end
            end
        end
    end

    xmlUnloadFile(metaFile)
end

function uiLoadLibrary()
    return funcInjectCode
end