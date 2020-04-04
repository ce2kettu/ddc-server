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

Palette = {
    primary = {
        light = "#6fbf73",
        main = "#4caf50",
        dark = "#357a38"
    },
    secondary = {
        light = "#33bfff",
        main = "#00b0ff",
        dark = "#007bb2"
    },
    error = {
        light = "#e57373",
        main = "#f44336",
        dark = "#d32f2f"
    },
    warning = {
        light = "#ffb74d",
        main = "#ff9800",
        dark = "#f57c00"
    },
    info = {
        light = "#64b5f6",
        main = "#2196f3",
        dark = "#1976d2"
    },
    success = {
        light = "#81c784",
        main = "#4caf50",
        dark = "#388e3c"
    }
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