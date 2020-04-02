-- *************************************************************************************** --
-- File: 		:uni\client\dxlib_styles.lua
-- Type:		Client
-- Author:		LopSided
-- *************************************************************************************** --
-- © Unison - All rights reserved
-- *************************************************************************************** --

dxStyles = {}
local baseScreenX, baseScreenY = 1920, 1080
local relX, relY = (g_vScreenSize.x / 1920), (g_vScreenSize.y / 1080)

-- TODO: add min size
local FONT_SIZE_SMALL = math.floor(g_vScreenSize.x * (7 / baseScreenY))
local FONT_SIZE_DEFAULT = math.floor(g_vScreenSize.x * (12 / baseScreenY))
local FONT_SIZE_LARGE = math.floor(g_vScreenSize.x * (20 / baseScreenY))

dxStyles.FONTS = {
	FONT_ICON_REGULAR = dxCreateFont("files/fonts/font_icon_regular.otf", FONT_SIZE_DEFAULT, false, "cleartype_natural"),
	FONT_ICON_SMALL = dxCreateFont("files/fonts/font_icon_light.otf", FONT_SIZE_SMALL, false, "cleartype_natural"),
	FONT_ICON_LARGE = dxCreateFont("files/fonts/font_icon_solid.otf", FONT_SIZE_LARGE, false, "cleartype_natural"),
	FONT_SEMIBOLD_SMALL = dxCreateFont("files/fonts/font_opensans_semibold.ttf", FONT_SIZE_SMALL, false, "cleartype_natural"),
	FONT_SEMIBOLD_DEFAULT = dxCreateFont("files/fonts/font_opensans_semibold.ttf", FONT_SIZE_DEFAULT, false, "cleartype_natural"),
	FONT_SEMIBOLD_LARGE = dxCreateFont("files/fonts/font_opensans_semibold.ttf", FONT_SIZE_LARGE, false, "cleartype_natural"),
	FONT_REGULAR_SMALL = dxCreateFont("files/fonts/font_opensans_regular.ttf", FONT_SIZE_SMALL, false, "cleartype_natural"),
	FONT_REGULAR_DEFAULT = dxCreateFont("files/fonts/font_opensans_regular.ttf", FONT_SIZE_DEFAULT, false, "cleartype_natural"),
	FONT_REGULAR_LARGE = dxCreateFont("files/fonts/font_opensans_regular.ttf", FONT_SIZE_LARGE, false, "cleartype_natural"),
	FONT_BOLD_SMALL = dxCreateFont("files/fonts/font_opensans_bold.ttf", FONT_SIZE_SMALL, false, "cleartype_natural"),
	FONT_BOLD_DEFAULT = dxCreateFont("files/fonts/font_opensans_bold.ttf", FONT_SIZE_DEFAULT, false, "cleartype_natural"),
	FONT_BOLD_LARGE = dxCreateFont("files/fonts/font_opensans_bold.ttf", FONT_SIZE_LARGE, false, "cleartype_natural")
}