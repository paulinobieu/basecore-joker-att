-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local TriggerClientEvent = TriggerClientEvent
local type = type
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENTATTOOSHOP
-----------------------------------------------------------------------------------------------------------------------------------------
function OpenTattooShop(src, userId)
    if not Customization.Features.TattooShop then return false end
    if not Framework.CanCustomize(src, userId) then return false end

    local gender = GenderOf(Framework.Model(src))
    local outfit = LoadOutfit(userId)

    TriggerClientEvent("core-customization:openTattoos", src, {
        admin = IsAdmin(userId, Customization.AdminLevels.Shop),
        available = BuildCatalog(gender),
        active = ActiveNames(outfit.tattoos),
    })

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTTATTOOS
-----------------------------------------------------------------------------------------------------------------------------------------
function Handlers.requestTattoos(src, userId)
    OpenTattooShop(src, userId)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAVETATTOOS
-----------------------------------------------------------------------------------------------------------------------------------------
function Handlers.saveTattoos(src, userId, data)
    if type(data) ~= "table" then return end

    local tattoos = SanitizeTattoos(data.tattoos)

    SaveOutfit(userId, nil, tattoos)

    Framework.Notify(src, L("tattooSaved"), "success")

    CoreLog("CUSTOMIZATION_TATTOOS", {
        playerName = UserName(userId),
        playerId = userId,
        amount = #ActiveNames(tattoos),
    })
end
