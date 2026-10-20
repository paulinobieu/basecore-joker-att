-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION · ROUPAS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Índice deste arquivo:
--   1. Peças
--   2. Roupa inicial
--   3. Peças escondidas do catálogo
--   4. Peças bloqueadas por modelo
-----------------------------------------------------------------------------------------------------------------------------------------

Clothes = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 1. PEÇAS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Cada peça vira um hexágono na trilha lateral da loja.
--
--   region   → cabeça, torso ou pernas; agrupa a peça na interface
--   id       → componente/prop do ped (GTA)
--   prop     → true = prop (chapéu, óculos...), false = componente
--   default  → índice de "sem peça". Number vale para os dois modelos;
--              table permite um por modelo
--   negative → a peça aceita o índice -1 (nenhuma) no catálogo
--   name     → título mostrado acima da grade
--   icon     → ícone do hexágono, resolvido pela interface
--              (nomes disponíveis em app/constants/icons.ts)
--   anim     → { dicionário, animação, duração } tocada ao vestir/tirar.
--              Sem anim, a troca é instantânea.
Clothes.Parts = {
    -- Cabeça
    ["hat"] = {
        region = "head", id = 0, prop = true, default = -1, negative = true,
        name = "CHAPÉU", icon = "chapeu",
        anim = { "veh@common@fp_helmet@", "take_off_helmet_stand", 700 },
    },
    ["glass"] = {
        region = "head", id = 1, prop = true, default = -1, negative = true,
        name = "ÓCULOS", icon = "oculos",
        anim = { "mini@ears_defenders", "takeoff_earsdefenders_idle", 500 },
    },
    ["ear"] = {
        region = "head", id = 2, prop = true, default = -1, negative = true,
        name = "ORELHA", icon = "orelha",
        anim = { "mini@ears_defenders", "takeoff_earsdefenders_idle", 500 },
    },
    ["mask"] = {
        region = "head", id = 1, prop = false, default = 0, negative = false,
        name = "MÁSCARA", icon = "mascara",
        anim = { "missfbi4", "takeoff_mask", 1100 },
    },
    ["accessory"] = {
        region = "head", id = 7, prop = false, default = 0, negative = false,
        name = "ACESSÓRIOS", icon = "acessorios",
    },

    -- Torso
    ["tshirt"] = {
        region = "chest", id = 8, prop = false, default = 15, negative = false,
        name = "CAMISA", icon = "camisas",
        anim = { "clothingshirt", "try_shirt_positive_d", 2500 },
    },
    ["torso"] = {
        region = "chest", id = 11, prop = false, default = 15, negative = false,
        name = "JAQUETA", icon = "jaqueta",
        anim = { "clothingshirt", "try_shirt_positive_d", 2500 },
    },
    ["arms"] = {
        region = "chest", id = 3, prop = false, default = 15, negative = false,
        name = "MÃOS", icon = "maos",
        anim = { "clothingshirt", "try_shirt_positive_d", 2500 },
    },
    ["vest"] = {
        region = "chest", id = 9, prop = false, default = 0, negative = false,
        name = "COLETE", icon = "coletes",
        anim = { "clothingshirt", "try_shirt_positive_d", 2500 },
    },
    ["backpack"] = {
        region = "chest", id = 5, prop = false, default = 0, negative = false,
        name = "MOCHILA", icon = "mochila",
        anim = { "clothingshirt", "try_shirt_positive_d", 2500 },
    },
    ["decals"] = {
        region = "chest", id = 10, prop = false, default = 0, negative = false,
        name = "ADESIVO", icon = "adesivo",
        anim = { "clothingshirt", "try_shirt_positive_d", 2500 },
    },
    ["watch"] = {
        region = "chest", id = 6, prop = true, default = -1, negative = true,
        name = "RELÓGIO", icon = "relogio",
    },
    ["bracelet"] = {
        region = "chest", id = 7, prop = true, default = -1, negative = true,
        name = "BRACELETE", icon = "bracelete",
    },

    -- Pernas
    ["pants"] = {
        region = "legs", id = 4, prop = false, negative = false,
        default = { ["mp_m_freemode_01"] = 18, ["mp_f_freemode_01"] = 15 },
        name = "CALÇAS", icon = "calca",
        anim = { "clothingtrousers", "try_trousers_neutral_c", 2500 },
    },
    ["shoes"] = {
        region = "legs", id = 6, prop = false, negative = false,
        default = { ["mp_m_freemode_01"] = 34, ["mp_f_freemode_01"] = 35 },
        name = "SAPATO", icon = "sapato",
        anim = { "clothingshoes", "try_shoes_positive_d", 2200 },
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 2. ROUPA INICIAL
-----------------------------------------------------------------------------------------------------------------------------------------
-- Com o que o personagem sai vestido quando ainda não tem roupa gravada.
Clothes.Default = {
    ["hat"]       = { item = -1, texture = 0 },
    ["glass"]     = { item = 0,  texture = 0 },
    ["ear"]       = { item = -1, texture = 0 },
    ["mask"]      = { item = 0,  texture = 0 },
    ["accessory"] = { item = 0,  texture = 0 },
    ["tshirt"]    = { item = 1,  texture = 0 },
    ["torso"]     = { item = 0,  texture = 0 },
    ["arms"]      = { item = 0,  texture = 0 },
    ["vest"]      = { item = 0,  texture = 0 },
    ["backpack"]  = { item = 0,  texture = 0 },
    ["decals"]    = { item = 0,  texture = 0 },
    ["watch"]     = { item = -1, texture = 0 },
    ["bracelet"]  = { item = -1, texture = 0 },
    ["pants"]     = { item = 0,  texture = 0 },
    ["shoes"]     = { item = 0,  texture = 0 },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 3. PEÇAS ESCONDIDAS DO CATÁLOGO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Índices que nem aparecem na loja e que o servidor recusa. Use para cortar
-- as roupas de DLC que o seu servidor não usa.
--
-- Aceita índice solto ("14") ou faixa fechada ("198-320").
Clothes.Hidden = {
    -- Vazio de propÃ³sito: tudo que o jogo carregar, inclusive add-ons,
    -- precisa entrar no catÃ¡logo de todas as categorias.
    ["Male"] = {},
    ["Female"] = {},
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 4. PEÇAS BLOQUEADAS POR MODELO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Diferente de Clothes.Hidden: a peça continua no catálogo, só não veste no
-- modelo listado. Use para roupas que quebram em um dos dois corpos.
--
--   [peça] = { [índice] = { ["modelo"] = true } }
Clothes.Blocked = {
    ["hat"] = {
        [1] = { ["mp_f_freemode_01"] = true },                                  -- só o corpo feminino
        [2] = { ["mp_m_freemode_01"] = true },                                  -- só o corpo masculino
        [3] = { ["mp_m_freemode_01"] = true, ["mp_f_freemode_01"] = true },     -- nenhum dos dois
    },
}
