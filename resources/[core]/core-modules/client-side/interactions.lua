-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISMANTLE
-----------------------------------------------------------------------------------------------------------------------------------------
local Dismantle = {
	vec3(943.23,-1497.87,30.11),
	vec3(-1172.57,-2037.65,13.75),
	vec3(-524.94,-1680.63,19.21),
	vec3(1358.14,-2095.41,52.0),
	vec3(602.47,-437.82,24.75),
	vec3(-413.86,-2179.29,10.31),
	vec3(146.51,320.62,112.14),
	vec3(520.91,169.14,99.36),
	vec3(1137.99,-794.32,57.59),
	vec3(-93.07,-2549.6,6.0),
	vec3(820.07,-488.43,30.46),
	vec3(1078.62,-2325.56,30.25),
	vec3(1204.69,-3116.71,5.50)
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- TYRES
-----------------------------------------------------------------------------------------------------------------------------------------
local Tyres = {
	["wheel_lf"] = 0,
	["wheel_rf"] = 1,
	["wheel_lm"] = 2,
	["wheel_rm"] = 3,
	["wheel_lr"] = 4,
	["wheel_rr"] = 5
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUELS
-----------------------------------------------------------------------------------------------------------------------------------------
local Fuels = {
	["FuelStation01"] = { vec3(273.83,-1253.46,28.29),vec3(273.83,-1261.29,28.29),vec3(273.83,-1268.63,28.29),vec3(265.06,-1253.46,28.29),vec3(265.06,-1261.29,28.29),vec3(265.06,-1268.63,28.29),vec3(256.43,-1253.46,28.29),vec3(256.43,-1261.29,28.29),vec3(256.43,-1268.63,28.29) },
	["FuelStation02"] = { vec3(2680.90,3266.40,54.39),vec3(2678.51,3262.33,54.39) },
	["FuelStation03"] = { vec3(-2104.53,-311.01,12.16),vec3(-2105.39,-319.21,12.16),vec3(-2106.06,-325.57,12.16),vec3(-2097.48,-326.48,12.16),vec3(-2096.81,-320.11,12.16),vec3(-2096.09,-311.90,12.16),vec3(-2087.21,-312.81,12.16),vec3(-2088.08,-321.03,12.16),vec3(-2088.75,-327.39,12.16) },
	["FuelStation04"] = { vec3(-2551.39,2327.11,32.24),vec3(-2558.02,2326.70,32.24),vec3(-2558.48,2334.13,32.24),vec3(-2552.60,2334.46,32.24),vec3(-2558.77,2341.48,32.24),vec3(-2552.39,2341.89,32.24) },
	["FuelStation05"] = { vec3(186.97,6606.21,31.06),vec3(179.67,6604.93,31.06),vec3(172.33,6603.63,31.06) },
	["FuelStation06"] = { vec3(810.7,-1026.24,25.44),vec3(810.7,-1030.94,25.44),vec3(818.99,-1030.94,25.44),vec3(818.99,-1026.24,25.44),vec3(827.3,-1026.24,25.64),vec3(827.3,-1030.94,25.64) },
	["FuelStation07"] = { vec3(1207.07,-1398.16,34.39),vec3(1204.2,-1401.03,34.39),vec3(1210.07,-1406.9,34.39),vec3(1212.94,-1404.03,34.39) },
	["FuelStation08"] = { vec3(1178.97,-339.54,68.37),vec3(1186.4,-338.23,68.36),vec3(1184.89,-329.7,68.31),vec3(1177.46,-331.01,68.32),vec3(1175.71,-322.3,68.36),vec3(1183.13,-320.99,68.36) },
	["FuelStation09"] = { vec3(629.64,263.84,102.27),vec3(629.64,273.97,102.27),vec3(620.99,273.97,102.27),vec3(621.0,263.84,102.27),vec3(612.44,263.84,102.27),vec3(612.43,273.96,102.27) },
	["FuelStation10"] = { vec3(2588.41,358.56,107.66),vec3(2588.65,364.06,107.66),vec3(2581.18,364.39,107.66),vec3(2580.94,358.89,107.66),vec3(2573.55,359.21,107.66),vec3(2573.79,364.71,107.66) },
	["FuelStation11"] = { vec3(174.99,-1568.44,28.33),vec3(181.81,-1561.96,28.33),vec3(176.03,-1555.91,28.33),vec3(169.3,-1562.26,28.33) },
	["FuelStation12"] = { vec3(-329.81,-1471.63,29.73),vec3(-324.74,-1480.41,29.73),vec3(-317.26,-1476.09,29.73),vec3(-322.33,-1467.31,29.73),vec3(-314.92,-1463.03,29.73),vec3(-309.85,-1471.79,29.73) },
	["FuelStation13"] = { vec3(1786.08,3329.86,40.42),vec3(1785.04,3331.48,40.35) },
	["FuelStation14"] = { vec3(50.31,2778.54,57.05),vec3(48.92,2779.59,57.05) },
	["FuelStation15"] = { vec3(264.98,2607.18,43.99),vec3(263.09,2606.8,43.99) },
	["FuelStation16"] = { vec3(1035.45,2674.44,38.71),vec3(1043.22,2674.45,38.71),vec3(1043.22,2667.92,38.71),vec3(1035.45,2667.91,38.71) },
	["FuelStation17"] = { vec3(1209.59,2658.36,36.9),vec3(1208.52,2659.43,36.9),vec3(1205.91,2662.05,36.9) },
	["FuelStation18"] = { vec3(2539.8,2594.81,36.96) },
	["FuelStation19"] = { vec3(2001.55,3772.21,31.4),vec3(2003.92,3773.48,31.4),vec3(2006.21,3774.96,31.4),vec3(2009.26,3776.78,31.4) },
	["FuelStation20"] = { vec3(1684.6,4931.66,41.23),vec3(1690.1,4927.81,41.23) },
	["FuelStation21"] = { vec3(1705.74,6414.61,31.77),vec3(1701.73,6416.49,31.77),vec3(1697.76,6418.35,31.77) },
	["FuelStation22"] = { vec3(-97.06,6416.77,30.65),vec3(-91.29,6422.54,30.65) },
	["FuelStation23"] = { vec3(-1808.71,799.96,137.69),vec3(-1803.62,794.4,137.69),vec3(-1797.22,800.56,137.66),vec3(-1802.31,806.12,137.66),vec3(-1795.93,811.97,137.7),vec3(-1790.83,806.41,137.7) },
	["FuelStation24"] = { vec3(-1438.07,-268.69,45.41),vec3(-1444.5,-274.23,45.41),vec3(-1435.5,-284.68,45.41),vec3(-1429.07,-279.15,45.41) },
	["FuelStation25"] = { vec3(-732.64,-932.51,18.22),vec3(-732.64,-939.32,18.22),vec3(-724.0,-939.32,18.22),vec3(-724.0,-932.51,18.22),vec3(-715.43,-932.51,18.22),vec3(-715.43,-939.32,18.22) },
	["FuelStation26"] = { vec3(-532.28,-1212.71,17.33),vec3(-529.51,-1213.96,17.33),vec3(-524.92,-1216.15,17.33),vec3(-522.23,-1217.42,17.33),vec3(-518.52,-1209.5,17.33),vec3(-521.21,-1208.23,17.33),vec3(-525.8,-1206.04,17.33),vec3(-528.57,-1204.8,17.33) },
	["FuelStation27"] = { vec3(-72.03,-1765.1,28.53),vec3(-69.45,-1758.01,28.55),vec3(-77.59,-1755.05,28.81),vec3(-80.17,-1762.14,28.8),vec3(-63.61,-1767.93,28.27),vec3(-61.03,-1760.85,28.31) }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- HELPERS
-----------------------------------------------------------------------------------------------------------------------------------------
local State = Entity

local function NetId(Entity)
	if NetworkGetEntityIsNetworked(Entity) then
		return NetworkGetNetworkIdFromEntity(Entity)
	end

	return nil
end

local function PlayerOk()
	return GetEntityHealth(PlayerPedId()) > 100
end

local FuelCacheTime = 0
local FuelCacheValue = nil

local function FuelPermission()
	local Now = GetGameTimer()
	if Now - FuelCacheTime < 250 then
		return FuelCacheValue
	end

	local Coords = GetEntityCoords(PlayerPedId())
	local Result = nil
	for Permission,List in pairs(Fuels) do
		for i = 1,#List do
			if #(Coords - List[i]) <= 2.5 then
				Result = Permission
				break
			end
		end

		if Result then
			break
		end
	end

	FuelCacheTime = Now
	FuelCacheValue = Result
	return Result
end

local function HasPetrolcan()
	return GetSelectedPedWeapon(PlayerPedId()) == GetHashKey("WEAPON_PETROLCAN")
end

local function NearDismantle()
	local Coords = GetEntityCoords(PlayerPedId())
	for _,v in pairs(Dismantle) do
		if #(Coords - v) <= 15 then
			return true
		end
	end

	return false
end

local function VehicleSelected(Entity)
	SetEntityAsMissionEntity(Entity,true,true)

	return { GetVehicleNumberPlateText(Entity),GetEntityArchetypeName(Entity),Entity,NetId(Entity),GetEntityModel(Entity),false,false }
end

local function ModelSelected(Entity)
	if not IsEntityAMissionEntity(Entity) then
		SetEntityAsMissionEntity(Entity,true,true)
	end

	return { Entity,GetEntityModel(Entity),NetId(Entity),GetEntityCoords(Entity),IsEntityDead(Entity) }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STATIC ZONES
-----------------------------------------------------------------------------------------------------------------------------------------
exports.ox_target:addSphereZone({
	coords = vec3(717.99,153.35,81.00),
	radius = 1.25,
	options = {
		{
			name = "target:blackout",
			label = "Conexão",
			icon = "fa-solid fa-bolt",
			onSelect = function()
				TriggerServerEvent("target:Blackout")
			end
		}
	}
})

for Index,Coords in ipairs({ vec3(-330.36,-1564.11,25.47),vec3(12.99,6501.61,31.84) }) do
	exports.ox_target:addSphereZone({
		coords = Coords,
		radius = 1.25,
		options = {
			{
				name = "target:trash:"..Index,
				label = "Despejar Lixo",
				icon = "fa-solid fa-trash",
				onSelect = function()
					TriggerServerEvent("inventory:Products","Trasher")
				end
			}
		}
	})
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STATIC MODELS
-----------------------------------------------------------------------------------------------------------------------------------------
exports.ox_target:addModel({ 654385216,161343630,-430989390,1096374064,-1519644200,-1932041857,207578973,-487222358 },{
	{
		name = "slotmachine:init",
		label = "Sentar",
		icon = "fa-solid fa-dice",
		distance = 0.75,
		onSelect = function(Data)
			TriggerEvent("slotmachine:Init",ModelSelected(Data.entity))
		end
	}
})

exports.ox_target:addModel({ -832573324,-1430839454,1457690978,1682622302,402729631,-664053099,1794449327,307287994,-1323586730,111281960,-541762431,-745300483,-417505688 },{
	{
		name = "inventory:animals",
		label = "Esfolar",
		icon = "fa-solid fa-paw",
		distance = 1.25,
		onSelect = function(Data)
			TriggerServerEvent("inventory:Animals",ModelSelected(Data.entity))
		end
	}
})

exports.ox_target:addModel({ -206690185,666561306,218085040,-58485588,1511880420,682791951 },{
	{
		name = "player:entertrash",
		label = "Esconder",
		icon = "fa-solid fa-person-shelter",
		distance = 1.0,
		onSelect = function(Data)
			TriggerEvent("player:enterTrash",ModelSelected(Data.entity))
		end
	},{
		name = "player:checktrash",
		label = "Verificar",
		icon = "fa-solid fa-magnifying-glass",
		distance = 1.0,
		onSelect = function(Data)
			TriggerServerEvent("player:checkTrash",ModelSelected(Data.entity))
		end
	},{
		name = "chest:trash",
		label = "Abrir",
		icon = "fa-solid fa-box-open",
		distance = 1.0,
		onSelect = function(Data)
			TriggerEvent("chest:Open",Data.entity,"Trash")
		end
	}
})

exports.ox_target:addModel({ -1691644768,-742198632 },{
	{
		name = "inventory:drink",
		label = "Beber",
		icon = "fa-solid fa-glass-water",
		distance = 0.75,
		onSelect = function(Data)
			TriggerServerEvent("inventory:Drink",ModelSelected(Data.entity))
		end
	},{
		name = "inventory:refillbottle",
		label = "Encher Garrafa",
		icon = "fa-solid fa-bottle-water",
		distance = 0.75,
		onSelect = function(Data)
			TriggerServerEvent("inventory:RefillBottle",ModelSelected(Data.entity))
		end
	},{
		name = "inventory:refillwateringcan",
		label = "Encher Regador",
		icon = "fa-solid fa-droplet",
		distance = 0.75,
		onSelect = function(Data)
			TriggerServerEvent("inventory:RefillGallon",ModelSelected(Data.entity))
		end
	}
})

for _,v in pairs({
	{ Models = { 690372739 }, Service = "Coffee" },
	{ Models = { -654402915,1421582485 }, Service = "Donut" },
	{ Models = { 992069095,1114264700 }, Service = "Soda" },
	{ Models = { 1129053052 }, Service = "Hamburger" },
	{ Models = { -1581502570 }, Service = "Hotdog" },
	{ Models = { 73774428 }, Service = "Cigarette" },
	{ Models = { -272361894 }, Service = "Chihuahua" },
	{ Models = { 1099892058 }, Service = "Water" }
}) do
	local Service = v.Service
	exports.ox_target:addModel(v.Models,{
		{
			name = "shops:vending:"..Service,
			label = "Abrir",
			icon = "fa-solid fa-store",
			distance = 1.25,
			onSelect = function()
				TriggerEvent("core-shops:Open",Service)
			end
		}
	})
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL VEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
exports.ox_target:addGlobalVehicle({
	{
		name = "engine:supply:fuel",
		label = "Abastecer",
		icon = "fa-solid fa-gas-pump",
		distance = 1.0,
		canInteract = function()
			return PlayerOk() and FuelPermission() ~= nil
		end,
		onSelect = function(Data)
			local Selected = VehicleSelected(Data.entity)
			Selected[7] = FuelPermission()
			TriggerEvent("engine:Supply",Selected)
		end
	},{
		name = "engine:supply:can",
		label = "Abastecer",
		icon = "fa-solid fa-gas-pump",
		distance = 1.0,
		canInteract = function()
			return PlayerOk() and FuelPermission() == nil and HasPetrolcan()
		end,
		onSelect = function(Data)
			local Selected = VehicleSelected(Data.entity)
			Selected[6] = true
			TriggerEvent("engine:Supply",Selected)
		end
	},{
		name = "trunkchest:opentrunk",
		label = "Abrir Porta-Malas",
		icon = "fa-solid fa-box",
		distance = 1.0,
		canInteract = function(Entity)
			return PlayerOk() and FuelPermission() == nil and not HasPetrolcan() and State(Entity).state.Lockpick and not IsPedArmed(PlayerPedId(),7) and GetVehicleDoorLockStatus(Entity) <= 1 and VehicleWeight(GetEntityArchetypeName(Entity)) > 0
		end,
		onSelect = function(Data)
			TriggerServerEvent("trunkchest:openTrunk",VehicleSelected(Data.entity))
		end
	},{
		name = "inventory:changeplate",
		label = "Trocar Placa",
		icon = "fa-solid fa-id-card",
		distance = 1.0,
		canInteract = function(Entity)
			return PlayerOk() and FuelPermission() == nil and not HasPetrolcan() and State(Entity).state.Lockpick and not IsPedArmed(PlayerPedId(),7) and GetVehicleDoorLockStatus(Entity) <= 1
		end,
		onSelect = function(Data)
			TriggerServerEvent("inventory:ChangePlate",VehicleSelected(Data.entity))
		end
	},{
		name = "garages:key",
		label = "Chave Veícular",
		icon = "fa-solid fa-key",
		distance = 1.0,
		canInteract = function(Entity)
			return PlayerOk() and FuelPermission() == nil and not HasPetrolcan() and State(Entity).state.Lockpick == LocalPlayer.state.Passport and not IsPedArmed(PlayerPedId(),7) and GetVehicleDoorLockStatus(Entity) <= 1
		end,
		onSelect = function(Data)
			TriggerServerEvent("garages:Key",VehicleSelected(Data.entity))
		end
	},{
		name = "engine:vehrify",
		label = "Verificar",
		icon = "fa-solid fa-circle-info",
		distance = 1.0,
		canInteract = function(Entity)
			return PlayerOk() and FuelPermission() == nil and not HasPetrolcan() and State(Entity).state.Lockpick
		end,
		onSelect = function(Data)
			TriggerEvent("engine:Vehrify",VehicleSelected(Data.entity))
		end
	},{
		name = "inventory:stealtrunk",
		label = "Arrombar Porta-Malas",
		icon = "fa-solid fa-lock-open",
		distance = 1.0,
		canInteract = function(Entity)
			return PlayerOk() and FuelPermission() == nil and not HasPetrolcan() and not State(Entity).state.Lockpick and GetEntityBoneIndexByName(Entity,"boot") ~= -1 and IsVehicleSeatFree(Entity,-1) and GetSelectedPedWeapon(PlayerPedId()) == GetHashKey("WEAPON_CROWBAR")
		end,
		onSelect = function(Data)
			TriggerServerEvent("inventory:StealTrunk",VehicleSelected(Data.entity))
		end
	},{
		name = "inventory:stockade",
		label = "Vasculhar",
		icon = "fa-solid fa-sack-dollar",
		distance = 1.0,
		canInteract = function(Entity)
			return PlayerOk() and FuelPermission() == nil and not HasPetrolcan() and not State(Entity).state.Lockpick and GetEntityArchetypeName(Entity) == "stockade"
		end,
		onSelect = function(Data)
			TriggerServerEvent("inventory:Stockade",VehicleSelected(Data.entity))
		end
	},{
		name = "player:rollvehicle",
		label = "Desvirar",
		icon = "fa-solid fa-rotate",
		distance = 1.0,
		canInteract = function(Entity)
			if not PlayerOk() or FuelPermission() ~= nil or HasPetrolcan() or IsThisModelABike(GetEntityModel(Entity)) then
				return false
			end

			local Rolling = GetEntityRoll(Entity)
			return Rolling > 75.0 or Rolling < -75.0
		end,
		onSelect = function(Data)
			TriggerServerEvent("player:RollVehicle",VehicleSelected(Data.entity))
		end
	},{
		name = "player:checktrunk",
		label = "Checar Porta-Malas",
		icon = "fa-solid fa-box-open",
		distance = 1.0,
		canInteract = function(Entity)
			return PlayerOk() and FuelPermission() == nil and not HasPetrolcan() and not IsThisModelABike(GetEntityModel(Entity)) and GetEntityBoneIndexByName(Entity,"boot") ~= -1 and not IsPedArmed(PlayerPedId(),7) and GetVehicleDoorLockStatus(Entity) <= 1
		end,
		onSelect = function(Data)
			TriggerServerEvent("player:checkTrunk",VehicleSelected(Data.entity))
		end
	},{
		name = "player:entertrunk",
		label = "Entrar no Porta-Malas",
		icon = "fa-solid fa-down-long",
		distance = 1.0,
		canInteract = function(Entity)
			return PlayerOk() and FuelPermission() == nil and not HasPetrolcan() and not IsThisModelABike(GetEntityModel(Entity)) and GetEntityBoneIndexByName(Entity,"boot") ~= -1 and not IsPedArmed(PlayerPedId(),7) and GetVehicleDoorLockStatus(Entity) <= 1
		end,
		onSelect = function(Data)
			TriggerEvent("player:enterTrunk",VehicleSelected(Data.entity))
		end
	},{
		name = "inventory:tow",
		label = "Rebocar",
		icon = "fa-solid fa-truck-ramp-box",
		distance = 1.0,
		canInteract = function(Entity)
			return PlayerOk() and FuelPermission() == nil and not HasPetrolcan() and GetEntityArchetypeName(GetLastDrivenVehicle()) == "flatbed" and GetEntityArchetypeName(Entity) ~= "flatbed"
		end,
		onSelect = function(Data)
			TriggerEvent("inventory:Tow",VehicleSelected(Data.entity))
		end
	},{
		name = "prison:plate",
		label = "Verificar Placa",
		icon = "fa-solid fa-magnifying-glass",
		distance = 1.0,
		canInteract = function()
			return PlayerOk() and FuelPermission() == nil and not HasPetrolcan() and CheckPolice()
		end,
		onSelect = function(Data)
			TriggerServerEvent("prison:Plate",VehicleSelected(Data.entity))
		end
	},{
		name = "inventory:dismantle",
		label = "Desmanchar",
		icon = "fa-solid fa-screwdriver-wrench",
		distance = 1.0,
		canInteract = function()
			return PlayerOk() and FuelPermission() == nil and not HasPetrolcan() and not CheckPolice() and NearDismantle()
		end,
		onSelect = function(Data)
			TriggerServerEvent("inventory:Dismantle",VehicleSelected(Data.entity))
		end
	}
})
-----------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL VEHICLE: TYRES (uma opção por roda, via bone)
-----------------------------------------------------------------------------------------------------------------------------------------
for Bone,Index in pairs(Tyres) do
	exports.ox_target:addGlobalVehicle({
		{
			name = "inventory:removetyres:"..Bone,
			label = "Retirar Pneu",
			icon = "fa-solid fa-circle-dot",
			distance = 1.0,
			bones = { Bone },
			canInteract = function(Vehicle)
				return PlayerOk() and FuelPermission() == nil and not HasPetrolcan() and State(Vehicle).state.Lockpick and GetVehicleDoorLockStatus(Vehicle) <= 1 and GetSelectedPedWeapon(PlayerPedId()) == GetHashKey("WEAPON_WRENCH")
			end,
			onSelect = function(Data)
				local Selected = VehicleSelected(Data.entity)
				Selected[6] = Index
				TriggerServerEvent("inventory:RemoveTyres",Selected)
			end
		}
	})
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL PLAYER
-----------------------------------------------------------------------------------------------------------------------------------------
local function PlayerSource(Entity)
	return GetPlayerServerId(NetworkGetPlayerIndexFromPed(Entity))
end

exports.ox_target:addGlobalPlayer({
	{
		name = "paramedic:adrenaline",
		label = "Ajudar",
		icon = "fa-solid fa-syringe",
		distance = 2.0,
		canInteract = function(Entity)
			return PlayerOk() and GetEntityHealth(Entity) <= 100 and Player(PlayerSource(Entity)).state.Crawl
		end,
		onSelect = function(Data)
			TriggerServerEvent("paramedic:Adrenaline",PlayerSource(Data.entity))
		end
	},{
		name = "paramedic:revive",
		label = "Reanimar",
		icon = "fa-solid fa-heart-pulse",
		distance = 2.0,
		canInteract = function(Entity)
			return PlayerOk() and GetEntityHealth(Entity) <= 100 and CheckMedical()
		end,
		onSelect = function(Data)
			TriggerServerEvent("paramedic:Revive",PlayerSource(Data.entity))
		end
	},{
		name = "player:demand",
		label = "Cobrança",
		icon = "fa-solid fa-money-bill",
		distance = 2.0,
		canInteract = function(Entity)
			return PlayerOk() and GetEntityHealth(Entity) > 100
		end,
		onSelect = function(Data)
			TriggerServerEvent("player:Demand",PlayerSource(Data.entity))
		end
	},{
		name = "marriage:request",
		label = "Relacionamento",
		icon = "fa-solid fa-heart",
		distance = 2.0,
		canInteract = function(Entity)
			return PlayerOk() and GetEntityHealth(Entity) > 100
		end,
		onSelect = function(Data)
			TriggerServerEvent("marriage:Request",PlayerSource(Data.entity))
		end
	},{
		name = "player:checkshoes",
		label = "Roubar Sapatos",
		icon = "fa-solid fa-shoe-prints",
		distance = 2.0,
		canInteract = function(Entity)
			return PlayerOk() and GetEntityHealth(Entity) > 100 and IsEntityPlayingAnim(Entity,"random@mugging3","handsup_standing_base",3)
		end,
		onSelect = function(Data)
			TriggerServerEvent("player:checkShoes",PlayerSource(Data.entity))
		end
	},{
		name = "paramedic:treatment",
		label = "Tratamento",
		icon = "fa-solid fa-stethoscope",
		distance = 2.0,
		canInteract = function(Entity)
			return PlayerOk() and GetEntityHealth(Entity) > 100 and CheckMedical()
		end,
		onSelect = function(Data)
			TriggerServerEvent("paramedic:Treatment",PlayerSource(Data.entity))
		end
	},{
		name = "paramedic:bandage",
		label = "Passar Ataduras",
		icon = "fa-solid fa-bandage",
		distance = 2.0,
		canInteract = function(Entity)
			return PlayerOk() and GetEntityHealth(Entity) > 100 and CheckMedical()
		end,
		onSelect = function(Data)
			TriggerServerEvent("paramedic:Bandage",PlayerSource(Data.entity))
		end
	},{
		name = "paramedic:presetburn",
		label = "Roupa de Queimadura",
		icon = "fa-solid fa-fire",
		distance = 2.0,
		canInteract = function(Entity)
			return PlayerOk() and GetEntityHealth(Entity) > 100 and CheckMedical()
		end,
		onSelect = function(Data)
			TriggerServerEvent("paramedic:presetBurn",PlayerSource(Data.entity))
		end
	},{
		name = "paramedic:presetplaster",
		label = "Colocar Gesso",
		icon = "fa-solid fa-bone",
		distance = 2.0,
		canInteract = function(Entity)
			return PlayerOk() and GetEntityHealth(Entity) > 100 and CheckMedical()
		end,
		onSelect = function(Data)
			TriggerServerEvent("paramedic:presetPlaster",PlayerSource(Data.entity))
		end
	},{
		name = "paramedic:extractblood",
		label = "Extrair Sangue",
		icon = "fa-solid fa-droplet",
		distance = 2.0,
		canInteract = function(Entity)
			return PlayerOk() and GetEntityHealth(Entity) > 100 and CheckMedical()
		end,
		onSelect = function(Data)
			TriggerServerEvent("paramedic:extractBlood",PlayerSource(Data.entity))
		end
	},{
		name = "target:repose",
		label = "Repouso",
		icon = "fa-solid fa-bed-pulse",
		distance = 2.0,
		canInteract = function(Entity)
			return PlayerOk() and GetEntityHealth(Entity) > 100 and CheckMedical()
		end,
		onSelect = function(Data)
			TriggerServerEvent("target:Repose",PlayerSource(Data.entity))
		end
	},{
		name = "prison:itens",
		label = "Apreender",
		icon = "fa-solid fa-handcuffs",
		distance = 2.0,
		canInteract = function()
			return PlayerOk() and CheckPolice()
		end,
		onSelect = function(Data)
			TriggerServerEvent("prison:Itens",PlayerSource(Data.entity))
		end
	},{
		name = "paramedic:diagnostic",
		label = "Informações",
		icon = "fa-solid fa-notes-medical",
		distance = 2.0,
		canInteract = function()
			return PlayerOk() and CheckMedical()
		end,
		onSelect = function(Data)
			TriggerServerEvent("paramedic:Diagnostic",PlayerSource(Data.entity))
		end
	},{
		name = "inspect:player",
		label = "Revistar",
		icon = "fa-solid fa-magnifying-glass",
		distance = 2.0,
		canInteract = function()
			return PlayerOk()
		end,
		onSelect = function(Data)
			TriggerServerEvent("inspect:Player",PlayerSource(Data.entity))
		end
	}
})
-----------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL PED
-----------------------------------------------------------------------------------------------------------------------------------------
exports.ox_target:addGlobalPed({
	{
		name = "target:deleteped",
		label = "Deletar",
		icon = "fa-solid fa-trash",
		distance = 2.0,
		canInteract = function(Entity)
			return LocalPlayer.state.Admin and not DecorGetBool(Entity,"CREATIVE_PED")
		end,
		onSelect = function(Data)
			TriggerServerEvent("DeletePed",NetId(Data.entity))
		end
	}
})
-----------------------------------------------------------------------------------------------------------------------------------------
-- TARGET:ROLLVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("target:RollVehicle")
AddEventHandler("target:RollVehicle",function(Network)
	if NetworkDoesNetworkIdExist(Network) then
		local Vehicle = NetToEnt(Network)
		if DoesEntityExist(Vehicle) then
			SetVehicleOnGroundProperly(Vehicle)
		end
	end
end)
