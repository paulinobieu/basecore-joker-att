-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local policeRadar  = false
local policeFreeze = false
local LastFront    = nil
local LastRear     = nil
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOGGLE RADAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("toggleRadar", function()
	local Ped = PlayerPedId()
	if not IsPedInAnyVehicle(Ped, false) then return end
	policeRadar = not policeRadar
	if not policeRadar then
		LastFront = nil
		LastRear  = nil
		SendNUIMessage({ action = "set:radar", payload = nil })
	end
	TriggerEvent("Notify", "Radar", "Radar de velocidade " .. (policeRadar and "ativado" or "desativado") .. ".", "verde", 3000)
end)
RegisterKeyMapping("toggleRadar", "Ligar/desligar radar de velocidade.", "keyboard", "N")
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOGGLE FREEZE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("toggleFreeze", function()
	local Ped = PlayerPedId()
	if not IsPedInAnyVehicle(Ped, false) then return end
	policeFreeze = not policeFreeze
	TriggerEvent("Notify", "Radar", "Congelamento de radar " .. (policeFreeze and "ativado" or "desativado") .. ".", "amarelo", 3000)
end)
RegisterKeyMapping("toggleFreeze", "Congelar/descongelar leitura do radar.", "keyboard", "M")
-----------------------------------------------------------------------------------------------------------------------------------------
-- HELPERS
-----------------------------------------------------------------------------------------------------------------------------------------
local function CapsuleScan(Vehicle, OffsetY)
	local Dimension = GetOffsetFromEntityInWorldCoords(Vehicle, 0.0, 1.0, 1.0)
	local Target    = GetOffsetFromEntityInWorldCoords(Vehicle, 0.0, OffsetY, 0.0)
	local Shape     = StartShapeTestCapsule(Dimension, Target, 3.0, 10, Vehicle, 7)
	local _, _, _, _, Entity = GetShapeTestResult(Shape)
	if IsEntityAVehicle(Entity) then
		local Speed = GetEntitySpeed(Entity) * 3.6
		local Plate = GetVehicleNumberPlateText(Entity)
		local ModelHash = GetEntityModel(Entity)
		return {
			speed   = math.floor(Speed),
			plate   = Plate,
			vehicle = GetDisplayNameFromVehicleModel(ModelHash) or "",
		}
	end
	return nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RADAR THREAD
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local Ped = PlayerPedId()

		if policeRadar and IsPedInAnyVehicle(Ped, false) then
			local Vehicle = GetVehiclePedIsIn(Ped, false)
			if CheckPolice and CheckPolice(Vehicle) then
				if not policeFreeze then
					local FrontData = CapsuleScan(Vehicle, 105.0)
					local RearData  = CapsuleScan(Vehicle, -105.0)

					if FrontData then LastFront = FrontData end
					if RearData  then LastRear  = RearData  end
				end

				SendNUIMessage({ action = "set:radar", payload = {
					front = LastFront,
					rear  = LastRear,
				}})

				Wait(100)
			else
				SendNUIMessage({ action = "set:radar", payload = nil })
				Wait(1000)
			end
		else
			if not IsPedInAnyVehicle(Ped, false) then
				policeRadar = false
				LastFront   = nil
				LastRear    = nil
				SendNUIMessage({ action = "set:radar", payload = nil })
			end
			Wait(1000)
		end
	end
end)
