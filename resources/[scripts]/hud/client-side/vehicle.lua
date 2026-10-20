-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Rpm = 0
local Fuel = 0
local Speed = 0
local Nitro = 0
local Spike = {}
local LastSpeed = 0
local Locked = false
local Light = {}
local Gear = 0
local Loadout = false
local EngineHealth = 0
local ActualVehicle = nil
-----------------------------------------------------------------------------------------------------------------------------------------
-- NITRO
-----------------------------------------------------------------------------------------------------------------------------------------
local NitroFuel = 0
local NitroActive = false
local NitroButton = GetGameTimer()
-----------------------------------------------------------------------------------------------------------------------------------------
-- LIGHTTRAILS
-----------------------------------------------------------------------------------------------------------------------------------------
local LightTrails = {}
local LightParticles = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- SEATBELT
-----------------------------------------------------------------------------------------------------------------------------------------
local SeatbeltSpeed = 0
local SeatbeltLock = false
local SeatbeltAlarm = GetGameTimer()
local SeatbeltVelocity = vec3(0,0,0)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TYRES
-----------------------------------------------------------------------------------------------------------------------------------------
local Tyres = {
	{ Bone = "wheel_lf", Index = 0 },
	{ Bone = "wheel_rf", Index = 1 },
	{ Bone = "wheel_lm", Index = 2 },
	{ Bone = "wheel_rm", Index = 3 },
	{ Bone = "wheel_lr", Index = 4 },
	{ Bone = "wheel_rr", Index = 5 }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	LoadPtfxAsset("veh_xs_vehicle_mods")

	while true do
		local TimeDistance = 999
		if LocalPlayer.state.Active then
			if not Loadout then
				if LoadTexture("circleminimap") then
					AddReplaceTexture("platform:/textures/graphics","radarmasksm","circleminimap","radarmasksm")

					local DefaultAspectRatio = 1920 / 1080
					local ResolutionX, ResolutionY = GetActiveScreenResolution()
					local AspectRatio = ResolutionX / ResolutionY
					local MinimapXOffset,MinimapYOffset = 0,0
					if AspectRatio > DefaultAspectRatio then
						local AspectDifference = DefaultAspectRatio - AspectRatio
						MinimapXOffset = AspectDifference / 3.6
					end

					SetMinimapComponentPosition("minimap","L","B",0.005 + MinimapXOffset,-0.025 + MinimapYOffset,0.175,0.225)
					SetMinimapComponentPosition("minimap_mask","L","B",0.02 + MinimapXOffset,0.39 + MinimapYOffset,0.1135,0.5)
					SetMinimapComponentPosition("minimap_blur","L","B",-0.02 + MinimapXOffset,-0.01 + MinimapYOffset,0.265,0.225)

					SetBigmapActive(true,false)

					repeat
						Wait(100)

						SetMinimapClipType(1)
						SetBigmapActive(false,false)
					until not IsBigmapActive()

					SetRadarZoom(1100)
					Loadout = true
				end
			end

			local Ped = PlayerPedId()
			local InVehicle = IsPedInAnyVehicle(Ped)
			if InVehicle then
				TimeDistance = 100

				local Vehicle = GetVehiclePedIsUsing(Ped)
				local VRpm = GetVehicleCurrentRpm(Vehicle)
				local VLocked = GetVehicleDoorLockStatus(Vehicle)
				local VFuel = Entity(Vehicle).state.Fuel or 0
				local VEngineHealth = GetVehicleEngineHealth(Vehicle)
				local VSpeed = hudConfig.getSpeedVehicle(Vehicle)
				local _, lightsOn, highbeamsOn = GetVehicleLightsState(Vehicle)
				local VGear = GetVehicleCurrentGear(Vehicle)

				if GetPedInVehicleSeat(Vehicle,-1) == Ped then
					if GetVehicleDirtLevel(Vehicle) > 0.0 then
						SetVehicleDirtLevel(Vehicle,0.0)
					end

					local Class = GetVehicleClass(Vehicle)
					if (Class >= 0 and Class <= 7) or Class == 9 then
						if IsControlPressed(1,21) then
							if VSpeed <= 75.0 and not GetDriftTyresEnabled(Vehicle) then
								SetDriftTyresEnabled(Vehicle,true)
								SetVehicleReduceGrip(Vehicle,true)
								SetReduceDriftVehicleSuspension(Vehicle,true)
							end
						else
							if GetDriftTyresEnabled(Vehicle) then
								SetDriftTyresEnabled(Vehicle,false)
								SetVehicleReduceGrip(Vehicle,false)
								SetReduceDriftVehicleSuspension(Vehicle,false)
							end
						end
					end

					if not IsPedOnAnyBike(Ped) and not IsPedInAnyHeli(Ped) and not IsPedInAnyBoat(Ped) and not IsPedInAnyPlane(Ped) then
						if not LocalPlayer.state.Races and VSpeed ~= LastSpeed then
							if (LastSpeed - VSpeed) >= (Entity(Vehicle).state.Seatbelt and 125 or 100) then
								VehicleTyreBurst(Vehicle)
							end

							LastSpeed = VSpeed
						end

						local Roll = GetEntityRoll(Vehicle)
						if (Roll > 75.0 or Roll < -75.0) and math.random(1000) <= 25 then
							VehicleTyreBurst(Vehicle)
						end
					end

					for Number,v in pairs(Spike) do
						if #(GetEntityCoords(Vehicle) - v.Coords) <= 10 then
							for Index = 1,#Tyres do
								local BoneIndex = GetEntityBoneIndexByName(Vehicle,Tyres[Index].Bone)
								local TirePosition = GetWorldPositionOfEntityBone(Vehicle,BoneIndex)

								if IsPointInAngledArea(TirePosition,v.Min,v.Max,0.45,false,false) then
									TriggerServerEvent("inventory:StoreObjects",Number)
									VehicleTyreBurst(Vehicle)
								end
							end
						end
					end
				end

				if NitroActive then
					Nitro = NitroFuel
				else
					Nitro = Entity(Vehicle).state.Nitro or 0
				end

				if not GetIsVehicleEngineRunning(Vehicle) then
					VRpm = 0.0
				end

				ActualVehicle = Vehicle
				Locked        = VLocked
				Fuel          = VFuel
				Speed         = VSpeed
				Rpm           = VRpm
				Gear          = VGear
				EngineHealth  = VEngineHealth
				Light[1]      = lightsOn
				Light[2]      = highbeamsOn

				local Headlight = (lightsOn == 1 or highbeamsOn == 1)
				local Velocimeter = {
					speed     = VSpeed,
					headlight = Headlight,
					seatbelt  = SeatbeltLock,
					lock      = VLocked >= 2,
					fuel      = VFuel,
					nitro     = math.floor(Nitro / 20),
					rpm       = VRpm * 100,
					gear      = VGear == 0 and "N" or tostring(VGear),
					engine    = math.floor(VEngineHealth / 10)
				}

				SendNUIMessage({ action = "set:velocimeter", payload = Velocimeter })

				if not SeatbeltLock and SeatbeltAlarm <= GetGameTimer() and IsPedInAnyVehicle(Ped) and not IsPedOnAnyBike(Ped) and not IsPedInAnyHeli(Ped) and not IsPedInAnyBoat(Ped) and not IsPedInAnyPlane(Ped) and VSpeed >= 20.0 then
					SeatbeltAlarm = GetGameTimer() + 1150
				end
			else
				TimeDistance = 100

				if ActualVehicle then
					ActualVehicle = nil
					Locked = false
					Nitro  = 0
					Speed  = 0
					SendNUIMessage({ action = "set:velocimeter", payload = nil })
				end

				if LastSpeed ~= 0 then
					LastSpeed = 0
				end
			end

			ApplyMinimapVisibility()
		end

		Wait(TimeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHICLETYREBURST
-----------------------------------------------------------------------------------------------------------------------------------------
function VehicleTyreBurst(Vehicle)
	if DoesEntityExist(Vehicle) then
		local WheelIndex
		local NumberWheels = GetVehicleNumberOfWheels(Vehicle)

		if NumberWheels == 2 then
			WheelIndex = (math.random(2) - 1) * 4
		elseif NumberWheels == 4 then
			local Round = math.random(4) - 1
			WheelIndex = (Round > 1) and (Round + 2) or Round
		elseif NumberWheels == 6 then
			WheelIndex = math.random(6) - 1
		else
			return
		end

		if GetTyreHealth(Vehicle,WheelIndex) == 1000.0 then
			SetVehicleTyreBurst(Vehicle,WheelIndex,true,1000.0)
		end

		if math.random(100) <= 25 then
			VehicleTyreBurst(Vehicle)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NITROENABLE
-----------------------------------------------------------------------------------------------------------------------------------------
function NitroEnable()
	if GetGameTimer() < NitroButton or IsPauseMenuActive() then
		return false
	end

	local Ped = PlayerPedId()
	if not IsPedInAnyVehicle(Ped) then
		return false
	end

	local Vehicle = GetVehiclePedIsUsing(Ped)
	if GetPedInVehicleSeat(Vehicle,-1) ~= Ped then
		return false
	end

	NitroButton = GetGameTimer() + 1000

	local VehicleState = Entity(Vehicle).state
	NitroFuel = VehicleState.Nitro or 0

	if NitroFuel < 1 or Speed <= 10 or GetVehicleTopSpeedModifier(Vehicle) >= 100.0 then
		return false
	end

	NitroActive = true
	LocalPlayer.state:set("Nitro",true,false)
	VehicleState:set("NitroFlame",true,true)

	SetVehicleRocketBoostActive(Vehicle,true)
	ModifyVehicleTopSpeed(Vehicle,100.0)
	SetVehicleBoostActive(Vehicle,true)
	SetLightTrail(Vehicle,true)

	CreateThread(function()
		while NitroActive and DoesEntityExist(Vehicle) do
			Wait(100)

			NitroFuel = NitroFuel - 10

			if NitroFuel > 0 then
				VehicleState:set("Nitro",NitroFuel,true)
			else
				LocalPlayer.state:set("Nitro",false,false)
				VehicleState:set("NitroFlame",false,true)
				VehicleState:set("Nitro",0,true)
				NitroActive = false

				SetVehicleRocketBoostActive(Vehicle,false)
				SetVehicleBoostActive(Vehicle,false)
				ModifyVehicleTopSpeed(Vehicle,0.0)
				SetLightTrail(Vehicle,false)

				break
			end
		end
	end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NITRODISABLE
-----------------------------------------------------------------------------------------------------------------------------------------
function NitroDisable()
	if not NitroActive then
		return false
	end

	NitroActive = false
	LocalPlayer.state:set("Nitro",false,false)

	local Vehicle = GetLastDrivenVehicle()
	if DoesEntityExist(Vehicle) then
		Entity(Vehicle).state:set("Nitro",NitroFuel,true)
		Entity(Vehicle).state:set("NitroFlame",false,true)

		SetVehicleRocketBoostActive(Vehicle,false)
		SetVehicleBoostActive(Vehicle,false)
		ModifyVehicleTopSpeed(Vehicle,0.0)
		SetLightTrail(Vehicle,false)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDSTATEBAGCHANGEHANDLER
-----------------------------------------------------------------------------------------------------------------------------------------
AddStateBagChangeHandler("NitroFlame",nil,function(Name,Key,Value)
	local Network = parseInt(Name:gsub("entity:",""))
	if NetworkDoesNetworkIdExist(Network) then
		local Vehicle = NetToVeh(Network)
		if DoesEntityExist(Vehicle) then
			SetVehicleNitroEnabled(Vehicle,Value)
			SetLightTrail(Vehicle,Value)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ACTIVENITRO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("+activeNitro",NitroEnable)
RegisterCommand("-activeNitro",NitroDisable)
RegisterKeyMapping("+activeNitro","Ativação do nitro.","keyboard","LMENU")
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETLIGHTTRAIL
-----------------------------------------------------------------------------------------------------------------------------------------
function SetLightTrail(Vehicle,Enable)
	if LightTrails[Vehicle] == Enable then
		return
	end

	if Enable then
		local Particles = {}
		local LeftTrail = CreateLightTrail(Vehicle,GetEntityBoneIndexByName(Vehicle,"taillight_l"))
		local RightTrail = CreateLightTrail(Vehicle,GetEntityBoneIndexByName(Vehicle,"taillight_r"))

		Particles[#Particles + 1] = LeftTrail
		Particles[#Particles + 1] = RightTrail

		LightTrails[Vehicle] = true
		LightParticles[Vehicle] = Particles
	else
		if LightParticles[Vehicle] and #LightParticles[Vehicle] > 0 then
			for _,v in ipairs(LightParticles[Vehicle]) do
				StopLightTrail(v)
			end
		end

		LightTrails[Vehicle] = nil
		LightParticles[Vehicle] = nil
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATELIGHTTRAIL
-----------------------------------------------------------------------------------------------------------------------------------------
function CreateLightTrail(Vehicle,Bone)
	UseParticleFxAssetNextCall("core")
	local Particle = StartParticleFxLoopedOnEntityBone("veh_light_red_trail",Vehicle,0.0,0.0,0.0,0.0,0.0,0.0,Bone,1.0,false,false,false)
	SetParticleFxLoopedEvolution(Particle,"speed",1.0,false)

	return Particle
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STOPLIGHTTRAIL
-----------------------------------------------------------------------------------------------------------------------------------------
function StopLightTrail(Particle)
	CreateThread(function()
		local EndTime = GetGameTimer() + 500
		while GetGameTimer() < EndTime do
			Wait(0)
			local now = GetGameTimer()
			local Scale = (EndTime - now) / 500
			SetParticleFxLoopedScale(Particle,Scale)
			SetParticleFxLoopedAlpha(Particle,Scale)
		end

		StopParticleFxLooped(Particle,false)
	end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADBELT
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local TimeDistance = 999
		if LocalPlayer.state.Active then
			local Ped = PlayerPedId()
			if IsPedInAnyVehicle(Ped) then
				if not IsPedOnAnyBike(Ped) and not IsPedInAnyHeli(Ped) and not IsPedInAnyBoat(Ped) and not IsPedInAnyPlane(Ped) then
					TimeDistance = SeatbeltLock and 0 or 100

					if SeatbeltLock then
						DisableControlAction(0,75,true)
						DisableControlAction(27,75,true)
					end

					if Speed ~= SeatbeltSpeed then
						local Vehicle = GetVehiclePedIsUsing(Ped)
						if not Entity(Vehicle).state.Seatbelt and not SeatbeltLock and (SeatbeltSpeed - Speed) >= 100 then
							ApplyDamageToPed(Ped,25,false)

							SetEntityNoCollisionEntity(Ped,Vehicle,false)
							SetEntityNoCollisionEntity(Vehicle,Ped,false)
							TriggerServerEvent("hud:VehicleEject",SeatbeltVelocity)

							SetTimeout(500,function()
								SetEntityNoCollisionEntity(Ped,Vehicle,true)
								SetEntityNoCollisionEntity(Vehicle,Ped,true)
							end)
						end

						SeatbeltVelocity = GetEntityVelocity(Vehicle)
						SeatbeltSpeed = Speed
					end
				end
			else
				if SeatbeltSpeed ~= 0 then
					SeatbeltSpeed = 0
				end

				if SeatbeltLock then
					SeatbeltLock = false
				end

				if NitroActive then
					NitroDisable()
				end
			end
		end

		Wait(TimeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SEATBELTZ
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("Seatbeltz",function(source)
	local Ped = PlayerPedId()
	if IsPedInAnyVehicle(Ped) and not IsPedOnAnyBike(Ped) and not IsPedInAnyHeli(Ped) and not IsPedInAnyBoat(Ped) and not IsPedInAnyPlane(Ped) then
		if SeatbeltLock then
			SeatbeltAlarm = GetGameTimer() + 2000
			TriggerEvent("sounds:Private","beltoff",0.5)

			SeatbeltLock = false
		else
			SeatbeltLock = true
			TriggerEvent("sounds:Private","belton",0.5)

			local Vehicle = GetVehiclePedIsUsing(Ped)
			if Entity(Vehicle).state.Seatbelt then
				TriggerEvent("Notify","Cinto de Segurança","Cinto de Corrida colocado.","verde",5000)
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- KEYMAPPING
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterKeyMapping("Seatbeltz","Colocar/Retirar o cinto.","keyboard","G")
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPIKES:ADICIONAR
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("spikes:Adicionar",function(Number,Coords,Min,Max)
	Spike[Number] = {
		Min = Min, Max = Max,
		Coords = vec3(Coords[1],Coords[2],Coords[3])
	}
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPIKES:REMOVER
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("spikes:Remover",function(Number)
	if Spike[Number] then
		Spike[Number] = nil
	end
end)
