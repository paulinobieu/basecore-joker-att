-----------------------------------------------------------------------------------------------------------------------------------------
-- PREÇOS
-----------------------------------------------------------------------------------------------------------------------------------------
-- price: valor do primeiro nível ou valor fixo da opção.
-- increaseBy: acréscimo por nível. Remova ou use 0 para manter o preço fixo.
-- requireItem/item: opcionais. Use apenas quando uma peça física for exigida.
-----------------------------------------------------------------------------------------------------------------------------------------
Bennys.Prices = {
    initialPrice = 20000,
    repairPrice = 3000,

    -- Slots nativos do veículo.
    [0]  = { price = 35000 }, -- Aerofólio
    [1]  = { price = 20000 }, -- Para-choque dianteiro
    [2]  = { price = 20000 }, -- Para-choque traseiro
    [3]  = { price = 25000 }, -- Saias
    [4]  = { price = 23000 }, -- Escapamento
    [5]  = { price = 50000 }, -- Carroceria
    [6]  = { price = 25000 }, -- Grelha
    [7]  = { price = 20000 }, -- Capô
    [8]  = { price = 20000 }, -- Paralama
    [9]  = { price = 1000 },
    [10] = { price = 35000 }, -- Teto
    [11] = { price = 50000, increaseBy = 50000 }, -- Motor
    [12] = { price = 30000, increaseBy = 30000 }, -- Freio
    [13] = { price = 45000, increaseBy = 45000 }, -- Transmissão
    [14] = { price = 10000 }, -- Buzina
    [15] = { price = 25000, increaseBy = 25000 }, -- Suspensão
    [16] = { price = 1000000, increaseBy = 1000000 }, -- Blindagem
    [17] = { price = 10000 },
    [18] = { price = 50000 }, -- Turbo
    [19] = { price = 3000 },
    [20] = { price = 0 }, -- Ativação da fumaça; a cor é cobrada abaixo.
    [21] = { price = 0 },
    [22] = { price = 0 }, -- Ativação do xênon; a cor é cobrada abaixo.
    [23] = { price = 20000 }, -- Rodas
    [24] = { price = 2500 },
    [25] = { price = 2500 },
    [26] = { price = 2500 },
    [27] = { price = 50000 }, -- Interior
    [28] = { price = 8000 }, -- Bonecos/gaiola
    [29] = { price = 15000 }, -- Dashboard
    [30] = { price = 5000 }, -- Velocímetro
    [31] = { price = 25000 }, -- Portas
    [32] = { price = 5000 }, -- Bancos
    [33] = { price = 5000 }, -- Volante
    [34] = { price = 5000 }, -- Marcha
    [35] = { price = 15000 }, -- Plaques
    [36] = { price = 15000 }, -- Caixa de som
    [37] = { price = 30000 }, -- Som na mala
    [38] = { price = 80000 }, -- Hidráulica
    [39] = { price = 50000 }, -- Bloco do motor
    [40] = { price = 20000 }, -- Filtro de ar
    [41] = { price = 1000 },
    [42] = { price = 8000 }, -- Arch cover
    [43] = { price = 1000 },
    [44] = { price = 1000 },
    [45] = { price = 1000 },
    [46] = { price = 1000 },
    [47] = { price = 1000 },
    [48] = { price = 30000 }, -- Decalque
    [49] = { price = 1000 },

    -- Pintura, iluminação e opções especiais.
    primaryColour = { price = 15000 },
    secondaryColour = { price = 15000 },
    primaryPaintType = { price = 0 },
    secondaryPaintType = { price = 0 },
    primaryChameleon = { price = 20000 },
    secondaryChameleon = { price = 20000 },
    pearlescentColour = { price = 30000 },
    wheelColour = { price = 15000 },
    tyreSmokeColour = { price = 9000 },
    neon = { price = 20000 },
    xenonColour = { price = 30000 },

    -- Demais opções manuais.
    engineSound = { price = 200000 },
    windowTint = { price = 60000 },
    plate = { price = 20000 },
    wheelType = { price = 0 },
    customTires = { price = 1000 },
    customTires1 = { price = 1000 },
    customTires2 = { price = 1000 },
    bulletProofTyres = { price = 1000 },
    driftTyres = { price = 1500 },
    vehicleExtras = { price = 1000000 },
}
