-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local vSERVER = Tunnel.getInterface("target")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Config = {
	Enabled = true,
	-- Use "object" para detectar props pelos Models ou "coordinate" para usar a lista Beds.
	Mode = "coordinate",
	-- Restricao usada no modo "object" para nao ativar esses props no mapa inteiro.
	RestrictToHospitals = true,
	DefaultRadius = 100.0,

	Target = {
		Resource = "sleepless_interact",
		RetryInterval = 1000
	},

	Interaction = {
		Distance = 1.5,
		UseTolerance = 1.0,
		Cooldown = 800,
		OccupiedRadius = 1.0,
		LieLabel = "Deitar",
		LieIcon = "fa-solid fa-bed",
		TreatmentLabel = "Tratamento",
		TreatmentIcon = "fa-solid fa-stethoscope"
	},

	Animation = {
		Dict = "amb@world_human_sunbathe@female@back@idle_a",
		Name = "idle_a",
		MonitorInterval = 1000,
		-- AF_LOOPING + AF_NOT_INTERRUPTABLE + AF_OVERRIDE_PHYSICS + AF_IGNORE_GRAVITY.
		Flag = 1 + 8 + 1024 + 2048
	},

	Treatment = {
		MaxHealth = 200,
		HealthPerTick = 1,
		TickInterval = 1000,
		ReviveHealth = 101
	},

	Coordinate = {
		-- O interact fica 1 metro abaixo, sem alterar a posicao fisica configurada para a animacao.
		InteractionZOffset = -1.0,
		PlayerZOffset = 0.0
	},

	Hospitals = {
		-- Adicione novos hospitais neste formato; cada entrada pode ter um raio diferente.
		{ Coords = vec3(-1010.46,-425.81,39.61), Radius = 100.0 }
	},

	-- Usado somente quando Mode = "coordinate".
	Beds = {
		{ Coords = vec4(-905.85,-735.01,18.89,0.0), Invert = 180.0 },
		{ Coords = vec4(-902.20,-734.83,18.89,351.5), Invert = 180.0 },
		{ Coords = vec4(-903.49,-725.56,18.89,181.42), Invert = 180.0 },
		{ Coords = vec4(-907.38,-725.56,18.89,172.92), Invert = 180.0 },
		{ Coords = vec4(-911.32,-725.39,18.89,184.26), Invert = 180.0 }
	},

	-- Usado somente quando Mode = "object".
	-- Aceita o hash numerico ou o nome do prop como chave, por exemplo: ["v_med_bed1"] = { ... }.
	-- Offset posiciona o jogador sobre a maca e HeadingOffset corrige sua orientacao.
	Models = {
		[1004440924]  = { Offset = vec3(0.0,-0.4,0.0), HeadingOffset = -180.0 },
		[256650529]   = { Offset = vec3(0.0,-0.4,0.0), HeadingOffset = -180.0 },
		[998593452]   = { Offset = vec3(0.0,-0.4,0.0), HeadingOffset = -180.0 },
		[-1248745872] = { Offset = vec3(0.0,-0.4,0.0), HeadingOffset = -180.0 },
		[3046221424]  = { Offset = vec3(0.0,-0.4,0.0), HeadingOffset = -180.0 },
		[835950247]   = { Offset = vec3(0.0,-0.4,0.0), HeadingOffset = -180.0 },
		[1631638868]  = { Offset = vec3(0.0,0.0,0.1), HeadingOffset = -180.0 },
		[-1091386327] = { Offset = vec3(0.0,0.4,0.0), HeadingOffset = 0.0 },
		[3203580969]  = { Offset = vec3(0.0,0.4,0.0), HeadingOffset = 0.0 },
		[2117668672]  = { Offset = vec3(0.0,0.4,0.0), HeadingOffset = 0.0 }
	}
}

local TargetRetryInterval = math.max(tonumber(Config.Target.RetryInterval) or 1000,250)
local AnimationMonitorInterval = math.max(tonumber(Config.Animation.MonitorInterval) or 1000,250)
local TreatmentTickInterval = math.max(tonumber(Config.Treatment.TickInterval) or 1000,100)
local InBed = false
local OutBed = false
local Treatment = false
local CheckingIn = false
local TargetRegistered = false
local TargetError = false
local CurrentResource = GetCurrentResourceName()
local OptionNames = { "beds:putbed","beds:treatment" }
local BedMode = string.lower(tostring(Config.Mode or "object"))
local BedModels = {}
local Models = {}
local CoordinateZones = {}

if BedMode ~= "object" and BedMode ~= "coordinate" then
	print(("^3[core-modules]^7 Mode '%s' invalido em beds.lua; usando 'object'."):format(tostring(Config.Mode)))
	BedMode = "object"
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MODEL HELPERS
-----------------------------------------------------------------------------------------------------------------------------------------
local function AddModel(Model,Data,Added)
	local Hash = type(Model) == "string" and GetHashKey(Model) or tonumber(Model)
	if not Hash then
		return
	end

	local Hashes = { Hash }
	if Hash < 0 then
		Hashes[#Hashes + 1] = Hash + 4294967296
	elseif Hash > 2147483647 then
		Hashes[#Hashes + 1] = Hash - 4294967296
	end

	for Number = 1,#Hashes do
		local CurrentHash = Hashes[Number]
		BedModels[CurrentHash] = Data

		if not Added[CurrentHash] then
			Added[CurrentHash] = true
			Models[#Models + 1] = CurrentHash
		end
	end
end

do
	local Added = {}
	for Model,Data in pairs(Config.Models or {}) do
		AddModel(Model,Data,Added)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
local function NormalizeHeading(Heading)
	Heading = Heading % 360.0

	if Heading < 0 then
		Heading = Heading + 360.0
	end

	return Heading
end

local function ToVector3(Coords)
	local CoordsType = type(Coords)
	if CoordsType ~= "vector3" and CoordsType ~= "vector4" and CoordsType ~= "table" then
		return false
	end

	if not tonumber(Coords.x) or not tonumber(Coords.y) or not tonumber(Coords.z) then
		return false
	end

	return vec3(Coords.x + 0.0,Coords.y + 0.0,Coords.z + 0.0)
end

local function VectorHeading(Coords)
	if type(Coords) == "vector4" then
		return tonumber(Coords.w)
	end

	if type(Coords) == "table" then
		return tonumber(Coords.w or Coords[4])
	end
end

local function HospitalData(Hospital)
	if type(Hospital) == "vector3" then
		return Hospital,Config.DefaultRadius
	end

	if type(Hospital) == "table" then
		return Hospital.Coords,Hospital.Radius or Config.DefaultRadius
	end
end

local function NearHospital(Coords,Tolerance)
	if not Config.RestrictToHospitals then
		return true
	end

	for Number = 1,#(Config.Hospitals or {}) do
		local HospitalCoords,Radius = HospitalData(Config.Hospitals[Number])
		if HospitalCoords and Radius and #(Coords - HospitalCoords) <= Radius + (Tolerance or 0.0) then
			return true
		end
	end

	return false
end

local function OtherPlayerInBed(Coords,CustomRadius)
	local OccupiedRadius = tonumber(CustomRadius) or Config.Interaction.OccupiedRadius or 0.0
	if OccupiedRadius <= 0.0 then
		return false
	end

	local LocalPlayerId = PlayerId()
	for _,PlayerId in ipairs(GetActivePlayers()) do
		if PlayerId ~= LocalPlayerId then
			local ServerId = GetPlayerServerId(PlayerId)
			local PlayerState = Player(ServerId).state
			local Ped = GetPlayerPed(PlayerId)

			if PlayerState.Bed and DoesEntityExist(Ped) and #(GetEntityCoords(Ped) - Coords) <= OccupiedRadius then
				return true
			end
		end
	end

	return false
end

local function CoordinateBedData(Data,CheckDistance,CheckOccupied)
	if not Config.Enabled or BedMode ~= "coordinate" or type(Data) ~= "table" or Data.Enabled == false then
		return false
	end

	local ZoneCoords = ToVector3(Data.Coords)
	if not ZoneCoords then
		return false
	end

	local InteractionZOffset = tonumber(Data.InteractionZOffset) or Config.Coordinate.InteractionZOffset or 0.0
	local InteractionCoords = vec3(ZoneCoords.x,ZoneCoords.y,ZoneCoords.z + InteractionZOffset)

	if CheckDistance then
		local MaxDistance = (tonumber(Data.Distance) or Config.Interaction.Distance or 1.5) + (Config.Interaction.UseTolerance or 0.0)
		if #(GetEntityCoords(PlayerPedId()) - InteractionCoords) > MaxDistance then
			return false
		end
	end

	local PlayerCoords = vec3(ZoneCoords.x,ZoneCoords.y,ZoneCoords.z + (tonumber(Data.ZOffset) or Config.Coordinate.PlayerZOffset or 0.0))
	if CheckOccupied and OtherPlayerInBed(PlayerCoords,Data.OccupiedRadius) then
		return false
	end

	local ZoneHeading = tonumber(Data.Heading) or VectorHeading(Data.Coords) or 0.0
	local Heading = ZoneHeading - (tonumber(Data.Invert) or 0.0)

	return {
		Coords = PlayerCoords,
		InteractionCoords = InteractionCoords,
		Heading = NormalizeHeading(Heading)
	}
end

local function BedData(Entity,CheckDistance,CheckOccupied)
	if not Config.Enabled or BedMode ~= "object" or not Entity or Entity <= 0 or not DoesEntityExist(Entity) or GetEntityType(Entity) ~= 3 then
		return false
	end

	local Data = BedModels[GetEntityModel(Entity)]
	if not Data then
		return false
	end

	local EntityCoords = GetEntityCoords(Entity)
	if not NearHospital(EntityCoords) then
		return false
	end

	if CheckDistance then
		local MaxDistance = (Config.Interaction.Distance or 1.5) + (Config.Interaction.UseTolerance or 0.0)
		if #(GetEntityCoords(PlayerPedId()) - EntityCoords) > MaxDistance then
			return false
		end
	end

	if CheckOccupied and OtherPlayerInBed(EntityCoords) then
		return false
	end

	return Data
end

local function SetBedState(State)
	LocalPlayer.state:set("Bed",State,true)
end

local function StartBedAnimation(Ped)
	if not InBed or not LoadAnim(Config.Animation.Dict) then
		return false
	end

	RequestCollisionAtCoord(InBed.Coords.x,InBed.Coords.y,InBed.Coords.z)
	FreezeEntityPosition(Ped,false)
	ClearPedTasksImmediately(Ped)
	SetPedKeepTask(Ped,true)
	TaskPlayAnimAdvanced(
		Ped,
		Config.Animation.Dict,
		Config.Animation.Name,
		InBed.Coords.x,InBed.Coords.y,InBed.Coords.z,
		0.0,0.0,InBed.Heading,
		8.0,-8.0,-1,
		Config.Animation.Flag or 9,
		0.0,2,0
	)

	return true
end

local function LeaveBed(Force)
	if (Treatment or CheckingIn) and not Force then
		return false
	end

	local Ped = PlayerPedId()
	FreezeEntityPosition(Ped,false)
	SetPedKeepTask(Ped,false)

	if InBed then
		ClearPedTasks(Ped)
	end

	if OutBed and OutBed.Coords then
		RequestCollisionAtCoord(OutBed.Coords.x,OutBed.Coords.y,OutBed.Coords.z)
		SetEntityCoords(Ped,OutBed.Coords.x,OutBed.Coords.y,OutBed.Coords.z,false,false,false,false)
		SetEntityHeading(Ped,OutBed.Heading)
	end

	SetBedState(false)
	OutBed = false
	InBed = false

	return true
end

local function EnterBed(Coords,Heading,Entity)
	if Treatment or LocalPlayer.state.Bed or InBed then
		return false
	end

	local Ped = PlayerPedId()
	OutBed = {
		Coords = GetEntityCoords(Ped),
		Heading = GetEntityHeading(Ped)
	}
	InBed = {
		Entity = Entity or false,
		Coords = Coords,
		Heading = NormalizeHeading(Heading)
	}

	if not StartBedAnimation(Ped) then
		OutBed = false
		InBed = false
		return false
	end

	SetBedState(true)

	return true
end

local function PutBed(Entity)
	if Treatment or LocalPlayer.state.Bed or InBed then
		return false
	end

	local Data = BedData(Entity,true,true)
	if not Data then
		return false
	end

	local Offset = Data.Offset or vec3(0.0,0.0,0.0)
	local Coords = GetOffsetFromEntityInWorldCoords(Entity,Offset.x,Offset.y,Offset.z)
	local Heading = NormalizeHeading(GetEntityHeading(Entity) + (Data.HeadingOffset or 0.0))

	return EnterBed(Coords,Heading,Entity)
end

local function PutCoordinateBed(Data)
	local Point = CoordinateBedData(Data,true,true)
	if not Point then
		return false
	end

	return EnterBed(Point.Coords,Point.Heading,false)
end

local function SetTreatmentState(State)
	local Ped = PlayerPedId()
	Treatment = State and GetGameTimer() + TreatmentTickInterval or false
	LocalPlayer.state:set("BedTreatment",State,false)
	LocalPlayer.state:set("Commands",State,true)
	LocalPlayer.state:set("Buttons",State,true)
	LocalPlayer.state:set("Cancel",State,true)
	NetworkSetFriendlyFireOption(not State)
	SetEntityInvincible(Ped,State)

	if State then
		TriggerEvent("paramedic:Reset")
	end
end

local function FinishTreatment(Completed)
	if not Treatment then
		return
	end

	SetTreatmentState(false)

	if Completed then
		TriggerEvent("Notify","Centro Médico","Tratamento concluído.","sangue",5000)
	end

	if InBed then
		LeaveBed(true)
	end
end

local function BeginTreatment(PutFunction,Data)
	if Treatment or LocalPlayer.state.Bed or InBed then
		return false
	end

	CheckingIn = true
	if not PutFunction(Data) then
		CheckingIn = false
		return false
	end

	local Approved = vSERVER.CheckIn()
	CheckingIn = false

	if not Approved then
		LeaveBed(true)
		return false
	end

	local Ped = PlayerPedId()
	if GetEntityHealth(Ped) <= 100 then
		exports.survival:Revive(Config.Treatment.ReviveHealth)
	end

	if not IsEntityPlayingAnim(Ped,Config.Animation.Dict,Config.Animation.Name,3) and not StartBedAnimation(Ped) then
		LeaveBed(true)
		return false
	end
	SetTreatmentState(true)
	return true
end

local function DoTreatment(Entity)
	return BeginTreatment(PutBed,Entity)
end

local function DoCoordinateTreatment(Data)
	return BeginTreatment(PutCoordinateBed,Data)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INTERACTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
local BedOptions = {
	{
		name = "beds:putbed",
		label = Config.Interaction.LieLabel,
		icon = Config.Interaction.LieIcon,
		distance = Config.Interaction.Distance,
		cooldown = Config.Interaction.Cooldown,
		canInteract = function(Entity)
			return not Treatment and not LocalPlayer.state.Bed and not InBed and GetEntityHealth(PlayerPedId()) > 100 and BedData(Entity,false,true) ~= false
		end,
		onSelect = function(Data)
			PutBed(Data.entity)
		end
	},{
		name = "beds:treatment",
		label = Config.Interaction.TreatmentLabel,
		icon = Config.Interaction.TreatmentIcon,
		distance = Config.Interaction.Distance,
		cooldown = Config.Interaction.Cooldown,
		canInteract = function(Entity)
			return not Treatment and not LocalPlayer.state.Bed and not InBed and BedData(Entity,false,true) ~= false
		end,
		onSelect = function(Data)
			DoTreatment(Data.entity)
		end
	}
}

local function CoordinateOptions(Data,Index)
	local Distance = tonumber(Data.Distance) or Config.Interaction.Distance

	return {
		{
			name = "beds:coordinate:lie:"..Index,
			label = Config.Interaction.LieLabel,
			icon = Config.Interaction.LieIcon,
			distance = Distance,
			cooldown = Config.Interaction.Cooldown,
			canInteract = function()
				return not Treatment and not LocalPlayer.state.Bed and not InBed and GetEntityHealth(PlayerPedId()) > 100 and CoordinateBedData(Data,false,true) ~= false
			end,
			onSelect = function()
				PutCoordinateBed(Data)
			end
		},{
			name = "beds:coordinate:treatment:"..Index,
			label = Config.Interaction.TreatmentLabel,
			icon = Config.Interaction.TreatmentIcon,
			distance = Distance,
			cooldown = Config.Interaction.Cooldown,
			canInteract = function()
				return not Treatment and not LocalPlayer.state.Bed and not InBed and CoordinateBedData(Data,false,true) ~= false
			end,
			onSelect = function()
				DoCoordinateTreatment(Data)
			end
		}
	}
end

local function TargetStarted()
	return Config.Enabled and GetResourceState(Config.Target.Resource) == "started"
end

local function RemoveCoordinateZones()
	for Number = 1,#CoordinateZones do
		pcall(function()
			exports[Config.Target.Resource]:removeCoords(CoordinateZones[Number])
		end)
	end

	CoordinateZones = {}
end

local function RegisterTarget()
	local HasTargets = BedMode == "object" and #Models > 0 or BedMode == "coordinate" and #(Config.Beds or {}) > 0
	if TargetRegistered or not TargetStarted() or not HasTargets then
		return false
	end

	local Success,Error = pcall(function()
		if BedMode == "object" then
			exports[Config.Target.Resource]:addModel(Models,BedOptions)
		else
			for Index,Data in ipairs(Config.Beds or {}) do
				local Point = CoordinateBedData(Data,false,false)
				if Point then
					local CoordinateId = exports[Config.Target.Resource]:addCoords(Point.InteractionCoords,CoordinateOptions(Data,Index))
					CoordinateZones[#CoordinateZones + 1] = CoordinateId
				else
					print(("^3[core-modules]^7 Coordenada de maca invalida no indice %s."):format(Index))
				end
			end
		end
	end)

	if Success then
		TargetRegistered = true
		TargetError = false
		return true
	end

	if Error ~= TargetError then
		TargetError = Error
		print(("^1[core-modules]^7 Nao foi possivel registrar as macas em %s: %s"):format(Config.Target.Resource,Error))
	end

	if BedMode == "object" and #Models > 0 then
		pcall(function()
			exports[Config.Target.Resource]:removeModel(Models,OptionNames)
		end)
	end
	RemoveCoordinateZones()

	return false
end

local function RemoveTarget()
	if TargetStarted() then
		if BedMode == "object" and #Models > 0 then
			pcall(function()
				exports[Config.Target.Resource]:removeModel(Models,OptionNames)
			end)
		end

		RemoveCoordinateZones()
	else
		CoordinateZones = {}
	end

	TargetRegistered = false
end

CreateThread(function()
	while true do
		if TargetStarted() then
			RegisterTarget()
		else
			TargetRegistered = false
			CoordinateZones = {}
		end

		Wait(TargetRetryInterval)
	end
end)

AddEventHandler("onClientResourceStart",function(Resource)
	if Resource == Config.Target.Resource then
		TargetRegistered = false
		CoordinateZones = {}
		CreateThread(function()
			Wait(250)
			RegisterTarget()
		end)
	end
end)

AddEventHandler("onClientResourceStop",function(Resource)
	if Resource == Config.Target.Resource then
		TargetRegistered = false
	elseif Resource == CurrentResource then
		RemoveTarget()
		FinishTreatment(false)
		LeaveBed(true)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TARGET:UPBED
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("target:UpBed",function()
	return LeaveBed(false)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- STARTTREATMENT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("target:StartTreatment")
AddEventHandler("target:StartTreatment",function()
	if Treatment or CheckingIn then
		return false
	end

	SetTreatmentState(true)
	return true
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BED MONITOR
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	if LocalPlayer.state.Bed then
		local Ped = PlayerPedId()
		FreezeEntityPosition(Ped,false)
		SetPedKeepTask(Ped,false)
		ClearPedTasks(Ped)
	end

	if LocalPlayer.state.BedTreatment then
		LocalPlayer.state:set("Commands",false,true)
		LocalPlayer.state:set("Buttons",false,true)
		LocalPlayer.state:set("Cancel",false,true)
		NetworkSetFriendlyFireOption(true)
		SetEntityInvincible(PlayerPedId(),false)
		LocalPlayer.state:set("BedTreatment",false,false)
	end

	SetBedState(false)

	while true do
		if InBed then
			local Ped = PlayerPedId()

			if not LocalPlayer.state.Bed or (IsEntityDead(Ped) and not CheckingIn) or (InBed.Entity and not DoesEntityExist(InBed.Entity)) then
				if Treatment then
					FinishTreatment(false)
				else
					LeaveBed(true)
				end
			end
		elseif LocalPlayer.state.Bed then
			SetBedState(false)
		end

		Wait(AnimationMonitorInterval)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADTREATMENT
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		local Time = TreatmentTickInterval

		if Treatment and GetGameTimer() >= Treatment then
			local Ped = PlayerPedId()
			local Health = GetEntityHealth(Ped)

			Treatment = GetGameTimer() + TreatmentTickInterval

			if Health < Config.Treatment.MaxHealth then
				SetEntityHealth(Ped,math.min(Config.Treatment.MaxHealth,Health + Config.Treatment.HealthPerTick))
			else
				FinishTreatment(true)
			end
		end

		Wait(Time)
	end
end)
