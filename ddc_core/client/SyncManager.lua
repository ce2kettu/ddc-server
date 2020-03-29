SyncManager = inherit(Singleton)
preInitializeClass("SyncManager")

function SyncManager:constructor()
	self.elementSyncFields = {}
	
	addEvent("onClientReceiveElementSync", true)	
	addEvent("onClientReceiveInitialElementSync", true)	
	
	addEventHandler("onClientReceiveElementSync", resourceRoot, bind(self.onClientReceiveElementSync, self))
	addEventHandler("onClientReceiveInitialElementSync", resourceRoot, bind(self.onClientReceiveInitialElementSync, self))
end

function SyncManager:destructor()
	for elementType, fields in pairs(self.elementSyncFields) do
		for _, element in ipairs(Element.getAllByType(elementType)) do
			for field in ipairs(fields) do
				element:setData(field, false, false)
			end
		end
	end
end

function SyncManager:setData(element, field, value, shouldSync)
	-- invalid arguments provided
	if (not checkArguments("us", element, field) or not isElement(element)) then
		return false
	end
	
	-- Check if value has changed - makes no sense to sync otherwise (?)
	if (not setElementData(element, field, (value or false), false)) then
		return false
	end
	
	if (shouldSync) then
		triggerServerEvent("onServerReceiveClientElementSync", resourceRoot, element, field, value or false)
	end
end

function SyncManager:onClientReceiveInitialElementSync(tblSyncFields)
	if (not checkArguments("t", fields)) then
		return
	end
	
	-- set all element datas
	for element, fields in pairs(tblSyncFields) do
		if (element and isElement(element)) then
			for field, value in pairs(fields) do
				self:setData(element, field, value, false)
			end
		end
	end
end

function SyncManager:onClientReceiveElementSync(element, field, value)	
	-- data sent from the server is invalid (element might've been destroyed)
	if (not checkArguments("us", element, field) or not isElement(element)) then
		outputDebug("warning", "Bad argument @ SyncManager.onClientReceiveElementSync(%s, %s)", type(element), type(field))		
		return
	end
	
	local elementType = element:getType()
	
	if (not self.elementSyncFields[elementType]) then
		self.elementSyncFields[elementType] = {}
	end
	
	if (not table.find(self.elementSyncFields, field)) then
		table.insert(self.elementSyncFields, field)
	end
	
	element:setData(field, value, false)
end