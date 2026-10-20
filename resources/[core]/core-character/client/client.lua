-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local AddEventHandler = AddEventHandler
local CreateThread = CreateThread
local DoesParticleFxLoopedExist = DoesParticleFxLoopedExist
local GetCurrentResourceName = GetCurrentResourceName
local GetGameTimer = GetGameTimer
local HasNamedPtfxAssetLoaded = HasNamedPtfxAssetLoaded
local RequestNamedPtfxAsset = RequestNamedPtfxAsset
local SetParticleFxLoopedColour = SetParticleFxLoopedColour
local StartParticleFxLoopedAtCoord = StartParticleFxLoopedAtCoord
local StopParticleFxLooped = StopParticleFxLooped
local UseParticleFxAssetNextCall = UseParticleFxAssetNextCall
local Wait = Wait
local ipairs = ipairs
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local SmokeEffects = {}

local SMOKE_ASSET = "scr_ba_club"
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPAWNSMOKE
-----------------------------------------------------------------------------------------------------------------------------------------
local function SpawnSmoke(effectName, list, rotation, scale)
    for _, coords in ipairs(list) do
        UseParticleFxAssetNextCall(SMOKE_ASSET)

        local effect = StartParticleFxLoopedAtCoord(effectName,
            coords[1], coords[2], coords[3],
            rotation[1], rotation[2], rotation[3],
            scale, false, false, false, false
        )

        if DoesParticleFxLoopedExist(effect) then
            SetParticleFxLoopedColour(effect, 255.0, 255.0, 255.0, false)
            SmokeEffects[#SmokeEffects + 1] = effect
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SMOKE
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    local club = Character.Smoke.Club
    local machines = Character.Smoke.Machines

    if #club == 0 and #machines == 0 then return end

    RequestNamedPtfxAsset(SMOKE_ASSET)

    local timeout = GetGameTimer() + 10000

    while not HasNamedPtfxAssetLoaded(SMOKE_ASSET) and GetGameTimer() < timeout do
        Wait(0)
    end

    if not HasNamedPtfxAssetLoaded(SMOKE_ASSET) then return end

    SpawnSmoke("scr_ba_club_smoke", club, { 0.0, 0.0, 0.0 }, 1.0)
    SpawnSmoke("scr_ba_club_smoke_machine", machines, { 0.0, -10.0, 158.0 }, 8.0)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ONRESOURCESTOP
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onResourceStop", function(resource)
    if resource ~= GetCurrentResourceName() then return end

    CloseScreen()
    DestroyCreatorCam()

    for _, effect in ipairs(SmokeEffects) do
        StopParticleFxLooped(effect, false)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENBARBER
-----------------------------------------------------------------------------------------------------------------------------------------
exports("OpenBarber", function()
    RequestBarber()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ISOPEN
-----------------------------------------------------------------------------------------------------------------------------------------
exports("IsOpen", function()
    return NUIOpen
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CURRENTSCREEN
-----------------------------------------------------------------------------------------------------------------------------------------
exports("CurrentScreen", function()
    return CurrentScreen
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETAPPEARANCE
-----------------------------------------------------------------------------------------------------------------------------------------
exports("GetAppearance", function()
    return CurrentAppearance
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- APPLYAPPEARANCE
-----------------------------------------------------------------------------------------------------------------------------------------
exports("ApplyAppearance", function(appearance)
    CurrentAppearance = CopyAppearance(appearance)
    ApplyAppearance(CurrentAppearance)

    return true
end)
