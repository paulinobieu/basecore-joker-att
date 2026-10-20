Inventory.MoneyWash = Inventory.MoneyWash or {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- SETTINGS
-----------------------------------------------------------------------------------------------------------------------------------------
Inventory.MoneyWash.Settings = {
    InputItem = "wetdollar",
    RewardPrefix = "promissory",
    SwapReward = "dollar",
    Permission = "MoneyWash",
    Police = {
        Permission = "Policia",
        Name = "Lavagem de Dinheiro",
        Wanted = 60,
        Code = 31,
        Color = 22
    }
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMS
-----------------------------------------------------------------------------------------------------------------------------------------
Inventory.MoneyWash.Items = {
    promissory1000 = {
        Value = 1000,
        Percentage = 0.750,
        Permission = 0.950,
        Police = 875
    },
    promissory2000 = {
        Value = 2000,
        Percentage = 0.725,
        Permission = 0.925,
        Police = 775
    },
    promissory3000 = {
        Value = 3000,
        Percentage = 0.700,
        Permission = 0.900,
        Police = 675
    },
    promissory4000 = {
        Value = 4000,
        Percentage = 0.675,
        Permission = 0.875,
        Police = 575
    },
    promissory5000 = {
        Value = 5000,
        Percentage = 0.650,
        Permission = 0.850,
        Police = 475
    }
}
