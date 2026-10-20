-----------------------------------------------------------------------------------------------------------------------------------------
-- BANCADAS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Cada bancada é um ponto de interação no mapa. O comentário ao lado da chave
-- identifica de quem é o ponto.
--   Title       → nome exibido no topo da interface (caixa alta)
--   Description → uma linha dizendo o que a bancada produz
--   Coords      → vec3(x, y, z) do ponto de interação
--   Permission  → grupo exigido para abrir (nil libera para qualquer um)
--   Rank        → nível mínimo dentro do grupo (nil aceita qualquer nível)
--   Modes       → categorias de recipes.lua liberadas nesta bancada
-----------------------------------------------------------------------------------------------------------------------------------------

Crafting.Stations = {
    -------------------------------------------------------------------------------------------------------------------------------------
    -- MUNIÇÃO
    -------------------------------------------------------------------------------------------------------------------------------------
    { -- Tríade
        Title       = "BANCADA DE MUNIÇÃO",
        Description = "Recarga de calibres para pistolas, SMGs e fuzis.",
        Coords      = vec3(412.64, 8.11, 84.74),
        Permission  = "Municao1",
        Rank        = 3,
        Modes       = { "Municao" },
    },
    { -- Fazenda
        Title       = "BANCADA DE MUNIÇÃO",
        Description = "Recarga de calibres para pistolas, SMGs e fuzis.",
        Coords      = vec3(1471.08, 1118.69, 118.92),
        Permission  = "Municao2",
        Rank        = 3,
        Modes       = { "Municao" },
    },
    { -- Jetsam
        Title       = "BANCADA DE MUNIÇÃO",
        Description = "Recarga de calibres para pistolas, SMGs e fuzis.",
        Coords      = vec3(826.05, -2925.15, 1.87),
        Permission  = "Municao3",
        Rank        = 3,
        Modes       = { "Municao" },
    },
    { -- Sinaloa
        Title       = "BANCADA DE MUNIÇÃO",
        Description = "Recarga de calibres para pistolas, SMGs e fuzis.",
        Coords      = vec3(-1810.19, 478.23, 108.22),
        Permission  = "Municao4",
        Rank        = 3,
        Modes       = { "Municao" },
    },

    -------------------------------------------------------------------------------------------------------------------------------------
    -- ARMAS
    -------------------------------------------------------------------------------------------------------------------------------------
    { -- Globo
        Title       = "BANCADA DE ARMAS",
        Description = "Montagem de pistolas, submetralhadoras e fuzis.",
        Coords      = vec3(-3695.05, 3789.86, 4.95),
        Permission  = "Arma1",
        Rank        = 3,
        Modes       = { "Armas" },
    },
    { -- Vinhedo
        Title       = "BANCADA DE ARMAS",
        Description = "Montagem de pistolas, submetralhadoras e fuzis.",
        Coords      = vec3(-1918.07, 2064.76, 135.76),
        Permission  = "Arma2",
        Rank        = 3,
        Modes       = { "Armas" },
    },
    { -- Playboy
        Title       = "BANCADA DE ARMAS",
        Description = "Montagem de pistolas, submetralhadoras e fuzis.",
        Coords      = vec3(-1545.09, 85.10, 53.67),
        Permission  = "Arma3",
        Rank        = 3,
        Modes       = { "Armas" },
    },
    { -- Casablanca
        Title       = "BANCADA DE ARMAS",
        Description = "Montagem de pistolas, submetralhadoras e fuzis.",
        Coords      = vec3(-1563.40, 831.47, 177.02),
        Permission  = "Arma4",
        Rank        = 3,
        Modes       = { "Armas" },
    },
    { -- Yakuza
        Title       = "BANCADA DE ARMAS",
        Description = "Montagem de pistolas, submetralhadoras e fuzis.",
        Coords      = vec3(-2288.97, -681.97, 20.08),
        Permission  = "Arma5",
        Rank        = 3,
        Modes       = { "Armas" },
    },

    -------------------------------------------------------------------------------------------------------------------------------------
    -- CONTRABANDO
    -------------------------------------------------------------------------------------------------------------------------------------
    { -- Distrito 14
        Title       = "BANCADA DE CONTRABANDO",
        Description = "Cartões de acesso, explosivos e equipamento de assalto.",
        Coords      = vec3(-690.21, 2698.25, 54.17),
        Permission  = "Contrabando1",
        Rank        = 3,
        Modes       = { "Ilegal" },
    },
    { -- Resort
        Title       = "BANCADA DE CONTRABANDO",
        Description = "Cartões de acesso, explosivos e equipamento de assalto.",
        Coords      = vec3(-2938.17, 34.73, 11.70),
        Permission  = "Contrabando2",
        Rank        = 3,
        Modes       = { "Ilegal" },
    },
    { -- Posto
        Title       = "BANCADA DE CONTRABANDO",
        Description = "Cartões de acesso, explosivos e equipamento de assalto.",
        Coords      = vec3(-2097.36, -347.56, 6.15),
        Permission  = "Contrabando3",
        Rank        = 3,
        Modes       = { "Ilegal" },
    },
    { -- Igreja
        Title       = "BANCADA DE CONTRABANDO",
        Description = "Cartões de acesso, explosivos e equipamento de assalto.",
        Coords      = vec3(-316.11, 6126.09, 14.08),
        Permission  = "Contrabando4",
        Rank        = 3,
        Modes       = { "Ilegal" },
    },

    -------------------------------------------------------------------------------------------------------------------------------------
    -- LAVAGEM
    -------------------------------------------------------------------------------------------------------------------------------------
    { -- Jack of Hearts
        Title       = "BANCADA DE LAVAGEM",
        Description = "Notas limpas e equipamento de sequestro.",
        Coords      = vec3(365.56, 240.98, 107.82),
        Permission  = "Lavagem1",
        Rank        = 3,
        Modes       = { "Lavagem" },
    },
    { -- Haute · o ponto entrega munição, como já era na config antiga
        Title       = "BANCADA DE MUNIÇÃO",
        Description = "Recarga de calibres para pistolas, SMGs e fuzis.",
        Coords      = vec3(4.25, 252.69, 101.15),
        Permission  = "Lavagem2",
        Rank        = 3,
        Modes       = { "Municao" },
    },
    { -- Vanilla Sul
        Title       = "BANCADA DE LAVAGEM",
        Description = "Notas limpas e equipamento de sequestro.",
        Coords      = vec3(-669.95, -705.84, 30.47),
        Permission  = "Lavagem3",
        Rank        = 3,
        Modes       = { "Lavagem" },
    },
    { -- Vanilla Norte
        Title       = "BANCADA DE LAVAGEM",
        Description = "Notas limpas e equipamento de sequestro.",
        Coords      = vec3(-296.44, 6262.85, 34.72),
        Permission  = "Lavagem4",
        Rank        = 3,
        Modes       = { "Lavagem" },
    },

    -------------------------------------------------------------------------------------------------------------------------------------
    -- DESMANCHE
    -------------------------------------------------------------------------------------------------------------------------------------
    { -- Yellow Jack
        Title       = "BANCADA DE DESMANCHE",
        Description = "Ferramentas de furto e peças de corrida.",
        Coords      = vec3(1990.45, 3019.05, 47.51),
        Permission  = "Desmanche1",
        Rank        = 3,
        Modes       = { "Desmanche" },
    },
    { -- Racha Crânios
        Title       = "BANCADA DE DESMANCHE",
        Description = "Ferramentas de furto e peças de corrida.",
        Coords      = vec3(1189.77, -3286.16, 5.36),
        Permission  = "Desmanche2",
        Rank        = 3,
        Modes       = { "Desmanche" },
    },
    { -- Mansão Black
        Title       = "BANCADA DE DESMANCHE",
        Description = "Ferramentas de furto e peças de corrida.",
        Coords      = vec3(-2798.17, 1461.40, 96.32),
        Permission  = "Desmanche3",
        Rank        = 3,
        Modes       = { "Desmanche" },
    },
    { -- Rising Sun
        Title       = "BANCADA DE DESMANCHE",
        Description = "Ferramentas de furto e peças de corrida.",
        Coords      = vec3(-328.78, -161.67, 38.87),
        Permission  = "Desmanche4",
        Rank        = 3,
        Modes       = { "Desmanche" },
    },

    -------------------------------------------------------------------------------------------------------------------------------------
    -- FAVELAS
    -------------------------------------------------------------------------------------------------------------------------------------
    { -- Barragem
        Title       = "REFINO DE METANFETAMINA",
        Description = "Metanfetamina pronta para uso e para venda na rua.",
        Coords      = vec3(1186.46, -17.24, 85.45),
        Permission  = "Metafetamina1",
        Rank        = 3,
        Modes       = { "Metanfetamina" },
    },
    { -- Demonike
        Title       = "REFINO DE METANFETAMINA",
        Description = "Metanfetamina pronta para uso e para venda na rua.",
        Coords      = vec3(-441.13, 1617.46, 360.72),
        Permission  = "Metafetamina2",
        Rank        = 3,
        Modes       = { "Metanfetamina" },
    },
    { -- Helipa
        Title       = "REFINO DE SKUNK",
        Description = "Skunk pronta para uso e para venda na rua.",
        Coords      = vec3(1308.32, -797.37, 84.78),
        Permission  = "Skunk1",
        Rank        = 3,
        Modes       = { "Skunk" },
    },
    { -- Juramento
        Title       = "REFINO DE SKUNK",
        Description = "Skunk pronta para uso e para venda na rua.",
        Coords      = vec3(-2198.12, 876.26, 229.83),
        Permission  = "Skunk2",
        Rank        = 3,
        Modes       = { "Skunk" },
    },
    { -- Sinaloa
        Title       = "REFINO DE COCAÍNA",
        Description = "Cocaína pronta para uso e para venda na rua.",
        Coords      = vec3(1571.70, -1316.31, 94.55),
        Permission  = "Cocaina1",
        Rank        = 3,
        Modes       = { "Cocaina" },
    },
    { -- Maré
        Title       = "REFINO DE COCAÍNA",
        Description = "Cocaína pronta para uso e para venda na rua.",
        Coords      = vec3(-2480.95, -118.21, 54.98),
        Permission  = "Cocaina2",
        Rank        = 3,
        Modes       = { "Cocaina" },
    },
    { -- MMDG
        Title       = "REFINO DE ECSTASY",
        Description = "Ecstasy pronto para uso e para venda na rua.",
        Coords      = vec3(-770.44, 1164.95, 280.60),
        Permission  = "Ecstasy1",
        Rank        = 3,
        Modes       = { "Ecstasy" },
    },
    { -- Vaticano
        Title       = "REFINO DE ECSTASY",
        Description = "Ecstasy pronto para uso e para venda na rua.",
        Coords      = vec3(2698.85, 1922.26, 54.55),
        Permission  = "Ecstasy2",
        Rank        = 3,
        Modes       = { "Ecstasy" },
    },
    { -- Santo Amaro
        Title       = "REFINO DE HEROÍNA",
        Description = "Heroína pronta para uso e para venda na rua.",
        Coords      = vec3(-1214.19, 2448.75, 74.87),
        Permission  = "Heroina1",
        Rank        = 3,
        Modes       = { "Heroina" },
    },
    { -- Santo Amaro
        Title       = "REFINO DE HEROÍNA",
        Description = "Heroína pronta para uso e para venda na rua.",
        Coords      = vec3(-1347.15, 1468.05, 165.28),
        Permission  = "Heroina2",
        Rank        = 3,
        Modes       = { "Heroina" },
    },

    -------------------------------------------------------------------------------------------------------------------------------------
    -- RESTAURANTES
    -------------------------------------------------------------------------------------------------------------------------------------
    { -- Soda Pop
        Title       = "COZINHA DO SODA POP",
        Description = "Combos, pratos e bebidas do cardápio.",
        Coords      = vec3(-1376.17, -1402.52, 5.57),
        Permission  = "SodaPop",
        Rank        = 5,
        Modes       = { "SodaPOP" },
    },
    -- Kitty Café · sem cardápio definido: a categoria "Kitty" não existe em
    -- recipes.lua e o core-totem também está com os itens pendentes.
    -- {
    --     Title       = "COZINHA DO KITTY CAFÉ",
    --     Description = "Combos, pratos e bebidas do cardápio.",
    --     Coords      = vec3(1137.00, -796.03, 58.41),
    --     Permission  = "KittyCafe",
    --     Rank        = 5,
    --     Modes       = { "Kitty" },
    -- },
    { -- Moo Moo
        Title       = "COZINHA DO MOO MOO",
        Description = "Combos, pratos e bebidas do cardápio.",
        Coords      = vec3(-591.81, -1063.01, 22.59),
        Permission  = "MooMoo",
        Rank        = 5,
        Modes       = { "MooMoo" },
    },
    { -- Marina Lounge
        Title       = "COZINHA DO MARINA LOUNGE",
        Description = "Combos, pratos e bebidas do cardápio.",
        Coords      = vec3(1537.56, 3795.58, 34.51),
        Permission  = "MarinaLounge",
        Rank        = 5,
        Modes       = { "Marina" },
    },
    -- Osaka Sushi · sem cardápio definido: a categoria "Osaka" não existe em
    -- recipes.lua e o core-totem também está com os itens pendentes.
    -- {
    --     Title       = "COZINHA DO OSAKA SUSHI",
    --     Description = "Combos, pratos e bebidas do cardápio.",
    --     Coords      = vec3(-792.84, -154.72, 37.76),
    --     Permission  = "OsakaSushi",
    --     Rank        = 5,
    --     Modes       = { "Osaka" },
    -- },

    -------------------------------------------------------------------------------------------------------------------------------------
    -- PÚBLICO
    -------------------------------------------------------------------------------------------------------------------------------------
    { -- Aberta para qualquer um
        Title       = "LAVANDERIA PÚBLICA",
        Description = "Troca de notas sujas por dinheiro limpo.",
        Coords      = vec3(-248.67, -2208.34, 9.89),
        Modes       = { "LavagemPublica" },
    },
}
