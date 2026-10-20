--[[
    core-roubos :: shared/config.lua
    Configurações gerais, permissões, hierarquias e mapeamento de armas
    para o killfeed/log de mortes em roubos.
--]]

Config = {}

-----------------------------------------------------------------------------
-- ROUBOS
-----------------------------------------------------------------------------
Config.Roubos = {
    openScoreboardKey      = 'INSERT',
    NeedAdminAuthorization = false,
    disableCooldown        = false,        -- DESABILITAR COOLDOWN (apenas testes)
    blipCooldown           = 100,          -- segundos do blip de rota policial
    cmdPermission          = 'AdminCommand', -- permissão para abrir o painel
    LogWebhook             = '',           -- webhook do Discord (vazio desativa)

    -- Cor primária da interface React (mesmo formato do Global.Theme.main do vRP).
    -- Para sincronizar com o tema do servidor, copie o valor que está em
    -- vrp/config/Global.lua → Theme.main. Resources rodam em sandboxes Lua
    -- separados, então não dá para ler diretamente — é cópia manual.
    ThemeColor             = '#dc1553',     -- bate com vrp/config/Global.lua → Theme.main
}

function Config.GetThemeColor()
    local c = Config.Roubos.ThemeColor
    if type(c) == 'string' and #c > 0 then return c end
    return '#dc1553'
end

-----------------------------------------------------------------------------
-- PERMISSÕES
-- Formato:
--   { Groups = { "Grupo1", "Grupo2" }, MinHierarchy = 1 }
-- MinHierarchy = nil  -> qualquer hierarquia
-----------------------------------------------------------------------------
Config.Permissions = {
    AdminCommand = {
        Groups       = { 'Admin', 'admin' },
        MinHierarchy = 1,
    },
    ManagePresets = {
        Groups       = { 'Admin', 'admin' },
        MinHierarchy = 1,
    },
    ViewHistoric = {
        Groups       = { 'Admin', 'admin' },
        MinHierarchy = 1,
    },
    Police = {
        Groups = {
            'Pc', 'Gcm', 'Radiopatrulha', 'Coe', 'Rota', 'Baep', 'Federal', 'Policia',
        },
        MinHierarchy = nil,
    },
}

-----------------------------------------------------------------------------
-- HIERARQUIA POLICIAL (cargos exibidos / verificados)
-----------------------------------------------------------------------------
Config.Hierarquia = {
    -- Alta patente
    'Coronel', 'Tenente-Coronel', 'Major', 'Capitão',
    -- Oficiais
    '1º Tenente', '2º Tenente', 'Aspirante',
    -- Praças especiais
    'Subtenente', '1º Sargento', '2º Sargento', '3º Sargento',
    -- Praças
    'Cabo',
    -- Delegacia
    'Delegada',
}

-----------------------------------------------------------------------------
-- HELPERS DE PERMISSÃO
-----------------------------------------------------------------------------
local IS_SERVER = IsDuplicityVersion()

local function hasGroupVariations(user_id, baseGroup)
    if vRP.HasGroup(user_id, baseGroup) then
        return true
    end
    for _, cargo in ipairs(Config.Hierarquia) do
        if vRP.HasGroup(user_id, baseGroup .. '.' .. cargo)
        or vRP.HasGroup(user_id, baseGroup .. ' ' .. cargo) then
            return true
        end
    end
    return false
end

function Config.HasPermission(user_id, name)
    local perm = Config.Permissions[name]
    if not perm or not IS_SERVER or not vRP then
        return false
    end

    for _, baseGroup in ipairs(perm.Groups) do
        if hasGroupVariations(user_id, baseGroup) then
            return true
        end
    end

    -- Fallback: tenta como permissão direta do vRP
    return vRP.HasPermission(user_id, name) == true
end

function Config.IsPolice(user_id)
    return Config.HasPermission(user_id, 'Police')
end

-----------------------------------------------------------------------------
-- DEATH EVENT (ícones e nomes traduzidos para o killfeed)
-- Estrutura preservada por compatibilidade com server/functions.lua e
-- client/events.lua (que indexam por hash da arma).
-----------------------------------------------------------------------------
local WEAPON_ICON = 'https://docs.fivem.net/weapons/'

Config.DeathEvent = {
    WeaponClassIcons = {
        suicide  = WEAPON_ICON .. 'WEAPON_PISTOL.png',
        pistol   = WEAPON_ICON .. 'WEAPON_PISTOL_MK2.png',
        rifle    = WEAPON_ICON .. 'WEAPON_ASSAULTRIFLE.png',
        smg      = WEAPON_ICON .. 'WEAPON_MICROSMG.png',
        unarmed  = WEAPON_ICON .. 'WEAPON_UNARMED.png',
        sniper   = WEAPON_ICON .. 'WEAPON_HEAVYSNIPER.png',
        melee    = WEAPON_ICON .. 'WEAPON_KNUCKLE.png',
        shotgun  = WEAPON_ICON .. 'WEAPON_PUMPSHOTGUN.png',
        rpg      = WEAPON_ICON .. 'WEAPON_RPG.png',
        grenade  = WEAPON_ICON .. 'WEAPON_GRENADE.png',
        snowball = WEAPON_ICON .. 'WEAPON_SNOWBALL.png',
    },
}

-- Construímos a tabela "reasonsKill" a partir de listas planas para evitar
-- a duplicação massiva de chave/valor que existia anteriormente.
do
    local reasons = {}
    reasons['0'] = { reason = 'Suicídio', weapon = 'SUICIDE', class = 'suicide' }

    local function add(class, items)
        for weapon, label in pairs(items) do
            reasons[GetHashKey(weapon)] = {
                reason = label,
                weapon = weapon,
                class  = class,
            }
        end
    end

    add('unarmed', {
        WEAPON_UNARMED = 'Espancado',
    })
    add('pistol', {
        WEAPON_RUN_OVER_BY_CAR  = 'Atropelado',
        WEAPON_RAMMED_BY_CAR    = 'Atropelado',
        VEHICLE_WEAPON_ROTORS   = 'Atropelado',
        WEAPON_PISTOL           = 'Pistola',
        WEAPON_PISTOL_MK2       = 'Pistola MK2',
        WEAPON_COMBATPISTOL     = 'Pistola de Combate',
        WEAPON_APPISTOL         = 'Pistola AP',
        WEAPON_STUNGUN          = 'Pistola de Choque',
        WEAPON_PISTOL50         = 'Pistola .50',
        WEAPON_SNSPISTOL        = 'Pistola Fajuta',
        WEAPON_SNSPISTOL_MK2    = 'Pistola Fajuta MK2',
        WEAPON_HEAVYPISTOL      = 'Pistola Pesada',
        WEAPON_VINTAGEPISTOL    = 'Pistola Vintage',
        WEAPON_FLAREGUN         = 'Pistola Sinalizadora',
        WEAPON_MARKSMANPISTOL   = 'Pistola Atiradora',
        WEAPON_REVOLVER         = 'Pistola Revólver',
        WEAPON_REVOLVER_MK2     = 'Pistola Revólver MK2',
        WEAPON_DOUBLEACTION     = 'Pistola de Dupla Ação',
        WEAPON_RAYPISTOL        = 'Pistola de Raio',
        WEAPON_CERAMICPISTOL    = 'Pistola de Cerâmica',
        WEAPON_NAVYREVOLVER     = 'Pistola Revólver da Marinha',
        WEAPON_GADGETPISTOL     = 'Pistola de Gadget',
    })
    add('melee', {
        WEAPON_DAGGER        = 'Punhal',
        WEAPON_BAT           = 'Bastão',
        WEAPON_BOTTLE        = 'Garrafa de Vidro',
        WEAPON_CROWBAR       = 'Pé de Cabra',
        WEAPON_FLASHLIGHT    = 'Lanterna',
        WEAPON_GOLFCLUB      = 'Taco de Golf',
        WEAPON_HAMMER        = 'Martelo',
        WEAPON_HATCHET       = 'Machadinho',
        WEAPON_KNUCKLE       = 'Soco Inglês',
        WEAPON_KNIFE         = 'Faca',
        WEAPON_MACHETE       = 'Facão',
        WEAPON_SWITCHBLADE   = 'Canivete',
        WEAPON_NIGHTSTICK    = 'Cassetete',
        WEAPON_WRENCH        = 'Chave Inglesa',
        WEAPON_BATTLEAXE     = 'Machado de Batalha',
        WEAPON_POOLCUE       = 'Taco de Sinuca',
        WEAPON_STONE_HATCHET = 'Machado de Pedra',
    })
    add('smg', {
        WEAPON_MICROSMG       = 'Micro SMG',
        WEAPON_SMG            = 'SMG',
        WEAPON_SMG_MK2        = 'SMG MK2',
        WEAPON_ASSAULTSMG     = 'SMG de Assalto',
        WEAPON_COMBATPDW      = 'PDW de Combate',
        WEAPON_MACHINEPISTOL  = 'Pistola Metralhadora',
        WEAPON_MINISMG        = 'Mini SMG',
        WEAPON_RAYCARBINE     = 'Carabina de Raios',
    })
    add('shotgun', {
        WEAPON_PUMPSHOTGUN     = 'Espingarda Pump',
        WEAPON_PUMPSHOTGUN_MK2 = 'Espingarda Pump MK2',
        WEAPON_SAWNOFFSHOTGUN  = 'Espingarda Cerrada',
        WEAPON_ASSAULTSHOTGUN  = 'Espingarda de Assalto',
        WEAPON_BULLPUPSHOTGUN  = 'Espingarda Bullpup',
        WEAPON_MUSKET          = 'Espingarda de Mosquete',
        WEAPON_HEAVYSHOTGUN    = 'Espingarda Pesada',
        WEAPON_DBSHOTGUN       = 'Espingarda de Cano Duplo',
        WEAPON_AUTOSHOTGUN     = 'Espingarda Automática',
        WEAPON_COMBATSHOTGUN   = 'Espingarda de Combate',
    })
    add('rifle', {
        WEAPON_ASSAULTRIFLE       = 'Rifle de Assalto',
        WEAPON_ASSAULTRIFLE_MK2   = 'Rifle de Assalto MK2',
        WEAPON_CARBINERIFLE       = 'Carabina',
        WEAPON_CARBINERIFLE_MK2   = 'Carabina MK2',
        WEAPON_ADVANCEDRIFLE      = 'Rifle Avançado',
        WEAPON_SPECIALCARBINE     = 'Carabina Especial',
        WEAPON_SPECIALCARBINE_MK2 = 'Carabina Especial MK2',
        WEAPON_BULLPUPRIFLE       = 'Rifle Bullpup',
        WEAPON_BULLPUPRIFLE_MK2   = 'Rifle Bullpup MK2',
        WEAPON_COMPACTRIFLE       = 'Rifle Compacto',
        WEAPON_MILITARYRIFLE      = 'Rifle Militar',
        WEAPON_MG                 = 'Metralhadora',
        WEAPON_COMBATMG           = 'Metralhadora de Combate',
        WEAPON_COMBATMG_MK2       = 'Metralhadora de Combate MK2',
        WEAPON_GUSENBERG          = 'Metralhadora de Tambor',
    })
    add('sniper', {
        WEAPON_SNIPERRIFLE        = 'Rifle Sniper',
        WEAPON_HEAVYSNIPER        = 'Rifle Sniper Pesado',
        WEAPON_HEAVYSNIPER_MK2    = 'Rifle Sniper Pesado MK2',
        WEAPON_MARKSMANRIFLE      = 'Rifle de Atirador',
        WEAPON_MARKSMANRIFLE_MK2  = 'Rifle de Atirador MK2',
    })
    add('rpg', {
        WEAPON_RPG             = 'Lança Míssel (RPG)',
        WEAPON_GRENADELAUNCHER = 'Lançador de Granadas',
        WEAPON_MINIGUN         = 'Metralhadora Giratória',
        WEAPON_FIREWORK        = 'Lança Fogos',
        WEAPON_RAILGUN         = 'Arma de Raios',
        WEAPON_HOMINGLAUNCHER  = 'Lança Míssel Teleguiado',
        WEAPON_COMPACTLAUNCHER = 'Lançador Compacto',
        WEAPON_RAYMINIGUN      = 'Metralhadora Giratória de Raios',
    })
    add('grenade', {
        WEAPON_GRENADE          = 'Granada',
        WEAPON_BZGAS            = 'Granada Gás',
        WEAPON_MOLOTOV          = 'Molotov',
        WEAPON_STICKYBOMB       = 'Bomba Adesivo (C4)',
        WEAPON_PROXMINE         = 'Mina de Proximidade',
        WEAPON_PIPEBOMB         = 'Bomba Caseira',
        WEAPON_BALL             = 'Bola de Tênis',
        WEAPON_SMOKEGRENADE     = 'Granada de Fumaça',
        WEAPON_FLARE            = 'Granda de Clarão',
        WEAPON_PETROLCAN        = 'Galão de Gasolina',
        WEAPON_PARACHUTE        = 'Paraquedas',
        WEAPON_FIREEXTINGUISHER = 'Extintor de Incêndio',
        WEAPON_HAZARDCAN        = 'Rezidos Inflamáveis',
    })
    add('snowball', {
        WEAPON_SNOWBALL = 'Bola de Neve',
    })

    Config.DeathEvent.reasonsKill = reasons
end
