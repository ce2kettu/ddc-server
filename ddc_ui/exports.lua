local metaFile = false
local metaNodes = false

local funcInjectCode = ""

function uiInitializeExporter()
	if (metaFile) then
		return false
	end

	funcInjectCode = [[
		local uiClass = {}
		
		uiClass.resourceName = "]]..RESOURCE_NAME..[["
		uiClass.resource = getResourceFromName(uiClass.resourceName)
		
		uiClass.elements = {}
		
		uiClass.types = ']]..toJSON(DxTypes)..[['
		uiClass.types = fromJSON(uiClass.types)
		
		uiClass.mt = {
			__index = function(obj, key)
				return function(self, ...)
					return call(uiClass.resource, "uiCallMethod", self.uid, key, ...)
				end
			end
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
			for i, element in ipairs(uiClass.elements) do
				call(uiClass.resource, "uiDestroyElement", element.uid)
			end
		end
		addEventHandler("onClientResourceStop", resourceRoot, uiClass.exit)
		
		for i, class in ipairs(uiClass.types) do		
			_G[class] = {
				new = function(self, ...)
					local element = call(uiClass.resource, "uiCreateElement", class, ...)
					
					uiClass.elements[#uiClass.elements + 1] = element
					
					setmetatable(element, uiClass.mt)
					
					return element					
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
							
							uiClass.elements[#uiClass.elements + 1] = element
							
							setmetatable(element, uiClass.mt)
							
							return element
						end 
					]]		
				end
			end
		end
	end
end

function uiLoadFunctions()
	return funcInjectCode
end