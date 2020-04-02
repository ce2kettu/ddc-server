-- *************************************************************************************** --
-- File: 		:uni\client\classes\dxlib\main.lua
-- Type:		Client
-- Author:		LopSided
-- *************************************************************************************** --
-- © Unison - All rights reserved
-- *************************************************************************************** --

DxObjects = {}
--------------
DxElement = inherit(DxAnimate)
local sx, sy = guiGetScreenSize()
g_vScreenSize = {
x = sx,
y = sy
}

function DxElement:constructGlobalDefaults()
	local tblDefaults = {
		m_iX = self.m_iBaseX,
		m_iY = self.m_iBaseY,
		m_iOffsetX = 0,
		m_iOffsetY = 0,
		m_bDisplay = true,
		m_tblParent = false,
		m_tblChildren = {},
		m_iZIndex = 1,
		m_bClickOrdering = false,
		m_clrBorder = false,
		m_iBorderThickness = 1,
		m_eRenderParentPositioning = bind(self.renderParentPositioning, self),
		m_eOnClientRender = bind(self.draw, self),
		m_eOnClick = bind(self.onClick, self)
	}
	
	for strVarName, vrtValue in pairs(tblDefaults) do
		if not self[strVarName] then
			self[strVarName] = vrtValue
		end
	end
	
	addEventHandler("onClientRender", root, self.m_eRenderParentPositioning) --The parent positioning needs to be rendered before we display the actual content, otherwise the child elements will move out of sync with the parent and look 'fluid'
	addEventHandler("onClientRender", root, self.m_eOnClientRender)
	addEventHandler("onClientClick", root, self.m_eOnClick)
	
	return true
end

function DxElement:setIndex(iZIndex)
	if type(iZIndex) ~= "number" then 
		return false 
	end
	
	local iPreZIndex = self.m_iZIndex
	self.m_iZIndex = iZIndex
	
	for _, objInstance in pairs(DxObjects) do --Shift the indexes of other DX elements (will need to be adjusted for child elements once they are implemented)
		if not self.m_tblChildren[objInstance] then
			if objInstance.m_iZIndex <= iPreZIndex and objInstance ~= self then
				if (objInstance.m_iZIndex + 1) <= countDxObjects() then
					objInstance.m_iZIndex = objInstance.m_iZIndex + 1
				end
			end
		else
			objInstance:bringToFront()
		end
	end	
end

function DxElement:getIndex()
	return self.m_iZIndex
end

function DxElement:setEnabled(bState)
	if type(bState) ~= "boolean" then 
		return false 
	end
	self.m_bDisplay = bState
	return true
end

function DxElement:setWindowCloseBackgroundColor(clr)
	if not self.m_clrCloseButtonBackground then 
		return false 
	end
	
	if type(clr) ~= "number" then 
		return false 
	end
	
	self.m_clrCloseButtonBackground = clr
	return true
end

function DxElement:setClickOrderingEnabled(bState)
	if type(bState) ~= "boolean" then 
		return false 
	end
	self.m_bClickOrdering = bState
	return true
end

function DxElement:bringToFront()
	removeEventHandler("onClientRender", root, self.m_eOnClientRender)
	addEventHandler("onClientRender", root, self.m_eOnClientRender)
	self:setIndex(1)
end 


function DxElement:calculateRelatives(iX, iY, objParent)
	if not objParent then
		if self.m_tblParent then
			objParent = self.m_tblParent
		else
			return false
		end
	end
	
	iX, iY = iX or self.m_iBaseX, iY or self.m_iBaseY
	
	local tblParentInstance = DxObjects[objParent]
	
	if not tblParentInstance then 
		return false 
	end
	
	local iRelativeWidth, iRelativeHeight = (self.m_iWidth) / tblParentInstance.m_iWidth, (self.m_iHeight) / tblParentInstance.m_iHeight
	
	if tblParentInstance.m_strTypeOf == "dx-window" then
		iRelativeHeight = iRelativeHeight + (tblParentInstance.m_iTitleBarHeight/tblParentInstance.m_iHeight)
	end

	local scaleX, scaleY = 1-iRelativeWidth, 1-iRelativeHeight
	
	return iX * scaleX, iY * scaleY, iRelativeWidth, iRelativeHeight
end

function DxElement:setParent(objParent, bCentered)
	if not objParent then
		DxObjects[self.m_tblParent].m_tblChildren[self] = nil
		self.m_tblParent = false
		return true
	end
	
	local tblParentInstance = DxObjects[objParent]
	
	if not tblParentInstance then 
		return false 
	end
	
	if self.m_tblParent == tblParentInstance then 
		return false 
	end
	
	if tblParentInstance.m_tblChildren[self] then 
		return false 
	end

	self.ms_iOriginalBaseX, self.ms_iOriginalBaseY = self.m_iBaseX, self.m_iBaseY
	self.m_iBaseX, self.m_iBaseY, self.ms_iRelativeWidth, self.ms_iRelativeHeight = self:calculateRelatives(self.m_iBaseX, self.m_iBaseY, objParent)
	
	self.ms_bCentered = bCentered
	self.m_tblParent = tblParentInstance
	tblParentInstance.m_tblChildren[self] = self
	return true
end

function DxElement:calculateParentPosition(iX, iY)
	if not self.m_tblParent then
		return false
	end
	
	local tblParentInstance = DxObjects[self.m_tblParent]
	
	iX, iY = iX or tblParentInstance.m_iX, iY or tblParentInstance.m_iY
	local iOffsetX, iOffsetY = (tblParentInstance.m_iWidth * self.m_iBaseX), (tblParentInstance.m_iHeight * self.m_iBaseY)
	
	if tblParentInstance.m_strTypeOf == "dx-window" then
		iOffsetY = iOffsetY + tblParentInstance.m_iTitleBarHeight
	end
	
	return iX + iOffsetX, iY + iOffsetY
end

function DxElement:renderParentPositioning()
	if not self.m_tblParent then 
		return false 
	end

	local tblParentInstance = DxObjects[self.m_tblParent]
	local iRelativeWidth, iRelativeHeight = self.ms_iRelativeWidth, self.ms_iRelativeHeight

	if (self.m_iBaseX > 1-iRelativeWidth) or (self.m_iBaseX < -iRelativeWidth) or (self.m_iBaseY > 1-iRelativeHeight) or (self.m_iBaseY < -iRelativeHeight) then 
		self:setParent(false) --Remove the parent from this DX element.
		return false 
	end
	
	self.m_iX, self.m_iY = self:calculateParentPosition()
end

function DxElement:dragRender()	
	if not self.m_bDisplay or not self.m_bDraggable or not self.isMoving then 
		return false 
	end
	if (isCursorShowing() and self.isMoving) then	--Check if the window is currently moving (being dragged by user)			
		local iCursorX, iCursorY = getCursorPosition()

		iCursorX = iCursorX * g_vScreenSize.x
		iCursorY = iCursorY * g_vScreenSize.y
		
		self.m_iX = iCursorX - self.m_iOffsetX
		self.m_iY = iCursorY - self.m_iOffsetY
		
		self:forceInBounds()
	end
end

function DxElement:onClick(strButton, strState, iCursorX, iCursorY)
	if not self.m_bDisplay then 
		return false 
	end
	
	if (strButton == 'left' and strState == 'down') then			
		if (iCursorX >= self.m_iX and iCursorX <= self.m_iX + self.m_iWidth and iCursorY >= self.m_iY and iCursorY <= self.m_iY + self.m_iHeight) then --Are we clicking/dragging in the DX element area?
			--Do a check to see if there are any other DX elements above this one where the user clicked
			for _, objInstance in pairs(DxObjects) do
				if objInstance ~= self then
					if objInstance.m_iZIndex < self.m_iZIndex then
						if (iCursorX >= objInstance.m_iX and iCursorX <= objInstance.m_iX + objInstance.m_iWidth and iCursorY >= objInstance.m_iY and iCursorY <= objInstance.m_iY + objInstance.m_iHeight) then
							return false --Detected DX element above, abort.
						end
					end
				end
			end
			
			for iIndex, fFunc in pairs(self.m_tblOnClickFunctions) do
				fFunc()
			end
			
			if self.m_bClickOrdering then --Are we allowed to bring to front on click?
				self:bringToFront()
			end
			
			if self.click then
				self:click(iCursorX, iCursorY) --Handle custom click function which passes cursor value
			end
		end
	elseif (strButton == 'left' and strState == 'up') then
		self.isMoving = false
	end
end

function DxElement:destroy()
	if self.m_eOnClientRender then
		removeEventHandler("onClientRender", root, self.m_eOnClientRender)
		removeEventHandler("onClientRender", root, self.m_eRenderParentPositioning)
		removeEventHandler("onClientClick", root, self.m_eOnClick)
		
		if self.ms_eRenderAnimation then
			removeEventHandler("onClientRender", root, self.ms_eRenderAnimation)
		end
		
		if self.ms_eRenderResize then
			removeEventHandler("onClientRender", root, self.ms_eRenderResize)
		end
		
		for _, childInstance in pairs(DxObjects[self].m_tblChildren) do
			childInstance:setEnabled(false)
			childInstance:destroy()
		end
	end
	
	DxAnimations[self] = nil
	DxObjects[self] = nil
	delete(self)
	self = nil	
	
	collectgarbage("collect")
		
	for _, objInstance in pairs(DxObjects) do --Find the DX element with an index of 2 and bring it to front (no need to use bringToFront() as we have already removed the DX element which was infront of this one)
		if objInstance.m_iZIndex == 2 then
			objInstance:setIndex(1)
			return true
		end
	end
	return true
end
