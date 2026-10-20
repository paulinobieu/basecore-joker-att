-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local AddEventHandler = AddEventHandler
local ClearFocus = ClearFocus
local CreateCamWithParams = CreateCamWithParams
local CreateThread = CreateThread
local DestroyCam = DestroyCam
local DoScreenFadeIn = DoScreenFadeIn
local DoScreenFadeOut = DoScreenFadeOut
local DoesCamExist = DoesCamExist
local FreezeEntityPosition = FreezeEntityPosition
local GetActivePlayers = GetActivePlayers
local GetCurrentResourceName = GetCurrentResourceName
local GetGameTimer = GetGameTimer
local GetHashKey = GetHashKey
local GetNumberOfPedDrawableVariations = GetNumberOfPedDrawableVariations
local GetPlayerPed = GetPlayerPed
local HasAnimDictLoaded = HasAnimDictLoaded
local HasModelLoaded = HasModelLoaded
local InvalidateIdleCam = InvalidateIdleCam
local NetworkResurrectLocalPlayer = NetworkResurrectLocalPlayer
local NetworkOverrideClockTime = NetworkOverrideClockTime
local PlayerId = PlayerId
local PlayerPedId = PlayerPedId
local RegisterNetEvent = RegisterNetEvent
local RenderScriptCams = RenderScriptCams
local RequestAnimDict = RequestAnimDict
local RequestModel = RequestModel
local SetCamActive = SetCamActive
local SetEntityCoords = SetEntityCoords
local SetEntityNoCollisionEntity = SetEntityNoCollisionEntity
local SetEntityVisible = SetEntityVisible
local SetFocusPosAndVel = SetFocusPosAndVel
local SetModelAsNoLongerNeeded = SetModelAsNoLongerNeeded
local SetPlayerModel = SetPlayerModel
local SetWeatherTypeNowPersist = SetWeatherTypeNowPersist
local ShutdownLoadingScreen = ShutdownLoadingScreen
local ShutdownLoadingScreenNui = ShutdownLoadingScreenNui
local TaskPlayAnim = TaskPlayAnim
local TriggerServerEvent = TriggerServerEvent
local Wait = Wait
local ipairs = ipairs
local math_random = math.random
local type = type
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local SelectCam = nil
-----------------------------------------------------------------------------------------------------------------------------------------
-- REPORTHAIRCOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
local function ReportHairCount(model)
    local hash = GetHashKey(model)

    RequestModel(hash)

    local timeout = GetGameTimer() + 10000

    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(10)
    end

    if not HasModelLoaded(hash) then return end

    SetPlayerModel(PlayerId(), hash)
    SetModelAsNoLongerNeeded(hash)
    FreezeEntityPosition(PlayerPedId(), false)

    TriggerServerEvent("core-character:reportHairs", model, GetNumberOfPedDrawableVariations(PlayerPedId(), 2) - 1)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYRANDOMPOSE
-----------------------------------------------------------------------------------------------------------------------------------------
local function PlayRandomPose(ped)
    local anim = Appearance.SelectAnims[math_random(1, #Appearance.SelectAnims)]

    RequestAnimDict(anim[1])

    local timeout = GetGameTimer() + 5000

    while not HasAnimDictLoaded(anim[1]) and GetGameTimer() < timeout do
        RequestAnimDict(anim[1])
        Wait(10)
    end

    -- Pose que não carregou não pode segurar a tela: o personagem fica parado
    -- em vez de a seleção nunca abrir.
    FreezeEntityPosition(ped, true)

    if not HasAnimDictLoaded(anim[1]) then return end

    TaskPlayAnim(ped, anim[1], anim[2], 3.0, 3.0, -1, 1, 0, false, false, false)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HIDEOTHERPLAYERS
-----------------------------------------------------------------------------------------------------------------------------------------
function HideOtherPlayers()
    local ped = PlayerPedId()

    for _, player in ipairs(GetActivePlayers()) do
        local other = GetPlayerPed(player)

        if ped ~= other then
            SetEntityVisible(other, false, false)
            SetEntityNoCollisionEntity(ped, other, true)
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PREPARESELECTSCENE
-----------------------------------------------------------------------------------------------------------------------------------------
local function PrepareSelectScene()
    local scene = Character.Scene
    local camera = scene.SelectCamera

    SelectCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA",
        camera[1], camera[2], camera[3],
        camera[4], camera[5], camera[6],
        camera[7], true, 2
    )

    SetCamActive(SelectCam, true)
    RenderScriptCams(true, false, 1, true, true)

    LoadIpl(scene.SelectIpl)

    local coords = scene.SelectCoords

    NetworkResurrectLocalPlayer(coords[1], coords[2], coords[3] - 0.98, coords[4], true, true, false)
    SetFocusPosAndVel(coords[1], coords[2], coords[3], 0.0, 0.0, 0.0)
    SetEntityCoords(PlayerPedId(), coords[1], coords[2], coords[3] - 0.98)
    SetEntityVisible(PlayerPedId(), true, false)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTSELECT
-----------------------------------------------------------------------------------------------------------------------------------------
function RequestSelect()
    InSelect = true

    TriggerServerEvent("core-character:requestRouting")

    SetWeatherTypeNowPersist("CLEAR")
    NetworkOverrideClockTime(0, 0, 0)

    DoScreenFadeOut(1000)

    local timeout = GetGameTimer() + 15000

    while not NUIUnlocked and GetGameTimer() < timeout do
        Wait(200)
    end

    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()

    if not NUIUnlocked then
        print("[core-character] A NUI não confirmou o carregamento em 15 segundos; continuando sem bloquear o jogador.")
    end

    SendServerAction("requestSelect")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CHARACTER:OPENSELECT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-character:openSelect", function(preview)
    PrepareSelectScene()
    ApplyPreview(preview)

    Wait(1000)
    DoScreenFadeIn(1000)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- APPLYPREVIEW
-----------------------------------------------------------------------------------------------------------------------------------------
function ApplyPreview(preview)
    local ped = PlayerPedId()

    if type(preview) == "table" then
        if preview.model then
            Framework.ApplySkin(preview.model)
            ped = PlayerPedId()
        end

        if type(preview.chardata) == "table" then
            CurrentAppearance = CopyAppearance(preview.chardata)
            ApplyAppearance(CurrentAppearance, ped)
        end

        if preview.clothes then Framework.ApplyClothes(preview.clothes) end
        if preview.tattoos then Framework.ApplyTattoos(preview.tattoos) end
    end

    PlayRandomPose(ped)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CHARACTER:PREVIEWCHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-character:previewCharacter", function(preview)
    ApplyPreview(preview)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSESELECT
-----------------------------------------------------------------------------------------------------------------------------------------
function CloseSelect()
    InSelect = false

    RenderScriptCams(false, false, 0, true, true)

    if DoesCamExist(SelectCam) then
        SetCamActive(SelectCam, false)
        DestroyCam(SelectCam, true)
    end

    SelectCam = nil
    ClearFocus()
    CloseScreen()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ONCLIENTRESOURCESTART
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onClientResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    ReportHairCount("mp_f_freemode_01")
    ReportHairCount("mp_m_freemode_01")

    Framework.Close()
    RequestSelect()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HIDEPLAYERS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    while true do
        if InSelect or InCreator or InBarber then
            HideOtherPlayers()
            InvalidateIdleCam()
            Wait(1)
        else
            Wait(500)
        end
    end
end)
