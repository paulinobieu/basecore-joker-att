-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local ipairs = ipairs
local pairs = pairs
local type = type
local floor = math.floor
local tonumber = tonumber
-----------------------------------------------------------------------------------------------------------------------------------------
-- SANITIZECLOTHES
-----------------------------------------------------------------------------------------------------------------------------------------
function SanitizeClothes(clothes)
    local safe = {}

    for part in pairs(Clothes.Parts) do
        local default = Clothes.Default[part] or { item = 0, texture = 0 }
        local entry = type(clothes) == "table" and clothes[part] or nil

        if type(entry) == "table" then
            safe[part] = {
                item = floor(tonumber(entry.item) or default.item),
                texture = floor(tonumber(entry.texture) or default.texture),
            }
        else
            safe[part] = { item = default.item, texture = default.texture }
        end
    end

    return safe
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SANITIZETATTOOS
-----------------------------------------------------------------------------------------------------------------------------------------
function SanitizeTattoos(tattoos)
    local safe = {}

    if type(tattoos) ~= "table" then return safe end

    for name, part in pairs(tattoos) do
        local collection = type(part) == "table" and part[1] or part

        if type(name) == "string" and type(collection) == "string" then
            safe[name] = { collection }
        end
    end

    return safe
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADOUTFIT
-----------------------------------------------------------------------------------------------------------------------------------------
function LoadOutfit(userId)
    local stored = Framework.LoadOutfit(userId)

    return {
        clothes = SanitizeClothes(type(stored) == "table" and stored.clothes or nil),
        tattoos = SanitizeTattoos(type(stored) == "table" and stored.tattoos or nil),
    }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAVEOUTFIT
-----------------------------------------------------------------------------------------------------------------------------------------
function SaveOutfit(userId, clothes, tattoos)
    return Framework.SaveOutfit(
        userId,
        clothes ~= nil and SanitizeClothes(clothes) or nil,
        tattoos ~= nil and SanitizeTattoos(tattoos) or nil
    )
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDCATALOG
-----------------------------------------------------------------------------------------------------------------------------------------
function BuildCatalog(gender)
    local zones = Tattoos.Catalog[gender] or {}
    local available = {}

    for _, zone in ipairs(Tattoos.Zones) do
        local list = zones[zone.key] or {}
        local entries = {}

        for index, entry in ipairs(list) do
            entries[index] = {
                name = entry[1],
                part = entry[2],
                link = Customization.Images.Tattoos..gender.."/"..entry[1]..".png",
            }
        end

        available[zone.key] = entries
    end

    return available
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ACTIVENAMES
-----------------------------------------------------------------------------------------------------------------------------------------
function ActiveNames(tattoos)
    local names = {}

    for name in pairs(tattoos or {}) do
        names[#names + 1] = name
    end

    return names
end
