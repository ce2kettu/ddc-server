DxElement = inherit(DxAnimator)

local function onClientRender()
    for k, v in ipairs(DxElements) do
        --v:dxDraw()
        --v:render()
        if (v.visible) then
            v:dxDraw()
           --v:isVisible()
        end
    end
end
addEventHandler("onClientRender", root, onClientRender)

local function onClientClick(...)
    for k, v in pairs(DxElements) do
        if (v.listenForClicks) then
            v:click(...)
        end
    end
end
addEventHandler("onClientClick", root, onClientClick)

-- local function onClientCursorMove(...)
--     for k, v in pairs(DxElements) do
--         v:cursorMove(...)
--     end
-- end
-- addEventHandler("onClientCursorMove", root, onClientCursorMove)

-- DxElement = inherit(DxAnimator)

function DxElement:new(...)
    return new(self, ...)
end

function DxElement:destroy(...)
    -- delete element children
    for i = #self.children, 1, -1 do
        self.children[i]:destroy()
    end

    self:setParent(false)

    -- remove from element table
    for i, element in ipairs(DxElements) do
        if (element == self) then
            table.remove(DxElements, i)
        end
    end

    return delete(self, ...)
end

function DxElement:virtual_constructor(x, y, width, height)
    self.uid = randomString(6)..getTickCount()
    self.type = "dx-element"
    self.zIndex = #DxElements + 1
    self.alpha = 255
    self.visible = true
    self.parent = false
    self.children = {}
    self.isHoverEnabled = true
    self.hovering = false
    self.baseX = x
    self.baseY = y
    self.previousBaseX = x
    self.previousBaseY = y
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.previousWidth = width
    self.previousHeight = height

    self.listenForClicks = false
    self.isObstructable = true
    self.drawBounds = true

    self.color = tocolor(255, 255, 255, 255)
    self.hoverColor = tocolor(0, 0, 0, 255)

    self.renderFunctions = {
        normal = {},
        preRender = {}
    }

    self.clickFunctions = {}

    self.bounds = {
        min = {
            x = 0,
            y = 0
        },
        max = {
            x = 0,
            y = 0
        }
    }

    self.canvas = {
        state = false
    }

    self.mask = {
        state = false,
        shader = false,
        texture = false
    }

    self:addRenderFunction(self.draw)
    -- self:addRenderFunction(self.updateShaderTexture)
    -- self:addRenderFunction(self.updateCachedTextures)
    -- self:addRenderFunction(self.drawCanvas)
    -- self:addRenderFunction(self.drawBounds)
    -- self:addRenderFunction(self.updatePreviousDimensions)

    DxElements[self.zIndex] = self

    -- bring newly created element to front
    --self:bringToFront()

    return DxElements[self.zIndex]
end

function DxElement:render()
    --dxDrawImage(self.x, self.y, self.width, self.height, texture)
    --self:dxDraw()
    for i, func in ipairs(self.renderFunctions.normal) do
        func()
    end
end

function DxElement:draw(allow)
    -- local isRootElement = self:isRootElement()

    -- if (self:isRootElement() and not self:isVisible()) then
    -- 	return false
    -- end

    if (self.visible) then
        self:dxDraw()
    end
    -- if (not self:isCanvasEnabled()) then
    -- 	if (self:hasParent() and not allow) then
    -- 		return false
    -- 	end

    -- 	if (self:inCanvas()) then
    -- 		return false
    -- 	end

    -- 	if (self:isVisible()) then
    -- 		if (self:isMaskEnabled()) then
    -- 			self:drawMask()
    -- 		else
    -- 			self:dxDraw()
    -- 		end

    -- 		for i=#self.children,1,-1 do
    -- 			local child = self.children[i]
    -- 			child:draw(true)
    -- 		end
    -- 	end
    -- else
    -- 	if (isRootElement) then
    -- 		if (not self:inCanvas()) then
    -- 			if (self:isVisible()) then
    -- 				if (self:isMaskEnabled()) then
    -- 					self:drawMask()
    -- 				else
    -- 					self:dxDraw()
    -- 				end
    -- 			end

    --             self:generateCanvas()
    -- 		end
    -- 	end
    -- end
end

function DxElement:click(button, state, x, y)
    if (state == "up") then
        for i, func in ipairs(self.clickFunctions) do
            func(button, state, x, y)
        end
    end

    if (button == "left" and state == "up") then
        -- if (DxInfo.draggingElement == self) then
        -- 	DxInfo.draggingElement = false
        -- end
        -- self.dragging = false
        -- self.dragInitialX, self.dragInitialY = false, false
    end

    if (not self:isMouseOverElement()) then
        return false
    end

    if (self:isObstructed(x, y)) then
        return false
    end

    -- if (button == "left" and state == "down") then
    -- 	if (self:getProperty("click_ordering")) then
    -- 		self:bringToFront()
    -- 	end
    -- 	if (self:hasParent()) then
    -- 		if (self.parent:getProperty("child_dragging")) then
    -- 			if (self:getProperty("allow_drag_x") or self:getProperty("allow_drag_y")) then
    -- 				if (isCursorInBounds(self.x + self.dragArea.x, self.y + self.dragArea.y, self.dragArea.width, self.dragArea.height)) then
    -- 					self.dragging = true
    -- 					DxInfo.draggingElement = self
    -- 				end
    -- 			end
    -- 		end
    -- 	else
    -- 		if (self:getProperty("allow_drag_x") or self:getProperty("allow_drag_y")) then
    -- 			if (isCursorInBounds(self.x + self.dragArea.x, self.y + self.dragArea.y, self.dragArea.width, self.dragArea.height)) then
    -- 				self.dragging = true
    -- 				DxInfo.draggingElement = self
    -- 			end
    -- 		end
    -- 	end
    -- end

    for i, func in ipairs(self.clickFunctions) do
        func(button, state, x, y)
    end
end

function DxElement:drawInternal(children)
    for i = #children, 1, -1 do
        local child = children[i]
        local x, y = child.baseX, child.baseY

        if (child.parent ~= self) then
            x, y = child:getInheritedBasePosition()
        end

        if (child:isVisible()) then
            if (child:isMaskEnabled()) then
                child:drawMask(x, y)
            else
                child:dxDraw(x, y)
            end

            self:drawInternal(child:getChildren())
        end
    end
end

function DxElement:cursorMove(relX, relY, absX, absY)
    if (not self.isHoverEnabled) then
        return false
    end

    if (self:isMouseOverElement()) then
        if (not self:isObstructed(absX, absY)) then
            if (self.hover) then
                self.color = self.hoverColor
                self.hovering = true
                return true
            end
        end
    end

    self.hovering = false
    self.color = self.primaryColor
end

function DxElement:createCanvas()
    if (not self.canvas.texture) then
        self.canvas.state = true
        self.canvas.texture = dxCreateRenderTarget(self.width, self.height, true)
        self.canvas.width, self.canvas.height = self.width, self.height
    end

    return self.canvas.texture and true or false
end

function DxElement:setCanvasState(state)
    self.canvas.state = state
end

function DxElement:getCanvas()
    return self.canvas.texture or false
end

function DxElement:isCanvasEnabled()
    return self.canvas.state
end

function DxElement:inCanvas(parent)
    local parent = parent or self:getParent()

    if (parent) then
        if (parent:isCanvasEnabled()) then
            return true
        else
            if (parent:hasParent()) then
                return self:inCanvas(parent:getParent())
            end
        end
    end

    return false
end

function DxElement:getInheritedBounds()
    local bounds = {
        min = {
            x = 0,
            y = 0
        },
        max = {
            x = self.width,
            y = self.height
        }
    }

    if (not self:isCanvasEnabled()) then
        for i,element in ipairs(self:getInheritedChildren()) do
            local x, y = element.x - self.x, element.y - self.y

            if (x < bounds.min.x) then
                bounds.min.x = x
            end

            if (y < bounds.min.y) then
                bounds.min.y = y
            end

            if ((x + element.width) > bounds.max.x) then
                bounds.max.x = (x + element.width)
            end

            if ((y + element.height) > bounds.max.y) then
                bounds.max.y = (y + element.height)
            end
        end
    end

    return bounds.min.x, bounds.min.y, bounds.max.x, bounds.max.y
end

function DxElement:getBounds(relative)
    return (not relative and self.x or 0),
        (not relative and self.y or 0),
        (not relative and self.x + self.width or self.width),
        (not relative and self.y + self.height or self.height)
end

function DxElement:updateInheritedBounds()
    local minX, minY, maxX, maxY = self:getInheritedBounds()

    self.bounds = {
        min = {
            x = minX,
            y = minY
        },
        max = {
            x = maxX,
            y = maxY
        }
    }

    return true
end

function DxElement:isMouseOverElement()
    return isCursorInBounds(self.x, self.y, self.width, self.height)
end

function DxElement:isParent(element)
    return self.parent == element
end

function DxElement:setParent(parent)
    if (not parent) then
        return false
    end

    -- element is already parent of the target element
    if (self:isParent(parent)) then
        return false
    end

    -- remove this element from the existing parent
    if (self:hasParent()) then
        for i = #self.parent.children, 1, -1 do
            if (self.parent.children[i] == self) then
                table.remove(self.parent.children, i)
                break
            end
        end
    end

    -- add new child to parent
    table.insert(parent.children, self)

    -- update parent
    self.parent = parent
    self:setIndex(1)

    return true
end

function DxElement:getParent()
    return self.parent
end

function DxElement:hasParent()
    return (self.parent and true) or false
end

function DxElement:isChild(element)
    for _, el in ipairs(self.children) do
        if (element == el) then
            return true
        end
    end

    return false
end

function DxElement:getTopLevelChildren(parent)
    parent = parent or self:getParent()

    if (not parent) then
        return self
    end

    local elements = {}

    if (not parent:hasParent()) then
        for _, child in ipairs(parent:getChildren()) do
            table.insert(elements, element)
        end

        return elements
    end

    return self:getTopLevelChildren(parent:getParent())
end


function DxElement:getRootElement()
    if (self:hasParent()) then
        return self.parent:getRootElement()
    end

    return self
end

function DxElement:isRootElement()
    if (self == self:getRootElement()) then
        return true
    end

    return false
end

function DxElement:getInheritedChildren()
    local children = {}

    for _, child in ipairs(self.children) do
        table.insert(children, child)

        for _, grandChild in ipairs(child:getInheritedChildren()) do
            table.insert(children, grandChild)
        end
    end

    return children
end

function DxElement:isInheritedChild(element)
    for _, el in pairs(self:getInheritedChildren()) do
        if (element == e) then
            return true
        end
    end

    return false
end

function DxElement:getInheritedChildrenByType(elementType)
    local children = {}

    for _, element in ipairs(self:getInheritedChildren()) do
        if (element.type == elementType) then
            table.insert(children, element)
        end
    end

    return children
end

function DxElement:getChildren()
    return self.children
end

function DxElement:getChildrenByType(elementType)
    local children = {}

    for _, element in ipairs(self:getChildren()) do
        if (element.type == elementType) then
            table.insert(children, element)
        end
    end

    return children
end

function DxElement:getType()
    return self.type
end

function DxElement:setPosition(x, y)
    x, y = tonumber(x), tonumber(y)

    self.baseX = x and x or self.baseX
    self.baseY = y and y or self.baseY

    if (not self:hasParent()) then
        self.x, self.y = self.baseX, self.baseY
    end

    return true
end

function DxElement:isPositionUpdated()
    if (self.baseX ~= self.previousBaseX) or (self.baseY ~= self.previousBaseY) then
        return true
    end

    return false
end

function DxElement:getPosition()
    return self.x, self.y
end

function DxElement:setSize(width, height)
    width, height = tonumber(width), tonumber(height)

    self.width = width and width or self.width
    self.height = height and height or self.height
end

function DxElement:getSize(width, height)
    return self.width, self.height
end

function DxElement:isSizeUpdated()
    if ((self.width ~= self.previousWidth) or (self.height ~= self.previousHeight)) then
        return true
    end

    return false
end

function DxElement:setIndex(index)
    if (type(index) ~= "number") then
        return false
    end

    local tbl = (self.parent and self.parent.children) or DxElements

    -- validate index
    if (index > #tbl) or (index < 1) then
        return false
    end

    -- update current index
    self:refreshIndex()

    local currentIndex = self:getIndex()

    table.insert(tbl, index, table.remove(tbl, currentIndex))

    -- shift the indexes of other elements
    for _, element in ipairs(DxElements) do
        if (element:isRootElement()) then
            element:refreshIndex()
            --element:refreshEventHandlers()

            local children = element:getInheritedChildren()

            for i = 1, #children do
                local child = children[i]
                child:refreshIndex()
               --child:refreshEventHandlers()
            end
        end
    end

    return true
end

function DxElement:refreshIndex()
    local tbl = (self:isRootElement() and DxElements) or self.parent.children

    for i, element in ipairs(tbl) do
        if (self == element) then
            self.zIndex = i
            return true
        end
    end

    return false
end

function DxElement:getIndex()
    return self.zIndex
end

function DxElement:getRootElements()
    local elements = {}

    for _, element in ipairs(DxElements) do
        if (element:isRootElement()) then
            table.insert(elements, element)
        end
    end

    return elements
end

function DxElement:getNonRootElements()
    local elements = {}

    for _, element in ipairs(DxElements) do
        if (not element:isRootElement()) then
            table.insert(elements, element)
        end
    end

    return elements
end

function DxElement:bringToFront()
    self:setIndex(1)

    if (self:hasParent()) then
        self.parent:bringToFront()
    end
end

function DxElement:sendToBack()
    self:setIndex(#DxElements)
end

function DxElement:isFront()
    return self.zIndex == 1
end

function DxElement:setCentered(horizontal, vertical)
    local width = (self:hasParent() and self:getParent().width) or SCREEN_WIDTH
    local height = (self:hasParent() and self:getParent().height) or SCREEN_HEIGHT

    if (horizontal) then
        local x = (width / 2) - (self.width / 2)
        self:setPosition(x)
    end

    if (vertical) then
        local y = (height / 2) - (self.height / 2)
        self:setPosition(nil, y)
    end
end

function DxElement:setVisible(bool)
    if (type(bool) ~= "boolean") then
        return false
    end

    self.visible = bool

    return true
end

function DxElement:isVisible()
    return self.visible
end

function DxElement:setAlpha(alpha)
    if (not tonumber(alpha)) then
        return false
    end

    self.alpha = tonumber(alpha)

    return true
end

function DxElement:getAlpha()
    return self.alpha
end

function DxElement:getRelativePositionFromAbsolute(x, y)
    local rootWidth, rootHeight = SCREEN_WIDTH, SCREEN_HEIGHT

    if (self:hasParent()) then
        rootWidth, rootHeight = self.parent.width, self.parent.height
    end

    return (x / rootWidth), (y / rootHeight)
end

function DxElement:getAbsolutePositionFromRelative(x, y)
    local rootWidth, rootHeight = SCREEN_WIDTH, SCREEN_HEIGHT

    if (self:hasParent()) then
        rootWidth, rootHeight = self.parent.width, self.parent.height
    end

    return (x * rootWidth), (y * rootHeight)
end

function DxElement:getRelativeSizeFromAbsolute(width, height)
    local rootWidth, rootHeight = SCREEN_WIDTH, SCREEN_HEIGHT

    if (self:hasParent()) then
        rootWidth, rootHeight = self.parent.width, self.parent.height
    end

    return (width / rootWidth), (height / rootHeight)
end

function DxElement:getAbsoluteSizeFromRelative(width, height)
    local rootWidth, rootHeight = SCREEN_WIDTH, SCREEN_HEIGHT

    if (self:hasParent()) then
        rootWidth, rootHeight = self.parent.width, self.parent.height
    end

    return (width * rootWidth), (height * rootHeight)
end

function DxElement:getInheritedBasePosition(parent, baseX, baseY)
    baseX, baseY = baseX or self.baseX, baseY or self.baseY

    parent = parent or self:getParent()

    if (parent and not parent:isRootElement()) then
        baseX, baseY = baseX + parent.baseX, baseY + parent.baseY

        if (parent:hasParent()) then
            return self:getInheritedBasePosition(parent:getParent(), baseX, baseY)
        end
    end

    return baseX, baseY
end

function DxElement:getTexture()
    if (not self.cachedTexture) then
        self.cachedTexture = dxCreateRenderTarget(self.width, self.height, true)
    end

    dxSetRenderTarget(self.cachedTexture, true)

    self:dxDraw(0, 0)

    self:drawInternal(self:getChildren())

    dxSetRenderTarget()

    return self.cachedTexture
end

function DxElement:getMaskTexture()
    if (not self.cachedMaskTexture) then
        self.cachedMaskTexture = dxCreateRenderTarget(self.width, self.height, true)
    end

    if (not self.mask.backgroundTexture) then
        self.mask.backgroundTexture = dxCreateTexture(self.width, self.height)
        local pixels = dxGetTexturePixels(self.mask.backgroundTexture)

        for y = 0, self.height - 1 do
            for x = 0, self.width - 1 do
                dxSetPixelColor(pixels, x, y, 255, 255, 255, 255)
            end
        end

        dxSetTexturePixels(self.mask.backgroundTexture, pixels)
    end

    dxSetRenderTarget(self.cachedMaskTexture, true)

    dxDrawImage(0, 0, self.width, self.height, self.mask.backgroundTexture)

    self:dxDraw(0, 0)

    self:drawInternal(self:getChildren())

    dxSetRenderTarget()

    return self.cachedMaskTexture
end

-- **************************************************************************

function DxElement:applyMask(mask)
    if (not self.mask.shader) then
        self.mask.shader = dxCreateShader("assets/shaders/mask.fx")
    end

    self.mask.texture = mask

    if (not isElement(self.mask.texture)) then
        self.mask.texture = dxCreateTexture(self.mask.texture, "argb", true, "clamp")
    end

    dxSetShaderValue(self.mask.shader, "ScreenTexture", self:getTexture())
    dxSetShaderValue(self.mask.shader, "MaskTexture", self.mask.texture)

    self.mask.state = true

    return true
end

function DxElement:isMaskEnabled()
    return self.mask.state
end

function DxElement:setMaskEnabled(state)
    self.mask.state = state
end

function DxElement:drawMask(x, y)
    x, y = x or self.x, y or self.y

    if (not self:isMaskEnabled()) then
        return false
    end

    dxDrawImage(x, y, self.width, self.height, self.mask.shader)
end

function DxElement:isHovering()
    return self.hovering
end

function DxElement:isObstructed(cursorX, cursorY)
    return self:getObstructingElement(cursorX, cursorY) and true or false
end

function DxElement:isObstructedByElement(cursorX, cursorY, element)
    if (not element.isObstructable) then
        return false
    end

    if (element ~= self) then
        if (element.visible) then
            if (cursorX >= element.x and cursorX <= element.x + element.width and cursorY >= element.y and cursorY <= element.y + element.height) then
                if (self:isChild(element)) then
                    return element
                elseif (element:getParent() == self:getParent()) then
                    if (element.zIndex < self.zIndex) then
                        return element
                    end
                else
                    if (self:getRootElement().zIndex > element:getRootElement().zIndex) then
                        return element
                    end
                end
            end
        end
    end
    return false
end

function DxElement:getObstructingElement(cursorX, cursorY)
    for _, element in ipairs(DxElements) do
        if (self:isObstructedByElement(cursorX, cursorY, element)) then
            return element
        end
    end

    return false
end

function DxElement:generateCanvas()
    if (not self:isCanvasEnabled()) then
        self:createCanvas()
    end

    if (self:isSizeUpdated()) then
        destroyElement(self.canvas.texture)
        self.canvas.texture = dxCreateRenderTarget(self.width, self.height, true)
        self.canvas.width, self.canvas.height = self.width, self.height
    end

    dxSetRenderTarget(self:getCanvas(), true)
    -- dxSetBlendMode("add")

    self:drawInternal(self:getChildren())

    -- dxSetBlendMode()
    dxSetRenderTarget()
end

function DxElement:addRenderFunction(func, preRender)
    if (type(func) ~= "function") then
        return false
    end

    func = bind(func, self)

    local tbl = self.renderFunctions.normal

    if (preRender) then
        tbl = self.renderFunctions.preRender
    end

    for _, boundFunc in ipairs(tbl) do
        if (boundFunc == func) then
            return false
        end
    end

    table.insert(tbl, func)
    return true
end

function DxElement:removeRenderFunction(func)
    if (type(func) ~= "function") then
        return false
    end

    local tbl = self.renderFunctions.normal

    for i = #tbl, 1, -1 do
        local f = tbl[i]

        if (f == func) then
            table.remove(tbl, i)
            return true
        end
    end

    tbl = self.renderFunctions.preRender

    for i = #tbl, 1, -1 do
        local f = tbl[i]

        if (f == func) then
            table.remove(tbl, i)
            return true
        end
    end

    return false
end

function DxElement:addClickFunction(func)
    if (type(func) ~= "function") then
        return false
    end

    return table.insert(self.clickFunctions, func)
end

function DxElement:removeClickFunction(func)
    if (type(func) ~= "function") then
        return false
    end

    for i = #self.clickFunctions, 1, -1 do
        local f = self.clickFunctions[i]

        if (f == func) then
            return table.remove(self.clickFunctions, i)
        end
    end

    return false
end

function DxElement:updateCachedTextures()
    self:getTexture()
    self:getMaskTexture()
end

function DxElement:updateShaderTexture()
    if (not self.shader) then
        return false
    end

    if (self:isSizeUpdated()) then
        if (self.shaderTexture) then
            destroyElement(self.shaderTexture)
        end

        self.shaderTexture = dxCreateRenderTarget(self.width, self.height, true)
    end

    dxSetRenderTarget(self.shaderTexture)
    dxDrawImage(0, 0, self.width, self.height, self.shader, 0, 0, 0, tocolor(255, 255, 255, 255))
    dxSetRenderTarget()
end

function DxElement:updatePreviousDimensions()
    self.previousX, self.previousY = self.x, self.y
    self.previousBaseX, self.previousBaseY = self.baseX, self.baseY
    self.previousWidth, self.previousHeight = self.width, self.height
end

function DxElement:drawCanvas()
    if (self:isCanvasEnabled()) then
        if (self:isRootElement()) then
            dxDrawImage(self.x, self.y, self.canvas.width, self.canvas.height, self:getCanvas())
        end
    end
end

function DxElement:drawBounds()
    if (self.drawBounds) then
        local bounds = self.bounds
        dxDrawLine(self.x + bounds.min.x, self.y + bounds.min.y, self.x + bounds.max.x, self.y + bounds.min.y, tocolor(0, 255, 0, 150),2)
        dxDrawLine(self.x + bounds.min.x, self.y + bounds.min.y, self.x + bounds.min.x, self.y + bounds.max.y, tocolor(0, 255, 0, 150),2)
        dxDrawLine(self.x + bounds.max.x, self.y + bounds.min.y, self.x + bounds.max.x, self.y + bounds.max.y, tocolor(0, 255, 0, 150),2)
        dxDrawLine(self.x + bounds.min.x, self.y + bounds.max.y, self.x + bounds.max.x, self.y + bounds.max.y, tocolor(0, 255, 0, 150),2)
    end
end