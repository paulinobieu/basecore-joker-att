if Config.EnablePnb then
	local RATE_LIMIT_MS = 120
	local playerLastTriggerTime = {}
	local installedPlates = {}

	function GetCurrentTime()
		return GetGameTimer()
	end

	function NormalizePlate(input)
		if type(input) == "table" then
			input = input.plate or input.plateNumber or input.value
		end
		
		if type(input) ~= "string" then
			return ""
		end
		
		local normalized = input:gsub("%s+", "")
		return normalized:upper()
	end

	function GetVehicleFromNetId(netId)
		if type(netId) ~= "number" then
			return nil
		end
		
		if NetworkDoesNetworkIdExist and not NetworkDoesNetworkIdExist(netId) then
			return nil
		end
		
		local vehicle = NetworkGetEntityFromNetworkId(netId)
		if not vehicle or vehicle == 0 then
			return nil
		end
		
		if not DoesEntityExist(vehicle) then
			return nil
		end
		
		return vehicle
	end

	function IsPlayerDrivingVehicle(playerId, vehicle)
		local ped = GetPlayerPed(playerId)
		if ped == 0 then
			return false
		end
		
		local playerVehicle = GetVehiclePedIsIn(ped, false)
		if playerVehicle ~= vehicle then
			return false
		end
		
		local driver = GetPedInVehicleSeat(vehicle, -1)
		return driver == ped
	end

	function SetVehiclePnbState(vehicle, isInstalled)
		if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
			local entityState = Entity(vehicle).state
			if entityState and entityState.set then
				entityState:set("pnb_installed", isInstalled == true, true)
			end
		end
	end

	function BroadcastPlateSync(plate, isInstalled)
		plate = NormalizePlate(plate)
		if plate == "" then
			return
		end
		
		TriggerClientEvent("thunder-pnb:syncInstalledPlate", -1, plate, isInstalled == true)
	end

	function SendAllInstalledPlates(playerId)
		local plateList = {}
		
		for plate, isInstalled in pairs(installedPlates) do
			if isInstalled then
				plateList[#plateList + 1] = plate
			end
		end
		
		TriggerClientEvent("thunder-pnb:syncInstalledAll", playerId or -1, plateList)
	end

	function SetPlateInstalled(plate, isInstalled, vehicleNetId)
		plate = NormalizePlate(plate)
		if plate == "" then
			return false
		end
		
		if isInstalled then
			installedPlates[plate] = true
		else
			installedPlates[plate] = nil
		end
		
		local vehicle = vehicleNetId and GetVehicleFromNetId(vehicleNetId)
		if vehicle then
			SetVehiclePnbState(vehicle, isInstalled)
		end
		
		BroadcastPlateSync(plate, isInstalled)
		return true
	end

	function RenamePlate(oldPlate, newPlate, vehicleNetId)
		oldPlate = NormalizePlate(oldPlate)
		newPlate = NormalizePlate(newPlate)
		
		if oldPlate == "" or newPlate == "" then
			return false
		end
		
		installedPlates[oldPlate] = nil
		installedPlates[newPlate] = true
		
		local vehicle = vehicleNetId and GetVehicleFromNetId(vehicleNetId)
		if vehicle then
			SetVehiclePnbState(vehicle, true)
		end
		
		BroadcastPlateSync(oldPlate, false)
		BroadcastPlateSync(newPlate, true)
		
		return true
	end

	function SendChatMessage(playerId, message)
		TriggerClientEvent("chat:addMessage", playerId, {
			args = {"^6PNB", message}
		})
	end

	RegisterNetEvent("thunder-pnb:resultGetPlayers")
	AddEventHandler("thunder-pnb:resultGetPlayers", function(vehicleNetId, nearbyPlayers)
		local playerId = source
		local currentTime = GetCurrentTime()
		
		local lastTime = playerLastTriggerTime[playerId] or 0
		if currentTime < lastTime + RATE_LIMIT_MS then
			return
		end
		
		playerLastTriggerTime[playerId] = currentTime
		
		local vehicle = GetVehicleFromNetId(vehicleNetId)
		if not vehicle then
			return
		end
		
		if not IsPlayerDrivingVehicle(playerId, vehicle) then
			return
		end
		
		if type(nearbyPlayers) ~= "table" or next(nearbyPlayers) == nil then
			TriggerClientEvent("pnb:ownerNitroBlink", -1, vehicleNetId)
			return
		end
		
		TriggerClientEvent("pnb:ownerNitroBlink", playerId, vehicleNetId)
		
		local count = 0
		for _, targetPlayerId in ipairs(nearbyPlayers) do
			targetPlayerId = tonumber(targetPlayerId)
			if targetPlayerId and targetPlayerId ~= playerId then
				TriggerClientEvent("pnb:ownerNitroBlink", targetPlayerId, vehicleNetId)
				count = count + 1
				if count > 64 then
					break
				end
			end
		end
	end)

	RegisterNetEvent("pnb:triggerBackfire", function(vehicleNetId)
		local playerId = source
		local currentTime = GetCurrentTime()
		
		local lastTime = playerLastTriggerTime[playerId] or 0
		if currentTime < lastTime + RATE_LIMIT_MS then
			return
		end
		
		playerLastTriggerTime[playerId] = currentTime
		
		local vehicle = GetVehicleFromNetId(vehicleNetId)
		if not vehicle then
			return
		end
		
		if not IsPlayerDrivingVehicle(playerId, vehicle) then
			return
		end
		
		TriggerClientEvent("pnb:ownerNitroBlink", -1, vehicleNetId)
	end)

	RegisterNetEvent("thunder-pnb:installByPlate", function(plate, vehicleNetId)
		SetPlateInstalled(plate, true, vehicleNetId)
	end)

	RegisterNetEvent("thunder-pnb:removeByPlate", function(plate, vehicleNetId)
		SetPlateInstalled(plate, false, vehicleNetId)
	end)

	RegisterNetEvent("thunder-pnb:renamePlate", function(oldPlate, newPlate, vehicleNetId)
		RenamePlate(oldPlate, newPlate, vehicleNetId)
	end)

	RegisterNetEvent("thunder-pnb:requestInstalledSync", function()
		SendAllInstalledPlates(source)
	end)

	exports("SetAllInstalled", function(plates)
		installedPlates = {}
		local count = 0
		
		if type(plates) == "table" then
			for key, value in pairs(plates) do
				local plate
				if type(key) == "string" and value then
					plate = NormalizePlate(key)
				else
					plate = NormalizePlate(value)
				end
				
				if plate ~= "" and not installedPlates[plate] then
					installedPlates[plate] = true
					count = count + 1
				end
			end
		else
			local plate = NormalizePlate(plates)
			if plate ~= "" then
				installedPlates[plate] = true
				count = 1
			end
		end
		
		SendAllInstalledPlates()
		return true, count
	end)

	exports("AddInstalled", function(plate)
		return SetPlateInstalled(plate, true, nil)
	end)

	exports("RemoveInstalled", function(plate)
		return SetPlateInstalled(plate, false, nil)
	end)

	exports("SetInstalledByPlate", function(plate, isInstalled, vehicleNetId)
		return SetPlateInstalled(plate, isInstalled, vehicleNetId)
	end)

	exports("InstallByPlate", function(plate, vehicleNetId)
		return SetPlateInstalled(plate, true, vehicleNetId)
	end)

	exports("RemoveByPlate", function(plate, vehicleNetId)
		return SetPlateInstalled(plate, false, vehicleNetId)
	end)

	exports("IsInstalled", function(plate)
		plate = NormalizePlate(plate)
		if plate == "" then
			return false
		end
		return installedPlates[plate] == true
	end)

	exports("GetAllInstalled", function()
		local result = {}
		for plate, isInstalled in pairs(installedPlates) do
			if isInstalled then
				result[#result + 1] = plate
			end
		end
		return result
	end)

	exports("InstallCurrentVehicle", function(playerId)
		local ped = GetPlayerPed(playerId)
		local vehicle = GetVehiclePedIsIn(ped, false)
		
		if vehicle == 0 or GetPedInVehicleSeat(vehicle, -1) ~= ped then
			return false
		end
		
		local plate = NormalizePlate(GetVehicleNumberPlateText(vehicle))
		installedPlates[plate] = true
		
		SetVehiclePnbState(vehicle, true)
		BroadcastPlateSync(plate, true)
		
		return true
	end)

	exports("RemoveCurrentVehicle", function(playerId)
		local ped = GetPlayerPed(playerId)
		local vehicle = GetVehiclePedIsIn(ped, false)
		
		if vehicle == 0 or GetPedInVehicleSeat(vehicle, -1) ~= ped then
			return false
		end
		
		local plate = NormalizePlate(GetVehicleNumberPlateText(vehicle))
		installedPlates[plate] = nil
		
		SetVehiclePnbState(vehicle, false)
		BroadcastPlateSync(plate, false)
		
		return true
	end)

	exports("RenameInstalledPlate", function(oldPlate, newPlate, vehicleNetId)
		return RenamePlate(oldPlate, newPlate, vehicleNetId)
	end)

	exports("IsPnbInstalled", function(input)
		if type(input) == "string" then
			local plate = NormalizePlate(input)
			return installedPlates[plate] == true
		elseif type(input) == "number" then
			local ped = GetPlayerPed(input)
			local vehicle = GetVehiclePedIsIn(ped, false)
			
			if vehicle == 0 then
				return false
			end
			
			local plate = NormalizePlate(GetVehicleNumberPlateText(vehicle))
			return installedPlates[plate] == true
		elseif type(input) == "table" and input.plate then
			local plate = NormalizePlate(input.plate)
			return installedPlates[plate] == true
		end
		
		return false
	end)

	RegisterCommand("pnb_test", function(playerId)
		local ped = GetPlayerPed(playerId)
		local vehicle = GetVehiclePedIsIn(ped, false)
		
		if vehicle == 0 then
			return SendChatMessage(playerId, "Entre como motorista.")
		end
		
		local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
		TriggerClientEvent("pnb:ownerNitroBlink", -1, vehicleNetId)
		SendChatMessage(playerId, "Backfire (teste) enviado (broadcast).")
	end, false)

	RegisterCommand("pnb_fx", function(playerId)
		local ped = GetPlayerPed(playerId)
		local vehicle = GetVehiclePedIsIn(ped, false)
		
		if vehicle == 0 then
			return SendChatMessage(playerId, "Entre como motorista.")
		end
		
		local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
		TriggerClientEvent("pnb:ownerNitroBlink", -1, vehicleNetId)
		SendChatMessage(playerId, "Fogo (teste) enviado (broadcast).")
	end, false)
end

---------------------------------------------------------------------------------------------------------------------------------------
-- AUTH / WEBHOOK
---------------------------------------------------------------------------------------------------------------------------------------
