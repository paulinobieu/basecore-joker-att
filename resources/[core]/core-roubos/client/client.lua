--[[
    core-roubos :: client/client.lua
    Estado client, thread principal de marker, comandos e callbacks NUI.
--]]

-----------------------------------------------------------------------------
-- ESTADO (globais por necessidade cross-file)
-----------------------------------------------------------------------------
inPainel       = false
inSelectTeam   = false
isInRobbery    = false
ActualRobbery  = nil
Team           = nil

RobberyPoints  = {}
robberyHappen  = {}
robberyBlips   = {}
blips          = setmetatable({}, { __index = table })

-----------------------------------------------------------------------------
-- CONSTANTES
-----------------------------------------------------------------------------
local INTERACT_KEY       = 38   -- E
local CANCEL_KEY         = 177  -- Backspace
local INTERACT_RADIUS    = 1.5
local DEAD_HEALTH        = 101
local MARKER_RENDER_DIST = 50.0

-----------------------------------------------------------------------------
-- COMANDOS
-----------------------------------------------------------------------------
RegisterCommand('bk', function(_, args)
    if args[1] ~= 'roubos' then return end

    if not vSERVER.getPermission(Config.Roubos.cmdPermission) then
        TriggerEvent('core-roubos:robnotify', 'negado', 'Sem permissão!', 8000)
        return
    end

    if not inPainel then
        OpenNUI({ action = 'openAdminPainel' }, true)
    end
end)

function OpenScoreboard()
    if not isInRobbery or inPainel then return end
    if type(ActualRobbery) ~= 'table' then return end

    OpenNUI({
        action  = 'OpenScoreboard',
        robbery = ActualRobbery,
        team    = Team or tostring(vSERVER.GetMyTeam(ActualRobbery)),
    }, true)
end

RegisterCommand('core-roubos:openscoreboard', OpenScoreboard)

-- Atalho extra via comando /placar — funciona mesmo se o jogador não
-- tiver bindado a tecla INSERT em Settings → Key Bindings → FiveM
RegisterCommand('placar', OpenScoreboard, false)

CreateThread(function()
    RegisterKeyMapping('core-roubos:openscoreboard',
        'Abrir Scoreboard', 'KEYBOARD',
        tostring(Config.Roubos.openScoreboardKey))

    SetTimeout(2000, function()
        -- Envia a cor primária do tema para o React (CSS vars).
        OpenNUI({ action = 'SetThemeColor', color = Config.GetThemeColor() }, false)

        OpenNUI({ action = 'UpdatingHud', robbery = false }, false)
    end)
end)

-----------------------------------------------------------------------------
-- THREAD DE INTERAÇÃO COM PONTOS DE ROUBO
-----------------------------------------------------------------------------
local function tryStartFromPoint(point)
    local err, msg, extra = vSERVER.tryRobbery(point)
    if not err then
        if msg then
            TriggerEvent('core-roubos:robnotify', 'negado', tostring(msg), 8000)
        end
        return
    end
    if not msg or not extra or type(extra) ~= 'table' or not extra.key then return end
    if type(extra.proj) ~= 'table' then return end

    inSelectTeam = true
    OpenNUI({
        action     = 'BanditsTeam',
        key        = extra.key,
        name       = err,
        nusers     = msg,
        projection = extra.proj,
        bandlimit  = extra.bandlimit,
    }, true)
end

CreateThread(function()
    while true do
        local sleep = 1000
        local ped   = PlayerPedId()
        local pos   = GetEntityCoords(ped)

        for _, v in pairs(RobberyPoints or {}) do
            local marker = vec3(v.cds.x, v.cds.y, v.cds.z)
            local dist   = #(pos - marker)

            if dist < MARKER_RENDER_DIST then
                sleep = 0
                DrawMarker(21, marker.x, marker.y, marker.z - 0.6,
                    0, 0, 0,  0, 0, 0,
                    0.5, 0.5, 0.4,
                    255, 0, 0, 100,
                    false, false, 0, true)

                if dist < INTERACT_RADIUS then
                    DrawText3D(marker.x, marker.y, marker.z,
                        'PRESSIONE ~r~E ~w~PARA ROUBAR')
                    if IsControlJustPressed(0, INTERACT_KEY)
                            and GetEntityHealth(ped) > DEAD_HEALTH
                            and not inPainel then
                        tryStartFromPoint(v)
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

-----------------------------------------------------------------------------
-- CALLBACKS NUI
-----------------------------------------------------------------------------
local CallBacks = {

    openHistoricRobberys = function(data)
        if type(data) ~= 'table' then return {} end
        data.limit  = 50
        data.offset = 0
        return vSERVER.getHistoric(data.offset, data.limit)
    end,

    createPreset = function(data)
        if type(data) ~= 'table' then return end
        return vSERVER.createPreset(data)
    end,

    deletePreset = function(data)
        if not data.name then return end
        return vSERVER.deletePreset(data.name)
    end,

    getPresets      = function() return vSERVER.getPresets()    end,
    getRobberies    = function() return vSERVER.getRobberies()  end,
    getPresetsName  = function() return vSERVER.getPresetsName() or {} end,

    getCoords = function()
        local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
        return { x = x or 0.0, y = y or 0.0, z = z or 0.0 }
    end,

    addRobbery = function(data)
        if not data.preset or not data.cds
                or not data.cds.x or not data.cds.y or not data.cds.z then
            return
        end
        return vSERVER.addRobbery(data)
    end,

    remRobbery = function(data)
        local id = data.count or data.key or data.id
        if id then return vSERVER.remRobbery(id) end
    end,

    -- ATENÇÃO: takeBanditsForRob/takeCopsForRob processam o server em
    -- THREAD SEPARADA, porque vSERVER.tryStartRobbery/approveRobbery podem
    -- bloquear por 15+ segundos (esperando policiais aceitarem ou entrarem
    -- no perímetro). Se aguardássemos no callback do NUI, o CEF daria
    -- "Failed to fetch" por timeout e a UI travaria em "Enviando...".
    takeBanditsForRob = function(data)
        inSelectTeam = false

        if type(data) ~= 'table' or not data.key
                or not data.bandits or not data.hostages then
            return { status = false, msg = 'Algum dado não foi recebido!' }
        end

        CreateThread(function()
            local response = vSERVER.tryStartRobbery(
                tonumber(data.key), data.bandits, data.hostages)
            if not response or not response.status then
                TriggerServerEvent('core-roubos:tryrobnotify',
                    tonumber(data.key), 'negado',
                    tostring(response and response.msg or 'Erro ao iniciar'),
                    8000)
                vSERVER.cancelRobbery(data.key)
            end
        end)

        -- ACK imediato para o NUI
        return { status = true, msg = 'Solicitando policiais…' }
    end,

    takeCopsForRob = function(data)
        CloseNUI()
        inSelectTeam = false

        if type(data) ~= 'table' or not tonumber(data.key) or not data.cops then
            return { status = false, msg = 'Dados inválidos' }
        end

        CreateThread(function()
            local err, msg = vSERVER.approveRobbery(tonumber(data.key), data.cops)
            if not err then
                TriggerServerEvent('core-roubos:tryrobnotify',
                    tonumber(data.key), 'negado', tostring(msg), 8000)
                vSERVER._cancelRobbery(data.key)
                return
            end
            stopTabletAnimation()
        end)

        -- ACK imediato para o NUI
        return { status = true, msg = 'Aprovando equipe…' }
    end,

    getGiveUpInfos = function()
        return vSERVER.getStateForGiveUp(Team)
    end,

    voteGiveUpinRobbery = function()
        local result = vSERVER.voteRobberyGiveUp(Team)
        if result.status then CloseNUI() end
        return result
    end,

    initAction = function() end,

    closePainel = function(data)
        CloseNUI()
        if data.key and inSelectTeam then
            TriggerServerEvent('core-roubos:tryrobnotify',
                tonumber(data.key), 'negado',
                'A seleção de time foi cancelada!', 8000)
            vSERVER.cancelRobbery(data.key)
            inSelectTeam = false
        end
    end,

    spectateUserInRobberyNow = function(data)
        if type(data) ~= 'table' or type(data.player) ~= 'table'
                or not data.player.id then
            return { status = false, msg = 'Jogador inválido!' }
        end
        return vSERVER.spectatePlayer(tonumber(data.player.id))
    end,

    teleportToUserInRobberyNow = function(data)
        if type(data) ~= 'table' or type(data.player) ~= 'table'
                or not data.player.id then
            return { status = false, msg = 'Jogador inválido!' }
        end
        return vSERVER.teleportToPlayer(tonumber(data.player.id))
    end,
}

local API_ROUTE = GetCurrentResourceName() .. '_API'
RegisterNUICallback(API_ROUTE, function(data, cb)
    -- IMPORTANTE: cb() SEMPRE precisa ser chamado, mesmo que o handler não
    -- exista ou retorne nil. Caso contrário a fetch do React fica pendurada
    -- até dar timeout e jogar "Failed to fetch" no console.
    local handler = CallBacks[tostring(data.cb)]
    if not handler then
        cb({ ok = false, error = 'unknown_cb' })
        return
    end

    local ok, res = pcall(handler, data)
    if not ok then
        print(('[core-roubos] callback %s falhou: %s'):format(tostring(data.cb), tostring(res)))
        cb({ ok = false, error = tostring(res) })
        return
    end

    cb(res ~= nil and res or { ok = true })
end)
