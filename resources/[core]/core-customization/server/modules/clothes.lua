-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local TriggerClientEvent = TriggerClientEvent
local pairs = pairs
local type = type
-----------------------------------------------------------------------------------------------------------------------------------------
-- CANCUSTOMIZE
-----------------------------------------------------------------------------------------------------------------------------------------
local function CanCustomize(src, userId)
    return Framework.CanCustomize(src, userId) == true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ISADMIN
-----------------------------------------------------------------------------------------------------------------------------------------
function IsAdmin(userId, level)
    return Framework.HasGroup(userId, Customization.AdminPermission, level)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENCLOTHESSHOP
-----------------------------------------------------------------------------------------------------------------------------------------
function OpenClothesShop(src, userId)
    if not Customization.Features.ClothesShop then return false end
    if not CanCustomize(src, userId) then return false end

    TriggerClientEvent("core-customization:openClothes", src, {
        admin = IsAdmin(userId, Customization.AdminLevels.Shop),
    })

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTCLOTHES
-----------------------------------------------------------------------------------------------------------------------------------------
function Handlers.requestClothes(src, userId)
    OpenClothesShop(src, userId)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTOUTFIT
-----------------------------------------------------------------------------------------------------------------------------------------
function Handlers.requestOutfit(src, userId)
    TriggerClientEvent("core-customization:applyOutfit", src, LoadOutfit(userId))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAVECLOTHES
-----------------------------------------------------------------------------------------------------------------------------------------
function Handlers.saveClothes(src, userId, data)
    if type(data) ~= "table" then return end

    SaveOutfit(userId, data.clothes, nil)

    Framework.Notify(src, L("clothesSaved"), "success")
    CoreLog("CUSTOMIZATION_CLOTHES", { playerName = UserName(userId), playerId = userId })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHANGEPART
-----------------------------------------------------------------------------------------------------------------------------------------
function ChangePart(src, userId, part, item, texture)
    if not Customization.Features.PartCommands then return end
    if not Clothes.Parts[part] then return end

    local required = Customization.PartCommandItem

    if required ~= "" then
        local allowed = Framework.ItemAmount(userId, required) >= 1
            or Framework.HasPremium(userId)

        if not allowed then
            return Framework.Notify(src, L("clothesNoItem"), "error")
        end
    end

    if not CanCustomize(src, userId) then return end

    TriggerClientEvent("core-customization:changePart", src, part, item, texture)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDPRESET
-----------------------------------------------------------------------------------------------------------------------------------------
function BuildPreset(userId)
    local outfit = LoadOutfit(userId)
    local content = ""

    for command, part in pairs(Customization.PartCommands) do
        local entry = outfit.clothes[part]

        if entry then
            content = content..command.." "..entry.item.." "..entry.texture.."; "
        end
    end

    return content
end
