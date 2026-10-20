--[[
    core-roubos :: client/functions.lua
    Helpers de NUI, blips, drawmarkers, animação de tablet, formatadores
    e métodos lRoubos.* expostos para o server (via vCLIENT).

    Globais consumidas / atualizadas:
        inPainel, inSelectTeam, isInRobbery, ActualRobbery, Team, isAlive,
        RobberyPoints, blips, robberyHappen, robberyBlips
--]]

-----------------------------------------------------------------------------
-- NUI
--
-- Obs.: o blur de fundo é aplicado via CSS no React (backdrop-blur). Não usamos
-- TriggerScreenblurFadeIn/Out pois o FadeOut(500) não cancela bem o FadeIn(2000)
-- em progresso, deixando blur residual.
--
-- ESCAPE/BACKSPACE: o FiveM intercepta a tecla ESC para o pause menu antes que
-- chegue no NUI. Por isso polamos via IsControlJustReleased no Lua e enviamos
-- a ação ClosePainel para o React fechar o painel atual.
-----------------------------------------------------------------------------
local CONTROL_ESC       = 200  -- INPUT_FRONTEND_PAUSE_ALTERNATE
local CONTROL_BACKSPACE = 177  -- INPUT_FRONTEND_CANCEL
local panelKey          = nil  -- key do roubo associado ao painel atual (se houver)

local function startPanelEscWatcher()
    CreateThread(function()
        while inPainel do
            Wait(0)
            DisableControlAction(0, CONTROL_ESC, true) -- impede pause menu
            if IsDisabledControlJustPressed(0, CONTROL_ESC)
                    or IsControlJustReleased(0, CONTROL_BACKSPACE) then
                -- Avisa o React pra desmontar o painel
                SendNUIMessage({ action = 'ClosePainel' })
                CloseNUI()
                -- Se o painel era de seleção de time, cancela o roubo no servidor
                if panelKey and inSelectTeam then
                    TriggerServerEvent('core-roubos:tryrobnotify',
                        tonumber(panelKey), 'negado',
                        'A seleção de time foi cancelada!', 8000)
                    vSERVER.cancelRobbery(panelKey)
                    inSelectTeam = false
                end
                panelKey = nil
                break
            end
        end
    end)
end

function OpenNUI(payload, focus)
    if type(payload) ~= 'table' then return end
    SendNUIMessage(payload)

    if focus then
        inPainel = true
        SetNuiFocus(focus, focus)
        -- Guarda a key (se vier no payload) pra usar no cancelamento via ESC
        panelKey = payload.key
        startPanelEscWatcher()
    end
end

function CloseNUI()
    inPainel = false
    SetNuiFocus(false, false)
    panelKey = nil
    TriggerScreenblurFadeOut(0)
end

-----------------------------------------------------------------------------
-- AVISO PARA ABRIR SCOREBOARD
-----------------------------------------------------------------------------
function showKeyForScoreboard()
    local show = true
    CreateThread(function()
        SetTimeout(8000, function() show = false end)
        while show do
            Wait(0)
            if IsDisabledControlJustPressed(2, 201)
                    or IsDisabledControlJustPressed(2, 215) then
                show = false
            end
        end
    end)
end

-----------------------------------------------------------------------------
-- API CLIENT (lRoubos.*) — CHAMADA PELO SERVER
-----------------------------------------------------------------------------
function lRoubos.updateRobberyPoints(obj)
    RobberyPoints = obj
end

function lRoubos.getNearestPlayers(radius)
    local result    = {}
    local pid       = PlayerId()
    local origin    = GetEntityCoords(PlayerPedId())

    for _, player in ipairs(GetActivePlayers()) do
        if player ~= pid then
            local dist = #(origin - GetEntityCoords(GetPlayerPed(player)))
            if dist <= radius then
                result[GetPlayerServerId(player)] = dist
            end
        end
    end
    return result
end

function lRoubos.removeDrawmarker(key)
    RemoveBlip(robberyBlips[key])
    robberyHappen[key] = false
end

function lRoubos.createDrawmarker(vec, key)
    robberyHappen[key] = true
    AreaBlip(vec.x, vec.y, vec.z, key)

    CreateThread(function()
        local center = vec3(vec.x, vec.y, vec.z)
        while robberyHappen[key] do
            if #(GetEntityCoords(PlayerPedId()) - center) < 200.0 then
                DrawMarker(1, vec.x, vec.y, vec.z - 2,
                    0, 0, 0,  0, 0, 0,
                    135.5, 135.5, 20.5,
                    255, 0, 0, 40,
                    false, false, 0, true)
                Wait(0)
            else
                Wait(1000)
            end
        end
    end)
end

function lRoubos.createCopsBlip(vec, name, cooldown)
    if not vec then return end
    name = name or ''

    blips:insert(AddBlipForCoord(vec))
    local blip = blips[#blips]
    if not DoesBlipExist(blip) then return end

    SetBlipScale(blip, 0.5)
    SetBlipSprite(blip, 1)
    SetBlipColour(blip, 27)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString('Roubo: ~r~' .. tostring(name))
    EndTextCommandSetBlipName(blip)
    SetBlipAsShortRange(blip, false)
    SetBlipRoute(blip, true)

    SetTimeout(tonumber(cooldown) * 1000, function()
        RemoveBlip(blip)
    end)
end

function lRoubos.cancelRobbery()
    inPainel     = false
    isInRobbery  = false
    inSelectTeam = false
    ActualRobbery, Team = nil, nil
    OpenNUI({ action = 'CloseLoadscreen' }, false)
    CloseNUI()
end

-----------------------------------------------------------------------------
-- SELEÇÃO DE TIME (POLICIAL "MONTADOR")
-----------------------------------------------------------------------------
local function watchSelectionCancel(key)
    CreateThread(function()
        while inSelectTeam do
            Wait(4)
            if IsControlJustPressed(0, 177) then
                CloseNUI()
                inSelectTeam = false
                TriggerServerEvent('core-roubos:tryrobnotify',
                    tonumber(key), 'negado',
                    'A seleção de time foi cancelada!', 8000)
                vSERVER.cancelRobbery(key)
            end
        end
    end)
end

function lRoubos.SelectCops(key, cops, needcops, bandits, hostages, name)
    OpenNUI({ action = 'CloseLoadscreen' }, false)
    CloseNUI()
    Wait(5000)

    if not tonumber(key) then return end
    if type(cops) ~= 'table' or not needcops or not bandits or not hostages then
        return
    end

    inSelectTeam = true
    playTabletAnimation()

    OpenNUI({
        action   = 'CopsTeam',
        key      = tonumber(key),
        nusers   = cops,
        needcops = parseInt(tonumber(needcops)),
        bandits  = parseInt(tonumber(bandits)),
        hostages = parseInt(tonumber(hostages)),
        name     = tostring(name),
        cops     = {},
    }, true)

    watchSelectionCancel(tonumber(key))

    Wait(60000 * 5)
    stopTabletAnimation()

    if inSelectTeam and key then
        CloseNUI()
        inSelectTeam = false
        TriggerServerEvent('core-roubos:tryrobnotify',
            tonumber(key), 'negado',
            'A seleção de time foi cancelada!', 8000)
        vSERVER.cancelRobbery(tonumber(key))
    end
end

-----------------------------------------------------------------------------
-- AVISOS DE FASE DO ROUBO
-----------------------------------------------------------------------------
local IMPORTANT_WARNS = {
    bandits  = 'Os policiais estão a caminho, aguarde.',
    cops     = 'O roubo iniciou, a localização já está marcada!',
    hostages = 'Os policiais foram alertados do roubo, coopere para sobreviver!',
}

local START_WARNS = {
    bandits  = 'Roubo iniciado, policiais chegaram no perímetro.',
    cops     = 'Roubo iniciado, policiais chegaram no perímetro.',
    hostages = 'O roubo iniciou, coopere para sobreviver!',
}

local function warn(team, list)
    local msg = list[team]
    if msg then
        TriggerEvent('core-roubos:robnotify', 'importante', tostring(msg), 8000)
    end
end

-----------------------------------------------------------------------------
-- HUD / INIT / UPDATE
-----------------------------------------------------------------------------
function lRoubos.hudRobbery(robbery, team)
    if type(robbery) ~= 'table' or type(team) ~= 'string' then return end

    -- 🔒 SEMPRE fecha qualquer painel pendente (bandits/cops em waiting),
    -- independente de isInRobbery (que pode estar com estado stale).
    OpenNUI({ action = 'CloseLoadscreen' }, false)
    if inPainel then CloseNUI() end

    ActualRobbery = robbery
    isInRobbery   = true
    Team          = team
    isAlive       = GetEntityHealth(PlayerPedId()) > 101

    OpenNUI({
        action        = 'UpdatingHud',
        robbery       = ActualRobbery,
        team          = Team,
        initialUpdate = true,
    }, false)

    -- 🏁 Roubo começou — abre o placar automaticamente.
    SetTimeout(1500, function()
        if isInRobbery and not inPainel then
            OpenScoreboard()
        end
    end)

    SetTimeout(1000, function()
        warn(Team, START_WARNS)
    end)
end

function lRoubos.initRobbery(robbery, team)
    if type(robbery) ~= 'table' or type(team) ~= 'string' then return end

    -- 🔒 SEMPRE fecha o painel de seleção (bandits/cops em waiting state)
    -- assim que o cop aprova a equipe. Não condiciona ao isInRobbery porque
    -- ele só vira true no hudRobbery (depois, quando todos chegam).
    OpenNUI({ action = 'CloseLoadscreen' }, false)
    if inPainel then CloseNUI() end

    ActualRobbery = robbery

    SetTimeout(1000, function()
        if isInRobbery then
            warn(team, IMPORTANT_WARNS)
        end
    end)
end

function lRoubos.updateActualRobbery(obj)
    if type(obj) == 'table' then
        ActualRobbery = obj
        local myTeam  = vSERVER.GetMyTeam(ActualRobbery)
        OpenNUI({
            action  = 'UpdatingHud',
            robbery = ActualRobbery,
            team    = myTeam,
        }, false)
    else
        inPainel     = false
        isInRobbery  = false
        inSelectTeam = false
        ActualRobbery, Team = nil, nil
        OpenNUI({ action = 'UpdatingHud', robbery = false }, false)
        CloseNUI()
    end
end

-----------------------------------------------------------------------------
-- RENDERIZAÇÃO DE TEXTO 3D
-----------------------------------------------------------------------------
function DrawText3D(x, y, z, text)
    local _, sx, sy = World3dToScreen2d(x, y, z)
    SetTextScale(0.39, 0.39)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 235)
    SetTextEntry('STRING')
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(sx, sy)

    local factor = string.len(text) / 270
    DrawRect(sx, sy + 0.0125, 0.005 + factor, 0.04, 0, 0, 0, 145)
end

function DrawTxt(text, font, x, y, scale, r, g, b, a)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextOutline()
    SetTextCentre(1)
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(x, y)
end

-----------------------------------------------------------------------------
-- FORMATADORES / BLIPS DE ÁREA
-----------------------------------------------------------------------------
function format(n)
    local left, num, right = string.match(n, '^([^%d]*%d)(%d*)(.-)$')
    return left .. (num:reverse():gsub('(%d%d%d)', '%1.'):reverse()) .. right
end

function AreaBlip(x, y, z, key)
    robberyBlips[key] = AddBlipForRadius(x, y, z, 50.0)
    SetBlipColour(robberyBlips[key], 1)
    SetBlipAlpha(robberyBlips[key], 80)
end

-----------------------------------------------------------------------------
-- ANIMAÇÃO DE TABLET
-----------------------------------------------------------------------------
local TABLET_DICT = 'amb@code_human_in_bus_passenger_idles@female@tablet@idle_a'
local TABLET_PROP = 'prop_cs_tablet'
local TABLET_BONE = 60309

local tabletProp
local animPlaying = false

function playTabletAnimation()
    if animPlaying then return end

    RequestAnimDict(TABLET_DICT)
    while not HasAnimDictLoaded(TABLET_DICT) do Wait(10) end

    local ped       = PlayerPedId()
    local boneIndex = GetPedBoneIndex(ped, TABLET_BONE)

    tabletProp = CreateObject(GetHashKey(TABLET_PROP), 0, 0, 0, true, true, false)
    AttachEntityToEntity(tabletProp, ped, boneIndex,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        false, false, false, false, 2, true)

    TaskPlayAnim(ped, TABLET_DICT, 'idle_b',
        8.0, -8.0, -1, 49, 0, false, false, false)
    animPlaying = true
end

function stopTabletAnimation()
    if not animPlaying then return end
    ClearPedTasks(PlayerPedId())
    DeleteObject(tabletProp)
    tabletProp  = nil
    animPlaying = false
end
