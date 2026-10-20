-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local ipairs = ipairs
local pairs = pairs
local tonumber = tonumber
local type = type
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
Clothes.Regions = { "head", "chest", "legs" }

local HiddenIndexes = nil
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXPANDHIDDEN
-----------------------------------------------------------------------------------------------------------------------------------------
local function ExpandHidden()
    local expanded = {}

    for gender, parts in pairs(Clothes.Hidden) do
        expanded[gender] = {}

        for part, ranges in pairs(parts) do
            local indexes = {}

            for _, entry in ipairs(ranges) do
                local first, last = tostring(entry):match("^(%-?%d+)%-(%d+)$")

                if first then
                    for index = tonumber(first), tonumber(last) do
                        indexes[index] = true
                    end
                else
                    local single = tonumber(entry)
                    if single then indexes[single] = true end
                end
            end

            expanded[gender][part] = indexes
        end
    end

    return expanded
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ISHIDDEN
-----------------------------------------------------------------------------------------------------------------------------------------
function Clothes.IsHidden(gender, part, item)
    HiddenIndexes = HiddenIndexes or ExpandHidden()

    local parts = HiddenIndexes[gender]
    if not parts or not parts[part] then return false end

    return parts[part][tonumber(item) or -1] == true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ISBLOCKED
-----------------------------------------------------------------------------------------------------------------------------------------
function Clothes.IsBlocked(part, item, model)
    local indexes = Clothes.Blocked[part]
    if not indexes then return false end

    local models = indexes[tonumber(item) or -1]
    if not models then return false end

    return models[model] == true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DEFAULTOF
-----------------------------------------------------------------------------------------------------------------------------------------
function Clothes.DefaultOf(part, model)
    local entry = Clothes.Parts[part]
    if not entry then return 0 end

    if type(entry.default) == "table" then
        return entry.default[model] or 0
    end

    return entry.default or 0
end
