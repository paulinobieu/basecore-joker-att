Inventory.Loot = Inventory.Loot or {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- PRODUCTS
-----------------------------------------------------------------------------------------------------------------------------------------
Inventory.Loot.Products = {
    -------------------------------------------------------------------------------------------------------------------------------------
    -- TRASHER
    -------------------------------------------------------------------------------------------------------------------------------------
    ["Trasher"] = {
        ["Timer"] = 5,
        ["Item"] = "binbag",
        ["Itens"] = {
            {["Item"] = "plastic", ["Chance"] = 100, ["Min"] = 6, ["Max"] = 10},
            {["Item"] = "glass", ["Chance"] = 100, ["Min"] = 6, ["Max"] = 10},
            {["Item"] = "rubber", ["Chance"] = 100, ["Min"] = 6, ["Max"] = 10},
            {["Item"] = "aluminum", ["Chance"] = 50, ["Min"] = 4, ["Max"] = 8},
            {["Item"] = "copper", ["Chance"] = 50, ["Min"] = 4, ["Max"] = 8},
            {["Item"] = "techtrash", ["Chance"] = 5, ["Min"] = 1, ["Max"] = 2},
            {["Item"] = "tarp", ["Chance"] = 7, ["Min"] = 1, ["Max"] = 2},
            {["Item"] = "sheetmetal", ["Chance"] = 5, ["Min"] = 1, ["Max"] = 2},
            {["Item"] = "roadsigns", ["Chance"] = 5, ["Min"] = 1, ["Max"] = 2},
            {["Item"] = "scotchtape", ["Chance"] = 3, ["Min"] = 1, ["Max"] = 2},
            {
                ["Item"] = "insulatingtape",
                ["Chance"] = 3,
                ["Min"] = 1,
                ["Max"] = 2
            },
            {
                ["Item"] = "electroniccomponents",
                ["Chance"] = 3,
                ["Min"] = 1,
                ["Max"] = 2
            },
            {["Item"] = "batteryaa", ["Chance"] = 5, ["Min"] = 1, ["Max"] = 2},
            {
                ["Item"] = "batteryaaplus",
                ["Chance"] = 5,
                ["Min"] = 1,
                ["Max"] = 2
            },
            {
                ["Item"] = "emptybottle",
                ["Chance"] = 25,
                ["Min"] = 3,
                ["Max"] = 4
            }
        }
    },
    -------------------------------------------------------------------------------------------------------------------------------------
    -- CEMETERY
    -------------------------------------------------------------------------------------------------------------------------------------
    ["Cemitery"] = {
        ["Timer"] = 10,
        ["Police"] = true,
        ["Animation"] = {
            ["Dict"] = "amb@medic@standing@tendtodead@idle_a",
            ["Anim"] = "idle_a"
        },
        ["Itens"] = {
            {["Item"] = "skunksell", ["Chance"] = 25, ["Min"] = 2, ["Max"] = 3},
            {
                ["Item"] = "cocainasell",
                ["Chance"] = 25,
                ["Min"] = 2,
                ["Max"] = 3
            },
            {["Item"] = "metasell", ["Chance"] = 25, ["Min"] = 2, ["Max"] = 3},
            {["Item"] = "alliance", ["Chance"] = 50, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "scotchtape", ["Chance"] = 25, ["Min"] = 1, ["Max"] = 2},
            {
                ["Item"] = "insulatingtape",
                ["Chance"] = 25,
                ["Min"] = 1,
                ["Max"] = 2
            },
            {["Item"] = "screws", ["Chance"] = 15, ["Min"] = 1, ["Max"] = 3},
            {["Item"] = "screwnuts", ["Chance"] = 15, ["Min"] = 1, ["Max"] = 3},
            {
                ["Item"] = "goldnecklace",
                ["Chance"] = 15,
                ["Min"] = 1,
                ["Max"] = 1
            },
            {
                ["Item"] = "silverchain",
                ["Chance"] = 15,
                ["Min"] = 1,
                ["Max"] = 1
            },
            {
                ["Item"] = "horsefigurine",
                ["Chance"] = 3,
                ["Min"] = 1,
                ["Max"] = 1
            },
            {["Item"] = "toothpaste", ["Chance"] = 25, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "treasurebox", ["Chance"] = 1, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "suitcase", ["Chance"] = 35, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "gauze", ["Chance"] = 45, ["Min"] = 2, ["Max"] = 3},
            {["Item"] = "lockpick", ["Chance"] = 35, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "cellphone", ["Chance"] = 45, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "cigarette", ["Chance"] = 75, ["Min"] = 4, ["Max"] = 6},
            {["Item"] = "lighter", ["Chance"] = 45, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "vape", ["Chance"] = 15, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "pager", ["Chance"] = 2, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "scotchtape", ["Chance"] = 1, ["Min"] = 1, ["Max"] = 1},
            {
                ["Item"] = "insulatingtape",
                ["Chance"] = 1,
                ["Min"] = 1,
                ["Max"] = 1
            },
            {["Item"] = "screws", ["Chance"] = 1, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "screwnuts", ["Chance"] = 1, ["Min"] = 1, ["Max"] = 1}
        },
        ["Residual"] = "Resíduo de Clorofórmio"
    },
    -------------------------------------------------------------------------------------------------------------------------------------
    -- MILKMAN
    -------------------------------------------------------------------------------------------------------------------------------------
    ["Milkman"] = {
        ["Timer"] = 5,
        ["PolyZone"] = true,
        ["Item"] = "emptybottle",
        ["Animation"] = {
            ["Dict"] = "amb@medic@standing@kneel@base",
            ["Anim"] = "base"
        },
        ["Itens"] = {
            {
                ["Item"] = "milkbottle",
                ["Chance"] = 100,
                ["Min"] = 1,
                ["Max"] = 1
            }
        }
    }
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONTAINERS
-----------------------------------------------------------------------------------------------------------------------------------------
Inventory.Loot.Containers = {
    -------------------------------------------------------------------------------------------------------------------------------------
    -- LOOT MEDICS
    -------------------------------------------------------------------------------------------------------------------------------------
    ["LootMedics"] = {
        ["Cooldown"] = 3600,
        ["Item"] = "medicalkey",
        ["List"] = {
            {["Item"] = "skunksell", ["Chance"] = 65, ["Min"] = 2, ["Max"] = 3},
            {
                ["Item"] = "cocainasell",
                ["Chance"] = 65,
                ["Min"] = 2,
                ["Max"] = 3
            },
            {["Item"] = "metasell", ["Chance"] = 65, ["Min"] = 2, ["Max"] = 3},
            {
                ["Item"] = "heroinasell",
                ["Chance"] = 25,
                ["Min"] = 1,
                ["Max"] = 2
            },
            {["Item"] = "metadone", ["Chance"] = 25, ["Min"] = 1, ["Max"] = 2},
            {["Item"] = "codeine", ["Chance"] = 25, ["Min"] = 1, ["Max"] = 2},
            {
                ["Item"] = "amphetamine",
                ["Chance"] = 25,
                ["Min"] = 1,
                ["Max"] = 2
            },
            {["Item"] = "sulfuric", ["Chance"] = 45, ["Min"] = 2, ["Max"] = 3},
            {["Item"] = "acetone", ["Chance"] = 45, ["Min"] = 2, ["Max"] = 3},
            {["Item"] = "saline", ["Chance"] = 45, ["Min"] = 2, ["Max"] = 3},
            {["Item"] = "alcohol", ["Chance"] = 45, ["Min"] = 2, ["Max"] = 3},
            {["Item"] = "syringe01", ["Chance"] = 65, ["Min"] = 1, ["Max"] = 2},
            {["Item"] = "syringe02", ["Chance"] = 65, ["Min"] = 1, ["Max"] = 2},
            {["Item"] = "syringe03", ["Chance"] = 65, ["Min"] = 1, ["Max"] = 2},
            {["Item"] = "syringe04", ["Chance"] = 65, ["Min"] = 1, ["Max"] = 2},
            {["Item"] = "bandage", ["Chance"] = 25, ["Min"] = 1, ["Max"] = 2},
            {["Item"] = "medkit", ["Chance"] = 15, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "ritmoneury", ["Chance"] = 35, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "sinkalmy", ["Chance"] = 35, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "analgesic", ["Chance"] = 35, ["Min"] = 1, ["Max"] = 2},
            {["Item"] = "gauze", ["Chance"] = 45, ["Min"] = 2, ["Max"] = 4},
            {["Item"] = "adrenaline", ["Chance"] = 15, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "fabric", ["Chance"] = 15, ["Min"] = 1, ["Max"] = 2}
        }
    },
    -------------------------------------------------------------------------------------------------------------------------------------
    -- LOOT WEAPONS
    -------------------------------------------------------------------------------------------------------------------------------------
    ["LootWeapons"] = {
        ["Cooldown"] = 7200,
        ["Item"] = "weaponkey",
        ["List"] = {
            {
                ["Item"] = "repairkit01",
                ["Chance"] = 15,
                ["Min"] = 1,
                ["Max"] = 1
            },
            {
                ["Item"] = "repairkit02",
                ["Chance"] = 10,
                ["Min"] = 1,
                ["Max"] = 1
            },
            {["Item"] = "repairkit03", ["Chance"] = 5, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "repairkit04", ["Chance"] = 1, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "nitro", ["Chance"] = 15, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "circuit", ["Chance"] = 35, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "gunpowder", ["Chance"] = 65, ["Min"] = 1, ["Max"] = 3},
            {["Item"] = "pistolbody", ["Chance"] = 50, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "smgbody", ["Chance"] = 35, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "riflebody", ["Chance"] = 20, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "techtrash", ["Chance"] = 50, ["Min"] = 1, ["Max"] = 2},
            {["Item"] = "explosives", ["Chance"] = 50, ["Min"] = 1, ["Max"] = 2},
            {
                ["Item"] = "safependrive",
                ["Chance"] = 5,
                ["Min"] = 1,
                ["Max"] = 1
            },
            {
                ["Item"] = "weaponparts",
                ["Chance"] = 15,
                ["Min"] = 2,
                ["Max"] = 3
            },
            {["Item"] = "dismantle", ["Chance"] = 25, ["Min"] = 1, ["Max"] = 1},
            {
                ["Item"] = "blocksignal",
                ["Chance"] = 15,
                ["Min"] = 1,
                ["Max"] = 1
            },
            {
                ["Item"] = "ballisticplate",
                ["Chance"] = 10,
                ["Min"] = 1,
                ["Max"] = 1
            },
            {["Item"] = "lockpick", ["Chance"] = 50, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "handcuff", ["Chance"] = 15, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "hood", ["Chance"] = 25, ["Min"] = 1, ["Max"] = 1}
        }
    },
    -------------------------------------------------------------------------------------------------------------------------------------
    -- LOOT SUPPLIES
    -------------------------------------------------------------------------------------------------------------------------------------
    ["LootSupplies"] = {
        ["Cooldown"] = 3600,
        ["Item"] = "utilkey",
        ["List"] = {
            {["Item"] = "weedclone_0", ["Chance"] = 1, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "cokeclone_0", ["Chance"] = 1, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "plate", ["Chance"] = 25, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "plastic", ["Chance"] = 100, ["Min"] = 6, ["Max"] = 10},
            {["Item"] = "glass", ["Chance"] = 100, ["Min"] = 6, ["Max"] = 10},
            {["Item"] = "rubber", ["Chance"] = 100, ["Min"] = 6, ["Max"] = 10},
            {["Item"] = "aluminum", ["Chance"] = 75, ["Min"] = 4, ["Max"] = 8},
            {["Item"] = "copper", ["Chance"] = 75, ["Min"] = 4, ["Max"] = 8},
            {["Item"] = "techtrash", ["Chance"] = 25, ["Min"] = 1, ["Max"] = 2},
            {["Item"] = "tarp", ["Chance"] = 35, ["Min"] = 1, ["Max"] = 2},
            {["Item"] = "sheetmetal", ["Chance"] = 25, ["Min"] = 1, ["Max"] = 2},
            {["Item"] = "roadsigns", ["Chance"] = 25, ["Min"] = 1, ["Max"] = 2},
            {["Item"] = "explosives", ["Chance"] = 45, ["Min"] = 1, ["Max"] = 2},
            {["Item"] = "scotchtape", ["Chance"] = 25, ["Min"] = 1, ["Max"] = 2},
            {
                ["Item"] = "insulatingtape",
                ["Chance"] = 25,
                ["Min"] = 1,
                ["Max"] = 2
            },
            {["Item"] = "screws", ["Chance"] = 25, ["Min"] = 1, ["Max"] = 2},
            {["Item"] = "screwnuts", ["Chance"] = 25, ["Min"] = 1, ["Max"] = 2},
            {["Item"] = "bait", ["Chance"] = 75, ["Min"] = 5, ["Max"] = 10},
            {
                ["Item"] = "sapphire_pure",
                ["Chance"] = 50,
                ["Min"] = 3,
                ["Max"] = 6
            },
            {
                ["Item"] = "emerald_pure",
                ["Chance"] = 50,
                ["Min"] = 3,
                ["Max"] = 6
            },
            {["Item"] = "ruby_pure", ["Chance"] = 50, ["Min"] = 3, ["Max"] = 6},
            {["Item"] = "gold_pure", ["Chance"] = 50, ["Min"] = 3, ["Max"] = 6},
            {["Item"] = "iron_pure", ["Chance"] = 50, ["Min"] = 3, ["Max"] = 6},
            {["Item"] = "lead_pure", ["Chance"] = 50, ["Min"] = 3, ["Max"] = 6},
            {["Item"] = "tin_pure", ["Chance"] = 50, ["Min"] = 3, ["Max"] = 6},
            {
                ["Item"] = "diamond_pure",
                ["Chance"] = 50,
                ["Min"] = 3,
                ["Max"] = 6
            },
            {
                ["Item"] = "copper_pure",
                ["Chance"] = 50,
                ["Min"] = 3,
                ["Max"] = 6
            },
            {["Item"] = "binoculars", ["Chance"] = 35, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "camera", ["Chance"] = 35, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "postit", ["Chance"] = 65, ["Min"] = 4, ["Max"] = 6},
            {["Item"] = "radio", ["Chance"] = 35, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "cigarette", ["Chance"] = 75, ["Min"] = 3, ["Max"] = 6},
            {["Item"] = "lighter", ["Chance"] = 25, ["Min"] = 1, ["Max"] = 1},
            {["Item"] = "soap", ["Chance"] = 35, ["Min"] = 1, ["Max"] = 1},
            {
                ["Item"] = "emptybottle",
                ["Chance"] = 75,
                ["Min"] = 3,
                ["Max"] = 4
            },
            {["Item"] = "fabric", ["Chance"] = 75, ["Min"] = 2, ["Max"] = 3}
        }
    },
    -------------------------------------------------------------------------------------------------------------------------------------
    -- LOOT LEGENDARY
    -------------------------------------------------------------------------------------------------------------------------------------
    ["LootLegendary"] = {
        ["Cooldown"] = 10800,
        ["Item"] = "legendarykey",
        ["List"] = {}
    },
    -------------------------------------------------------------------------------------------------------------------------------------
    -- LOOT CODE
    -------------------------------------------------------------------------------------------------------------------------------------
    ["LootCode"] = {
        ["Code"] = "5221",
        ["Cooldown"] = 3600,
        ["List"] = {
            {["Item"] = "bandage", ["Chance"] = 100, ["Min"] = 1, ["Max"] = 1}
        }
    }
}
