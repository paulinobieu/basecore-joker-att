-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local CreateThread = CreateThread
local FreezeEntityPosition = FreezeEntityPosition
local PlayerPedId = PlayerPedId
local RegisterNetEvent = RegisterNetEvent
local TriggerServerEvent = TriggerServerEvent
local ipairs = ipairs
local type = type
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENBARBER
-----------------------------------------------------------------------------------------------------------------------------------------
function OpenBarber(appearance)
    if InBarber or InCreator or InSelect or InSpawn then return end

    InBarber = true
    CurrentAppearance = CopyAppearance(appearance)

    local ped = PlayerPedId()

    FreezeEntityPosition(ped, true)
    PlayPose("idle")
    CreateCreatorCam(1)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSEBARBER
-----------------------------------------------------------------------------------------------------------------------------------------
function CloseBarber()
    if not InBarber then return end

    InBarber = false

    FreezeEntityPosition(PlayerPedId(), false)
    StopPose()

    DestroyCreatorCam()
    CloseScreen()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTBARBER
-----------------------------------------------------------------------------------------------------------------------------------------
function RequestBarber()
    if InBarber or InCreator or InSelect or InSpawn then return end

    TriggerServerEvent("core-character:requestBarber")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CHARACTER:OPENBARBER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-character:openBarber", function(appearance)
    OpenBarber(appearance)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REGISTERBARBERPOINT
-----------------------------------------------------------------------------------------------------------------------------------------
local function RegisterBarberPoint(locate)
    if type(locate) ~= "table" or #locate < 3 then return end

    Framework.CreateBarberPoint(vector3(locate[1], locate[2], locate[3]), L("barberLabel"), RequestBarber)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CHARACTER:ADDBARBER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-character:addBarber", function(locate)
    Character.BarberLocations[#Character.BarberLocations + 1] = locate
    RegisterBarberPoint(locate)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BARBERPOINTS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    if not Character.Features.Barber then return end

    for _, locate in ipairs(Character.BarberLocations) do
        RegisterBarberPoint(locate)
    end
end)
