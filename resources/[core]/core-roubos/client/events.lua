--[[
    core-roubos :: client/events.lua
    Detecção de morte (hit na cabeça com arma de fogo) durante roubos +
    handlers de killfeed, vencedor e notificações estilizadas.
--]]

-----------------------------------------------------------------------------
-- ARMAS QUE NÃO CONTAM COMO HEADSHOT INSTANT-KILL
-- (corpo a corpo, atropelamentos, granadas, etc.)
-----------------------------------------------------------------------------
local NON_LETHAL_HEAD = {}
do
    local list = {
        '0', 'WEAPON_UNARMED',
        'WEAPON_RUN_OVER_BY_CAR', 'WEAPON_RAMMED_BY_CAR', 'VEHICLE_WEAPON_ROTORS',
        'WEAPON_DAGGER', 'WEAPON_BAT', 'WEAPON_BOTTLE', 'WEAPON_CROWBAR',
        'WEAPON_FLASHLIGHT', 'WEAPON_GOLFCLUB', 'WEAPON_HAMMER', 'WEAPON_HATCHET',
        'WEAPON_KNUCKLE', 'WEAPON_KNIFE', 'WEAPON_MACHETE', 'WEAPON_SWITCHBLADE',
        'WEAPON_NIGHTSTICK', 'WEAPON_WRENCH', 'WEAPON_BATTLEAXE', 'WEAPON_POOLCUE',
        'WEAPON_STONE_HATCHET',
        'WEAPON_GRENADE', 'WEAPON_BZGAS', 'WEAPON_MOLOTOV', 'WEAPON_STICKYBOMB',
        'WEAPON_PROXMINE', 'WEAPON_SNOWBALL', 'WEAPON_PIPEBOMB', 'WEAPON_BALL',
        'WEAPON_SMOKEGRENADE', 'WEAPON_FLARE', 'WEAPON_PETROLCAN',
        'WEAPON_PARACHUTE', 'WEAPON_FIREEXTINGUISHER', 'WEAPON_HAZARDCAN',
    }
    for _, w in ipairs(list) do NON_LETHAL_HEAD[w] = true end
end

local HEAD_BONE         = 31086   -- SKEL_Head
local DEAD_HEALTH       = 101
local DAMAGE_COOLDOWN_MS = 500

-----------------------------------------------------------------------------
-- DETECÇÃO DE MORTE / FATAL
-----------------------------------------------------------------------------
local lastDamageAt = 0

AddEventHandler('gameEventTriggered', function(event, args)
    if event ~= 'CEventNetworkEntityDamage' or not ActualRobbery then return end

    local victim   = args[1]
    local attacker = args[2]
    if not IsEntityAPed(victim) then return end

    local ped = PlayerPedId()
    if victim ~= ped then return end

    local now = GetGameTimer()
    if lastDamageAt >= now then return end

    local source = -1
    local weapon = '0'
    if DoesEntityExist(attacker) and IsPedAPlayer(attacker) and attacker ~= victim then
        source = GetPlayerServerId(NetworkGetPlayerIndexFromPed(attacker))
        weapon = ({ GetCurrentPedWeapon(attacker) })[2]
    end

    local _, bone = GetPedLastDamageBone(ped)
    local fatalHead = bone == HEAD_BONE and not NON_LETHAL_HEAD[weapon]
    local downed    = GetEntityHealth(ped) <= DEAD_HEALTH

    if (fatalHead or downed) and isInRobbery then
        lastDamageAt = now + DAMAGE_COOLDOWN_MS
        SetEntityHealth(ped, 100)

        OpenNUI({ action = 'ClosePainel' }, false)
        CloseNUI()

        TriggerServerEvent('core-roubos:playerKilled', source, {
            weaponhash = weapon,
            killerpos  = GetEntityCoords(ped),
        })
        isAlive = false
    end
end)

-----------------------------------------------------------------------------
-- KILLFEED
-----------------------------------------------------------------------------
RegisterNetEvent('killfeed', function(victim, reason, killer, team, team2)
    if type(victim) ~= 'string' or type(reason) ~= 'string' then return end

    local myTeam = tostring(vSERVER.GetMyTeam(ActualRobbery) or '')

    if team  == 'cops' then team  = 'Policial' end
    if team2 == 'cops' then team2 = 'Policial' end

    local payload = {
        action = 'KillFeed',
        type   = killer and 'kill' or 'death',
        victim = { name = tostring(team), team = tostring(team) },
        icon   = tostring(reason),
        myteam = myTeam,
    }
    if killer then
        payload.killer = { name = tostring(team2), team = tostring(team2) }
    end

    OpenNUI(payload, false)
end)

-----------------------------------------------------------------------------
-- WINNER
-----------------------------------------------------------------------------
RegisterNetEvent('winnernotify', function(team)
    if type(team) ~= 'string' then return end
    OpenNUI({ action = 'WinnerNotify', winner = tostring(team) }, false)
end)

-----------------------------------------------------------------------------
-- NOTIFY
-----------------------------------------------------------------------------
local NOTIFY_STYLES = { negado = true, sucesso = true, aviso = true, importante = true }

RegisterNetEvent('core-roubos:robnotify', function(style, content, sleep)
    if not NOTIFY_STYLES[style] or not content then return end

    OpenNUI({
        action  = 'NotifyMessage',
        style   = style,
        content = content,
        sleep   = tonumber(sleep) or 8000,
    }, false)
end)
