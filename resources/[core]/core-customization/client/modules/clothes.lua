-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local ClearPedProp = ClearPedProp
local GetEntityHealth = GetEntityHealth
local GetNumberOfPedDrawableVariations = GetNumberOfPedDrawableVariations
local GetNumberOfPedPropDrawableVariations = GetNumberOfPedPropDrawableVariations
local GetPedDrawableVariation = GetPedDrawableVariation
local GetPedPropIndex = GetPedPropIndex
local GetPedPropTextureIndex = GetPedPropTextureIndex
local GetPedTextureVariation = GetPedTextureVariation
local PlayerPedId = PlayerPedId
local RegisterNetEvent = RegisterNetEvent
local SetPedComponentVariation = SetPedComponentVariation
local SetPedPropIndex = SetPedPropIndex
local Wait = Wait
local ipairs = ipairs
local pairs = pairs
local sort = table.sort
local type = type
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEARPART
-----------------------------------------------------------------------------------------------------------------------------------------
local function WearPart(ped, part, item, texture)
    local entry = Clothes.Parts[part]
    if not entry then return end

    item, texture = Int(item), Int(texture)

    if entry.prop then
        if item == -1 then
            ClearPedProp(ped, entry.id)
        else
            SetPedPropIndex(ped, entry.id, item, texture, true)
        end

        return
    end

    SetPedComponentVariation(ped, entry.id, item, 0, 1)
    SetPedComponentVariation(ped, entry.id, GetPedDrawableVariation(ped, entry.id), texture, 1)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEARCLOTHES
-----------------------------------------------------------------------------------------------------------------------------------------
function WearClothes(clothes, otherPed)
    local ped = otherPed or PlayerPedId()

    for part in pairs(Clothes.Parts) do
        local entry = clothes and clothes[part]

        if type(entry) == "table" then
            WearPart(ped, part, entry.item, entry.texture)
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PREVIEWCLOTHES
-----------------------------------------------------------------------------------------------------------------------------------------
function PreviewClothes(config)
    if type(config) ~= "table" then return false end

    local ped = PlayerPedId()
    local model = PlayerModel(ped)

    for part, entry in pairs(config) do
        if Clothes.Parts[part] and type(entry) == "table" then
            local item = Int(entry.item)

            if not Clothes.IsBlocked(part, item, model) then
                local texture = Int(entry.texture)

                WearPart(ped, part, item, texture)
                CurrentClothes[part] = { item = item, texture = texture }
            end
        end
    end

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- READCLOTHES
-----------------------------------------------------------------------------------------------------------------------------------------
function ReadClothes()
    local ped = PlayerPedId()
    local config = {}

    for _, region in ipairs(Clothes.Regions) do
        config[region] = {}
    end

    for part, entry in pairs(Clothes.Parts) do
        local item, texture, maxItem

        if entry.prop then
            item = GetPedPropIndex(ped, entry.id)
            texture = GetPedPropTextureIndex(ped, entry.id)
            maxItem = GetNumberOfPedPropDrawableVariations(ped, entry.id) - 1
        else
            item = GetPedDrawableVariation(ped, entry.id)
            texture = GetPedTextureVariation(ped, entry.id)
            maxItem = GetNumberOfPedDrawableVariations(ped, entry.id) - 1
        end

        CurrentClothes[part] = { item = item, texture = texture }

        config[entry.region][part] = {
            item = item,
            texture = texture,
            negative = entry.negative,
            infos = {
                name = entry.name,
                icon = entry.icon,
                maxItem = maxItem,
                maxTex = 25,
            },
        }
    end

    return config
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHANGEPART
-----------------------------------------------------------------------------------------------------------------------------------------
function ChangePart(part, item, texture, save)
    local entry = Clothes.Parts[part]
    if not entry then return nil end

    local ped = PlayerPedId()
    if GetEntityHealth(ped) <= 101 then return nil end

    local model = PlayerModel(ped)
    local gender = PlayerGender(ped)

    if item and (Clothes.IsHidden(gender, part, item) or Clothes.IsBlocked(part, item, model)) then
        Notify(L("clothesBlocked"), "error")
        return nil
    end

    if ClothesLocked then
        Notify(L("clothesLocked"), "error")
        return nil
    end

    if entry.anim then
        Framework.PlayAnim(entry.anim)
        Wait(entry.anim[3])
    end

    if item == nil then
        item, texture = Clothes.DefaultOf(part, model), 0
    end

    WearPart(ped, part, item, texture)
    CurrentClothes[part] = { item = Int(item), texture = Int(texture) }

    if save then
        SendServerAction("saveClothes", { clothes = CurrentClothes })
    end

    Framework.StopAnim()

    return CurrentClothes[part]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOGGLEPART
-----------------------------------------------------------------------------------------------------------------------------------------
function TogglePart(part, put, otherPed)
    local entry = Clothes.Parts[part]
    local stored = CurrentClothes[part]

    if not entry or not stored then return false end

    if ClothesLocked then
        Notify(L("clothesLocked"), "error")
        return false
    end

    local ped = otherPed or PlayerPedId()

    if entry.anim and not otherPed then
        Framework.PlayAnim(entry.anim)
        Wait(entry.anim[3])
    end

    if put then
        WearPart(ped, part, stored.item, stored.texture)
    else
        WearPart(ped, part, Clothes.DefaultOf(part, PlayerModel(ped)), 0)
    end

    Framework.StopAnim()

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SWAPPART
-----------------------------------------------------------------------------------------------------------------------------------------
function SwapPart(part)
    local entry = Clothes.Parts[part]
    local stored = CurrentClothes[part]

    if not entry or not stored then return false end

    local ped = PlayerPedId()
    local default = Clothes.DefaultOf(part, PlayerModel(ped))

    local current = entry.prop
        and GetPedPropIndex(ped, entry.id)
        or GetPedDrawableVariation(ped, entry.id)

    if current ~= default then
        return TogglePart(part, false)
    end

    if stored.item == default then return false end

    return TogglePart(part, true)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LISTPARTS
-----------------------------------------------------------------------------------------------------------------------------------------
function ListParts()
    local ped = PlayerPedId()
    local model = PlayerModel(ped)
    local list = {}

    for part, entry in pairs(Clothes.Parts) do
        local current = entry.prop
            and GetPedPropIndex(ped, entry.id)
            or GetPedDrawableVariation(ped, entry.id)

        list[#list + 1] = {
            index = part,
            name = entry.name,
            icon = entry.icon,
            worn = current ~= Clothes.DefaultOf(part, model),
        }
    end

    sort(list, function(a, b) return a.name < b.name end)

    return list
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION:CHANGEPART
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-customization:changePart", function(part, item, texture)
    ChangePart(part, item, texture, true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION:WEARCLOTHES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-customization:wearClothes", function(clothes)
    CurrentClothes = CopyClothes(clothes)
    WearClothes(CurrentClothes)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION:RELOADCLOTHES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-customization:reloadClothes", function()
    SendServerAction("requestOutfit")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION:APPLYTEMPORARY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-customization:applyTemporary", function(clothes)
    PreviousClothes = CopyClothes(CurrentClothes)

    CurrentClothes = CopyClothes(clothes)
    WearClothes(CurrentClothes)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION:RETURNTEMPORARY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-customization:returnTemporary", function()
    if not PreviousClothes then return end

    CurrentClothes = PreviousClothes
    PreviousClothes = nil

    WearClothes(CurrentClothes)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION:OVERLAYCLOTHES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-customization:overlayClothes", function(parts, otherPed)
    if type(parts) ~= "table" then return end

    local merged = CopyClothes(CurrentClothes)

    for part, entry in pairs(parts) do
        if Clothes.Parts[part] and type(entry) == "table" then
            merged[part] = { item = Int(entry.item), texture = Int(entry.texture) }
        end
    end

    WearClothes(merged, otherPed)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION:LOCKCLOTHES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-customization:lockClothes", function(state)
    ClothesLocked = state and true or false
end)
