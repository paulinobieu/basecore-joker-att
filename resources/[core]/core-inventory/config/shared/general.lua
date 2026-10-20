Inventory = Inventory or {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- GENERAL
-----------------------------------------------------------------------------------------------------------------------------------------
Inventory.General = {
    Language = "pt-BR",
    ImageBaseUrl = "https://cdn.corenetwork.dev/Itens/",
    Slots = {ExternalLimit = 200, DefaultExternal = 25},
    Ground = {Radius = 2.0},
    Interface = {
        Accent = "#dc1553",
        HeadshotTimeout = 3000,
        UseCooldown = 1000
    },
    Features = {
        Chests = true,
        Inspect = true,
        GroundDrops = true,
        ChestUpgrade = true,
        Properties = true,
        Trunks = true
    }
}
