-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIG
-----------------------------------------------------------------------------------------------------------------------------------------
Config = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- UI
-----------------------------------------------------------------------------------------------------------------------------------------
Config.UI = {
    logo = "https://cdn.corenetwork.dev/IDCore/HUD_GIF.gif"
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THEME
-----------------------------------------------------------------------------------------------------------------------------------------
Config.Theme = {
    primaryColor = "#dc1553",
    secondaryColor = "#01205c",
    thirdyColor = "#2563eb",
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- LINKS
-----------------------------------------------------------------------------------------------------------------------------------------
Config.Links = {
    shop = "https://lojamaldivas.citygroup.com.br",
    discord = "https://discord.gg/maldivasrps1",
    tiktok = "https://tiktok.com/@maldivasrp_oficial",
    instagram = "https://instagram.com/maldivasrp_oficial",
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONTROLS
-----------------------------------------------------------------------------------------------------------------------------------------
Config.Controls = {
    commands = {
        esc = "escmenu",
        map = "mapa",
    },
    descriptions = {
        esc = "Abrir menu ESC",
        map = "Abrir o mapa",
    },
    defaultKey = "ESCAPE",
    mapKey = "P",
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMMANDS
-----------------------------------------------------------------------------------------------------------------------------------------
Config.Commands = {
    skins = "skins",
    fpsOn = "fps on",
    fpsOff = "fps off",
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- BATTLEPASS [ Em breve ]
-----------------------------------------------------------------------------------------------------------------------------------------
Config.BattlePass = {
    current = 0,
    total = 10,
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- RANKING [ Em breve ]
-----------------------------------------------------------------------------------------------------------------------------------------
Config.Ranking = {
    Categories = {
        ["money"] = { name = "Dinheiro", showValue = true },
        ["kills"] = { name = "Kills", showValue = true },
        ["deaths"] = { name = "Mortes", showValue = true },
        ["cars"] = { name = "Carros", showValue = true },
        ["facs"] = { name = "Facções", showValue = true },
        ["online"] = { name = "Horas Jogadas", showValue = true },
    },
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- SHOP
-- Catálogo da Loja de Gemas. Produtos com `Item` são entregues no inventário;
-- os demais retornam "indisponível" até definir a entrega.
-----------------------------------------------------------------------------------------------------------------------------------------
Config.Shop = {
    categories = {
        -- { id = "todas", name = "Todas" },
        -- { id = "aeronaves", name = "Aeronaves" },
        -- { id = "barcos", name = "Barcos" },
        -- { id = "veiculos", name = "Veículos" },
        -- { id = "itens", name = "Itens" },
    },
    products = {
        -- Em breve. Exemplos (produtos com `Item` são entregues no inventário):
        -- { id = "heli_maverick", name = "Helicóptero Maverick", image = "", price = { diamonds = 500, cash = 55250 }, category = { id = "aeronaves", name = "Aeronaves" } },
        -- { id = "plane_luxor", name = "Jato Luxor Deluxe", image = "", price = { diamonds = 5000, cash = 0 }, category = { id = "aeronaves", name = "Aeronaves" } },
        -- { id = "yacht_adder", name = "Iate Adder Luxury", image = "", price = { diamonds = 8000, cash = 0 }, category = { id = "barcos", name = "Barcos" } },
        -- { id = "boat_dinghy", name = "Bote Inflável Dinghy", image = "", price = { diamonds = 450, cash = 0 }, category = { id = "barcos", name = "Barcos" } },
        -- { id = "car_adder", name = "Truffade Adder", image = "", price = { diamonds = 3200, cash = 0 }, category = { id = "veiculos", name = "Veículos" } },
        -- { id = "item_repairkit", name = "Kit de Reparo", image = "", Item = "repairkit01", price = { diamonds = 150, cash = 12000 }, category = { id = "itens", name = "Itens" } },
    },
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CACHE
-----------------------------------------------------------------------------------------------------------------------------------------
Config.Cache = {
    clientTime = 300000,
}
