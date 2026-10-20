Inventory.Chest = Inventory.Chest or {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- TARGET
-----------------------------------------------------------------------------------------------------------------------------------------
Inventory.Chest.Target = {
    Distance = 1.25,
    MinimumDistance = 0.5,
    MaximumDistance = 10.0,
    ServerTolerance = 1.5
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- LOCATIONS
-----------------------------------------------------------------------------------------------------------------------------------------
Inventory.Chest.Locations = {
    -------------------------------------------------------------------------------------------------------------------------------------
    -- POLICE
    -------------------------------------------------------------------------------------------------------------------------------------
    {Name = "Policia", Coords = vec3(460.75, -996.82, 30.16), Mode = "1"},
    {Name = "Policia", Coords = vec3(2541.04, -287.19, 93.38), Mode = "1"},
    {Name = "Policia", Coords = vec3(-992.86, -2009.86, 13.43), Mode = "1"},
    {Name = "Policia", Coords = vec3(-1663.71, 167.85, 62.39), Mode = "1"},
    -------------------------------------------------------------------------------------------------------------------------------------
    -- SERVICES
    -------------------------------------------------------------------------------------------------------------------------------------
    {Name = "HospitalNorte", Coords = vec3(1743.67, 3622.31, 34.57), Mode = "2"},
    {Name = "HospitalSul", Coords = vec3(-1035.59, -427.41, 45.64), Mode = "2"},
    {Name = "Bennys", Coords = vec3(-243.90, -1361.22, 39.82), Mode = "2"},
    {Name = "Restaurante", Coords = vec3(-631.68, 228.32, 82.17), Mode = "2"},
    {Name = "SodaPop", Coords = vec3(-1378.43, -1400.88, 6.13), Mode = "2"},
    {Name = "MooMoo", Coords = vec3(-588.07, -1054.07, 22.27), Mode = "2"},
    {Name = "OsakaSushi", Coords = vec3(-791.98, -158.39, 38.11), Mode = "2"},
    {Name = "MarinaLounge", Coords = vec3(1539.74, 3790.69, 34.57), Mode = "2"},
    {Name = "KittyCafe", Coords = vec3(1139.86, -786.82, 58.04), Mode = "2"},
    {Name = "Lester", Coords = vec3(1275.21, -1712.12, 54.64), Mode = "2"},
    -------------------------------------------------------------------------------------------------------------------------------------
    -- ORGANIZATIONS
    -------------------------------------------------------------------------------------------------------------------------------------
    {Name = "Municao1", Coords = vec3(387.92, -10.01, 86.70), Mode = "4"},
    {Name = "Municao2", Coords = vec3(1470.96, 1104.39, 119.53), Mode = "4"},
    {Name = "Municao3", Coords = vec3(812.16, -2927.04, 1.74), Mode = "4"},
    {Name = "Municao4", Coords = vec3(-1808.18, 482.51, 108.86), Mode = "4"},
    {Name = "Arma1", Coords = vec3(-3692.92, 3796.92, 5.31), Mode = "4"},
    {Name = "Arma2", Coords = vec3(-1905.39, 2057.43, 135.93), Mode = "4"},
    {Name = "Arma3", Coords = vec3(-1560.11, 85.57, 53.62), Mode = "4"},
    {Name = "Arma4", Coords = vec3(-1581.45, 820.51, 176.95), Mode = "4"},
    {Name = "Arma5", Coords = vec3(-2283.04, -690.17, 20.28), Mode = "4"},
    {Name = "Contrabando1", Coords = vec3(-705.99, 2699.23, 54.39), Mode = "4"},
    {Name = "Contrabando2", Coords = vec3(-2940.82, 36.22, 11.74), Mode = "4"},
    {Name = "Contrabando3", Coords = vec3(-2090.09, -347.42, 6.47), Mode = "4"},
    {Name = "Contrabando4", Coords = vec3(-316.48, 6134.34, 14.61), Mode = "4"},
    {Name = "Lavagem1", Coords = vec3(369.40, 215.31, 107.90), Mode = "4"},
    {Name = "Lavagem2", Coords = vec3(-1.53, 255.09, 101.77), Mode = "4"},
    {Name = "Lavagem3", Coords = vec3(-676.68, -694.73, 30.64), Mode = "4"},
    {Name = "Lavagem4", Coords = vec3(-294.23, 6267.52, 35.09), Mode = "4"},
    {Name = "Desmanche1", Coords = vec3(1985.75, 3017.25, 52.27), Mode = "4"},
    {Name = "Desmanche2", Coords = vec3(1192.76, -3285.03, 5.92), Mode = "4"},
    {Name = "Desmanche3", Coords = vec3(-2773.44, 1444.74, 96.69), Mode = "4"},
    {Name = "Desmanche4", Coords = vec3(-335.23, -155.44, 39.53), Mode = "4"},
    {Name = "Metafetamina1", Coords = vec3(1186.04, -17.00, 82.06), Mode = "4"},
    {
        Name = "Metafetamina2",
        Coords = vec3(-443.15, 1621.79, 361.18),
        Mode = "4"
    },
    {Name = "Skunk1", Coords = vec3(1304.71, -798.08, 85.18), Mode = "4"},
    {Name = "Skunk2", Coords = vec3(-2193.77, 873.90, 230.04), Mode = "4"},
    {Name = "Cocaina1", Coords = vec3(1571.07, -1321.15, 94.71), Mode = "4"},
    {Name = "Cocaina2", Coords = vec3(-2481.67, -123.01, 55.32), Mode = "4"},
    {Name = "Ecstasy1", Coords = vec3(-774.62, 1167.63, 280.80), Mode = "4"},
    {Name = "Ecstasy2", Coords = vec3(2694.47, 1920.39, 54.71), Mode = "4"},
    {Name = "Heroina1", Coords = vec3(-1209.67, 2446.90, 74.90), Mode = "4"},
    {Name = "Heroina2", Coords = vec3(-1344.48, 1472.12, 165.41), Mode = "4"}
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- MODES
-----------------------------------------------------------------------------------------------------------------------------------------
Inventory.Chest.Modes = {
    ["1"] = {
        {
            event = "chest:Open",
            label = "Compartimento Geral",
            tunnel = "client",
            service = "Normal"
        },
        {
            event = "chest:Open",
            label = "Compartimento Pessoal",
            tunnel = "client",
            service = "Personal"
        },
        {event = "chest:Armour", label = "Colete Balistico", tunnel = "server"}
    },
    ["2"] = {
        {
            event = "chest:Open",
            label = "Abrir",
            tunnel = "client",
            service = "Normal"
        }
    },
    ["3"] = {
        {
            event = "chest:Open",
            label = "Abrir",
            tunnel = "client",
            service = "Tray"
        }
    },
    ["4"] = {
        {
            event = "chest:Open",
            label = "Compartimento do Lider",
            tunnel = "client",
            service = "Leader"
        },
        {
            event = "chest:Open",
            label = "Compartimento de Membro",
            tunnel = "client",
            service = "Member"
        },
        {
            event = "chest:Open",
            label = "Compartimento Pessoal",
            tunnel = "client",
            service = "PersonalGroup"
        }
    }
}
