-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local CreatePed = CreatePed
local CreateThread = CreateThread
local DeleteEntity = DeleteEntity
local GetHashKey = GetHashKey
local GetNumberOfPedDrawableVariations = GetNumberOfPedDrawableVariations
local GetNumberOfPedPropDrawableVariations = GetNumberOfPedPropDrawableVariations
local GetNumberOfPedPropTextureVariations = GetNumberOfPedPropTextureVariations
local GetNumberOfPedTextureVariations = GetNumberOfPedTextureVariations
local HasModelLoaded = HasModelLoaded
local RequestModel = RequestModel
local SetModelAsNoLongerNeeded = SetModelAsNoLongerNeeded
local Wait = Wait
local pairs = pairs
local tostring = tostring
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local MeasurePoint = {
    ["mp_m_freemode_01"] = { -146.47, -871.25, 29.83, 119.35 },
    ["mp_f_freemode_01"] = { -143.32, -875.47, 29.73, 120.28 },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- MEASUREMODEL
-----------------------------------------------------------------------------------------------------------------------------------------
local function MeasureModel(model, gender)
    local hash = GetHashKey(model)
    local spawn = MeasurePoint[model]

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(10)
    end

    local ped = CreatePed(4, hash, spawn[1], spawn[2], spawn[3], spawn[4], false, true)
    local catalog = {}

    for part, entry in pairs(Clothes.Parts) do
        local variants = {}

        if entry.negative then
            variants["-1"] = {
                image = Customization.Images.Clothes..gender.."/"..part.."/-1.jpg",
                max = 0,
            }
        end

        local total = entry.prop
            and GetNumberOfPedPropDrawableVariations(ped, entry.id)
            or GetNumberOfPedDrawableVariations(ped, entry.id)

        for index = 0, total - 1 do
            if not Clothes.IsHidden(gender, part, index) then
                local textures = entry.prop
                    and GetNumberOfPedPropTextureVariations(ped, entry.id, index)
                    or GetNumberOfPedTextureVariations(ped, entry.id, index)

                variants[tostring(index)] = {
                    image = Customization.Images.Clothes..gender.."/"..part.."/"..index..".jpg",
                    max = textures - 1,
                }
            end
        end

        catalog[part] = variants
    end

    DeleteEntity(ped)
    SetModelAsNoLongerNeeded(hash)

    return catalog
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CATALOG
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    local catalog = {
        Male = MeasureModel("mp_m_freemode_01", "Male"),
        Female = MeasureModel("mp_f_freemode_01", "Female"),
    }

    while not NUIReady do
        Wait(500)
    end

    SendInterfaceMessage("textures", catalog)
end)
