-- *************************************************************************************** --
-- File: 		:uni\client\classes\dxlib\button.lua
-- Type:		Client
-- Author:		LopSided
-- *************************************************************************************** --
-- © Unison - All rights reserved
-- *************************************************************************************** --

DxButton = inherit(DxElement) --create DxWindow Class and inherit from DxElement

local FONTS = dxStyles.FONTS

function DxButton:new(...)
	if not self then 
		return false 
	end
	
	self = new(self)
	
	local tblRequiredArgs = { --These are pretty self explanatory. Defaults will probably never be used here (for required args), just makes code cleaner later on.
		{name="iBaseX", default=0, typeof="number"},
		{name="iBaseY", default=0, typeof="number"},
		{name="iWidth", default=0, typeof="number"},
		{name="iHeight", default=0, typeof="number"},
		{name="strButtonText", default="My Button", typeof="string"}
	}	
	local tblOptionalArgs = {
		{name="tblOnClickFunctions", default={example=function() print("Clicked button!") end}, typeof="table"},
		{name="tblParentObject", default=false, typeof="table"},
		{name="bRelative", default=false, typeof="boolean"}, --Default: false (relative positioning of parent, if true this requires a value between 0 and 1. Screen is always "parent" for DxWindow)	
		{name="clrPrimary", default=tocolor(255,255,255,255), typeof="number"},
		{name="clrText", default=tocolor(10,10,10,255), typeof="number"},
		{name="iTextScale", default=1, typeof="number"},
		{name="fntButton", default=FONTS.FONT_SEMIBOLD_SMALL, typeof="dx-font"},
		{name="strAlignX", default="center", typeof="string"},
		{name="strAlignY", default="center", typeof="string"}
	}
	
	local vrtArgumentCheck, tblRemainingArgs = argvf({...}, tblRequiredArgs, tblOptionalArgs) --vrt = variable return type
	if not vrtArgumentCheck then return false end
	
	for argKey, vrtArg in pairs(vrtArgumentCheck) do --Traverse the formatted argument table and add them to our object.
		self["m_"..argKey] = vrtArg
	end
	
	--Core vars & functionality added here.
	self.m_strTypeOf = "dx-button"

	self:constructGlobalDefaults()
	DxObjects[self] = self
	DxObjects[self]:setIndex(1)
	return DxObjects[self]
end

function DxButton:draw()
	if not self.m_bDisplay then 
		return false 
	end

	--Main Button
	dxDrawRectangle(self.m_iX, self.m_iY, self.m_iWidth, self.m_iHeight, self.m_clrPrimary) --Background
	dxDrawText(self.m_strButtonText, self.m_iX, self.m_iY, self.m_iX+self.m_iWidth, self.m_iY+self.m_iHeight, self.m_clrText, self.m_iTextScale, self.m_fntButton, self.m_strAlignX, self.m_strAlignY)
end

--SHITTY EXAMPLE USAGE /button
local function testButtonToggle()
	if not testButton then
		testButton = DxButton:new(0.5,0.5,150,35,"Change Cursor",{nextCursor})
		testButton:setParent(testWindow, true)
		testButton:moveTo(1,1,3000)
	else
		testButton:destroy()
		testButton = nil
	end
end
addCommandHandler("button", testButtonToggle)