-----------------------------------------------------------------------------------------------------------------------------------------
-- ASSAULT
-- Assault        : ativa/desativa o modo de assalto
-- AssaultRegion  : "North" (Y > 1500) | "South" (Y < 1500) | "All" (mapa inteiro)
-- AssaultInitTime: hora de início (0-23)
-- AssaultEndTime : hora de fim (0-23) — suporta virada de meia-noite (ex: 22 → 06)
-----------------------------------------------------------------------------------------------------------------------------------------
Assault = true
AssaultRegion  = "North"    -- "North" | "South" | "All"
AssaultInitTime = 22
AssaultEndTime  = 6
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
MaxRepair = 1
MinimumWeight = 30
MaximumWeight = 150
BackpackWeight = 30
MinimumSlots = 9
MaximumSlots = 45
BackpackSlots = 9
BackpackItem = "backpackm"
PrisonCoords = vec3(1896.15,2604.44,45.75)
CreatorCoords = vec4(280.37,-409.95,28.05,0.0)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BANNED
-----------------------------------------------------------------------------------------------------------------------------------------
Banned = {
	Mute = true,
	Route = 9999998,
	Leave = vec3(242.71,-392.01,46.30)
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- SERVERINFO
-----------------------------------------------------------------------------------------------------------------------------------------
Currency = "R$"
SalaryCooldown = 1800
DiscordBot = true
BaseMode = "steam"
Whitelisted = true
Liberation = "Token"
DisconnectReason = 30
NameDefault = "Indivíduo Indigente"
-----------------------------------------------------------------------------------------------------------------------------------------
-- SERVER
-----------------------------------------------------------------------------------------------------------------------------------------
ServerName = "Core"
ServerLink = "https://discord.gg/corenetworkdev"
ServerAvatar = "https://cdn.corenetwork.dev/IDCore/HUD_GIF.gif"
-----------------------------------------------------------------------------------------------------------------------------------------
-- ASSETS
-- ItemsURL: CDN base usada por todos os recursos para resolver imagens de itens
-- (sempre com barra final). Substitui o antigo `nui://vrp/config/inventory/`.
-----------------------------------------------------------------------------------------------------------------------------------------
ItemsURL = "https://cdn.corenetwork.dev/Itens/"
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOOT
-- Ativa/desativa as caixas de loot espalhadas pelo mapa (LootMedics, LootWeapons, LootSupplies, LootLegendary).
-- Marcar como false impede que o server registre as coords correspondentes em Default e remove blips/target no client.
-----------------------------------------------------------------------------------------------------------------------------------------
Loot = {
	Medics = false,
	Weapons = false,
	Supplies = false,
	Legendary = false
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- MAINTENANCE
-----------------------------------------------------------------------------------------------------------------------------------------
Maintenance = false
WantedSystem = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEAPONBACK
-----------------------------------------------------------------------------------------------------------------------------------------
WeaponBack = false
--{
--	["11000010c6d36de"] = true
--}
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPAWNCOORDS
-----------------------------------------------------------------------------------------------------------------------------------------
SpawnCoords = {
	vec3(-1039.89,-2740.74,13.88)
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- NPCSYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
NPCSystem = {
	DefaultVehicleDensity = 0.1, -- Quantidade de veículos NPCs nas ruas (0.0 = nenhum, 1.0 = máximo)
	DefaultPedDensity = 1.0, -- Quantidade de pedestres NPCs nas ruas (0.0 = nenhum, 1.0 = máximo)
	SpawnVehicles = false, -- Spawnar veículos NPCs estacionados nas ruas
	SpawnTrains = true, -- Spawnar trens no mapa
	SpawnBoats = true, -- Spawnar barcos NPCs na água
	SpawnGarbageTrucks = false, -- Spawnar caminhões de lixo NPCs
	SpawnPoliceVehicles = false, -- Spawnar viaturas policiais NPCs
	AllowArmedPeds = true, -- Permite que NPCs andem armados
	DropWeaponsOnDeath = false, -- NPCs dropam armas ao morrer
	PoliceVehicleWeapons = false, -- Permite armas nos porta-malas de veículos policiais
	GangInteractions = true, -- Gangues NPCs reagem ao jogador
	PedInteractions = true, -- Pedestres NPCs reagem ao jogador
	AllNPCInteractions = true, -- Ativa todas as interações de NPCs com o jogador
	DispatchServices = false, -- Ativa os serviços de emergência automáticos
	VehicleDistantLights = true, -- Mostra luzes de veículos à distância
	AreaOverrides = {
		{ x = 195.24, y = -937.37, z = 29.42, radius = 150, pedDensity = 0.0, vehicleDensity = 0.0 }, -- Praça
		{ x = -1634.47, y = -901.74, z = 9.08, radius = 75, pedDensity = 0.0, vehicleDensity = 0.0 }, -- Hospital
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- TEXTUREPACK
-----------------------------------------------------------------------------------------------------------------------------------------
TexturePack = {
	{ Width = 19, Height = 20, Image = "E" },
	{ Width = 19, Height = 20, Image = "H" },
	{ Width = 72, Height = 72, Image = "Drop" },
	{ Width = 43, Height = 67, Image = "Races" },
	{ Width = 72, Height = 72, Image = "Normal" },
	{ Width = 102, Height = 20, Image = "EPress" },
	{ Width = 102, Height = 20, Image = "HPress" },
	{ Width = 72, Height = 72, Image = "Selected" },
	{ Width = 72, Height = 72, Image = "Marker" }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- GROUPS
-----------------------------------------------------------------------------------------------------------------------------------------
Groups = {
	Admin = {
		Permission = {
			Admin = true
		},
		Hierarchy = { "C-Level", "Diretor", "Supervisor", "Administrador", "Moderador", "Suporte" },
		Name = "Administradores",
		Service = true,
		ServiceGated = true,
		Chat = true,
		Max = 30,
		ChatIcon       = "fa-solid fa-crown",
		ChatBackground = "#dc1553",
		ChatLetter     = "#ffffff",
	},
	Ouro = {
		Permission = {
			Ouro = true
		},
		Hierarchy = { "Membro" },
		Salary = { 3750 },
		Backpack = { 25 },
		Service = true,
		Block = true
	},
	Prata = {
		Permission = {
			Prata = true
		},
		Hierarchy = { "Membro" },
		Salary = { 2500 },
		Backpack = { 15 },
		Service = true,
		Block = true
	},
	Bronze = {
		Permission = {
			Bronze = true
		},
		Hierarchy = { "Membro" },
		Salary = { 1250 },
		Backpack = { 5 },
		Service = true,
		Block = true
	},
	PTFX = {
		Permission = {
			PTFX = true
		},
		Hierarchy = { "Membro" },
		Service = true,
		Block = true
	},
	Militar = {
		Permission = {
			Militar = true
		},
		Hierarchy = { "Coronel","Tenente-Coronel","Major","Capitão","Tenente","Subtenente","Sargento","Cabo","Soldado","Aluno" },
		Salary = { 10000,9500,9000,8500,8000,7500,7000,6500,6000 },
		Name = "Polícia Militar",
		SecurityCam = true,
		Service = false,
		Type = "Work",
		Markers = 25,
		Banned = true,
		Chat = true,
		ChatIcon       = "fa-solid fa-star",
		ChatBackground = "#3a4a2f",
		ChatLetter     = "#ffffff",
	},
	Civil = {
		Permission = {
			Civil = true
		},
		Hierarchy = { "Delegado-Geral","Delegado","Investigador","Escrivão","Perito","Agente" },
		Salary = { 10000,9400,8800,8200,7600,7000 },
		Name = "Polícia Civil",
		SecurityCam = true,
		Service = false,
		Type = "Work",
		Markers = 38,
		Banned = true,
		Chat = true,
		ChatIcon       = "fa-solid fa-id-badge",
		ChatBackground = "#1f3a5f",
		ChatLetter     = "#ffffff",
	},
	CORE = {
		Permission = {
			CORE = true
		},
		Hierarchy = { "Coordenador","Delegado","Inspetor","Investigador","Operador" },
		Salary = { 10000,9250,8500,7750,7000 },
		Name = "Coordenadoria de Recursos Especiais",
		SecurityCam = true,
		Service = false,
		Type = "Work",
		Markers = 1,
		Banned = true,
		Chat = true,
		ChatIcon       = "fa-solid fa-skull",
		ChatBackground = "#1a1a1a",
		ChatLetter     = "#ffffff",
	},
	BOPE = {
		Permission = {
			BOPE = true
		},
		Hierarchy = { "Comandante","Major","Capitão","Tenente","Sargento","Cabo","Soldado" },
		Salary = { 10000,9500,9000,8500,8000,7500,7000 },
		Name = "Batalhão de Operações Policiais Especiais",
		SecurityCam = true,
		Service = false,
		Type = "Work",
		Markers = 40,
		Banned = true,
		Chat = true,
		ChatIcon       = "fa-solid fa-skull-crossbones",
		ChatBackground = "#111111",
		ChatLetter     = "#ffffff",
	},
	PRF = {
		Permission = {
			PRF = true
		},
		Hierarchy = { "Superintendente","Inspetor","Agente Especial","Agente" },
		Salary = { 10000,9000,8000,7000 },
		Name = "Polícia Rodoviária Federal",
		SecurityCam = true,
		Service = false,
		Type = "Work",
		Markers = 5,
		Banned = true,
		Chat = true,
		ChatIcon       = "fa-solid fa-road",
		ChatBackground = "#1c1c1c",
		ChatLetter     = "#ffffff",
	},
	HospitalNorte = {
		Permission = {
			HospitalNorte = true
		},
		Hierarchy = { "Diretor-Geral","Diretor Clínico","Diretor Técnico","Chefe de Corpo Clínico","Médico Supervisor","Médico Cirurgião","Médico Plantonista","Médico Especialista","Médico Clínico","Residente","Enfermeiro","Técnico de Enfermagem","Auxiliar de Enfermagem","Estagiário de Medicina","Estagiário de Enfermagem" },
		Salary = { 8750,8500,8250,8000,7750,7500,7250,7000,6750,6500,6250,6000,5750,5500,5250 },
		Name = "Hospital Norte",
		Service = false,
		Type = "Work",
		Markers = 34,
		Banned = true,
		Chat = true
	},
	HospitalSul = {
		Permission = {
			HospitalSul = true
		},
		Hierarchy = { "Diretor-Geral","Diretor Clínico","Diretor Técnico","Chefe de Corpo Clínico","Médico Supervisor","Médico Cirurgião","Médico Plantonista","Médico Especialista","Médico Clínico","Residente","Enfermeiro","Técnico de Enfermagem","Auxiliar de Enfermagem","Estagiário de Medicina","Estagiário de Enfermagem" },
		Salary = { 8750,8500,8250,8000,7750,7500,7250,7000,6750,6500,6250,6000,5750,5500,5250 },
		Name = "Hospital Sul",
		Service = false,
		Type = "Work",
		Markers = 34,
		Banned = true,
		Chat = true
	},
	-- ARMA
	Arma1 = { -- Globo | -3704.75, 3819.01, 14.79, 65.2
		Permission = {
			Arma1 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Arma2 = { -- Vinhedo | -1916.91, 2061.8, 140.83, 73.71
		Permission = {
			Arma2 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Arma3 = { -- Playboy | -1527.66, 86.66, 56.6, 76.54
		Permission = {
			Arma3 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Arma4 = { -- Casablanca | -1542.9, 803.46, 184.91, 14.18
		Permission = {
			Arma4 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Arma5 = { -- Yakuza | -2283.04, -690.17, 20.28
		Permission = {
			Arma5 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	-- MUNICAO
	Municao1 = { -- Triade | 387.58, 2.02, 91.41, 240.95
		Permission = {
			Municao1 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Municao2 = { -- Fazenda | 1371.92, 1130.11, 113.92, 266.46
		Permission = {
			Municao2 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Municao3 = { -- Jetsam | 794.68, -2989.18, 6.02, 269.3
		Permission = {
			Municao3 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Municao4 = { -- Sinaloa | -1796.62, 414.45, 113.31, 2.84
		Permission = {
			Municao4 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	-- CONTRABANDO
	Contrabando1 = { -- Distrito 14 | -525.75, 2792.4, 42.24, 51.03
		Permission = {
			Contrabando1 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Contrabando2 = { -- Resort | -2943.78, 50.97, 11.61, 238.12
		Permission = {
			Contrabando2 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Contrabando3 = { -- Posto | -2078.63, -330.55, 13.14, 289.14
		Permission = {
			Contrabando3 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Contrabando4 = { -- Igreja | -333.7, 6153.34, 31.59, 274.97
		Permission = {
			Contrabando4 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	-- LAVAGEM
	Lavagem1 = { -- Jack Of Hearts | 369.45, 241.9, 107.75, 155.91
		Permission = {
			Lavagem1 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Lavagem2 = { -- Haute | -15.44, 235.48, 109.56, 175.75
		Permission = {
			Lavagem2 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Lavagem3 = { -- Vanilla Sul | -663.48, -703.63, 30.99, 181.42
		Permission = {
			Lavagem3 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Lavagem4 = { -- Vanilla Norte | -297.48, 6252.2, 31.46, 36.86
		Permission = {
			Lavagem4 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	-- DESMANCHE
	Desmanche1 = { -- Yellow | 1991.54, 3064.86, 47.04, 235.28
		Permission = {
			Desmanche1 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Desmanche2 = { -- Racha Cranios | 1224.45, -3222.14, 5.8, 178.59
		Permission = {
			Desmanche2 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Desmanche3 = { -- Mansao Black | -2746.6, 1464.06, 110.35, 130.4
		Permission = {
			Desmanche3 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Desmanche4 = { -- Rising Sun | -335.53, -161.85, 39.06, 354.34
		Permission = {
			Desmanche4 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	-- FAVELAS (PRODUCAO DE DROGAS)
	Metafetamina1 = { -- Favela Barragem | 1186.57, -23.52, 81.35, 138.9
		Permission = {
			Metafetamina1 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Metafetamina2 = { -- Favela Demonike | -461.9, 1589.99, 363.55, 348.67
		Permission = {
			Metafetamina2 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Skunk1 = { -- Favela Helipa | 1314.18, -786.07, 79.01, 331.66
		Permission = {
			Skunk1 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Skunk2 = { -- Favela Juramento | -2151.16, 866.27, 208.53, 209.77
		Permission = {
			Skunk2 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Cocaina1 = { -- Favela Sinaloa | 1543.09, -1374.39, 89.78, 257.96
		Permission = {
			Cocaina1 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Cocaina2 = { -- Favela Mare | -2487.37, -155.98, 45.21, 235.28
		Permission = {
			Cocaina2 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Ecstasy1 = { -- Favela MMDG | -843.41, 982.2, 250.81, 280.63
		Permission = {
			Ecstasy1 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Ecstasy2 = { -- Favela Vaticano | 2636.22, 1841.4, 36.97, 223.94
		Permission = {
			Ecstasy2 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Heroina1 = { -- Favela Santo Amaro | -1164.34, 2524.88, 41.48, 110.56
		Permission = {
			Heroina1 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Heroina2 = { -- Favela Fallet | -1395.28, 1543.68, 132.46, 85.04
		Permission = {
			Heroina2 = true
		},
		Hierarchy = { "Lider","SubLider","Gerente","Membro","Novato" },
		SecurityCam = true,
		Domination = true,
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Bennys = {
		Permission = {
			Bennys = true
		},
		Hierarchy = { "Dono","Sócio","Gerente","Mecânico","Ajudante" },
		Salary = { 4000,3500,3000,2500,2000 },
		Name = "Benny's Motorworks",
		Service = false,
		Chest = true,
		Type = "Work"
	},
	Bahamas = {
		Permission = {
			Bahamas = true
		},
		Hierarchy = { "Dono","Sócio","Gerente","Maitré","Especialista","Cozinheiro Sênior","Cozinheiro Pleno","Cozinheiro Júnior","Ajudante de Cozinha","Estagiário de Cozinha" },
		Salary = { 4000,3750,3500,3250,3000,2750,2500,2250,2000,1750 },
		Service = true,
		Chest = true,
		Type = "Work"
	},
	Restaurante = {
		Permission = {
			Restaurante = true
		},
		Hierarchy = { "Dono","Sócio","Gerente","Maitré","Especialista","Cozinheiro Sênior","Cozinheiro Pleno","Cozinheiro Júnior","Ajudante de Cozinha","Estagiário de Cozinha" },
		Salary = { 4000,3750,3500,3250,3000,2750,2500,2250,2000,1750 },
		Service = true,
		Chest = true,
		Type = "Work"
	},
	SodaPop = {
		Permission = {
			SodaPop = true
		},
		Hierarchy = { "Dono","Sócio","Gerente","Cozinheiro","Auxiliar" },
		Salary = { 4000,3500,3000,2500,2000 },
		Name = "Soda Pop",
		Service = false,
		Chest = true,
		Type = "Work"
	},
	MooMoo = {
		Permission = {
			MooMoo = true
		},
		Hierarchy = { "Dono","Sócio","Gerente","Cozinheiro","Auxiliar" },
		Salary = { 4000,3500,3000,2500,2000 },
		Name = "Moo Moo",
		Service = false,
		Chest = true,
		Type = "Work"
	},
	OsakaSushi = {
		Permission = {
			OsakaSushi = true
		},
		Hierarchy = { "Dono","Sócio","Gerente","Cozinheiro","Auxiliar" },
		Salary = { 4000,3500,3000,2500,2000 },
		Name = "Osaka Sushi",
		Service = false,
		Chest = true,
		Type = "Work"
	},
	MarinaLounge = {
		Permission = {
			MarinaLounge = true
		},
		Hierarchy = { "Dono","Sócio","Gerente","Cozinheiro","Auxiliar" },
		Salary = { 4000,3500,3000,2500,2000 },
		Name = "Marina Lounge",
		Service = false,
		Chest = true,
		Type = "Work"
	},
	KittyCafe = {
		Permission = {
			KittyCafe = true
		},
		Hierarchy = { "Dono","Sócio","Gerente","Cozinheiro","Auxiliar" },
		Salary = { 4000,3500,3000,2500,2000 },
		Name = "Kitty Café",
		Service = false,
		Chest = true,
		Type = "Work"
	},
	Booster = {
		Permission = {
			Booster = true
		},
		Hierarchy = { "Membro" },
		Service = true,
		Salary = { 2500 },
		Block = true
	},
	Freecam = {
		Permission = {
			Freecam = true
		},
		Hierarchy = { "Membro" },
		Service = true,
		Block = true
	},
	Policia = {
		Permission = {
			Militar = true,
			Civil = true,
			CORE = true,
			BOPE = true,
			PRF = true
		},
		Hierarchy = { "Membro" },
		Block = true
	},
	Medico = {
		Permission = {
			HospitalNorte = true,
			HospitalSul = true
		},
		Hierarchy = { "Membro" },
		Block = true
	},
	Emergencia = {
		Permission = {
			Militar = true,
			Civil = true,
			CORE = true,
			BOPE = true,
			PRF = true,
			HospitalNorte = true,
			HospitalSul = true
		},
		Hierarchy = { "Membro" },
		Block = true
	},
	Corredor = {
		Permission = {
			Corredor = true
		},
		Hierarchy = { "Jogador" },
		Markers = 46,
		Block = true
	},
	Boosting = {
		Permission = {
			Boosting = true
		},
		Hierarchy = { "Jogador" },
		Markers = 50,
		Block = true
	},
	-- FUELSTATIONS
	FuelStation01 = {
		Permission = {
			FuelStation01 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation02 = {
		Permission = {
			FuelStation02 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation03 = {
		Permission = {
			FuelStation03 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation04 = {
		Permission = {
			FuelStation04 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation05 = {
		Permission = {
			FuelStation05 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation06 = {
		Permission = {
			FuelStation06 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation07 = {
		Permission = {
			FuelStation07 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation08 = {
		Permission = {
			FuelStation08 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation09 = {
		Permission = {
			FuelStation09 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation10 = {
		Permission = {
			FuelStation10 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation11 = {
		Permission = {
			FuelStation11 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation12 = {
		Permission = {
			FuelStation12 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation13 = {
		Permission = {
			FuelStation13 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation14 = {
		Permission = {
			FuelStation14 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation15 = {
		Permission = {
			FuelStation15 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation16 = {
		Permission = {
			FuelStation16 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation17 = {
		Permission = {
			FuelStation17 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation18 = {
		Permission = {
			FuelStation18 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation19 = {
		Permission = {
			FuelStation19 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation20 = {
		Permission = {
			FuelStation20 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation21 = {
		Permission = {
			FuelStation21 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation22 = {
		Permission = {
			FuelStation22 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation23 = {
		Permission = {
			FuelStation23 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation24 = {
		Permission = {
			FuelStation24 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation25 = {
		Permission = {
			FuelStation25 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation26 = {
		Permission = {
			FuelStation26 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	FuelStation27 = {
		Permission = {
			FuelStation27 = true
		},
		Hierarchy = { "Proprietário","Gerente","Atendente","Frentista" },
		Service = true,
		Type = "Fuel",
		Block = true,
		Max = 3
	},
	-- PROPRIEDADES
	Mansao01 = { -- Exemplo de propriedade com painel/permissão
		Permission = {
			Mansao01 = true
		},
		Name = "Mansão",
		Hierarchy = { "Proprietário","Morador" },
		Type = "Propertys",
		Service = true,
		Max = 5
	},
	-- DOMINATION
	Lester = {
		Permission = {
			Lester = true
		},
		Hierarchy = { "Chefe","Subchefe","Membro" },
		Domination = true,
		Service = true
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHARACTERITENS
-----------------------------------------------------------------------------------------------------------------------------------------
CharacterItens = {
	soda = 2,
	identity = 1,
	hamburger = 2,
	mapgps = 1
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- BOXES
-----------------------------------------------------------------------------------------------------------------------------------------
Boxes = {
	treasurebox = {
		Multiplier = { Min = 1, Max = 1 },
		List = {
			{ Item = "dollar", Chance = 100, Min = 4250, Max = 6250 }
		}
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPPERLEVEL
-----------------------------------------------------------------------------------------------------------------------------------------
UpperLevel = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THEME
-----------------------------------------------------------------------------------------------------------------------------------------
Theme = {
	shadow = true,
	main = "#dc1553",
	mainText = "#ffffff",
	currency = Currency,
	items = ListItem,
	groups = Groups,
	inventory = {
		missions = true,
		blueprint = true,
		slots = {
			max = MaximumSlots,
			default = MinimumSlots,
		}
	},

	common = "#6fc66a",
	rare = "#6ac6c5",
	epic = "#c66a75",
	legendary = "#c6986a",
	accept = {
		letter = "#dcffe9",
		background = "#3fa466"
	},
	reject = {
		letter = "#ffe8e8",
		background = "#ad4443"
	},
	loading = {
		mode = "dark", -- [ Opções disponíveis: dark,light ],
		model = 2, -- [ Opções disponíveis: 1,2 ],
		progress = true -- [ Opções disponíveis: true, false ],
	},
	chat = {
		Importante = {
			background = "#9d194e",
			letter = "#f7c1d6"
		},
		Militar = {
			background = "#3a4a2f",
			letter = "#ffffff"
		},
		Civil = {
			background = "#1f3a5f",
			letter = "#ffffff"
		},
		CORE = {
			background = "#1a1a1a",
			letter = "#ffffff"
		},
		BOPE = {
			background = "#111111",
			letter = "#ffffff"
		},
		PRF = {
			background = "#1c1c1c",
			letter = "#ffffff"
		},
		HospitalNorte = {
			background = "#9f1918",
			letter = "#ffffff"
		},
		HospitalSul = {
			background = "#9f1918",
			letter = "#ffffff"
		},
		Families = {
			background = "#4d7a06",
			letter = "#ffffff"
		},
		Ballas = {
			background = "#430d8e",
			letter = "#ffffff"
		},
		Vagos = {
			background = "#948209",
			letter = "#ffffff"
		}
	},
	hud = {
		modes = {
			info = 1, -- [ Opções disponíveis: 1,2,3 ],
			icon = "fill", -- [ Opções disponíveis: fill,line ],
			status = 8, -- [ Opções disponíveis: 1 a 12 ],
			vehicle = 1 -- [ Opções disponíveis: 1,2,3 ]
		},
		logo = 75, -- tamanho da logo
		percentage = false,
		icons = "#FFFFFF",
		nitro = "#0074D9",
		rpm = "#FFFFFF",
		fuel = "#F94C54",
		engine = "#F69D2A",
		health = "#FF3769",
		armor = "#7681FF",
		hunger = "#FFC36F",
		thirst = "#63D0FF",
		oxygen = "#38F8F8",
		stress = "#E287C9",
		luck = "#F18A7C",
		dexterity = "#E4E76E",
		repose = "#7FCCC7",
		pointer = "#EF4444",
		progress = {
			background = "#FFFFFF",
			circle = "#dc1553",
			letter = "#FFFFFF"
		}
	},
	notifyitem = {
		add = {
			letter = "#dcffe9",
			background = "#3fa466"
		},
		remove = {
			letter = "#ffe8e8",
			background = "#ad4443"
		}
	},
	pause = {
		premium = true,
		propertys = true,
		store = true,
		boxes = true,
		marketplace = true,
		ranking = true,
		statistics = true,
		code = true,
		map = true,
		settings = true,
		hud = true,
		disconnect = true
	},
	scripts = {
		taximeter = {
			main = "#efcf2f",
			mainText = "#120b02"
		}
	}
}
