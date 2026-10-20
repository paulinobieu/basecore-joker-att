-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local CreateThread = CreateThread
local DoScreenFadeIn = DoScreenFadeIn
local GetGameTimer = GetGameTimer
local DoScreenFadeOut = DoScreenFadeOut
local FreezeEntityPosition = FreezeEntityPosition
local IsIplActive = IsIplActive
local PlayerPedId = PlayerPedId
local RegisterNetEvent = RegisterNetEvent
local RequestIpl = RequestIpl
local SetEntityCoordsNoOffset = SetEntityCoordsNoOffset
local SetEntityHeading = SetEntityHeading
local SetEntityInvincible = SetEntityInvincible
local SetEntityVisible = SetEntityVisible
local TriggerServerEvent = TriggerServerEvent
local Wait = Wait
local AwaitingClothing = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADIPL
-----------------------------------------------------------------------------------------------------------------------------------------
-- Com teto de tempo de propósito: um IPL que não existe no servidor nunca fica
-- ativo, e o laço sem saída travava a tela inteira — sem erro nenhum no
-- console, só o fade que nunca voltava.
function LoadIpl(ipl)
    if not ipl or ipl == "" then return false end

    local timeout = GetGameTimer() + 10000

    while not IsIplActive(ipl) and GetGameTimer() < timeout do
        RequestIpl(ipl)
        Wait(500)
    end

    return IsIplActive(ipl)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENCREATOR
-----------------------------------------------------------------------------------------------------------------------------------------
function OpenCreator(payload)
    if InCreator then return end
    if type(payload) ~= "table" then return end

    AwaitingClothing = false

    -- O /resetchar pega o jogador onde ele estiver, inclusive dentro da
    -- barbearia: sem isso as duas telas ficariam abertas ao mesmo tempo.
    if InBarber then CloseBarber() end

    InCreator = true
    EditMode = payload.edit and true or false
    InSelect = false

    local ped = PlayerPedId()

    if EditMode then
        CurrentAppearance = CopyAppearance(payload.appearance)
    else
        -- Sem visual gravado o rosto volta ao padrão, mas o MODELO é o do
        -- personagem: forçar masculino aqui viraria toda personagem feminina
        -- de cabeça para baixo no primeiro login.
        Framework.ApplySkin(payload.model or "mp_m_freemode_01")
        CurrentAppearance = CopyAppearance(Appearance.Default)
    end

    -- SetPlayerModel substitui a entidade do jogador. O handle obtido antes da
    -- troca aponta para o ped antigo e faria o teleporte abaixo ser ignorado.
    ped = PlayerPedId()

    SetEntityInvincible(ped, false)
    SetEntityVisible(ped, true, false)
    FreezeEntityPosition(ped, true)

    DoScreenFadeOut(500)
    Wait(500)

    LoadIpl(Character.Scene.CreateIpl)

    TriggerServerEvent("core-character:requestRouting")

    local coords = Character.Scene.CreateCoords
    SetEntityCoordsNoOffset(ped, coords[1], coords[2], coords[3], true, true, true)
    SetEntityHeading(ped, coords[4] or 0.0)

    Wait(500)

    ApplyAppearance(CurrentAppearance)

    if not EditMode then
        Framework.ApplyClothes(Appearance.Clothes.Creator[GenderKey()])
    end

    PlayPose("idle")
    CreateCreatorCam(1)

    Wait(500)
    DoScreenFadeIn(500)

    OpenScreen("character", {
        hairs = GlobalState["CharacterHairs"],
        gender = IsMale() and "mp_m_freemode_01" or "mp_f_freemode_01",
        character = CurrentAppearance,
        name = payload.name,
        lastname = payload.lastname,
        edit = EditMode,
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSECREATOR
-----------------------------------------------------------------------------------------------------------------------------------------
function CloseCreator()
    InCreator = false
    EditMode = false

    DestroyCreatorCam()
    CloseScreen()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPAWNAFTERCREATE
-----------------------------------------------------------------------------------------------------------------------------------------
function SpawnAfterCreate(spawn)
    local ped = PlayerPedId()
    local coords = spawn or Character.SpawnCoords
    local x = coords.x or coords[1]
    local y = coords.y or coords[2]
    local z = coords.z or coords[3]
    local heading = coords.h or coords.heading or coords[4] or 0.0

    FreezeEntityPosition(ped, false)
    StopPose()

    SendServerAction("exitCreator")

    SetEntityCoordsNoOffset(ped, x, y, z, true, true, true)
    SetEntityHeading(ped, heading)

    DoScreenFadeIn(1000)
    Wait(1000)

    Framework.OnSpawned()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CHARACTER:OPENCREATOR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-character:openCreator", function(payload)
    OpenCreator(payload)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CHARACTER:CHARACTERCREATED
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-character:characterCreated", function(appearance)
    CurrentAppearance = CopyAppearance(appearance)

    local wasEditing = EditMode

    DoScreenFadeOut(1000)
    Wait(1000)

    CloseCreator()

    if wasEditing then
        Framework.ResetClothes()
    else
        Framework.ApplyClothes(Appearance.Clothes.Spawn[GenderKey()])
    end

    if Character.Features.Clothing then
        AwaitingClothing = true
        return Framework.OpenClothing()
    end

    FinishCreatorFlow()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FINISHCREATORFLOW
-----------------------------------------------------------------------------------------------------------------------------------------
function FinishCreatorFlow()
    if Character.Features.Cutscene then
        return StartArrivalCutscene()
    end

    SpawnAfterCreate()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CHARACTER:FINISHEDCLOTHING
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-character:finishedClothing", function()
    if not Character.Features.Clothing or not AwaitingClothing then return end

    AwaitingClothing = false

    FinishCreatorFlow()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CHARACTER:APPLYSKIN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-character:applySkin", function(model)
    Framework.ApplySkin(model)
    ApplyAppearance(CurrentAppearance)
    Framework.ResetClothes()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CHARACTER:APPLYAPPEARANCE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-character:applyAppearance", function(appearance)
    CurrentAppearance = CopyAppearance(appearance)

    -- Restaurar rosto/cabelo não pode zerar os componentes de roupa. O outfit
    -- é reaplicado também para recuperar tatuagens removidas ao trocar o
    -- overlay do cabelo.
    ApplyAppearance(CurrentAppearance, nil, true)
    Framework.ResetClothes()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- POSEWATCH
-----------------------------------------------------------------------------------------------------------------------------------------
-- Entrar num personagem novo faz a base rodar um ReloadCharacter cinco
-- segundos depois, e ele limpa as tasks do ped — o que derrubaria a pose bem
-- no meio da criação. PlayPose não faz nada se a pose já estiver tocando, então
-- este laço só custa a checagem.
CreateThread(function()
    while true do
        if (InCreator or InBarber) and CurrentPose then
            PlayPose(CurrentPose)
            Wait(1000)
        else
            Wait(2000)
        end
    end
end)
