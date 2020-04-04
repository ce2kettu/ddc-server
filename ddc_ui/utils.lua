-- https://gist.github.com/haggen/2fd643ea9a261fea2094#gistcomment-2339900
local charset = {}  do -- [0-9a-zA-Z]
    for c = 48, 57  do table.insert(charset, string.char(c)) end
    for c = 65, 90  do table.insert(charset, string.char(c)) end
    for c = 97, 122 do table.insert(charset, string.char(c)) end
end

function randomString(length)
    if (not length or length <= 0) then
        return ""
    end

    math.randomseed(getTickCount())
    return randomString(length - 1)..charset[math.random(1, #charset)]
end

function generateId()
   return randomString(6)..(getTickCount() + (#DxElements + #DxHostedElements))
end

local matches = {
  ["^"] = "%^";
  ["$"] = "%$";
  ["("] = "%(";
  [")"] = "%)";
  ["%"] = "%%";
  ["."] = "%.";
  ["["] = "%[";
  ["]"] = "%]";
  ["*"] = "%*";
  ["+"] = "%+";
  ["-"] = "%-";
  ["?"] = "%?";
  ["\0"] = "%z";
}

function escapePattern(s)
    return s:gsub(".", matches)
end

function isCursorInBounds(x, y, width, height)
    if (not isCursorShowing()) then
        return false
    end

    local sx, sy = guiGetScreenSize()
    local cx, cy = getCursorPosition()
    local cx, cy = (cx * sx), (cy * sy)

    return ((cx >= x and cx <= x + width) and (cy >= y and cy <= y + height))
end

function decimalToRGBA(c)
    return bitExtract(c, 0, 8), bitExtract(c, 8, 8), bitExtract(c, 16, 8), bitExtract(c, 24, 8)
end

function textFit(text, size, font, width, padding)
    local fontSize = size
    padding = padding or 10
    width = width - padding

    while (dxGetTextWidth(text, fontSize, font, true) > width) do
        fontSize = fontSize - 0.1
    end

    return fontSize
end

function textOverflow(text, size, font, width, ellipsis, padding)
    local ellipsis = ellipsis or false
    local padding = padding or 0

    while (dxGetTextWidth(text, size, font, true) > width - padding) do
        if (ellipsis) then
            text = text:sub(1, text:len() - 4).."..."
        else
            text = text:sub(1, text:len() - 1)
        end
    end

    return text
end

function getExternalFile(resource, path)
    if (not path) then
        return false
    end

    if (resource) then
        path = path:gsub("\\", "/")

        if (not path:find(":")) then
            path = ":"..getResourceName(res).."/"..path
            path = path:gsub("//", "/") or path
        end
    end

    return path
end