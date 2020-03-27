Singleton = {}

function Singleton:new(...)
	if (self.instance) then
		return self.instance
	end
	
	local newInstance = new(self, ...)
	
	self.instance = newInstance
	
	return newInstance
end

function Singleton:virtual_destructor()
	for _, v in pairs(super(self)) do
		if (type(v) == "table") then
			v.instance = nil
			v.new = Singleton.new
		end
	end
	
	self.instance = nil
end

function Singleton:i(...)
	return self:new(...)
end