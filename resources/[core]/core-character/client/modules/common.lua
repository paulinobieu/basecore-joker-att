-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local GetEntityModel = GetEntityModel
local GetHashKey = GetHashKey
local PlayerPedId = PlayerPedId
local TriggerServerEvent = TriggerServerEvent
local pairs = pairs
local tonumber = tonumber
local tostring = tostring
local type = type
local floor = math.floor
local format = string.format
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
NUIOpen      = false
NUIReady     = false
NUIUnlocked  = false
NUIQueue     = {}
CurrentScreen = nil

CurrentAppearance = {}
CurrentPose = nil

InCreator = false
InBarber  = false
InSelect  = false
InSpawn   = false
EditMode  = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- VALIDATENUMBER
-----------------------------------------------------------------------------------------------------------------------------------------
function ValidateNumber(val, min, max, default)
    local num = tonumber(val)
    if not num then return default or 0 end
    if min and num < min then return min end
    if max and num > max then return max end
    return num
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VALIDATESTRING
-----------------------------------------------------------------------------------------------------------------------------------------
function ValidateString(val, minLen, maxLen, default)
    if type(val) ~= "string" then return default or "" end
    local trimmed = val:gsub("^%s+", ""):gsub("%s+$", "")
    if minLen and #trimmed < minLen then return default or "" end
    if maxLen and #trimmed > maxLen then return trimmed:sub(1, maxLen) end
    return trimmed
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FLOAT
-----------------------------------------------------------------------------------------------------------------------------------------
function Float(value)
    return (tonumber(value) or 0) + 0.0
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLAMPCOLOR
-----------------------------------------------------------------------------------------------------------------------------------------
function ClampColor(value)
    value = floor(tonumber(value) or 0)
    if value < 0 then return 0 end
    if value > 255 then return 255 end
    return value
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NORMALIZEHEXCOLOR
-----------------------------------------------------------------------------------------------------------------------------------------
function NormalizeHexColor(color, fallback)
    color = tostring(color or fallback or "#df155b")
    color = color:gsub("#", "")

    if #color == 3 then
        color = color:sub(1, 1):rep(2) .. color:sub(2, 2):rep(2) .. color:sub(3, 3):rep(2)
    end

    if #color ~= 6 or not color:match("^[%x]+$") then
        color = tostring(fallback or "df155b"):gsub("#", "")
    end

    return "#" .. color:lower()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HEXTORGB
-----------------------------------------------------------------------------------------------------------------------------------------
function HexToRgb(color)
    color = NormalizeHexColor(color)
    return {
        r = tonumber(color:sub(2, 3), 16) or 223,
        g = tonumber(color:sub(4, 5), 16) or 21,
        b = tonumber(color:sub(6, 7), 16) or 91
    }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RGBTOHEX
-----------------------------------------------------------------------------------------------------------------------------------------
function RgbToHex(rgb)
    return format("#%02x%02x%02x", ClampColor(rgb.r), ClampColor(rgb.g), ClampColor(rgb.b))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BLENDHEX
-----------------------------------------------------------------------------------------------------------------------------------------
function BlendHex(colorA, colorB, factor)
    local from = HexToRgb(colorA)
    local to = HexToRgb(colorB)
    local ratio = tonumber(factor) or 0

    return RgbToHex({
        r = from.r + ((to.r - from.r) * ratio),
        g = from.g + ((to.g - from.g) * ratio),
        b = from.b + ((to.b - from.b) * ratio)
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDTHEMEPALETTE
-----------------------------------------------------------------------------------------------------------------------------------------
local function PickColor(themeConfig, key)
    if type(themeConfig) == "table" then
        local value = themeConfig[key]
        if type(value) == "string" and value ~= "" then return value end
    end
    return nil
end

function BuildThemePalette(themeConfig)
    local baseColor = NormalizeHexColor(PickColor(themeConfig, "primaryColor"), "#df155b")
    local secondary = PickColor(themeConfig, "secondaryColor")
    local thirdy    = PickColor(themeConfig, "thirdyColor")

    return {
        primaryColor = baseColor,
        secondaryColor = secondary and NormalizeHexColor(secondary, baseColor)
            or BlendHex(baseColor, "#000000", 0.29),
        thirdyColor = thirdy and NormalizeHexColor(thirdy, baseColor)
            or BlendHex(baseColor, "#000000", 0.54)
    }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- COPYAPPEARANCE
-----------------------------------------------------------------------------------------------------------------------------------------
function CopyAppearance(source)
    local out = {}
    for key, fallback in pairs(Appearance.Default) do
        local value = source and source[key]
        out[key] = value ~= nil and value or fallback
    end
    return out
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ISMALE
-----------------------------------------------------------------------------------------------------------------------------------------
function IsMale(ped)
    return GetEntityModel(ped or PlayerPedId()) == GetHashKey("mp_m_freemode_01")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GENDERKEY
-----------------------------------------------------------------------------------------------------------------------------------------
function GenderKey(ped)
    return IsMale(ped) and "Male" or "Female"
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFY
-----------------------------------------------------------------------------------------------------------------------------------------
function Notify(message, severity)
    Framework.Notify(message, severity)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYPOSE
-----------------------------------------------------------------------------------------------------------------------------------------
-- Guarda qual pose está valendo para o vigia lá do creator.lua saber o que
-- recolocar.
function PlayPose(pose)
    CurrentPose = pose
    Framework.PlayPose(pose)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STOPPOSE
-----------------------------------------------------------------------------------------------------------------------------------------
function StopPose()
    CurrentPose = nil
    Framework.StopAnim()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SENDSERVERACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function SendServerAction(action, data)
    TriggerServerEvent("core-character:handleAction", action, data or {})
end
