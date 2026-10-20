-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Name = nil
local Amounts = 1
local Selected = 1
local Active = false
local Experience = 1
local Vehicle = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- PEDS
-----------------------------------------------------------------------------------------------------------------------------------------
local Peds = Inventory.Dismantle.Peds
-----------------------------------------------------------------------------------------------------------------------------------------
-- WEAPONS
-----------------------------------------------------------------------------------------------------------------------------------------
local Weapons = Inventory.Dismantle.Weapons
-----------------------------------------------------------------------------------------------------------------------------------------
-- CATEGORY
-----------------------------------------------------------------------------------------------------------------------------------------
local Category = Inventory.Dismantle.Categories
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISMANTLE
-----------------------------------------------------------------------------------------------------------------------------------------
local Dismantle = Inventory.Dismantle.Locations
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISMANTLE
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Dismantle()
	if not Active then
		Experience = Framework.Server.Experience()
		local Level = Framework.ClassCategory(Experience)
		local RandLevels = math.random(Level)
		local Model = math.random(#Category[RandLevels])

		Selected = math.random(#Dismantle)
		Name = Category[RandLevels][Model]
		Active = true
		Amounts = 1

		if Level == 3 or Level == 4 then
			Amounts = 2
		elseif Level == 5 or Level == 6 then
			Amounts = 3
		elseif Level == 7 or Level == 8 then
			Amounts = 4
		elseif Level == 9 or Level == 10 then
			Amounts = 5
		end

		TriggerEvent("NotifyPush",{ code = 20, title = "Localização Veículo", x = Dismantle[Selected]["x"], y = Dismantle[Selected]["y"], z = Dismantle[Selected]["z"], color = 44 })

		return true
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISMANTLE:RESET
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("dismantle:Reset")
AddEventHandler("dismantle:Reset",function()
	Name = nil
	Amounts = 1
	Selected = 1
	Active = false
	Vehicle = false
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADDISMANTLE
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		if Active and not Vehicle then
			local Ped = PlayerPedId()
			if #(GetEntityCoords(Ped) - Dismantle[Selected]["xyz"]) <= 75 then
				Vehicle = Framework.Server.CreateVehicle(Name,Dismantle[Selected],Experience)

				SetTimeout(1000,function()
					local Network = NetToEnt(Vehicle)

					SetVehicleHasBeenOwnedByPlayer(Network,true)
					SetVehicleNeedsToBeHotwired(Network,false)
					DecorSetInt(Network,"Player_Vehicle",-1)
					SetVehRadioStation(Network,"OFF")

					SetVehicleModKit(Network,0)
					ToggleVehicleMod(Network,18,true)
					SetVehicleMod(Network,11,GetNumVehicleMods(Network,11) - 1,false)
					SetVehicleMod(Network,12,GetNumVehicleMods(Network,12) - 1,false)
					SetVehicleMod(Network,13,GetNumVehicleMods(Network,13) - 1,false)
					SetVehicleMod(Network,15,GetNumVehicleMods(Network,15) - 1,false)
				end)
			end
		end

		Wait(1000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISMANTLE:DISPATCH
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("dismantle:Dispatch")
AddEventHandler("dismantle:Dispatch",function()
	local Ped = PlayerPedId()
	local Coords = GetEntityCoords(Ped)

	for Number = 1,Amounts do
		local FoundSafe = false
		local SpawnPosition = nil

		repeat
			local x = Coords.x + math.random(-25,25)
			local y = Coords.y + math.random(-25,25)
			local z = Coords.z

			local Hitz,Groundz = GetGroundZFor_3dCoord(x,y,z,true)
			local SafeHitz,SafeCoords = GetSafeCoordForPed(x,y,Groundz,false,16)

			if Hitz and SafeHitz and IsPointOnRoad(SafeCoords.x,SafeCoords.y,SafeCoords.z,0) then
				FoundSafe = true
				SpawnPosition = SafeCoords
			end
		until FoundSafe

		local Model = Peds[math.random(#Peds)]
		if FoundSafe and SpawnPosition and Framework.LoadModel(Model) then
			local Entitys = CreatePed(6,Model,SpawnPosition.x,SpawnPosition.y,SpawnPosition.z,0.0,true,false)

			SetPedArmour(Entitys,100)
			SetPedAccuracy(Entitys,90)
			SetPedMaxHealth(Entitys,500)
			SetEntityHealth(Entitys,500)

			SetPedCombatAttributes(Entitys,5,true)
			SetPedCombatAttributes(Entitys,13,true)
			SetPedCombatAttributes(Entitys,25,true)
			SetPedCombatAttributes(Entitys,46,true)

			SetPedAlertness(Entitys,3)
			SetPedKeepTask(Entitys,true)
			SetPedCombatRange(Entitys,1)
			SetPedCombatAbility(Entitys,3)
			SetPedCanRagdoll(Entitys,false)
			SetPedCombatMovement(Entitys,3)
			SetPedSeeingRange(Entitys,150.0)
			SetPedHearingRange(Entitys,150.0)
			SetPedCanBeTargetted(Entitys,true)
			SetPedCanEvasiveDive(Entitys,true)
			SetPedTargetLossResponse(Entitys,1)
			SetPedFiringPattern(Entitys,0xC6EE6B4C)
			SetPedSuffersCriticalHits(Entitys,false)
			SetPedDropsWeaponsWhenDead(Entitys,false)
			SetPedRelationshipGroupHash(Entitys,-276063219)

			local Rand = math.random(#Weapons)
			GiveWeaponToPed(Entitys,Weapons[Rand],250,false,true)
			SetCurrentPedWeapon(Entitys,Weapons[Rand],true)
			SetPedInfiniteAmmo(Entitys,true,Weapons[Rand])
			SetPedCanSwitchWeapon(Entitys,true)

			TaskCombatHatedTargetsAroundPed(Entitys,150.0,0)

			Wait(250)
		end
	end
end)
