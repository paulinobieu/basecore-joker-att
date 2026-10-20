-----------------------------------------------------------------------------------------------------------------------------------------
-- SETTINGS
-----------------------------------------------------------------------------------------------------------------------------------------
Inventory.Robbery.Settings = {
    DefaultDelay = 3600,
    DefaultTimer = 30,
    DefaultWanted = 60,
    DefaultResidual = "Resquício de Línter",
    ReuseWindow = 300,
    PartySize = 2,
    PartyMultiplier = 1.1,
    Buff = "Dexterity",
    BuffMultiplier = 1.1,
    Membership = {Ouro = 0.1, Prata = 0.075, Bronze = 0.05},
    Police = {Permission = "Policia", Code = 31, Color = 22}
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- MODES
-----------------------------------------------------------------------------------------------------------------------------------------
Inventory.Robbery.Modes = {
    Register = {
        Timer = 15,
        Scope = "point",
        Percentage = 750,
        Name = "Roubo a Registradora",
        Payment = {
            Multiplier = {Min = 1, Max = 2},
            Money = {Item = "dirtydollar", Min = 325, Max = 375},
            List = {
                {Item = "water", Chance = 100, Min = 1, Max = 2},
                {Item = "bandage", Chance = 100, Min = 1, Max = 2},
                {Item = "weedclone_0", Chance = 100, Min = 1, Max = 2}
            }
        },
        Animation = {Dict = "oddjobs@shop_robbery@rob_till", Name = "loop"}
    },
    Container = {
        Wanted = 120,
        Scope = "point",
        Percentage = 750,
        Name = "Roubo a Container",
        Payment = {
            Multiplier = {Min = 1, Max = 2},
            Money = {Item = "dirtydollar", Min = 325, Max = 375},
            List = {
                {Item = "water", Chance = 100, Min = 1, Max = 2},
                {Item = "bandage", Chance = 100, Min = 1, Max = 2},
                {Item = "weedclone_0", Chance = 100, Min = 1, Max = 2}
            }
        },
        Animation = {Dict = "oddjobs@shop_robbery@rob_till", Name = "loop"}
    },
    Ammunation = {
        Timer = 30,
        Wanted = 180,
        Scope = "point",
        Percentage = 900,
        Name = "Roubo a Loja de Armas",
        Payment = {
            Multiplier = {Min = 1, Max = 2},
            Money = {Item = "dirtydollar", Min = 500, Max = 650},
            List = {
                {Item = "WEAPON_PISTOL_AMMO", Chance = 100, Min = 1, Max = 2},
                {Item = "bandage", Chance = 100, Min = 1, Max = 2}
            }
        },
        Animation = {Dict = "oddjobs@shop_robbery@rob_till", Name = "loop"}
    },
    Eletronic = {
        Police = 5,
        Delay = 300,
        Wanted = 600,
        Scope = "point",
        Explosion = true,
        Name = "Caixa Eletrônico",
        Need = {Amount = 1, Item = "c4", Consume = true},
        Payment = {Money = {Item = "dirtydollar", Min = 325, Max = 375}}
    }
}
