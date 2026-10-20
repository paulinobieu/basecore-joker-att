-- ══════════════════════════════════════════════
--              CORE NETWORK LTDA
-- ══════════════════════════════════════════════
-- Todos os direitos reservados © Core Network Ltda.
--
-- ATENÇÃO: arquivo de configuração aberto para adaptação. NÃO altere nada
-- aqui se você não tem conhecimento de programação — mudanças incorretas
-- podem quebrar o funcionamento do sistema.
-- ══════════════════════════════════════════════

globalConfig = {}

-- Comando pra abrir o tablet (lista de partidas) e teclas usadas em jogo.
globalConfig.system = {
    command =
    "coregame",            -- comando de chat/console que abre o tablet
    scoreboardKey = "TAB", -- tecla que mostra o placar ao vivo durante a partida
    buyMenuControl = 29    -- controle (INPUT_) que abre a loja de armamentos na fase de compra
}

-- Marcador 3D no mapa que o jogador usa pra abrir o tablet (ex.: em frente à
-- delegacia). Pode cadastrar quantos pontos quiser em "coords".
globalConfig.markers = {
    enabled          = true,                                -- true = mostra o marcador no mundo, false = desativa
    key              = 38,                                  -- tecla de interação (INPUT_) pra abrir o tablet no marcador
    drawDistance     = 8.0,                                 -- distância (metros) em que o marcador começa a ser desenhado
    interactDistance = 1.5,                                 -- distância (metros) em que a tecla de interação passa a funcionar

    markerType       = 21,                                  -- tipo do marcador (ver lista de MarkerType do FiveM/GTA)
    size             = vec3(0.5, 0.5, 0.5),                 -- tamanho do marcador
    color            = { r = 1, g = 67, b = 187, a = 180 }, -- cor do marcador (RGBA)

    coords           = {
        -- adicione vec3(x, y, z) aqui pra cada local onde o marcador deve aparecer
    },
}

-- Cor de destaque (accent) usada em toda a interface (tablet, HUD, loja, etc.).
globalConfig.nuiColors = {
    accent = "#0143bb", -- hexadecimal, ex.: "#0143bb"

}

-- Logo exibido no centro do placar (HUD). Link http(s) terminando em .png/.jpg/.gif.
-- Deixe "" para usar o logo padrão do recurso (web/logos/logo.png).
globalConfig.hudLogo = ""

-- Regras gerais das partidas criadas na aba "Partidas" (fora do Duelo).
globalConfig.matches = {
    maxBetValue       = 100000, -- valor máximo de aposta permitido ao criar uma partida
    maxPlayersPerTeam = 10,     -- máximo de jogadores por time que o criador pode escolher
    armour            = false,  -- true = todo jogador já entra com colete de graça
    energetic         = true,   -- false = Desative a mecânica do uso de energético com faca e itens similares.
}

-- Modo Duelo: times fixos, desafio entre líderes e votação de mapa/arma.
globalConfig.duel = {
    maxTeamMembers           = 5,  -- máximo de jogadores por time de duelo
    mapVoteDuration          = 30, -- segundos que a votação de mapa fica aberta
    weaponVoteDuration       = 30, -- segundos que a votação de modo de arma fica aberta (só no modo arena)
    challengeResponseTimeout = 10, -- segundos que o time desafiado tem pra aceitar/recusar antes de expirar
    rounds                   = 12, -- rounds da partida quando o modo é Plante/Desarme
    arenaRounds              = 6,  -- rounds da partida quando o modo é Arena
}

-- Modo Plante/Desarme (bomba): tempos e distâncias da bomba.
globalConfig.plantDefuse = {
    plantTime        = 4,    -- segundos parado pra plantar a bomba
    defuseTime       = 10,   -- segundos parado pra desarmar sem kit
    defuseTimeKit    = 5,    -- segundos parado pra desarmar usando o kit de desarme
    explodeTime      = 40,   -- segundos entre o plante e a explosão
    defuseRadius     = 3.0,  -- distância (metros) em que dá pra começar a desarmar
    pickupRadius     = 2.0,  -- distância (metros) em que dá pra pegar a bomba no chão
    soundVolume      = 0.4,  -- volume do bipe da bomba armada
    soundMaxDistance = 45.0, -- distância máxima (metros) em que o bipe ainda é ouvido
}

-- Granada de fumaça: duração e distâncias de bloqueio de visão/som.
globalConfig.smoke = {
    explodeTime             = 5000,  -- ms até a granada estourar depois de lançada
    smokeTime               = 35000, -- ms que a fumaça permanece no ar
    smokeSize               = 2.0,   -- tamanho do efeito de fumaça
    smokeVisibilityDistance = 80.0,  -- distância (metros) considerada pra bloqueio visual
    smokeScreenDistance     = 15.0,  -- distância (metros) em que a tela do jogador fica esbranquiçada dentro da fumaça
    maxThrowDistance        = 60.0,  -- distância máxima (metros) que a granada pode ser arremessada
}

-- Sistema de dinheiro: quanto cada jogador começa e ganha por round/kill.
globalConfig.economy = {
    startMoney          = 800,                -- dinheiro inicial de cada jogador na partida
    maxMoney            = 16000,              -- teto de dinheiro acumulado
    buyPhaseDuration    = 15,                 -- segundos de loja liberada no início de cada round
    dropPickupRadius    = 2.0,                -- distância (metros) pra pegar arma largada no chão
    defuseKitProp       = "w_am_digiscanner", -- prop usado pra representar o kit de desarme no mundo

    winBonus            = {                   -- bônus de dinheiro pro time que VENCEU o round, por motivo da vitória
        elimination   = 3250,                 -- venceu eliminando o time inimigo
        bomb_exploded = 3500,                 -- venceu porque a bomba explodiu
        bomb_defused  = 3250,                 -- venceu desarmando a bomba
        timeout       = 3250,                 -- venceu porque o tempo do round acabou
    },

    lossBonus           = { 1400, 1900, 2400, 2900, 3400 }, -- bônus pro time que PERDEU, crescente a cada round perdido seguido (streak)

    killBonusByCategory = {                                 -- dinheiro ganho por abate, de acordo com a categoria da arma usada
        knife    = 1500,
        pistols  = 300,
        smgs     = 600,
        rifles   = 300,
        snipers  = 100,
        grenades = 300,
    },
    killBonusDefault    = 300, -- usado quando a arma não está em nenhuma categoria acima

    bombPlantBonusTeam  = 800, -- bônus pro time inteiro quando alguém planta a bomba
    bombDefuseBonus     = 300, -- bônus extra pra quem desarma a bomba
    assistBonus         = 50,  -- bônus por assistência num abate
}

-- Nome exibido de cada categoria da loja de armamentos (chave = mesma usada em shopItems.category).
globalConfig.shopCategoryLabels = {
    equipment = "Equipamento",
    pistols   = "Pistolas",
    smgs      = "Submetralhadoras",
    rifles    = "Fuzis",
    grenades  = "Granadas",
}

-- Itens vendidos na loja. Cada item aceita:
--   id         -> identificador único do item
--   name       -> nome exibido na loja
--   category   -> categoria (deve existir em shopCategoryLabels)
--   price      -> preço em dinheiro
--   weapon     -> hash da arma (WEAPON_...) dada ao comprar (omitir se não for arma)
--   weaponName -> nome do modelo da arma (usado pra troca de skin/exibição)
--   armor      -> quantidade de colete dado (só itens de equipamento)
--   defuseKit  -> true = esse item é o kit de desarme
globalConfig.shopItems = {
    { id = "armor_half",         name = "Meio Colete",       category = "equipment", price = 400,  armor = 50 },
    { id = "armor_full",         name = "Colete Full",       category = "equipment", price = 650,  armor = 100 },
    { id = "defuse_kit",         name = "Kit de Desarme",    category = "equipment", price = 400,  defuseKit = true },

    { id = "pistol",             name = "FIVE",              category = "pistols",   price = 500,  weapon = "WEAPON_PISTOL_MK2",         weaponName = "weapon_pistol_mk2" },
    { id = "combatpistol",       name = "Glock",             category = "pistols",   price = 500,  weapon = "WEAPON_COMBATPISTOL",       weaponName = "weapon_combatpistol" },
    { id = "pistol50",           name = "Desert",            category = "pistols",   price = 700,  weapon = "WEAPON_PISTOL50",           weaponName = "weapon_pistol50" },

    { id = "microsmg",           name = "Uzi",               category = "smgs",      price = 1050, weapon = "WEAPON_MICROSMG",           weaponName = "weapon_microsmg" },
    { id = "smg",                name = "MP5",               category = "smgs",      price = 1250, weapon = "WEAPON_SMG",                weaponName = "weapon_smg" },
    { id = "assaultsmg",         name = "MTAR",              category = "smgs",      price = 1700, weapon = "WEAPON_ASSAULTSMG",         weaponName = "weapon_assaultsmg" },

    { id = "carbinerifle",       name = "M4",                category = "rifles",    price = 2900, weapon = "WEAPON_CARBINERIFLE",       weaponName = "weapon_carbinerifle" },
    { id = "assaultrifle_mk2",   name = "AK",                category = "rifles",    price = 2700, weapon = "WEAPON_ASSAULTRIFLE_MK2",   weaponName = "weapon_assaultrifle_mk2" },
    { id = "specialcarbine_mk2", name = "G3",                category = "rifles",    price = 3100, weapon = "WEAPON_SPECIALCARBINE_MK2", weaponName = "weapon_specialcarbine_mk2" },
    { id = "sniperrifle",        name = "AWP",               category = "rifles",    price = 4750, weapon = "WEAPON_SNIPERRIFLE",        weaponName = "weapon_sniperrifle" },

    { id = "grenade",            name = "Granada",           category = "grenades",  price = 300,  weapon = "WEAPON_GRENADE" },
    { id = "smokegrenade",       name = "Granada de Fumaça", category = "grenades",  price = 300,  weapon = "WEAPON_CORESMOKE" },
    { id = "molotov",            name = "Molotov",           category = "grenades",  price = 400,  weapon = "WEAPON_MOLOTOV" },
}

-- A qual categoria (da loja) cada arma pertence. Usado pra saber o bônus de
-- abate correto e pra organizar o inventário/hotbar do jogador.
globalConfig.weaponCategories = {
    WEAPON_KNIFE              = "knife",

    WEAPON_PISTOL_MK2         = "pistols",
    WEAPON_COMBATPISTOL       = "pistols",
    WEAPON_PISTOL50           = "pistols",

    WEAPON_MICROSMG           = "smgs",
    WEAPON_SMG                = "smgs",
    WEAPON_ASSAULTSMG         = "smgs",

    WEAPON_CARBINERIFLE       = "rifles",
    WEAPON_ASSAULTRIFLE_MK2   = "rifles",
    WEAPON_SPECIALCARBINE_MK2 = "rifles",

    WEAPON_SNIPERRIFLE        = "snipers",

    WEAPON_GRENADE            = "grenades",
    WEAPON_SMOKEGRENADE       = "grenades",
    WEAPON_CORESMOKE          = "grenades",
    WEAPON_MOLOTOV            = "grenades",
}

-- Prop (modelo 3D) usado quando a arma é largada/exibida solta no mundo.
globalConfig.weaponProps = {
    WEAPON_PISTOL_MK2         = "w_pi_pistolmk2",
    WEAPON_COMBATPISTOL       = "w_pi_combatpistol",
    WEAPON_PISTOL50           = "w_pi_pistol50",

    WEAPON_MICROSMG           = "w_sb_microsmg",
    WEAPON_SMG                = "w_sb_smg",
    WEAPON_ASSAULTSMG         = "w_sb_assaultsmg",

    WEAPON_CARBINERIFLE       = "w_ar_carbinerifle",
    WEAPON_ASSAULTRIFLE_MK2   = "w_ar_assaultrifle_mk2",
    WEAPON_SPECIALCARBINE_MK2 = "w_ar_specialcarbine_mk2",

    WEAPON_SNIPERRIFLE        = "w_sr_sniperrifle",
}

-- Modos de arma disponíveis pra votação no modo Arena. Chave = nome exibido
-- na votação, valor = chave interna usada nas outras tabelas abaixo.
globalConfig.weaponModes = {
    ["Apenas Pistolas"] = "Pistolas",
    ["Apenas Fuzil"]    = "Fuzil",
    ["Apenas Subs"]     = "Subs",
    ["Misto"]           = "Misto",
}

-- Quais armas cada jogador recebe automaticamente de acordo com o modo de
-- arma escolhido (Arena). "Misto" alterna entre as armas na ordem de
-- mixedModeSequence a cada round.
globalConfig.weaponsForModes = {
    ["Pistolas"] = { "WEAPON_PISTOL_MK2" },
    ["Fuzil"]    = { "WEAPON_SPECIALCARBINE_MK2" },
    ["Subs"]     = { "WEAPON_ASSAULTSMG" },
    ["Misto"]    = { "WEAPON_SPECIALCARBINE_MK2", "WEAPON_ASSAULTSMG", "WEAPON_PISTOL_MK2" },
}

-- Ordem de rotação das armas no modo "Misto" (um item por round, recomeça
-- do início quando chega no fim da lista).
globalConfig.mixedModeSequence = {
    "Pistolas",
    "Subs",
    "Fuzil",
}

-- Lista de mapas disponíveis pra escolher/votar. Cada nome aqui precisa ter
-- uma entrada correspondente em globalConfig.mapsData logo abaixo.
globalConfig.maps = {
    "Mirage Exclusive",
    "Dust 1.6",
    "Dust Go",
    "Inferno",
    "Haven",
    "ItalyV1",
    "ClockTower",
    "Observatório",
    "Teatro",
    "Pier",
    "Prefeitura",
    "Predio",
    "Labirinto",
    "Ilha",
    "Paleto",
    "Porto",
    "Train",
    "Pool"
}

-- Dados de cada mapa listado em globalConfig.maps. Campos aceitos:
--   attackerTeamSpawn / defenderTeamSpawn -> vec3 de spawn de cada time
--   roundDuration                         -> segundos de duração do round
--   roundCountdown                        -> segundos de contagem antes do round começar
--   image                                 -> caminho da imagem de preview (pasta web/)
--   modes                                 -> lista de modos que esse mapa aceita
--                                            (omitir = aceita plante/desarme e arena)
--   bombs                                 -> sítios de bomba, só usado no modo plante/desarme
--                                            (["NOME"] = { coords = vec3(...), radius = raio })
globalConfig.mapsData = {
    ["Mirage Exclusive"] = {
        attackerTeamSpawn = vec3(-2613.64, -2718.96, 457.89),
        defenderTeamSpawn = vec3(-2719.95, -2708.05, 453.97),
        roundDuration     = 180,
        roundCountdown    = 3,
        image             = "arenas/mirage.png",
        bombs             = {
            ["A"] = { coords = vec3(-2688.54, -2743.06, 457.56), radius = 6.0 },
            ["B"] = { coords = vec3(-2684.37, -2653.52, 457.56), radius = 6.0 },
        },
    },

    ["Dust 1.6"] = {
        attackerTeamSpawn = vec3(-5839.81, 1787.44, 674.13),
        defenderTeamSpawn = vec3(-5886.45, 1857.57, 667.73),
        roundDuration     = 180,
        roundCountdown    = 3,
        image             = "arenas/dust.png",
        bombs             = {
            ["A"] = { coords = vec3(-5874.03, 1876.63, 673.32), radius = 6.0 },
            ["B"] = { coords = vec3(-5919.83, 1825.28, 670.93), radius = 6.0 },
        },
    },

    ["Dust Go"] = {
        attackerTeamSpawn = vec3(-4464.64, 2754.06, 412.34),
        defenderTeamSpawn = vec3(-4437.01, 2841.37, 405.94),
        roundDuration     = 180,
        roundCountdown    = 3,
        image             = "arenas/dust2.png",
        bombs             = {
            ["A"] = { coords = vec3(-4416.89, 2841.49, 411.67), radius = 6.0 },
            ["B"] = { coords = vec3(-4484.75, 2845.46, 409.25), radius = 6.0 },
        },
    },

    ["Inferno"] = {
        attackerTeamSpawn = vec3(-3845.89, 1822.07, 285.39),
        defenderTeamSpawn = vec3(-3755.3, 1856.85, 288.57),
        roundDuration     = 180,
        roundCountdown    = 3,
        image             = "arenas/inferno.png",
        bombs             = {
            ["A"] = { coords = vec3(-3762.89, 1819.05, 290.34), radius = 6.0 },
            ["B"] = { coords = vec3(-3802.87, 1870.73, 290.34), radius = 6.0 },
        },
    },

    ["Haven"] = {
        attackerTeamSpawn = vec3(3349.97, 6366.28, 84.52),
        defenderTeamSpawn = vec3(3321.02, 6446.5, 84.5),
        roundDuration     = 180,
        roundCountdown    = 3,
        image             = "arenas/haven.png",
        bombs             = {
            ["A"] = { coords = vec3(3357.83, 6431.56, 84.5), radius = 6.0 },
            ["B"] = { coords = vec3(3329.37, 6412.26, 84.52), radius = 6.0 },
            ["C"] = { coords = vec3(3297.87, 6398.52, 83.76), radius = 6.0 }
        },
    },

    ["Train"] = {
        attackerTeamSpawn = vec3(-3833.11, 1598.02, 286.48),
        defenderTeamSpawn = vec3(-3770.8, 1548.26, 284.58),
        roundDuration     = 180,
        roundCountdown    = 3,
        image             = "arenas/train.png",
        bombs             = {
            ["A"] = { coords = vec3(-3779.84, 1568.26, 287.56), radius = 6.0 },
            ["B"] = { coords = vec3(-3795.15, 1549.38, 283.89), radius = 6.0 },
        },
    },

    ["ItalyV1"] = {
        attackerTeamSpawn = vec3(-4862.02, 4053.89, 415.06),
        defenderTeamSpawn = vec3(-4838.54, 4155.52, 421.03),
        roundDuration     = 180,
        roundCountdown    = 3,
        modes             = { "arena" },
        image             = "arenas/italy.png",
    },

    ["Pool"] = {
        attackerTeamSpawn = vec3(-4106.18, 952.25, 8.51),
        defenderTeamSpawn = vec3(-4105.08, 976.9, 8.51),
        roundDuration     = 180,
        roundCountdown    = 3,
        modes             = { "arena" },
        image             = "arenas/pool.png",
    },

    ["ClockTower"] = {
        attackerTeamSpawn = vec3(-3187.83, -2572.74, 12.24),
        defenderTeamSpawn = vec3(-3331.67, -2486.48, 10.75),
        roundDuration     = 180,
        roundCountdown    = 3,
        modes             = { "arena" },
        image             = "arenas/clocktower.png",
    },

    ["Observatório"] = {
        attackerTeamSpawn = vec3(858.29, 526.33, 125.92),
        defenderTeamSpawn = vec3(660.4, 603.47, 129.06),
        roundDuration     = 180,
        roundCountdown    = 3,
        modes             = { "arena" },
        image             = "arenas/observatorio.png",
    },

    ["Teatro"] = {
        attackerTeamSpawn = vec3(-1001.16, -531.81, 36.71),
        defenderTeamSpawn = vec3(-1256.48, -518.26, 31.56),
        roundDuration     = 180,
        roundCountdown    = 3,
        modes             = { "arena" },
        image             = "arenas/teatro.png",
    },

    ["Pier"] = {
        attackerTeamSpawn = vec3(-1612.52, -1009.1, 13.02),
        defenderTeamSpawn = vec3(-1713.31, -1136.7, 13.07),
        roundDuration     = 180,
        roundCountdown    = 3,
        modes             = { "arena" },
        image             = "arenas/pier.png",
    },

    ["Prefeitura"] = {
        attackerTeamSpawn = vec3(2526.26, -289.03, 92.99),
        defenderTeamSpawn = vec3(2486.87, -454.2, 92.98),
        roundDuration     = 180,
        roundCountdown    = 3,
        modes             = { "arena" },
        image             = "arenas/prefeitura.png",
    },

    ["Predio"] = {
        attackerTeamSpawn = vec3(120.71, -878.59, 134.78),
        defenderTeamSpawn = vec3(83.2, -864.77, 134.78),
        roundDuration     = 180,
        roundCountdown    = 3,
        modes             = { "arena" },
        image             = "arenas/predio.png",
    },

    ["Labirinto"] = {
        attackerTeamSpawn = vec3(-2306.8, 235.86, 167.6),
        defenderTeamSpawn = vec3(-2285.86, 163.88, 167.59),
        roundDuration     = 180,
        roundCountdown    = 3,
        modes             = { "arena" },
        image             = "arenas/labirinto.png",
    },

    ["Ilha"] = {
        attackerTeamSpawn = vec3(5029.06, -5120.08, 4.77),
        defenderTeamSpawn = vec3(5137.05, -5574.32, 39.75),
        roundDuration     = 180,
        roundCountdown    = 3,
        modes             = { "arena" },
        image             = "arenas/ilha.png",
    },

    ["Paleto"] = {
        attackerTeamSpawn = vec3(143.67, 6594.95, 31.85),
        defenderTeamSpawn = vec3(-438.17, 6038.86, 31.35),
        roundDuration     = 180,
        roundCountdown    = 3,
        modes             = { "arena" },
        image             = "arenas/paleto.png",
    },

    ["Porto"] = {
        attackerTeamSpawn = vec3(881.16, -2979.03, 5.91),
        defenderTeamSpawn = vec3(1193.3, -2988.72, 5.91),
        roundDuration     = 180,
        roundCountdown    = 3,
        modes             = { "arena" },
        image             = "arenas/porto.png",
    },
}
