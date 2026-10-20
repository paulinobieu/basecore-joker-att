-----------------------------------------------------------------------------------------------------------------------------------------
-- CATÁLOGO DE CAIXAS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Cada caixa sorteia uma skin do config/weapons.lua, com peso proporcional ao
-- `chance` da skin. Campos da caixa:
--   id / name / image = identificação e visual na NUI
--   price             = custo em SkinsCoins (0 = grátis)
--   originalPrice     = preço "de", riscado na NUI (opcional)
--   badge             = selo exibido no card ("free", "new", ...)
--   free              = marca a caixa como diária (usa cooldownSeconds)
--   cooldownSeconds   = intervalo entre aberturas da caixa diária
--   permission        = restringe a caixa a uma permissão/grupo (opcional)
--
-- Cada skin pode ter `durationDays = N` (skin temporária; expira em N dias ao ser ganha).
-- Sem o campo, a skin é permanente. A duração é por skin dentro da caixa.
--   skins = { { id = "M4_Natal", durationDays = 7 }, { id = "Pato" } }
-----------------------------------------------------------------------------------------------------------------------------------------
CasesCatalog = {
	{
		id = "diaria",
		name = "Caixa Diária",
		price = 0,
		badge = "free",
		free = true,
		cooldownSeconds = 86400,
		image = "https://cdn.europacity.com.br/WeaponSkinsImage/CaixaGratis.png",
		skins = {
			{ id = "Glock_Rajada_Anime" }, { id = "Glock_Rajada_Fade" }, { id = "Glock_Rajada_Grafite" },
			{ id = "Glock_Rajada_Ouro" }, { id = "GLOCKRAJADA_YELLOWWIRE" },
			{ id = "Pistol_LevelUp" }, { id = "Glock_Green" }, { id = "Glock_Halloween" }, { id = "Pato" },
			{ id = "Pistol_1911_FJ" }, { id = "Pistol_1911_AL" }, { id = "Pistol_Natal_01" },
			{ id = "Pistola_Lego" }, { id = "Glock_R48" }, { id = "Glock_Toy" }, { id = "Glock_Game" },
			{ id = "PistolMk2_Natal" }, { id = "FIVE_YELLOWWIRE" },
			{ id = "M4_Natal_IceGun" }, { id = "M4_Fade" }, { id = "EO_Carbine_01" },
			{ id = "Brinquedo_Fuzil" }, { id = "CarbineRifle_Speed" },
			{ id = "MTAR_Galaxy" }, { id = "MTAR_LevelUp" }, { id = "AssaultSMG_Future" },
			{ id = "Uzi_Storm" }, { id = "Uzi_Toxic_Puddin" }, { id = "UZI_YELLOWWIRE" },
		},
	},

	{
		id = "pistola",
		name = "Box Pistol",
		price = 75,
		badge = "new",
		image = "https://cdn.europacity.com.br/WeaponSkinsImage/CaixaPistola.png",
		skins = {
			{ id = "PistolMk2_Natal" }, { id = "FIVE_YELLOWWIRE" },
			{ id = "Glock_Rajada_Anime" }, { id = "Glock_Rajada_Fade" }, { id = "Glock_Rajada_Grafite" },
			{ id = "Glock_Rajada_Ouro" }, { id = "GLOCKRAJADA_YELLOWWIRE" },
		},
	},

	{
		id = "epic",
		name = "Box Epic",
		price = 170,
		badge = "new",
		image = "https://cdn.europacity.com.br/WeaponSkinsImage/CaixaEpic.png",
		skins = {
			{ id = "APPistol_Galaxy" }, { id = "APPistol_GoldStorm" }, { id = "APPistol_RGX" },
			{ id = "Champions_APPistol" }, { id = "Pistol_Storm" }, { id = "PL_Pistol_Halloween" },
			{ id = "WhiteFire_APPistol" }, { id = "APPistol_Future" }, { id = "APPistol_Brinquedo" },
			{ id = "APPistol_Speed" },
		},
	},

	{
		id = "policia",
		name = "Box Polícia",
		price = 50,
		badge = "new",
		image = "https://cdn.europacity.com.br/WeaponSkinsImage/CaixaPolicia.png",
		permission = "Policia",
		skins = {
			{ id = "Pistol_LevelUp" }, { id = "Glock_Green" }, { id = "Glock_Halloween" }, { id = "Pato" },
			{ id = "Pistol_1911_FJ" }, { id = "Pistol_1911_AL" }, { id = "Pistol_Natal_01" },
			{ id = "Pistola_Lego" }, { id = "Glock_R48" }, { id = "Glock_Toy" }, { id = "Glock_Game" },
			{ id = "Pistola_Agua_2" }, { id = "Glock_R48_Auto" }, { id = "Glock_Toy_Auto" },
			{ id = "Halloween_CarbineRifleMk2" }, { id = "M4_Anime_Mk2" }, { id = "Scorpion_M4" },
			{ id = "WhiteFire_CarbineMk2" }, { id = "WolfStorm_Purple" }, { id = "WolfStorm_Red" },
			{ id = "CarbineRifleMk2_Future" }, { id = "M4_Lego" }, { id = "M4_Love" }, { id = "M4_Anime" },
			{ id = "M4_Mk2_Toxic" }, { id = "M4_Mk2_Pascoa" }, { id = "M4_Game" }, { id = "M4MK2_YELLOWWIRE" },
			{ id = "Champions_Knife" }, { id = "Faca_LevelUp" }, { id = "Knife_GoldStorm" },
			{ id = "Knife_Hellfire" }, { id = "Knife_RGX" }, { id = "WhiteFire_Knife" }, { id = "Bat_Storm" },
			{ id = "Knife_Future" }, { id = "Faca_Love" }, { id = "Faca_UIU" }, { id = "KARAMBIT_YELLOWWIRE" },
		},
	},

	{
		id = "copa2026",
		name = "Box Copa 2026",
		price = 200,
		badge = "new",
		image = "https://cdn.europacity.com.br/WeaponSkinsImage/CaixaCopa2026.png",
		skins = {
			{ id = "AK_Storm" }, { id = "AssaultRifle_GoldStorm" }, { id = "AssaultRifle_RGX" },
			{ id = "AK_Future" }, { id = "AK_Wolf" }, { id = "AK_Puddin_Pascoa" }, { id = "AK_YELLOWWIRE" },
			{ id = "AK_Toxic_V3" }, { id = "AK_Uni" }, { id = "AK_Agua" }, { id = "AK_Game" }, { id = "AK_Craft" },
			{ id = "BullpupRifleMk2_Natal" },
		},
	},

	{
		id = "smg",
		name = "Box SMG",
		price = 85,
		badge = "new",
		image = "https://cdn.europacity.com.br/WeaponSkinsImage/CaixaSMG.png",
		skins = {
			{ id = "MTAR_Galaxy" }, { id = "MTAR_LevelUp" }, { id = "AssaultSMG_Future" },
			{ id = "MPX_Lego_V2" }, { id = "AssaultSMG_Speed" }, { id = "SMG_Verao_Puddin" },
			{ id = "MTAR_YELLOWWIRE" },
			{ id = "PDW_YELLOWWIRE" },
			{ id = "MachinePistol_GoldStorm" }, { id = "MachinePistol_RGX" }, { id = "Tec9_Future" },
			{ id = "TEC9_YELLOWWIRE" },
			{ id = "Uzi_Storm" }, { id = "Uzi_Toxic_Puddin" }, { id = "UZI_YELLOWWIRE" },
		},
	},

	{
		id = "inverno",
		name = "Box Inverno",
		price = 120,
		badge = "new",
		image = "https://cdn.europacity.com.br/WeaponSkinsImage/CaixaInverno.png",
		skins = {
			{ id = "G3Mk2_Future" },
		},
	},

	{
		id = "prismatica",
		name = "Box Prismática",
		price = 150,
		badge = "new",
		image = "https://cdn.europacity.com.br/WeaponSkinsImage/CaixaPrismatica.png",
		skins = {
			{ id = "BlueStorm_G3" }, { id = "Champions_G3" }, { id = "G3_Galaxy" }, { id = "G3_GoldStorm" },
			{ id = "G3_Hellfire" }, { id = "G3_LevelUp" }, { id = "G3_Storm" }, { id = "G3_Toxic" },
			{ id = "Halloween_G3" }, { id = "PinkFire_G3" }, { id = "PL_G3_Halloween" },
			{ id = "SpecialCarbine_RGX" }, { id = "SpecialCarbine_Natal" }, { id = "G3_De_Agua" },
			{ id = "G3_Papelao" }, { id = "G3_Toxic_White" }, { id = "G3_Mk2_Toxic" }, { id = "G3_Urban" },
			{ id = "G3_Anime" }, { id = "G3_Wolf" }, { id = "G3_Natal" }, { id = "G3_Caveira" },
			{ id = "G3_Egito" }, { id = "G3_GIH_Toxic" }, { id = "G3_Biohazard" }, { id = "G3_Game" },
			{ id = "SpecialCarbine_Speed" }, { id = "EO_G36_01" }, { id = "EO_G36_02" },
			{ id = "G36S_YELLOWWIRE" }, { id = "G36_DRAGONWIREFLAY" }, { id = "G36B_YELLOWWIRE" },
		},
	},

	{
		id = "arcoiris",
		name = "Box Arco-Íris",
		price = 250,
		badge = "new",
		image = "https://cdn.europacity.com.br/WeaponSkinsImage/CaixaArcoIris.png",
		skins = {
			{ id = "AK_Storm" }, { id = "AssaultRifle_GoldStorm" }, { id = "AssaultRifle_RGX" },
			{ id = "AK_Future" }, { id = "AK_Wolf" }, { id = "AK_Puddin_Pascoa" }, { id = "AK_YELLOWWIRE" },
			{ id = "AK_Toxic_V3" }, { id = "AK_Uni" }, { id = "AK_Agua" }, { id = "AK_Game" }, { id = "AK_Craft" },
			{ id = "BullpupRifleMk2_Natal" },
			{ id = "APPistol_Galaxy" }, { id = "APPistol_GoldStorm" }, { id = "APPistol_RGX" },
			{ id = "Champions_APPistol" }, { id = "Pistol_Storm" }, { id = "PL_Pistol_Halloween" },
			{ id = "WhiteFire_APPistol" }, { id = "APPistol_Future" }, { id = "APPistol_Brinquedo" },
			{ id = "APPistol_Speed" },
			{ id = "Glock_Rajada_Anime" }, { id = "Glock_Rajada_Fade" }, { id = "Glock_Rajada_Grafite" },
			{ id = "Glock_Rajada_Ouro" }, { id = "GLOCKRAJADA_YELLOWWIRE" },
			{ id = "Pistol_LevelUp" }, { id = "Glock_Green" }, { id = "Glock_Halloween" }, { id = "Pato" },
			{ id = "Pistol_1911_FJ" }, { id = "Pistol_1911_AL" }, { id = "Pistol_Natal_01" },
			{ id = "Pistola_Lego" }, { id = "Glock_R48" }, { id = "Glock_Toy" }, { id = "Glock_Game" },
			{ id = "Pistola_Agua_2" }, { id = "Glock_R48_Auto" }, { id = "Glock_Toy_Auto" },
			{ id = "PistolMk2_Natal" }, { id = "FIVE_YELLOWWIRE" },
			{ id = "M4_Natal_IceGun" }, { id = "M4_Fade" }, { id = "EO_Carbine_01" },
			{ id = "Brinquedo_Fuzil" }, { id = "CarbineRifle_Speed" },
			{ id = "Halloween_CarbineRifleMk2" }, { id = "M4_Anime_Mk2" }, { id = "Scorpion_M4" },
			{ id = "WhiteFire_CarbineMk2" }, { id = "WolfStorm_Purple" }, { id = "WolfStorm_Red" },
			{ id = "CarbineRifleMk2_Future" }, { id = "M4_Lego" }, { id = "M4_Love" }, { id = "M4_Anime" },
			{ id = "M4_Mk2_Toxic" }, { id = "M4_Mk2_Pascoa" }, { id = "M4_Game" }, { id = "M4MK2_YELLOWWIRE" },
			{ id = "PDW_YELLOWWIRE" },
			{ id = "Champions_Knife" }, { id = "Faca_LevelUp" }, { id = "Knife_GoldStorm" },
			{ id = "Knife_Hellfire" }, { id = "Knife_RGX" }, { id = "WhiteFire_Knife" }, { id = "Bat_Storm" },
			{ id = "Knife_Future" }, { id = "Faca_Love" }, { id = "Faca_UIU" }, { id = "KARAMBIT_YELLOWWIRE" },
			{ id = "MachinePistol_GoldStorm" }, { id = "MachinePistol_RGX" }, { id = "Tec9_Future" },
			{ id = "TEC9_YELLOWWIRE" },
			{ id = "Uzi_Storm" }, { id = "Uzi_Toxic_Puddin" }, { id = "UZI_YELLOWWIRE" },
			{ id = "MTAR_Galaxy" }, { id = "MTAR_LevelUp" }, { id = "AssaultSMG_Future" },
			{ id = "MPX_Lego_V2" }, { id = "AssaultSMG_Speed" }, { id = "SMG_Verao_Puddin" },
			{ id = "MTAR_YELLOWWIRE" },
			{ id = "FALL_YELLOWWIRE" },
			{ id = "BlueStorm_G3" }, { id = "Champions_G3" }, { id = "G3_Galaxy" }, { id = "G3_GoldStorm" },
			{ id = "G3_Hellfire" }, { id = "G3_LevelUp" }, { id = "G3_Storm" }, { id = "G3_Toxic" },
			{ id = "Halloween_G3" }, { id = "PinkFire_G3" }, { id = "PL_G3_Halloween" },
			{ id = "SpecialCarbine_RGX" }, { id = "SpecialCarbine_Natal" }, { id = "G3_De_Agua" },
			{ id = "G3_Papelao" }, { id = "G3_Toxic_White" }, { id = "G3_Mk2_Toxic" }, { id = "G3_Urban" },
			{ id = "G3_Anime" }, { id = "G3_Wolf" }, { id = "G3_Natal" }, { id = "G3_Caveira" },
			{ id = "G3_Egito" }, { id = "G3_GIH_Toxic" }, { id = "G3_Biohazard" }, { id = "G3_Game" },
			{ id = "SpecialCarbine_Speed" }, { id = "EO_G36_01" }, { id = "EO_G36_02" },
			{ id = "G36S_YELLOWWIRE" }, { id = "G36_DRAGONWIREFLAY" }, { id = "G36B_YELLOWWIRE" },
			{ id = "G3Mk2_Future" },
		},
	},
}
