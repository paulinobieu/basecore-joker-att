-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
Arsenal = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THEME
-----------------------------------------------------------------------------------------------------------------------------------------
Arsenal.ThemeColor = "#dc1553"
-----------------------------------------------------------------------------------------------------------------------------------------
-- IMAGES
-----------------------------------------------------------------------------------------------------------------------------------------
Arsenal.ImagesUrl = "https://cdn.corenetwork.dev/Itens/"
-----------------------------------------------------------------------------------------------------------------------------------------
-- INTERACT
-----------------------------------------------------------------------------------------------------------------------------------------
Arsenal.OpenSound = true
Arsenal.InteractLabel = "Abrir Arsenal"
Arsenal.InteractIcon = "person-rifle"
Arsenal.InteractDistance = 1.5
-----------------------------------------------------------------------------------------------------------------------------------------
-- CATEGORIES
-----------------------------------------------------------------------------------------------------------------------------------------
Arsenal.CategoryOrder = { "Rifles", "Subs", "Pistolas", "Munições", "Utilitários" }
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOCATIONS
-----------------------------------------------------------------------------------------------------------------------------------------
Arsenal.Locations = {
	["PoliciaMRPD"] = {
		coords = vec3(466.32,-1000.68,30.61),
		distance = 0.7,
		permission = "Policia",
		template = "DEFAULT_POLICE",
	},
	["PoliciaMilitar"] = {
		coords = vec3(2545.69,-284.57,93.32),
		permission = "Policia",
		template = "DEFAULT_POLICE",
	},
	["PoliciaCivil"] = {
		coords = vec3(-995.16,-2007.55,13.54),
		permission = "Policia",
		template = "DEFAULT_POLICE",
	},
	["BOPE"] = {
		coords = vec3(-1663.63,171.04,61.95),
		permission = "Policia",
		template = "DEFAULT_POLICE",
	},
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- TEMPLATES
-----------------------------------------------------------------------------------------------------------------------------------------
Arsenal.Templates = {
	["DEFAULT_POLICE"] = {
		["Rifles"] = {
			{ item = "WEAPON_POLICE_CARBINERIFLE", price = 1500, permission = { "Policia" } },
			{ item = "WEAPON_POLICE_CARBINERIFLE_MK2", price = 1500, permission = { "Policia" } },
			{ item = "WEAPON_POLICE_TACTICALRIFLE", price = 1500, permission = { "Policia" } },
			{ item = "WEAPON_POLICE_SPECIALCARBINE", price = 1500, permission = { "Policia" } },
			{ item = "WEAPON_POLICE_SPECIALCARBINE_MK2", price = 1500, permission = { "Policia" } },
			{ item = "WEAPON_POLICE_PUMPSHOTGUN_MK2", price = 1200, permission = { "Policia" } },
			{ item = "WEAPON_POLICE_SAWNOFFSHOTGUN", price = 1200, permission = { "Policia" } },
		},
		["Subs"] = {
			{ item = "WEAPON_POLICE_SMG_MK2", price = 1000, permission = { "Policia" } },
		},
		["Pistolas"] = {
			{ item = "WEAPON_POLICE_COMBATPISTOL", price = 500, permission = { "Policia" } },
			{ item = "WEAPON_STUNGUN", price = 725, permission = { "Policia" } },
		},
		["Munições"] = {
			{ item = "BOX_WEAPON_POLICE_AMMO", price = 500, permission = { "Policia" } },
		},
		["Utilitários"] = {
			{ item = "armour", price = 500, permission = { "Policia" } },
			{ item = "handcuff", price = 125, permission = { "Policia" } },
			{ item = "gsrkit", price = 25, permission = { "Policia" } },
			{ item = "gdtkit", price = 25, permission = { "Policia" } },
			{ item = "barrier", price = 25, permission = { "Policia" } },
			{ item = "spikestrips", price = 275, permission = { "Policia" } },
			{ item = "tacticalbackpack", price = 1000, permission = { "Policia" } },
			{ item = "radio", price = 975, permission = { "Policia" } },
			{ item = "cellphone", price = 725, permission = { "Policia" } },
			{ item = "energetic", price = 150, permission = { "Policia" } },
			{ item = "WEAPON_NIGHTSTICK", price = 150, permission = { "Policia" } },
			{ item = "ATTACH_POLICE_FLASHLIGHT", price = 200, permission = { "Policia" } },
			{ item = "ATTACH_POLICE_MAGAZINE", price = 200, permission = { "Policia" } },
			{ item = "ATTACH_POLICE_SILENCER", price = 400, permission = { "Policia" } },
			{ item = "ATTACH_POLICE_GRIP", price = 150, permission = { "Policia" } },
			{ item = "ATTACH_POLICE_CROSSHAIR", price = 250, permission = { "Policia" } },
		},
	},
}
