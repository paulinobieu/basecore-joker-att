-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local AddEventHandler = AddEventHandler
local CreateThread = CreateThread
local GetCurrentResourceName = GetCurrentResourceName
local RegisterNetEvent = RegisterNetEvent
local SetNuiFocus = SetNuiFocus
local ipairs = ipairs
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDCLOTHESSHOP
-----------------------------------------------------------------------------------------------------------------------------------------
local function AddClothesShop(coords)
    Framework.CreateShopPoint(coords, L("clothesLabel"), function()
        RequestClothes(false)
    end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDTATTOOSHOP
-----------------------------------------------------------------------------------------------------------------------------------------
local function AddTattooShop(coords)
    Framework.CreateShopPoint(coords, L("tattooLabel"), function()
        RequestTattoos()
    end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION:ADDCLOTHESSHOP
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-customization:addClothesShop", function(coords)
    if not Customization.Features.ClothesShop then return end

    Customization.ClothesShops[#Customization.ClothesShops + 1] = coords
    AddClothesShop(coords)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION:ADDTATTOOSHOP
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-customization:addTattooShop", function(coords)
    if not Customization.Features.TattooShop then return end

    Customization.TattooShops[#Customization.TattooShops + 1] = coords
    AddTattooShop(coords)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION:REQUESTCLOTHES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-customization:requestClothes", function()
    RequestClothes(false)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION:REQUESTTATTOOS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-customization:requestTattoos", function()
    RequestTattoos()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION:SETPARTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-customization:setParts", function(parts)
    PreviewClothes(parts)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION:TOGGLEPART
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-customization:togglePart", function(part)
    SwapPart(part)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION:APPLYOUTFIT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-customization:applyOutfit", function(outfit)
    if type(outfit) ~= "table" then return end

    CurrentClothes = CopyClothes(outfit.clothes)
    CurrentTattoos = CopyTattoos(outfit.tattoos)

    WearClothes(CurrentClothes)
    WearTattoos(CurrentTattoos)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SHOPPOINTS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    if Customization.Features.ClothesShop then
        for _, coords in ipairs(Customization.ClothesShops) do
            AddClothesShop(coords)
        end
    end

    if Customization.Features.TattooShop then
        for _, coords in ipairs(Customization.TattooShops) do
            AddTattooShop(coords)
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXPORTS
-----------------------------------------------------------------------------------------------------------------------------------------
exports("GetClothes", function()
    return CurrentClothes
end)

exports("GetTattoos", function()
    return CurrentTattoos
end)

exports("ChangePart", function(part, item, texture, save)
    return ChangePart(part, item, texture, save ~= false)
end)

exports("TogglePart", function(part, put, otherPed)
    return TogglePart(part, put, otherPed)
end)

exports("ListParts", function()
    return ListParts()
end)

exports("IsLocked", function()
    return ClothesLocked
end)

exports("IsOpen", function()
    return InClothes or InTattoos
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ONCLIENTRESOURCESTOP
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onClientResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if not InClothes and not InTattoos then return end

    SetNuiFocus(false, false)
    DestroyShopCam()
    Framework.Close()
end)
