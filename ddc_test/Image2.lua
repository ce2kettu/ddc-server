DxImage2 = inherit(DxElement)

function DxImage2:constructor(x, y, width, height, image)
	self.type = "dx-image"
	self.texture = image

	if (type(self.texture) == "string") then
		self.texture = dxCreateTexture(image)
	end

	if (not isElement(self.texture)) then
		self:destroy()
		return error("[DxImage] Texture creation failed (constructor)")
    end
end

function DxImage2:dxDraw(x, y)
    x, y = x or self.x, y or self.y
	dxDrawImage(x, y, self.width, self.height, self.texture)
end
