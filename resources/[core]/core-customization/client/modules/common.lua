-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local GetEntityModel = GetEntityModel
local GetHashKey = GetHashKey
local PlayerPedId = PlayerPedId
local TriggerServerEvent = TriggerServerEvent
local pairs = pairs
local tonumber = tonumber
local type = type
local floor = math.floor
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
NUIOpen     = false
NUIReady    = false
NUIUnlocked = false
NUIQueue    = {}

InClothes = false
InTattoos = false

CurrentClothes = {}
PreviousClothes = nil
BackupClothes = nil

CurrentTattoos = {}
BackupTattoos = nil

ClothesLocked = false
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
-- INT
-----------------------------------------------------------------------------------------------------------------------------------------
function Int(value)
    return floor(tonumber(value) or 0)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FLOAT
-----------------------------------------------------------------------------------------------------------------------------------------
function Float(value)
    return (tonumber(value) or 0) + 0.0
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERMODEL
-----------------------------------------------------------------------------------------------------------------------------------------
function PlayerModel(ped)
    return GetEntityModel(ped or PlayerPedId()) == GetHashKey("mp_f_freemode_01")
        and "mp_f_freemode_01"
        or "mp_m_freemode_01"
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERGENDER
-----------------------------------------------------------------------------------------------------------------------------------------
function PlayerGender(ped)
    return PlayerModel(ped) == "mp_f_freemode_01" and "Female" or "Male"
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- COPYCLOTHES
-----------------------------------------------------------------------------------------------------------------------------------------
function CopyClothes(clothes)
    local copy = {}

    for part, entry in pairs(clothes or {}) do
        if type(entry) == "table" then
            copy[part] = { item = Int(entry.item), texture = Int(entry.texture) }
        end
    end

    return copy
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- COPYTATTOOS
-----------------------------------------------------------------------------------------------------------------------------------------
function CopyTattoos(tattoos)
    local copy = {}

    for name, part in pairs(tattoos or {}) do
        copy[name] = { type(part) == "table" and part[1] or part }
    end

    return copy
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFY
-----------------------------------------------------------------------------------------------------------------------------------------
function Notify(message, severity)
    if NUIOpen then
        return SendInterfaceMessage("notify", {
            severity = severity or "info",
            title = "Aparência",
            message = message,
        })
    end

    Framework.Notify(message, severity)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLAMPCOLOR
-----------------------------------------------------------------------------------------------------------------------------------------
local function ClampColor(value)
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
-- BLENDHEX
-----------------------------------------------------------------------------------------------------------------------------------------
local function BlendHex(colorA, colorB, factor)
    local from = NormalizeHexColor(colorA)
    local to = NormalizeHexColor(colorB)
    local ratio = tonumber(factor) or 0
    local out = {}

    for index = 0, 2 do
        local start = 2 + index * 2
        local a = tonumber(from:sub(start, start + 1), 16) or 0
        local b = tonumber(to:sub(start, start + 1), 16) or 0

        out[index + 1] = ClampColor(a + ((b - a) * ratio))
    end

    return string.format("#%02x%02x%02x", out[1], out[2], out[3])
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
-- SENDSERVERACTION
-----------------------------------------------------------------------------------------------------------------------------------------
function SendServerAction(action, data)
    TriggerServerEvent("core-customization:handleAction", action, data)
end
