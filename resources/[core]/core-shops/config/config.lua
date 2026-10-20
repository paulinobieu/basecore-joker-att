-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-SHOPS · CONFIGURAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Lojas de compra com interface própria e carrinho. Substitui a compra pelo
-- inventário do resource `shops` -- mantenha apenas um dos dois ativo nos
-- mesmos pontos para não duplicar a interação.
-----------------------------------------------------------------------------------------------------------------------------------------
-- Outros arquivos da pasta config/:
--   locations.lua → pontos de interação de cada loja no mapa
--   language.lua  → textos e notificações do resource
-----------------------------------------------------------------------------------------------------------------------------------------
-- Índice deste arquivo:
--   1. Interface & Interação
--   2. Regras de compra
--   3. Catálogo das lojas
-----------------------------------------------------------------------------------------------------------------------------------------

Shops = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 1. INTERFACE & INTERAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Distance em metros. Icon usa o catálogo do sleepless_interact.
Shops.Interaction = {
    Icon     = "cart-shopping",
    Distance = 2.0,
}

-- Sons tocados pelo resource `sounds` (arquivos em sounds/web-side/sounds).
-- Use false em qualquer um para desligar.
Shops.Sounds = {
    Open     = { Name = "shop", Volume = 0.5 },
    Purchase = { Name = "cash", Volume = 0.5 },
}

-- Cores enviadas para a interface no momento em que ela abre.
Shops.Colors = {
    primaryColor   = "#df1553",
    secondaryColor = "#9e0f3c",
    thirdyColor    = "#670a27",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 2. REGRAS DE COMPRA
-----------------------------------------------------------------------------------------------------------------------------------------
-- MaxLines: produtos distintos por compra. MaxAmount: unidades por produto.
Shops.Cart = {
    MaxLines  = 12,
    MaxAmount = 99,
}

-- Impostos ou multas pendentes bloqueiam a abertura da loja.
Shops.BlockOnDebt = true

-----------------------------------------------------------------------------------------------------------------------------------------
-- 3. CATÁLOGO DAS LOJAS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Title       → nome exibido no topo da interface (caixa alta).
-- Description → uma linha explicando o que a loja vende.
-- Payment     → "Cash" (dinheiro/banco), "Consume" (item) ou "Gemstone" (diamantes).
-- PaymentItem → item cobrado quando Payment = "Consume".
-- Permission  → serviço exigido para abrir (vRP.HasService). Opcional.
-- Route       → routing bucket exigido para abrir. Opcional.
-- IgnoreDebt  → libera a loja mesmo com impostos/multas em aberto. Opcional.
-- Categories  → abas da interface. Omita quando a loja for pequena.
-- Items       → { Item = índice do item, Price = valor unitário, Category = id da aba }
-----------------------------------------------------------------------------------------------------------------------------------------
Shops.List = {
    -------------------------------------------------------------------------------------------------------------------------------------
    -- CONVENIÊNCIA & VAREJO
    -------------------------------------------------------------------------------------------------------------------------------------
    Departament = {
        Title       = "LOJA DE CONVENIÊNCIA",
        Description = "Mantimentos, utilidades e eletrônicos do dia a dia.",
        Payment     = "Cash",
        Categories  = {
            { Id = "mercearia",  Label = "Mercearia" },
            { Id = "utilidade",  Label = "Utilidades" },
            { Id = "eletronico", Label = "Eletrônicos" },
        },
        Items = {
            { Item = "ryebread",           Price = 20,    Category = "mercearia" },
            { Item = "mayonnaise",         Price = 20,    Category = "mercearia" },
            { Item = "condensedmilk",      Price = 25,    Category = "mercearia" },
            { Item = "sugarbox",           Price = 35,    Category = "mercearia" },
            { Item = "ricebag",            Price = 105,   Category = "mercearia" },
            { Item = "postit",             Price = 20,    Category = "utilidade" },
            { Item = "cigarette",          Price = 15,    Category = "utilidade" },
            { Item = "lighter",            Price = 225,   Category = "utilidade" },
            { Item = "emptypurifiedwater", Price = 1275,  Category = "utilidade" },
            { Item = "vape",               Price = 4750,  Category = "utilidade" },
            { Item = "camera",             Price = 425,   Category = "eletronico" },
            { Item = "binoculars",         Price = 425,   Category = "eletronico" },
            { Item = "cellphone",          Price = 725,   Category = "eletronico" },
            { Item = "radio",              Price = 975,   Category = "eletronico" },
            { Item = "mapgps",             Price = 50000, Category = "eletronico" },
        },
    },

    Megamall = {
        Title       = "LOJA DO SHOPPING",
        Description = "Equipamentos de aventura e ferramentas de trabalho.",
        Payment     = "Cash",
        Categories  = {
            { Id = "equipamento", Label = "Equipamentos" },
            { Id = "ferramenta",  Label = "Ferramentas" },
        },
        Items = {
            { Item = "bait",                Price = 5,    Category = "equipamento" },
            { Item = "notepad",             Price = 10,   Category = "equipamento" },
            { Item = "WEAPON_ACIDPACKAGE",  Price = 10,   Category = "equipamento" },
            { Item = "WEAPON_BRICK",        Price = 25,   Category = "equipamento" },
            { Item = "WEAPON_SHOES",        Price = 25,   Category = "equipamento" },
            { Item = "GADGET_PARACHUTE",    Price = 225,  Category = "equipamento" },
            { Item = "suitcase",            Price = 275,  Category = "equipamento" },
            { Item = "alliance",            Price = 525,  Category = "equipamento" },
            { Item = "rope",                Price = 925,  Category = "equipamento" },
            { Item = "scuba",               Price = 975,  Category = "equipamento" },
            { Item = "emptypurifiedwater",  Price = 1275, Category = "equipamento" },
            { Item = "axe",                 Price = 1225, Category = "ferramenta" },
            { Item = "pickaxe",             Price = 1225, Category = "ferramenta" },
            { Item = "fishingrod",          Price = 1225, Category = "ferramenta" },
        },
    },

    Ammunation = {
        Title       = "LOJA DE ARMAS",
        Description = "Armas brancas e recursos de caça.",
        Payment     = "Cash",
        Items = {
            { Item = "WEAPON_HATCHET",      Price = 975 },
            { Item = "WEAPON_BAT",          Price = 975 },
            { Item = "WEAPON_BATTLEAXE",    Price = 975 },
            { Item = "WEAPON_CROWBAR",      Price = 975 },
            { Item = "WEAPON_SWITCHBLADE",  Price = 975 },
            { Item = "WEAPON_GOLFCLUB",     Price = 975 },
            { Item = "WEAPON_HAMMER",       Price = 975 },
            { Item = "WEAPON_MACHETE",      Price = 975 },
            { Item = "WEAPON_POOLCUE",      Price = 975 },
            { Item = "WEAPON_STONE_HATCHET", Price = 975 },
            { Item = "WEAPON_WRENCH",       Price = 975 },
            { Item = "WEAPON_KNUCKLE",      Price = 975 },
            { Item = "WEAPON_FLASHLIGHT",   Price = 975 },
        },
    },

    Cigarette = {
        Title       = "TABACARIA",
        Description = "Cigarros e isqueiro para o maço.",
        Payment     = "Cash",
        Items = {
            { Item = "cigarette", Price = 15 },
            { Item = "lighter",   Price = 225 },
        },
    },

    -------------------------------------------------------------------------------------------------------------------------------------
    -- COMIDA & BEBIDA
    -------------------------------------------------------------------------------------------------------------------------------------
    Lanchonete = {
        Title       = "LANCHONETE",
        Description = "Salgados, doces e bebidas do balcão.",
        Payment     = "Cash",
        Categories  = {
            { Id = "comida", Label = "Comidas" },
            { Id = "bebida", Label = "Bebidas" },
        },
        Items = {
            { Item = "donut",     Price = 15, Category = "comida" },
            { Item = "hotdog",    Price = 20, Category = "comida" },
            { Item = "chocolate", Price = 20, Category = "comida" },
            { Item = "hamburger", Price = 25, Category = "comida" },
            { Item = "cola",      Price = 20, Category = "bebida" },
            { Item = "soda",      Price = 20, Category = "bebida" },
            { Item = "coffeecup", Price = 20, Category = "bebida" },
            { Item = "water",     Price = 35, Category = "bebida" },
        },
    },

    Chihuahua = {
        Title       = "COMIDA MEXICANA",
        Description = "Lanches e bebidas servidos no balcão.",
        Payment     = "Cash",
        Items = {
            { Item = "hotdog",    Price = 20 },
            { Item = "cola",      Price = 20 },
            { Item = "soda",      Price = 20 },
            { Item = "hamburger", Price = 25 },
            { Item = "water",     Price = 35 },
        },
    },

    Hamburger = {
        Title       = "HAMBURGUERIA",
        Description = "Lanche na chapa para matar a fome.",
        Payment     = "Cash",
        Items = {
            { Item = "hamburger", Price = 25 },
        },
    },

    Hotdog = {
        Title       = "CARRINHO DE CACHORRO-QUENTE",
        Description = "Dogão completo servido na rua.",
        Payment     = "Cash",
        Items = {
            { Item = "hotdog", Price = 20 },
        },
    },

    Donut = {
        Title       = "DONUTERIA",
        Description = "Rosquinhas doces para acompanhar o café.",
        Payment     = "Cash",
        Items = {
            { Item = "donut",     Price = 15 },
            { Item = "chocolate", Price = 20 },
        },
    },

    Coffee = {
        Title       = "CAFETERIA",
        Description = "Café fresco para aguentar o turno.",
        Payment     = "Cash",
        Items = {
            { Item = "coffeecup", Price = 20 },
        },
    },

    Soda = {
        Title       = "MÁQUINA DE BEBIDAS",
        Description = "Refrigerantes e água gelada na hora.",
        Payment     = "Cash",
        Items = {
            { Item = "cola",  Price = 20 },
            { Item = "soda",  Price = 20 },
            { Item = "water", Price = 35 },
        },
    },

    Water = {
        Title       = "BEBEDOURO",
        Description = "Água mineral para repor a sede.",
        Payment     = "Cash",
        Items = {
            { Item = "water", Price = 35 },
        },
    },

    -------------------------------------------------------------------------------------------------------------------------------------
    -- SAÚDE
    -------------------------------------------------------------------------------------------------------------------------------------
    HospitalNorte = {
        Title       = "FARMÁCIA DO HOSPITAL NORTE",
        Description = "Suprimentos médicos para a equipe em serviço.",
        Payment     = "Cash",
        Permission  = "HospitalNorte",
        Categories  = {
            { Id = "medicamento", Label = "Medicamentos" },
            { Id = "suprimento",  Label = "Suprimentos" },
        },
        Items = {
            { Item = "syringe01",  Price = 45,   Category = "medicamento" },
            { Item = "syringe02",  Price = 45,   Category = "medicamento" },
            { Item = "syringe03",  Price = 45,   Category = "medicamento" },
            { Item = "syringe04",  Price = 45,   Category = "medicamento" },
            { Item = "analgesic",  Price = 65,   Category = "medicamento" },
            { Item = "sinkalmy",   Price = 185,  Category = "medicamento" },
            { Item = "ritmoneury", Price = 235,  Category = "medicamento" },
            { Item = "adrenaline", Price = 3225, Category = "medicamento" },
            { Item = "gdtkit",     Price = 25,   Category = "suprimento" },
            { Item = "gauze",      Price = 75,   Category = "suprimento" },
            { Item = "bandage",    Price = 115,  Category = "suprimento" },
            { Item = "medkit",     Price = 285,  Category = "suprimento" },
            { Item = "medicbag",   Price = 725,  Category = "suprimento" },
        },
    },

    HospitalSul = {
        Title       = "FARMÁCIA DO HOSPITAL SUL",
        Description = "Suprimentos médicos para a equipe em serviço.",
        Payment     = "Cash",
        Permission  = "HospitalSul",
        Categories  = {
            { Id = "medicamento", Label = "Medicamentos" },
            { Id = "suprimento",  Label = "Suprimentos" },
        },
        Items = {
            { Item = "syringe01",  Price = 45,   Category = "medicamento" },
            { Item = "syringe02",  Price = 45,   Category = "medicamento" },
            { Item = "syringe03",  Price = 45,   Category = "medicamento" },
            { Item = "syringe04",  Price = 45,   Category = "medicamento" },
            { Item = "analgesic",  Price = 65,   Category = "medicamento" },
            { Item = "sinkalmy",   Price = 185,  Category = "medicamento" },
            { Item = "ritmoneury", Price = 235,  Category = "medicamento" },
            { Item = "adrenaline", Price = 3225, Category = "medicamento" },
            { Item = "gdtkit",     Price = 25,   Category = "suprimento" },
            { Item = "gauze",      Price = 75,   Category = "suprimento" },
            { Item = "bandage",    Price = 115,  Category = "suprimento" },
            { Item = "medkit",     Price = 285,  Category = "suprimento" },
            { Item = "medicbag",   Price = 725,  Category = "suprimento" },
        },
    },

    FarmaciaPublica = {
        Title       = "FARMÁCIA",
        Description = "Remédios e curativos de venda livre.",
        Payment     = "Cash",
        Items = {
            { Item = "analgesic",  Price = 325 },
            { Item = "gauze",      Price = 375 },
            { Item = "bandage",    Price = 575 },
            { Item = "sinkalmy",   Price = 925 },
            { Item = "ritmoneury", Price = 1175 },
            { Item = "medkit",     Price = 1425 },
            { Item = "adrenaline", Price = 16125 },
        },
    },

    -------------------------------------------------------------------------------------------------------------------------------------
    -- OFICINA & TRABALHO
    -------------------------------------------------------------------------------------------------------------------------------------
    Bennys = {
        Title       = "LOJA DA OFICINA",
        Description = "Peças e ferramentas para o serviço mecânico.",
        Payment     = "Cash",
        Permission  = "Bennys",
        Items = {
            { Item = "tyres",         Price = 100 },
            { Item = "WEAPON_WRENCH", Price = 150 },
            { Item = "toolbox",       Price = 250 },
            { Item = "advtoolbox",    Price = 500 },
        },
    },

    MecanicaPublica = {
        Title       = "LOJA AUTOMOTIVA",
        Description = "Reparo rápido para tirar o veículo da rua.",
        Payment     = "Cash",
        Items = {
            { Item = "tyres",         Price = 500 },
            { Item = "WEAPON_WRENCH", Price = 750 },
            { Item = "toolbox",       Price = 1250 },
            { Item = "advtoolbox",    Price = 2500 },
        },
    },

    Hunting2 = {
        Title       = "LOJA DE CAÇA",
        Description = "Mosquete, munição e ração para a temporada.",
        Payment     = "Cash",
        Items = {
            { Item = "WEAPON_MUSKET_AMMO", Price = 10 },
            { Item = "ration",             Price = 125 },
            { Item = "WEAPON_MUSKET",      Price = 4225 },
        },
    },

    Dismantle = {
        Title       = "DEPÓSITO DE MATERIAIS",
        Description = "Troque limalha de ferro por matéria-prima industrial.",
        Payment     = "Consume",
        PaymentItem = "ironfilings",
        Items = {
            { Item = "plastic",  Price = 30 },
            { Item = "glass",    Price = 30 },
            { Item = "rubber",   Price = 30 },
            { Item = "aluminum", Price = 50 },
            { Item = "copper",   Price = 50 },
        },
    },

    -------------------------------------------------------------------------------------------------------------------------------------
    -- PENITENCIÁRIA
    -------------------------------------------------------------------------------------------------------------------------------------
    Banned = {
        Title       = "CANTINA DA PENITENCIÁRIA",
        Description = "Reduza sua pena usando diamantes.",
        Payment     = "Gemstone",
        Route       = 9999998,
        IgnoreDebt  = true,
        Items = {
            { Item = "banned_reduce", Price = 10 },
        },
    },
}
