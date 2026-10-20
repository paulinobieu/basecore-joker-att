-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
Crash = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THEME
-----------------------------------------------------------------------------------------------------------------------------------------
Crash.ThemeColor = "#dc1553"
-----------------------------------------------------------------------------------------------------------------------------------------
-- PERMISSION
-----------------------------------------------------------------------------------------------------------------------------------------
Crash.Permission = "Admin"
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMMANDS
-----------------------------------------------------------------------------------------------------------------------------------------
Crash.Commands = {
	Start = "crash",
	Random = "crashstart",
	Stop = "crashstop",
	End = "endcrash",
	Fast = "crashfast",
	Special = "specialcrash",
	Test = "testcrash",
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- TIMES
-----------------------------------------------------------------------------------------------------------------------------------------
Crash.Times = {
	Duration = 1200,
	SpawnCooldown = 420,
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETTINGS
-----------------------------------------------------------------------------------------------------------------------------------------
Crash.MinPlayers = 10
Crash.AreaSize = 280
Crash.SpawnDistance = 400
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHEST CONTRACT
-- O prefixo do container e as GlobalStates abaixo sao o contrato com o recurso chest:
-- chest bloqueia auto-loot, controla o "quente" e decrementa GlobalState.Helibox quando o container "Prefix:N" esvazia.
-----------------------------------------------------------------------------------------------------------------------------------------
Crash.ChestPrefix = "Helicrash"
-----------------------------------------------------------------------------------------------------------------------------------------
-- DEATH RESPAWN
-----------------------------------------------------------------------------------------------------------------------------------------
Crash.Respawn = {
	Enable = true,
	Timer = 5,
	Item = "adrenaline",
	Health = 200,
	Coords = { x = 2685.97, y = 3430.96, z = 58.99, h = 167.25 },
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- SCHEDULE
-- Horarios de auto-spawn (HH:MM). SpecialTime dispara o crash especial, os demais sorteiam um local aleatorio.
-----------------------------------------------------------------------------------------------------------------------------------------
Crash.SpecialTime = "21:00"
Crash.Schedule = {
	["00:00"] = true,
	["01:00"] = true,
	["02:00"] = true,
	["03:00"] = true,
	["04:00"] = true,
	["05:00"] = true,
	["06:00"] = true,
	["07:00"] = true,
	["08:00"] = true,
	["09:00"] = true,
	["10:00"] = true,
	["11:00"] = true,
	["12:00"] = true,
	["13:00"] = true,
	["14:00"] = true,
	["15:00"] = true,
	["16:00"] = true,
	["17:00"] = true,
	["18:00"] = true,
	["19:00"] = true,
	["20:00"] = true,
	["21:00"] = true,
	["22:00"] = true,
	["23:00"] = true,
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOGS
-- Webhooks opcionais do Discord. Vazio = sem envio. Os logs internos vao para core_logs automaticamente.
-----------------------------------------------------------------------------------------------------------------------------------------
Crash.Logs = {
	Started = "",
	Finished = "",
	CombatLog = "",
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISPLAY NAMES
-----------------------------------------------------------------------------------------------------------------------------------------
Crash.Names = {
	heli = "Helicóptero",
	truck = "Caminhão",
	stock = "Carro Forte",
	stockade = "Carro Forte (Especial)",
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- ANNOUNCE MESSAGES
-----------------------------------------------------------------------------------------------------------------------------------------
Crash.Messages = {
	heli = "Mayday! Mayday! Tivemos problemas técnicos em nossos motores e estamos em queda livre.",
	truck = "Alerta! Um caminhão militar acabou de tombar e está em chamas.",
	stock = "Alerta! Um carro forte acabou de capotar e está em chamas.",
	stockade = "Alerta crítico! Um carro forte foi atacado e está em chamas. Recompensas dobradas.",
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROPS
-----------------------------------------------------------------------------------------------------------------------------------------
Crash.Props = {
	heli = { Vehicle = "snt_crash_helicopter", Chest = "prop_mil_crate_01" },
	truck = { Vehicle = "snt_crash_barracks", Chest = "xm3_prop_xm3_crate_01a" },
	stock = { Vehicle = "snt_crash_stockade", Chest = "xm3_prop_xm3_bag_01a" },
	stockade = { Vehicle = "snt_crash_stockade", Chest = "xm3_prop_xm3_bag_01a" },
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPECIAL CRASH
-----------------------------------------------------------------------------------------------------------------------------------------
Crash.Special = {
	Type = "stockade",
	LootMultiplier = 2,
	Bonus = { item = "gemstone", amount = 10 },
	Vehicle = { x = -677.77, y = -225.69, z = 36.93, h = 65.2 },
	Chests = {
		{ x = -671.89, y = -233.73, z = 36.85, h = 348.67, prop = "xm3_prop_xm3_bag_01a" },
		{ x = -668.58, y = -231.38, z = 37.02, h = 311.82, prop = "xm3_prop_xm3_bag_01a" },
		{ x = -669.33, y = -228.51, z = 37.1, h = 25.52, prop = "ex_prop_crate_jewels_racks_bc" },
		{ x = -667.31, y = -224.17, z = 37.27, h = 351.5, prop = "xm3_prop_xm3_bag_01a" },
		{ x = -670.41, y = -222.46, z = 37.22, h = 65.2, prop = "xm3_prop_xm3_bag_01a" },
	},
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOCATIONS
-----------------------------------------------------------------------------------------------------------------------------------------
Crash.Locations = {
	[1] = {
		Vehicle = { x = -2769.57, y = 2495.86, z = 2.68, h = 187.09 },
		Chests = {
			{ x = -2769.03, y = 2514.23, z = 2.71, h = 354.34 },
			{ x = -2752.0, y = 2493.97, z = 1.7, h = 85.04 },
			{ x = -2788.23, y = 2494.13, z = 2.61, h = 93.55 },
		},
	},
	[2] = {
		Vehicle = { x = 478.63, y = -3369.98, z = 6.07, h = 93.55 },
		Chests = {
			{ x = 469.92, y = -3370.25, z = 6.07, h = 277.8 },
			{ x = 478.88, y = -3359.05, z = 6.07, h = 184.26 },
			{ x = 489.38, y = -3370.15, z = 6.07, h = 93.55 },
		},
	},
	[3] = {
		Vehicle = { x = 1449.58, y = -2384.43, z = 66.86, h = 0.0 },
		Chests = {
			{ x = 1433.66, y = -2384.01, z = 67.03, h = 87.88 },
			{ x = 1465.44, y = -2383.09, z = 68.49, h = 93.55 },
			{ x = 1453.19, y = -2411.39, z = 66.93, h = 357.17 },
		},
	},
	[4] = {
		Vehicle = { x = -1284.97, y = -2195.92, z = 13.93, h = 243.78 },
		Chests = {
			{ x = -1275.09, y = -2182.97, z = 13.93, h = 331.66 },
			{ x = -1268.07, y = -2207.47, z = 13.93, h = 238.12 },
			{ x = -1311.15, y = -2183.68, z = 13.93, h = 68.04 },
		},
	},
	[5] = {
		Vehicle = { x = 1060.32, y = 2362.25, z = 44.33, h = 272.13 },
		Chests = {
			{ x = 1083.93, y = 2362.33, z = 44.65, h = 272.13 },
			{ x = 1059.93, y = 2349.21, z = 46.02, h = 0.0 },
			{ x = 1036.7, y = 2363.57, z = 48.11, h = 274.97 },
		},
	},
	[6] = {
		Vehicle = { x = 3792.77, y = 4511.44, z = 6.99, h = 294.81 },
		Chests = {
			{ x = 3806.91, y = 4517.71, z = 4.92, h = 124.73 },
			{ x = 3791.77, y = 4529.28, z = 5.37, h = 17.01 },
			{ x = 3779.37, y = 4495.81, z = 6.52, h = 147.41 },
		},
	},
	[7] = {
		Vehicle = { x = -1121.92, y = 4927.13, z = 218.68, h = 76.54 },
		Chests = {
			{ x = -1124.75, y = 4942.59, z = 219.52, h = 189.93 },
			{ x = -1139.7, y = 4923.84, z = 220.24, h = 280.63 },
			{ x = -1097.82, y = 4925.49, z = 216.2, h = 164.41 },
		},
	},
	[8] = {
		Vehicle = { x = -2328.97, y = 3045.96, z = 32.81, h = 56.7 },
		Chests = {
			{ x = -2320.4, y = 3061.05, z = 32.81, h = 150.24 },
			{ x = -2339.45, y = 3028.36, z = 32.81, h = 328.82 },
			{ x = -2352.61, y = 3058.25, z = 32.82, h = 243.78 },
		},
	},
	[9] = {
		Vehicle = { x = 2403.21, y = 3106.28, z = 48.24, h = 260.79 },
		Chests = {
			{ x = 2421.1, y = 3103.81, z = 48.16, h = 82.21 },
			{ x = 2388.03, y = 3089.31, z = 48.17, h = 334.49 },
			{ x = 2407.1, y = 3125.81, z = 48.16, h = 161.58 },
		},
	},
	[10] = {
		Vehicle = { x = -325.89, y = 2721.74, z = 68.97, h = 328.82 },
		Chests = {
			{ x = -315.62, y = 2737.9, z = 68.07, h = 150.24 },
			{ x = -312.23, y = 2705.98, z = 67.4, h = 51.03 },
			{ x = -345.5, y = 2728.48, z = 66.94, h = 269.3 },
		},
	},
	[11] = {
		Vehicle = { x = 2548.99, y = -384.29, z = 92.99, h = 93.55 },
		Chests = {
			{ x = 2533.07, y = -384.15, z = 92.99, h = 272.13 },
			{ x = 2551.86, y = -369.78, z = 92.99, h = 170.08 },
			{ x = 2566.28, y = -384.36, z = 92.99, h = 87.88 },
		},
	},
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOOT TABLES
-- Cada bau sorteia uma destas tabelas. amount e o valor base (dobrado no crash especial).
-----------------------------------------------------------------------------------------------------------------------------------------
Crash.LootTables = {
	{
		{ item = "dirtydollar", amount = 10000 },
		{ item = "vest", amount = 5 },
		{ item = "energetic", amount = 15 },
		{ item = "c4", amount = 8 },
		{ item = "BOX_WEAPON_COMPACTRIFLE", amount = 1 },
		{ item = "BOX_WEAPON_PISTOL_MK2", amount = 1 },
		{ item = "caixarifleammo", amount = 2 },
		{ item = "caixapistolammo", amount = 2 },
	},
	{
		{ item = "dirtydollar", amount = 12000 },
		{ item = "vest", amount = 5 },
		{ item = "energetic", amount = 15 },
		{ item = "c4", amount = 8 },
		{ item = "BOX_WEAPON_SPECIALCARBINE", amount = 1 },
		{ item = "BOX_WEAPON_SNSPISTOL_MK2", amount = 1 },
		{ item = "caixarifleammo", amount = 3 },
		{ item = "caixasubammo", amount = 2 },
	},
	{
		{ item = "dirtydollar", amount = 11000 },
		{ item = "vest", amount = 5 },
		{ item = "energetic", amount = 15 },
		{ item = "c4", amount = 8 },
		{ item = "BOX_WEAPON_SPECIALCARBINE_MK2", amount = 1 },
		{ item = "BOX_WEAPON_MACHINEPISTOL", amount = 1 },
		{ item = "caixarifleammo", amount = 2 },
		{ item = "caixasubammo", amount = 3 },
	},
	{
		{ item = "dirtydollar", amount = 13000 },
		{ item = "vest", amount = 5 },
		{ item = "energetic", amount = 20 },
		{ item = "c4", amount = 10 },
		{ item = "BOX_WEAPON_COMPACTRIFLE", amount = 1 },
		{ item = "BOX_WEAPON_SMG_MK2", amount = 1 },
		{ item = "caixarifleammo", amount = 3 },
		{ item = "caixasubammo", amount = 2 },
	},
	{
		{ item = "dirtydollar", amount = 10000 },
		{ item = "vest", amount = 5 },
		{ item = "energetic", amount = 15 },
		{ item = "c4", amount = 8 },
		{ item = "BOX_WEAPON_SPECIALCARBINE", amount = 1 },
		{ item = "BOX_WEAPON_PISTOL_MK2", amount = 1 },
		{ item = "caixarifleammo", amount = 2 },
		{ item = "caixapistolammo", amount = 2 },
	},
	{
		{ item = "dirtydollar", amount = 11500 },
		{ item = "vest", amount = 5 },
		{ item = "energetic", amount = 15 },
		{ item = "c4", amount = 8 },
		{ item = "BOX_WEAPON_SPECIALCARBINE_MK2", amount = 1 },
		{ item = "BOX_WEAPON_SNSPISTOL_MK2", amount = 1 },
		{ item = "caixarifleammo", amount = 3 },
		{ item = "caixapistolammo", amount = 2 },
	},
	{
		{ item = "dirtydollar", amount = 9000 },
		{ item = "backpackm", amount = 3 },
		{ item = "radio", amount = 3 },
		{ item = "BOX_WEAPON_COMPACTRIFLE", amount = 1 },
		{ item = "BOX_WEAPON_PISTOL_MK2", amount = 1 },
		{ item = "vest", amount = 5 },
		{ item = "caixarifleammo", amount = 2 },
		{ item = "caixapistolammo", amount = 2 },
	},
	{
		{ item = "dirtydollar", amount = 9500 },
		{ item = "backpackm", amount = 3 },
		{ item = "radio", amount = 3 },
		{ item = "BOX_WEAPON_SPECIALCARBINE", amount = 1 },
		{ item = "BOX_WEAPON_SMG_MK2", amount = 1 },
		{ item = "vest", amount = 5 },
		{ item = "caixarifleammo", amount = 3 },
		{ item = "caixasubammo", amount = 2 },
	},
	{
		{ item = "dirtydollar", amount = 10000 },
		{ item = "backpackm", amount = 3 },
		{ item = "radio", amount = 3 },
		{ item = "BOX_WEAPON_SPECIALCARBINE_MK2", amount = 1 },
		{ item = "BOX_WEAPON_MACHINEPISTOL", amount = 1 },
		{ item = "vest", amount = 5 },
		{ item = "caixarifleammo", amount = 2 },
		{ item = "caixasubammo", amount = 3 },
	},
	{
		{ item = "dirtydollar", amount = 8500 },
		{ item = "lockpick", amount = 5 },
		{ item = "radio", amount = 3 },
		{ item = "BOX_WEAPON_COMPACTRIFLE", amount = 1 },
		{ item = "BOX_WEAPON_PISTOL_MK2", amount = 1 },
		{ item = "vest", amount = 5 },
		{ item = "caixarifleammo", amount = 2 },
		{ item = "caixapistolammo", amount = 2 },
	},
	{
		{ item = "dirtydollar", amount = 11000 },
		{ item = "backpackm", amount = 3 },
		{ item = "radio", amount = 3 },
		{ item = "BOX_WEAPON_SPECIALCARBINE", amount = 1 },
		{ item = "BOX_WEAPON_SNSPISTOL_MK2", amount = 1 },
		{ item = "vest", amount = 5 },
		{ item = "caixarifleammo", amount = 3 },
		{ item = "caixapistolammo", amount = 2 },
	},
	{
		{ item = "dirtydollar", amount = 12500 },
		{ item = "energetic", amount = 20 },
		{ item = "c4", amount = 10 },
		{ item = "BOX_WEAPON_SPECIALCARBINE_MK2", amount = 1 },
		{ item = "BOX_WEAPON_SMG_MK2", amount = 1 },
		{ item = "vest", amount = 5 },
		{ item = "caixarifleammo", amount = 3 },
		{ item = "caixasubammo", amount = 3 },
	},
	{
		{ item = "dirtydollar", amount = 10500 },
		{ item = "backpackm", amount = 3 },
		{ item = "energetic", amount = 15 },
		{ item = "BOX_WEAPON_COMPACTRIFLE", amount = 1 },
		{ item = "BOX_WEAPON_ASSAULTSMG", amount = 1 },
		{ item = "vest", amount = 5 },
		{ item = "caixarifleammo", amount = 2 },
		{ item = "caixasubammo", amount = 3 },
	},
}
