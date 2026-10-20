if Config.EnablePassengerLite then
	CreateThread(function()
		while true do
			SetGlobalPassengerMassMultiplier(0.0)
			Wait(Config.PassengerLite.WaitTime)
		end
	end)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- ANTI BUMP
-----------------------------------------------------------------------------------------------------------------------------------------
if Config.EnableAntiBump then
	local processedVehicles = {}

	function ApplyAntiBumpHandling(vehicle)
		pcall(function()
			SetVehicleHandlingInt(vehicle, "CCarHandlingData", "strAdvancedFlags", 134217728)
		end)
	end

	CreateThread(function()
		while true do
			local playerPed = PlayerPedId()
			local currentVehicle = GetVehiclePedIsIn(playerPed, false)
			
			if currentVehicle ~= 0 and not processedVehicles[currentVehicle] then
				ApplyAntiBumpHandling(currentVehicle)
				processedVehicles[currentVehicle] = true
			end
			
			Wait(Config.AntiBump.TimeThread)
		end
	end)

	AddEventHandler("onResourceStop", function(resourceName)
		if resourceName == GetCurrentResourceName() then
			processedVehicles = {}
		end
	end)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- DEL PROPS
-----------------------------------------------------------------------------------------------------------------------------------------
if Config.EnableDelProps then
	AddEventHandler("entityDamaged", function(damagedEntity)
		local entityModel = GetEntityModel(damagedEntity)
		
		for _, propHash in pairs(Config.DelProps.PropsToRemove) do
			local propModel = tonumber(propHash)
			
			if propModel == entityModel then
				while DoesEntityExist(damagedEntity) and HasEntityBeenDamagedByAnyVehicle(damagedEntity) do
					Wait(Config.DelProps.TimeToRemove)
					SetEntityAsMissionEntity(damagedEntity)
					DeleteObject(damagedEntity)
					Wait(1)
				end
				break
			end
		end
	end)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- POPS & BANGS
-----------------------------------------------------------------------------------------------------------------------------------------
if Config.EnablePnb then
	local PlayerPedId = PlayerPedId
	local GetGameTimer = GetGameTimer
	local GetVehiclePedIsIn = GetVehiclePedIsIn
	local GetPedInVehicleSeat = GetPedInVehicleSeat
	local DoesEntityExist = DoesEntityExist
	local GetEntityCoords = GetEntityCoords
	local GetEntityModel = GetEntityModel
	local GetVehicleClass = GetVehicleClass
	local GetEntitySpeed = GetEntitySpeed
	local IsPedInAnyVehicle = IsPedInAnyVehicle
	local IsControlPressed = IsControlPressed
	local GetVehicleCurrentGear = GetVehicleCurrentGear
	local GetVehicleCurrentRpm = GetVehicleCurrentRpm
	local GetIsVehicleEngineRunning = GetIsVehicleEngineRunning
	local VehToNet = VehToNet
	local NetToVeh = NetToVeh
	local PlaySoundFromEntity = PlaySoundFromEntity
	local GetDisplayNameFromVehicleModel = GetDisplayNameFromVehicleModel
	local GetVehicleNumberPlateText = GetVehicleNumberPlateText
	local RequestNamedPtfxAsset = RequestNamedPtfxAsset
	local HasNamedPtfxAssetLoaded = HasNamedPtfxAssetLoaded
	local GetVehicleMaxNumberOfPassengers = GetVehicleMaxNumberOfPassengers
	local GetPlayerServerId = GetPlayerServerId
	local NetworkGetPlayerIndexFromPed = NetworkGetPlayerIndexFromPed
	local NetworkIsPlayerConnected = NetworkIsPlayerConnected
	local NetworkDoesNetworkIdExist = NetworkDoesNetworkIdExist
	local IsPedAPlayer = IsPedAPlayer
	local GetGamePool = GetGamePool

	local KEY_ACCELERATE = 71
	local KEY_HANDBRAKE = 76

	local installedPlates = {}
	local isPopping = false
	local wasAccelerating = false
	local lastGear = nil
	local isHandbrakeActive = false
	local currentVehicle = 0
	local isDriver = false
	local currentPlate = nil
	local canUsePnb = false

	local lastSpeedCheckVehicle = 0
	local lastSpeedCheckTime = 0
	local cachedSpeedKmh = 0.0

	local PTFX_ASSET = "veh_xs_vehicle_mods"
	local BLINK_DURATION = 250

	LocalPlayer.state:set("PnbNitro", false, true)

	function NormalizePlate(plate)
		if not plate then
			plate = ""
		end
		local normalized = plate:gsub("%s+", "")
		return normalized:upper()
	end

	function LoadPtfxAsset()
		if HasNamedPtfxAssetLoaded(PTFX_ASSET) then
			return true
		end
		
		RequestNamedPtfxAsset(PTFX_ASSET)
		local timeout = GetGameTimer() + 3000
		
		while not HasNamedPtfxAssetLoaded(PTFX_ASSET) do
			Wait(0)
			if GetGameTimer() > timeout then
				return false
			end
		end
		
		return true
	end

	function SetVehicleNeonLight(vehicle, enabled, scaleX, scaleY, scaleZ, toggle)
		scaleX = scaleX or 1.0
		scaleY = scaleY or 1.0
		scaleZ = scaleZ or 1.0
		toggle = toggle or false
		
		Citizen.InvokeNative(-3969440698992794099, vehicle, enabled or false, math.max(scaleX, 0.05), scaleY, scaleZ, toggle)
	end

	function TriggerNitroVisualBlink(vehicle)
		if not LoadPtfxAsset() then
			return false
		end
		
		if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
			return false
		end
		
		local duration = BLINK_DURATION
		local scale = math.max(duration / 1000.0, 0.05)
		
		SetVehicleNeonLight(vehicle, true, scale, 1.0, 9999999.0, true)
		
		CreateThread(function()
			Wait(duration)
			SetVehicleNeonLight(vehicle, false, 0.0, 0.0, 0.0, true)
		end)
		
		return true
	end

	function IsElectricVehicle(vehicle)
		if not vehicle or vehicle == 0 then
			return false
		end
		
		local electricModels = Config.Pnb.electricModels or {}
		local model = GetEntityModel(vehicle)
		
		if electricModels[model] then
			return true
		end
		
		local displayName = GetDisplayNameFromVehicleModel(model) or ""
		local lowerName = string.lower(displayName)
		
		return electricModels[lowerName] == true
	end

	function IsBlockedVehicleClass(vehicle)
		if not vehicle or vehicle == 0 then
			return false
		end
		
		local blockedClasses = Config.Pnb.blockedClasses or {}
		local vehicleClass = GetVehicleClass(vehicle)
		
		return blockedClasses[vehicleClass] == true
	end

	function CheckVehicleSpeed(vehicle, minSpeedKmh)
		if minSpeedKmh <= 0.0 then
			return true
		end
		
		if vehicle ~= lastSpeedCheckVehicle then
			lastSpeedCheckVehicle = vehicle
			lastSpeedCheckTime = 0
			cachedSpeedKmh = 0.0
		end
		
		local currentTime = GetGameTimer()
		local checkInterval = Config.Pnb.speedCheckInterval or 150
		
		if currentTime - lastSpeedCheckTime >= checkInterval then
			cachedSpeedKmh = GetEntitySpeed(vehicle) * 3.6
			lastSpeedCheckTime = currentTime
		end
		
		return cachedSpeedKmh >= minSpeedKmh
	end

	function UpdateCurrentVehicleState(vehicle, isDriverSeat)
		if vehicle == 0 or not isDriverSeat then
			currentVehicle = vehicle
			isDriver = isDriverSeat
			currentPlate = nil
			canUsePnb = false
			return
		end
		
		currentVehicle = vehicle
		isDriver = isDriverSeat
		currentPlate = NormalizePlate(GetVehicleNumberPlateText(vehicle))
		
		if IsElectricVehicle(vehicle) or IsBlockedVehicleClass(vehicle) then
			canUsePnb = false
			return
		end
		
		if Config.Pnb.enableAllVehicles then
			canUsePnb = true
		else
			local entityState = Entity(vehicle).state
			local isInstalled = entityState and entityState.pnb_installed
			canUsePnb = isInstalled == true
		end
	end

	function PlayFlameSound(vehicle)
		local fireConfig = Config.Pnb.PNBFire or {}
		local soundName = fireConfig.FlameSoundName or "zr350_exhaust_pops"
		local soundSet = fireConfig.FlameSoundSet
		
		if soundSet == "" then
			soundSet = nil
		end
		
		PlaySoundFromEntity(-1, soundName, vehicle, soundSet, false, 0)
	end

	function TriggerNitroVisual(vehicle)
		if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
			return
		end
		
		if not TriggerNitroVisualBlink(vehicle) then
			return
		end
		
		local fireConfig = Config.Pnb.PNBFire or {}
		if fireConfig.SoundPerFlame then
			PlayFlameSound(vehicle)
		end
	end

	function GetNearbyPlayerServerIds(vehicle, maxDistance)
		local nearbyPlayers = {}
		local vehicleCoords = GetEntityCoords(vehicle)
		maxDistance = maxDistance or Config.Pnb.soundMaxDist or 150.0
		local maxDistSq = maxDistance * maxDistance
		
		local pedPool = GetGamePool and GetGamePool("CPed") or {}
		
		for _, ped in pairs(pedPool) do
			if ped and ped ~= 0 and IsPedAPlayer(ped) then
				local playerIndex = NetworkGetPlayerIndexFromPed(ped)
				if playerIndex and NetworkIsPlayerConnected(playerIndex) then
					local serverId = GetPlayerServerId(playerIndex)
					local pedCoords = GetEntityCoords(ped)
					
					local dx = pedCoords.x - vehicleCoords.x
					local dy = pedCoords.y - vehicleCoords.y
					local dz = pedCoords.z - vehicleCoords.z
					local distSq = dx * dx + dy * dy + dz * dz
					
					if distSq <= maxDistSq then
						nearbyPlayers[#nearbyPlayers + 1] = serverId
					end
				end
			end
		end
		
		local maxPassengers = GetVehicleMaxNumberOfPassengers(vehicle)
		for seatIndex = -1, maxPassengers do
			local seatPed = GetPedInVehicleSeat(vehicle, seatIndex)
			if seatPed and seatPed ~= 0 and IsPedAPlayer(seatPed) then
				local playerIndex = NetworkGetPlayerIndexFromPed(seatPed)
				if playerIndex and NetworkIsPlayerConnected(playerIndex) then
					local serverId = GetPlayerServerId(playerIndex)
					local alreadyAdded = false
					
					for _, existingId in ipairs(nearbyPlayers) do
						if existingId == serverId then
							alreadyAdded = true
							break
						end
					end
					
					if not alreadyAdded then
						nearbyPlayers[#nearbyPlayers + 1] = serverId
					end
				end
			end
		end
		
		return nearbyPlayers
	end

	function TriggerBackfireToServer()
		local ped = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(ped, false)
		
		if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped then
			local vehicleNetId = VehToNet(vehicle)
			local maxDist = Config.Pnb.soundMaxDist or 150.0
			TriggerEvent("thunder-pnb:getPlayers", vehicleNetId, maxDist)
		end
	end

	function StartPopsSequence(triggerReason)
		local endTime = GetGameTimer() + (Config.Pnb.popDuration or 1600)
		local ped = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(ped, false)
		
		if vehicle == 0 then
			return
		end
		
		local chancePerPop = Config.Pnb.chancePerPop or 1.0
		local minDelay = Config.Pnb.minDelay or 80
		local maxDelay = Config.Pnb.maxDelay or 140
		local delayRange = (maxDelay > minDelay) and (maxDelay - minDelay) or 0
		
		CreateThread(function()
			while GetGameTimer() < endTime do
				if not DoesEntityExist(vehicle) then
					break
				end
				
				if IsControlPressed(0, KEY_ACCELERATE) then
					break
				end
				
				if not IsControlPressed(0, KEY_HANDBRAKE) then
					local lowSpeedCutoff = Config.Pnb.lowSpeedCutoff or 0.0
					if not CheckVehicleSpeed(vehicle, lowSpeedCutoff) then
						break
					end
				end
				
				if math.random() <= chancePerPop then
					TriggerBackfireToServer()
				end
				
				local delay = minDelay + (delayRange > 0 and math.random(delayRange) or 0)
				Wait(delay)
			end
			
			isPopping = false
		end)
	end

	function StartHandbrakeLoop(vehicle)
		local minDelay = Config.Pnb.Handbrake.minDelay or 60
		local maxDelay = Config.Pnb.Handbrake.maxDelay or 120
		local chance = Config.Pnb.Handbrake.chance or 1.0
		local minRpm = Config.Pnb.Handbrake.minRpm or 0.45
		local minSpeedKmh = Config.Pnb.Handbrake.minSpeedKmh or 0.0
		
		CreateThread(function()
			while true do
				local ped = PlayerPedId()
				local currentVeh = GetVehiclePedIsIn(ped, false)
				
				if currentVeh == 0 or currentVeh ~= vehicle then
					break
				end
				
				if GetPedInVehicleSeat(currentVeh, -1) ~= ped then
					break
				end
				
				local isPressingHandbrake = IsControlPressed(0, KEY_HANDBRAKE)
				local requireAccel = Config.Pnb.Handbrake.requireAccel
				local isPressingAccel = IsControlPressed(0, KEY_ACCELERATE)
				
				if not (isPressingHandbrake and (not requireAccel or isPressingAccel)) then
					break
				end
				
				local rpm = GetVehicleCurrentRpm(currentVeh) or 0.0
				local speedKmh = GetEntitySpeed(currentVeh) * 3.6
				
				if rpm >= minRpm and speedKmh >= minSpeedKmh then
					if math.random() <= chance then
						TriggerBackfireToServer()
					end
				end
				
				Wait(math.random(minDelay, maxDelay))
			end
			
			isPopping = false
			isHandbrakeActive = false
		end)
	end

	RegisterNetEvent("thunder-pnb:syncInstalledPlate", function(plate, isInstalled)
		local normalizedPlate = NormalizePlate(plate)
		if normalizedPlate == "" then
			return
		end
		
		if isInstalled then
			installedPlates[normalizedPlate] = true
		else
			installedPlates[normalizedPlate] = nil
		end
		
		currentVehicle = 0
	end)

	RegisterNetEvent("thunder-pnb:syncInstalledAll", function(plateList)
		installedPlates = {}
		
		for _, plate in ipairs(plateList or {}) do
			local normalizedPlate = NormalizePlate(plate)
			if normalizedPlate ~= "" then
				installedPlates[normalizedPlate] = true
			end
		end
		
		currentVehicle = 0
	end)

	CreateThread(function()
		Wait(2000)
		TriggerServerEvent("thunder-pnb:requestInstalledSync")
	end)

	RegisterNetEvent("thunder-pnb:getPlayers", function(vehicleNetId, maxDistance)
		vehicleNetId = tonumber(vehicleNetId)
		
		if not vehicleNetId or (NetworkDoesNetworkIdExist and not NetworkDoesNetworkIdExist(vehicleNetId)) then
			return
		end
		
		local vehicle = NetToVeh(vehicleNetId)
		if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
			return
		end
		
		local nearbyPlayers = GetNearbyPlayerServerIds(vehicle, maxDistance or Config.Pnb.soundMaxDist or 150.0)
		TriggerServerEvent("thunder-pnb:resultGetPlayers", vehicleNetId, nearbyPlayers)
	end)

	RegisterNetEvent("pnb:ownerNitroBlink", function(vehicleNetId)
		vehicleNetId = tonumber(vehicleNetId)
		if not vehicleNetId or (NetworkDoesNetworkIdExist and not NetworkDoesNetworkIdExist(vehicleNetId)) then
			return
		end
		
		local vehicle = NetToVeh(vehicleNetId)
		if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
			return
		end
		
		TriggerNitroVisual(vehicle)
	end)

	CreateThread(function()
		local tickConfig = Config.Pnb.tick or {}
		
		while true do
			local idleTick = tickConfig.idle or 300
			local ped = PlayerPedId()
			
			if not IsPedInAnyVehicle(ped, false) then
				wasAccelerating = false
				lastGear = nil
				
				if currentVehicle ~= 0 then
					UpdateCurrentVehicleState(0, false)
				end
				
				Wait(idleTick)
			else
				local vehicle = GetVehiclePedIsIn(ped, false)
				local isDriverSeat = GetPedInVehicleSeat(vehicle, -1) == ped
				
				if vehicle ~= currentVehicle or isDriver ~= isDriverSeat then
					UpdateCurrentVehicleState(vehicle, isDriverSeat)
				end
				
				if not isDriverSeat then
					wasAccelerating = false
					lastGear = nil
					Wait(tickConfig.passenger or 250)
				elseif not canUsePnb then
					wasAccelerating = false
					lastGear = nil
					Wait(tickConfig.driver_no_install or 180)
				else
					local speedKmh = GetEntitySpeed(vehicle) * 3.6
					local isAccelerating = IsControlPressed(0, KEY_ACCELERATE)
					local isPressingHandbrake = IsControlPressed(0, KEY_HANDBRAKE)
					local currentGear = GetVehicleCurrentGear(vehicle)
					local rpm = GetVehicleCurrentRpm(vehicle)
					local engineRunning = GetIsVehicleEngineRunning(vehicle)
					
					local handbrakeConfig = Config.Pnb.Handbrake
					if handbrakeConfig and handbrakeConfig.enabled then
						local requireAccel = handbrakeConfig.requireAccel
						if (not requireAccel or isAccelerating) and isPressingHandbrake and engineRunning then
							if not isPopping and not isHandbrakeActive then
								isHandbrakeActive = true
								isPopping = true
								StartHandbrakeLoop(vehicle)
							end
						end
					end
					
					if wasAccelerating and not isAccelerating then
						if not isPopping then
							local minSpeed = Config.Pnb.minSpeedKmh or 0.0
							if speedKmh >= minSpeed then
								isPopping = true
								StartPopsSequence("desaceleração")
							end
						end
					end
					
					if lastGear and currentGear < lastGear and currentGear > 0 then
						if not isPopping then
							local minSpeed = Config.Pnb.minSpeedKmh or 0.0
							if speedKmh >= minSpeed then
								isPopping = true
								StartPopsSequence("redução")
							end
						end
					end
					
					wasAccelerating = isAccelerating
					lastGear = currentGear
					
					local sleepTime
					if isAccelerating and isPressingHandbrake then
						sleepTime = tickConfig.handbrake or 20
					else
						sleepTime = tickConfig.driver_installed or 55
					end
					
					Wait(sleepTime)
				end
			end
		end
	end)

	if Config.Pnb.pnbMode ~= false then
		RegisterCommand(Config.Pnb.pnbCmd or "pnb", function(source, args)
			local ped = PlayerPedId()
			local vehicle = GetVehiclePedIsIn(ped, false)
			
		if vehicle == 0 or GetPedInVehicleSeat(vehicle, -1) ~= ped then
			return
		end
		
		if IsElectricVehicle(vehicle) or IsBlockedVehicleClass(vehicle) then
			return
		end
			
			local plate = NormalizePlate(GetVehicleNumberPlateText(vehicle))
			local action = args[1] and string.lower(args[1]) or "toggle"
			local shouldInstall
			
			if action == "on" then
				shouldInstall = true
			elseif action == "off" then
				shouldInstall = false
			else
				shouldInstall = installedPlates[plate] ~= true
			end
			
			if Config.Pnb.enableAllVehicles then
				canUsePnb = shouldInstall
				return
			end
			
			installedPlates[plate] = shouldInstall or nil
			
			local entityState = Entity(vehicle).state
			if entityState and entityState.set then
				entityState:set("pnb_installed", shouldInstall == true, true)
			end
			
			local vehicleNetId = VehToNet(vehicle)
			if shouldInstall then
				TriggerServerEvent("thunder-pnb:installByPlate", plate, vehicleNetId)
			else
				TriggerServerEvent("thunder-pnb:removeByPlate", plate, vehicleNetId)
			end
			
			UpdateCurrentVehicleState(vehicle, true)
		end, false)
	end

	RegisterCommand("pnb_local_fx", function()
		local ped = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(ped, false)
		
		if vehicle == 0 then
			return
		end
		
		TriggerNitroVisual(vehicle)
	end)

	RegisterCommand("pnb_local_snd", function()
		local ped = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(ped, false)
		
		if vehicle == 0 then
			return
		end
		
		PlayFlameSound(vehicle)
	end)

	exports("InstallPopsAndBangs", function(vehicle)
		vehicle = vehicle or 0
		
		if vehicle == 0 or not DoesEntityExist(vehicle) then
			return false
		end
		
		local plate = GetVehicleNumberPlateText(vehicle) or ""
		plate = NormalizePlate(plate)
		
		local entityState = Entity(vehicle).state
		if entityState and entityState.set then
			entityState:set("pnb_installed", true, true)
		end
		
		TriggerServerEvent("thunder-pnb:installByPlate", plate, VehToNet(vehicle))
		return true
	end)

	exports("RemovePopsAndBangs", function(vehicle)
		vehicle = vehicle or 0
		
		if vehicle == 0 or not DoesEntityExist(vehicle) then
			return false
		end
		
		local plate = GetVehicleNumberPlateText(vehicle) or ""
		plate = NormalizePlate(plate)
		
		local entityState = Entity(vehicle).state
		if entityState and entityState.set then
			entityState:set("pnb_installed", false, true)
		end
		
		TriggerServerEvent("thunder-pnb:removeByPlate", plate, VehToNet(vehicle))
		return true
	end)

	exports("IsPnbInstalled", function(vehicle)
		vehicle = vehicle or 0
		
		if vehicle == 0 or not DoesEntityExist(vehicle) then
			return false
		end
		
		local entityState = Entity(vehicle).state
		local isInstalled = entityState and entityState.pnb_installed
		return isInstalled == true
	end)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- DRIVE BY
-----------------------------------------------------------------------------------------------------------------------------------------
local BypassHashes = {}
for _, model in ipairs(Config.BypassDriveBy or {}) do
	BypassHashes[GetHashKey(model)] = true
end

local NotDriveByHashes = {}
for _, model in ipairs(Config.NotDriveBy or {}) do
	NotDriveByHashes[GetHashKey(model)] = true
end

local ExtraWeaponHashes = {}
for _, weapon in ipairs(Config.DriveByExtraWeapons or {}) do
	ExtraWeaponHashes[GetHashKey(weapon)] = true
end

CreateThread(function()
	while true do
		local ped = PlayerPedId()
		local allow = false
		local inVehicle = IsPedInAnyVehicle(ped, false)

		if inVehicle then
			local veh = GetVehiclePedIsIn(ped, false)
			local model = GetEntityModel(veh)

			if BypassHashes[model] then
				allow = true
			elseif NotDriveByHashes[model] then
				allow = false
			elseif IsPedInAnyHeli(ped) then
				allow = Config.EnableHeliDriveBy
			else
				if Config.EnableDriveBy then
					allow = true
				else
					local weaponHash = GetSelectedPedWeapon(ped)
					allow = ExtraWeaponHashes[weaponHash] == true
				end
			end

			SetPlayerCanDoDriveBy(PlayerId(), allow)
			if not allow then
				DisableControlAction(0, 68, true)
			end
		else
			allow = true
			SetPlayerCanDoDriveBy(PlayerId(), allow)
		end

		Wait((inVehicle and not allow) and 0 or 500)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- SPEED LIMITER
-----------------------------------------------------------------------------------------------------------------------------------------
if Config.EnableSpeedLimiter then
	local isInitialized = false
	local lastVehicleCheckTime = GetGameTimer()
	local shouldLimit = false
	local currentSpeedLimitValue = nil
	local currentMaxSpeed = Config.SpeedLimiter.MaxSpeed
	local isNitroActive = false

	function ShouldLimitVehicle(vehicle)
		local vehicleClass = GetVehicleClass(vehicle)
		local vehicleModel = GetEntityArchetypeName(vehicle)
		
		local modelLimit = Config.SpeedLimiter.LimitedModels[vehicleModel]
		if modelLimit then
			return true, modelLimit
		end
		
		local classLimit = Config.SpeedLimiter.LimitedClasses[vehicleClass]
		if classLimit then
			return true, classLimit
		end
		
		if Config.SpeedLimiter.LimitGlobal then
			local isForbiddenClass = Config.SpeedLimiter.ClassesForbiddenGlobal[vehicleClass]
			if not isForbiddenClass then
				return true
			end
		end
		
		return false
	end

	function GetMaxSpeed(speedValue)
		if type(speedValue) == "number" then
			return speedValue
		elseif type(speedValue) == "string" then
			local customClassSpeed = Config.SpeedLimiter.CustomClasses[speedValue]
			if customClassSpeed then
				return customClassSpeed
			end
		end
		return Config.SpeedLimiter.MaxSpeed
	end

	function GetSpeedCalculated(vehicle)
		local conversionFactor = (Config.SpeedLimiter.SpeedUnit == "mph") and 2.236936 or 3.6
		local maxSpeedConverted = currentMaxSpeed / conversionFactor
		local currentSpeed = GetEntitySpeed(vehicle) * conversionFactor
		return maxSpeedConverted, currentSpeed
	end

	function SetInitialValues(vehicle)
		local limitEnabled, limitValue = ShouldLimitVehicle(vehicle)
		currentSpeedLimitValue = limitValue
		shouldLimit = limitEnabled
		currentMaxSpeed = GetMaxSpeed(currentSpeedLimitValue)
		isInitialized = true
	end

	AddEventHandler("gameEventTriggered", function(eventName, eventData)
		if eventName == "CEventNetworkPlayerEnteredVehicle" then
			local vehicle = eventData[2]
			local playerId = eventData[1]
			
			if playerId == PlayerId() then
				local currentTime = GetGameTimer()
				if currentTime >= lastVehicleCheckTime then
					lastVehicleCheckTime = currentTime + 1000
					SetInitialValues(vehicle)
				end
			end
		end
	end)

	CreateThread(function()
		while true do
			local waitTime = 1000
			local playerPed = PlayerPedId()
			
			if IsPedInAnyVehicle(playerPed, false) then
				local vehicle = GetVehiclePedIsIn(playerPed, false)
				
				if isInitialized then
					local driver = GetPedInVehicleSeat(vehicle, -1)
					if driver == playerPed then
						if shouldLimit then
							if not isNitroActive then
								waitTime = 500
								local maxSpeedConverted, currentSpeed = GetSpeedCalculated(vehicle)
								if currentSpeed <= currentMaxSpeed then
									SetEntityMaxSpeed(vehicle, maxSpeedConverted + 0.1)
								end
							end
						end
					else
						if isNitroActive then
							SetEntityMaxSpeed(vehicle, 500.0)
						end
					end
				end
			else
				isInitialized = false
			end
			
			Wait(waitTime)
		end
	end)

	AddEventHandler("onResourceStart", function(resourceName)
		if GetCurrentResourceName() ~= resourceName then
			return
		end
		
		local playerPed = PlayerPedId()
		if IsPedInAnyVehicle(playerPed, false) then
			local vehicle = GetVehiclePedIsIn(playerPed, false)
			SetInitialValues(vehicle)
		end
	end)

	function ToggleNitro(enabled)
		isNitroActive = enabled
	end

	exports("ToggleNitro", ToggleNitro)
end


