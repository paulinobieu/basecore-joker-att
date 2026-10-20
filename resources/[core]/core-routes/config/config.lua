Routes = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- IMAGENS
-----------------------------------------------------------------------------------------------------------------------------------------

Routes.Images = {
    -- URL base para as imagens dos itens (consome ItemsURL do Global.lua)
    BaseUrl   = ItemsURL,
    -- Extensao dos arquivos de imagem
    Extension = ".png",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- COR DO TEMA (frontend)
-- Cor hexadecimal aplicada como variavel CSS --primary na interface NUI.
-- Pode ser sobrescrita individualmente por ponto, se necessario.
-----------------------------------------------------------------------------------------------------------------------------------------

Routes.ThemeColor = "#dc1553"

-----------------------------------------------------------------------------------------------------------------------------------------
-- POSIÇÃO DO HUD DE ROTA (NotificationPosition)
-- Define onde o painel de progresso da rota aparece na tela durante a coleta.
-- Valores aceitos: "bottom-left" (padrao, evita o minimapa), "bottom-center", "bottom-right",
--                  "top-left",    "top-center",    "top-right",
--                  "middle-left", "middle-right"
-----------------------------------------------------------------------------------------------------------------------------------------

Routes.NotificationPosition = "bottom-left"

-----------------------------------------------------------------------------------------------------------------------------------------
-- INTERAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------

Routes.Interaction = {
    -- Sistema de interacao utilizado para abrir os pontos de rota
    -- Valores aceitos: "sleepless" | "ox_target" | "marker"
    System = "sleepless",

    -- Distancia em metros em que o painel e fechado automaticamente ao se afastar do ponto
    AutoCloseDistance = 4.0,

    -- Configuracoes do sleepless_interact (utilizado quando System = "sleepless")
    Sleepless = {
        Label = "Abrir Rotas",
        Icon = "route",
        -- Distancia maxima para exibir a interacao
        Distance = 2.0,
        -- Distancia maxima para permitir a interacao
        InteractDistance = 2.0,
    },

    -- Configuracoes do ox_target (utilizado quando System = "ox_target")
    OxTarget = {
        Label = "Abrir Rotas",
        Icon = "fa-solid fa-route",
        -- Distancia maxima para exibir a opcao
        Distance = 2.0,
        -- Raio da zona esferica criada ao redor do ponto
        Radius = 1.0,
    },

    -- Configuracoes do marcador 3D no chao (utilizado quando System = "marker")
    Marker = {
        -- Distancia em que o marcador comeca a ser desenhado
        DrawDistance = 12.0,
        -- Distancia em que a tecla de interacao e exibida e pode ser pressionada
        OpenDistance = 1.5,
        -- Tecla de interacao (38 = E)
        Key = 38,
        -- Texto exibido sobre o marcador quando o jogador esta proximo
        Text = "~g~E~w~  ABRIR ROTAS",
        -- Tipo do marcador GTA (2 = cilindro, 1 = seta)
        Type = 2,
        -- Deslocamento vertical do marcador em relacao a coordenada Z
        ZOffset = 0.15,
        -- Deslocamento vertical do texto em relacao a coordenada Z
        TextZOffset = 0.35,
        -- Escala do marcador
        Scale = vec3(0.18, 0.18, 0.18),
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGURAÇÕES POR ZONA (ESTILO DE ROTA)
-----------------------------------------------------------------------------------------------------------------------------------------

Routes.ZoneSettings = {
    -- Zona terrestre — coleta manual a pe com animacao
    terrestrial = {
        -- Se true, coleta automaticamente ao entrar no raio
        autoCollect = false,
        -- Distancia em metros para permitir a coleta
        collectDistance = 3.0,
        -- Distancia em metros para exibir o marcador
        markerDistance = 30.0,
        -- Tipo do marcador GTA (2 = cilindro)
        markerType = 2,
        -- Escala do marcador
        markerScale = 1.0,
        -- Se exibe efeito de fumaca (flare) no ponto
        showFlare = false,
        -- Distancia para ativar a fumaca
        flareDistance = 0,
        -- Se exige que o jogador esteja a pe para coletar
        requiresOnFoot = true,
        -- Animacao executada ao coletar (nil = sem animacao)
        collectAnim = {
            dict = "anim@gangops@facility@servers@bodysearch@",
            anim = "player_search",
            duration = 2000,
        },
    },

    -- Zona aquatica — coleta automatica dentro de embarcacao
    aquatic = {
        autoCollect = true,
        collectDistance = 6.0,
        markerDistance = 80.0,
        markerType = 2,
        markerScale = 2.0,
        showFlare = true,
        flareDistance = 80.0,
        requiresOnFoot = false,
        collectAnim = nil,
    },

    -- Zona aerea — coleta automatica em aeronave, marcador grande
    aerial = {
        autoCollect = true,
        collectDistance = 15.0,
        markerDistance = 250.0,
        -- Tipo 6 = seta vertical (visivel de longe)
        markerType = 6,
        markerScale = 30.0,
        showFlare = false,
        flareDistance = 0,
        requiresOnFoot = false,
        collectAnim = nil,
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- MAPEAMENTO DE ESTILO (frontend → zona interna)
-- Converte o estilo selecionado na NUI para a chave de zona usada internamente.
-----------------------------------------------------------------------------------------------------------------------------------------

Routes.StyleToZone = {
    -- Estilo "terrestre" na NUI = zona "terrestrial" no codigo
    terrestre = "terrestrial",
    -- Estilo "aquatica" na NUI = zona "aquatic" no codigo
    aquatica  = "aquatic",
    -- Estilo "aerea" na NUI = zona "aerial" no codigo
    aerea     = "aerial",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- POOLS DE COORDENADAS (importadas do routes/shared.lua)
-- Cada pool é um conjunto de pontos de coleta usados durante a execução da rota.
-- As rotas referenciam esses pools via DefaultCoordsZones ou CoordsZones personalizado.
-----------------------------------------------------------------------------------------------------------------------------------------

Routes.Coords = {

    New = {
        { 201.91,   2461.28, 55.18 },
        { 317.58,   2623.11, 43.94 },
        { 591.14,   2744.09, 41.53 },
        { 983.97,   2718.32, 38.99 },
        { 1141.89,  2664.02, 37.64 },
        { 2046.43,  2954.46, 47.23 },
        { 2341.3,   3128.4,  47.7 },
        { 2998.61,  4099.32, 56.48 },
        { 2855.61,  4446.1,  48.02 },
        { 2932.24,  4624.07, 48.71 },
        { 1706.13,  6425.23, 32.18 },
        { 132.32,   6638.01, 31.29 },
        { 38.67,    6454.32, 30.9 },
        { -112.9,   6242.89, 30.8 },
        { -773.63,  5597.12, 33.04 },
        { -1491.04, 4981.69, 62.82 },
        { -2193.6,  4290.47, 48.66 },
        { -2544.22, 2316.62, 32.71 },
        { -1313.31, 2507.6,  21.48 },
        { -1105.58, 2696.21, 18.1 },
        { -457.12,  2862.08, 34.66 },
        { -35.82,   2871.0,  59.11 },
        { 195.7,    3031.02, 43.79 },
        { 387.33,   3585.34, 32.77 },
        { 910.8,    3644.19, 32.17 },
    },

    Aquaticas = {
        { 1329.21, 3844.31, 32.7 },
        { 1204.28, 3830.63, 30.95 },
        { 1135.11, 3737.53, 30.53 },
        { 1035.4,  3745.12, 30.77 },
        { 888.82,  3773.96, 30.03 },
        { 835.9,   3815.98, 30.93 },
        { 814.18,  3909.85, 30.52 },
        { 764.63,  3990.16, 30.57 },
        { 700.44,  4067.65, 30.56 },
        { 624.18,  4109.49, 29.76 },
        { 531.26,  4132.86, 30.22 },
        { 460.17,  4176.22, 30.68 },
        { 368.96,  4092.71, 30.39 },
        { 307.41,  4035.27, 30.72 },
        { 274.36,  3953.31, 30.41 },
        { 194.1,   3859.16, 30.26 },
        { 186.31,  3736.44, 29.95 },
        { 233.58,  3668.6,  30.03 },
        { 259.2,   3730.3,  30.06 },
        { 295.75,  3808.49, 30.67 },
        { 431.68,  3825.7,  30.81 },
        { 490.75,  3851.77, 29.41 },
        { 575.69,  3889.49, 31.86 },
        { 686.17,  3895.2,  30.52 },
        { 766.75,  3885.09, 30.41 },
        { 846.26,  3875.02, 30.12 },
        { 900.01,  3890.28, 30.29 },
        { 942.08,  3931.21, 31.32 },
        { 1058.28, 4030.74, 30.58 },
        { 1142.94, 4066.58, 30.35 },
        { 1264.82, 4024.53, 30.47 },
        { 1339.37, 3961.29, 29.93 },
        { 1414.75, 3952.6,  29.81 },
        { 1575.36, 3985.69, 29.98 },
        { 1662.82, 4031.26, 30.02 },
        { 1701.14, 4089.67, 29.52 },
        { 1759.06, 4169.9,  30.53 },
        { 1824.34, 4228.16, 30.48 },
        { 1897.74, 4258.43, 30.97 },
        { 2125.62, 4349.76, 29.45 },
        { 2228.63, 4358.56, 30.08 },
        { 2297.68, 4335.83, 30.41 },
        { 2336.86, 4257.75, 30.03 },
        { 2323.09, 4167.09, 30.13 },
        { 2235.97, 4074.93, 29.97 },
        { 2154.85, 4035.62, 30.33 },
        { 2065.34, 4114.87, 32.09 },
        { 2048.42, 4236.93, 29.34 },
        { 2043.92, 4343.49, 29.78 },
        { 2092.77, 4415.07, 30.3 },
        { 2163.15, 4476.89, 31.23 },
        { 2122.3,  4544.94, 29.58 },
        { 2063.33, 4471.44, 29.57 },
        { 1995.65, 4384.26, 31.16 },
        { 1932.59, 4301.7,  30.59 },
        { 1816.02, 4243.0,  30.59 },
        { 1737.32, 4239.89, 30.3 },
        { 1584.68, 4226.33, 30.24 },
        { 1491.76, 4220.56, 29.94 },
        { 1490.06, 4136.93, 29.68 },
        { 1514.26, 4005.13, 29.63 },
        { 1418.84, 3920.48, 30.55 },
    },

    Aerea = {
        { -1314.41, -2961.54, 43.33 },
        { -1532.24, -2689.55, 67.71 },
        { -1608.48, -2366.32, 82.29 },
        { -1647.73, -2026.91, 79.85 },
        { -1854.84, -1526.81, 94.32 },
        { -1846.62, -1082.66, 110.85 },
        { -1729.27, -754.93,  93.09 },
        { -1608.45, -265.41,  106.07 },
        { -1789.58, 78.54,    97.21 },
        { -1975.91, 408.42,   123.69 },
        { -1818.41, 752.21,   156.10 },
        { -1663.11, 957.32,   153.88 },
        { -1626.76, 1235.75,  153.91 },
        { -1513.73, 1522.14,  139.51 },
        { -1469.64, 1932.82,  126.75 },
        { -1316.47, 2281.47,  106.47 },
        { -1425.89, 2631.97,  8.29 },
        { -1121.46, 2789.43,  13.22 },
        { -795.02,  2834.88,  26.89 },
        { -414.11,  2958.44,  18.42 },
        { -186.86,  3051.37,  45.05 },
        { 95.54,    3233.65,  45.49 },
        { 137.66,   3409.31,  33.20 },
        { 372.71,   3634.15,  59.77 },
        { 738.50,   3713.89,  61.98 },
        { 1304.49,  3729.30,  63.49 },
        { 1556.02,  3753.68,  63.34 },
        { 1986.56,  3961.56,  57.33 },
        { 2187.81,  4176.92,  54.30 },
        { 2399.21,  4579.44,  51.93 },
        { 2677.69,  4833.45,  37.00 },
        { 2817.90,  4976.62,  40.78 },
        { 2827.35,  4975.75,  95.51 },
        { 2820.32,  4614.30,  102.81 },
        { 2920.64,  4301.52,  88.43 },
        { 2759.46,  4001.40,  84.76 },
        { 2777.25,  3707.97,  84.99 },
        { 2734.72,  3297.13,  109.12 },
        { 2634.53,  3008.68,  63.78 },
        { 2498.81,  2780.40,  40.02 },
        { 2440.57,  2568.74,  47.20 },
        { 2583.71,  2281.80,  47.66 },
        { 2556.93,  2193.93,  21.92 },
        { 2534.00,  1912.73,  37.12 },
        { 2542.15,  1649.16,  40.58 },
        { 2454.14,  1270.96,  55.15 },
        { 2352.14,  1171.86,  64.48 },
        { 2410.43,  966.69,   98.39 },
        { 2640.57,  449.56,   119.88 },
        { 2595.23,  208.97,   99.81 },
        { 2522.55,  -17.85,   104.59 },
        { 2289.42,  -420.15,  107.79 },
        { 2144.99,  -575.59,  112.17 },
        { 1885.61,  -759.39,  87.99 },
        { 1717.10,  -885.82,  80.40 },
        { 1553.47,  -993.45,  77.43 },
        { 1253.12,  -1169.06, 73.13 },
        { 1034.71,  -1277.55, 33.04 },
        { 886.27,   -1432.08, 18.35 },
        { 827.25,   -1521.01, 16.44 },
        { 777.20,   -1553.49, 13.05 },
        { 677.57,   -1715.57, 15.16 },
        { 631.41,   -2034.07, 17.78 },
        { 612.32,   -2502.11, 6.59 },
        { 640.84,   -2654.19, 24.63 },
        { 571.11,   -2822.70, 27.57 },
        { 324.28,   -3052.37, 37.93 },
        { 32.54,    -3070.34, 35.72 },
        { -283.32,  -3072.08, 32.40 },
        { -580.05,  -3083.62, 26.96 },
        { -913.29,  -3090.29, 29.65 },
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- MAPEAMENTO PADRÃO: estilo → pool de coordenadas
-- Usado quando o Point não define CoordsZones personalizado.
-----------------------------------------------------------------------------------------------------------------------------------------

Routes.DefaultCoordsZones = {
    -- Pool de coordenadas usado para rotas terrestres
    terrestrial = "New",
    -- Pool de coordenadas usado para rotas aquaticas
    aquatic     = "Aquaticas",
    -- Pool de coordenadas usado para rotas aereas
    aerial      = "Aerea",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- FARM BUFF
-- Configuração por dia da semana. Cada dia pode ter seu próprio horário.
-- Para ativar o dia inteiro, use StartHour = 0, EndHour = 24.
-- Para desativar um dia, remova-o ou defina Enabled = false.
-----------------------------------------------------------------------------------------------------------------------------------------

Routes.FarmBuff = {
    -- Se true, ativa o sistema de multiplicador de farm
    Enabled    = true,
    -- Multiplicador base aplicado durante os horarios ativos
    Multiplier = 1,

    -- Multiplicador adicional por tipo de zona
    ZoneMultiplier = {
        terrestrial = 1.0,
        aquatic     = 2.0,
        aerial      = 1.0,
    },

    -- Agenda por dia da semana
    -- Para ativar o dia inteiro: StartHour = 0, EndHour = 24
    -- Para desativar um dia: remova-o ou defina Enabled = false
    Schedule = {
        Segunda = { Enabled = true,  StartHour = 6,  EndHour = 16 },
        Terca   = { Enabled = true,  StartHour = 6,  EndHour = 16 },
        Quarta  = { Enabled = true,  StartHour = 6,  EndHour = 16 },
        Quinta  = { Enabled = true,  StartHour = 6,  EndHour = 16 },
        Sexta   = { Enabled = true,  StartHour = 6,  EndHour = 16 },
        Sabado  = { Enabled = true,  StartHour = 0,  EndHour = 24 },
        Domingo = { Enabled = true,  StartHour = 0,  EndHour = 24 },
    },

    -- Notificacao exibida ao jogador quando o multiplicador esta ativo
    Notify = {
        -- Se true, exibe a notificacao ao coletar durante o evento
        Enabled = false,
        -- Cor da notificacao (ex: "event", "azul", "sucesso")
        Color   = "event",
        -- Mensagem exibida ao jogador
        Message = "Aproveite o evento, o farm está dobrado!",
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- VIP BONUS
-- Se true, tenta obter bônus VIP via seattle-bonuses
-----------------------------------------------------------------------------------------------------------------------------------------

Routes.VipBonus = {
    -- Se true, tenta obter bonus VIP via export externo
    Enabled = true,
    -- Nome do resource que exporta a funcao de bonus
    Export = "seattle-bonuses",
    -- Nome da funcao exportada (recebe userId, retorna multiplicador)
    Function = "GetBonusFarm",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- DEFINIÇÕES DE ROTAS
-- Cada rota declara os insumos disponíveis e configurações de coleta.
-- Permissão é verificada no Point (pela chave), NÃO na rota.
--
-- Campos:
--   RouteCost      : number        → Custo base da rota (0 = grátis)
--   UpgradeStress  : number        → Stress adicionado por coleta (0 = nenhum)
--   CallPolice     : boolean       → Se alerta a polícia durante coletas
--   UsingVehicle   : boolean       → Se permite coletar dentro de veículo
--   Items          : table         → Itens disponíveis para seleção na NUI
--     - id         : string        → Spawn name do item
--     - price      : number        → Custo para selecionar este item (0 = grátis)
--     - reward     : table         → { min, max } quantidade gerada por coleta
-----------------------------------------------------------------------------------------------------------------------------------------

Routes.Routes = {

    Importacao = {
        RouteCost     = 500,
        UpgradeStress = 1,
        CallPolice    = false,
        UsingVehicle  = true,
        Items = {
            { id = "aluminiofarm",  price = 50,  reward = { min = 2, max = 4 } },
            { id = "carbonofarm",   price = 50,  reward = { min = 2, max = 4 } },
            { id = "papelfarm",     price = 30,  reward = { min = 3, max = 5 } },
            { id = "washbleach",     price = 30,  reward = { min = 3, max = 5 } },
            { id = "tarp",       price = 40,  reward = { min = 1, max = 3 } },
            { id = "plastic",       price = 25,  reward = { min = 2, max = 4 } },
            { id = "copper",        price = 35,  reward = { min = 2, max = 3 } },
            { id = "rubber",        price = 25,  reward = { min = 2, max = 3 } },
            { id = "techtrash",     price = 60,  reward = { min = 1, max = 2 } },
            { id = "cdfarm",        price = 45,  reward = { min = 1, max = 2 } },
            { id = "microchipfarm", price = 80,  reward = { min = 1, max = 1 } },
            { id = "sugar",         price = 20,  reward = { min = 2, max = 4 } },
            { id = "farinha",       price = 20,  reward = { min = 1, max = 3 } },
            { id = "leite",         price = 20,  reward = { min = 1, max = 3 } },
            { id = "polvorafarm",   price = 40,  reward = { min = 3, max = 5 } },
        },
    },

    Arma = {
        RouteCost     = 0,
        UpgradeStress = 1,
        CallPolice    = false,
        UsingVehicle  = true,
        Items = {
            { id = "canofuzil",   price = 0, reward = { min = 2, max = 3 } },
            { id = "canopistola", price = 0, reward = { min = 2, max = 3 } },
            { id = "canosub",     price = 0, reward = { min = 2, max = 3 } },
            { id = "gatilhofarm", price = 0, reward = { min = 4, max = 6 } },
            { id = "molafarm",    price = 0, reward = { min = 4, max = 6 } },
        },
    },

    Parafal = {
        RouteCost     = 0,
        UpgradeStress = 1,
        CallPolice    = false,
        UsingVehicle  = true,
        Items = {
            { id = "canofuzil",    price = 0, reward = { min = 8,  max = 12 } },
            { id = "canopistola",  price = 0, reward = { min = 8,  max = 12 } },
            { id = "canosub",      price = 0, reward = { min = 8,  max = 12 } },
            { id = "gatilhofarm",  price = 0, reward = { min = 16, max = 24 } },
            { id = "molafarm",     price = 0, reward = { min = 16, max = 24 } },
            { id = "carbonofarm",  price = 0, reward = { min = 8,  max = 12 } },
            { id = "cdfarm",       price = 0, reward = { min = 4,  max = 4 } },
            { id = "aluminiofarm", price = 0, reward = { min = 8,  max = 12 } },
            { id = "techtrash",    price = 0, reward = { min = 4,  max = 8 } },
            { id = "copper",       price = 0, reward = { min = 8,  max = 12 } },
            { id = "rubber",       price = 0, reward = { min = 4,  max = 8 } },
            { id = "plastic",      price = 0, reward = { min = 8,  max = 12 } },
            { id = "papelfarm",    price = 0, reward = { min = 12, max = 20 } },
            { id = "washbleach",    price = 0, reward = { min = 12, max = 20 } },
            { id = "tarp",      price = 0, reward = { min = 4,  max = 8 } },
        },
    },

    Maconha = {
        RouteCost     = 0,
        UpgradeStress = 1,
        CallPolice    = false,
        UsingVehicle  = true,
        Items = {
            { id = "weed", price = 0, reward = { min = 4, max = 6 } },
        },
    },

    Cafe = {
        RouteCost     = 0,
        UpgradeStress = 1,
        CallPolice    = false,
        UsingVehicle  = true,
        Items = {
            { id = "farinha",  price = 0, reward = { min = 1, max = 2 } },
            { id = "leite",    price = 0, reward = { min = 1, max = 2 } },
            { id = "plastic",  price = 0, reward = { min = 1, max = 2 } },
        },
    },

    Restaurante = {
        RouteCost     = 0,
        UpgradeStress = 1,
        CallPolice    = false,
        UsingVehicle  = true,
        Items = {
            { id = "farinha",    price = 0, reward = { min = 1, max = 3 } },
            { id = "leite",      price = 0, reward = { min = 1, max = 3 } },
            { id = "sugar",      price = 0, reward = { min = 1, max = 3 } },
            { id = "water",      price = 0, reward = { min = 1, max = 3 } },
            { id = "carne",      price = 0, reward = { min = 1, max = 3 } },
            { id = "tomato",     price = 0, reward = { min = 1, max = 3 } },
            { id = "strawberry", price = 0, reward = { min = 1, max = 3 } },
            { id = "cereja",     price = 0, reward = { min = 1, max = 3 } },
            { id = "coco",       price = 0, reward = { min = 1, max = 3 } },
            { id = "chocolate",  price = 0, reward = { min = 1, max = 3 } },
            { id = "batata",     price = 0, reward = { min = 1, max = 3 } },
            { id = "amendoim",   price = 0, reward = { min = 1, max = 3 } },
            { id = "grape",      price = 0, reward = { min = 1, max = 3 } },
            { id = "orange",     price = 0, reward = { min = 1, max = 3 } },
            { id = "limao",      price = 0, reward = { min = 1, max = 3 } },
            { id = "tilapia",    price = 0, reward = { min = 1, max = 3 } },
            { id = "salmao",     price = 0, reward = { min = 1, max = 3 } },
        },
    },

    Lean = {
        RouteCost     = 0,
        UpgradeStress = 1,
        CallPolice    = false,
        UsingVehicle  = true,
        Items = {
            { id = "codeine", price = 0, reward = { min = 1, max = 1 } },
            { id = "alcohol", price = 0, reward = { min = 1, max = 1 } },
        },
    },

    Cocaina = {
        RouteCost     = 0,
        UpgradeStress = 1,
        CallPolice    = false,
        UsingVehicle  = true,
        Items = {
            { id = "cocainafarm", price = 0, reward = { min = 4, max = 6 } },
        },
    },

    Metanfetamina = {
        RouteCost     = 0,
        UpgradeStress = 1,
        CallPolice    = false,
        UsingVehicle  = true,
        Items = {
            { id = "metadone", price = 0, reward = { min = 4, max = 6 } },
        },
    },

    LSD = {
        RouteCost     = 0,
        UpgradeStress = 1,
        CallPolice    = false,
        UsingVehicle  = true,
        Items = {
            { id = "lsdfarm", price = 0, reward = { min = 4, max = 6 } },
        },
    },

    Ecstasy = {
        RouteCost     = 0,
        UpgradeStress = 1,
        CallPolice    = false,
        UsingVehicle  = true,
        Items = {
            { id = "exatasyfarm", price = 0, reward = { min = 4, max = 6 } },
        },
    },

    Skunk = {
        RouteCost     = 0,
        UpgradeStress = 1,
        CallPolice    = false,
        UsingVehicle  = true,
        Items = {
            { id = "skunkfarm", price = 0, reward = { min = 4, max = 6 } },
        },
    },

    Ayahuasca = {
        RouteCost     = 0,
        UpgradeStress = 1,
        CallPolice    = false,
        UsingVehicle  = true,
        Items = {
            { id = "ayahuascafarm", price = 0, reward = { min = 4, max = 6 } },
        },
    },

    Ketamina = {
        RouteCost     = 0,
        UpgradeStress = 1,
        CallPolice    = false,
        UsingVehicle  = true,
        Items = {
            { id = "ketaminafarm", price = 0, reward = { min = 4, max = 6 } },
        },
    },

    Heroina = {
        RouteCost     = 0,
        UpgradeStress = 1,
        CallPolice    = false,
        UsingVehicle  = true,
        Items = {
            { id = "heroinafarm", price = 0, reward = { min = 4, max = 6 } },
        },
    },

    Lavagem = {
        RouteCost     = 0,
        UpgradeStress = 1,
        CallPolice    = false,
        UsingVehicle  = true,
        Items = {
            { id = "papelfarm",    price = 0, reward = { min = 3, max = 5 } },
            { id = "washbleach",    price = 0, reward = { min = 3, max = 5 } },
            { id = "aluminiofarm", price = 0, reward = { min = 1, max = 2 } },
            { id = "carbonofarm",  price = 0, reward = { min = 1, max = 2 } },
            { id = "tarp",      price = 0, reward = { min = 1, max = 2 } },
        },
    },

    Ilegal = {
        RouteCost     = 0,
        UpgradeStress = 1,
        CallPolice    = false,
        UsingVehicle  = true,
        Items = {
            { id = "microchipfarm", price = 0, reward = { min = 1, max = 1 } },
            { id = "aluminiofarm",  price = 0, reward = { min = 2, max = 3 } },
            { id = "plastic",       price = 0, reward = { min = 2, max = 3 } },
            { id = "cdfarm",        price = 0, reward = { min = 1, max = 2 } },
            { id = "carbonofarm",   price = 0, reward = { min = 2, max = 3 } },
            { id = "techtrash",     price = 0, reward = { min = 1, max = 2 } },
            { id = "tarp",       price = 0, reward = { min = 1, max = 2 } },
            { id = "sugar",         price = 0, reward = { min = 1, max = 2 } },
        },
    },

    Desmanche = {
        RouteCost     = 0,
        UpgradeStress = 1,
        CallPolice    = false,
        UsingVehicle  = true,
        Items = {
            { id = "carbonofarm",  price = 0, reward = { min = 2, max = 3 } },
            { id = "cdfarm",       price = 0, reward = { min = 1, max = 1 } },
            { id = "aluminiofarm", price = 0, reward = { min = 2, max = 3 } },
            { id = "techtrash",    price = 0, reward = { min = 1, max = 2 } },
            { id = "copper",       price = 0, reward = { min = 2, max = 3 } },
            { id = "rubber",       price = 0, reward = { min = 1, max = 2 } },
            { id = "plastic",      price = 0, reward = { min = 2, max = 3 } },
        },
    },

    Municao = {
        RouteCost     = 0,
        UpgradeStress = 1,
        CallPolice    = false,
        UsingVehicle  = true,
        Items = {
            { id = "capsula",      price = 0, reward = { min = 6,  max = 9 } },
            { id = "capsulafuzil", price = 0, reward = { min = 6,  max = 9 } },
            { id = "capsulasub",   price = 0, reward = { min = 6,  max = 9 } },
            { id = "polvorafarm",  price = 0, reward = { min = 9,  max = 15 } },
        },
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- PONTOS DE INTERAÇÃO
-- Chave = nome da permissão verificada no jogador.
-- Cada ponto pode referenciar múltiplas rotas — o script mescla os itens.
--
-- Campos:
--   Routes        : table         → Lista de chaves de Routes.Routes disponíveis neste ponto
--   Coords        : vec4          → Posição + heading do NPC / ponto de interação
--   NPC           : boolean       → Se cria um NPC no local
--   Hash          : string        → Modelo do NPC (quando NPC = true)
--   anim          : table         → { dict, anim } animação do NPC
--   CoordsZones   : table|nil     → Override do DefaultCoordsZones (nil = usa padrão)
--   Blip          : table|nil     → Blip no mapa (nil = sem blip)
--   AllowedStyles : table|nil     → Estilos de rota permitidos neste ponto (nil = todos os 3)
--                                   Valores: "terrestre" | "aquatica" | "aerea"
-----------------------------------------------------------------------------------------------------------------------------------------

Routes.Points = {

    -- ============================================================
    -- MUNICAO (Triade / Fazenda / Jetsam / Sinaloa)
    -- ============================================================
    Municao1 = {
        Routes = { "Municao" },
        Coords = vec4(402.03,-4.98,84.92,238.12),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Municao2 = {
        Routes = { "Municao" },
        Coords = vec4(1463.37,1104.18,119.13,0.0),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Municao3 = {
        Routes = { "Municao" },
        Coords = vec4(833.19,-2924.51,1.79,93.55),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Municao4 = {
        Routes = { "Municao" },
        Coords = vec4(-1802.92,485.71,108.48,130.4),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },

    -- ============================================================
    -- ARMA (Globo / Vinhedo / Playboy / Casablanca)
    -- ============================================================
    Arma1 = {
        Routes = { "Arma" },
        Coords = vec4(-3695.4,3822.98,14.76,153.08),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Arma2 = {
        Routes = { "Arma" },
        Coords = vec4(-1908.96,2064.33,135.98,158.75),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Arma3 = {
        Routes = { "Arma" },
        Coords = vec4(-1562.61,89.08,53.87,274.97),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Arma4 = {
        Routes = { "Arma" },
        Coords = vec4(-1564.02,836.46,177.19,138.9),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Arma5 = { -- Yakuza
        Routes = { "Arma" },
        Coords = vec4(-2292.1,-660.17,20.17,314.65),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },

    -- ============================================================
    -- CONTRABANDO (Distrito 14 / Resort / Posto / Igreja)
    -- ============================================================
    Contrabando1 = {
        Routes = { "Ilegal" },
        Coords = vec4(-691.06,2706.93,54.34,110.56),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Contrabando2 = {
        Routes = { "Ilegal" },
        Coords = vec4(-2933.72,36.89,11.61,65.2),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Contrabando3 = {
        Routes = { "Ilegal" },
        Coords = vec4(-2093.77,-353.6,6.07,354.34),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Contrabando4 = {
        Routes = { "Ilegal" },
        Coords = vec4(-306.44,6132.84,14.2,192.76),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },

    -- ============================================================
    -- LAVAGEM (Jack Of Hearts / Haute / Vanilla Sul / Vanilla Norte)
    -- ============================================================
    Lavagem1 = {
        Routes = { "Lavagem" },
        Coords = vec4(369.45,241.9,107.75,155.91),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Lavagem2 = {
        Routes = { "Municao" },
        Coords = vec4(-6.31,250.54,101.35,164.41),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Lavagem3 = {
        Routes = { "Lavagem" },
        Coords = vec4(-663.48,-703.63,30.99,181.42),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Lavagem4 = {
        Routes = { "Lavagem" },
        Coords = vec4(-298.87,6262.92,34.79,314.65),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },

    -- ============================================================
    -- DESMANCHE (Yellow Jack / Racha Cranios / Mansao Black / Rising Sun)
    -- ============================================================
    Desmanche1 = {
        Routes = { "Desmanche" },
        Coords = vec4(1988.84,3016.58,47.5,59.53),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Desmanche2 = {
        Routes = { "Desmanche" },
        Coords = vec4(1186.9,-3283.16,5.53,274.97),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Desmanche3 = {
        Routes = { "Desmanche" },
        Coords = vec4(-2811.0,1449.22,96.25,238.12),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Desmanche4 = {
        Routes = { "Desmanche" },
        Coords = vec4(-335.53,-161.85,39.06,354.34),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },

    -- ============================================================
    -- FAVELAS (Produção de drogas)
    -- ============================================================
    Metafetamina1 = {
        Routes = { "Metanfetamina" },
        Coords = vec4(1186.57,-23.52,81.35,138.9),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Metafetamina2 = {
        Routes = { "Metanfetamina" },
        Coords = vec4(-461.9,1589.99,363.55,348.67),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Skunk1 = {
        Routes = { "Skunk" },
        Coords = vec4(1314.18,-786.07,79.01,331.66),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Skunk2 = {
        Routes = { "Skunk" },
        Coords = vec4(-2151.16,866.27,208.53,209.77),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Cocaina1 = {
        Routes = { "Cocaina" },
        Coords = vec4(1543.09,-1374.39,89.78,257.96),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Cocaina2 = {
        Routes = { "Cocaina" },
        Coords = vec4(-2487.37,-155.98,45.21,235.28),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Ecstasy1 = {
        Routes = { "Ecstasy" },
        Coords = vec4(-843.41,982.2,250.81,280.63),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Ecstasy2 = {
        Routes = { "Ecstasy" },
        Coords = vec4(2636.22,1841.4,36.97,223.94),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Heroina1 = {
        Routes = { "Heroina" },
        Coords = vec4(-1164.34,2524.88,41.48,110.56),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    Heroina2 = {
        Routes = { "Heroina" },
        Coords = vec4(-1395.28,1543.68,132.46,85.04),
        NPC    = true,
        Hash   = "s_m_y_dealer_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },

    -- ============================================================
    -- RESTAURANTES (Soda Pop / Moo Moo / Osaka Sushi / Marina Lounge / Kitty Café)
    -- ============================================================
    SodaPop = {
        Routes = { "Restaurante" },
        Coords = vec4(-1395.65,-1399.08,3.91,85.04),
        NPC    = true,
        Hash   = "s_m_y_chef_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    MooMoo = {
        Routes = { "Restaurante" },
        Coords = vec4(-593.73,-1058.99,22.53,87.88),
        NPC    = true,
        Hash   = "s_m_y_chef_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    OsakaSushi = {
        Routes = { "Restaurante" },
        Coords = vec4(-802.14,-148.87,37.81,121.89),
        NPC    = true,
        Hash   = "s_m_y_chef_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    MarinaLounge = {
        Routes = { "Restaurante" },
        Coords = vec4(1545.49,3796.17,34.51,300.48),
        NPC    = true,
        Hash   = "s_m_y_chef_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
    KittyCafe = {
        Routes = { "Restaurante" },
        Coords = vec4(1146.3,-801.19,58.06,87.88),
        NPC    = true,
        Hash   = "s_m_y_chef_01",
        anim   = { "anim@heists@heist_corona@single_team", "single_team_loop_boss" },
    },
}
