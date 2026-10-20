-----------------------------------------------------------------------------------------------------------------------------------------
-- ACTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
Inventory.Actions = {
    ChangePlate = {Item = "plate", Amount = 1, Duration = 10},
    StealTrunk = {
        Weapon = "WEAPON_CROWBAR",
        Task = {Amount = 5, Time = 5000},
        Duration = 15,
        Cooldown = 3600,
        Multiplier = 2,
        Residual = "Resíduo de Ferro",
        Money = {Item = "dirtydollar", Amount = 100},
        Police = {
            Permission = "Policia",
            Name = "Roubo de Veículo",
            Percentage = 925,
            Wanted = 60,
            Code = 31,
            Color = 44
        }
    },
    Hunting = {
        Weapon = "WEAPON_SWITCHBLADE",
        Duration = 30,
        Experience = "Hunting",
        ExperienceAmount = 1,
        Stars = 3,
        MeatItem = "meatfillet",
        WeightItem = "deer1star"
    },
    ProductsPolice = {
        Permission = "Policia",
        Name = "Roubo de Pertences",
        Wanted = 60,
        Code = 31,
        Color = 22,
        Task = {Amount = 5, Time = 5000}
    },
    Tyres = {
        Weapon = "WEAPON_WRENCH",
        Item = "tyres",
        Duration = 10,
        Task = {Amount = 5, Time = 5000}
    },
    RollVehicle = {Duration = 60},
    Buffs = {MaximumDuration = 3600, LuckChance = 51},
    StealPeds = {
        PoliceChance = 26,
        Police = {
            Permission = "Policia",
            Name = "Assalto a mão armada",
            Wanted = 60,
            Code = 32,
            Color = 16
        }
    },
    Shots = {
        Permission = "Policia",
        VehicleName = "Disparos de um veículo",
        WeaponName = "Disparos com arma de fogo",
        Code = 10,
        Color = 6
    },
    Drink = {Duration = 10, Thirst = 10},
    RefillGallon = {
        Duration = 30,
        Input = "emptypurifiedwater",
        Output = "purifiedwater"
    },
    RefillBottle = {Duration = 5, Input = "emptybottle", Output = "water"}
}
