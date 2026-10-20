-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local ClearPedProp = ClearPedProp
local CreatePed = CreatePed
local DeleteEntity = DeleteEntity
local DoScreenFadeIn = DoScreenFadeIn
local DoScreenFadeOut = DoScreenFadeOut
local FinalizeHeadBlend = FinalizeHeadBlend
local GetEntityModel = GetEntityModel
local GetGameTimer = GetGameTimer
local HasCutsceneLoaded = HasCutsceneLoaded
local IsEntityDead = IsEntityDead
local NetworkSetEntityInvisibleToNetwork = NetworkSetEntityInvisibleToNetwork
local NewLoadSceneStartSphere = NewLoadSceneStartSphere
local NewLoadSceneStop = NewLoadSceneStop
local PlayerPedId = PlayerPedId
local PrepareMusicEvent = PrepareMusicEvent
local RegisterEntityForCutscene = RegisterEntityForCutscene
local RemoveCutscene = RemoveCutscene
local RequestCutsceneWithPlaybackList = RequestCutsceneWithPlaybackList
local SetCutsceneEntityStreamingFlags = SetCutsceneEntityStreamingFlags
local SetPedComponentVariation = SetPedComponentVariation
local SetWeatherTypeNow = SetWeatherTypeNow
local StartCutscene = StartCutscene
local StopCutscene = StopCutscene
local StopCutsceneImmediately = StopCutsceneImmediately
local TriggerMusicEvent = TriggerMusicEvent
local Wait = Wait
local ipairs = ipairs
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local SCENE_COORDS = { -1117.77, -1557.62, 3.38 }
local SCENE_SPHERE = { -1212.79, -1673.52, 7.0 }
local SCENE_DURATION = 25000
-----------------------------------------------------------------------------------------------------------------------------------------
-- DRESSEXTRA
-----------------------------------------------------------------------------------------------------------------------------------------
local function DressExtra(ped, slot)
    local outfit = Appearance.Cutscene.Outfits[slot]
    if not outfit then return end

    for _, component in ipairs(outfit) do
        SetPedComponentVariation(ped, component[1], component[2], component[3], 0)
    end

    for index = 0, 8 do
        ClearPedProp(ped, index)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REGISTERPLAYER
-----------------------------------------------------------------------------------------------------------------------------------------
local function RegisterPlayer(ped)
    local own = IsMale(ped) and "MP_Male_Character" or "MP_Female_Character"
    local other = IsMale(ped) and "MP_Female_Character" or "MP_Male_Character"

    RegisterEntityForCutscene(0, own, 3, GetEntityModel(ped), 0)
    RegisterEntityForCutscene(ped, own, 0, 0, 0)
    SetCutsceneEntityStreamingFlags(own, 0, 1)

    local hidden = RegisterEntityForCutscene(0, other, 3, 0, 64)
    NetworkSetEntityInvisibleToNetwork(hidden, true)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STARTARRIVALCUTSCENE
-----------------------------------------------------------------------------------------------------------------------------------------
function StartArrivalCutscene()
    local ped = PlayerPedId()

    PrepareMusicEvent("FM_INTRO_START")
    TriggerMusicEvent("FM_INTRO_START")

    RequestCutsceneWithPlaybackList("MP_INTRO_CONCAT", IsMale(ped) and 31 or 103, 8)

    local timeout = GetGameTimer() + 15000

    while not HasCutsceneLoaded() and GetGameTimer() < timeout do
        Wait(1)
    end

    -- Cutscene que não carregou pula direto para o fim do fluxo; travar aqui
    -- deixaria o jogador na tela preta para sempre.
    if not HasCutsceneLoaded() then
        PrepareMusicEvent("AC_STOP")
        TriggerMusicEvent("AC_STOP")

        return SpawnAfterCreate()
    end

    RegisterPlayer(ped)

    local extras = {}

    for slot = 0, 6 do
        local model = Appearance.Cutscene.FemaleSlots[slot] and "mp_f_freemode_01" or "mp_m_freemode_01"
        local extra = CreatePed(26, model, SCENE_COORDS[1], SCENE_COORDS[2], SCENE_COORDS[3], 0.0, false, false)

        if not IsEntityDead(extra) then
            DressExtra(extra, slot)
            FinalizeHeadBlend(extra)
            RegisterEntityForCutscene(extra, Appearance.Cutscene.Peds[slot], 0, 0, 64)
        end

        extras[slot] = extra
    end

    NewLoadSceneStartSphere(SCENE_SPHERE[1], SCENE_SPHERE[2], SCENE_SPHERE[3], 1000.0, 0)
    SetWeatherTypeNow("EXTRASUNNY")
    StartCutscene(4)

    DoScreenFadeIn(1000)
    Wait(SCENE_DURATION)

    DoScreenFadeOut(2000)
    Wait(2000)

    StopCutscene(false)
    StopCutsceneImmediately()
    RemoveCutscene()
    NewLoadSceneStop()

    for slot = 0, 6 do
        DeleteEntity(extras[slot])
    end

    PrepareMusicEvent("AC_STOP")
    TriggerMusicEvent("AC_STOP")

    SpawnAfterCreate()
end
