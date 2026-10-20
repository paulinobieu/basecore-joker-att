-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
Types = ""
Actived = false
local Swimming = false
local ShotDelay = GetGameTimer()
local Settings = Inventory.Gameplay
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADBLOCKBUTTONS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local TimeDistance = 999
		local Ped = PlayerPedId()
		if LocalPlayer["state"]["Buttons"] then
			for _,Control in ipairs(Settings.BlockedControls) do
				DisableControlAction(0,Control,true)
			end

			DisablePlayerFiring(Ped,true)

			TimeDistance = 1
		end

		Wait(TimeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:CLEARNER
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("inventory:Cleaner",function(Ped)
	TriggerEvent("hud:Weapon",false)
	RemoveAllPedWeapons(Ped,true)
	TriggerEvent("Weapon","")
	Actived = false
	Weapon = ""
	Types = ""
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:REPAIRBOOSTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:RepairBoosts")
AddEventHandler("inventory:RepairBoosts",function(Index,Plate)
	if NetworkDoesNetworkIdExist(Index) then
		local Vehicle = NetToEnt(Index)
		if DoesEntityExist(Vehicle) and GetVehicleNumberPlateText(Vehicle) == Plate then
			local Tyres = {}

			for i = 0,7 do
				local Status = false

				if GetTyreHealth(Vehicle,i) ~= Settings.Vehicle.TyreHealth then
					Status = true
				end

				Tyres[i] = Status
			end

			local Fuel = GetVehicleFuelLevel(Vehicle)

			SetVehicleUndriveable(Vehicle,false)
			SetVehicleFixed(Vehicle)
			SetVehicleDirtLevel(Vehicle,0.0)
			SetVehicleDeformationFixed(Vehicle)
			SetVehicleFuelLevel(Vehicle,Fuel)

			for Tyre,Burst in pairs(Tyres) do
				if Burst then
					SetVehicleTyreBurst(Vehicle,Tyre,true,Settings.Vehicle.TyreHealth)
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:REPAIRTYRES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:RepairTyres")
AddEventHandler("inventory:RepairTyres",function(Vehicle,Tyres,Plate)
	if NetworkDoesNetworkIdExist(Vehicle) then
		local Vehicle = NetToEnt(Vehicle)
		if DoesEntityExist(Vehicle) and GetVehicleNumberPlateText(Vehicle) == Plate then
			if Tyres == "All" then
				for i = 0,10 do
					if GetTyreHealth(Vehicle,i) ~= Settings.Vehicle.TyreHealth then
						SetVehicleTyreFixed(Vehicle,i)
					end
				end
			else
				for i = 0,10 do
					if GetTyreHealth(Vehicle,i) ~= Settings.Vehicle.TyreHealth then
						SetVehicleTyreBurst(Vehicle,i,true,Settings.Vehicle.TyreHealth)
					end
				end

				SetVehicleTyreFixed(Vehicle,Tyres)
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:REPAIRDEFAULT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:RepairDefault")
AddEventHandler("inventory:RepairDefault",function(Index,Plate)
	if NetworkDoesNetworkIdExist(Index) then
		local Vehicle = NetToEnt(Index)
		if DoesEntityExist(Vehicle) and GetVehicleNumberPlateText(Vehicle) == Plate then
			SetVehicleEngineHealth(Vehicle,1000.0)
			SetVehicleBodyHealth(Vehicle,1000.0)
			SetEntityHealth(Vehicle,1000)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:REPAIRADMIN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:RepairAdmin")
AddEventHandler("inventory:RepairAdmin",function(Index,Plate)
	if NetworkDoesNetworkIdExist(Index) then
		local Vehicle = NetToEnt(Index)
		if DoesEntityExist(Vehicle) and GetVehicleNumberPlateText(Vehicle) == Plate then
			local Fuel = GetVehicleFuelLevel(Vehicle)

			SetVehicleUndriveable(Vehicle,false)
			SetVehicleFixed(Vehicle)
			SetVehicleDirtLevel(Vehicle,0.0)
			SetVehicleDeformationFixed(Vehicle)
			SetVehicleFuelLevel(Vehicle,Fuel)

			TriggerEvent("target:RollVehicle",Index)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- WAYPOINT
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Waypoint(Coords)
	if Coords.x ~= 0.0 and Coords.y ~= 0.0 then
		SetNewWaypoint(Coords.x + 0.0001,Coords.y + 0.0001)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:EXPLODETYRES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:explodeTyres")
AddEventHandler("inventory:explodeTyres",function(Network,Plate,Tyre)
	if NetworkDoesNetworkIdExist(Network) then
		local Vehicle = NetToEnt(Network)
		if DoesEntityExist(Vehicle) and GetVehicleNumberPlateText(Vehicle) == Plate then
			SetVehicleTyreBurst(Vehicle,Tyre,true,Settings.Vehicle.TyreHealth)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TYRELIST
-----------------------------------------------------------------------------------------------------------------------------------------
local TyreList = {
	["wheel_lf"] = 0,
	["wheel_rf"] = 1,
	["wheel_lm"] = 2,
	["wheel_rm"] = 3,
	["wheel_lr"] = 4,
	["wheel_rr"] = 5
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- TYRES
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Tyres()
	local Ped = PlayerPedId()
	if not IsPedInAnyVehicle(Ped) then
		local Vehicle,Model = Framework.ClosestVehicle(Settings.Vehicle.SearchDistance)
		if IsEntityAVehicle(Vehicle) then
			local Coords = GetEntityCoords(Ped)

			for Index,Tyre in pairs(TyreList) do
				local Selected = GetEntityBoneIndexByName(Vehicle,Index)
				if Selected ~= -1 then
					local CoordsWheel = GetWorldPositionOfEntityBone(Vehicle,Selected)
				if #(Coords - CoordsWheel) <= Settings.Vehicle.TyreDistance and GetTyreHealth(Vehicle,Tyre) ~= Settings.Vehicle.TyreHealth then
						return Vehicle,Tyre,VehToNet(Vehicle),GetVehicleNumberPlateText(Vehicle),Model
					end
				end
			end
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TYREHEALTH
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.tyreHealth(Network,Tyre)
	if NetworkDoesNetworkIdExist(Network) then
		local Vehicle = NetToEnt(Network)
		if DoesEntityExist(Vehicle) then
			return GetTyreHealth(Vehicle,Tyre)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OBJECTEXISTS
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.ObjectExists(Coords,Hash,Distance)
	return DoesObjectOfTypeExistAtCoords(Coords[1],Coords[2],Coords[3],Distance or Settings.Vehicle.ObjectDistance,Hash,true)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKINTERIOR
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.CheckInterior()
	return GetInteriorFromEntity(PlayerPedId()) ~= 0
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CEVENTGUNSHOT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("CEventGunShot",function(_,OtherPeds)
	local Ped = PlayerPedId()
	if Ped == OtherPeds and not LocalPlayer.state.Banned and not LocalPlayer.state.Arena and not Framework.IsInCoreGameMatch() and not CheckPolice() and GetGameTimer() >= ShotDelay and Weapon ~= Settings.Gunshots.IgnoredWeapon then
		ShotDelay = GetGameTimer() + Settings.Gunshots.Cooldown
		TriggerEvent("player:Residual",Settings.Gunshots.Residual)

		local Coords = GetEntityCoords(Ped)
		local InVehicle = IsPedInAnyVehicle(Ped)
		if not IsPedCurrentWeaponSilenced(Ped) then
			Framework.Server.ShotsFired(InVehicle)
		elseif math.random(100) <= Settings.Gunshots.SilencedChance then
			Framework.Server.ShotsFired(InVehicle)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESTAURANTE:POLYZONE
-----------------------------------------------------------------------------------------------------------------------------------------
local Restaurante = PolyZone:Create(Inventory.Gameplay.Restaurant.Points,{ name = Inventory.Gameplay.Restaurant.Name })
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESTAURANT
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Restaurant()
	local Ped = PlayerPedId()
	local Coords = GetEntityCoords(Ped)

	return Restaurante:isPointInside(Coords)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADLEAVESERVICE
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local Ped = PlayerPedId()
		if not IsPedInAnyVehicle(Ped) then
			if IsPedSwimming(Ped) then
				if not Swimming and not ScubaTank and not ScubaMask then
					Swimming = true
					Framework.Server.Swimming()
				end
			elseif Swimming then
				Swimming = false
			end
		end

		Wait(Settings.SwimmingInterval)
	end
end)
