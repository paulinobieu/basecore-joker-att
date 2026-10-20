-----------------------------------------------------------------------------------------------------------------------------------------
-- CATÁLOGO
-- type: sempre "collection" · name: nome no painel · category: agrupador
-- price: preço em Diamantes na loja (omitido = Pets.Shop.DefaultPrice)
-- buyable: false = não aparece à venda na loja (só por entrega/evento)
-- tradeable: false = não pode ser trocada com outro jogador
-- icon: URL HTTPS · prop: prop em-jogo (pos/rot único ou lista de positions)
-- objetodiferente: true = usa o caminho de anexo alternativo no cliente
-- testable: (opcional) false = não pode testar na loja (default true)
-----------------------------------------------------------------------------------------------------------------------------------------
CollectionsCatalog = {

    -- ════════════════════════════════════════════════════════════════════════
    -- BACKYARDIGANS
    -- ════════════════════════════════════════════════════════════════════════
    ["austin"] = {
        type = "collection", name = "Austin", category = "Backyardigans", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/BACKYARDIGANS/austin.webp",
        prop = { model = "austinbackyardigans_by_joao", loop = true, moving = true, bone = 24817, pos = { x = 0.0, y = 0.45, z = -0.01 }, rot = { x = 0.1149, y = 88.0, z = 180.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["pablo"] = {
        type = "collection", name = "Pablo", category = "Backyardigans", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/BACKYARDIGANS/pablo.webp",
        prop = { model = "pablobackyardigans_by_joao", loop = true, moving = true, bone = 24817, pos = { x = 0.0, y = 0.45, z = -0.01 }, rot = { x = 0.1149, y = 88.0, z = 180.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["tasha"] = {
        type = "collection", name = "Tasha", category = "Backyardigans", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/BACKYARDIGANS/tasha.webp",
        prop = { model = "tashabackyardigans_by_joao", loop = true, moving = true, bone = 24817, pos = { x = 0.0, y = 0.45, z = -0.01 }, rot = { x = 0.1149, y = 88.0, z = 180.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["tyrone"] = {
        type = "collection", name = "Tyrone", category = "Backyardigans", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/BACKYARDIGANS/tyrone.webp",
        prop = { model = "tyronebackyardigans_by_joao", loop = true, moving = true, bone = 24817, pos = { x = 0.0, y = 0.45, z = -0.01 }, rot = { x = 0.1149, y = 88.0, z = 180.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["uniqua"] = {
        type = "collection", name = "Uniqua", category = "Backyardigans", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/BACKYARDIGANS/uniqua.webp",
        prop = { model = "uniquabackyardigans_by_joao", loop = true, moving = true, bone = 24817, pos = { x = 0.0, y = 0.45, z = -0.01 }, rot = { x = 0.1149, y = 88.0, z = 180.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- BAHAMAS
    -- ════════════════════════════════════════════════════════════════════════
    ["bahamas_angel"] = {
        type = "collection", name = "Angel", category = "Bahamas", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/BAHAMAS/angelbahamas.webp",
        prop = { model = "bag_angel", loop = true, moving = true, bone = 24817, pos = { x = -0.01, y = 0.45, z = -0.02 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["bahamas_stitch"] = {
        type = "collection", name = "Stitch", category = "Bahamas", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/BAHAMAS/stitchbahamas.webp",
        prop = { model = "bag_stitch", loop = true, moving = true, bone = 24817, pos = { x = -0.01, y = 0.45, z = -0.02 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- BOB ESPONJA
    -- ════════════════════════════════════════════════════════════════════════
    ["bobesponja"] = {
        type = "collection", name = "Bob Esponja", category = "Bob Esponja", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/BOB%20ESPONJA/bobesponja.webp",
        prop = { model = "spongebobanim_by_joao", loop = true, moving = true, bone = 31086, pos = { x = 0.18, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
    },
    ["gary"] = {
        type = "collection", name = "Gary", category = "Bob Esponja", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/BOB%20ESPONJA/gary.webp",
        prop = { model = "garyanim_by_joao", loop = true, moving = true, bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.05 }, rot = { x = 0.0, y = 0.0, z = 195.0 } },
    },
    ["lula"] = {
        type = "collection", name = "Lula Molusco", category = "Bob Esponja", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/BOB%20ESPONJA/lula.webp",
        prop = { model = "lulamolusco_by_joao", loop = true, moving = true, bone = 28422, pos = { x = -0.026, y = 0.1419, z = -0.04 }, rot = { x = -85.0, y = 34.945, z = 20.963 }, anim = { dict = "peluciaanim@joao", name = "esquerda_clip", flag = 49 } },
    },
    ["patrick"] = {
        type = "collection", name = "Patrick", category = "Bob Esponja", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/BOB%20ESPONJA/patrick.webp",
        prop = { model = "patrickstaranim_by_joao", loop = true, moving = true, bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.06 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
    },
    ["plankton"] = {
        type = "collection", name = "Plankton", category = "Bob Esponja", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/BOB%20ESPONJA/plankton.webp",
        prop = { model = "plankton_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.11, y = -0.021, z = 0.2 }, rot = { x = 0.0, y = 0.0, z = 170.0 }, anim = { dict = "expondopelucia@joao", name = "expondo_clip", flag = 49 } },
    },
    ["sandy"] = {
        type = "collection", name = "Sandy", category = "Bob Esponja", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/BOB%20ESPONJA/sandy.webp",
        prop = { model = "sandybochechas_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.0, y = 0.0957, z = 0.065 }, rot = { x = 104.704, y = -14.742, z = -147.15 }, anim = { dict = "peluciaanim@joao", name = "direita_clip", flag = 49 } },
    },
    ["sirigueijo"] = {
        type = "collection", name = "Sirigueijo", category = "Bob Esponja", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/BOB%20ESPONJA/sirigueijo.webp",
        prop = { model = "srsirigueijo_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 180.0, y = 275.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- BRAINROTS
    -- ════════════════════════════════════════════════════════════════════════
    ["ballerinacappuccina"] = {
        type = "collection", name = "Ballerina Cappuccina", category = "Brainrots", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/BRAINROTS/ballerinacappuccina.webp",
        prop = { model = "ballerinacappuccina_by_joao", loop = true, moving = true, bone = 10706, pos = { x = 0.09, y = 0.0, z = 0.16 }, rot = { x = 0.0, y = 0.0, z = 195.0 } },
    },
    ["bombardirocrocodilo"] = {
        type = "collection", name = "Bombardiro Crocodilo", category = "Brainrots", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/BRAINROTS/bombardinocrocodilo.webp",
        prop = { model = "bombardinocrocodilo_by_joao", loop = true, moving = true, bone = 31086, pos = { x = 0.23, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
    },
    ["cappuccinoassassino"] = {
        type = "collection", name = "Cappuccino Assassino", category = "Brainrots", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/BRAINROTS/cappuccinoassassino.webp",
        prop = { model = "cappuccinoassassino_by_joao", loop = true, moving = true, bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.15 }, rot = { x = 0.0, y = 180.0, z = 165.0 } },
    },
    ["tralalerotralala"] = {
        type = "collection", name = "Tralalero Tralala", category = "Brainrots", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/BRAINROTS/tralalerotralala.webp",
        prop = { model = "tralalerotralala_by_joao", loop = true, moving = true, bone = 31086, pos = { x = 0.23, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
    },
    ["tungtungsahur"] = {
        type = "collection", name = "Tung Tung Sahur", category = "Brainrots", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/BRAINROTS/tungtungsahur.webp",
        prop = { model = "tungtungsahur_by_joao", loop = true, moving = true, bone = 10706, pos = { x = 0.09, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = 0.0, z = 195.0 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- CALOPSITA
    -- ════════════════════════════════════════════════════════════════════════
    ["Calopsita"] = {
        type = "collection", name = "Calopsita", category = "Calopsita", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CALOPSITA/Calopsita.webp",
        prop = { model = "vfcalopsita", loop = true, moving = true, bone = 64729, pos = { x = 0.13, y = 0.0, z = -0.07 }, rot = { x = 183.0, y = 0.0, z = 21.0 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- CAPIVARA
    -- ════════════════════════════════════════════════════════════════════════
    ["Soul_capivara_coelho"] = {
        type = "collection", name = "Capivara Coelho", category = "Capivara", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CAPIVARA/capivara_coelho.webp",
        prop = { model = "Soul_capivara_coelho", loop = true, moving = true, bone = 60309, pos = { x = 0.05, y = 0.01, z = 0.12 }, rot = { x = -100.169998, y = -245.699997, z = -10.92 }, anim = { dict = "hold_flowers@dad", name = "hold_flowers_clip", flag = 49 } },
    },
    ["Soul_capivara_marrom"] = {
        type = "collection", name = "Capivara Marrom", category = "Capivara", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CAPIVARA/capivara_marrom.webp",
        prop = { model = "Soul_capivara_marrom", loop = true, moving = true, bone = 60309, pos = { x = 0.04, y = 0.0, z = 0.11 }, rot = { x = -111.019997, y = -233.869995, z = 0.0 }, anim = { dict = "hold_flowers@dad", name = "hold_flowers_clip", flag = 49 } },
    },
    ["Soul_capivara_natal"] = {
        type = "collection", name = "Capivara Natalina", category = "Capivara", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CAPIVARA/capivara_natal.webp",
        prop = { model = "Soul_capivara_natal", loop = true, moving = true, bone = 60309, pos = { x = 0.06, y = 0.03, z = 0.11 }, rot = { x = -107.379997, y = -252.070007, z = -12.74 }, anim = { dict = "hold_flowers@dad", name = "hold_flowers_clip", flag = 49 } },
    },
    ["Soul_capivara_r6"] = {
        type = "collection", name = "Capivara R6", category = "Capivara", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CAPIVARA/capivara_r6.webp",
        prop = { model = "Soul_capivara_r6", loop = true, moving = true, bone = 60309, pos = { x = 0.06, y = 0.03, z = 0.11 }, rot = { x = -107.379997, y = -252.070007, z = -12.74 }, anim = { dict = "hold_flowers@dad", name = "hold_flowers_clip", flag = 49 } },
    },
    ["Soul_capivara_verde"] = {
        type = "collection", name = "Capivara Verde", category = "Capivara", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CAPIVARA/capivara_verde.webp",
        prop = { model = "Soul_capivara_verde", loop = true, moving = true, bone = 60309, pos = { x = 0.06, y = 0.03, z = 0.11 }, rot = { x = -107.379997, y = -252.070007, z = -12.74 }, anim = { dict = "hold_flowers@dad", name = "hold_flowers_clip", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- CAQUINHOS
    -- ════════════════════════════════════════════════════════════════════════
    ["caquinha"] = {
        type = "collection", name = "Caquinha", category = "Caquinhos", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CAQUINHOS/caquinha.webp",
        prop = { model = "caquinhaprincesa_by_joao", loop = true, moving = true, positions = {
            { id = "ombro", label = "No Ombro", bone = 24818, pos = { x = 0.28, y = -0.0948, z = 0.022 }, rot = { x = -0.78, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noombro_clip", flag = 49 } },
            { id = "mao_direita", label = "Segurando", bone = 18905, pos = { x = 0.702, y = -0.13155, z = -0.0102 }, rot = { x = 180.0, y = 67.81, z = 0.48 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando2_clip", flag = 49 } },
            { id = "perna", label = "Na Perna", bone = 51826, pos = { x = 0.267, y = 0.0, z = 0.138 }, rot = { x = 0.0, y = -86.95, z = 167.49 }, anim = { dict = "caquinhocarnasoul@joao", name = "naperna_clip", flag = 49 } },
            { id = "mao_esquerda", label = "Segurando 2", bone = 18905, pos = { x = 0.653, y = -0.086, z = 0.0176 }, rot = { x = 180.0, y = 67.45, z = -3.52 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando_clip", flag = 49 } },
            { id = "colo", label = "No Colo", bone = 24818, pos = { x = -0.094, y = 0.164, z = 0.0 }, rot = { x = 180.0, y = -90.0, z = 0.42 }, anim = { dict = "caquinhocarnasoul@joao", name = "nocolo_clip", flag = 49 } },
            { id = "costas", label = "Nas Costas", bone = 24818, pos = { x = 0.2, y = -0.12, z = -0.1 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "nascostas_clip", flag = 49 } },
            { id = "antebraco", label = "No antebraço", bone = 61007, pos = { x = 0.0811, y = -0.00102, z = -0.136 }, rot = { x = -0.579, y = -90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noantebraco_clip", flag = 49 } },
        }},
    },
    ["caquinhosoul"] = {
        type = "collection", name = "Caquinho", category = "Caquinhos", price = 60, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CAQUINHOS/caquinho.webp",
        prop = { model = "chimpamzesoul_by_joao", loop = true, moving = true, positions = {
            { id = "ombro", label = "Ombro", bone = 24818, pos = { x = 0.28, y = -0.0948, z = 0.022 }, rot = { x = -0.78, y = 90.0, z = 180.0 }, anim = { dict = "chimapamzesoul@joao", name = "noombro_clip", flag = 49 } },
            { id = "mao_direita", label = "Mão direita", bone = 57005, pos = { x = 0.702, y = -0.13155, z = -0.0102 }, rot = { x = 180.0, y = 67.81, z = 0.48 }, anim = { dict = "chimapamzesoul@joao", name = "segurando2_clip", flag = 49 } },
            { id = "perna", label = "Perna", bone = 51826, pos = { x = 0.267, y = 0.0, z = 0.138 }, rot = { x = 0.0, y = -86.95, z = 167.49 }, anim = { dict = "chimapamzesoul@joao", name = "naperna_clip", flag = 49 } },
            { id = "mao_esquerda", label = "Mão esquerda", bone = 18905, pos = { x = 0.653, y = -0.086, z = 0.0176 }, rot = { x = 180.0, y = 67.45, z = -3.52 }, anim = { dict = "chimapamzesoul@joao", name = "segurando_clip", flag = 49 } },
            { id = "colo", label = "Colo", bone = 24818, pos = { x = -0.094, y = 0.164, z = 0.0 }, rot = { x = 180.0, y = -90.0, z = 0.42 }, anim = { dict = "chimapamzesoul@joao", name = "nocolo_clip", flag = 49 } },
            { id = "costas", label = "Costas", bone = 24818, pos = { x = 0.2, y = -0.12, z = -0.1 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "chimapamzesoul@joao", name = "nascostas_clip", flag = 49 } },
        }},
    },
    ["caquinho2"] = {
        type = "collection", name = "Caquinho", category = "Caquinhos", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CAQUINHOS/caquinho2.webp",
        prop = { model = "caquinhopvp_by_joao", loop = true, moving = true, positions = {
            { id = "ombro", label = "No Ombro", bone = 24818, pos = { x = 0.28, y = -0.0948, z = 0.022 }, rot = { x = -0.78, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noombro_clip", flag = 49 } },
            { id = "mao_direita", label = "Segurando", bone = 18905, pos = { x = 0.702, y = -0.13155, z = -0.0102 }, rot = { x = 180.0, y = 67.81, z = 0.48 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando2_clip", flag = 49 } },
            { id = "perna", label = "Na Perna", bone = 51826, pos = { x = 0.267, y = 0.0, z = 0.138 }, rot = { x = 0.0, y = -86.95, z = 167.49 }, anim = { dict = "caquinhocarnasoul@joao", name = "naperna_clip", flag = 49 } },
            { id = "mao_esquerda", label = "Segurando 2", bone = 18905, pos = { x = 0.653, y = -0.086, z = 0.0176 }, rot = { x = 180.0, y = 67.45, z = -3.52 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando_clip", flag = 49 } },
            { id = "colo", label = "No Colo", bone = 24818, pos = { x = -0.094, y = 0.164, z = 0.0 }, rot = { x = 180.0, y = -90.0, z = 0.42 }, anim = { dict = "caquinhocarnasoul@joao", name = "nocolo_clip", flag = 49 } },
            { id = "costas", label = "Nas Costas", bone = 24818, pos = { x = 0.2, y = -0.12, z = -0.1 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "nascostas_clip", flag = 49 } },
            { id = "antebraco", label = "No antebraço", bone = 61007, pos = { x = 0.0811, y = -0.00102, z = -0.136 }, rot = { x = -0.579, y = -90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noantebraco_clip", flag = 49 } },
        }},
    },
    ["caquinhoatletico"] = {
        type = "collection", name = "Caquinho Atletico", category = "Caquinhos", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CAQUINHOS/caquinhoatletico.webp",
        prop = { model = "caquinhoatletico_by_joao", loop = true, moving = true, positions = {
            { id = "ombro", label = "No Ombro", bone = 24818, pos = { x = 0.28, y = -0.0948, z = 0.022 }, rot = { x = -0.78, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noombro_clip", flag = 49 } },
            { id = "mao_direita", label = "Segurando", bone = 18905, pos = { x = 0.702, y = -0.13155, z = -0.0102 }, rot = { x = 180.0, y = 67.81, z = 0.48 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando2_clip", flag = 49 } },
            { id = "perna", label = "Na Perna", bone = 51826, pos = { x = 0.267, y = 0.0, z = 0.138 }, rot = { x = 0.0, y = -86.95, z = 167.49 }, anim = { dict = "caquinhocarnasoul@joao", name = "naperna_clip", flag = 49 } },
            { id = "mao_esquerda", label = "Segurando 2", bone = 18905, pos = { x = 0.653, y = -0.086, z = 0.0176 }, rot = { x = 180.0, y = 67.45, z = -3.52 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando_clip", flag = 49 } },
            { id = "colo", label = "No Colo", bone = 24818, pos = { x = -0.094, y = 0.164, z = 0.0 }, rot = { x = 180.0, y = -90.0, z = 0.42 }, anim = { dict = "caquinhocarnasoul@joao", name = "nocolo_clip", flag = 49 } },
            { id = "costas", label = "Nas Costas", bone = 24818, pos = { x = 0.2, y = -0.12, z = -0.1 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "nascostas_clip", flag = 49 } },
            { id = "antebraco", label = "No antebraço", bone = 61007, pos = { x = 0.0811, y = -0.00102, z = -0.136 }, rot = { x = -0.579, y = -90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noantebraco_clip", flag = 49 } },
        }},
    },
    ["caquinhobotafogo"] = {
        type = "collection", name = "Caquinho BotaFoguense", category = "Caquinhos", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CAQUINHOS/caquinhobotafogo.webp",
        prop = { model = "caquinhobotafogo_by_joao", loop = true, moving = true, positions = {
            { id = "ombro", label = "No Ombro", bone = 24818, pos = { x = 0.28, y = -0.0948, z = 0.022 }, rot = { x = -0.78, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noombro_clip", flag = 49 } },
            { id = "mao_direita", label = "Segurando", bone = 18905, pos = { x = 0.702, y = -0.13155, z = -0.0102 }, rot = { x = 180.0, y = 67.81, z = 0.48 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando2_clip", flag = 49 } },
            { id = "perna", label = "Na Perna", bone = 51826, pos = { x = 0.267, y = 0.0, z = 0.138 }, rot = { x = 0.0, y = -86.95, z = 167.49 }, anim = { dict = "caquinhocarnasoul@joao", name = "naperna_clip", flag = 49 } },
            { id = "mao_esquerda", label = "Segurando 2", bone = 18905, pos = { x = 0.653, y = -0.086, z = 0.0176 }, rot = { x = 180.0, y = 67.45, z = -3.52 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando_clip", flag = 49 } },
            { id = "colo", label = "No Colo", bone = 24818, pos = { x = -0.094, y = 0.164, z = 0.0 }, rot = { x = 180.0, y = -90.0, z = 0.42 }, anim = { dict = "caquinhocarnasoul@joao", name = "nocolo_clip", flag = 49 } },
            { id = "costas", label = "Nas Costas", bone = 24818, pos = { x = 0.2, y = -0.12, z = -0.1 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "nascostas_clip", flag = 49 } },
            { id = "antebraco", label = "No antebraço", bone = 61007, pos = { x = 0.0811, y = -0.00102, z = -0.136 }, rot = { x = -0.579, y = -90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noantebraco_clip", flag = 49 } },
        }},
    },
    ["caquinhocorinthians"] = {
        type = "collection", name = "Caquinho Corithiano", category = "Caquinhos", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CAQUINHOS/caquinhocorithians.webp",
        prop = { model = "caquinhocorithians_by_joao", loop = true, moving = true, positions = {
            { id = "ombro", label = "No Ombro", bone = 24818, pos = { x = 0.28, y = -0.0948, z = 0.022 }, rot = { x = -0.78, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noombro_clip", flag = 49 } },
            { id = "mao_direita", label = "Segurando", bone = 18905, pos = { x = 0.702, y = -0.13155, z = -0.0102 }, rot = { x = 180.0, y = 67.81, z = 0.48 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando2_clip", flag = 49 } },
            { id = "perna", label = "Na Perna", bone = 51826, pos = { x = 0.267, y = 0.0, z = 0.138 }, rot = { x = 0.0, y = -86.95, z = 167.49 }, anim = { dict = "caquinhocarnasoul@joao", name = "naperna_clip", flag = 49 } },
            { id = "mao_esquerda", label = "Segurando 2", bone = 18905, pos = { x = 0.653, y = -0.086, z = 0.0176 }, rot = { x = 180.0, y = 67.45, z = -3.52 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando_clip", flag = 49 } },
            { id = "colo", label = "No Colo", bone = 24818, pos = { x = -0.094, y = 0.164, z = 0.0 }, rot = { x = 180.0, y = -90.0, z = 0.42 }, anim = { dict = "caquinhocarnasoul@joao", name = "nocolo_clip", flag = 49 } },
            { id = "costas", label = "Nas Costas", bone = 24818, pos = { x = 0.2, y = -0.12, z = -0.1 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "nascostas_clip", flag = 49 } },
            { id = "antebraco", label = "No antebraço", bone = 61007, pos = { x = 0.0811, y = -0.00102, z = -0.136 }, rot = { x = -0.579, y = -90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noantebraco_clip", flag = 49 } },
        }},
    },
    ["caquinhocruzeiro"] = {
        type = "collection", name = "Caquinho Cruzeirense", category = "Caquinhos", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CAQUINHOS/caquinhocruzeiro.webp",
        prop = { model = "caquinhocruzeiro_by_joao", loop = true, moving = true, positions = {
            { id = "ombro", label = "No Ombro", bone = 24818, pos = { x = 0.28, y = -0.0948, z = 0.022 }, rot = { x = -0.78, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noombro_clip", flag = 49 } },
            { id = "mao_direita", label = "Segurando", bone = 18905, pos = { x = 0.702, y = -0.13155, z = -0.0102 }, rot = { x = 180.0, y = 67.81, z = 0.48 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando2_clip", flag = 49 } },
            { id = "perna", label = "Na Perna", bone = 51826, pos = { x = 0.267, y = 0.0, z = 0.138 }, rot = { x = 0.0, y = -86.95, z = 167.49 }, anim = { dict = "caquinhocarnasoul@joao", name = "naperna_clip", flag = 49 } },
            { id = "mao_esquerda", label = "Segurando 2", bone = 18905, pos = { x = 0.653, y = -0.086, z = 0.0176 }, rot = { x = 180.0, y = 67.45, z = -3.52 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando_clip", flag = 49 } },
            { id = "colo", label = "No Colo", bone = 24818, pos = { x = -0.094, y = 0.164, z = 0.0 }, rot = { x = 180.0, y = -90.0, z = 0.42 }, anim = { dict = "caquinhocarnasoul@joao", name = "nocolo_clip", flag = 49 } },
            { id = "costas", label = "Nas Costas", bone = 24818, pos = { x = 0.2, y = -0.12, z = -0.1 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "nascostas_clip", flag = 49 } },
            { id = "antebraco", label = "No antebraço", bone = 61007, pos = { x = 0.0811, y = -0.00102, z = -0.136 }, rot = { x = -0.579, y = -90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noantebraco_clip", flag = 49 } },
        }},
    },
    ["caquinhoflamengo"] = {
        type = "collection", name = "Caquinho Flamenguista", category = "Caquinhos", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CAQUINHOS/caquinhoflamengo.webp",
        prop = { model = "caquinhoflamengo_by_joao", loop = true, moving = true, positions = {
            { id = "ombro", label = "No Ombro", bone = 24818, pos = { x = 0.28, y = -0.0948, z = 0.022 }, rot = { x = -0.78, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noombro_clip", flag = 49 } },
            { id = "mao_direita", label = "Segurando", bone = 18905, pos = { x = 0.702, y = -0.13155, z = -0.0102 }, rot = { x = 180.0, y = 67.81, z = 0.48 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando2_clip", flag = 49 } },
            { id = "perna", label = "Na Perna", bone = 51826, pos = { x = 0.267, y = 0.0, z = 0.138 }, rot = { x = 0.0, y = -86.95, z = 167.49 }, anim = { dict = "caquinhocarnasoul@joao", name = "naperna_clip", flag = 49 } },
            { id = "mao_esquerda", label = "Segurando 2", bone = 18905, pos = { x = 0.653, y = -0.086, z = 0.0176 }, rot = { x = 180.0, y = 67.45, z = -3.52 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando_clip", flag = 49 } },
            { id = "colo", label = "No Colo", bone = 24818, pos = { x = -0.094, y = 0.164, z = 0.0 }, rot = { x = 180.0, y = -90.0, z = 0.42 }, anim = { dict = "caquinhocarnasoul@joao", name = "nocolo_clip", flag = 49 } },
            { id = "costas", label = "Nas Costas", bone = 24818, pos = { x = 0.2, y = -0.12, z = -0.1 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "nascostas_clip", flag = 49 } },
            { id = "antebraco", label = "No antebraço", bone = 61007, pos = { x = 0.0811, y = -0.00102, z = -0.136 }, rot = { x = -0.579, y = -90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noantebraco_clip", flag = 49 } },
        }},
    },
    ["caquinhofluminense"] = {
        type = "collection", name = "Caquinho Fluminense", category = "Caquinhos", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CAQUINHOS/caquinhofluminense.webp",
        prop = { model = "caquinhofluminense_by_joao", loop = true, moving = true, positions = {
            { id = "ombro", label = "No Ombro", bone = 24818, pos = { x = 0.28, y = -0.0948, z = 0.022 }, rot = { x = -0.78, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noombro_clip", flag = 49 } },
            { id = "mao_direita", label = "Segurando", bone = 18905, pos = { x = 0.702, y = -0.13155, z = -0.0102 }, rot = { x = 180.0, y = 67.81, z = 0.48 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando2_clip", flag = 49 } },
            { id = "perna", label = "Na Perna", bone = 51826, pos = { x = 0.267, y = 0.0, z = 0.138 }, rot = { x = 0.0, y = -86.95, z = 167.49 }, anim = { dict = "caquinhocarnasoul@joao", name = "naperna_clip", flag = 49 } },
            { id = "mao_esquerda", label = "Segurando 2", bone = 18905, pos = { x = 0.653, y = -0.086, z = 0.0176 }, rot = { x = 180.0, y = 67.45, z = -3.52 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando_clip", flag = 49 } },
            { id = "colo", label = "No Colo", bone = 24818, pos = { x = -0.094, y = 0.164, z = 0.0 }, rot = { x = 180.0, y = -90.0, z = 0.42 }, anim = { dict = "caquinhocarnasoul@joao", name = "nocolo_clip", flag = 49 } },
            { id = "costas", label = "Nas Costas", bone = 24818, pos = { x = 0.2, y = -0.12, z = -0.1 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "nascostas_clip", flag = 49 } },
            { id = "antebraco", label = "No antebraço", bone = 61007, pos = { x = 0.0811, y = -0.00102, z = -0.136 }, rot = { x = -0.579, y = -90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noantebraco_clip", flag = 49 } },
        }},
    },
    ["caquinhocarnaval"] = {
        type = "collection", name = "Caquinho Folião", category = "Caquinhos", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CAQUINHOS/caquinhocarnaval.webp",
        prop = { model = "caquinhocarnasoul_by_joao", loop = true, moving = true, positions = {
            { id = "ombro", label = "Ombro", bone = 24818, pos = { x = 0.28, y = -0.0948, z = 0.022 }, rot = { x = -0.78, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noombro_clip", flag = 49 } },
            { id = "mao_direita", label = "Mão direita", bone = 18905, pos = { x = 0.702, y = -0.13155, z = -0.0102 }, rot = { x = 180.0, y = 67.81, z = 0.48 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando2_clip", flag = 49 } },
            { id = "perna", label = "Perna", bone = 51826, pos = { x = 0.267, y = 0.0, z = 0.138 }, rot = { x = 0.0, y = -86.95, z = 167.49 }, anim = { dict = "caquinhocarnasoul@joao", name = "naperna_clip", flag = 49 } },
            { id = "mao_esquerda", label = "Mão esquerda", bone = 18905, pos = { x = 0.653, y = -0.086, z = 0.0176 }, rot = { x = 180.0, y = 67.45, z = -3.52 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando_clip", flag = 49 } },
            { id = "colo", label = "Colo", bone = 24818, pos = { x = -0.094, y = 0.164, z = 0.0 }, rot = { x = 180.0, y = -90.0, z = 0.42 }, anim = { dict = "caquinhocarnasoul@joao", name = "nocolo_clip", flag = 49 } },
            { id = "costas", label = "Costas", bone = 24818, pos = { x = 0.2, y = -0.12, z = -0.1 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "nascostas_clip", flag = 49 } },
            { id = "antebraco", label = "Antebraço", bone = 61007, pos = { x = 0.0811, y = -0.00102, z = -0.136 }, rot = { x = -0.579, y = -90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noantebraco_clip", flag = 49 } },
        }},
    },
    ["caquinhogremio"] = {
        type = "collection", name = "Caquinho Grêmista", category = "Caquinhos", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CAQUINHOS/caquinhogremio.webp",
        prop = { model = "caquinhogremio_by_joao", loop = true, moving = true, positions = {
            { id = "ombro", label = "No Ombro", bone = 24818, pos = { x = 0.28, y = -0.0948, z = 0.022 }, rot = { x = -0.78, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noombro_clip", flag = 49 } },
            { id = "mao_direita", label = "Segurando", bone = 18905, pos = { x = 0.702, y = -0.13155, z = -0.0102 }, rot = { x = 180.0, y = 67.81, z = 0.48 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando2_clip", flag = 49 } },
            { id = "perna", label = "Na Perna", bone = 51826, pos = { x = 0.267, y = 0.0, z = 0.138 }, rot = { x = 0.0, y = -86.95, z = 167.49 }, anim = { dict = "caquinhocarnasoul@joao", name = "naperna_clip", flag = 49 } },
            { id = "mao_esquerda", label = "Segurando 2", bone = 18905, pos = { x = 0.653, y = -0.086, z = 0.0176 }, rot = { x = 180.0, y = 67.45, z = -3.52 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando_clip", flag = 49 } },
            { id = "colo", label = "No Colo", bone = 24818, pos = { x = -0.094, y = 0.164, z = 0.0 }, rot = { x = 180.0, y = -90.0, z = 0.42 }, anim = { dict = "caquinhocarnasoul@joao", name = "nocolo_clip", flag = 49 } },
            { id = "costas", label = "Nas Costas", bone = 24818, pos = { x = 0.2, y = -0.12, z = -0.1 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "nascostas_clip", flag = 49 } },
            { id = "antebraco", label = "No antebraço", bone = 61007, pos = { x = 0.0811, y = -0.00102, z = -0.136 }, rot = { x = -0.579, y = -90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noantebraco_clip", flag = 49 } },
        }},
    },
    ["caquinhointer"] = {
        type = "collection", name = "Caquinho Inter", category = "Caquinhos", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CAQUINHOS/caquinhointer.webp",
        prop = { model = "caquinhointer_by_joao", loop = true, moving = true, positions = {
            { id = "ombro", label = "No Ombro", bone = 24818, pos = { x = 0.28, y = -0.0948, z = 0.022 }, rot = { x = -0.78, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noombro_clip", flag = 49 } },
            { id = "mao_direita", label = "Segurando", bone = 18905, pos = { x = 0.702, y = -0.13155, z = -0.0102 }, rot = { x = 180.0, y = 67.81, z = 0.48 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando2_clip", flag = 49 } },
            { id = "perna", label = "Na Perna", bone = 51826, pos = { x = 0.267, y = 0.0, z = 0.138 }, rot = { x = 0.0, y = -86.95, z = 167.49 }, anim = { dict = "caquinhocarnasoul@joao", name = "naperna_clip", flag = 49 } },
            { id = "mao_esquerda", label = "Segurando 2", bone = 18905, pos = { x = 0.653, y = -0.086, z = 0.0176 }, rot = { x = 180.0, y = 67.45, z = -3.52 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando_clip", flag = 49 } },
            { id = "colo", label = "No Colo", bone = 24818, pos = { x = -0.094, y = 0.164, z = 0.0 }, rot = { x = 180.0, y = -90.0, z = 0.42 }, anim = { dict = "caquinhocarnasoul@joao", name = "nocolo_clip", flag = 49 } },
            { id = "costas", label = "Nas Costas", bone = 24818, pos = { x = 0.2, y = -0.12, z = -0.1 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "nascostas_clip", flag = 49 } },
            { id = "antebraco", label = "No antebraço", bone = 61007, pos = { x = 0.0811, y = -0.00102, z = -0.136 }, rot = { x = -0.579, y = -90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noantebraco_clip", flag = 49 } },
        }},
    },
    ["caquinhopalmeiras"] = {
        type = "collection", name = "Caquinho Palmeirense", category = "Caquinhos", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CAQUINHOS/caquinhopalmeiras.webp",
        prop = { model = "caquinhopalmeiras_by_joao", loop = true, moving = true, positions = {
            { id = "ombro", label = "No Ombro", bone = 24818, pos = { x = 0.28, y = -0.0948, z = 0.022 }, rot = { x = -0.78, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noombro_clip", flag = 49 } },
            { id = "mao_direita", label = "Segurando", bone = 18905, pos = { x = 0.702, y = -0.13155, z = -0.0102 }, rot = { x = 180.0, y = 67.81, z = 0.48 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando2_clip", flag = 49 } },
            { id = "perna", label = "Na Perna", bone = 51826, pos = { x = 0.267, y = 0.0, z = 0.138 }, rot = { x = 0.0, y = -86.95, z = 167.49 }, anim = { dict = "caquinhocarnasoul@joao", name = "naperna_clip", flag = 49 } },
            { id = "mao_esquerda", label = "Segurando 2", bone = 18905, pos = { x = 0.653, y = -0.086, z = 0.0176 }, rot = { x = 180.0, y = 67.45, z = -3.52 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando_clip", flag = 49 } },
            { id = "colo", label = "No Colo", bone = 24818, pos = { x = -0.094, y = 0.164, z = 0.0 }, rot = { x = 180.0, y = -90.0, z = 0.42 }, anim = { dict = "caquinhocarnasoul@joao", name = "nocolo_clip", flag = 49 } },
            { id = "costas", label = "Nas Costas", bone = 24818, pos = { x = 0.2, y = -0.12, z = -0.1 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "nascostas_clip", flag = 49 } },
            { id = "antebraco", label = "No antebraço", bone = 61007, pos = { x = 0.0811, y = -0.00102, z = -0.136 }, rot = { x = -0.579, y = -90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noantebraco_clip", flag = 49 } },
        }},
    },
    ["caquinhopascoa"] = {
        type = "collection", name = "Caquinho Páscoa", category = "Caquinhos", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CAQUINHOS/caquinhopascoa.webp",
        prop = { model = "caquinhodapascoa_by_joao", loop = true, moving = true, positions = {
            { id = "ombro", label = "No ombro", bone = 24818, pos = { x = 0.28, y = -0.0948, z = 0.022 }, rot = { x = -0.78, y = 90.0, z = 180.0 }, anim = { dict = "caquinhodapascoa@joao", name = "noombro_clip", flag = 49 } },
            { id = "segurando", label = "Segurando", bone = 18905, pos = { x = 0.702, y = -0.13155, z = -0.0102 }, rot = { x = 180.0, y = 67.81, z = 0.48 }, anim = { dict = "caquinhodapascoa@joao", name = "segurando2_clip", flag = 49 } },
            { id = "perna", label = "Na perna", bone = 51826, pos = { x = 0.267, y = 0.0, z = 0.138 }, rot = { x = 0.0, y = -86.95, z = 167.49 }, anim = { dict = "caquinhodapascoa@joao", name = "naperna_clip", flag = 49 } },
            { id = "segurando2", label = "Segurando 2", bone = 18905, pos = { x = 0.653, y = -0.086, z = 0.0176 }, rot = { x = 180.0, y = 67.45, z = -3.52 }, anim = { dict = "caquinhodapascoa@joao", name = "segurando_clip", flag = 49 } },
            { id = "colo", label = "No colo", bone = 24818, pos = { x = -0.094, y = 0.164, z = 0.0 }, rot = { x = 180.0, y = -90.0, z = 0.42 }, anim = { dict = "caquinhodapascoa@joao", name = "nocolo_clip", flag = 49 } },
            { id = "costas", label = "Nas costas", bone = 24818, pos = { x = 0.2, y = -0.12, z = -0.1 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "caquinhodapascoa@joao", name = "nascostas_clip", flag = 49 } },
            { id = "antebraco", label = "No antebraço", bone = 61007, pos = { x = 0.0811, y = -0.00102, z = -0.136 }, rot = { x = -0.579, y = -90.0, z = 180.0 }, anim = { dict = "caquinhodapascoa@joao", name = "noantebraco_clip", flag = 49 } },
            { id = "andando", label = "Andando", bone = 0, pos = { x = -0.5, y = 0.0, z = -0.79 }, rot = { x = 0.0, y = 0.0, z = 180.0 }, anim = { dict = "caquinhodapascoa@joao", name = "andando_clip", flag = 49 } },
            { id = "colo2", label = "No colo 2", bone = 18905, pos = { x = 0.0046, y = 0.0515, z = 0.078 }, rot = { x = -112.74, y = 67.1, z = 5.65 }, animOnPed = true, anim = { dict = "segurandocoelhinho@joao", name = "segurandocaquinho_clip", flag = 49 } },
        }},
    },
    ["caquinhosantos"] = {
        type = "collection", name = "Caquinho Santista", category = "Caquinhos", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CAQUINHOS/caquinhosantos.webp",
        prop = { model = "caquinhosantos_by_joao", loop = true, moving = true, positions = {
            { id = "ombro", label = "No Ombro", bone = 24818, pos = { x = 0.28, y = -0.0948, z = 0.022 }, rot = { x = -0.78, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noombro_clip", flag = 49 } },
            { id = "mao_direita", label = "Segurando", bone = 18905, pos = { x = 0.702, y = -0.13155, z = -0.0102 }, rot = { x = 180.0, y = 67.81, z = 0.48 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando2_clip", flag = 49 } },
            { id = "perna", label = "Na Perna", bone = 51826, pos = { x = 0.267, y = 0.0, z = 0.138 }, rot = { x = 0.0, y = -86.95, z = 167.49 }, anim = { dict = "caquinhocarnasoul@joao", name = "naperna_clip", flag = 49 } },
            { id = "mao_esquerda", label = "Segurando 2", bone = 18905, pos = { x = 0.653, y = -0.086, z = 0.0176 }, rot = { x = 180.0, y = 67.45, z = -3.52 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando_clip", flag = 49 } },
            { id = "colo", label = "No Colo", bone = 24818, pos = { x = -0.094, y = 0.164, z = 0.0 }, rot = { x = 180.0, y = -90.0, z = 0.42 }, anim = { dict = "caquinhocarnasoul@joao", name = "nocolo_clip", flag = 49 } },
            { id = "costas", label = "Nas Costas", bone = 24818, pos = { x = 0.2, y = -0.12, z = -0.1 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "nascostas_clip", flag = 49 } },
            { id = "antebraco", label = "No antebraço", bone = 61007, pos = { x = 0.0811, y = -0.00102, z = -0.136 }, rot = { x = -0.579, y = -90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noantebraco_clip", flag = 49 } },
        }},
    },
    ["caquinhosaopaulo"] = {
        type = "collection", name = "Caquinho São Paulo", category = "Caquinhos", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CAQUINHOS/caquinhosaopaulo.webp",
        prop = { model = "caquinhosaopaulo_by_joao", loop = true, moving = true, positions = {
            { id = "ombro", label = "No Ombro", bone = 24818, pos = { x = 0.28, y = -0.0948, z = 0.022 }, rot = { x = -0.78, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noombro_clip", flag = 49 } },
            { id = "mao_direita", label = "Segurando", bone = 18905, pos = { x = 0.702, y = -0.13155, z = -0.0102 }, rot = { x = 180.0, y = 67.81, z = 0.48 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando2_clip", flag = 49 } },
            { id = "perna", label = "Na Perna", bone = 51826, pos = { x = 0.267, y = 0.0, z = 0.138 }, rot = { x = 0.0, y = -86.95, z = 167.49 }, anim = { dict = "caquinhocarnasoul@joao", name = "naperna_clip", flag = 49 } },
            { id = "mao_esquerda", label = "Segurando 2", bone = 18905, pos = { x = 0.653, y = -0.086, z = 0.0176 }, rot = { x = 180.0, y = 67.45, z = -3.52 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando_clip", flag = 49 } },
            { id = "colo", label = "No Colo", bone = 24818, pos = { x = -0.094, y = 0.164, z = 0.0 }, rot = { x = 180.0, y = -90.0, z = 0.42 }, anim = { dict = "caquinhocarnasoul@joao", name = "nocolo_clip", flag = 49 } },
            { id = "costas", label = "Nas Costas", bone = 24818, pos = { x = 0.2, y = -0.12, z = -0.1 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "nascostas_clip", flag = 49 } },
            { id = "antebraco", label = "No antebraço", bone = 61007, pos = { x = 0.0811, y = -0.00102, z = -0.136 }, rot = { x = -0.579, y = -90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noantebraco_clip", flag = 49 } },
        }},
    },
    ["caquinhovasco"] = {
        type = "collection", name = "Caquinho Vascaino", category = "Caquinhos", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CAQUINHOS/caquinhovasco.webp",
        prop = { model = "caquinhovasco_by_joao", loop = true, moving = true, positions = {
            { id = "ombro", label = "No Ombro", bone = 24818, pos = { x = 0.28, y = -0.0948, z = 0.022 }, rot = { x = -0.78, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noombro_clip", flag = 49 } },
            { id = "mao_direita", label = "Segurando", bone = 18905, pos = { x = 0.702, y = -0.13155, z = -0.0102 }, rot = { x = 180.0, y = 67.81, z = 0.48 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando2_clip", flag = 49 } },
            { id = "perna", label = "Na Perna", bone = 51826, pos = { x = 0.267, y = 0.0, z = 0.138 }, rot = { x = 0.0, y = -86.95, z = 167.49 }, anim = { dict = "caquinhocarnasoul@joao", name = "naperna_clip", flag = 49 } },
            { id = "mao_esquerda", label = "Segurando 2", bone = 18905, pos = { x = 0.653, y = -0.086, z = 0.0176 }, rot = { x = 180.0, y = 67.45, z = -3.52 }, anim = { dict = "caquinhocarnasoul@joao", name = "segurando_clip", flag = 49 } },
            { id = "colo", label = "No Colo", bone = 24818, pos = { x = -0.094, y = 0.164, z = 0.0 }, rot = { x = 180.0, y = -90.0, z = 0.42 }, anim = { dict = "caquinhocarnasoul@joao", name = "nocolo_clip", flag = 49 } },
            { id = "costas", label = "Nas Costas", bone = 24818, pos = { x = 0.2, y = -0.12, z = -0.1 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "nascostas_clip", flag = 49 } },
            { id = "antebraco", label = "No antebraço", bone = 61007, pos = { x = 0.0811, y = -0.00102, z = -0.136 }, rot = { x = -0.579, y = -90.0, z = 180.0 }, anim = { dict = "caquinhocarnasoul@joao", name = "noantebraco_clip", flag = 49 } },
        }},
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- CARROS
    -- ════════════════════════════════════════════════════════════════════════
    ["Cruz"] = {
        type = "collection", name = "Cruz Ramirez", category = "Carros", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CARROS/cruz.webp",
        prop = { model = "Koch_Store_Cruz", loop = true, moving = true, bone = 60309, pos = { x = 0.06, y = 0.02, z = 0.11 }, rot = { x = -101.01, y = 107.38, z = -11.83 }, anim = { dict = "hold_flowers@dad", name = "hold_flowers_clip", flag = 49 } },
    },
    ["Doc"] = {
        type = "collection", name = "Doc Hudson", category = "Carros", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CARROS/doc.webp",
        prop = { model = "Koch_Store_Doc", loop = true, moving = true, bone = 60309, pos = { x = 0.06, y = 0.02, z = 0.11 }, rot = { x = -101.01, y = 107.38, z = -11.83 }, anim = { dict = "hold_flowers@dad", name = "hold_flowers_clip", flag = 49 } },
    },
    ["Guido"] = {
        type = "collection", name = "Guido", category = "Carros", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CARROS/guido.webp",
        prop = { model = "Koch_Store_Guido", loop = false, moving = true, bone = 64729, pos = { x = 0.12, y = 0.0, z = -0.1 }, rot = { x = -13.65, y = -185.83, z = -205.66 } },
    },
    ["Luigi"] = {
        type = "collection", name = "Luigi", category = "Carros", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CARROS/luigi.webp",
        prop = { model = "Koch_Store_Luigi", loop = false, moving = true, bone = 10706, pos = { x = 0.1, y = -0.01, z = 0.08 }, rot = { x = 0.0, y = -1.82, z = -161.07 } },
    },
    ["Mater"] = {
        type = "collection", name = "Mater", category = "Carros", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CARROS/mater.webp",
        prop = { model = "Koch_Store_Mater", loop = true, moving = true, bone = 60309, pos = { x = 0.06, y = 0.02, z = 0.11 }, rot = { x = -101.01, y = 107.38, z = -11.83 }, anim = { dict = "hold_flowers@dad", name = "hold_flowers_clip", flag = 49 } },
    },
    ["Mcqueen"] = {
        type = "collection", name = "McQueen", category = "Carros", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CARROS/mcqueen.webp",
        prop = { model = "Koch_Store_Mcqueen", loop = true, moving = true, bone = 18905, pos = { x = -0.04, y = -0.13, z = 0.13 }, rot = { x = -5.46, y = -206.82, z = -1227.59 }, anim = { dict = "holding_book_3@dark", name = "holding_book_3_clip", flag = 49 } },
    },
    ["Sally"] = {
        type = "collection", name = "Sally", category = "Carros", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CARROS/sally.webp",
        prop = { model = "Koch_Store_Sally", loop = true, moving = true, bone = 18905, pos = { x = 0.0, y = -0.04, z = 0.17 }, rot = { x = -1.9, y = -191.1, z = -142.87 }, anim = { dict = "holding_book_3@dark", name = "holding_book_3_clip", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- CARTOON NETWORK
    -- ════════════════════════════════════════════════════════════════════════
    ["ben10"] = {
        type = "collection", name = "Ben 10", category = "Cartoon Network", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CARTOON%20NETWORK/ben10.webp",
        prop = { model = "dreamsstore_ben10", loop = true, moving = true, bone = 28422, pos = { x = -0.120927, y = -0.230408, z = -0.120515 }, rot = { x = -12.024129, y = -2.873321, z = 165.803594 }, anim = { dict = "amb@code_human_wander_drinking@male@base", name = "static", flag = 49 } },
    },
    ["coragem"] = {
        type = "collection", name = "Coragem", category = "Cartoon Network", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CARTOON%20NETWORK/coragem.webp",
        prop = { model = "dreamsstore_coragem", loop = true, moving = true, bone = 28422, pos = { x = -0.046948, y = 0.153739, z = -0.18673 }, rot = { x = -109.686063, y = 23.614802, z = 167.568636 }, anim = { dict = "amb@code_human_wander_eating_donut@female@base", name = "static", flag = 49 } },
    },
    ["johnny"] = {
        type = "collection", name = "Johnny", category = "Cartoon Network", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CARTOON%20NETWORK/jhonny.webp",
        prop = { model = "dreamsstore_johnny", loop = true, moving = true, bone = 64729, pos = { x = 0.340518, y = -0.016383, z = 0.658956 }, rot = { x = 174.08774, y = 37.032062, z = 25.774003 } },
    },
    ["puroosso"] = {
        type = "collection", name = "Puro Osso", category = "Cartoon Network", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CARTOON%20NETWORK/puroosso.webp",
        prop = { model = "dreamsstore_puroosso", loop = true, moving = true, bone = 64729, pos = { x = 0.016173, y = -0.01944, z = 0.744871 }, rot = { x = 179.157147, y = -5.021441, z = 17.84407 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- CHAVES
    -- ════════════════════════════════════════════════════════════════════════
    ["chaves"] = {
        type = "collection", name = "Chaves", category = "Chaves", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CHAVES/gotica_chaves.webp",
        prop = { model = "gotica_chaves", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["chiquinha"] = {
        type = "collection", name = "Chiquinha", category = "Chaves", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CHAVES/gotica_chiquinha.webp",
        prop = { model = "gotica_chiquinha", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["donaflorinda"] = {
        type = "collection", name = "Dona Florinda", category = "Chaves", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CHAVES/gotica_donaflorinda.webp",
        prop = { model = "gotica_donaflorinda", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["girafales"] = {
        type = "collection", name = "Girafales", category = "Chaves", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CHAVES/gotica_girafales.webp",
        prop = { model = "gotica_girafales", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["kiko"] = {
        type = "collection", name = "Kiko", category = "Chaves", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CHAVES/gotica_kiko.webp",
        prop = { model = "gotica_kiko", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["seumadruga"] = {
        type = "collection", name = "Seu Madruga", category = "Chaves", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/CHAVES/gotica_seumadruga.webp",
        prop = { model = "gotica_seumadruga", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- COELHOS
    -- ════════════════════════════════════════════════════════════════════════
    ["coelho1"] = {
        type = "collection", name = "Coelho 1", category = "Coelhos", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/COELHOS/coelho1.webp",
        prop = { model = "dreamsstore_coelho1", loop = true, moving = true, bone = 28422, pos = { x = -0.030124, y = -0.083599, z = -0.033523 }, rot = { x = -110.506183, y = 15.20104, z = 168.165109 }, anim = { dict = "amb@code_human_wander_eating_donut@female@base", name = "static", flag = 49 } },
    },
    ["coelho2"] = {
        type = "collection", name = "Coelho 2", category = "Coelhos", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/COELHOS/coelho2.webp",
        prop = { model = "dreamsstore_coelho2", loop = true, moving = true, bone = 28422, pos = { x = 0.116257, y = 0.080919, z = -0.049307 }, rot = { x = -36.072629, y = 36.534632, z = -20.713506 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },
    ["coelho3"] = {
        type = "collection", name = "Coelho 3", category = "Coelhos", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/COELHOS/coelho3.webp",
        prop = { model = "dreamsstore_coelho3", loop = true, moving = true, bone = 28422, pos = { x = -0.057375, y = 0.166014, z = -0.016707 }, rot = { x = -70.552918, y = -19.53015, z = -3.973869 }, anim = { dict = "random@shop_gunstore", name = "_idle", flag = 49 } },
    },
    ["coelho4"] = {
        type = "collection", name = "Coelho 4", category = "Coelhos", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/COELHOS/coelho4.webp",
        prop = { model = "dreamsstore_coelho4", loop = true, moving = true, bone = 6286, pos = { x = 0.125183, y = 0.114074, z = -0.026236 }, rot = { x = -77.522318, y = 53.243009, z = 6.203196 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },
    ["coelho5"] = {
        type = "collection", name = "Coelho 5", category = "Coelhos", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/COELHOS/coelho5.webp",
        prop = { model = "dreamsstore_coelho5", loop = true, moving = true, bone = 12844, pos = { x = 0.290841, y = -0.02172, z = -0.005638 }, rot = { x = 173.857904, y = -81.780244, z = 0.0 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- COMO TREINAR O SEU DRAGÃO
    -- ════════════════════════════════════════════════════════════════════════
    ["astrid"] = {
        type = "collection", name = "Astrid", category = "Como Treinar o Seu Dragão", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/COMO%20TREINAR%20O%20SEU%20DRAG%C3%83O/astrid.webp",
        prop = { model = "dreamsstore_astrid", loop = true, moving = true, bone = 6286, pos = { x = -0.161514, y = -0.063829, z = -0.125912 }, rot = { x = -71.862454, y = 55.503543, z = 11.02586 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },
    ["banguela"] = {
        type = "collection", name = "Banguela", category = "Como Treinar o Seu Dragão", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/COMO%20TREINAR%20O%20SEU%20DRAG%C3%83O/banguela.webp",
        prop = { model = "dreamsstore_banguela", loop = true, moving = true, bone = 6286, pos = { x = -0.161514, y = -0.063829, z = -0.125912 }, rot = { x = -71.862454, y = 55.503543, z = 11.02586 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },
    ["Soul_dragaob"] = {
        type = "collection", name = "Dragão Azul", category = "Como Treinar o Seu Dragão", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/COMO%20TREINAR%20O%20SEU%20DRAG%C3%83O/dragaob.webp",
        prop = { model = "Soul_dragaob", loop = true, moving = true, bone = 60309, pos = { x = 0.04, y = 0.13, z = 0.07 }, rot = { x = -95.550003, y = -242.110001, z = -16.379999 }, anim = { dict = "hold_flowers@dad", name = "hold_flowers_clip", flag = 49 } },
    },
    ["Soul_dragaop"] = {
        type = "collection", name = "Dragão Rosa", category = "Como Treinar o Seu Dragão", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/COMO%20TREINAR%20O%20SEU%20DRAG%C3%83O/dragaop.webp",
        prop = { model = "Soul_dragaop", loop = true, moving = true, bone = 60309, pos = { x = 0.04, y = 0.07, z = 0.08 }, rot = { x = -96.419998, y = -256.75, z = -13.69 }, anim = { dict = "hold_flowers@dad", name = "hold_flowers_clip", flag = 49 } },
    },
    ["furiadaluz"] = {
        type = "collection", name = "Fúria da Luz", category = "Como Treinar o Seu Dragão", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/COMO%20TREINAR%20O%20SEU%20DRAG%C3%83O/furiadaluz.webp",
        prop = { model = "dreamsstore_furiadaluz", loop = true, moving = true, bone = 6286, pos = { x = -0.161514, y = -0.063829, z = -0.125912 }, rot = { x = -71.862454, y = 55.503543, z = 11.02586 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },
    ["light"] = {
        type = "collection", name = "Light", category = "Como Treinar o Seu Dragão", price = 240,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/COMO%20TREINAR%20SEU%20DRAG%C3%83O/FURIA%20DA%20LUZ.webp",
        prop = { model = "jpx_light_fury_mount", loop = true, moving = true, positions = {
            { id = "na_mao",    label = "Na Mão",     bone = 12844, pos = { x = -0.03, y =  0.15, z =  0.03  }, rot = { x =   0.0,  y =   90.0, z =  180.0 }, model = "jpx_light_fury_mount"    },
            { id = "no_ombro",  label = "No Ombro",   bone = 64729, pos = { x =  0.18, y = -0.02, z = -0.13  }, rot = { x = -10.0,  y =  180.0, z = -190.0 }, model = "jpx_light_fury_shoulder" },
            { id = "segurando", label = "Segurando",  bone = 45509, pos = { x =  0.55, y =  0.07, z = -0.07  }, rot = { x =   0.0,  y =  240.0, z =  180.0 }, model = "jpx_light_fury_hold"     },
            { id = "no_chao",   label = "No Chão",    bone = 20190, pos = { x =  0.85, y =  0.0,  z = -0.82  }, rot = { x =   0.0,  y =    0.0, z =  210.0 }, model = "jpx_light_fury_ground"   },
            { id = "flutuando", label = "Flutuando",  bone = 20190, pos = { x = -0.5,  y =  0.0,  z =  0.8   }, rot = { x =   0.0,  y =    0.0, z =  180.0 }, model = "jpx_light_fury_float"    },
        }},
    },
    ["soluco"] = {
        type = "collection", name = "Soluço", category = "Como Treinar o Seu Dragão", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/COMO%20TREINAR%20O%20SEU%20DRAG%C3%83O/soluco.webp",
        prop = { model = "dreamsstore_soluco", loop = true, moving = true, bone = 6286, pos = { x = -0.161514, y = -0.063829, z = -0.125912 }, rot = { x = -71.862454, y = 55.503543, z = 11.02586 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },
    ["tempestade"] = {
        type = "collection", name = "Tempestade", category = "Como Treinar o Seu Dragão", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/COMO%20TREINAR%20O%20SEU%20DRAG%C3%83O/tempestade.webp",
        prop = { model = "dreamsstore_tempestade", loop = true, moving = true, bone = 6286, pos = { x = -0.161514, y = -0.063829, z = -0.125912 }, rot = { x = -71.862454, y = 55.503543, z = 11.02586 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },
    ["toothless"] = {
        type = "collection", name = "Toothless", category = "Como Treinar o Seu Dragão", price = 240,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/COMO%20TREINAR%20SEU%20DRAG%C3%83O/BANGUELA.webp",
        prop = { model = "jpx_toothless_head", loop = true, moving = true, positions = {
            { id = "na_mao",    label = "Na Mão",     bone = 12844, pos = { x =  0.29, y =  0.08, z =  0.0  }, rot = { x =   0.0, y = -270.0, z =  180.0 }, model = "jpx_toothless_head"     },
            { id = "no_ombro",  label = "No Ombro",   bone = 10706, pos = { x =  0.11, y =  0.01, z =  0.21 }, rot = { x =   0.0, y =   15.0, z =  170.0 }, model = "jpx_toothless_shoulder" },
            { id = "segurando", label = "Segurando",  bone = 40269, pos = { x =  0.4,  y =  0.06, z =  0.1  }, rot = { x =   0.0, y =  -70.0, z =  200.0 }, model = "jpx_toothless_hold"     },
            { id = "no_chao",   label = "No Chão",    bone = 20190, pos = { x =  0.45, y = -0.2,  z = -1.0  }, rot = { x =   0.0, y =    0.0, z =  180.0 }, model = "jpx_toothless_ground"   },
            { id = "flutuando", label = "Flutuando",  bone = 20190, pos = { x =  0.5,  y =  0.0,  z =  0.8  }, rot = { x =   0.0, y =    0.0, z =  180.0 }, model = "jpx_toothless_float"    },
        }},
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- DEMON SLAYER
    -- ════════════════════════════════════════════════════════════════════════
    ["inosuke"] = {
        type = "collection", name = "Inosuke", category = "Demon Slayer", buyable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DEMON%20SLAYER/inosuke.webp",
        prop = { model = "inosukeanim_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo", label = "Ombro esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.18 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_direito", label = "Ombro direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.18 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.32, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["inosukee"] = {
        type = "collection", name = "Inosuke", category = "Demon Slayer", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DEMON%20SLAYER/inosukee.webp",
        prop = { model = "inosukedemonslayer_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 0.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["mitsuri"] = {
        type = "collection", name = "Mitsuri", category = "Demon Slayer", buyable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DEMON%20SLAYER/mitsuri.webp",
        prop = { model = "mitsurianim_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo", label = "Ombro esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.18 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_direito", label = "Ombro direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.18 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["muzan"] = {
        type = "collection", name = "Muzan", category = "Demon Slayer", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DEMON%20SLAYER/muzan.webp",
        prop = { model = "muzandemonslayer_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 0.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["nezuko"] = {
        type = "collection", name = "Nezuko", category = "Demon Slayer", buyable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DEMON%20SLAYER/nezuko.webp",
        prop = { model = "nezukoanim_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo", label = "Ombro esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.18 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_direito", label = "Ombro direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.18 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["nezukoo"] = {
        type = "collection", name = "Nezuko", category = "Demon Slayer", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DEMON%20SLAYER/nezukoo.webp",
        prop = { model = "nezukodemonslayer_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 0.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["obanai"] = {
        type = "collection", name = "Obanai", category = "Demon Slayer", buyable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DEMON%20SLAYER/obanai.webp",
        prop = { model = "obanaianim_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo", label = "Ombro esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.18 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_direito", label = "Ombro direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.18 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["shinobu"] = {
        type = "collection", name = "Shinobu", category = "Demon Slayer", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DEMON%20SLAYER/shinobu.webp",
        prop = { model = "shinobudemonslayer_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 0.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["tanjiro"] = {
        type = "collection", name = "Tanjiro", category = "Demon Slayer", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DEMON%20SLAYER/tanjiro.webp",
        prop = { model = "tanjirodemonslayer_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 0.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["zenitsu"] = {
        type = "collection", name = "Zenitsu", category = "Demon Slayer", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DEMON%20SLAYER/zenitsu.webp",
        prop = { model = "zenitsudemonslayer_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 0.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- DIABINHOS VANILLA
    -- ════════════════════════════════════════════════════════════════════════
    ["devil1"] = {
        type = "collection", name = "Diabinho 1", category = "Diabinhos Vanilla", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DIABINHOS%20VANILLA/devil1.webp",
        prop = { model = "emotedevil_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 90.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["devil2"] = {
        type = "collection", name = "Diabinho 2", category = "Diabinhos Vanilla", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DIABINHOS%20VANILLA/devil2.webp",
        prop = { model = "emotedevil2_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 90.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["devil3"] = {
        type = "collection", name = "Diabinho 3", category = "Diabinhos Vanilla", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DIABINHOS%20VANILLA/devil3.webp",
        prop = { model = "emotedevil3_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 90.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["devil4"] = {
        type = "collection", name = "Diabinho 4", category = "Diabinhos Vanilla", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DIABINHOS%20VANILLA/devil4.webp",
        prop = { model = "emotedevil4_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 90.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["devil5"] = {
        type = "collection", name = "Diabinho 5", category = "Diabinhos Vanilla", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DIABINHOS%20VANILLA/devil5.webp",
        prop = { model = "emotedevil5_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 90.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- DIVERTIDAMENTE
    -- ════════════════════════════════════════════════════════════════════════
    ["anger"] = {
        type = "collection", name = "Anger", category = "Divertidamente", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DIVERTIDAMENTE/anger.webp",
        prop = { model = "angerinsideout_by_joao", loop = true, moving = true, bone = 28422, pos = { x = -0.004, y = 0.093, z = -0.12 }, rot = { x = -100.0, y = 34.23, z = 14.0 }, anim = { dict = "peluciaanim@joao", name = "esquerda_clip", flag = 49 } },
    },
    ["disgust"] = {
        type = "collection", name = "Disgust", category = "Divertidamente", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DIVERTIDAMENTE/disgust.webp",
        prop = { model = "disgustinsideout_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.0, y = 0.0957, z = 0.065 }, rot = { x = 104.704, y = -14.742, z = -147.15 }, anim = { dict = "peluciaanim@joao", name = "direita_clip", flag = 49 } },
    },
    ["fear"] = {
        type = "collection", name = "Fear", category = "Divertidamente", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DIVERTIDAMENTE/fear.webp",
        prop = { model = "fearinsideout_by_joao", loop = true, moving = true, bone = 28422, pos = { x = 0.0, y = 0.098, z = -0.023 }, rot = { x = -88.44, y = 36.14, z = 26.78 }, anim = { dict = "peluciaanim@joao", name = "esquerda_clip", flag = 49 } },
    },
    ["joy"] = {
        type = "collection", name = "Joy", category = "Divertidamente", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DIVERTIDAMENTE/joy.webp",
        prop = { model = "joyinsideout_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.084, y = 0.436, z = -0.0198 }, rot = { x = 0.1149, y = 88.0, z = 180.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["sadness"] = {
        type = "collection", name = "Sadness", category = "Divertidamente", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DIVERTIDAMENTE/sadness.webp",
        prop = { model = "sadnessinsideout_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.0, y = 0.0957, z = 0.065 }, rot = { x = 104.704, y = -14.742, z = -147.15 }, anim = { dict = "peluciaanim@joao", name = "direita_clip", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- DRAGÕES
    -- ════════════════════════════════════════════════════════════════════════
    ["baby2"] = {
        type = "collection", name = "Baby Dragon Azul", category = "Dragões", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DRAG%C3%95ES/baby2.webp",
        prop = { model = "babydragon2_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo", label = "Ombro Esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.06 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_direito", label = "Ombro Direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.06 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.18, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["baby5"] = {
        type = "collection", name = "Baby Dragon Laranja", category = "Dragões", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DRAG%C3%95ES/baby5.webp",
        prop = { model = "babydragon5_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo", label = "Ombro Esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.06 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_direito", label = "Ombro Direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.06 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.18, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["baby6"] = {
        type = "collection", name = "Baby Dragon Preto", category = "Dragões", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DRAG%C3%95ES/baby6.webp",
        prop = { model = "babydragon6_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo", label = "Ombro Esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.06 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_direito", label = "Ombro Direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.06 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.18, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["baby3"] = {
        type = "collection", name = "Baby Dragon Rosa", category = "Dragões", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DRAG%C3%95ES/baby3.webp",
        prop = { model = "babydragon3_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo", label = "Ombro Esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.06 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_direito", label = "Ombro Direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.06 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.18, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["baby"] = {
        type = "collection", name = "Baby Dragon Roxo", category = "Dragões", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DRAG%C3%95ES/baby.webp",
        prop = { model = "babydragon_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo", label = "Ombro Esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.06 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_direito", label = "Ombro Direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.06 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.18, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["baby4"] = {
        type = "collection", name = "Baby Dragon Verde", category = "Dragões", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DRAG%C3%95ES/baby4.webp",
        prop = { model = "babydragon4_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo", label = "Ombro Esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.06 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_direito", label = "Ombro Direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.06 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.18, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- DRAGON BALL
    -- ════════════════════════════════════════════════════════════════════════
    ["bills"] = {
        type = "collection", name = "Bills", category = "Dragon Ball", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DRAGON%20BALL/bills.webp",
        prop = { model = "dreamsstore_bills", loop = true, moving = true, bone = 24817, pos = { x = 0.0, y = 0.443293, z = -0.014057 }, rot = { x = 178.295907, y = 2.578304, z = 85.080973 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["bulma"] = {
        type = "collection", name = "Bulma", category = "Dragon Ball", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DRAGON%20BALL/bulma.webp",
        prop = { model = "dreamsstore_bulma", loop = true, moving = true, bone = 24817, pos = { x = 0.0, y = 0.453719, z = -0.015552 }, rot = { x = 109.563334, y = -14.971246, z = 106.569378 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["goku"] = {
        type = "collection", name = "Goku", category = "Dragon Ball", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DRAGON%20BALL/goku.webp",
        prop = { model = "dreamsstore_goku", loop = true, moving = true, bone = 24817, pos = { x = 0.0, y = 0.453719, z = -0.015552 }, rot = { x = 109.563334, y = -14.971246, z = 106.569378 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["piccolo"] = {
        type = "collection", name = "Piccolo", category = "Dragon Ball", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DRAGON%20BALL/piccolo.webp",
        prop = { model = "dreamsstore_piccolo", loop = true, moving = true, bone = 24817, pos = { x = 0.0, y = 0.426807, z = 0.0 }, rot = { x = -173.201821, y = -4.613038, z = 94.003216 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["vegeta"] = {
        type = "collection", name = "Vegeta", category = "Dragon Ball", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/DRAGON%20BALL/vegeta.webp",
        prop = { model = "dreamsstore_vegeta", loop = true, moving = true, bone = 24817, pos = { x = 0.058752, y = 0.434696, z = -0.029431 }, rot = { x = -178.591352, y = -0.594785, z = 99.128805 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- ESCOLINHA
    -- ════════════════════════════════════════════════════════════════════════
    ["alphabeta"] = {
        type = "collection", name = "Alphabet School A", category = "Escolinha", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/ESCOLINHA/alphabeta.webp",
        prop = { model = "alphabetschool_a_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0736, y = 0.43, z = -0.03 }, rot = { x = 90.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["alphabete"] = {
        type = "collection", name = "Alphabet School E", category = "Escolinha", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/ESCOLINHA/alphabete.webp",
        prop = { model = "alphabetschool_e_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0736, y = 0.43, z = -0.03 }, rot = { x = 90.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["alphabeti"] = {
        type = "collection", name = "Alphabet School I", category = "Escolinha", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/ESCOLINHA/alphabeti.webp",
        prop = { model = "alphabetschool_i_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0736, y = 0.43, z = -0.03 }, rot = { x = 90.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["alphabeto"] = {
        type = "collection", name = "Alphabet School O", category = "Escolinha", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/ESCOLINHA/alphabeto.webp",
        prop = { model = "alphabetschool_o_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0736, y = 0.43, z = -0.03 }, rot = { x = 90.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["alphabetu"] = {
        type = "collection", name = "Alphabet School U", category = "Escolinha", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/ESCOLINHA/alphabetu.webp",
        prop = { model = "alphabetschool_u_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0736, y = 0.43, z = -0.03 }, rot = { x = 90.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- EVENTOS
    -- ════════════════════════════════════════════════════════════════════════
    ["aleluiadolphin"] = {
        type = "collection", name = "Aleluia Dolphin", category = "Eventos", price = 240, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/aleluiadolphin.webp",
        prop = { model = "aleluiadolphin_by_joao", loop = true, moving = true, animOnPed = true, positions = {
            { id = "ombro_esquerdo", label = "Ombro Esquerdo", bone = 10706, pos = { x = 0.09, y = 0.019, z = 0.213 }, rot = { x = 0.0, y = 0.0, z = -73.62 } },
            { id = "ombro_direito", label = "Ombro Direito", bone = 64729, pos = { x = 0.126, y = 0.0, z = -0.21 }, rot = { x = 165.43, y = 8.063, z = -70.61 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.303, y = 0.0, z = 0.0027 }, rot = { x = 0.0, y = 90.0, z = -80.0 } },
            { id = "mao_esquerda", label = "Mão Esquerda", bone = 18905, pos = { x = 0.151, y = 0.04, z = 0.033 }, rot = { x = -109.62, y = 9.85, z = 13.46 } },
        }},
    },
    ["baleia"] = {
        type = "collection", name = "Baleia", category = "Eventos", price = 240, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/baleia.webp",
        prop = { model = "baleiaeventoinfantsoul_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo", label = "Ombro esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_direito", label = "Ombro direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.15 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.23, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["sombrinha"] = {
        type = "collection", name = "Carnasoul 2026", category = "Eventos", price = 240, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/sombrinha.webp",
        prop = { model = "sombrinhadecarnaval_by_joao", loop = true, moving = true, animOnPed = true, positions = {
            { id = "pos1", label = "Posição 1", bone = 28422, pos = { x = 0.08, y = 0.0386, z = -0.025 }, rot = { x = 90.74, y = 3.81, z = 143.41 }, anim = { dict = "umbrellaanims@joao", name = "umbrella_clip", flag = 49 } },
            { id = "pos2", label = "Posição 2", bone = 60309, pos = { x = 0.063, y = 0.051, z = 0.0 }, rot = { x = -105.62, y = 57.185, z = -30.44 }, anim = { dict = "umbrellaanims@joao", name = "umbrella2_clip", flag = 49 } },
            { id = "pos3", label = "Posição 3", bone = 60309, pos = { x = 0.0811, y = 0.043, z = 0.0062 }, rot = { x = 112.97, y = -35.59, z = 174.42 }, anim = { dict = "umbrellaanims@joao", name = "umbrella3_clip", flag = 49 } },
        }},
    },
    ["cestinha"] = {
        type = "collection", name = "Cestinha", category = "Eventos", price = 240, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/cestinha.webp",
        prop = { model = "cestinhadeovossoul_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 0.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["chicaazza"] = {
        type = "collection", name = "Chica Azza", category = "Eventos", price = 240, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/chicaazza.webp",
        prop = { model = "flykimprop_azza2", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 180.0, y = 275.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["cinturaosoul"] = {
        type = "collection", name = "Cinturão UFSOUL", category = "Eventos", price = 240, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/cinturao.webp",
        prop = { model = "cinturaoufcsoul_by_joao", loop = true, moving = true, bone = 28422, pos = { x = -0.133317, y = -0.091685, z = -0.168323 }, rot = { x = 62.357295, y = -22.851699, z = 24.231387 }, anim = { dict = "paper_1_rcm_alt1-8", name = "player_one_dual-8", flag = 49 } },
    },
    ["coelhocoleira"] = {
        type = "collection", name = "Coelho com Coleira", category = "Eventos", price = 240, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/coelhocoleira.webp",
        prop = { model = "gotica_coelhocoleira", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["diadasmaes"] = {
        type = "collection", name = "Dia Das Mães", category = "Eventos", price = 240, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/diadasmaes.webp",
        prop = { model = "gotica_mamaeexclusivo", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["diadasmaes2"] = {
        type = "collection", name = "Dia Das Mães", category = "Eventos", price = 240, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/dreamsstore_soulmae.webp",
        prop = { model = "dreamsstore_soulmae", loop = true, moving = true, bone = 28422, pos = { x = -0.043184, y = 0.023472, z = -0.047706 }, rot = { x = 0.0, y = 0.0, z = 89.583748 }, anim = { dict = "amb@code_human_wander_drinking_fat@beer@male@base", name = "static", flag = 49 } },
    },
    ["freddyazza"] = {
        type = "collection", name = "Freddy Azza", category = "Eventos", price = 240, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/freddyazza.webp",
        prop = { model = "kimfly_azza", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.5111, z = 0.0 }, rot = { x = 180.0, y = 275.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["stawberrycatevento"] = {
        type = "collection", name = "Gatorango Evento", category = "Eventos", price = 240, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/stawberrycatevento.webp",
        prop = { model = "peluciaeventosoul_by_joao", loop = true, moving = true, bone = 24817, pos = { x = 0.0, y = 0.45, z = -0.01 }, rot = { x = 0.1149, y = 88.0, z = 180.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["gotica_ghostface"] = {
        type = "collection", name = "Ghost", category = "Eventos", price = 240, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/ghostfaceevento.webp",
        prop = { model = "gotica_ghostface", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["globoazza"] = {
        type = "collection", name = "Globo Azza", category = "Eventos", price = 240, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/globoazza.webp",
        prop = { model = "flay_globoneveazza", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["jetazul"] = {
        type = "collection", name = "Jetski Azul", category = "Eventos", price = 240, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/jetazul.webp",
        prop = { model = "dreamsstore_jetski2", loop = true, moving = true, bone = 31086, pos = { x = -0.474917, y = -0.03182, z = -0.039606 }, rot = { x = 4.981428, y = 85.930711, z = 178.692791 }, anim = { dict = "missheistdocksprep1hold_cellphone", name = "static", flag = 49 } },
    },
    ["jetrelampago"] = {
        type = "collection", name = "Jetski Relâmpago", category = "Eventos", price = 240, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/jetrelampago.webp",
        prop = { model = "dreamsstore_jetski", loop = true, moving = true, bone = 31086, pos = { x = -0.474917, y = -0.03182, z = -0.039606 }, rot = { x = 4.981428, y = 85.930711, z = 178.692791 }, anim = { dict = "missheistdocksprep1hold_cellphone", name = "static", flag = 49 } },
    },
    ["labubuevento"] = {
        type = "collection", name = "Labubu Evento", category = "Eventos", price = 240, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/labubuevento.webp",
        prop = { model = "peluciaeventosoul2_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.05, y = 0.13, z = 0.09 }, rot = { x = 100.0, y = -17.48, z = -170.0 }, anim = { dict = "peluciaanim@joao", name = "direita_clip", flag = 49 } },
    },
    ["labubueventoufc"] = {
        type = "collection", name = "Labubu UFSOUL", category = "Eventos", price = 240, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/labubuufc.webp",
        prop = { model = "labubuufcsoul_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.05, y = 0.13, z = 0.09 }, rot = { x = 100.0, y = -17.48, z = -170.0 }, anim = { dict = "peluciaanim@joao", name = "direita_clip", flag = 49 } },
    },
    ["luckyblock_joao"] = {
        type = "collection", name = "Lucky Block", category = "Eventos", price = 240, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/lucky_joao.webp",
        prop = { model = "luckyblock_by_joao", loop = true, moving = true, positions = {
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.4, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["peluciamari"] = {
        type = "collection", name = "Mari Deserto Tour", category = "Eventos", price = 240, tradeable = false,
        prop = { model = "mari_jptr", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["missbearsoul"] = {
        type = "collection", name = "Miss Bear", category = "Eventos", price = 240, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/missbear.webp",
        prop = { model = "misssoulurso_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 180.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["ovodepascoa2"] = {
        type = "collection", name = "Ovo de Páscoa", category = "Eventos", price = 240, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/ovo2.webp",
        prop = { model = "ovodespascoasoul2_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 0.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["ovodepascoa"] = {
        type = "collection", name = "Ovo de Páscoa", category = "Eventos", price = 240, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/ovo.webp",
        prop = { model = "ovodespascoasoul_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 0.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["proerd"] = {
        type = "collection", name = "Proerd", category = "Eventos", price = 240, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/proerd.webp",
        prop = { model = "dreamsstore_proerd", loop = true, moving = true, bone = 28422, pos = { x = -0.03507, y = -0.094819, z = -0.061523 }, rot = { x = 177.639869, y = -65.88736, z = -20.261746 }, anim = { dict = "amb@code_human_wander_eating_donut@female@base", name = "static", flag = 49 } },
    },
    ["golfinho"] = {
        type = "collection", name = "Golfinho Summer 2026", category = "Eventos", price = 240, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/golfinho.webp",
        prop = { model = "babydolphin_by_joao", loop = true, moving = true, bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.2 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
    },
    ["trophysoul"] = {
        type = "collection", name = "Troféu UFSOUL", category = "Eventos", price = 240, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EVENTOS/trophysoul.webp",
        prop = { model = "trophyufcsoul_by_joao", loop = true, moving = true, bone = 57005, pos = { x = 0.229216, y = 0.0, z = -0.082315 }, rot = { x = 5.027411, y = 90.0, z = 9.656495 }, anim = { dict = "ufcsoultrophy@joao", name = "segurandotrofeu_clip", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- EXCLUSIVO
    -- ════════════════════════════════════════════════════════════════════════
    ["dreamsstore_anya"] = {
        type = "collection", name = "Anya", category = "Exclusivo", price = 120,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EXCLUSIVO/dreamsstore_anya.webp",
        prop = { model = "dreamsstore_anya", loop = true, moving = true, bone = 24817, pos = { x = -0.278168, y = 0.258339, z = -0.039517 }, rot = { x = 5.62929, y = 88.745054, z = -174.405456 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["aureolaplanet"] = {
        type = "collection", name = "Auréola Planet", category = "Exclusivo", price = 120,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EXCLUSIVO/aureola.webp",
        prop = { model = "aureolaplanet", loop = true, moving = true, bone = 31086, pos = { x = -0.7, y = 0.0, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "clip@aureolaplanet", name = "aureolaplanet", flag = 49 } },
    },
    ["cutekizeteddy2_by_joao"] = {
        type = "collection", name = "Cute Kizeteddy", category = "Exclusivo", price = 120,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EXCLUSIVO/cuteteddy.webp",
        prop = { model = "cutekizeteddy2_by_joao", loop = true, moving = true, bone = 24818, pos = { x = 0.0, y = -0.32, z = 0.0 }, rot = { x = 180.0, y = 90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["cutekizeteddy_by_joao"] = {
        type = "collection", name = "Cute Kizeteddy Preto", category = "Exclusivo", price = 120,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EXCLUSIVO/cuteteddy2.webp",
        prop = { model = "cutekizeteddy_by_joao", loop = true, moving = true, bone = 24818, pos = { x = 0.0, y = -0.32, z = 0.0 }, rot = { x = 180.0, y = 90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["gekko"] = {
        type = "collection", name = "Gekko", category = "Exclusivo", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EXCLUSIVO/gekko.webp",
        prop = { model = "dreamsstore_gekkoe", loop = true, moving = true, bone = 24817, pos = { x = -0.005, y = 0.46, z = -0.02 }, rot = { x = 0, y = 89.885468, z = 177.149468 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["CasamentoGravata"] = {
        type = "collection", name = "Gravata", category = "Exclusivo", price = 120,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EXCLUSIVO/CasamentoGravata.webp",
        prop = { model = "gotica_gravata", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["dreamsstore_itachi"] = {
        type = "collection", name = "Itachi", category = "Exclusivo", price = 120,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EXCLUSIVO/dreamsstore_itachi.webp",
        prop = { model = "dreamsstore_itachi", loop = true, moving = true, bone = 24817, pos = { x = -0.278168, y = 0.258339, z = -0.039517 }, rot = { x = 5.62929, y = 88.745054, z = -174.405456 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["KittyBanguela"] = {
        type = "collection", name = "Kitty Banguela", category = "Exclusivo", price = 120, tradeable = false,
        prop = { model = "gotica_kittybanguela", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["KittyET"] = {
        type = "collection", name = "Kitty ET", category = "Exclusivo", price = 120, tradeable = false,
        prop = { model = "gotica_kittyet", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["KittyFuria"] = {
        type = "collection", name = "Kitty Furia", category = "Exclusivo", price = 120, tradeable = false,
        prop = { model = "gotica_kittyfuria", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["KittyUnicornio"] = {
        type = "collection", name = "Kitty Unicórnio", category = "Exclusivo", price = 120, tradeable = false,
        prop = { model = "gotica_kittyunicornio", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["CasamentoLeon"] = {
        type = "collection", name = "Leon", category = "Exclusivo", price = 120,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EXCLUSIVO/CasamentoLeon.webp",
        prop = { model = "gotica_leon", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["CasamentoLeonada"] = {
        type = "collection", name = "Leonada", category = "Exclusivo", price = 120,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EXCLUSIVO/CasamentoLeonada.webp",
        prop = { model = "gotica_leonada", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["CasamentoLeonda"] = {
        type = "collection", name = "Leonda", category = "Exclusivo", price = 120,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EXCLUSIVO/CasamentoLeonda.webp",
        prop = { model = "gotica_leonda", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["ling"] = {
        type = "collection", name = "Ling", category = "Exclusivo", price = 120,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EXCLUSIVO/lig.webp",
        prop = { model = "dreamsstore_ling", loop = true, moving = true, bone = 24817, pos = { x = 0.0, y = 0.436509, z = -0.01722 }, rot = { x = 178.511155, y = -87.596526, z = 0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["RainbowPonieAlice"] = {
        type = "collection", name = "Rainbow Ponei Alice", category = "Exclusivo", price = 120, tradeable = false,
        prop = { model = "rainbow_poneialice", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["RainbowPonieAlice2"] = {
        type = "collection", name = "Rainbow Ponei Alice 2", category = "Exclusivo", price = 120, tradeable = false,
        prop = { model = "rainbow_poneialice2", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["RainbowPoneiMel"] = {
        type = "collection", name = "Rainbow Ponei Mel", category = "Exclusivo", price = 120, tradeable = false,
        prop = { model = "rainbow_poneimel", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["supra1"] = {
        type = "collection", name = "Supra 1", category = "Exclusivo", price = 120,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EXCLUSIVO/supra1.webp",
        prop = { model = "dreamsstore_supra1", loop = true, moving = true, bone = 28422, pos = { x = -0.042467, y = -0.203797, z = -0.036497 }, rot = { x = -102.034436, y = 16.652597, z = 169.781705 }, anim = { dict = "amb@code_human_wander_eating_donut@female@base", name = "static", flag = 49 } },
    },
    ["supra2"] = {
        type = "collection", name = "Supra 2", category = "Exclusivo", price = 120,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EXCLUSIVO/supra2.webp",
        prop = { model = "dreamsstore_supra2", loop = true, moving = true, bone = 28422, pos = { x = -0.081501, y = -0.20459, z = -0.010802 }, rot = { x = -99.252001, y = 19.141837, z = 161.283084 }, anim = { dict = "amb@code_human_wander_eating_donut@female@base", name = "static", flag = 49 } },
    },
    ["supra3"] = {
        type = "collection", name = "Supra 3", category = "Exclusivo", price = 120,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EXCLUSIVO/supra3.webp",
        prop = { model = "dreamsstore_supra3", loop = true, moving = true, bone = 28422, pos = { x = -0.037231, y = -0.123243, z = -0.017274 }, rot = { x = -102.540209, y = 11.654826, z = 163.69015 }, anim = { dict = "amb@code_human_wander_eating_donut@female@base", name = "static", flag = 49 } },
    },
    ["CasamentoTesoura"] = {
        type = "collection", name = "Tesoura", category = "Exclusivo", price = 120,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/EXCLUSIVO/CasamentoTesoura.webp",
        prop = { model = "gotica_tesoura", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- FADAS
    -- ════════════════════════════════════════════════════════════════════════
    ["pixie6"] = {
        type = "collection", name = "Pixie Fairy Amarelo", category = "Fadas", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/FADAS/pixel6.webp",
        prop = { model = "pixiefairy6_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_direito", label = "Ombro Direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.15 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "ombro_esquerdo", label = "Ombro Esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.25, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["pixie4"] = {
        type = "collection", name = "Pixie Fairy Laranja", category = "Fadas", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/FADAS/pixel4.webp",
        prop = { model = "pixiefairy4_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_direito", label = "Ombro Direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.15 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "ombro_esquerdo", label = "Ombro Esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.25, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["pixie"] = {
        type = "collection", name = "Pixie Fairy Rosa", category = "Fadas", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/FADAS/pixel.webp",
        prop = { model = "pixiefairy_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_direito", label = "Ombro Direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.15 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "ombro_esquerdo", label = "Ombro Esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.25, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["pixie2"] = {
        type = "collection", name = "Pixie Fairy Roxo", category = "Fadas", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/FADAS/pixel2.webp",
        prop = { model = "pixiefairy2_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_direito", label = "Ombro Direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.15 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "ombro_esquerdo", label = "Ombro Esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.25, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["pixie3"] = {
        type = "collection", name = "Pixie Fairy Roxo Claro", category = "Fadas", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/FADAS/pixel3.webp",
        prop = { model = "pixiefairy3_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_direito", label = "Ombro Direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.15 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "ombro_esquerdo", label = "Ombro Esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.25, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["pixie5"] = {
        type = "collection", name = "Pixie Fairy Verde", category = "Fadas", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/FADAS/pixel5.webp",
        prop = { model = "pixiefairy5_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_direito", label = "Ombro Direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.15 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "ombro_esquerdo", label = "Ombro Esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.25, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- FIVE NIGHTS AT FREDDY'S
    -- ════════════════════════════════════════════════════════════════════════
    ["chica"] = {
        type = "collection", name = "Chica", category = "Five Nights at Freddy's", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/FIVE%20NIGHTS%20AT%20FREDDY'S/chica.webp",
        prop = { model = "chicaanim_by_joao", loop = true, moving = true, bone = 10706, pos = { x = 0.1033, y = 0.01, z = 0.056 }, rot = { x = -180.0, y = -5.14, z = -170.0 } },
    },
    ["freddy"] = {
        type = "collection", name = "Freddy", category = "Five Nights at Freddy's", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/FIVE%20NIGHTS%20AT%20FREDDY'S/freddy.webp",
        prop = { model = "freddyanim_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.11, y = -0.021, z = 0.019 }, rot = { x = 0.0, y = 0.0, z = 170.0 }, anim = { dict = "expondopelucia@joao", name = "expondo_clip", flag = 49 } },
    },
    ["monty"] = {
        type = "collection", name = "Monty", category = "Five Nights at Freddy's", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/FIVE%20NIGHTS%20AT%20FREDDY'S/monty.webp",
        prop = { model = "montyanim_by_joao", loop = true, moving = true, bone = 31086, pos = { x = 0.15, y = 0.03, z = 0.0 }, rot = { x = 180.0, y = 90.0, z = 180.0 } },
    },
    ["roxy"] = {
        type = "collection", name = "Roxy", category = "Five Nights at Freddy's", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/FIVE%20NIGHTS%20AT%20FREDDY'S/roxy.webp",
        prop = { model = "roxyanim_by_joao", loop = true, moving = true, bone = 64729, pos = { x = 0.12, y = 0.0, z = -0.04 }, rot = { x = -180.0, y = 5.14, z = 20.0 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- GATOS
    -- ════════════════════════════════════════════════════════════════════════
    ["britishcat_joao"] = {
        type = "collection", name = "British Cat", category = "Gatos", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/GATOS/britishcat.webp",
        prop = { model = "britishicat_by_joao", loop = true, moving = true, bone = 24818, pos = { x = -0.04, y = 0.163, z = 0.0176 }, rot = { x = 0.0, y = 90.0, z = -180.0 }, anim = { dict = "petcarinhoanimation@joao", name = "carinho_clip", flag = 49 } },
    },
    ["munchkincat_joao"] = {
        type = "collection", name = "Munchkin Cat", category = "Gatos", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/GATOS/munchkincat.webp",
        prop = { model = "munchkincat_by_joao", loop = true, moving = true, bone = 24818, pos = { x = -0.02, y = 0.163, z = 0.0176 }, rot = { x = 0.0, y = 90.0, z = -180.0 }, anim = { dict = "petcarinhoanimation@joao", name = "carinho_clip", flag = 49 } },
    },
    ["siamescat_joao"] = {
        type = "collection", name = "Siamês Cat", category = "Gatos", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/GATOS/siamescat.webp",
        prop = { model = "siamescat_by_joao", loop = true, moving = true, bone = 24818, pos = { x = -0.04, y = 0.163, z = 0.0176 }, rot = { x = 0.0, y = 90.0, z = -180.0 }, anim = { dict = "petcarinhoanimation@joao", name = "carinho_clip", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- HARRY POTTER
    -- ════════════════════════════════════════════════════════════════════════
    ["Dobby"] = {
        type = "collection", name = "Dobby", category = "Harry Potter", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HARRY%20POTTER/dobby.webp",
        prop = { model = "gotica_dobby", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["Draco"] = {
        type = "collection", name = "Draco", category = "Harry Potter", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HARRY%20POTTER/draco.webp",
        prop = { model = "gotica_draco", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["Harry_potter"] = {
        type = "collection", name = "Harry Potter", category = "Harry Potter", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HARRY%20POTTER/harry_potter.webp",
        prop = { model = "gotica_harry", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["Hermione"] = {
        type = "collection", name = "Hermione", category = "Harry Potter", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HARRY%20POTTER/hermione.webp",
        prop = { model = "gotica_hermione", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["Luna"] = {
        type = "collection", name = "Luna", category = "Harry Potter", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HARRY%20POTTER/luna.webp",
        prop = { model = "gotica_luna", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["Voldemorte"] = {
        type = "collection", name = "Voldemorte", category = "Harry Potter", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HARRY%20POTTER/voldemorte.webp",
        prop = { model = "gotica_voldemorte", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- HAZBIN HOTEL
    -- ════════════════════════════════════════════════════════════════════════
    ["vks_angel"] = {
        type = "collection", name = "Angel", category = "Hazbin Hotel", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HAZBIN%20HOTEL/Angel.webp",
        prop = { model = "Vks_Angel", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["vks_charlie"] = {
        type = "collection", name = "Charlie", category = "Hazbin Hotel", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HAZBIN%20HOTEL/Charlie.webp",
        prop = { model = "Vks_Charlie", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["vks_husk"] = {
        type = "collection", name = "Husk", category = "Hazbin Hotel", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HAZBIN%20HOTEL/Husk.webp",
        prop = { model = "Vks_Husk", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["vks_lulu"] = {
        type = "collection", name = "Lulu", category = "Hazbin Hotel", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HAZBIN%20HOTEL/Lulu.webp",
        prop = { model = "Vks_Lulu", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["vks_nifty"] = {
        type = "collection", name = "Nifty", category = "Hazbin Hotel", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HAZBIN%20HOTEL/Nifty.webp",
        prop = { model = "Vks_Nifty", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- HELLO KITTY
    -- ════════════════════════════════════════════════════════════════════════
    ["Soul_cap3"] = {
        type = "collection", name = "Capteste", category = "Hello Kitty", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HELLO%20KITTY/kuromi.webp",
        prop = { model = "Soul_cap3", loop = true, moving = true, bone = 60309, pos = { x = 0.03, y = 0.02, z = 0.12 }, rot = { x = -108.290001, y = -251.740005, z = -369.850006 }, anim = { dict = "hold_flowers@dad", name = "hold_flowers_clip", flag = 49 } },
    },
    ["LV_cinnaxmelody"] = {
        type = "collection", name = "Cinnax Melody", category = "Hello Kitty", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HELLO%20KITTY/cinnaxmelody.webp",
        prop = { model = "LV_cinnaxmelodycatcafe", loop = true, moving = true, bone = 24817, pos = { x = -0.21, y = 0.52, z = 0.0 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["hellokittyabobora"] = {
        type = "collection", name = "Hello Kitty Abóbora", category = "Hello Kitty", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HELLO%20KITTY/habobora.webp",
        prop = { model = "rbs_hellokitty_abobora", loop = true, moving = true, bone = 24817, pos = { x = -0.05, y = 0.45, z = -0.02 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["hellokittyaranha"] = {
        type = "collection", name = "Hello Kitty Aranha", category = "Hello Kitty", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HELLO%20KITTY/haranha.webp",
        prop = { model = "rbs_hellokitty_aranha", loop = true, moving = true, bone = 24817, pos = { x = -0.05, y = 0.45, z = -0.02 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["hellokittycoracao"] = {
        type = "collection", name = "Hello Kitty Coração", category = "Hello Kitty", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HELLO%20KITTY/hcoracao.webp",
        prop = { model = "rbs_hellokitty_coracao", loop = true, moving = true, bone = 24817, pos = { x = -0.05, y = 0.45, z = -0.02 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["hellokittydino"] = {
        type = "collection", name = "Hello Kitty Dino", category = "Hello Kitty", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HELLO%20KITTY/hdino.webp",
        prop = { model = "rbs_hellokitty_dino", loop = true, moving = true, bone = 24817, pos = { x = -0.05, y = 0.45, z = -0.02 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["hellokittysapo"] = {
        type = "collection", name = "Hello Kitty Sapo", category = "Hello Kitty", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HELLO%20KITTY/hsapo.webp",
        prop = { model = "rbs_hellokitty_sapo", loop = true, moving = true, bone = 24817, pos = { x = -0.05, y = 0.45, z = -0.02 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["hellokittystitch"] = {
        type = "collection", name = "Hello Kitty Stitch", category = "Hello Kitty", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HELLO%20KITTY/hstitch.webp",
        prop = { model = "rbs_hellokitty_stitch", loop = true, moving = true, bone = 24817, pos = { x = -0.05, y = 0.45, z = -0.02 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["hellokittyurso"] = {
        type = "collection", name = "Hello Kitty Urso", category = "Hello Kitty", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HELLO%20KITTY/hurso.webp",
        prop = { model = "rbs_hellokitty_ursomal", loop = true, moving = true, bone = 24817, pos = { x = -0.05, y = 0.45, z = -0.02 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["hellokittyvampiro"] = {
        type = "collection", name = "Hello Kitty Vampiro", category = "Hello Kitty", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HELLO%20KITTY/hvampiro.webp",
        prop = { model = "rbs_hellokitty_vampiro", loop = true, moving = true, bone = 24817, pos = { x = -0.05, y = 0.45, z = -0.02 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["LV_kuromi"] = {
        type = "collection", name = "Kuromi", category = "Hello Kitty", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HELLO%20KITTY/kuromi.webp",
        prop = { model = "LV_kuromicatcafe", loop = true, moving = true, bone = 24817, pos = { x = -0.21, y = 0.52, z = 0.0 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["LV_mymelody"] = {
        type = "collection", name = "My Melody", category = "Hello Kitty", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HELLO%20KITTY/mymelody.webp",
        prop = { model = "LV_mymelodycatcafe", loop = true, moving = true, bone = 24817, pos = { x = -0.21, y = 0.52, z = 0.0 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["LV_pochaacco"] = {
        type = "collection", name = "Pochacco", category = "Hello Kitty", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HELLO%20KITTY/pochaacco.webp",
        prop = { model = "LV_pochaaccocatcafe", loop = true, moving = true, bone = 24817, pos = { x = -0.21, y = 0.52, z = 0.0 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["LV_pompompurin"] = {
        type = "collection", name = "Pompompurin", category = "Hello Kitty", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HELLO%20KITTY/pompompurin.webp",
        prop = { model = "LV_pompompurincatcafe", loop = true, moving = true, bone = 24817, pos = { x = -0.21, y = 0.52, z = 0.0 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- HORA DE AVENTURA
    -- ════════════════════════════════════════════════════════════════════════
    ["bmo"] = {
        type = "collection", name = "BMO", category = "Hora de Aventura", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HORA%20DE%20AVENTURA/bmo.webp",
        prop = { model = "dreamsstore_bmo", loop = true, moving = true, bone = 12844, pos = { x = -0.639837, y = 0.0, z = -0.012967 }, rot = { x = 1.921525, y = 88.329479, z = 169.001673 } },
    },
    ["caroco"] = {
        type = "collection", name = "Caroço", category = "Hora de Aventura", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HORA%20DE%20AVENTURA/caroco.webp",
        prop = { model = "dreamsstore_caroco", loop = true, moving = true, bone = 28422, pos = { x = -0.0156, y = 0.092706, z = -0.330203 }, rot = { x = -66.330173, y = -7.343119, z = -5.891195 }, anim = { dict = "random@shop_gunstore", name = "_idle", flag = 49 } },
    },
    ["finn"] = {
        type = "collection", name = "Finn", category = "Hora de Aventura", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HORA%20DE%20AVENTURA/finn.webp",
        prop = { model = "dreamsstore_finn", loop = true, moving = true, bone = 28422, pos = { x = 0.001387, y = 0.002141, z = -0.247352 }, rot = { x = -84.983122, y = -20.958448, z = -8.152033 }, anim = { dict = "random@shop_gunstore", name = "_idle", flag = 49 } },
    },
    ["jake"] = {
        type = "collection", name = "Jake", category = "Hora de Aventura", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HORA%20DE%20AVENTURA/jake.webp",
        prop = { model = "dreamsstore_jake", loop = true, moving = true, bone = 28422, pos = { x = -0.065763, y = 0.229937, z = -0.031694 }, rot = { x = 161.010737, y = 67.563804, z = 174.284998 }, anim = { dict = "random@shop_gunstore", name = "_idle", flag = 49 } },
    },
    ["jujuba"] = {
        type = "collection", name = "Jujuba", category = "Hora de Aventura", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HORA%20DE%20AVENTURA/jujuba.webp",
        prop = { model = "dreamsstore_jujuba", loop = true, moving = true, bone = 28422, pos = { x = 0.031152, y = -0.29177, z = -0.127254 }, rot = { x = 2.844984, y = -6.875361, z = 164.850409 }, anim = { dict = "amb@code_human_wander_drinking@male@base", name = "static", flag = 49 } },
    },
    ["marceline"] = {
        type = "collection", name = "Marceline", category = "Hora de Aventura", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HORA%20DE%20AVENTURA/marceline.webp",
        prop = { model = "dreamsstore_marceline", loop = true, moving = true, bone = 6286, pos = { x = -0.161514, y = -0.063829, z = -0.125912 }, rot = { x = -71.862454, y = 55.503543, z = 11.02586 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- HORROR
    -- ════════════════════════════════════════════════════════════════════════
    ["dreamsstore_chucky"] = {
        type = "collection", name = "Chucky", category = "Horror", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HORROR/chucky.webp",
        prop = { model = "dramsstore_chucky", loop = true, moving = true, bone = 24817, pos = { x = -1.150421, y = -0.106788, z = 0.049361 }, rot = { x = -167.899255, y = -88.464433, z = 5.789191 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["dreamsstore_it"] = {
        type = "collection", name = "IT", category = "Horror", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HORROR/it.webp",
        prop = { model = "dreams_it", loop = true, moving = true, bone = 24817, pos = { x = -1.150421, y = -0.106788, z = 0.049361 }, rot = { x = -167.899255, y = -88.464433, z = 5.789191 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["dreamsstore_jason"] = {
        type = "collection", name = "Jason", category = "Horror", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HORROR/jason.webp",
        prop = { model = "dreamsstore_jason", loop = true, moving = true, bone = 24817, pos = { x = 0.03434, y = 0.457896, z = -0.017332 }, rot = { x = 179.380351, y = 1.922407, z = 88.979321 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["dreamsstore_pikachu2"] = {
        type = "collection", name = "Pikachu", category = "Horror", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HORROR/pikachu2.webp",
        prop = { model = "dreamsstore_pikachu2", loop = true, moving = true, bone = 24817, pos = { x = -1.150421, y = -0.106788, z = 0.049361 }, rot = { x = -167.899255, y = -88.464433, z = 5.789191 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["dreamsstore_pinhead"] = {
        type = "collection", name = "Pinhead", category = "Horror", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HORROR/pinhead.webp",
        prop = { model = "dreamsstore_pinhead", loop = true, moving = true, bone = 24817, pos = { x = -1.150421, y = -0.106788, z = 0.049361 }, rot = { x = -167.899255, y = -88.464433, z = 5.789191 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["dreamsstore_stitchvampire"] = {
        type = "collection", name = "Stitch Vampiro", category = "Horror", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HORROR/stichvampiro.webp",
        prop = { model = "dreams_stitchvampire", loop = true, moving = true, bone = 24817, pos = { x = -1.150421, y = -0.106788, z = 0.049361 }, rot = { x = -167.899255, y = -88.464433, z = 5.789191 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["dreamsstore_stitchzombie"] = {
        type = "collection", name = "Stitch Zombie", category = "Horror", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HORROR/stichzombie.webp",
        prop = { model = "dreams_zombiestitch", loop = true, moving = true, bone = 24817, pos = { x = -1.150421, y = -0.106788, z = 0.049361 }, rot = { x = -167.899255, y = -88.464433, z = 5.789191 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- HOSPITAL
    -- ════════════════════════════════════════════════════════════════════════
    ["doutorcapivara"] = {
        type = "collection", name = "Doutor Capivara", category = "Hospital", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HOSPITAL/doutorcapivara.webp",
        prop = { model = "doctorcapyvara_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.07, y = 0.111, z = 0.117 }, rot = { x = 103.85, y = -8.53, z = -152.39 }, anim = { dict = "peluciaanim@joao", name = "direita_clip", flag = 49 } },
    },
    ["doutorpinguim"] = {
        type = "collection", name = "Doutor Pinguim", category = "Hospital", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HOSPITAL/doutorpinguim.webp",
        prop = { model = "doctorpinguim_by_joao", loop = true, moving = true, bone = 28422, pos = { x = 0.017, y = 0.063, z = -0.115 }, rot = { x = -90.774, y = 31.53, z = 2.43 }, anim = { dict = "peluciaanim@joao", name = "esquerda_clip", flag = 49 } },
    },
    ["doutorgirafa"] = {
        type = "collection", name = "Doutora Girafa", category = "Hospital", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HOSPITAL/doutorgirafa.webp",
        prop = { model = "doctorgirafa_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 90.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["hospital2"] = {
        type = "collection", name = "Ursinha Rosa", category = "Hospital", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HOSPITAL/hospital2.webp",
        prop = { model = "nurseteddy_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.334, y = -0.114, z = -0.0065 }, rot = { x = -82.14, y = 70.338, z = -38.72 } },
    },
    ["hospital"] = {
        type = "collection", name = "Ursinho", category = "Hospital", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HOSPITAL/hospital3.webp",
        prop = { model = "doctorteddy_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.063, y = 0.0804, z = 0.083 }, rot = { x = 106.33, y = -12.19, z = -146.39 }, anim = { dict = "peluciaanim@joao", name = "direita_clip", flag = 49 } },
    },
    ["hospital3"] = {
        type = "collection", name = "Ursinho Azul", category = "Hospital", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HOSPITAL/hospital.webp",
        prop = { model = "pacientteddy_by_joao", loop = true, moving = true, bone = 28422, pos = { x = -0.026, y = 0.1419, z = -0.04 }, rot = { x = -76.102, y = 34.945, z = 20.963 }, anim = { dict = "peluciaanim@joao", name = "esquerda_clip", flag = 49 } },
    },
    ["zegotinha"] = {
        type = "collection", name = "Zé Gotinha", category = "Hospital", price = 240,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/HOSPITAL/zegotinha.webp",
        prop = { model = "zegotinhasoul_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 90.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- JORNAL
    -- ════════════════════════════════════════════════════════════════════════
    ["clarkkent"] = {
        type = "collection", name = "Clark Kent", category = "Jornal", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/JORNAL/clarkkent.webp",
        prop = { model = "funkoclarkkent_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.11, y = -0.021, z = 0.08 }, rot = { x = 0.0, y = 0.0, z = 170.0 }, anim = { dict = "expondopelucia@joao", name = "expondo_clip", flag = 49 } },
    },
    ["louislane"] = {
        type = "collection", name = "Louis Lane", category = "Jornal", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/JORNAL/louislane.webp",
        prop = { model = "funkolouislane_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.11, y = -0.021, z = 0.08 }, rot = { x = 0.0, y = 0.0, z = 170.0 }, anim = { dict = "expondopelucia@joao", name = "expondo_clip", flag = 49 } },
    },
    ["tvsoul"] = {
        type = "collection", name = "TV", category = "Jornal", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/JORNAL/tvsoul.webp",
        prop = { model = "tvjornalsoul_by_joao", loop = true, moving = true, bone = 28422, pos = { x = 0.0039, y = -0.0581, z = -0.0251 }, rot = { x = 0.0, y = 0.0, z = 0.0 }, anim = { dict = "anim@heists@box_carry@", name = "idle", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- JOVENS TITÃS
    -- ════════════════════════════════════════════════════════════════════════
    ["gotica_ciborgue"] = {
        type = "collection", name = "Ciborgue", category = "Jovens Titãs", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/JOVENS%20TIT%C3%83S/cyborg.webp",
        prop = { model = "gotica_ciborgue", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["gotica_estelar"] = {
        type = "collection", name = "Estelar", category = "Jovens Titãs", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/JOVENS%20TIT%C3%83S/starfire.webp",
        prop = { model = "gotica_estelar", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["gotica_mutano"] = {
        type = "collection", name = "Mutano", category = "Jovens Titãs", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/JOVENS%20TIT%C3%83S/beastboy.webp",
        prop = { model = "gotica_mutano", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["gotica_ravena"] = {
        type = "collection", name = "Ravena", category = "Jovens Titãs", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/JOVENS%20TIT%C3%83S/ravena.webp",
        prop = { model = "gotica_ravena", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["gotica_robin"] = {
        type = "collection", name = "Robin", category = "Jovens Titãs", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/JOVENS%20TIT%C3%83S/robin.webp",
        prop = { model = "gotica_robin", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- JUJUTSU KAISEN
    -- ════════════════════════════════════════════════════════════════════════
    ["megumi"] = {
        type = "collection", name = "Megumi", category = "Jujutsu Kaisen", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/JUJUTSU%20KAISEN/Megumi.webp",
        prop = { model = "dreamsstore_megumi", loop = true, moving = true, bone = 6286, pos = { x = -0.161514, y = -0.063829, z = -0.125912 }, rot = { x = -71.862454, y = 55.503543, z = 11.02586 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },
    ["nobara"] = {
        type = "collection", name = "Nobara", category = "Jujutsu Kaisen", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/JUJUTSU%20KAISEN/Nobara.webp",
        prop = { model = "dreamsstore_nobara", loop = true, moving = true, bone = 6286, pos = { x = -0.176101, y = 0.017832, z = -0.041546 }, rot = { x = -68.164265, y = 64.735061, z = 11.516778 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },
    ["sartoru"] = {
        type = "collection", name = "Sartoru", category = "Jujutsu Kaisen", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/JUJUTSU%20KAISEN/Sartoru.webp",
        prop = { model = "dreamsstore_sartoru", loop = true, moving = true, bone = 6286, pos = { x = -0.161514, y = -0.063829, z = -0.125912 }, rot = { x = -71.862454, y = 55.503543, z = 11.02586 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },
    ["yuji"] = {
        type = "collection", name = "Yuji", category = "Jujutsu Kaisen", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/JUJUTSU%20KAISEN/Yuji.webp",
        prop = { model = "dreamsstore_yuji", loop = true, moving = true, bone = 6286, pos = { x = -0.176101, y = 0.017832, z = -0.041546 }, rot = { x = -68.164265, y = 64.735061, z = 11.516778 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },
    ["yuta"] = {
        type = "collection", name = "Yuta", category = "Jujutsu Kaisen", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/JUJUTSU%20KAISEN/Yuta.webp",
        prop = { model = "dreamsstore_yuta", loop = true, moving = true, bone = 6286, pos = { x = -0.161514, y = -0.063829, z = -0.125912 }, rot = { x = -71.862454, y = 55.503543, z = 11.02586 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- LABUBU
    -- ════════════════════════════════════════════════════════════════════════
    ["labubu_azul_joao"] = {
        type = "collection", name = "Labubu Azul", category = "Labubu", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/LABUBU/labubu_azul_by_joao.webp",
        prop = { model = "labubu_azul_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.05, y = 0.13, z = 0.09 }, rot = { x = 100.0, y = -17.48, z = -170.0 }, anim = { dict = "peluciaanim@joao", name = "direita_clip", flag = 49 } },
    },
    ["labubu_laranja_joao"] = {
        type = "collection", name = "Labubu Laranja", category = "Labubu", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/LABUBU/labubu_laranja_by_joao.webp",
        prop = { model = "labubu_laranja_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.05, y = 0.13, z = 0.09 }, rot = { x = 100.0, y = -17.48, z = -170.0 }, anim = { dict = "peluciaanim@joao", name = "direita_clip", flag = 49 } },
    },
    ["labubu_marrom_joao"] = {
        type = "collection", name = "Labubu Marrom", category = "Labubu", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/LABUBU/labubu_marrom_by_joao.webp",
        prop = { model = "labubu_marrom_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.05, y = 0.13, z = 0.09 }, rot = { x = 100.0, y = -17.48, z = -170.0 }, anim = { dict = "peluciaanim@joao", name = "direita_clip", flag = 49 } },
    },
    ["labubu_preto_joao"] = {
        type = "collection", name = "Labubu Preto", category = "Labubu", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/LABUBU/labubu_preto_by_joao.webp",
        prop = { model = "labubu_preto_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.05, y = 0.13, z = 0.09 }, rot = { x = 100.0, y = -17.48, z = -170.0 }, anim = { dict = "peluciaanim@joao", name = "direita_clip", flag = 49 } },
    },
    ["labubu_rosa_joao"] = {
        type = "collection", name = "Labubu Rosa", category = "Labubu", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/LABUBU/labubu_rosa_by_joao.webp",
        prop = { model = "labubu_rosa_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.05, y = 0.13, z = 0.09 }, rot = { x = 100.0, y = -17.48, z = -170.0 }, anim = { dict = "peluciaanim@joao", name = "direita_clip", flag = 49 } },
    },
    ["LabubuAzul"] = {
        type = "collection", name = "Lafufu Azul", category = "Labubu", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/LABUBU/labubu04.webp",
        prop = { model = "panda_labubu04", loop = true, moving = true, bone = 24817, pos = { x = 0.05, y = 0.42, z = -0.01 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["LabubuCinza"] = {
        type = "collection", name = "Lafufu Cinza", category = "Labubu", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/LABUBU/labubu05.webp",
        prop = { model = "panda_labubu05", loop = true, moving = true, bone = 24817, pos = { x = 0.05, y = 0.42, z = -0.01 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["LabubuLaranja"] = {
        type = "collection", name = "Lafufu Laranja", category = "Labubu", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/LABUBU/labubu03.webp",
        prop = { model = "panda_labubu03", loop = true, moving = true, bone = 24817, pos = { x = 0.05, y = 0.42, z = -0.01 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["LabubuRosa"] = {
        type = "collection", name = "Lafufu Rosa", category = "Labubu", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/LABUBU/labubu02.webp",
        prop = { model = "panda_labubu02", loop = true, moving = true, bone = 24817, pos = { x = 0.05, y = 0.42, z = -0.01 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["LabubuVerde"] = {
        type = "collection", name = "Lafufu Verde", category = "Labubu", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/LABUBU/labubu01.webp",
        prop = { model = "panda_labubu01", loop = true, moving = true, bone = 24817, pos = { x = 0.05, y = 0.42, z = -0.01 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- LOL
    -- ════════════════════════════════════════════════════════════════════════
    ["ezreal"] = {
        type = "collection", name = "Ezreal", category = "Lol", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/LOL/Ezreal.webp",
        prop = { model = "dreamsstore_ezreal", loop = true, moving = true, bone = 24816, pos = { x = 0.526, y = -0.058, z = -0.168 }, rot = { x = 0.0, y = 186.0, z = -253.0 } },
    },
    ["gnar"] = {
        type = "collection", name = "Gnar", category = "Lol", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/LOL/Gnar.webp",
        prop = { model = "dreamsstore_gnar", loop = true, moving = true, bone = 24816, pos = { x = 0.516, y = 0.0, z = -0.166 }, rot = { x = 10.0, y = 113.0, z = 166.0 } },
    },
    ["jinx"] = {
        type = "collection", name = "Jinx", category = "Lol", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/LOL/Jinx.webp",
        prop = { model = "dreamsstore_jinx", loop = true, moving = true, bone = 24816, pos = { x = 0.504, y = 0.0, z = -0.192 }, rot = { x = 0.0, y = 116.0, z = 167.0 } },
    },
    ["katarina"] = {
        type = "collection", name = "Katarina", category = "Lol", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/LOL/Katarina.webp",
        prop = { model = "dreamsstore_katarina", loop = true, moving = true, bone = 24816, pos = { x = 0.544, y = 0.008, z = -0.194 }, rot = { x = 10.0, y = 103.0, z = -167.0 } },
    },
    ["lux"] = {
        type = "collection", name = "Lux", category = "Lol", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/LOL/Lux.webp",
        prop = { model = "dreamsstore_lux", loop = true, moving = true, bone = 24816, pos = { x = 0.536, y = -0.008, z = 0.166 }, rot = { x = -86.0, y = -109.0, z = 96.0 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- LOONEY TUNES
    -- ════════════════════════════════════════════════════════════════════════
    ["frajola"] = {
        type = "collection", name = "Frajola", category = "Looney Tunes", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/LOONEY%20TUNES/frajola.webp",
        prop = { model = "gnd_frajola", loop = true, moving = true, bone = 28422, pos = { x = 0.14, y = 0.13, z = -0.04 }, rot = { x = -84.699997, y = 61.709999, z = 1.21 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["patolino"] = {
        type = "collection", name = "Patolino", category = "Looney Tunes", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/LOONEY%20TUNES/patolino.webp",
        prop = { model = "gnd_patolino", loop = true, moving = true, bone = 28422, pos = { x = 0.13, y = 0.09, z = -0.04 }, rot = { x = -88.330002, y = 62.200001, z = 4.88 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["pernalonga"] = {
        type = "collection", name = "Pernalonga", category = "Looney Tunes", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/LOONEY%20TUNES/pernalonga.webp",
        prop = { model = "gnd_pernalonga", loop = true, moving = true, bone = 28422, pos = { x = 0.14, y = 0.12, z = -0.02 }, rot = { x = -87.68, y = 55.110001, z = 4.83 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["piupiu"] = {
        type = "collection", name = "Piu-Piu", category = "Looney Tunes", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/LOONEY%20TUNES/piupiu.webp",
        prop = { model = "gnd_piupiu", loop = true, moving = true, bone = 28422, pos = { x = 0.11, y = 0.09, z = -0.07 }, rot = { x = -93.169998, y = 60.5, z = 2.42 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["tazmania"] = {
        type = "collection", name = "Taz Mania", category = "Looney Tunes", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/LOONEY%20TUNES/tazmania.webp",
        prop = { model = "gnd_tazmania", loop = true, moving = true, bone = 28422, pos = { x = 0.14, y = 0.07, z = -0.03 }, rot = { x = 87.360001, y = -122.849998, z = 173.809998 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- MARIO
    -- ════════════════════════════════════════════════════════════════════════
    ["bowser_joao"] = {
        type = "collection", name = "Bowser", category = "Mario", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MARIO/bowser_joao.webp",
        prop = { model = "bowseranim_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_dir", label = "Ombro direito", bone = 64729, pos = { x = 0.12, y = 0.01, z = -0.064 }, rot = { x = 0.0, y = 0.0, z = 0.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.2, y = 0.016, z = 0.015 }, rot = { x = 0.0, y = -80.0, z = 0.0 } },
        }},
    },
    ["luigicap_joao"] = {
        type = "collection", name = "Chapéu do Luigi", category = "Mario", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MARIO/luigicap_joao.webp",
        prop = { model = "luigicap_by_joao", loop = true, moving = true, positions = {
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.141, y = 0.0, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["mariocap_joao"] = {
        type = "collection", name = "Chapéu do Mario", category = "Mario", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MARIO/mariocap_joao.webp",
        prop = { model = "mariocap_by_joao", loop = true, moving = true, positions = {
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.141, y = 0.0, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["kingboo_joao"] = {
        type = "collection", name = "King Boo", category = "Mario", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MARIO/kingboo_joao.webp",
        prop = { model = "kingbooanim_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esq", label = "Ombro esquerdo", bone = 10706, pos = { x = 0.15, y = 0.0, z = 0.2 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_dir", label = "Ombro direito", bone = 64729, pos = { x = 0.15, y = 0.0, z = -0.2 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["kirby"] = {
        type = "collection", name = "Kirby", category = "Mario", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MARIO/kirby.webp",
        prop = { model = "dreamsstore_kirby", loop = true, moving = true, bone = 24817, pos = { x = 0.0, y = 0.469774, z = -0.007641 }, rot = { x = 11.949591, y = 82.039265, z = 111.581126 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["luigi2"] = {
        type = "collection", name = "Luigi", category = "Mario", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MARIO/luigi2.webp",
        prop = { model = "dreamsstore_luigi", loop = true, moving = true, bone = 24817, pos = { x = 0.0, y = 0.451295, z = -0.015966 }, rot = { x = 93.475222, y = -3.135495, z = 97.203698 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["luigi_joao"] = {
        type = "collection", name = "Luigi", category = "Mario", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MARIO/luigi_joao.webp",
        prop = { model = "luigianim_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esq", label = "Ombro esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.07 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_dir", label = "Ombro direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.07 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.18, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["mario"] = {
        type = "collection", name = "Mario", category = "Mario", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MARIO/mario.webp",
        prop = { model = "dreamsstore_mario", loop = true, moving = true, bone = 24817, pos = { x = 0.0, y = 0.403569, z = -0.020119 }, rot = { x = 16.052409, y = 75.650412, z = 131.021507 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["mario_joao"] = {
        type = "collection", name = "Mario", category = "Mario", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MARIO/mario_joao.webp",
        prop = { model = "supermarioanim_by_joao", loop = true, moving = true, positions = {
            { id = "parado_ombro_esq", label = "Parado (ombro esquerdo)", bone = 10706, pos = { x = 0.1, y = -0.04, z = 0.06 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "supermarioanimations@joao", name = "marioidle_clip", flag = 49 } },
            { id = "parado_ombro_dir", label = "Parado (ombro direito)", bone = 64729, pos = { x = 0.1, y = -0.04, z = -0.06 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "supermarioanimations@joao", name = "marioidle_clip", flag = 49 } },
            { id = "parado_cabeca", label = "Parado (cabeça)", bone = 31086, pos = { x = 0.18, y = 0.03, z = -0.04 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "supermarioanimations@joao", name = "marioidle_clip", flag = 49 } },
            { id = "pulo_ombro_esq", label = "Pulo (ombro esquerdo)", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.06 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "supermarioanimations@joao", name = "mariojump_clip", flag = 49 } },
            { id = "pulo_ombro_dir", label = "Pulo (ombro direito)", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.06 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "supermarioanimations@joao", name = "mariojump_clip", flag = 49 } },
            { id = "pulo_cabeca", label = "Pulo (cabeça)", bone = 31086, pos = { x = 0.18, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "supermarioanimations@joao", name = "mariojump_clip", flag = 49 } },
            { id = "pulos_ombro_esq", label = "Pulos (ombro esquerdo)", bone = 10706, pos = { x = 0.1, y = 0.04, z = 0.06 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "supermarioanimations@joao", name = "mariojumpsequence_clip", flag = 49 } },
            { id = "pulos_ombro_dir", label = "Pulos (ombro direito)", bone = 64729, pos = { x = 0.1, y = 0.04, z = -0.06 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "supermarioanimations@joao", name = "mariojumpsequence_clip", flag = 49 } },
            { id = "pulos_cabeca", label = "Pulos (cabeça)", bone = 31086, pos = { x = 0.18, y = 0.03, z = 0.04 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "supermarioanimations@joao", name = "mariojumpsequence_clip", flag = 49 } },
        }},
    },
    ["princess"] = {
        type = "collection", name = "Princess", category = "Mario", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MARIO/princess.webp",
        prop = { model = "dreamsstore_princess", loop = true, moving = true, bone = 24817, pos = { x = 0.0, y = 0.414073, z = -0.011116 }, rot = { x = 114.102687, y = -23.5125, z = 98.925018 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["peach_joao"] = {
        type = "collection", name = "Princess Peach", category = "Mario", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MARIO/peach_joao.webp",
        prop = { model = "princesspeachanim_by_joao", loop = true, moving = true, animOnPed = true, positions = {
            { id = "ombro_esq", label = "Ombro esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.06 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_dir", label = "Ombro direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.06 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.18, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
            { id = "expondo", label = "Expondo", bone = 18905, pos = { x = 0.11, y = -0.021, z = 0.019 }, rot = { x = 0.0, y = 0.0, z = 170.0 }, anim = { dict = "expondopelucia@joao", name = "expondo_clip", flag = 49 } },
        }},
    },
    ["yoshi"] = {
        type = "collection", name = "Yoshi", category = "Mario", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MARIO/yoshi.webp",
        prop = { model = "dreamsstore_yoshi", loop = true, moving = true, bone = 24817, pos = { x = 0.0, y = 0.414073, z = -0.011116 }, rot = { x = 114.102687, y = -23.5125, z = 98.925018 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- MECÂNICA SUL
    -- ════════════════════════════════════════════════════════════════════════
    ["cerebro"] = {
        type = "collection", name = "Cérebro", category = "Mecânica Sul", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MEC%C3%82NICA%20SUL/cerebro.webp",
        prop = { model = "dreamsstore_cerebero", loop = true, moving = true, bone = 64729, pos = { x = 0.016173, y = -0.01944, z = 0.744871 }, rot = { x = 179.157147, y = -5.021441, z = 17.84407 }, anim = { dict = "missheistdocksprep1hold_cellphone", name = "static", flag = 49 } },
    },
    ["daphne"] = {
        type = "collection", name = "Daphne", category = "Mecânica Sul", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MEC%C3%82NICA%20SUL/daphne.webp",
        prop = { model = "dreamsstore_daphne", loop = true, moving = true, bone = 24817, pos = { x = -0.299608, y = 0.230694, z = -0.004371 }, rot = { x = -177.148608, y = -88.163437, z = 3.698955 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["fred"] = {
        type = "collection", name = "Fred", category = "Mecânica Sul", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MEC%C3%82NICA%20SUL/fred.webp",
        prop = { model = "dreamsstore_fred", loop = true, moving = true, bone = 24817, pos = { x = -0.299608, y = 0.230694, z = -0.004371 }, rot = { x = -177.148608, y = -88.163437, z = 3.698955 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["jerry"] = {
        type = "collection", name = "Jerry", category = "Mecânica Sul", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MEC%C3%82NICA%20SUL/jerry.webp",
        prop = { model = "dreamsstore_jerry", loop = true, moving = true, bone = 64729, pos = { x = 0.12, y = 0.015139, z = -0.11 }, rot = { x = -169.30209, y = 1.285687, z = 27.527401 } },
    },
    ["pink"] = {
        type = "collection", name = "Pink", category = "Mecânica Sul", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MEC%C3%82NICA%20SUL/pink.webp",
        prop = { model = "dreamsstore_pink", loop = true, moving = true, bone = 12844, pos = { x = -0.639837, y = 0.0, z = -0.012967 }, rot = { x = 1.921525, y = 88.329479, z = 169.001673 }, anim = { dict = "missheistdocksprep1hold_cellphone", name = "static", flag = 49 } },
    },
    ["ratatouille"] = {
        type = "collection", name = "Ratatouille", category = "Mecânica Sul", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MEC%C3%82NICA%20SUL/ratato.webp",
        prop = { model = "dreamsstore_ratato", loop = true, moving = true, bone = 12844, pos = { x = 0.25, y = 0.039232, z = -0.005474 }, rot = { x = 0, y = 89.377481, z = 172.002812 } },
    },
    ["ratocego"] = {
        type = "collection", name = "Rato Cego", category = "Mecânica Sul", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MEC%C3%82NICA%20SUL/ratocego.webp",
        prop = { model = "dreamsstore_ratocego", loop = true, moving = true, bone = 64729, pos = { x = 0.12, y = 0.015139, z = -0.12 }, rot = { x = -169.30209, y = 1.285687, z = 27.527401 } },
    },
    ["salsicha"] = {
        type = "collection", name = "Salsicha", category = "Mecânica Sul", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MEC%C3%82NICA%20SUL/salsicha.webp",
        prop = { model = "dreamsstore_salsicha", loop = true, moving = true, bone = 24817, pos = { x = -0.299608, y = 0.230694, z = -0.004371 }, rot = { x = -177.148608, y = -88.163437, z = 3.698955 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["scooby"] = {
        type = "collection", name = "Scooby", category = "Mecânica Sul", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MEC%C3%82NICA%20SUL/scoobyloo.webp",
        prop = { model = "dreamsstore_scooby", loop = true, moving = true, bone = 24817, pos = { x = -0.323567, y = 0.217136, z = -0.017465 }, rot = { x = -171.121951, y = -85.608771, z = -4.471979 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["velma"] = {
        type = "collection", name = "Velma", category = "Mecânica Sul", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MEC%C3%82NICA%20SUL/velma.webp",
        prop = { model = "dreamsstore_velma", loop = true, moving = true, bone = 24817, pos = { x = -0.299608, y = 0.230694, z = -0.004371 }, rot = { x = -177.148608, y = -88.163437, z = 3.698955 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- MENINAS SUPER PODEROSAS
    -- ════════════════════════════════════════════════════════════════════════
    ["flick_docinho"] = {
        type = "collection", name = "Docinho", category = "Meninas Super Poderosas", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MENINAS%20SUPER%20PODEROSAS/docinho.webp",
        prop = { model = "flick_docinho_prontaentrega", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.45, z = -0.028 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["docinho"] = {
        type = "collection", name = "Docinho", category = "Meninas Super Poderosas", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MENINAS%20SUPER%20PODEROSAS/DOCINHO.webp",
        prop = { model = "jpx_molly_powerpuff_buttercup", loop = true, moving = true,
            bone = 24818, pos = { x = 0.30, y = 0.04, z = -0.30 }, rot = { x = -90.0, y = -90.0, z = 0.0 } },
    },
    ["flick_florzinha"] = {
        type = "collection", name = "Florzinha", category = "Meninas Super Poderosas", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MENINAS%20SUPER%20PODEROSAS/florzinha.webp",
        prop = { model = "flick_florzinha_prontaentrega", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.45, z = -0.028 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["florzinha"] = {
        type = "collection", name = "Florzinha", category = "Meninas Super Poderosas", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MENINAS%20SUPER%20PODEROSAS/FLORZINHA.webp",
        prop = { model = "jpx_molly_powerpuff_blossom", loop = true, moving = true,
            bone = 64729, pos = { x = 0.20, y = 0.10, z = -0.08 }, rot = { x = 90.0, y = 195.0, z = 170.0 } },
    },
    ["him"] = {
        type = "collection", name = "Him", category = "Meninas Super Poderosas", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MENINAS%20SUPER%20PODEROSAS/ele.webp",
        prop = { model = "flick_him_prontaentrega", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.45, z = -0.028 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["flick_lindinha"] = {
        type = "collection", name = "Lindinha", category = "Meninas Super Poderosas", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MENINAS%20SUPER%20PODEROSAS/lindinha.webp",
        prop = { model = "flick_lindinha_prontaentrega", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.45, z = -0.028 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["lindinha"] = {
        type = "collection", name = "Lindinha", category = "Meninas Super Poderosas", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MENINAS%20SUPER%20PODEROSAS/LINDINHA.webp",
        prop = { model = "jpx_molly_powerpuff_bubbles", loop = true, moving = true,
            bone = 12844, pos = { x = 0.15, y = 0.04, z = 0.00 }, rot = { x = -90.0, y = -90.0, z = 0.0 } },
    },
    ["macacolouco"] = {
        type = "collection", name = "Macaco Louco", category = "Meninas Super Poderosas", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MENINAS%20SUPER%20PODEROSAS/macacolouco.webp",
        prop = { model = "flick_macacolouco_prontaentrega", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.45, z = -0.028 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- MINECRAFT
    -- ════════════════════════════════════════════════════════════════════════
    ["alex"] = {
        type = "collection", name = "Alex", category = "Minecraft", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MINECRAFT/Alex.webp",
        prop = { model = "dreamsstore_alex", loop = true, moving = true, bone = 6286, pos = { x = -0.176101, y = 0.017832, z = -0.041546 }, rot = { x = -68.164265, y = 64.735061, z = 11.516778 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },
    ["creeper"] = {
        type = "collection", name = "Creeper", category = "Minecraft", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MINECRAFT/Creeper.webp",
        prop = { model = "dreamsstore_creeper", loop = true, moving = true, bone = 6286, pos = { x = -0.082692, y = -0.059643, z = -0.1072 }, rot = { x = -69.04659, y = 42.536754, z = 4.811835 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },
    ["enderman"] = {
        type = "collection", name = "Enderman", category = "Minecraft", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MINECRAFT/Enderman.webp",
        prop = { model = "dreamsstore_enderman", loop = true, moving = true, bone = 6286, pos = { x = -0.161514, y = -0.063829, z = -0.125912 }, rot = { x = -71.862454, y = 55.503543, z = 11.02586 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },
    ["skeleto"] = {
        type = "collection", name = "Skeleto", category = "Minecraft", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MINECRAFT/Skeleto.webp",
        prop = { model = "dreamsstore_skeleto", loop = true, moving = true, bone = 6286, pos = { x = -0.161514, y = -0.063829, z = -0.125912 }, rot = { x = -71.862454, y = 55.503543, z = 11.02586 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },
    ["steve"] = {
        type = "collection", name = "Steve", category = "Minecraft", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MINECRAFT/Steve.webp",
        prop = { model = "dreamsstore_steve", loop = true, moving = true, bone = 6286, pos = { x = -0.161514, y = -0.063829, z = -0.125912 }, rot = { x = -71.862454, y = 55.503543, z = 11.02586 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- MONSTER HIGH
    -- ════════════════════════════════════════════════════════════════════════
    ["cwolf"] = {
        type = "collection", name = "Clawdeen Wolf", category = "Monster High", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MONSTER%20HIGH/cwolf.webp",
        prop = { model = "wave_cwolf_prop", loop = true, moving = true, bone = 24817, pos = { x = -0.1, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["cleo"] = {
        type = "collection", name = "Cleo", category = "Monster High", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MONSTER%20HIGH/cleo.webp",
        prop = { model = "wave_cleo_prop", loop = true, moving = true, bone = 24817, pos = { x = -0.1, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["drac"] = {
        type = "collection", name = "Draculaura", category = "Monster High", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MONSTER%20HIGH/drac.webp",
        prop = { model = "wave_drac_prop", loop = true, moving = true, bone = 24817, pos = { x = -0.1, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["frankie"] = {
        type = "collection", name = "Frankie Stein", category = "Monster High", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MONSTER%20HIGH/frankie.webp",
        prop = { model = "wave_frankie_prop", loop = true, moving = true, bone = 24817, pos = { x = -0.1, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["lagoona"] = {
        type = "collection", name = "Lagoona Blue", category = "Monster High", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MONSTER%20HIGH/lagoona.webp",
        prop = { model = "wave_lagoona_prop", loop = true, moving = true, bone = 24817, pos = { x = -0.1, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- MONSTROS S.A
    -- ════════════════════════════════════════════════════════════════════════
    ["boo"] = {
        type = "collection", name = "Boo", category = "Monstros S.A", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MONSTROS%20S.A/boo.webp",
        prop = { model = "rbs_msa_boo", loop = true, moving = true, bone = 24817, pos = { x = -0.01, y = 0.45, z = -0.02 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["celiamae"] = {
        type = "collection", name = "Celia Mae", category = "Monstros S.A", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MONSTROS%20S.A/celiamae.webp",
        prop = { model = "rbs_msa_ceiamae", loop = true, moving = true, bone = 24817, pos = { x = -0.01, y = 0.45, z = -0.02 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["mike"] = {
        type = "collection", name = "Mike Wazowski", category = "Monstros S.A", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MONSTROS%20S.A/mikewazowski.webp",
        prop = { model = "rbs_msa_mike", loop = true, moving = true, bone = 24817, pos = { x = -0.01, y = 0.45, z = -0.02 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["randall"] = {
        type = "collection", name = "Randall Boggs", category = "Monstros S.A", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MONSTROS%20S.A/randall.webp",
        prop = { model = "rbs_msa_randall_boggs", loop = true, moving = true, bone = 24817, pos = { x = -0.01, y = 0.45, z = -0.02 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["roz"] = {
        type = "collection", name = "Roz", category = "Monstros S.A", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MONSTROS%20S.A/roz.webp",
        prop = { model = "rbs_msa_roz", loop = true, moving = true, bone = 24817, pos = { x = -0.01, y = 0.45, z = -0.02 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["sulley"] = {
        type = "collection", name = "Sullivan", category = "Monstros S.A", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MONSTROS%20S.A/sullivan.webp",
        prop = { model = "rbs_msa_sulley", loop = true, moving = true, bone = 24817, pos = { x = -0.01, y = 0.45, z = -0.02 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- MY LITTLE PONY
    -- ════════════════════════════════════════════════════════════════════════
    ["applejack"] = {
        type = "collection", name = "Applejack", category = "My Little Pony", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MY%20LITTLE%20PONY/applejack.webp",
        prop = { model = "dreams_applejack", loop = true, moving = true, bone = 24817, pos = { x = -0.1, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["fluttershy"] = {
        type = "collection", name = "Fluttershy", category = "My Little Pony", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MY%20LITTLE%20PONY/fluttershy.webp",
        prop = { model = "dreams_fluttershy", loop = true, moving = true, bone = 24817, pos = { x = -0.1, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["pinkie"] = {
        type = "collection", name = "Pinkie", category = "My Little Pony", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MY%20LITTLE%20PONY/pinkie.webp",
        prop = { model = "dreams_pinkie", loop = true, moving = true, bone = 24817, pos = { x = -0.1, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["rainbowdash"] = {
        type = "collection", name = "Rainbow Dash", category = "My Little Pony", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MY%20LITTLE%20PONY/rainbowdash.webp",
        prop = { model = "dreams_rainbowdash", loop = true, moving = true, bone = 24817, pos = { x = -0.1, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["twilight"] = {
        type = "collection", name = "Twilight", category = "My Little Pony", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/MY%20LITTLE%20PONY/twilight.webp",
        prop = { model = "dreams_twilight", loop = true, moving = true, bone = 24817, pos = { x = -0.1, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- NARUTO
    -- ════════════════════════════════════════════════════════════════════════
    ["kakashi"] = {
        type = "collection", name = "Kakashi", category = "Naruto", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/NARUTO/kakashi.webp",
        prop = { model = "dreamsstore_kakashi", loop = true, moving = true, bone = 12844, pos = { x = -0.64, y = 0.0, z = -0.013 }, rot = { x = 1.92, y = 88.33, z = 169.0 } },
    },
    ["naruto"] = {
        type = "collection", name = "Naruto", category = "Naruto", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/NARUTO/naruto.webp",
        prop = { model = "dreamsstore_naruto", loop = true, moving = true, bone = 12844, pos = { x = -0.64, y = 0.0, z = -0.013 }, rot = { x = 1.92, y = 88.33, z = 169.0 } },
    },
    ["raposa"] = {
        type = "collection", name = "Raposa", category = "Naruto", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/NARUTO/raposa.webp",
        prop = { model = "dreamsstore_raposa", loop = true, moving = true, bone = 12844, pos = { x = -0.64, y = 0.0, z = -0.013 }, rot = { x = 1.92, y = 88.33, z = 169.0 } },
    },
    ["sakura"] = {
        type = "collection", name = "Sakura", category = "Naruto", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/NARUTO/sakura.webp",
        prop = { model = "dreamsstore_sakura", loop = true, moving = true, bone = 12844, pos = { x = -0.64, y = 0.0, z = -0.013 }, rot = { x = 1.92, y = 88.33, z = 169.0 } },
    },
    ["sasuke"] = {
        type = "collection", name = "Sasuke", category = "Naruto", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/NARUTO/sasuke.webp",
        prop = { model = "dreamsstore_sasuke", loop = true, moving = true, bone = 12844, pos = { x = -0.64, y = 0.0, z = -0.013 }, rot = { x = 1.92, y = 88.33, z = 169.0 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- NATAL SOUL 2025
    -- ════════════════════════════════════════════════════════════════════════
    ["snowsoul"] = {
        type = "collection", name = "Globo de Neve", category = "Natal", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/NATAL%20SOUL%202025/vny_snowsoul.webp",
        prop = { model = "vny_snowsoul", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["grinchsoul"] = {
        type = "collection", name = "Grinch Natal", category = "Natal", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/NATAL%20SOUL%202025/vny_grinchsoul.webp",
        prop = { model = "vny_grinchsoul", loop = true, moving = true, bone = 24817, pos = { x = -0.1, y = 0.3, z = 0.0 }, rot = { x = -180.0, y = -90.0, z = 0.0 } },
    },
    ["lightsoul"] = {
        type = "collection", name = "Pisca Pisca", category = "Natal", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/NATAL%20SOUL%202025/vny_lightsoul.webp",
        prop = { model = "vny_lightsoul", loop = true, moving = true, bone = 39317, pos = { x = -1.75, y = 0.0, z = 0.0 }, rot = { x = 2.0, y = 90.0, z = -190.0 } },
    },
    ["noelsoul"] = {
        type = "collection", name = "Noel", category = "Natal", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/NATAL%20SOUL%202025/vny_noelsoul.webp",
        prop = { model = "vny_noelsoul", loop = true, moving = true, bone = 45509, pos = { x = -0.1, y = 0.02, z = 0.01 }, rot = { x = -180.0, y = 80.0, z = 0.0 } },
    },
    ["trenosoul"] = {
        type = "collection", name = "Trenó", category = "Natal", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/NATAL%20SOUL%202025/vny_trenosoul.webp",
        prop = { model = "vny_trenosoul", loop = true, moving = true, bone = 12844, pos = { x = 0.1, y = 0.0, z = 0.0 }, rot = { x = -180.0, y = -90.0, z = 0.0 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- ONE PIECE
    -- ════════════════════════════════════════════════════════════════════════
    ["luffy"] = {
        type = "collection", name = "Luffy", category = "One Piece", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/ONE%20PIECE/Luffy.webp",
        prop = { model = "dreamsstore_luffy", loop = true, moving = true, bone = 6286, pos = { x = -0.176101, y = 0.017832, z = -0.041546 }, rot = { x = -68.164265, y = 64.735061, z = 11.516778 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },
    ["nami"] = {
        type = "collection", name = "Nami", category = "One Piece", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/ONE%20PIECE/Nami.webp",
        prop = { model = "dreamsstore_nami", loop = true, moving = true, bone = 6286, pos = { x = -0.176101, y = 0.017832, z = -0.041546 }, rot = { x = -68.164265, y = 64.735061, z = 11.516778 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },
    ["sanji"] = {
        type = "collection", name = "Sanji", category = "One Piece", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/ONE%20PIECE/Sanji.webp",
        prop = { model = "dreamsstore_sanji", loop = true, moving = true, bone = 6286, pos = { x = -0.161514, y = -0.063829, z = -0.125912 }, rot = { x = -71.862454, y = 55.503543, z = 11.02586 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },
    ["shanks"] = {
        type = "collection", name = "Shanks", category = "One Piece", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/ONE%20PIECE/Shanks.webp",
        prop = { model = "dreamsstore_shanks", loop = true, moving = true, bone = 6286, pos = { x = -0.161514, y = -0.063829, z = -0.125912 }, rot = { x = -71.862454, y = 55.503543, z = 11.02586 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },
    ["zoro"] = {
        type = "collection", name = "Zoro", category = "One Piece", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/ONE%20PIECE/Zoro.webp",
        prop = { model = "dreamsstore_zoro", loop = true, moving = true, bone = 6286, pos = { x = -0.161514, y = -0.063829, z = -0.125912 }, rot = { x = -71.862454, y = 55.503543, z = 11.02586 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- OS CAVALEIROS DO ZODÍACO
    -- ════════════════════════════════════════════════════════════════════════
    ["atena"] = {
        type = "collection", name = "Atena", category = "Os Cavaleiros do Zodíaco", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/OS%20CAVALEIROS%20DO%20ZOD%C3%8DACO/gotica_atena.webp",
        prop = { model = "gotica_atena", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["hyoga"] = {
        type = "collection", name = "Hyoga", category = "Os Cavaleiros do Zodíaco", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/OS%20CAVALEIROS%20DO%20ZOD%C3%8DACO/gotica_hyoga.webp",
        prop = { model = "gotica_hyoga", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["ikki"] = {
        type = "collection", name = "Ikki", category = "Os Cavaleiros do Zodíaco", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/OS%20CAVALEIROS%20DO%20ZOD%C3%8DACO/gotica_ikki.webp",
        prop = { model = "gotica_ikki", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["seiya"] = {
        type = "collection", name = "Pegasus Seiya", category = "Os Cavaleiros do Zodíaco", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/OS%20CAVALEIROS%20DO%20ZOD%C3%8DACO/gotica_seiya.webp",
        prop = { model = "gotica_seiya", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["shiryu"] = {
        type = "collection", name = "Shiryu", category = "Os Cavaleiros do Zodíaco", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/OS%20CAVALEIROS%20DO%20ZOD%C3%8DACO/gotica_shiryu.webp",
        prop = { model = "gotica_shiryu", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["shun"] = {
        type = "collection", name = "Shun", category = "Os Cavaleiros do Zodíaco", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/OS%20CAVALEIROS%20DO%20ZOD%C3%8DACO/gotica_shun.webp",
        prop = { model = "gotica_shun", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- PANDA
    -- ════════════════════════════════════════════════════════════════════════
    ["babypanda_joao"] = {
        type = "collection", name = "Baby Panda", category = "Panda", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PANDA/babypanda_joao.webp",
        prop = { model = "babypanda_by_joao", loop = true, moving = true, positions = {
            { id = "padrao", label = "Padrão", bone = 45509, pos = { x = 0.142, y = 0.0, z = -0.092 }, rot = { x = -180.0, y = 44.97, z = 6.56 } },
        }},
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- PÂNICO
    -- ════════════════════════════════════════════════════════════════════════
    ["ghostface_joao"] = {
        type = "collection", name = "GhostFace", category = "Pânico", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/P%C3%82NICO/ghostface.webp",
        prop = { model = "ghostfaceanim_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esq_parado", label = "Parado (Ombro esquerdo)", bone = 10706, pos = { x = 0.13, y = 0.0, z = 0.22 }, rot = { x = 0.0, y = 0.0, z = 195.0 }, anim = { dict = "terrorfilmsanimprops@joao", name = "ghostfaceidle_clip", flag = 49 } },
            { id = "ombro_dir_parado", label = "Parado (Ombro direito)", bone = 64729, pos = { x = 0.13, y = 0.0, z = -0.22 }, rot = { x = -180.0, y = 0.0, z = 20.0 }, anim = { dict = "terrorfilmsanimprops@joao", name = "ghostfaceidle_clip", flag = 49 } },
            { id = "cabeca_parado", label = "Parado (Cabeça)", bone = 31086, pos = { x = 0.33, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "terrorfilmsanimprops@joao", name = "ghostfaceidle_clip", flag = 49 } },
            { id = "ombro_esq_correndo", label = "Correndo (Ombro esquerdo)", bone = 10706, pos = { x = 0.13, y = 0.0, z = 0.2 }, rot = { x = 0.0, y = 0.0, z = 195.0 }, anim = { dict = "terrorfilmsanimprops@joao", name = "ghostfacerun_clip", flag = 49 } },
            { id = "ombro_dir_correndo", label = "Correndo (Ombro direito)", bone = 64729, pos = { x = 0.13, y = 0.0, z = -0.2 }, rot = { x = -180.0, y = 0.0, z = 20.0 }, anim = { dict = "terrorfilmsanimprops@joao", name = "ghostfacerun_clip", flag = 49 } },
            { id = "cabeca_correndo", label = "Correndo (Cabeça)", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "terrorfilmsanimprops@joao", name = "ghostfacerun_clip", flag = 49 } },
            { id = "espreitando", label = "Espreitando", bone = 0, pos = { x = 0.75, y = -1.23, z = 0.1 }, rot = { x = 0.0, y = 0.0, z = -165.65 }, anim = { dict = "terrorfilmsanimprops@joao", name = "ghostfaceidle2_clip", flag = 49 } },
            { id = "correndo_atras", label = "Correndo Atrás", bone = 0, pos = { x = 0.0, y = -1.39, z = 0.1 }, rot = { x = 0.0, y = 0.0, z = -180.0 }, anim = { dict = "terrorfilmsanimprops@joao", name = "ghostfacerun2_clip", flag = 49 } },
        }},
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- PÁSCOA
    -- ════════════════════════════════════════════════════════════════════════
    ["coelhokesh"] = {
        type = "collection", name = "Bunny Kesh", category = "Páscoa", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/P%C3%81SCOA/cutekesh.webp",
        prop = { model = "cutekeshbabybunny_by_joao", loop = true, moving = true, positions = {
            { id = "parado_ombro_esq", label = "Parado (ombro esquerdo)", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.09 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "cutekeshbabybunny@joao", name = "idle_clip", flag = 49 } },
            { id = "parado_ombro_dir", label = "Parado (ombro direito)", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.09 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "cutekeshbabybunny@joao", name = "idle_clip", flag = 49 } },
            { id = "parado_cabeca", label = "Parado (cabeça)", bone = 31086, pos = { x = 0.2, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "cutekeshbabybunny@joao", name = "idle_clip", flag = 49 } },
            { id = "na_mao", label = "Na mão", bone = 18905, pos = { x = 0.105, y = 0.0036, z = 0.03 }, rot = { x = 10.83, y = 7.12, z = 147.048 }, animOnPed = true, anim = { dict = "segurandocoelhinho@joao", name = "segurandocoelhinho_coelho", flag = 49 } },
            { id = "sentado_ombro_esq", label = "Sentado (ombro esquerdo)", bone = 10706, pos = { x = 0.12, y = 0.0, z = 0.07 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "cutekeshbabybunny@joao", name = "sit_clip", flag = 49 } },
            { id = "sentado_ombro_dir", label = "Sentado (ombro direito)", bone = 64729, pos = { x = 0.12, y = 0.0, z = -0.07 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "cutekeshbabybunny@joao", name = "sit_clip", flag = 49 } },
        }},
    },
    ["lolabunny"] = {
        type = "collection", name = "Lola Bunny", category = "Páscoa", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/P%C3%81SCOA/lola.webp",
        prop = { model = "lolabunny_by_joao", loop = true, moving = true, positions = {
            { id = "parada_ombro_esq", label = "Parada (ombro esquerdo)", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.06 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "parada_ombro_dir", label = "Parada (ombro direito)", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.06 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "parada_cabeca", label = "Parada (cabeça)", bone = 31086, pos = { x = 0.18, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
            { id = "sentada_ombro", label = "Sentada no ombro", bone = 10706, pos = { x = 0.086, y = 0.018, z = 0.08 }, rot = { x = 0.0, y = 0.0, z = -162.799 }, anim = { dict = "looneytunes@joao", name = "sitlolla_clip", flag = 49 } },
        }},
    },
    ["cuterabbitbackpack"] = {
        type = "collection", name = "Mochila Coelhão Rosa", category = "Páscoa", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/P%C3%81SCOA/coelhorosa.webp",
        prop = { model = "cuterabbitbackpack_by_joao", loop = true, moving = true, animOnPed = true, positions = {
            { id = "costas", label = "Nas costas", bone = 24818, pos = { x = 0.0, y = -0.18, z = 0.0 }, rot = { x = 8.058002, y = 90.0, z = 5.12 } },
            { id = "frente", label = "Segurando na frente", bone = 24817, pos = { x = -0.04, y = 0.5, z = 0.0 }, rot = { x = 0.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
        }},
    },
    ["pernalongajoao"] = {
        type = "collection", name = "Pernalonga", category = "Páscoa", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/P%C3%81SCOA/pernalonga2.webp",
        prop = { model = "pernalonga_by_joao", loop = true, moving = true, positions = {
            { id = "parado_ombro_esq", label = "Parado (ombro esquerdo)", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.06 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "parado_ombro_dir", label = "Parado (ombro direito)", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.06 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "parado_cabeca", label = "Parado (cabeça)", bone = 31086, pos = { x = 0.18, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
            { id = "sentado_ombro", label = "Sentado no ombro", bone = 64729, pos = { x = 0.149, y = 0.019, z = -0.0609 }, rot = { x = -174.046, y = 0.0, z = 10.64 }, anim = { dict = "looneytunes@joao", name = "sitpernalonga_clip", flag = 49 } },
        }},
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- PASS
    -- ════════════════════════════════════════════════════════════════════════
    ["blackcat_joao"] = {
        type = "collection", name = "Black Cat", category = "Pass", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PASS/blackcat2.webp",
        prop = { model = "blackcat_by_joao", loop = true, moving = true, bone = 24818, pos = { x = -0.04, y = 0.163, z = 0.0176 }, rot = { x = 0.0, y = 90.0, z = -180.0 }, anim = { dict = "petcarinhoanimation@joao", name = "carinho_clip", flag = 49 } },
    },
    ["skullbear_joao"] = {
        type = "collection", name = "Skull Bear", category = "Pass", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PASS/skullbear_joao.webp",
        prop = { model = "thegraveyardbear_by_joao", loop = true, moving = true, positions = {
            { id = "costas", label = "Nas costas", bone = 24818, pos = { x = 0.0, y = -0.18, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 0.0 } },
            { id = "frente", label = "Segurando na frente", bone = 24817, pos = { x = -0.04, y = 0.5, z = 0.0 }, rot = { x = 0.0, y = 88.69, z = 176.23 }, animOnPed = true, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
        }},
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- PATO
    -- ════════════════════════════════════════════════════════════════════════
    ["pato"] = {
        type = "collection", name = "Pato", category = "Pato", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PATO/pato.webp",
        prop = { model = "patoanim_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo_idle", label = "Idle (Ombro esquerdo)", bone = 10706, pos = { x = 0.15, y = 0.0, z = 0.13 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_direito_idle", label = "Idle (Ombro direito)", bone = 64729, pos = { x = 0.15, y = 0.0, z = -0.13 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca_idle", label = "Idle (Cabeça)", bone = 31086, pos = { x = 0.25, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
            { id = "ombro_esquerdo_dance", label = "Dance (Ombro esquerdo)", bone = 10706, pos = { x = 0.15, y = 0.0, z = 0.13 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "pocoanims@joao", name = "patodance_clip", flag = 49 } },
            { id = "ombro_direito_dance", label = "Dance (Ombro direito)", bone = 64729, pos = { x = 0.15, y = 0.0, z = -0.13 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "pocoanims@joao", name = "patodance_clip", flag = 49 } },
            { id = "cabeca_dance", label = "Dance (Cabeça)", bone = 31086, pos = { x = 0.25, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "pocoanims@joao", name = "patodance_clip", flag = 49 } },
        }},
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- PATOS
    -- ════════════════════════════════════════════════════════════════════════
    ["Soul_patinho"] = {
        type = "collection", name = "Patinho", category = "Patos", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PATOS/soul_patinho.webp",
        prop = { model = "Soul_patinho", loop = true, moving = true, bone = 60309, pos = { x = 0.0, y = 0.03, z = 0.1 }, rot = { x = -112.839996, y = -243.880005, z = -10.01 }, anim = { dict = "hold_flowers@dad", name = "hold_flowers_clip", flag = 49 } },
    },
    ["Soul_patinho_sino"] = {
        type = "collection", name = "Patinho com Sino", category = "Patos", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PATOS/soul_patinho_sino.webp",
        prop = { model = "Soul_patinho_sino", loop = true, moving = true, bone = 60309, pos = { x = 0.0, y = 0.03, z = 0.1 }, rot = { x = -112.839996, y = -243.880005, z = -10.01 }, anim = { dict = "hold_flowers@dad", name = "hold_flowers_clip", flag = 49 } },
    },
    ["Soul_pato_gelo"] = {
        type = "collection", name = "Pato de Gelo", category = "Patos", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PATOS/soul_pato_gelo.webp",
        prop = { model = "Soul_pato_gelo", loop = true, moving = true, bone = 60309, pos = { x = 0.01, y = 0.02, z = 0.14 }, rot = { x = -113.75, y = -248.429993, z = -10.92 }, anim = { dict = "hold_flowers@dad", name = "hold_flowers_clip", flag = 49 } },
    },
    ["Soul_pato_pisca"] = {
        type = "collection", name = "Pato Piscante", category = "Patos", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PATOS/soul_pato_pisca.webp",
        prop = { model = "Soul_pato_pisca", loop = true, moving = true, bone = 60309, pos = { x = 0.01, y = 0.02, z = 0.14 }, rot = { x = -113.75, y = -248.429993, z = -10.92 }, anim = { dict = "hold_flowers@dad", name = "hold_flowers_clip", flag = 49 } },
    },
    ["Soul_pato_rena"] = {
        type = "collection", name = "Pato Rena", category = "Patos", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PATOS/soul_pato_rena.webp",
        prop = { model = "Soul_pato_rena", loop = true, moving = true, bone = 60309, pos = { x = 0.04, y = 0.07, z = 0.11 }, rot = { x = -100.099998, y = -228.410004, z = -16.379999 }, anim = { dict = "hold_flowers@dad", name = "hold_flowers_clip", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- PATRULHA CANININA
    -- ════════════════════════════════════════════════════════════════════════
    ["chase"] = {
        type = "collection", name = "Chase", category = "Patrulha Caninina", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PATRULHA%20CANININA/chase.webp",
        prop = { model = "chasepawpatrol_by_joao", loop = true, moving = true, bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.18 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
    },
    ["marshall"] = {
        type = "collection", name = "Marshall", category = "Patrulha Caninina", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PATRULHA%20CANININA/marshall.webp",
        prop = { model = "marshallpawpatrol_by_joao", loop = true, moving = true, bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.19 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
    },
    ["rocky"] = {
        type = "collection", name = "Rocky", category = "Patrulha Caninina", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PATRULHA%20CANININA/rocky.webp",
        prop = { model = "rockypawpatrol_by_joao", loop = true, moving = true, bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
    },
    ["rubble"] = {
        type = "collection", name = "Rubble", category = "Patrulha Caninina", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PATRULHA%20CANININA/rubble.webp",
        prop = { model = "rubblepawpatrol_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 0.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["skyepc"] = {
        type = "collection", name = "Skye", category = "Patrulha Caninina", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PATRULHA%20CANININA/skyepc.webp",
        prop = { model = "skyepawpatrol_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 0.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- PETS
    -- ════════════════════════════════════════════════════════════════════════
    ["chowchow"] = {
        type = "collection", name = "Chowchow", category = "Pets", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PETS/chowchow.webp",
        prop = { model = "chowchow_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.06, y = 0.019, z = 0.12 }, rot = { x = 108.73, y = 14.53, z = -176.56 }, anim = { dict = "segurandodoguinhoanim@joao", name = "doguinho_clip", flag = 49 } },
    },
    ["husky"] = {
        type = "collection", name = "Husky", category = "Pets", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PETS/husky.webp",
        prop = { model = "husky_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.057, y = 0.019, z = 0.099 }, rot = { x = 108.73, y = 14.53, z = -176.56 }, anim = { dict = "segurandodoguinhoanim@joao", name = "doguinho_clip", flag = 49 } },
    },
    ["pug"] = {
        type = "collection", name = "Pug", category = "Pets", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PETS/pug.webp",
        prop = { model = "pug_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.06, y = 0.019, z = 0.12 }, rot = { x = 108.73, y = 14.53, z = -176.56 }, anim = { dict = "segurandodoguinhoanim@joao", name = "doguinho_clip", flag = 49 } },
    },
    ["sharpei"] = {
        type = "collection", name = "Sharpei", category = "Pets", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PETS/sharpei.webp",
        prop = { model = "sharpei_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.06, y = 0.019, z = 0.12 }, rot = { x = 108.73, y = 14.53, z = -176.56 }, anim = { dict = "segurandodoguinhoanim@joao", name = "doguinho_clip", flag = 49 } },
    },
    ["spitz"] = {
        type = "collection", name = "Spitz", category = "Pets", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PETS/spitz.webp",
        prop = { model = "luludapomerania_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.06, y = 0.019, z = 0.12 }, rot = { x = 108.73, y = 14.53, z = -176.56 }, anim = { dict = "segurandodoguinhoanim@joao", name = "doguinho_clip", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- PHINEAS E FERB
    -- ════════════════════════════════════════════════════════════════════════
    ["candace"] = {
        type = "collection", name = "Candace", category = "Phineas e Ferb", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PHINEAS%20E%20FERB/Candace.webp",
        prop = { model = "dreamsstore_candace", loop = true, moving = true, bone = 28422, pos = { x = -0.169047, y = 0.119143, z = -0.225712 }, rot = { x = -107.2647, y = 39.93511, z = 173.375773 }, anim = { dict = "amb@code_human_wander_eating_donut@female@base", name = "static", flag = 49 } },
    },
    ["doofenshmirtz"] = {
        type = "collection", name = "Doofenshmirtz", category = "Phineas e Ferb", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PHINEAS%20E%20FERB/dufismit.webp",
        prop = { model = "dreamsstore_doofenshmirtz", loop = true, moving = true, bone = 6286, pos = { x = -0.009244, y = 0.10176, z = -0.201295 }, rot = { x = -50.448592, y = 31.772588, z = -19.045339 }, anim = { dict = "impexp_int-6", name = "mp_m_waremech_01_dual-6", flag = 49 } },
    },
    ["ferb"] = {
        type = "collection", name = "Ferb", category = "Phineas e Ferb", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PHINEAS%20E%20FERB/ferb.webp",
        prop = { model = "dreamsstore_ferb", loop = true, moving = true, bone = 12844, pos = { x = -0.639837, y = 0.0, z = -0.012967 }, rot = { x = 1.921525, y = 88.329479, z = 169.001673 } },
    },
    ["perry"] = {
        type = "collection", name = "Perry", category = "Phineas e Ferb", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PHINEAS%20E%20FERB/Perry.webp",
        prop = { model = "dreamsstore_perry", loop = true, moving = true, bone = 64729, pos = { x = 0.016173, y = -0.01944, z = 0.744871 }, rot = { x = 179.157147, y = -5.021441, z = 17.84407 } },
    },
    ["phineas"] = {
        type = "collection", name = "Phineas", category = "Phineas e Ferb", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PHINEAS%20E%20FERB/Phineas.webp",
        prop = { model = "dreamsstore_phineas", loop = true, moving = true, bone = 12844, pos = { x = -0.639837, y = 0.0, z = -0.012967 }, rot = { x = 1.921525, y = 88.329479, z = 169.001673 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- PIGGY'S
    -- ════════════════════════════════════════════════════════════════════════
    ["piggy"] = {
        type = "collection", name = "Piggy Smallz", category = "Piggy's", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PIGGY'S/piggy.webp",
        prop = { model = "piggysmallz_by_joao", loop = true, moving = true, bone = 24818, pos = { x = 0.1, y = -0.2, z = 0.0 }, rot = { x = 180.0, y = 90.0, z = 0.0 } },
    },
    ["piggy2"] = {
        type = "collection", name = "Piggy Smallz Dark Version", category = "Piggy's", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PIGGY'S/piggy2.webp",
        prop = { model = "piggysmallz2_by_joao", loop = true, moving = true, bone = 24818, pos = { x = 0.1, y = -0.2, z = 0.0 }, rot = { x = 180.0, y = 90.0, z = 0.0 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- POCOYO
    -- ════════════════════════════════════════════════════════════════════════
    ["pocoyo"] = {
        type = "collection", name = "Pocoyo", category = "Pocoyo", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/POCOYO/pocoyoanim.webp",
        prop = { model = "pocoanim_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo_idle", label = "Idle (Ombro esquerdo)", bone = 10706, pos = { x = 0.15, y = 0.0, z = 0.13 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_direito_idle", label = "Idle (Ombro direito)", bone = 64729, pos = { x = 0.15, y = 0.0, z = -0.13 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca_idle", label = "Idle (Cabeça)", bone = 31086, pos = { x = 0.25, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
            { id = "ombro_esquerdo_dance", label = "Dance (Ombro esquerdo)", bone = 10706, pos = { x = 0.15, y = 0.0, z = 0.13 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "pocoanims@joao", name = "pocoyodance_clip", flag = 49 } },
            { id = "ombro_direito_dance", label = "Dance (Ombro direito)", bone = 64729, pos = { x = 0.15, y = 0.0, z = -0.13 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "pocoanims@joao", name = "pocoyodance_clip", flag = 49 } },
            { id = "cabeca_dance", label = "Dance (Cabeça)", bone = 31086, pos = { x = 0.25, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "pocoanims@joao", name = "pocoyodance_clip", flag = 49 } },
        }},
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- POKÉMON
    -- ════════════════════════════════════════════════════════════════════════
    ["dreamsstore_bulbasaur"] = {
        type = "collection", name = "Bulbasaur", category = "Pokémon", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/POK%C3%89MON/bulbasaur.webp",
        prop = { model = "dreamsstore_bulbasaur", loop = true, moving = true, bone = 24817, pos = { x = -0.012553, y = 0.341958, z = 0.010345 }, rot = { x = -8.934948, y = 85.853547, z = 174.039535 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["bulbasaur"] = {
        type = "collection", name = "Bulbasaur", category = "Pokémon", price = 90,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/POKEMONS/BULBASAUR.webp",
        prop = { model = "jpx_bulbasaur", loop = true, moving = true,
            bone = 20190, pos = { x = -0.2, y = 0.0, z = -1.0 }, rot = { x = 0.0, y = 0.0, z = 180.0 } },
    },
    ["butterfree"] = {
        type = "collection", name = "Butterfree", category = "Pokémon", price = 90,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/POKEMONS/BUTTERFREE.webp",
        prop = { model = "jpx_butterfree", loop = true, moving = true,
            bone = 24818, pos = { x = 0.45, y = 0.0, z = 0.05 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
    },
    ["dreamsstore_charmander"] = {
        type = "collection", name = "Charmander", category = "Pokémon", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/POK%C3%89MON/charmander.webp",
        prop = { model = "dreamsstore_charmander", loop = true, moving = true, bone = 24817, pos = { x = -0.01854, y = 0.420363, z = -0.000171 }, rot = { x = 99.757329, y = -11.593075, z = 88.020781 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["charmander"] = {
        type = "collection", name = "Charmander", category = "Pokémon", price = 120,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/POKEMONS/CHARMANDER.webp",
        prop = { model = "jpx_charmander", loop = true, moving = true,
            bone = 45509, pos = { x = 0.01, y = -0.04, z = -0.1 }, rot = { x = 0.0, y = 220.0, z = 180.0 } },
    },
    ["eve"] = {
        type = "collection", name = "Eevee", category = "Pokémon", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/POK%C3%89MON/eve.webp",
        prop = { model = "dreamsstore_eve", loop = true, moving = true, bone = 24817, pos = { x = -0.074618, y = 0.426022, z = -0.012278 }, rot = { x = 174.175648, y = -86.958801, z = -4.831519 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["gengar"] = {
        type = "collection", name = "Gengar", category = "Pokémon", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/POK%C3%89MON/gengar.webp",
        prop = { model = "dreamsstore_gengar", loop = true, moving = true, bone = 24817, pos = { x = -0.046827, y = 0.423064, z = -0.020972 }, rot = { x = 5.077973, y = 82.491932, z = 85.850467 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["jigglypuff"] = {
        type = "collection", name = "Jigglypuff", category = "Pokémon", price = 90,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/POKEMONS/JIGGLYPUFF.webp",
        prop = { model = "jpx_jigglypuff", loop = true, moving = true,
            bone = 10706, pos = { x = 0.15, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = 10.0, z = 200.0 } },
    },
    ["magikarp"] = {
        type = "collection", name = "Magikarp", category = "Pokémon", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/POKEMONS/MAGIKARP.webp",
        prop = { model = "jpx_magikarp", loop = true, moving = true,
            bone = 20190, pos = { x = 0.0, y = 0.0, z = -0.45 }, rot = { x = 0.0, y = 0.0, z = 0.0 } },
    },
    ["meowth"] = {
        type = "collection", name = "Meowth", category = "Pokémon", price = 90,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/POKEMONS/MEOWTH.webp",
        prop = { model = "jpx_meowth", loop = true, moving = true,
            bone = 46078, pos = { x = -0.03, y = 0.07, z = -0.17 }, rot = { x = 30.0, y = 200.0, z = 190.0 } },
    },
    ["pidgey"] = {
        type = "collection", name = "Pidgey", category = "Pokémon", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/POKEMONS/PIDGEY.webp",
        prop = { model = "jpx_pidgey", loop = true, moving = true,
            bone = 24818, pos = { x = 0.5, y = 0.0, z = 0.5 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
    },
    ["dreamsstore_pikachu"] = {
        type = "collection", name = "Pikachu", category = "Pokémon", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/POK%C3%89MON/pikachu.webp",
        prop = { model = "dreamsstore_pikachu", loop = true, moving = true, bone = 24817, pos = { x = -0.01854, y = 0.420363, z = -0.000171 }, rot = { x = 99.757329, y = -11.593075, z = 88.020781 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["pikachu"] = {
        type = "collection", name = "Pikachu", category = "Pokémon", price = 120,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/POKEMONS/PIKACHU.webp",
        prop = { model = "jpx_pikachu", loop = true, moving = true,
            bone = 12844, pos = { x = 0.16, y = -0.06, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 195.0 } },
    },
    ["poliwhirl"] = {
        type = "collection", name = "Poliwhirl", category = "Pokémon", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/POKEMONS/POLIWHIRL.webp",
        prop = { model = "jpx_poliwhirl", loop = true, moving = true,
            bone = 20190, pos = { x = 0.5, y = 0.0, z = -0.82 }, rot = { x = 0.0, y = 0.0, z = 180.0 } },
    },
    ["psyduck"] = {
        type = "collection", name = "Psyduck", category = "Pokémon", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/POKEMONS/PSYDUCK.webp",
        prop = { model = "jpx_psyduck", loop = true, moving = true,
            bone = 16335, pos = { x = 0.05, y = 0.0, z = 0.18 }, rot = { x = 0.0, y = 0.0, z = 180.0 } },
    },
    ["squirtle"] = {
        type = "collection", name = "Squirtle", category = "Pokémon", price = 90,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/POKEMONS/SQUIRTLE.webp",
        prop = { model = "jpx_squirtle", loop = true, moving = true,
            bone = 40269, pos = { x = 0.3, y = 0.05, z = 0.12 }, rot = { x = 0.0, y = 0.0, z = 180.0 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- POLAR
    -- ════════════════════════════════════════════════════════════════════════
    ["polar"] = {
        type = "collection", name = "Ursinho Polar", category = "Polar", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/POLAR/babypolarbear.webp",
        prop = { model = "ursinhopolar_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_direito", label = "Ombro direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.08 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "ombro_esquerdo", label = "Ombro esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.08 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.18, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- PROCURANDO NEMO
    -- ════════════════════════════════════════════════════════════════════════
    ["bruce"] = {
        type = "collection", name = "Bruce", category = "Procurando Nemo", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PROCURANDO%20NEMO/bruce.webp",
        prop = { model = "brucefindingnemo_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.1, y = 0.45, z = -0.01 }, rot = { x = 0.1149, y = 88.0, z = 180.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["dory"] = {
        type = "collection", name = "Dory", category = "Procurando Nemo", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PROCURANDO%20NEMO/dory.webp",
        prop = { model = "doryfindingnemo_by_joao", loop = true, moving = true, bone = 10706, pos = { x = 0.15, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
    },
    ["marlin"] = {
        type = "collection", name = "Marlin", category = "Procurando Nemo", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PROCURANDO%20NEMO/marlin.webp",
        prop = { model = "marlinfindingnemo_by_joao", loop = true, moving = true, bone = 64729, pos = { x = 0.15, y = 0.0, z = -0.15 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
    },
    ["nemo"] = {
        type = "collection", name = "Nemo", category = "Procurando Nemo", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PROCURANDO%20NEMO/nemo.webp",
        prop = { model = "nemofindingnemo_by_joao", loop = true, moving = true, bone = 10706, pos = { x = 0.15, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
    },
    ["squirt"] = {
        type = "collection", name = "Squirt", category = "Procurando Nemo", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PROCURANDO%20NEMO/squirt.webp",
        prop = { model = "squirtfindingnemo_by_joao", loop = true, moving = true, bone = 31086, pos = { x = 0.2, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- PUCCA E GARU
    -- ════════════════════════════════════════════════════════════════════════
    ["blackcat"] = {
        type = "collection", name = "Black Cat", category = "Pucca e Garu", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PUCCA%20E%20GARU/blackcat.webp",
        prop = { model = "tokyoblackcat_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 90.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["chinesedragon"] = {
        type = "collection", name = "Dragao Chines", category = "Pucca e Garu", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PUCCA%20E%20GARU/chinesedragon.webp",
        prop = { model = "tokyochinesedragon_by_joao", loop = true, moving = true, bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
    },
    ["garu"] = {
        type = "collection", name = "Garu", category = "Pucca e Garu", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PUCCA%20E%20GARU/garu.webp",
        prop = { model = "tokyogaru_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.0, y = 0.15, z = -0.01 }, rot = { x = 105.0, y = -30.0, z = 230.0 }, anim = { dict = "peluciaanim@joao", name = "direita_clip", flag = 49 } },
    },
    ["luckycat"] = {
        type = "collection", name = "Lucky Cat", category = "Pucca e Garu", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PUCCA%20E%20GARU/luckycat.webp",
        prop = { model = "tokyoluckycat_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 90.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["Soul_menina"] = {
        type = "collection", name = "Menina", category = "Pucca e Garu", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PUCCA%20E%20GARU/Menina.webp",
        prop = { model = "Soul_menina", loop = true, moving = true, bone = 60309, pos = { x = 0.09, y = 0.24, z = 0.02 }, rot = { x = -103.699997, y = -257.529999, z = -20.02 }, anim = { dict = "hold_flowers@dad", name = "hold_flowers_clip", flag = 49 } },
    },
    ["Soul_menino"] = {
        type = "collection", name = "Menino", category = "Pucca e Garu", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PUCCA%20E%20GARU/menino.webp",
        prop = { model = "Soul_menino", loop = true, moving = true, bone = 60309, pos = { x = 0.04, y = 0.17, z = 0.07 }, rot = { x = -89.150002, y = -242.970001, z = -18.200001 }, anim = { dict = "hold_flowers@dad", name = "hold_flowers_clip", flag = 49 } },
    },
    ["pucca"] = {
        type = "collection", name = "Pucca", category = "Pucca e Garu", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/PUCCA%20E%20GARU/pucca.webp",
        prop = { model = "tokyopucca_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.0, y = 0.15, z = -0.01 }, rot = { x = 105.0, y = -30.0, z = 230.0 }, anim = { dict = "peluciaanim@joao", name = "direita_clip", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- QUARTETO FANTÁSTICO
    -- ════════════════════════════════════════════════════════════════════════
    ["homemelastico"] = {
        type = "collection", name = "Homem Elástico", category = "Quarteto Fantástico", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/QUARTETO%20FANT%C3%81STICO/homemelastico.webp",
        prop = { model = "homemelastico_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 180.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["mulherinvisivel"] = {
        type = "collection", name = "Mulher Invisível", category = "Quarteto Fantástico", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/QUARTETO%20FANT%C3%81STICO/mulherinvisivel.webp",
        prop = { model = "mulherinvisivel_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 180.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["ocoisa"] = {
        type = "collection", name = "O Coisa", category = "Quarteto Fantástico", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/QUARTETO%20FANT%C3%81STICO/ocoisa.webp",
        prop = { model = "ocoisa_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 180.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["otocha"] = {
        type = "collection", name = "O Tocha", category = "Quarteto Fantástico", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/QUARTETO%20FANT%C3%81STICO/otocha.webp",
        prop = { model = "otocha_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 180.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["surfistaprateado"] = {
        type = "collection", name = "Surfista Prateado", category = "Quarteto Fantástico", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/QUARTETO%20FANT%C3%81STICO/survistaprateado.webp",
        prop = { model = "surfistaprateado_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 180.0, y = 88.69, z = 176.23 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- REPO
    -- ════════════════════════════════════════════════════════════════════════
    ["repobranco"] = {
        type = "collection", name = "Repo Branco", category = "Repo", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/REPO/repobranco.webp",
        prop = { model = "gotica_repobranco", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["repopreto"] = {
        type = "collection", name = "Repo Preto", category = "Repo", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/REPO/repopreto.webp",
        prop = { model = "gotica_repopreto", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["reporosa"] = {
        type = "collection", name = "Repo Rosa", category = "Repo", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/REPO/reporosa.webp",
        prop = { model = "gotica_reporosa", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["reporoxo"] = {
        type = "collection", name = "Repo Roxo", category = "Repo", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/REPO/reporoxo.webp",
        prop = { model = "gotica_reporoxo", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["repoverde"] = {
        type = "collection", name = "Repo Verde", category = "Repo", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/REPO/repoverde.webp",
        prop = { model = "gotica_repoverde", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- RIO
    -- ════════════════════════════════════════════════════════════════════════
    ["blue"] = {
        type = "collection", name = "Blu", category = "Rio", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/RIO/blue.webp",
        prop = { model = "riobluanim_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo", label = "Ombro Esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.1 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_direito", label = "Ombro Direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.1 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.2, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["jade"] = {
        type = "collection", name = "Jade", category = "Rio", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/RIO/jade.webp",
        prop = { model = "jawelrioanim_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo", label = "Ombro Esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_direito", label = "Ombro Direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.15 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.25, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["nico"] = {
        type = "collection", name = "Nico", category = "Rio", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/RIO/nico.webp",
        prop = { model = "nicorioanim_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo", label = "Ombro Esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.13 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_direito", label = "Ombro Direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.13 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["pedro"] = {
        type = "collection", name = "Pedro", category = "Rio", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/RIO/pedro.webp",
        prop = { model = "pedrorioanim_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo", label = "Ombro Esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.13 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_direito", label = "Ombro Direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.13 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.2, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- SAGRADO PROFANO
    -- ════════════════════════════════════════════════════════════════════════
    ["angelwings"] = {
        type = "collection", name = "Asas Angelicais", category = "Sagrado Profano", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SAGRADO%20PROFANO/angelicalwings.webp",
        prop = { model = "angelicalwings_by_joao", loop = true, moving = true, positions = {
            { id = "costas", label = "Costas", bone = 24818, pos = { x = 0.15, y = -0.122, z = -0.012 }, rot = { x = 0.0, y = -90.0, z = 0.0 } },
        }},
    },
    ["demonwings"] = {
        type = "collection", name = "Asas Profanas", category = "Sagrado Profano", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SAGRADO%20PROFANO/profanewings.webp",
        prop = { model = "profanewings_by_joao", loop = true, moving = true, positions = {
            { id = "costas", label = "Costas", bone = 24818, pos = { x = 0.15, y = -0.16, z = 0.0 }, rot = { x = 6.586, y = 90.0, z = 180.0 } },
        }},
    },
    ["angelaura"] = {
        type = "collection", name = "Aura Angelical", category = "Sagrado Profano", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SAGRADO%20PROFANO/angelaura.webp",
        prop = { model = "angelaura_by_joao", loop = true, moving = true, positions = {
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.23, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["demonaura"] = {
        type = "collection", name = "Aura Demoníaca", category = "Sagrado Profano", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SAGRADO%20PROFANO/demonaura_.webp",
        prop = { model = "demonaura_by_joao", loop = true, moving = true, positions = {
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.19, y = 0.0937, z = 0.0 }, rot = { x = 15.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["angel"] = {
        type = "collection", name = "Bear Angel", category = "Sagrado Profano", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SAGRADO%20PROFANO/bearangel.webp",
        prop = { model = "bearangel_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo", label = "Ombro Esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.2 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_direito", label = "Ombro Direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.2 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["devil"] = {
        type = "collection", name = "Bear Devil", category = "Sagrado Profano", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SAGRADO%20PROFANO/beardevil.webp",
        prop = { model = "beardevil_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo", label = "Ombro Esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.2 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_direito", label = "Ombro Direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.2 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- SANRIO
    -- ════════════════════════════════════════════════════════════════════════
    ["cinnamonroll_joao"] = {
        type = "collection", name = "Cinnamonroll", category = "Sanrio", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SANRIO/cinnamon_joao.webp",
        prop = { model = "cinnamonrollanim_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esq", label = "Ombro esquerdo", bone = 10706, pos = { x = 0.15, y = 0.0, z = 0.1 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_dir", label = "Ombro direito", bone = 64729, pos = { x = 0.15, y = 0.0, z = -0.1 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.2, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["hellokitty_joao"] = {
        type = "collection", name = "Hello Kitty", category = "Sanrio", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SANRIO/hellokitty_joao.webp",
        prop = { model = "hellokittyanimated_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esq", label = "Ombro esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.1 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_dir", label = "Ombro direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.1 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.2, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["kuromi_joao"] = {
        type = "collection", name = "Kuromi", category = "Sanrio", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SANRIO/kuromi_joao.webp",
        prop = { model = "kuromisanrioanim_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esq", label = "Ombro esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.1 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_dir", label = "Ombro direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.1 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.2, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },
    ["mymelody_joao"] = {
        type = "collection", name = "My Melody", category = "Sanrio", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SANRIO/mymelody_joao.webp",
        prop = { model = "mymelodysunrioanim_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esq", label = "Ombro esquerdo", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.1 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
            { id = "ombro_dir", label = "Ombro direito", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.1 }, rot = { x = -180.0, y = 14.0, z = 20.0 } },
            { id = "cabeca", label = "Cabeça", bone = 31086, pos = { x = 0.2, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
        }},
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- SCOOBY-DOO
    -- ════════════════════════════════════════════════════════════════════════
    ["2daphne"] = {
        type = "collection", name = "Daphne Blake", category = "Scooby-Doo", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SCOOBY-DOO/2daphne.webp",
        prop = { model = "daphneblake_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.15, y = 0.2, z = 0.042 }, rot = { x = 90.0, y = -20.0, z = -180.0 }, anim = { dict = "minidolls@joao", name = "dolls_clip", flag = 49 } },
    },
    ["2fred"] = {
        type = "collection", name = "Fred Jones", category = "Scooby-Doo", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SCOOBY-DOO/2fred.webp",
        prop = { model = "fredjones_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.109, y = 0.087, z = 0.038 }, rot = { x = 94.754, y = -66.37, z = -170.0 }, anim = { dict = "minidolls@joao", name = "dolls_clip", flag = 49 } },
    },
    ["2salsisha"] = {
        type = "collection", name = "Salsisha Rogers", category = "Scooby-Doo", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SCOOBY-DOO/2salsisha.webp",
        prop = { model = "salsisharogers_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.12, y = 0.1, z = 0.042 }, rot = { x = 90.0, y = -20.0, z = -180.0 }, anim = { dict = "minidolls@joao", name = "dolls_clip", flag = 49 } },
    },
    ["2scoobyloo"] = {
        type = "collection", name = "Scooby-Loo", category = "Scooby-Doo", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SCOOBY-DOO/2scoobyloo.webp",
        prop = { model = "scoobyloo_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.113567, y = 0.477136, z = -0.017465 }, rot = { x = -171.121951, y = -85.608771, z = -4.471979 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["2velma"] = {
        type = "collection", name = "Velma Dinkley", category = "Scooby-Doo", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SCOOBY-DOO/2velma.webp",
        prop = { model = "velmadinkley_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.12, y = 0.15, z = 0.042 }, rot = { x = 90.0, y = -20.0, z = -180.0 }, anim = { dict = "minidolls@joao", name = "dolls_clip", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- SHREK
    -- ════════════════════════════════════════════════════════════════════════
    ["biscoito"] = {
        type = "collection", name = "Biscoito", category = "Shrek", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SHREK/biscoito.webp",
        prop = { model = "biscoito_by_joao", loop = true, moving = true, bone = 28422, pos = { x = 0.09, y = 0.08, z = -0.06 }, rot = { x = -73.059998, y = 64.18, z = 12.94 }, anim = { dict = "propsanimations@joao", name = "segurando_clip", flag = 50 } },
    },
    ["burro"] = {
        type = "collection", name = "Burro", category = "Shrek", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SHREK/burro.webp",
        prop = { model = "burro_by_joao", loop = true, moving = true, bone = 24817, pos = { x = 0.0, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["fiona"] = {
        type = "collection", name = "Fiona", category = "Shrek", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SHREK/fiona.webp",
        prop = { model = "fiona_by_joao", loop = true, moving = true, bone = 28422, pos = { x = 0.05, y = 0.05, z = -0.06 }, rot = { x = -73.059998, y = 64.18, z = 12.94 }, anim = { dict = "propsanimations@joao", name = "segurando_clip", flag = 50 } },
    },
    ["gatodebotas"] = {
        type = "collection", name = "Gato de Botas", category = "Shrek", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SHREK/gatodebotas.webp",
        prop = { model = "gatodebotas_by_joao", loop = true, moving = true, bone = 28422, pos = { x = 0.05, y = 0.05, z = -0.06 }, rot = { x = -73.059998, y = 64.18, z = 12.94 }, anim = { dict = "propsanimations@joao", name = "segurando_clip", flag = 50 } },
    },
    ["shrek"] = {
        type = "collection", name = "Shrek", category = "Shrek", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SHREK/shrek.webp",
        prop = { model = "shrek_by_joao", loop = true, moving = true, bone = 24817, pos = { x = 0.0, y = 0.4, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- SIMPSONS
    -- ════════════════════════════════════════════════════════════════════════
    ["bart"] = {
        type = "collection", name = "Bart", category = "Simpsons", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SIMPSONS/bart.webp",
        prop = { model = "bartsimpson_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.098, y = 0.055, z = 0.035 }, rot = { x = 105.37, y = -15.0, z = -137.37 }, anim = { dict = "peluciaanim@joao", name = "direita_clip", flag = 49 } },
    },
    ["homer"] = {
        type = "collection", name = "Homer", category = "Simpsons", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SIMPSONS/homer.webp",
        prop = { model = "homersimpson_by_joao", loop = true, moving = true, bone = 24817, pos = { x = -0.084, y = 0.436, z = -0.0198 }, rot = { x = 0.1149, y = 88.0, z = 180.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["lisa"] = {
        type = "collection", name = "Lisa", category = "Simpsons", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SIMPSONS/lisa.webp",
        prop = { model = "lisasimpson_by_joao", loop = true, moving = true, bone = 18905, pos = { x = 0.098, y = 0.055, z = 0.035 }, rot = { x = 105.37, y = -15.0, z = -137.37 }, anim = { dict = "peluciaanim@joao", name = "direita_clip", flag = 49 } },
    },
    ["maggie"] = {
        type = "collection", name = "Maggie", category = "Simpsons", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SIMPSONS/maggie.webp",
        prop = { model = "maggiesimpson_by_joao", loop = true, moving = true, bone = 24817, pos = { x = 0.0, y = 0.4, z = -0.01 }, rot = { x = 0.1149, y = 88.0, z = 180.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["marge"] = {
        type = "collection", name = "Marge", category = "Simpsons", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SIMPSONS/marge.webp",
        prop = { model = "margesimpson_by_joao", loop = true, moving = true, bone = 28422, pos = { x = 0.0, y = 0.0703, z = -0.054 }, rot = { x = -86.76, y = 30.25, z = 16.94 }, anim = { dict = "peluciaanim@joao", name = "esquerda_clip", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- SONIC
    -- ════════════════════════════════════════════════════════════════════════
    ["amyrose"] = {
        type = "collection", name = "Amy Rose", category = "Sonic", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SONIC/amyrose.webp",
        prop = { model = "amyroseflickgabbys", loop = true, moving = true, bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.09 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
    },
    ["knuckles"] = {
        type = "collection", name = "Knuckles", category = "Sonic", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SONIC/knuckles.webp",
        prop = { model = "knuclesflickgabbys", loop = true, moving = true, bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.13 }, rot = { x = 0.0, y = -14.0, z = 195.0 } },
    },
    ["shadow"] = {
        type = "collection", name = "Shadow", category = "Sonic", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SONIC/shadow.webp",
        prop = { model = "shadowflickgabbys", loop = true, moving = true, bone = 12844, pos = { x = 0.169, y = 0.0, z = -0.006 }, rot = { x = 180.0, y = 275.0, z = 0.0 } },
    },
    ["sonic"] = {
        type = "collection", name = "Sonic", category = "Sonic", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SONIC/sonic.webp",
        prop = { model = "sonicflickgabbys", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.3911, z = 0.0 }, rot = { x = 180.0, y = 275.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["tails"] = {
        type = "collection", name = "Tails", category = "Sonic", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SONIC/tails.webp",
        prop = { model = "tailsflickgabbys", loop = true, moving = true, bone = 12844, pos = { x = 0.239, y = 0.0, z = -0.013 }, rot = { x = 180.0, y = 275.0, z = 0.0 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- STITCH
    -- ════════════════════════════════════════════════════════════════════════
    ["grinch"] = {
        type = "collection", name = "Grinch", category = "Stitch", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/STITCH/grinch.webp",
        prop = { model = "bgd_chanel_grinch", loop = true, moving = true, bone = 28422, pos = { x = 0.14, y = -0.15, z = -0.11 }, rot = { x = -91.99, y = 52.03, z = 10.92 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["olaf"] = {
        type = "collection", name = "Olaf", category = "Stitch", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/STITCH/olaf.webp",
        prop = { model = "gnd_olaf", loop = true, moving = true, bone = 28422, pos = { x = 0.08, y = 0.14, z = -0.05 }, rot = { x = -67.76, y = 62.92, z = 13.31 }, anim = { dict = "gndsegunrandochucky@animations", name = "gndsegunrandochucky_clip", flag = 50 } },
    },
    ["stitch1"] = {
        type = "collection", name = "Stitch Noel", category = "Stitch", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/STITCH/stitch1.webp",
        prop = { model = "dreamsstore_stitch1", loop = true, moving = true, bone = 24817, pos = { x = -0.05, y = 0.485648, z = -0.013037 }, rot = { x = -174.648998, y = -88.776546, z = 2.156822 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["stitch2"] = {
        type = "collection", name = "Stitch Pisca Pisca", category = "Stitch", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/STITCH/stitch2.webp",
        prop = { model = "dreamsstore_stitch2", loop = true, moving = true, bone = 24817, pos = { x = -0.05, y = 0.52, z = -0.013037 }, rot = { x = -174.648998, y = -88.776546, z = 2.156822 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["stitch3"] = {
        type = "collection", name = "Stitch Rena", category = "Stitch", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/STITCH/stitch3.webp",
        prop = { model = "dreamsstore_stitch3", loop = true, moving = true, bone = 24817, pos = { x = -0.05, y = 0.52, z = -0.013037 }, rot = { x = -174.648998, y = -88.776546, z = 2.156822 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- STRANGER THINGS
    -- ════════════════════════════════════════════════════════════════════════
    ["demogorgon"] = {
        type = "collection", name = "Demogorgon", category = "Stranger Things", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/STRANGER%20THINGS/demogorgon.webp",
        prop = { model = "gotica_demogorgon", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["eleven"] = {
        type = "collection", name = "Eleven", category = "Stranger Things", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/STRANGER%20THINGS/eleven.webp",
        prop = { model = "gotica_eleven", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["lucas"] = {
        type = "collection", name = "Lucas", category = "Stranger Things", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/STRANGER%20THINGS/lucas.webp",
        prop = { model = "gotica_lucas", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["max"] = {
        type = "collection", name = "Max", category = "Stranger Things", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/STRANGER%20THINGS/max.webp",
        prop = { model = "gotica_max", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["mikes"] = {
        type = "collection", name = "Mike", category = "Stranger Things", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/STRANGER%20THINGS/mike.webp",
        prop = { model = "gotica_mike", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["vecna"] = {
        type = "collection", name = "Vecna", category = "Stranger Things", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/STRANGER%20THINGS/vecna.webp",
        prop = { model = "gotica_vecna", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["will"] = {
        type = "collection", name = "Will", category = "Stranger Things", buyable = false, tradeable = false,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/STRANGER%20THINGS/will.webp",
        prop = { model = "gotica_will", loop = true, moving = true, bone = 24817, pos = { x = -0.2, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- SUPER NATURAL
    -- ════════════════════════════════════════════════════════════════════════
    ["bobs"] = {
        type = "collection", name = "Bobs", category = "Super Natural", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SUPER%20NATURAL/bobs.webp",
        prop = { model = "dreamsstore_bobs", loop = true, moving = true, bone = 28422, pos = { x = -0.077333, y = -0.000117, z = -0.104622 }, rot = { x = -67.276622, y = -2.046104, z = -106.908707 }, anim = { dict = "amb@code_human_wander_eating_donut@male@base", name = "static", flag = 49 } },
    },
    ["castiel"] = {
        type = "collection", name = "Castiel", category = "Super Natural", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SUPER%20NATURAL/castiel.webp",
        prop = { model = "dreamsstore_castiel", loop = true, moving = true, bone = 28422, pos = { x = -0.077333, y = -0.000117, z = -0.104622 }, rot = { x = -67.276622, y = -2.046104, z = -106.908707 }, anim = { dict = "amb@code_human_wander_eating_donut@male@base", name = "static", flag = 49 } },
    },
    ["crowley"] = {
        type = "collection", name = "Crowley", category = "Super Natural", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SUPER%20NATURAL/crowley.webp",
        prop = { model = "dreamsstore_crowley", loop = true, moving = true, bone = 28422, pos = { x = -0.077333, y = -0.000117, z = -0.104622 }, rot = { x = -67.276622, y = -2.046104, z = -106.908707 }, anim = { dict = "amb@code_human_wander_eating_donut@male@base", name = "static", flag = 49 } },
    },
    ["dean"] = {
        type = "collection", name = "Dean", category = "Super Natural", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SUPER%20NATURAL/dean.webp",
        prop = { model = "dreamsstore_dean", loop = true, moving = true, bone = 28422, pos = { x = -0.077333, y = -0.000117, z = -0.104622 }, rot = { x = -67.276622, y = -2.046104, z = -106.908707 }, anim = { dict = "amb@code_human_wander_eating_donut@male@base", name = "static", flag = 49 } },
    },
    ["sam"] = {
        type = "collection", name = "Sam", category = "Super Natural", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SUPER%20NATURAL/sam.webp",
        prop = { model = "dreamsstore_sam", loop = true, moving = true, bone = 28422, pos = { x = -0.077333, y = -0.000117, z = -0.104622 }, rot = { x = -67.276622, y = -2.046104, z = -106.908707 }, anim = { dict = "amb@code_human_wander_eating_donut@male@base", name = "static", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- SUPER-HERÓIS
    -- ════════════════════════════════════════════════════════════════════════
    ["bat"] = {
        type = "collection", name = "Batman", category = "Super-heróis", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SUPER-HER%C3%93IS/bat.webp",
        prop = { model = "wave_bat_prop", loop = true, moving = true, bone = 24817, pos = { x = -0.1, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["cap"] = {
        type = "collection", name = "Capitão América", category = "Super-heróis", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SUPER-HER%C3%93IS/cap.webp",
        prop = { model = "wave_cap_prop", loop = true, moving = true, bone = 24817, pos = { x = -0.1, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["marvel_capitao"] = {
        type = "collection", name = "Capitão América", category = "Super-heróis", price = 60, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SUPER-HER%C3%93IS/capitaomarvel.webp",
        prop = { model = "dreamsstore_capitao", loop = true, moving = true, animOnPed = true, bone = 28422, pos = { x = -0.120927, y = -0.230408, z = -0.120515 }, rot = { x = -12.024129, y = -2.873321, z = 165.803594 }, anim = { dict = "amb@code_human_wander_drinking@male@base", name = "static", flag = 49 } },
    },
    ["ironman"] = {
        type = "collection", name = "Homem de Ferro", category = "Super-heróis", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SUPER-HER%C3%93IS/iron.webp",
        prop = { model = "wave_iron_prop", loop = true, moving = true, bone = 24817, pos = { x = -0.1, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["marvel_ironman"] = {
        type = "collection", name = "Homem de Ferro", category = "Super-heróis", price = 60, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SUPER-HER%C3%93IS/ironmanmarvel.webp",
        prop = { model = "dreamsstore_ironman", loop = true, moving = true, animOnPed = true, bone = 28422, pos = { x = -0.120927, y = -0.230408, z = -0.120515 }, rot = { x = -12.024129, y = -2.873321, z = 165.803594 }, anim = { dict = "amb@code_human_wander_drinking@male@base", name = "static", flag = 49 } },
    },
    ["spider"] = {
        type = "collection", name = "Homem-Aranha", category = "Super-heróis", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SUPER-HER%C3%93IS/spider.webp",
        prop = { model = "wave_spider_prop", loop = true, moving = true, bone = 24817, pos = { x = -0.1, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["hulk"] = {
        type = "collection", name = "Hulk", category = "Super-heróis", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SUPER-HER%C3%93IS/hulk.webp",
        prop = { model = "wave_hulk_prop", loop = true, moving = true, bone = 24817, pos = { x = -0.1, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["super"] = {
        type = "collection", name = "Superman", category = "Super-heróis", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/SUPER-HER%C3%93IS/super.webp",
        prop = { model = "wave_super_prop", loop = true, moving = true, bone = 24817, pos = { x = -0.1, y = 0.46, z = -0.016 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- TAROT MODELS
    -- ════════════════════════════════════════════════════════════════════════
    ["coelho_ombro"] = {
        type = "collection", name = "Coelho Ombro", category = "Tarot Models", price = 120,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/TAROT%20MODELS/coelho_ombro.webp",
        prop = { model = "coelho_ombro", loop = true, moving = true, bone = 10706, pos = { x = -0.068, y = -0.078, z = -0.117 }, rot = { x = -13.1, y = -55.1, z = -175.8 } },
    },
    ["hiotostore_labubu_alorny"] = {
        type = "collection", name = "Labubu Alorny", category = "Tarot Models", price = 120,
        prop = { model = "hiotostore_labubu_alorny", loop = true, moving = true, bone = 18905, pos = { x = -0.01, y = 0.03, z = 0.14 }, rot = { x = -69.0, y = -162.0, z = -44.0 }, anim = { dict = "hiotostore_labubupose", name = "hiotostore_labubupose_clip", flag = 49 } },
    },
    ["hiotostore_labubu_juliana"] = {
        type = "collection", name = "Labubu Juliana", category = "Tarot Models", price = 120,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/TAROT%20MODELS/hiotostore_labubu_juliana.webp",
        prop = { model = "hiotostore_labubu_juliana", loop = true, moving = true, bone = 24817, pos = { x = -0.1, y = 0.4, z = -0.034 }, rot = { x = -180.0, y = -90.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["i_torat_labubu"] = {
        type = "collection", name = "Labubu Tarot", category = "Tarot Models", price = 120,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/TAROT%20MODELS/i_torat_labubu.webp",
        prop = { model = "i_torat_labubu", loop = true, moving = true, bone = 60309, pos = { x = -0.01, y = 0.06, z = 0.11 }, rot = { x = 62.7, y = -23.7, z = 166.8 }, anim = { dict = "alabubu@anima", name = "alabubu_clip", flag = 49 } },
    },
    ["urso_espinhoso"] = {
        type = "collection", name = "Urso Espinhoso", category = "Tarot Models", price = 120,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/TAROT%20MODELS/urso_espinhoso.webp",
        prop = { model = "urso_espinhoso", loop = true, moving = true, bone = 60309, pos = { x = 0.163, y = -1.67, z = 2.893 }, rot = { x = 33.0, y = 310.6, z = 229.9 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- TURMA DO SNOOPY
    -- ════════════════════════════════════════════════════════════════════════
    ["Soul_Cachorro"] = {
        type = "collection", name = "Cachorro", category = "Turma do Snoopy", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/TURMA%20DO%20SNOOPY/cachorro.webp",
        prop = { model = "Soul_Cachorro", loop = true, moving = true, bone = 60309, pos = { x = 0.09, y = 0.24, z = 0.02 }, rot = { x = -103.699997, y = -257.529999, z = -20.02 }, anim = { dict = "hold_flowers@dad", name = "hold_flowers_clip", flag = 49 } },
    },
    ["charliebrow"] = {
        type = "collection", name = "Charlie Brow", category = "Turma do Snoopy", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/TURMA%20DO%20SNOOPY/charliebrow.webp",
        prop = { model = "charliebrow_by_joao", loop = true, moving = true, bone = 24817, pos = { x = 0.0, y = 0.45, z = -0.01 }, rot = { x = 0.1149, y = 88.0, z = 180.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["linus"] = {
        type = "collection", name = "Linus", category = "Turma do Snoopy", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/TURMA%20DO%20SNOOPY/linus.webp",
        prop = { model = "linuscharliebrow_by_joao", loop = true, moving = true, bone = 24817, pos = { x = 0.0, y = 0.45, z = -0.01 }, rot = { x = 0.1149, y = 88.0, z = 180.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["lucy"] = {
        type = "collection", name = "Lucy", category = "Turma do Snoopy", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/TURMA%20DO%20SNOOPY/lucy.webp",
        prop = { model = "lucycharliebrow_by_joao", loop = true, moving = true, bone = 24817, pos = { x = 0.0, y = 0.45, z = -0.01 }, rot = { x = 0.1149, y = 88.0, z = 180.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["snoopy"] = {
        type = "collection", name = "Snoopy", category = "Turma do Snoopy", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/TURMA%20DO%20SNOOPY/snoopy.webp",
        prop = { model = "snoopycharliebrow_by_joao", loop = true, moving = true, bone = 24817, pos = { x = 0.0, y = 0.45, z = -0.01 }, rot = { x = 0.1149, y = 88.0, z = 180.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["woodstock"] = {
        type = "collection", name = "Woodstock", category = "Turma do Snoopy", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/TURMA%20DO%20SNOOPY/woodstock.webp",
        prop = { model = "woodstockcharliebrow_by_joao", loop = true, moving = true, bone = 31086, pos = { x = 0.22, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- URSINHOS CARINHOSOS
    -- ════════════════════════════════════════════════════════════════════════
    ["ursinhoamarelo"] = {
        type = "collection", name = "Ursinho Amarelo", category = "Ursinhos Carinhosos", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/URSINHOS%20CARINHOSOS/ursinhoamarelo.webp",
        prop = { model = "ursinhoflickamarelo", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 180.0, y = 275.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["ursinhoazul"] = {
        type = "collection", name = "Ursinho Azul", category = "Ursinhos Carinhosos", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/URSINHOS%20CARINHOSOS/ursinhoazul.webp",
        prop = { model = "ursinhoflickazul", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 180.0, y = 275.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["ursinhorosa"] = {
        type = "collection", name = "Ursinho Rosa", category = "Ursinhos Carinhosos", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/URSINHOS%20CARINHOSOS/ursinhorosa.webp",
        prop = { model = "ursinhoflickrosa", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 180.0, y = 275.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["ursinhoroxo"] = {
        type = "collection", name = "Ursinho Roxo", category = "Ursinhos Carinhosos", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/URSINHOS%20CARINHOSOS/ursinhoroxo.webp",
        prop = { model = "ursinhoflickroxo", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 180.0, y = 275.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["ursinhoverde"] = {
        type = "collection", name = "Ursinho Verde", category = "Ursinhos Carinhosos", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/URSINHOS%20CARINHOSOS/ursinhoverde.webp",
        prop = { model = "ursinhoflickverde", loop = true, moving = true, bone = 24817, pos = { x = -0.0436, y = 0.4311, z = 0.0 }, rot = { x = 180.0, y = 275.0, z = 0.0 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- VALENTINE'S DAY
    -- ════════════════════════════════════════════════════════════════════════
    ["loveablecat2"] = {
        type = "collection", name = "Gato Branco Apaixonado", category = "Valentine's Day", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/VALENTINE'S%20DAY/lovablewhitecat.webp",
        prop = { model = "lovablewhitecat_by_joao", loop = true, moving = true, positions = {
            { id = "flores_ombro_esq", label = "Com Flores na mão (Ombro Esquerdo)", bone = 10706, pos = { x = 0.15, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "lovablecat@joao", name = "idle_clip", flag = 49 } },
            { id = "voando_ombro_esq", label = "Voando (Ombro esquerdo)", bone = 10706, pos = { x = 0.15, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "lovablecat@joao", name = "flying_clip", flag = 49 } },
            { id = "sentado_ombro_esq", label = "Sentado (Ombro Esquerdo)", bone = 10706, pos = { x = 0.15, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "lovablecat@joao", name = "sit_clip", flag = 49 } },
            { id = "flores_ombro_dir", label = "Com Flores na mão (Ombro Direito)", bone = 64729, pos = { x = 0.15, y = 0.0, z = -0.15 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "lovablecat@joao", name = "idle_clip", flag = 49 } },
            { id = "voando_ombro_dir", label = "Voando (Ombro Direito)", bone = 64729, pos = { x = 0.15, y = 0.0, z = -0.15 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "lovablecat@joao", name = "flying_clip", flag = 49 } },
            { id = "sentado_ombro_dir", label = "Sentado (Ombro Direito)", bone = 64729, pos = { x = 0.15, y = 0.0, z = -0.15 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "lovablecat@joao", name = "sit_clip", flag = 49 } },
            { id = "flores_cabeca", label = "Com Flores na mão (Na Cabeça)", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "lovablecat@joao", name = "idle_clip", flag = 49 } },
            { id = "voando_cabeca", label = "Voando (Na Cabeça)", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "lovablecat@joao", name = "flying_clip", flag = 49 } },
            { id = "sentado_cabeca", label = "Sentado (Na Cabeça)", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "lovablecat@joao", name = "sit_clip", flag = 49 } },
        }},
    },
    ["loveablecat3"] = {
        type = "collection", name = "Gato Branco Cupido", category = "Valentine's Day", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/VALENTINE'S%20DAY/CupidWhiteCat.webp",
        prop = { model = "cupidwhitecat_by_joao", loop = true, moving = true, positions = {
            { id = "flores_ombro_esq", label = "Com Flores na mão (Ombro Esquerdo)", bone = 10706, pos = { x = 0.15, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "lovablecat@joao", name = "idle_clip", flag = 49 } },
            { id = "voando_ombro_esq", label = "Voando (Ombro esquerdo)", bone = 10706, pos = { x = 0.15, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "lovablecat@joao", name = "flying_clip", flag = 49 } },
            { id = "sentado_ombro_esq", label = "Sentado (Ombro Esquerdo)", bone = 10706, pos = { x = 0.15, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "lovablecat@joao", name = "sit_clip", flag = 49 } },
            { id = "flores_ombro_dir", label = "Com Flores na mão (Ombro Direito)", bone = 64729, pos = { x = 0.15, y = 0.0, z = -0.15 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "lovablecat@joao", name = "idle_clip", flag = 49 } },
            { id = "voando_ombro_dir", label = "Voando (Ombro Direito)", bone = 64729, pos = { x = 0.15, y = 0.0, z = -0.15 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "lovablecat@joao", name = "flying_clip", flag = 49 } },
            { id = "sentado_ombro_dir", label = "Sentado (Ombro Direito)", bone = 64729, pos = { x = 0.15, y = 0.0, z = -0.15 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "lovablecat@joao", name = "sit_clip", flag = 49 } },
            { id = "flores_cabeca", label = "Com Flores na mão (Na Cabeça)", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "lovablecat@joao", name = "idle_clip", flag = 49 } },
            { id = "voando_cabeca", label = "Voando (Na Cabeça)", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "lovablecat@joao", name = "flying_clip", flag = 49 } },
            { id = "sentado_cabeca", label = "Sentado (Na Cabeça)", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "lovablecat@joao", name = "sit_clip", flag = 49 } },
        }},
    },
    ["loveablecat"] = {
        type = "collection", name = "Gato Preto Apaixonado", category = "Valentine's Day", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/VALENTINE'S%20DAY/lovableDarkCat.webp",
        prop = { model = "lovabledarkcat_by_joao", loop = true, moving = true, positions = {
            { id = "flores_ombro_esq", label = "Com Flores na mão (Ombro Esquerdo)", bone = 10706, pos = { x = 0.15, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "lovablecat@joao", name = "idle_clip", flag = 49 } },
            { id = "voando_ombro_esq", label = "Voando (Ombro esquerdo)", bone = 10706, pos = { x = 0.15, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "lovablecat@joao", name = "flying_clip", flag = 49 } },
            { id = "sentado_ombro_esq", label = "Sentado (Ombro Esquerdo)", bone = 10706, pos = { x = 0.15, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "lovablecat@joao", name = "sit_clip", flag = 49 } },
            { id = "flores_ombro_dir", label = "Com Flores na mão (Ombro Direito)", bone = 64729, pos = { x = 0.15, y = 0.0, z = -0.15 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "lovablecat@joao", name = "idle_clip", flag = 49 } },
            { id = "voando_ombro_dir", label = "Voando (Ombro Direito)", bone = 64729, pos = { x = 0.15, y = 0.0, z = -0.15 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "lovablecat@joao", name = "flying_clip", flag = 49 } },
            { id = "sentado_ombro_dir", label = "Sentado (Ombro Direito)", bone = 64729, pos = { x = 0.15, y = 0.0, z = -0.15 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "lovablecat@joao", name = "sit_clip", flag = 49 } },
            { id = "flores_cabeca", label = "Com Flores na mão (Na Cabeça)", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "lovablecat@joao", name = "idle_clip", flag = 49 } },
            { id = "voando_cabeca", label = "Voando (Na Cabeça)", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "lovablecat@joao", name = "flying_clip", flag = 49 } },
            { id = "sentado_cabeca", label = "Sentado (Na Cabeça)", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "lovablecat@joao", name = "sit_clip", flag = 49 } },
        }},
    },
    ["loveablecat4"] = {
        type = "collection", name = "Gato Preto Cupido", category = "Valentine's Day", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/VALENTINE'S%20DAY/CupidDarkCat.webp",
        prop = { model = "cupiddarkcat_by_joao", loop = true, moving = true, positions = {
            { id = "flores_ombro_esq", label = "Com Flores na mão (Ombro Esquerdo)", bone = 10706, pos = { x = 0.15, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "lovablecat@joao", name = "idle_clip", flag = 49 } },
            { id = "voando_ombro_esq", label = "Voando (Ombro esquerdo)", bone = 10706, pos = { x = 0.15, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "lovablecat@joao", name = "flying_clip", flag = 49 } },
            { id = "sentado_ombro_esq", label = "Sentado (Ombro Esquerdo)", bone = 10706, pos = { x = 0.15, y = 0.0, z = 0.15 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "lovablecat@joao", name = "sit_clip", flag = 49 } },
            { id = "flores_ombro_dir", label = "Com Flores na mão (Ombro Direito)", bone = 64729, pos = { x = 0.15, y = 0.0, z = -0.15 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "lovablecat@joao", name = "idle_clip", flag = 49 } },
            { id = "voando_ombro_dir", label = "Voando (Ombro Direito)", bone = 64729, pos = { x = 0.15, y = 0.0, z = -0.15 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "lovablecat@joao", name = "flying_clip", flag = 49 } },
            { id = "sentado_ombro_dir", label = "Sentado (Ombro Direito)", bone = 64729, pos = { x = 0.15, y = 0.0, z = -0.15 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "lovablecat@joao", name = "sit_clip", flag = 49 } },
            { id = "flores_cabeca", label = "Com Flores na mão (Na Cabeça)", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "lovablecat@joao", name = "idle_clip", flag = 49 } },
            { id = "voando_cabeca", label = "Voando (Na Cabeça)", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "lovablecat@joao", name = "flying_clip", flag = 49 } },
            { id = "sentado_cabeca", label = "Sentado (Na Cabeça)", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "lovablecat@joao", name = "sit_clip", flag = 49 } },
        }},
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- VINGADORES
    -- ════════════════════════════════════════════════════════════════════════
    ["marvel_groot"] = {
        type = "collection", name = "Groot", category = "Vingadores", price = 60, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/VINGADORES/grootmarvel.webp",
        prop = { model = "dreamsstore_groot", loop = true, moving = true, animOnPed = true, bone = 28422, pos = { x = -0.120927, y = -0.230408, z = -0.120515 }, rot = { x = -12.024129, y = -2.873321, z = 165.803594 }, anim = { dict = "amb@code_human_wander_drinking@male@base", name = "static", flag = 49 } },
    },
    ["marvel_hulk"] = {
        type = "collection", name = "Hulk", category = "Vingadores", price = 60, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/VINGADORES/hulkmarvel.webp",
        prop = { model = "dreamsstore_hulk", loop = true, moving = true, animOnPed = true, bone = 28422, pos = { x = -0.110674, y = -0.248752, z = -0.109559 }, rot = { x = 0.0, y = 0.0, z = 176.159348 }, anim = { dict = "amb@code_human_wander_drinking@male@base", name = "static", flag = 49 } },
    },
    ["marvel_loki"] = {
        type = "collection", name = "Loki", category = "Vingadores", price = 180, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/VINGADORES/lokimarvel.webp",
        prop = { model = "dreamsstore_loki", loop = true, moving = true, animOnPed = true, bone = 28422, pos = { x = -0.046948, y = 0.153739, z = -0.18673 }, rot = { x = -109.686063, y = 23.614802, z = 167.568636 }, anim = { dict = "amb@code_human_wander_eating_donut@female@base", name = "static", flag = 49 } },
    },
    ["marvel_thor"] = {
        type = "collection", name = "Thor", category = "Vingadores", price = 60, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/VINGADORES/thormarvel.webp",
        prop = { model = "dreamsstore_thor", loop = true, moving = true, animOnPed = true, bone = 28422, pos = { x = -0.023253, y = -0.037066, z = 0.144309 }, rot = { x = 87.708379, y = -4.226223, z = 90.16897 }, anim = { dict = "amb@code_human_wander_drinking@male@base", name = "static", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- WINX
    -- ════════════════════════════════════════════════════════════════════════
    ["aisha"] = {
        type = "collection", name = "Aisha", category = "Winx", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/WINX/aisha.webp",
        prop = { model = "dreamsstore_aisha", loop = true, moving = true, bone = 24817, pos = { x = -0.009555, y = 0.439745, z = 0.0 }, rot = { x = 12.349201, y = 86.812626, z = 168.274097 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["bloom"] = {
        type = "collection", name = "Bloom", category = "Winx", price = 180,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/WINX/bloom.webp",
        prop = { model = "dreamsstore_blom", loop = true, moving = true, bone = 24817, pos = { x = -0.009555, y = 0.439745, z = 0.0 }, rot = { x = 12.349201, y = 86.812626, z = 168.274097 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["flora"] = {
        type = "collection", name = "Flora", category = "Winx", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/WINX/flora.webp",
        prop = { model = "dreamsstore_flora", loop = true, moving = true, bone = 24817, pos = { x = -0.009555, y = 0.439745, z = 0.0 }, rot = { x = 12.349201, y = 86.812626, z = 168.274097 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["musa"] = {
        type = "collection", name = "Musa", category = "Winx", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/WINX/musa.webp",
        prop = { model = "dreamsstore_musa", loop = true, moving = true, bone = 24817, pos = { x = -0.009555, y = 0.439745, z = 0.0 }, rot = { x = 12.349201, y = 86.812626, z = 168.274097 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["stella"] = {
        type = "collection", name = "Stella", category = "Winx", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/WINX/stella.webp",
        prop = { model = "dreamsstore_stella", loop = true, moving = true, bone = 24817, pos = { x = -0.009555, y = 0.439745, z = 0.0 }, rot = { x = 12.349201, y = 86.812626, z = 168.274097 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },
    ["tecna"] = {
        type = "collection", name = "Tecna", category = "Winx", price = 60,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/WINX/tecna.webp",
        prop = { model = "dreamsstore_tecna", loop = true, moving = true, bone = 24817, pos = { x = -0.009555, y = 0.439745, z = 0.0 }, rot = { x = 12.349201, y = 86.812626, z = 168.274097 }, anim = { dict = "impexp_int-0", name = "mp_m_waremech_01_dual-0", flag = 49 } },
    },

    -- ════════════════════════════════════════════════════════════════════════
    -- WINX ANIMADAS
    -- ════════════════════════════════════════════════════════════════════════
    ["aishaanimada"] = {
        type = "collection", name = "Aisha Animada", category = "Winx Animadas", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/WINX%20ANIMADAS/aishaanimada.webp",
        prop = { model = "aishaenchantixanim_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo_idle", label = "Idle (Ombro esquerdo)", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.18 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "winxenchantixanim@joao", name = "idle_clip", flag = 49 } },
            { id = "ombro_direito_idle", label = "Idle (Ombro direito)", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.18 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "winxenchantixanim@joao", name = "idle_clip", flag = 49 } },
            { id = "cabeca_idle", label = "Idle (Cabeça)", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "winxenchantixanim@joao", name = "idle_clip", flag = 49 } },
            { id = "voando", label = "Voando", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.18 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "winxenchantixanim@joao", name = "fly_clip", flag = 49 } },
        }},
    },
    ["bloomanimada"] = {
        type = "collection", name = "Bloom Animada", category = "Winx Animadas", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/WINX%20ANIMADAS/bloomanimada.webp",
        prop = { model = "bloomenchantixanim_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo_idle", label = "Idle (Ombro esquerdo)", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.18 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "winxenchantixanim@joao", name = "idle_clip", flag = 49 } },
            { id = "ombro_direito_idle", label = "Idle (Ombro direito)", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.18 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "winxenchantixanim@joao", name = "idle_clip", flag = 49 } },
            { id = "cabeca_idle", label = "Idle (Cabeça)", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "winxenchantixanim@joao", name = "idle_clip", flag = 49 } },
            { id = "voando", label = "Voando", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.18 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "winxenchantixanim@joao", name = "fly_clip", flag = 49 } },
        }},
    },
    ["floraanimada"] = {
        type = "collection", name = "Flora Animada", category = "Winx Animadas", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/WINX%20ANIMADAS/floraanimada.webp",
        prop = { model = "floraenchantixanim_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo_idle", label = "Idle (Ombro esquerdo)", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.18 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "winxenchantixanim@joao", name = "idle_clip", flag = 49 } },
            { id = "ombro_direito_idle", label = "Idle (Ombro direito)", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.18 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "winxenchantixanim@joao", name = "idle_clip", flag = 49 } },
            { id = "cabeca_idle", label = "Idle (Cabeça)", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "winxenchantixanim@joao", name = "idle_clip", flag = 49 } },
            { id = "voando", label = "Voando", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.18 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "winxenchantixanim@joao", name = "fly_clip", flag = 49 } },
        }},
    },
    ["musaanimada"] = {
        type = "collection", name = "Musa Animada", category = "Winx Animadas", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/WINX%20ANIMADAS/musaanimada.webp",
        prop = { model = "musaenchantixanim_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo_idle", label = "Idle (Ombro esquerdo)", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.18 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "winxenchantixanim@joao", name = "idle_clip", flag = 49 } },
            { id = "ombro_direito_idle", label = "Idle (Ombro direito)", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.18 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "winxenchantixanim@joao", name = "idle_clip", flag = 49 } },
            { id = "cabeca_idle", label = "Idle (Cabeça)", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "winxenchantixanim@joao", name = "idle_clip", flag = 49 } },
            { id = "voando", label = "Voando", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.18 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "winxenchantixanim@joao", name = "fly_clip", flag = 49 } },
        }},
    },
    ["stellaanimada"] = {
        type = "collection", name = "Stella Animada", category = "Winx Animadas", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/WINX%20ANIMADAS/stellaanimada.webp",
        prop = { model = "stellaenchantixanim_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo_idle", label = "Idle (Ombro esquerdo)", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.18 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "winxenchantixanim@joao", name = "idle_clip", flag = 49 } },
            { id = "ombro_direito_idle", label = "Idle (Ombro direito)", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.18 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "winxenchantixanim@joao", name = "idle_clip", flag = 49 } },
            { id = "cabeca_idle", label = "Idle (Cabeça)", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "winxenchantixanim@joao", name = "idle_clip", flag = 49 } },
            { id = "voando", label = "Voando", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.18 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "winxenchantixanim@joao", name = "fly_clip", flag = 49 } },
        }},
    },
    ["technaanimada"] = {
        type = "collection", name = "Techna Animada", category = "Winx Animadas", buyable = false, tradeable = false, objetodiferente = true,
        icon = "https://cdn.corenetwork.dev/PeluciasCore2/WINX%20ANIMADAS/technaanimada.webp",
        prop = { model = "technaenchantixanim_by_joao", loop = true, moving = true, positions = {
            { id = "ombro_esquerdo_idle", label = "Idle (Ombro esquerdo)", bone = 10706, pos = { x = 0.1, y = 0.0, z = 0.18 }, rot = { x = 0.0, y = -14.0, z = 195.0 }, anim = { dict = "winxenchantixanim@joao", name = "idle_clip", flag = 49 } },
            { id = "ombro_direito_idle", label = "Idle (Ombro direito)", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.18 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "winxenchantixanim@joao", name = "idle_clip", flag = 49 } },
            { id = "cabeca_idle", label = "Idle (Cabeça)", bone = 31086, pos = { x = 0.3, y = 0.03, z = 0.0 }, rot = { x = 0.0, y = 90.0, z = 180.0 }, anim = { dict = "winxenchantixanim@joao", name = "idle_clip", flag = 49 } },
            { id = "voando", label = "Voando", bone = 64729, pos = { x = 0.1, y = 0.0, z = -0.18 }, rot = { x = -180.0, y = 14.0, z = 20.0 }, anim = { dict = "winxenchantixanim@joao", name = "fly_clip", flag = 49 } },
        }},
    },
}
