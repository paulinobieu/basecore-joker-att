-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local AddPedDecorationFromHashes = AddPedDecorationFromHashes
local ClearPedDecorations = ClearPedDecorations
local GetHashKey = GetHashKey
local PlayerPedId = PlayerPedId
local RegisterNetEvent = RegisterNetEvent
local pairs = pairs
local type = type
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEARTATTOOS
-----------------------------------------------------------------------------------------------------------------------------------------
function WearTattoos(tattoos, otherPed)
    local ped = otherPed or PlayerPedId()

    ClearPedDecorations(ped)

    for name, part in pairs(tattoos or {}) do
        local collection = type(part) == "table" and part[1] or part

        if collection then
            AddPedDecorationFromHashes(ped, GetHashKey(collection), GetHashKey(name))
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOGGLETATTOO
-----------------------------------------------------------------------------------------------------------------------------------------
function ToggleTattoo(name, collection)
    if CurrentTattoos[name] then
        CurrentTattoos[name] = nil
    else
        CurrentTattoos[name] = { collection }
    end

    WearTattoos(CurrentTattoos)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION:WEARTATTOOS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-customization:wearTattoos", function(tattoos)
    CurrentTattoos = CopyTattoos(tattoos)
    WearTattoos(CurrentTattoos)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION:RETURNTATTOOS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-customization:returnTattoos", function()
    if not BackupTattoos then return end

    CurrentTattoos = BackupTattoos
    BackupTattoos = nil

    WearTattoos(CurrentTattoos)
end)
