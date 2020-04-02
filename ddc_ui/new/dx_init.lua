SCREEN_WIDTH, SCREEN_HEIGHT = guiGetScreenSize()
--RELATIVE_SCALE = math.min(math.max((SCREEN_WIDTH * 0.5625) / 900, 0.7), 1)
RELATIVE_SCALE = math.max(SCREEN_HEIGHT / 1080, 0.55)
RELATIVE_FONT_SCALE = math.max(SCREEN_HEIGHT / 1080, 0.75)

function REL(a) return a * RELATIVE_SCALE end
function FONT_SIZE(a) return a * RELATIVE_FONT_SCALE end

DxElements = {}

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