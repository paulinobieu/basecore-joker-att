Inventory.Drugs = Inventory.Drugs or {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- SETTINGS
-----------------------------------------------------------------------------------------------------------------------------------------
Inventory.Drugs.Settings = {
    Experience = "Traffic",
    BaseExperience = 2,
    LevelMultiplier = 0.05,
    Buff = "Dexterity",
    BuffMultiplier = 0.1,
    Membership = {Ouro = 0.1, Prata = 0.075, Bronze = 0.05},
    MembershipExperience = 1,
    SprayMultiplier = 0.25,
    SprayExperience = 1,
    RewardItem = "dirtydollar",
    Residual = "Resíduo de Orgânicos",
    Stress = 1,
    Police = {
        Permission = "Policia",
        Name = "Venda de Drogas",
        Wanted = 60,
        Code = 20,
        Color = 16
    }
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- PRODUCTS
-----------------------------------------------------------------------------------------------------------------------------------------
Inventory.Drugs.Products = {
    skunksell = {
        Timer = 6,
        Percentage = 725,
        Price = {Min = 350, Max = 450},
        Amount = {Min = 1, Max = 1}
    },
    lolosell = {
        Timer = 6,
        Percentage = 725,
        Price = {Min = 300, Max = 400},
        Amount = {Min = 1, Max = 1}
    },
    exatasysell = {
        Timer = 6,
        Percentage = 725,
        Price = {Min = 450, Max = 550},
        Amount = {Min = 1, Max = 1}
    },
    mdmasell = {
        Timer = 6,
        Percentage = 725,
        Price = {Min = 500, Max = 600},
        Amount = {Min = 1, Max = 1}
    },
    lsdsell = {
        Timer = 6,
        Percentage = 725,
        Price = {Min = 550, Max = 675},
        Amount = {Min = 1, Max = 1}
    },
    ketaminasell = {
        Timer = 6,
        Percentage = 725,
        Price = {Min = 600, Max = 725},
        Amount = {Min = 1, Max = 1}
    },
    metasell = {
        Timer = 6,
        Percentage = 775,
        Price = {Min = 600, Max = 750},
        Amount = {Min = 1, Max = 1}
    },
    cocainasell = {
        Timer = 6,
        Percentage = 775,
        Price = {Min = 650, Max = 800},
        Amount = {Min = 1, Max = 1}
    },
    ayahuascasell = {
        Timer = 6,
        Percentage = 775,
        Price = {Min = 700, Max = 850},
        Amount = {Min = 1, Max = 1}
    },
    heroinasell = {
        Timer = 6,
        Percentage = 775,
        Price = {Min = 750, Max = 900},
        Amount = {Min = 1, Max = 1}
    }
}
