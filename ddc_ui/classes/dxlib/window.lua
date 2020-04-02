-- *************************************************************************************** --
-- File: 		:uni\client\classes\dxlib\window.lua
-- Type:		Client
-- Author:		LopSided
-- *************************************************************************************** --
-- © Unison - All rights reserved
-- *************************************************************************************** --

DxWindow = inherit(DxElement) --create DxWindow Class and inherit from DxElement

local FONTS = dxStyles.FONTS

function DxWindow:new(...)
	if not self then
		return false 
	end
	
	self = new(self)
	
	local tblRequiredArgs = { --These are pretty self explanatory. Defaults will probably never be used here (for required args), just makes code cleaner later on.
		{name="iBaseX", default=0, typeof="number"},
		{name="iBaseY", default=0, typeof="number"},
		{name="iWidth", default=0, typeof="number"},
		{name="iHeight", default=0, typeof="number"}
	}	
	local tblOptionalArgs = {
		{name="bDraggable", default=false, typeof="boolean"},
		{name="bRelative", default=false, typeof="boolean"}, --Default: false (relative positioning of parent, if true this requires a value between 0 and 1. Screen is always "parent" for DxWindow)	
		{name="clrPrimary", default=tocolor(255,255,255,255), typeof="number"},
		{name="strTitleBarText", default="My Window", typeof="string"}, --Default: "My Window"
		{name="clrTitleBar", default=tocolor(30,30,30,255), typeof="number"},
		{name="clrTitleBarText", default=tocolor(255,255,255,255), typeof="number"},
		{name="fntTitleBar", default=FONTS.FONT_REGULAR_SMALL, typeof="dx-font"},
		{name="iTitleBarHeight", default=35, typeof="number"},
		{name="iTitleBarTextScale", default=1, typeof="number"},
		{name="clrCloseButtonBackground", default=tocolor(255,0,0), typeof="number"},		
		{name="clrBorder", default=false, typeof="number"},		
		{name="iBorderThickness", default=1, typeof="number"}
	}
	
	local vrtArgumentCheck, tblRemainingArgs = argvf({...}, tblRequiredArgs, tblOptionalArgs) --vrt = variable return type
	if not vrtArgumentCheck then 
		return false 
	end
	
	for argKey, vrtArg in pairs(vrtArgumentCheck) do --Traverse the formatted argument table and add them to our object.
		self["m_"..argKey] = vrtArg
	end
	
	--Core vars & functionality added here.
	
	self.m_strTypeOf = "dx-window"

	self.isMoving = false
	
	self.m_bClickOrdering = true
	
	self.m_iCloseButtonWidth = 40
	self.m_clrCloseButtonIcon = tocolor(255,255,255)
	
	self.m_eDragRender = bind(DxWindow.dragRender, self)
	addEventHandler("onClientRender", root, self.m_eDragRender)
	
	self.m_tblOnClickFunctions = {} --Functions stored here will be called upon element click (after certain checks handled by m_eOnClick)
	
	self.m_tblParent = false
	
	self:constructGlobalDefaults()
	DxObjects[self] = self
	DxObjects[self]:setIndex(1)
	return DxObjects[self]
end

function DxWindow:draw()
	-- self = DxObjects[self]
	if not self.m_bDisplay then 
		return false 
	end
	
	--Main Window
	dxDrawRectangle(self.m_iX, self.m_iY, self.m_iWidth, self.m_iHeight, self.m_clrPrimary) --Background
	
	--Titlebar
	dxDrawRectangle(self.m_iX, self.m_iY, self.m_iWidth, self.m_iTitleBarHeight, self.m_clrTitleBar) --Titlebar Background
	if self.m_strTitleBarText then		
		dxDrawText(self.m_strTitleBarText, self.m_iX, self.m_iY, self.m_iX+self.m_iWidth, self.m_iY+self.m_iTitleBarHeight, self.m_clrTitleBarText, self.m_iTitleBarTextScale, self.m_fntTitleBar, "center", "center") --Titlebar Text
	end		
	
	--Close button
	if self.m_clrCloseButtonBackground then
		dxDrawRectangle(self.m_iX+(self.m_iWidth-self.m_iCloseButtonWidth), self.m_iY, self.m_iCloseButtonWidth, self.m_iTitleBarHeight, self.m_clrCloseButtonBackground)
	end	
	dxDrawText("", self.m_iX+(self.m_iWidth-self.m_iCloseButtonWidth), self.m_iY, self.m_iX+(self.m_iWidth-self.m_iCloseButtonWidth)+self.m_iCloseButtonWidth, self.m_iY+self.m_iTitleBarHeight, self.m_clrCloseButtonIcon, 1, FONTS.FONT_ICON_SMALL, "center", "center")
	
	--Window border
	if self.m_clrBorder then
		dxDrawRectangle(self.m_iX, self.m_iY-self.m_iBorderThickness, self.m_iWidth, self.m_iBorderThickness, self.m_clrBorder)
		dxDrawRectangle(self.m_iX-(self.m_iBorderThickness), self.m_iY-(self.m_iBorderThickness), self.m_iBorderThickness, self.m_iHeight+(self.m_iBorderThickness*2), self.m_clrBorder)
		
		dxDrawRectangle(self.m_iX, self.m_iY+self.m_iHeight, self.m_iWidth, self.m_iBorderThickness, self.m_clrBorder)
		dxDrawRectangle(self.m_iX+self.m_iWidth, self.m_iY-(self.m_iBorderThickness), self.m_iBorderThickness, self.m_iHeight+(self.m_iBorderThickness*2), self.m_clrBorder)
	end		
end

function DxWindow:click(iCursorX, iCursorY)
	if (iCursorX >= self.m_iX and iCursorX <= self.m_iX + self.m_iWidth and iCursorY >= self.m_iY and iCursorY <= self.m_iY + self.m_iTitleBarHeight) then --Are we clicking/dragging in the title bar area?			
		if (iCursorX >= self.m_iX+(self.m_iWidth-self.m_iCloseButtonWidth) and iCursorX <= self.m_iX+(self.m_iWidth-self.m_iCloseButtonWidth)+self.m_iCloseButtonWidth and iCursorY >= self.m_iY and iCursorY <= self.m_iY+(self.m_iTitleBarHeight)) then --Are we clicking the close button?
			self:setEnabled(false) --Hack to make sure all other onClick events are done. We will temporarily hide the DX element and destroy it slightly later. Otherwise the click will carry through to other DX elements, and since we would normally destroy this instantly there will be no reason for it to abort in the block above.
			setTimer(function()
				self:destroy()
			end, 100, 1) --100ms should be safe enough just incase the DxObjects table gets quite big. Should probably implement a callback here later instead of a timer.
			return false
		end						

		if not self.m_bDraggable then 
			return false 
		end
		
		if not getKeyState("mouse1") then 
			return false 
		end
		self.isMoving = true
		self.m_iOffsetX = iCursorX - self.m_iX
		self.m_iOffsetY = iCursorY - self.m_iY
	end
end

--SHITTY EXAMPLE USAGE /window
testWindow = false
local function toggleTestWindow()
	showCursor(true)
	if not testWindow then
		testWindow = DxWindow:new(g_vScreenSize.x-450, g_vScreenSize.y-350, 400, 300, true, nil, tocolor(20,20,20), "Window", nil, nil, nil, nil, nil, nil,tocolor(0,0,0,0),0)
		-- testWindow:moveTo(0,0,5000)
	else
		testWindow:destroy()
		testWindow = nil
	end
end
addCommandHandler("window", toggleTestWindow)
