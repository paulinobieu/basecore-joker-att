--[[
    core-roubos :: server/server.lua
    Camada de exposição:
        - Métodos lRoubos.*  (chamados via vSERVER do client)
        - Comando administrativo /roubos
        - Hooks Connect / Disconnect (eventos do vRP da CoreBase)
--]]

local combatlog = {}

-----------------------------------------------------------------------------
-- HELPERS DE GUARDIA (passport / permissão)
-----------------------------------------------------------------------------
local function requirePassport(src)
    return vRP.Passport(src)
end

local function requirePermission(src, perm)
    local passport = vRP.Passport(src)
    if not passport then return nil end
    if not Config.HasPermission(passport, perm) then return nil end
    return passport
end

-----------------------------------------------------------------------------
-- API EXPOSTA (lRoubos)
-----------------------------------------------------------------------------
function lRoubos.getPermission(perm)
    local passport = requirePassport(source)
    if not passport then return end
    return Config.HasPermission(passport, perm)
end

function lRoubos.getHistoric(offset, limit)
    if not requirePermission(source, 'ViewHistoric') then return false end
    return lotusRoubos:getHistoricRobberys(offset, limit)
end

function lRoubos.createPreset(data)
    if not requirePermission(source, 'ManagePresets') then return end
    return lotusRoubos:createPreset(data)
end

function lRoubos.deletePreset(name)
    if not requirePermission(source, 'ManagePresets') then return end
    return lotusRoubos:deletePreset(name)
end

function lRoubos.getPresets()
    if not requirePassport(source) then return end
    return lotusRoubos:getDataPresets()
end

function lRoubos.getRobberies()
    if not requirePassport(source) then return end
    return lotusRoubos:getDataRobberies()
end

function lRoubos.getPresetsName()
    if not requirePassport(source) then return end
    local consult = vRP.Query('lotusRoubos/getAllPresetsName')
    local result  = {}
    for _, v in ipairs(consult or {}) do
        if v.name then result[#result + 1] = tostring(v.name) end
    end
    return result
end

function lRoubos.cancelRobbery(key)
    if not requirePassport(source) then return end
    lotusRoubos:cancelRobbery(key)
end

function lRoubos.addRobbery(data)
    if not requirePassport(source) then return end
    return lotusRoubos:addRobbery(data)
end

function lRoubos.remRobbery(count)
    if not requirePassport(source) then return end
    return lotusRoubos:remRobbery(count)
end

function lRoubos.tryRobbery(point)
    local passport = requirePassport(source)
    if not passport then return end
    if Config.IsPolice(passport) then
        return false, 'Você é policial, e não pode roubar!'
    end
    return lotusRoubos:tryRobbery(passport, point)
end

function lRoubos.tryStartRobbery(key, bandits, hostages)
    if not requirePassport(source) then return end
    return lotusRoubos:tryStartRobbery(key, bandits, hostages)
end

function lRoubos.approveRobbery(key, rcops)
    if not requirePassport(source) then return end
    return lotusRoubos:approveRobbery(key, rcops)
end

function lRoubos.GetMyTeam(obj)
    local passport = requirePassport(source)
    if not passport then return end

    for team, members in pairs(obj) do
        if type(members) == 'table' then
            for _, m in ipairs(members) do
                if type(m) == 'table' and m.id == passport then
                    return tostring(team)
                end
            end
        end
    end
end

function lRoubos.getStateForGiveUp(team)
    local src      = source
    local passport = requirePassport(src)
    if not passport then return end

    local _, _, key, Team = IsInRobbery(src)
    if not (key and tostring(Team) == tostring(team)) then return end

    if not tonumber(key) or type(ActualRobberies[tonumber(key)]) ~= 'table' then
        return { status = false, msg = 'Erro ao pegar as informações de rendição!' }
    end

    local data    = GetPlayerTable(src)
    local members = GetGiveUpMembers(tonumber(key), tostring(team))
    return {
        voted              = not not data.giveup,
        playersAlreadyVoted = members,
    }
end

function lRoubos.voteRobberyGiveUp(team)
    if not requirePassport(source) then return end
    return lotusRoubos:voteRobberyGiveUp(team)
end

-----------------------------------------------------------------------------
-- ESPECTAR / TELEPORTAR (admin)
-----------------------------------------------------------------------------
local function adminTargetCheck(src, targetPassport)
    local passport = vRP.Passport(src)
    if not passport then
        return nil, { status = false, msg = 'Você não está identificado!' }
    end
    if not Config.HasPermission(passport, 'AdminCommand') then
        return nil, { status = false, msg = 'Sem permissão!' }
    end

    local target = tonumber(targetPassport)
    if not target then
        return nil, { status = false, msg = 'Passaporte inválido!' }
    end
    local targetSource = vRP.Source(target)
    if not targetSource then
        return nil, { status = false, msg = 'Jogador offline!' }
    end
    return targetSource
end

function lRoubos.spectatePlayer(targetPassport)
    local targetSource, err = adminTargetCheck(source, targetPassport)
    if not targetSource then return err end

    TriggerClientEvent('admin:initSpectate', source, targetSource)
    return { status = true,
        msg = 'Espectando ' .. tonumber(targetPassport) .. '. Use /tirarspec para sair.' }
end

function lRoubos.teleportToPlayer(targetPassport)
    local targetSource, err = adminTargetCheck(source, targetPassport)
    if not targetSource then return err end

    local ped = GetPlayerPed(targetSource)
    if not ped or not DoesEntityExist(ped) then
        return { status = false, msg = 'Não foi possível localizar o jogador!' }
    end

    local coords = GetEntityCoords(ped)
    vRP.Teleport(source, coords.x, coords.y, coords.z)
    return { status = true,
        msg = 'Teletransportado até ' .. tonumber(targetPassport) .. '!' }
end

-----------------------------------------------------------------------------
-- COMANDO /roubos
-----------------------------------------------------------------------------
RegisterCommand('roubos', function(src, args)
    if not requirePermission(src, 'AdminCommand') then return end

    if not args[1] then
        TriggerClientEvent('Notify', src, 'negado',
            'Use /roubos listar ou /roubos deletar [ID]', 30000)
        return
    end

    if args[1] == 'listar' then
        TriggerClientEvent('Notify', src, 'sucesso',
            lotusRoubos:listRobberys(), 30000)
        return
    end

    if args[1] == 'deletar' then
        local id = tonumber(args[2])
        if not id then
            TriggerClientEvent('Notify', src, 'negado',
                'Você precisa informar o ID do roubo.', 30000)
            return
        end
        if not ActualRobberies[id] then
            TriggerClientEvent('Notify', src, 'negado',
                'Roubo de ID ' .. id .. ' não encontrado.', 30000)
            return
        end
        lotusRoubos:cancelRobbery(id)
        TriggerClientEvent('Notify', src, 'sucesso',
            'Roubo de ID ' .. id .. ' deletado com sucesso.', 30000)
    end
end)

-----------------------------------------------------------------------------
-- HOOKS vRP (CoreBase)
-----------------------------------------------------------------------------
AddEventHandler('Connect', function(passport, src)
    vCLIENT._updateRobberyPoints(src, RobberyCache)

    if passport and combatlog[passport] then
        Wait(5000)
        TriggerClientEvent('robnotify', src, 'aviso',
            'Você deslogou na última ação, e voltou finalizado!', 10000)
        vRPC.SetHealth(src, 100)
        combatlog[passport] = nil
    end
end)

AddEventHandler('Disconnect', function(passport, src)
    if GlobalState.ServerRestart then return end
    if not passport then return end

    if selectMenu[src] then
        TriggerEvent('core-roubos:tryrobnotify', tonumber(selectMenu[src]),
            'importante',
            'O roubo foi cancelado porque o responsável por escolher time deslogou.',
            15000, 'bandits')
        TriggerEvent('core-roubos:tryrobnotify', tonumber(selectMenu[src]),
            'importante',
            'O roubo foi cancelado porque o responsável por escolher time deslogou.',
            15000, 'cops')
        lotusRoubos:cancelRobbery(tonumber(selectMenu[src]))
        selectMenu[src] = nil
    end
end)

---------------------------------------------------------------------------------------------------------------------------------------
-- AUTH / WEBHOOK
---------------------------------------------------------------------------------------------------------------------------------------
