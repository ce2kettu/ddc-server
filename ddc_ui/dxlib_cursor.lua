-- *************************************************************************************** --
-- File: 		:uni\client\dxlib_cursor.lua
-- Type:		Client
-- Author:		LopSided
-- *************************************************************************************** --
-- © Unison - All rights reserved
-- *************************************************************************************** --

DxCursor = {}
DxCursor.strCursorType = "default"

DxCursor.tblCursorTypes = {
	"closedhand",
	"default",
	"ibeam",
	"move",
	"notallowed",
	"pointinghand",
	"resizeeastwest",
	"resizenortheastsouthwest",
	"resizenorthsouth",
	"resizenorthwestsoutheast"
}

DxCursor.tblCursorSize = {}
DxCursor.mainMenuActive = false

--Replace the default cursor
function DxCursor.renderCursor()
	--Stuff for detecting if main menu is open or closed.
	if DxCursor.mainMenuInitialized then
		if not DxCursor.mainMenuActive then
			if isMTAWindowActive() then
				DxCursor.mainMenuActive = true
			end
		else
			if not isMTAWindowActive() then
				setCursorAlpha(0)
				DxCursor.mainMenuInitialized = false
				DxCursor.mainMenuActive = false
			end				
		end
	end

	if DxCursor.mainMenuInitialized then 
		return false 
	end
	
	local iX, iY = DxCursor.iCursorX, DxCursor.iCursorY
	if not iX then 
		return false 
	end
	local strCurrentCursorPath = "files/images/cursors/"..DxCursor.strCursorType..".png"
	
	if not DxCursor.tblCursorSize[DxCursor.strCursorType] then
		DxCursor.tblCursorSize[DxCursor.strCursorType] = {}
		DxCursor.tblCursorSize[DxCursor.strCursorType].elemStaticImage = guiCreateStaticImage(0,0,0,0,strCurrentCursorPath,false)
	end
	
	if isElement(DxCursor.tblCursorSize[DxCursor.strCursorType].elemStaticImage) then
		if (not DxCursor.tblCursorSize[DxCursor.strCursorType].iWidth) and (guiStaticImageGetNativeSize(DxCursor.tblCursorSize[DxCursor.strCursorType].elemStaticImage)) then
			local iWidth, iHeight = guiStaticImageGetNativeSize(DxCursor.tblCursorSize[DxCursor.strCursorType].elemStaticImage)
			DxCursor.tblCursorSize[DxCursor.strCursorType].iWidth, DxCursor.tblCursorSize[DxCursor.strCursorType].iHeight = iWidth, iHeight
			destroyElement(DxCursor.tblCursorSize[DxCursor.strCursorType].elemStaticImage)
			DxCursor.tblCursorSize[DxCursor.strCursorType].elemStaticImage = nil
		end
	end
	
	local iImageWidth, iImageHeight = DxCursor.tblCursorSize[DxCursor.strCursorType].iWidth, DxCursor.tblCursorSize[DxCursor.strCursorType].iHeight
	
	if not iImageWidth then 
		return false 
	end
	
	if isChatBoxInputActive(  ) and not isCursorShowing( ) then
		dxDrawImage(iX, iY, iImageWidth, iImageHeight, strCurrentCursorPath, 0, 0, 0, tocolor(255, 255, 255, 255), true)
		setCursorAlpha(0)
	elseif isConsoleActive(  ) and not isCursorShowing( ) then
		dxDrawImage(iX, iY, iImageWidth, iImageHeight, strCurrentCursorPath, 0, 0, 0, tocolor(255, 255, 255, 255), true)
		setCursorAlpha(0)
	elseif isCursorShowing( ) then
		dxDrawImage(iX, iY, iImageWidth, iImageHeight, strCurrentCursorPath, 0, 0, 0, tocolor(255, 255, 255, 255), true)
		setCursorAlpha(0)
	end
end
addEventHandler("onClientRender", root, DxCursor.renderCursor)

function DxCursor.onEscape(strButton, bPressed) --Initialize main menu opening state.
	if not bPressed then 
		return false 
	end
	
	if strButton ~= "escape" then 
		return false 
	end 
	
	if not DxCursor.mainMenuInitialized then
		DxCursor.mainMenuInitialized = true	
		DxCursor.mainMenuActive = false
		return true
	end
end
addEventHandler("onClientKey", root, DxCursor.onEscape)

function DxCursor.cursorMove(_, _, x, y)
	DxCursor.iCursorX, DxCursor.iCursorY = x, y
end
addEventHandler("onClientCursorMove", root, DxCursor.cursorMove)

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		setCursorAlpha(0)
	end
)

addEventHandler("onClientResourceStop", resourceRoot,
	function()
		setCursorAlpha(255)
	end
)
