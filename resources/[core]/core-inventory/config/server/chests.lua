-----------------------------------------------------------------------------------------------------------------------------------------
-- SETTINGS
-----------------------------------------------------------------------------------------------------------------------------------------
Inventory.Chest.Settings = {
    Personal = {Weight = 50, Slots = 25},
    Tray = {Weight = 25, Slots = 25},
    Recycle = {Name = "Recycle", Weight = 100},
    Custom = {Weight = 50, Slots = 25},
    Organization = {
        Weight = 5000,
        Slots = 500,
        LeaderLevel = 2,
        PersonalWeight = 100,
        PersonalSlots = 50
    },
    PremiumWeightMultiplier = 2,
    Upgrade = {Item = "diagram", Amount = 1, Weight = 10, Slots = 5},
    HelicrashCooldown = 600,
    HelicrashDamage = 10,
    Armour = 100,
    ArmourFallbackPermission = "Policia"
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMS
-----------------------------------------------------------------------------------------------------------------------------------------
Inventory.Chest.Items = {
    ["personalp"] = {Slots = 100, Weight = 100, Block = true},
    ["personalm"] = {Slots = 100, Weight = 250, Block = true},
    ["personalg"] = {Slots = 100, Weight = 500, Block = true},
    ["chestgroupp"] = {Slots = 100, Weight = 1000, Block = true},
    ["chestgroupm"] = {Slots = 100, Weight = 2500, Block = true},
    ["chestgroupg"] = {Slots = 100, Weight = 5000, Block = true},
    ["suitcase"] = {
        Slots = 25,
        Weight = 10,
        Close = true,
        Itens = {
            ["dollar"] = true,
            ["dirtydollar"] = true,
            ["wetdollar"] = true,
            ["promissory"] = true
        }
    },
    ["ammobox"] = {
        Slots = 25,
        Weight = 12,
        Close = true,
        Itens = {
            ["WEAPON_PISTOL_AMMO"] = true,
            ["WEAPON_SMG_AMMO"] = true,
            ["WEAPON_RIFLE_AMMO"] = true,
            ["WEAPON_SHOTGUN_AMMO"] = true,
            ["WEAPON_MUSKET_AMMO"] = true
        }
    },
    ["weaponbox"] = {
        Slots = 50,
        Weight = 100,
        Close = true,
        Itens = {
            ["WEAPON_STUNGUN"] = true,
            ["WEAPON_PISTOL"] = true,
            ["WEAPON_PISTOL_MK2"] = true,
            ["WEAPON_COMPACTRIFLE"] = true,
            ["WEAPON_APPISTOL"] = true,
            ["WEAPON_HEAVYPISTOL"] = true,
            ["WEAPON_MACHINEPISTOL"] = true,
            ["WEAPON_MICROSMG"] = true,
            ["WEAPON_RPG"] = true,
            ["WEAPON_MINISMG"] = true,
            ["WEAPON_SNSPISTOL"] = true,
            ["WEAPON_SNSPISTOL_MK2"] = true,
            ["WEAPON_VINTAGEPISTOL"] = true,
            ["WEAPON_PISTOL50"] = true,
            ["WEAPON_COMBATPISTOL"] = true,
            ["WEAPON_CARBINERIFLE"] = true,
            ["WEAPON_CARBINERIFLE_MK2"] = true,
            ["WEAPON_ADVANCEDRIFLE"] = true,
            ["WEAPON_BULLPUPRIFLE"] = true,
            ["WEAPON_BULLPUPRIFLE_MK2"] = true,
            ["WEAPON_SPECIALCARBINE"] = true,
            ["WEAPON_SPECIALCARBINE_MK2"] = true,
            ["WEAPON_PUMPSHOTGUN"] = true,
            ["WEAPON_PUMPSHOTGUN_MK2"] = true,
            ["WEAPON_MUSKET"] = true,
            ["WEAPON_SAWNOFFSHOTGUN"] = true,
            ["WEAPON_SMG"] = true,
            ["WEAPON_SMG_MK2"] = true,
            ["WEAPON_TACTICALRIFLE"] = true,
            ["WEAPON_HEAVYRIFLE"] = true,
            ["WEAPON_ASSAULTRIFLE"] = true,
            ["WEAPON_ASSAULTRIFLE_MK2"] = true,
            ["WEAPON_ASSAULTSMG"] = true,
            ["WEAPON_GUSENBERG"] = true
        }
    },
    ["medicbag"] = {
        Slots = 25,
        Weight = 10,
        Close = true,
        Itens = {
            ["bandage"] = true,
            ["gauze"] = true,
            ["gdtkit"] = true,
            ["medkit"] = true,
            ["sinkalmy"] = true,
            ["analgesic"] = true,
            ["ritmoneury"] = true,
            ["adrenaline"] = true
        }
    },
    ["treasurebox"] = {Slots = 25, Weight = 50, Close = true}
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- LUNCHBAG
-----------------------------------------------------------------------------------------------------------------------------------------
Inventory.Chest.Lunchbag = {
    Item = "lunchbag",
    Slots = 9,
    Weight = 8,
    Multiplier = 3,
    Title = "Sua lancheira",
    Description = "Alimentos aqui dentro estragam 3x mais devagar."
}
