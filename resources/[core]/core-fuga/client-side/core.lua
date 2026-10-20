local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local SavedVehicleInfo = nil
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUGA:SALVAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("fuga:salvar")
AddEventHandler("fuga:salvar",function()
	local Ped = PlayerPedId()

	if IsPedInAnyVehicle(Ped,false) then
		local Veh = GetVehiclePedIsUsing(Ped)
		local Coords = GetEntityCoords(Veh)
		local Heading = GetEntityHeading(Veh)

		SavedVehicleInfo = {
			coords = Coords,
			heading = Heading
		}

		TriggerEvent("Notify","Fuga","Posição salva.","verde",5000)
	else
		TriggerEvent("Notify","Fuga","Você precisa estar em um veículo.","vermelho",5000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUGA:VOLTAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("fuga:voltar")
AddEventHandler("fuga:voltar",function()
	local Ped = PlayerPedId()

	if not SavedVehicleInfo then
		TriggerEvent("Notify","Fuga","Nenhuma posição salva.","vermelho",5000)
		return
	end

	if IsPedInAnyVehicle(Ped,false) then
		local Veh = GetVehiclePedIsUsing(Ped)

		SetVehicleForwardSpeed(Veh,0.0)
		SetVehicleSteeringAngle(Veh,0.0)

		SetEntityCoordsNoOffset(Veh,SavedVehicleInfo.coords.x,SavedVehicleInfo.coords.y,SavedVehicleInfo.coords.z,false,false,false)
		SetEntityHeading(Veh,SavedVehicleInfo.heading)
		SetVehicleOnGroundProperly(Veh)

		SetVehicleFixed(Veh)
		SetVehicleDeformationFixed(Veh)
		SetVehicleUndriveable(Veh,false)
		SetVehicleEngineOn(Veh,true,true,false)
		SetVehicleDirtLevel(Veh,0.0)
		SetVehicleBodyHealth(Veh,1000.0)
		SetVehicleEngineHealth(Veh,1000.0)
		SetVehiclePetrolTankHealth(Veh,1000.0)

		TriggerEvent("Notify","Fuga","Teleportado para posição salva.","verde",5000)
	else
		TriggerEvent("Notify","Fuga","Você precisa estar em um veículo.","vermelho",5000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUGA:CORRER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("fuga:correr")
AddEventHandler("fuga:correr",function()
	local Ped = PlayerPedId()

	if IsPedInAnyVehicle(Ped,false) then
		local Veh = GetVehiclePedIsUsing(Ped)

		SetEntityMaxSpeed(Veh,2500.0)
		SetVehicleEnginePowerMultiplier(Veh,200.0)
		SetVehicleEngineTorqueMultiplier(Veh,200.0)

		TriggerEvent("Notify","Fuga","Velocidade máxima aumentada.","verde",5000)
	else
		TriggerEvent("Notify","Fuga","Você precisa estar em um veículo.","vermelho",5000)
	end
end)
