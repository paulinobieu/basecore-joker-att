-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Core = {}
Tunnel.bindInterface("core-crash",Core)
vSERVER = Tunnel.getInterface("core-crash")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Active = false
local Selected = 0
local CrashType = "heli"
local Objects = {}
local Blip = nil
local BlipRadius = nil
local Inside = false
local KillCooldown = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEAPONS
-----------------------------------------------------------------------------------------------------------------------------------------
local WeaponNames = {}

CreateThread(function()
	local List = {
		"WEAPON_ADVANCEDRIFLE","WEAPON_APPISTOL","WEAPON_ASSAULTRIFLE","WEAPON_ASSAULTRIFLE_MK2","WEAPON_ASSAULTSHOTGUN",
		"WEAPON_ASSAULTSMG","WEAPON_AUTOSHOTGUN","WEAPON_BAT","WEAPON_BATTLEAXE","WEAPON_BULLPUPRIFLE","WEAPON_BULLPUPRIFLE_MK2",
		"WEAPON_BULLPUPSHOTGUN","WEAPON_CARBINERIFLE","WEAPON_CARBINERIFLE_MK2","WEAPON_COMBATMG","WEAPON_COMBATMG_MK2",
		"WEAPON_COMBATPDW","WEAPON_COMBATPISTOL","WEAPON_COMPACTRIFLE","WEAPON_CROWBAR","WEAPON_DAGGER","WEAPON_DBSHOTGUN",
		"WEAPON_DOUBLEACTION","WEAPON_FIREEXTINGUISHER","WEAPON_FIREWORK","WEAPON_FLARE","WEAPON_FLAREGUN","WEAPON_FLASHLIGHT",
		"WEAPON_GOLFCLUB","WEAPON_GRENADE","WEAPON_GRENADELAUNCHER","WEAPON_GUSENBERG","WEAPON_HAMMER","WEAPON_HATCHET",
		"WEAPON_HEAVYPISTOL","WEAPON_HEAVYSHOTGUN","WEAPON_HEAVYSNIPER","WEAPON_HEAVYSNIPER_MK2","WEAPON_HOMINGLAUNCHER",
		"WEAPON_KNIFE","WEAPON_KNUCKLE","WEAPON_MACHETE","WEAPON_MACHINEPISTOL","WEAPON_MARKSMANPISTOL","WEAPON_MARKSMANRIFLE",
		"WEAPON_MARKSMANRIFLE_MK2","WEAPON_MG","WEAPON_MICROSMG","WEAPON_MINIGUN","WEAPON_MINISMG","WEAPON_MOLOTOV","WEAPON_MUSKET",
		"WEAPON_NIGHTSTICK","WEAPON_PETROLCAN","WEAPON_PIPEBOMB","WEAPON_PISTOL","WEAPON_PISTOL_MK2","WEAPON_PISTOL50","WEAPON_POOLCUE",
		"WEAPON_PROXMINE","WEAPON_PUMPSHOTGUN","WEAPON_PUMPSHOTGUN_MK2","WEAPON_RAILGUN","WEAPON_RAYCARBINE","WEAPON_RAYMINIGUN",
		"WEAPON_RAYPISTOL","WEAPON_REVOLVER","WEAPON_REVOLVER_MK2","WEAPON_RPG","WEAPON_SAWNOFFSHOTGUN","WEAPON_SMG","WEAPON_SMG_MK2",
		"WEAPON_SMOKEGRENADE","WEAPON_SNIPERRIFLE","WEAPON_SNSPISTOL","WEAPON_SNSPISTOL_MK2","WEAPON_SPECIALCARBINE",
		"WEAPON_SPECIALCARBINE_MK2","WEAPON_STICKYBOMB","WEAPON_STONE_HATCHET","WEAPON_STUNGUN","WEAPON_SWITCHBLADE",
		"WEAPON_VINTAGEPISTOL","WEAPON_WRENCH","WEAPON_aktamb","WEAPON_G3RELIKIASHOPFEMININO","WEAPON_ARRELIKIASHOPFEMININO1",
		"WEAPON_M4GOLD","WEAPON_HK417DENDE","WEAPON_GLOCKRELIKIASHOPFEMININO","WEAPON_SIG_MCX","WEAPON_BARRETMENGO","WEAPON_BCM4",
		"WEAPON_GLOCKNORM","WEAPON_GLOCKRAJADA","WEAPON_HK416","WEAPON_HKBOPE","WEAPON_M4BAL","WEAPON_M16A4CAMMO","WEAPON_M16A4TCP",
	}

	for _,Name in ipairs(List) do
		WeaponNames[GetHashKey(Name)] = Name
	end
end)

local function GetWeaponName(Hash)
	return WeaponNames[Hash] or ""
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOCATION
-----------------------------------------------------------------------------------------------------------------------------------------
local function GetLocation(Index)
	if Index == -1 then
		return Crash.Special
	end

	return Crash.Locations[Index]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROPS
-----------------------------------------------------------------------------------------------------------------------------------------
local function VehicleProp()
	return (Crash.Props[CrashType] or Crash.Props.heli).Vehicle
end

local function ChestProp(Custom)
	return Custom or (Crash.Props[CrashType] or Crash.Props.heli).Chest
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATEOBJECT
-----------------------------------------------------------------------------------------------------------------------------------------
local function CreateObject(Model,Coords)
	local Hash = GetHashKey(Model)
	RequestModel(Hash)
	while not HasModelLoaded(Hash) do
		Wait(10)
	end

	local Object = CreateObjectNoOffset(Hash,Coords.x,Coords.y,Coords.z,false,false,false)
	SetEntityLodDist(Object,0xFFFF)
	PlaceObjectOnGroundProperly(Object)
	FreezeEntityPosition(Object,true)
	SetEntityHeading(Object,Coords.h or 0.0)
	SetModelAsNoLongerNeeded(Hash)

	return Object
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TARGETZONE
-----------------------------------------------------------------------------------------------------------------------------------------
local function CreateTargetZone(Index,Coords)
	local Container = Crash.ChestPrefix..":"..Index
	exports.ox_target:addBoxZone({
		coords = vec3(Coords.x,Coords.y,Coords.z),
		size = vec3(2.25,1.25,2.0),
		rotation = Coords.h or 0.0,
		name = "core-crash:"..Index,
		options = {
			{
				name = "core-crash:open:"..Index,
				label = "Abrir",
				icon = "fa-solid fa-box",
				distance = 2.0,
				onSelect = function()
					TriggerEvent("chest:Open",Container,"Custom")
				end
			}
		}
	})
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVEOBJECTS
-----------------------------------------------------------------------------------------------------------------------------------------
local function RemoveObjects()
	if Objects.Vehicle then
		if DoesEntityExist(Objects.Vehicle) then
			DeleteEntity(Objects.Vehicle)
		end

		Objects.Vehicle = nil
	end

	for Index,Object in pairs(Objects) do
		exports.ox_target:removeZone("core-crash:"..Index)

		if DoesEntityExist(Object) then
			DeleteEntity(Object)
		end

		Objects[Index] = nil
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPAWNOBJECTS
-----------------------------------------------------------------------------------------------------------------------------------------
local function SpawnObjects(Location)
	if not Objects.Vehicle then
		Objects.Vehicle = CreateObject(VehicleProp(),Location.Vehicle)
	end

	for Index,Coords in ipairs(Location.Chests) do
		if not Objects[Index] then
			Objects[Index] = CreateObject(ChestProp(Coords.prop),Coords)
			CreateTargetZone(Index,Coords)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BLIPS
-----------------------------------------------------------------------------------------------------------------------------------------
local function RemoveBlips()
	if DoesBlipExist(Blip) then
		RemoveBlip(Blip)
		Blip = nil
	end

	if DoesBlipExist(BlipRadius) then
		RemoveBlip(BlipRadius)
		BlipRadius = nil
	end
end

local function CreateBlips(Coords)
	RemoveBlips()

	Blip = AddBlipForCoord(Coords.x,Coords.y,Coords.z)
	SetBlipSprite(Blip,43)
	SetBlipDisplay(Blip,4)
	SetBlipAsShortRange(Blip,true)
	SetBlipColour(Blip,49)
	SetBlipScale(Blip,1.0)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Crash")
	EndTextCommandSetBlipName(Blip)

	BlipRadius = AddBlipForRadius(Coords.x,Coords.y,Coords.z,Crash.AreaSize + 0.0)
	SetBlipColour(BlipRadius,49)
	SetBlipAlpha(BlipRadius,128)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETUP
-----------------------------------------------------------------------------------------------------------------------------------------
local function Setup(Index,Type)
	local Location = GetLocation(Index)
	if not Location or not Location.Vehicle then
		return false
	end

	Active = true
	Selected = Index
	CrashType = Type or "heli"

	CreateBlips(Location.Vehicle)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLEANUP
-----------------------------------------------------------------------------------------------------------------------------------------
local function Cleanup()
	Active = false
	Selected = 0
	CrashType = "heli"
	Inside = false

	RemoveBlips()
	RemoveObjects()
	SendNUIMessage({ action = "hide" })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-crash:spawn")
AddEventHandler("core-crash:spawn",function(Index,Type)
	Setup(Index,Type)
end)

RegisterNetEvent("core-crash:finished")
AddEventHandler("core-crash:finished",function()
	Cleanup()
end)

RegisterNetEvent("core-crash:timer")
AddEventHandler("core-crash:timer",function(Timer)
	SendNUIMessage({ action = "timer", timer = Timer })
end)

RegisterNetEvent("core-crash:newKill")
AddEventHandler("core-crash:newKill",function(Killer,Victim,Weapon)
	if Inside then
		SendNUIMessage({ action = "novakill", matador = Killer, morto = Victim, arma = Weapon })
	end
end)

RegisterNetEvent("core-crash:prepareRespawn")
AddEventHandler("core-crash:prepareRespawn",function()
	DoScreenFadeOut(250)
	Wait(500)
	DoScreenFadeIn(500)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MAIN THREAD
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local Sleep = 1000

		if Active then
			local Location = GetLocation(Selected)
			if Location and Location.Vehicle then
				local Coords = GetEntityCoords(PlayerPedId())
				local Distance = #(Coords - vector3(Location.Vehicle.x,Location.Vehicle.y,Location.Vehicle.z))

				if Distance <= Crash.SpawnDistance then
					Sleep = 500
					SpawnObjects(Location)

					if Distance <= Crash.AreaSize then
						if not Inside then
							Inside = true
							vSERVER.Enter()
						end
					elseif Inside then
						Inside = false
						vSERVER.Exit()
						SendNUIMessage({ action = "hide" })
					end
				else
					if Objects.Vehicle then
						RemoveObjects()
					end

					if Inside then
						Inside = false
						vSERVER.Exit()
						SendNUIMessage({ action = "hide" })
					end
				end
			end
		end

		Wait(Sleep)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GAMEEVENTTRIGGERED
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("gameEventTriggered",function(Name,Args)
	if Name ~= "CEventNetworkEntityDamage" or not Inside then
		return false
	end

	local Victim = Args[1]
	local Attacker = Args[2]
	if not IsEntityAPed(Victim) or GetEntityHealth(Victim) > 101 then
		return false
	end

	local Ped = PlayerPedId()

	if Ped == Attacker and Victim ~= Attacker and IsPedAPlayer(Victim) then
		local Now = GetGameTimer()
		if KillCooldown < Now then
			KillCooldown = Now + 1000

			local Index = NetworkGetPlayerIndexFromPed(Victim)
			vSERVER.DeathLog(GetPlayerServerId(Index),GetWeaponName(GetSelectedPedWeapon(Attacker)))
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESPAWN WATCHER
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	local Requested = false
	while true do
		local Sleep = 1000

		if Active and Inside then
			Sleep = 500

			if IsEntityDead(PlayerPedId()) then
				if not Requested then
					Requested = true
					vSERVER.QueueRespawn()
				end
			else
				Requested = false
			end
		end

		Wait(Sleep)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INIT
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	Wait(1000)

	local State = GlobalState["CoreCrash"]
	if State and State.active then
		Setup(State.selected,State.crashType)
	end
end)
