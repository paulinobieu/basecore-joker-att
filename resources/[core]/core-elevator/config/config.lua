Elevator = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- THEME
-- Cor principal da UI. Theme.main (vrp/config/Global.lua) tem prioridade quando definido.
-----------------------------------------------------------------------------------------------------------------------------------------
Elevator.ThemeColor = "#dc1553"

-----------------------------------------------------------------------------------------------------------------------------------------
-- INTERAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------

Elevator.Interaction = {
    System = "sleepless",

    Sleepless = {
        Label = "Abrir Elevador",
        Icon = "elevator",
        Distance = 1.5,
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- ELEVADORES
-----------------------------------------------------------------------------------------------------------------------------------------

Elevator.Locations = {
    -- HOSPITAL
    {
        floors = {
            { label = "Heliponto", coords = { -1023.66, -432.89, 77.36, 116.23 } },
            { label = "2º Andar",  coords = { -1025.2, -429.37, 46.44, 150.24 } },
            { label = "1º Andar",  coords = { -1025.2, -429.37, 42.98, 150.24 } },
            { label = "Térreo",    coords = { -1025.2, -429.37, 39.82, 150.24 } },
            { label = "Garagem",   coords = { -1025.2, -429.37, 33.56, 19.85 } },
        },
    },

    -- TORRE
    {
        floors = {
            { label = "2º Andar", coords = { -855.89, -2144.09, 106.71 } },
            { label = "1º Andar", coords = { -857.36, -2145.52, 101.99 } },
            { label = "Térreo",   coords = { -875.18, -2110.33, 9.91 } },
        },
    },

    -- VERMELHO
    {
        floors = {
            { label = "Cobertura", coords = { -286.64, -723.12, 125.46 } },
            { label = "Garagem",   coords = { -305.59, -722.74, 28.02 } },
        },
    },

    -- ECLIPSE
    {
        floors = {
            { label = "Cobertura", coords = { -775.42, 328.65, 240.14 } },
            { label = "Térreo",    coords = { -761.82, 352.46, 87.99 } },
        },
    },

    -- CAMPO DE GOLF
    {
        floors = {
            { label = "Cobertura", coords = { -1186.57, -186.15, 87.28 } },
            { label = "Térreo",    coords = { -1220.26, -169.37, 39.33 } },
        },
    },

    -- VANILLA NORTE (Lavagem4)
    {
        floors = {
            { label = "Boate", coords = { -293.88, 6266.17, 31.49 } },
            { label = "Motel", coords = { 1103.1, 4922.72, -80.42 } },
        },
    },

    -- VANILLA SUL (Lavagem3)
    {
        floors = {
            { label = "Rooftop",       coords = { -690.79, -689.55, 54.95, 93.55 } },
            { label = "Apartamento 2", coords = { -691.23, -690.38, 45.58, 0.0 } },
            { label = "Apartamento 1", coords = { -691.23, -690.38, 35.76, 0.0 } },
            { label = "Bar Privado",   coords = { -708.22, -688.6, 35.76, 0.0 } },
            { label = "Escritório",    coords = { -673.81, -688.87, 30.31, 181.42 }, permission = "Lavagem3" },
            { label = "Lobby",         coords = { -708.09, -686.4, 30.3, 0.0 } },
            { label = "Garagem",       coords = { -673.66, -688.07, 25.65, 0.0 }, permission = "Lavagem3" },
        },
    },

    -- BUNKER PARAFAL
    {
        floors = {
            { label = "Entrada", coords = { -403.64, -87.25, 54.73 } },
            { label = "Bunker",  coords = { -398.95, -146.0, 3.91 } },
        },
    },

    -- MAFIA LAGO
    {
        floors = {
            { label = "Entrada", coords = { 556.29, -1821.32, 25.63 } },
            { label = "Bunker",  coords = { 554.8, -1886.37, -4.08 } },
        },
    },

    -- STUDIO
    {
        floors = {
            { label = "Cenários", coords = { -329.52, 1140.28, 1142.42, 266.46 } },
            { label = "4º Andar", coords = { -317.38, 1124.72, 367.49, 110.56 } },
            { label = "3º Andar", coords = { -325.63, 1121.66, 348.0, 107.72 } },
            { label = "2º Andar", coords = { -325.63, 1121.66, 337.94, 107.72 } },
            { label = "1º Andar", coords = { -325.63, 1121.66, 326.2, 107.72 } },
        },
    },

    -- TRIBUNAL
    {
        floors = {
            { label = "Heliponto", coords = { -533.02, 1155.84, 363.28, 223.94 } },
            { label = "3º Andar",  coords = { -532.97, 1155.9, 355.7, 39.69 } },
            { label = "2º Andar",  coords = { -532.97, 1155.9, 347.36, 39.69 } },
            { label = "1º Andar",  coords = { -532.97, 1155.9, 337.27, 39.69 } },
            { label = "Térreo",    coords = { -535.39, 1158.81, 325.52, 36.86 } },
        },
    },

    -- DP CIVIL (elevador 1)
    {
        floors = {
            { label = "Heliponto", coords = { -998.16, -1967.14, 44.75, 136.07 } },
            { label = "Térreo",    coords = { -1011.9, -1979.44, 13.31, 130.4 } },
        },
    },

    -- DP CIVIL (elevador 2)
    {
        floors = {
            { label = "Heliponto", coords = { -990.07, -1975.56, 44.75, 150.24 } },
            { label = "Térreo",    coords = { -1002.18, -1989.27, 13.31, 138.9 } },
        },
    },

    -- TRIADE (Municao1)
    {
        floors = {
            { label = "Garagem", coords = { 380.46, -15.01, 83.0, 36.86 } },
            { label = "Térreo",  coords = { 417.45, -10.78, 99.65, 235.28 } },
        },
    },
}
