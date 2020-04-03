SCREEN_WIDTH, SCREEN_HEIGHT = guiGetScreenSize()
REAL_SCALE = SCREEN_HEIGHT / 1080
RELATIVE_SCALE = math.max(SCREEN_HEIGHT / 1080, 0.55)
RELATIVE_FONT_SCALE = math.max(SCREEN_HEIGHT / 1080, 0.75)
RESOURCE_NAME = false

function REL(a) return a * RELATIVE_SCALE end
function FONT_SIZE(a) return a * RELATIVE_FONT_SCALE end

DxElements = {}
DxHostedElements = {}

DxTypes = {
	"DxElement",
    "DxImage",
    "DxRoundedRect",
    "DxRoundedRectDetail"
}

local function init()
	RESOURCE_NAME = getResourceName(getThisResource())

    -- load import function
    loadstring(exports.ddc_import:load())()

	-- initialize exporter
	uiInitializeExporter()
end
addEventHandler("onClientResourceStart", resourceRoot, init)

local testValues = {
	["none"] = true,
	["no_mem"] = true,
	["low_mem"] = true,
	["no_shader"] = true
}

function testMode(cmd, value)
	if (testValues[value]) then
		dxSetTestMode(value)
		outputChatBox("Test mode set to "..value..".", 220, 175, 20, false)
	else
		outputChatBox("Invalid test mode entered.", 245, 20, 20, false)
	end
end
addCommandHandler("setmode", testMode)