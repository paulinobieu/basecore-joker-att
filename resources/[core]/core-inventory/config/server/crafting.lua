Inventory.Crafting = Inventory.Crafting or {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- RECIPES
-----------------------------------------------------------------------------------------------------------------------------------------
Inventory.Crafting.Recipes = {
    gauze = {Amount = 1, Required = {fabric = 3}},
    bandage = {Amount = 1, Required = {gauze = 4}},
    medkit = {
        Amount = 1,
        Required = {saline = 1, acetone = 1, alcohol = 1, fabric = 5, gauze = 3}
    },
    analgesic = {Amount = 1, Required = {fabric = 5, saline = 1}}
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- MISSIONS
-----------------------------------------------------------------------------------------------------------------------------------------
Inventory.Crafting.Missions = {
    {
        Xp = 100,
        Code = "MISSION01",
        Title = "Titulo da missão",
        Description = "Descrição da missão",
        Required = {blue_essence = 10},
        Rewards = {purple_essence = 10}
    },
    {
        Xp = 1000,
        Code = "MISSION02",
        Title = "Titulo da missão 2",
        Description = "Descrição da missão 2",
        Required = {purple_essence = 10},
        Rewards = {green_essence = 10}
    },
    {
        Xp = 10000,
        Code = "MISSION03",
        Title = "Titulo da missão 3",
        Description = "Descrição da missão 3",
        Required = {green_essence = 10},
        Rewards = {red_essence = 10}
    },
    {
        Xp = 50000,
        Code = "MISSION04",
        Title = "Titulo da missão 4",
        Description = "Descrição da missão 4",
        Required = {red_essence = 10},
        Rewards = {pink_essence = 10}
    }
}
