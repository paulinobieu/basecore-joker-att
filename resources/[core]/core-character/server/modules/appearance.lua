-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local RegisterNetEvent = RegisterNetEvent
local ipairs = ipairs
local pairs = pairs
local tonumber = tonumber
local tostring = tostring
local type = type
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local HairCount = { Male = 0, Female = 0 }
local HairSynced = false

GlobalState["CharacterHairs"] = { Male = {}, Female = {} }
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDHAIRLIST
-----------------------------------------------------------------------------------------------------------------------------------------
local function HiddenHairs(gender)
    local hidden = {}

    for _, entry in ipairs(Appearance.HiddenHairs[gender] or {}) do
        local first, last = tostring(entry):match("^(%d+)%-(%d+)$")

        if first then
            for index = tonumber(first), tonumber(last) do
                hidden[index] = true
            end
        else
            local single = tonumber(entry)
            if single then hidden[single] = true end
        end
    end

    return hidden
end

local function BuildHairList(gender, total)
    local hidden = HiddenHairs(gender)
    local list = {}

    for index = 0, total do
        if not hidden[index] then
            list[#list + 1] = {
                index = index,
                image = ("%s/%s/%d.png"):format(Character.Images.Hair, gender, index),
            }
        end
    end

    return list
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYNCHAIRS
-----------------------------------------------------------------------------------------------------------------------------------------
function SyncHairs()
    if HairSynced then return end
    if HairCount.Male <= 0 or HairCount.Female <= 0 then return end

    GlobalState:set("CharacterHairs", {
        Male   = BuildHairList("Male", HairCount.Male),
        Female = BuildHairList("Female", HairCount.Female),
    }, true)

    HairSynced = true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CHARACTER:REPORTHAIRS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-character:reportHairs", function(model, total)
    if HairSynced then return end

    total = ValidateNumber(total, 0, 20000, 0)
    if total <= 0 then return end

    if model == "mp_m_freemode_01" then
        HairCount.Male = total
    elseif model == "mp_f_freemode_01" then
        HairCount.Female = total
    else
        return
    end

    SyncHairs()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SANITIZEAPPEARANCE
-----------------------------------------------------------------------------------------------------------------------------------------
function SanitizeAppearance(appearance)
    if type(appearance) ~= "table" then return nil end

    local clean = {}
    for key, fallback in pairs(Appearance.Default) do
        local value = tonumber(appearance[key])
        clean[key] = value or fallback
    end

    return clean
end
