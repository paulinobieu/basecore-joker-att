-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
vSERVER = Tunnel.getInterface("core-influencers")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local EmotesByCmd = {}

local UIOpen = false
local ActiveEmote = false
local ActiveProps = {}
local ActivePartner = nil
local CurrentSyncId = nil
local LastPlayOtherSync = nil
local PendingSync = nil

local Group = { owner = nil, members = {}, enabled = false, isOwner = false }

local MuteKvp = "core_influencers:mute"
local Muted = (GetResourceKvpInt(MuteKvp) or 0) == 1

local Active3DSounds = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- THEME
-----------------------------------------------------------------------------------------------------------------------------------------
local function ResolveColors()
	local Hex = (Theme and Theme.main) or Influencers.ThemeColor or "#37dae6"
	local R,G,B = Functions.HexToRgb(Hex)
	local Sec = string.format("#%02x%02x%02x",
		math.floor(R * 0.72),math.floor(G * 0.72),math.floor(B * 0.72))
	return { primaryColor = "#"..Hex:gsub("#",""), secondaryColor = Sec, thirdyColor = "#ffffff" }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CATALOG
-----------------------------------------------------------------------------------------------------------------------------------------
local CatalogPayload = { order = {}, groups = {} }

local function LoadCatalog()
	local Pack = Influencers.EmotePack or {}
	local Groups = {}
	local Seen = {}

	local function Add(Emote)
		if not Emote or not Emote.Command or not Emote.Label then return end

		local Command = tostring(Emote.Command)
		if Seen[Command] then return end
		Seen[Command] = true
		EmotesByCmd[Emote.Command] = Emote

		local Category = Emote.Category
		if type(Category) ~= "string" or Category == "" then
			Category = Influencers.DefaultCategory
		end

		Groups[Category] = Groups[Category] or {}
		Groups[Category][#Groups[Category]+1] = {
			label = tostring(Emote.Label),
			command = Command,
			music = (Emote.soundFile ~= nil and Emote.soundFile ~= ""),
			sync = Emote.Synchronized == true,
		}
	end

	for _,Emote in ipairs(Pack.options or {}) do
		Add(Emote)
	end

	for CategoryName,CategoryData in pairs(Pack.categories or {}) do
		for _,Entry in ipairs(CategoryData.emoteList or {}) do
			if Entry.command or Entry.Command then
				Add({
					Label = Entry.label or Entry.Label,
					Command = Entry.command or Entry.Command,
					Dictionary = Entry.dict or Entry.Dictionary,
					Animation = Entry.anim or Entry.Animation,
					soundFile = Entry.soundFile,
					volume = Entry.volume or Influencers.Sound.Volume,
					Category = CategoryName,
					Synchronized = Entry.Synchronized or false,
					Options = {
						Flags = {
							Loop = (Entry.loop == true) or (Entry.Options and Entry.Options.Flags and Entry.Options.Flags.Loop) or false,
							Move = (Entry.Options and Entry.Options.Flags and Entry.Options.Flags.Move) or false,
						},
						Shared = Entry.Options and Entry.Options.Shared or nil,
						Props = Entry.Options and Entry.Options.Props or nil,
					},
				})
			end
		end
	end

	local Order = {}
	local Ordered = {}
	for _,Name in ipairs(Influencers.CategoryOrder or {}) do
		if Groups[Name] and not Ordered[Name] then
			Order[#Order+1] = Name
			Ordered[Name] = true
		end
	end

	local Rest = {}
	for Name in pairs(Groups) do
		if not Ordered[Name] then Rest[#Rest+1] = Name end
	end
	table.sort(Rest)
	for _,Name in ipairs(Rest) do
		Order[#Order+1] = Name
	end

	CatalogPayload = { order = Order, groups = Groups }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GROUP HELPERS
-----------------------------------------------------------------------------------------------------------------------------------------
local function GroupCount()
	return #(Group.members or {})
end

local function IsGroupOwner()
	return Group.isOwner == true
end

local function RefreshGroupUI()
	if not UIOpen then return end
	SendNUIMessage({ action = "groupState", payload = {
		group = {
			owner = Group.owner,
			members = Group.members or {},
			enabled = Group.enabled == true,
			isOwner = Group.isOwner == true,
		},
	} })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MUTE
-----------------------------------------------------------------------------------------------------------------------------------------
local function SyncMuteUI()
	SendNUIMessage({ action = "muteState", payload = { muted = Muted } })
end

local function SetMuted(Value)
	Muted = Value == true
	SetResourceKvpInt(MuteKvp,Muted and 1 or 0)
	SyncMuteUI()

	if Muted then
		SendNUIMessage({ action = "soundStopAll" })
	else
		for Sid,Data in pairs(Active3DSounds) do
			SendNUIMessage({ action = "sound3dPlay", payload = {
				id = tostring(Sid), file = Data.file, volume = Data.vol or Influencers.Sound.Volume,
			} })
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- 3D SOUND
-----------------------------------------------------------------------------------------------------------------------------------------
local function PlayEmoteSound(Emote)
	if not Emote or not Emote.soundFile or Emote.soundFile == "" then return end
	TriggerServerEvent("core-influencers:PlaySoundNear",Emote.soundFile,Emote.volume or Influencers.Sound.Volume,Influencers.Sound.Radius)
end

local function StopEmoteSound()
	TriggerServerEvent("core-influencers:StopSoundNear")
end

RegisterNetEvent("core-influencers:PlaySound",function(Sid,File,Volume,Radius)
	Sid = tonumber(Sid)
	if not Sid or not File or File == "" then return end

	Active3DSounds[Sid] = {
		file = File,
		vol = tonumber(Volume) or Influencers.Sound.Volume,
		radius = tonumber(Radius) or Influencers.Sound.Radius,
	}

	if not Muted then
		SendNUIMessage({ action = "sound3dPlay", payload = {
			id = tostring(Sid), file = File, volume = tonumber(Volume) or Influencers.Sound.Volume,
		} })
	end
end)

RegisterNetEvent("core-influencers:StopSound",function(Sid)
	Sid = tonumber(Sid)
	if not Sid then return end
	Active3DSounds[Sid] = nil
	SendNUIMessage({ action = "sound3dStop", payload = { id = tostring(Sid) } })
end)

CreateThread(function()
	while true do
		Wait(100)
		if next(Active3DSounds) ~= nil then
			local Ped = PlayerPedId()
			local Listener = GetEntityCoords(Ped)
			local CamRot = GetGameplayCamRot(2)
			local Heading = CamRot.z or GetEntityHeading(Ped)

			local Sources = {}
			for Sid,Data in pairs(Active3DSounds) do
				local Pid = GetPlayerFromServerId(tonumber(Sid))
				local Gain = 0.0
				local X,Y,Z = Listener.x,Listener.y,Listener.z

				if Pid ~= -1 then
					local SourcePed = GetPlayerPed(Pid)
					if SourcePed and SourcePed ~= 0 then
						local SourceCoords = GetEntityCoords(SourcePed)
						X,Y,Z = SourceCoords.x,SourceCoords.y,SourceCoords.z

						local Distance = #(Listener - SourceCoords)
						local Radius = tonumber(Data.radius) or Influencers.Sound.Radius
						if Distance < Radius then
							Gain = (tonumber(Data.vol) or Influencers.Sound.Volume) * (1.0 - (Distance / Radius))
							Gain = math.max(0.0,math.min(1.0,Gain))
						end
					end
				end

				Sources[#Sources+1] = { id = tostring(Sid), x = X + 0.0, y = Y + 0.0, z = Z + 0.0, gain = Gain + 0.0 }
			end

			SendNUIMessage({ action = "audioUpdate", payload = {
				listener = { x = Listener.x + 0.0, y = Listener.y + 0.0, z = Listener.z + 0.0, heading = Heading + 0.0 },
				sources = Sources,
			} })
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EMOTE ENGINE
-----------------------------------------------------------------------------------------------------------------------------------------
local function LoadAnimDict(Dict)
	if not Dict or Dict == "" then return false end
	if HasAnimDictLoaded(Dict) then return true end
	RequestAnimDict(Dict)
	local Timeout = GetGameTimer() + 5000
	while not HasAnimDictLoaded(Dict) and GetGameTimer() < Timeout do
		Wait(0)
	end
	return HasAnimDictLoaded(Dict)
end

local function BuildFlag(Flags)
	Flags = Flags or {}
	if Flags.Flag ~= nil then return tonumber(Flags.Flag) or 0 end
	local Loop = Flags.Loop == true
	local Move = Flags.Move == true
	if Loop and Move then return 51 end
	if Loop and not Move then return 1 end
	if (not Loop) and Move then return 48 end
	return 0
end

local function ToVec3(Value)
	if type(Value) == "vector3" or type(Value) == "vec3" then
		return vec3(Value.x,Value.y,Value.z)
	end
	return Value
end

local function ReadPlacement(Shared)
	local Placement = Shared and Shared.Placement
	if type(Placement) == "table" then
		return ToVec3(Placement[1]) or vec3(0.0,0.0,0.0),ToVec3(Placement[2]) or vec3(0.0,0.0,0.0)
	end
	return vec3(0.0,0.0,0.0),vec3(0.0,0.0,0.0)
end

local function ClearProps()
	for _,Entity in ipairs(ActiveProps) do
		if DoesEntityExist(Entity) then DeleteEntity(Entity) end
	end
	ActiveProps = {}
end

local function SpawnProps(Ped,Props,Command)
	if not Props then return end

	if Command then
		TriggerServerEvent("core-influencers:AddPropToPlayer",Command)
	end

	for _,Prop in ipairs(Props) do
		if Prop and Prop.Name and Prop.Name ~= "" then
			local Model = joaat(Prop.Name)
			RequestModel(Model)
			local Timeout = GetGameTimer() + 5000
			while not HasModelLoaded(Model) and GetGameTimer() < Timeout do
				Wait(0)
			end

			if HasModelLoaded(Model) then
				local Object = CreateObject(Model,0.0,0.0,0.0,true,true,false)
				SetModelAsNoLongerNeeded(Model)

				local Bone = Prop.Bone or 57005
				local Pos = ToVec3(Prop.Placement and Prop.Placement[1]) or vec3(0.0,0.0,0.0)
				local Rot = ToVec3(Prop.Placement and Prop.Placement[2]) or vec3(0.0,0.0,0.0)

				AttachEntityToEntity(Object,Ped,GetPedBoneIndex(Ped,Bone),
					Pos.x,Pos.y,Pos.z,Rot.x,Rot.y,Rot.z,true,true,false,true,2,true)

				ActiveProps[#ActiveProps+1] = Object
			end
		end
	end
end

local function PlayEmoteOnPed(Ped,Emote)
	if not Emote then return false end
	if Emote.Dictionary and not LoadAnimDict(Emote.Dictionary) then return false end

	local Flag = BuildFlag(Emote.Options and Emote.Options.Flags or {})
	TaskPlayAnim(Ped,Emote.Dictionary or "",Emote.Animation or "",8.0,8.0,-1,Flag,0.0,false,false,false)
	ActiveEmote = true
	return true
end

local function HasActiveEmote()
	return ActiveEmote == true or ActivePartner ~= nil or CurrentSyncId ~= nil or #ActiveProps > 0
end

local function StopEmote(Sync)
	if not HasActiveEmote() then return false end

	local Ped = PlayerPedId()
	ClearProps()
	if IsEntityAttached(Ped) then DetachEntity(Ped,true,true) end
	ClearPedTasksImmediately(Ped)

	if Sync ~= false and ActivePartner then
		TriggerServerEvent("core-influencers:SyncCancel",ActivePartner)
	end

	ActivePartner = nil
	CurrentSyncId = nil
	ActiveEmote = false
	StopEmoteSound()
	return true
end

local function WaitNetStart(NetStart)
	if not NetStart then return end
	while GetNetworkTime() < NetStart do Wait(0) end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYNC
-----------------------------------------------------------------------------------------------------------------------------------------
local function ClosestPlayer(MaxDistance)
	local Me = PlayerPedId()
	local MyCoords = GetEntityCoords(Me)
	local Best,BestDistance = nil,MaxDistance or Influencers.SyncDistance

	for _,Pid in ipairs(GetActivePlayers()) do
		local Ped = GetPlayerPed(Pid)
		if Ped ~= Me then
			local Distance = #(GetEntityCoords(Ped) - MyCoords)
			if Distance < BestDistance then
				BestDistance = Distance
				Best = GetPlayerServerId(Pid)
			end
		end
	end
	return Best
end

local function PedFromServerId(Sid)
	local Pid = GetPlayerFromServerId(Sid)
	if not Pid or Pid == -1 then return nil end
	local Ped = GetPlayerPed(Pid)
	if Ped == 0 or not DoesEntityExist(Ped) then return nil end
	return Ped
end

local function WrapAngle(Angle)
	return (Angle + 180.0) % 360.0 - 180.0
end

local function ApplySenderSync(MyPed,TargetPed,Shared)
	Shared = Shared or {}
	local FrontOffset = (Shared.FrontOffset ~= nil) and (Shared.FrontOffset + 0.0) or 1.0
	local SideOffset = (Shared.SideOffset ~= nil) and (Shared.SideOffset + 0.0) or 0.0
	local HeightOffset = (Shared.HeightOffset ~= nil) and (Shared.HeightOffset + 0.0) or 0.0
	local HeadingOffset = (Shared.HeadingOffset ~= nil) and (Shared.HeadingOffset + 0.0) or 180.1

	if Shared.Attach then
		local Pos,Rot = ReadPlacement(Shared)
		AttachEntityToEntity(MyPed,TargetPed,GetPedBoneIndex(TargetPed,Shared.Bone or -1),
			Pos.x,Pos.y,Pos.z,Rot.x,Rot.y,Rot.z,false,false,false,true,1,true)
	elseif IsEntityAttached(MyPed) then
		DetachEntity(MyPed,true,true)
	end

	local TargetCoords = GetOffsetFromEntityInWorldCoords(TargetPed,SideOffset,FrontOffset,HeightOffset)
	SetEntityHeading(MyPed,GetEntityHeading(TargetPed) - HeadingOffset)
	SetEntityCoordsNoOffset(MyPed,TargetCoords.x,TargetCoords.y,TargetCoords.z,false,false,false)
end

local function ApplyTargetSync(MyPed,SenderPed,Shared,SenderAttachFlag)
	Shared = Shared or {}
	if Shared.Attach and not SenderAttachFlag then
		local Pos,Rot = ReadPlacement(Shared)
		AttachEntityToEntity(MyPed,SenderPed,GetPedBoneIndex(SenderPed,Shared.Bone or -1),
			Pos.x,Pos.y,Pos.z,Rot.x,Rot.y,Rot.z,false,false,false,true,1,true)
	elseif IsEntityAttached(MyPed) then
		DetachEntity(MyPed,true,true)
	end
end

local function PlayEmote(Command)
	local Emote = EmotesByCmd[Command]
	if not Emote then return false end

	if not Emote.Synchronized then
		StopEmote(false)
		local Ped = PlayerPedId()

		if Emote.Options and Emote.Options.Props then
			SpawnProps(Ped,Emote.Options.Props,Command)
		end

		local NetStart = GetNetworkTime() + 450
		local SyncId = ("%s:%s:%s"):format(GetPlayerServerId(PlayerId()),Command,NetStart)

		WaitNetStart(NetStart)
		if not PlayEmoteOnPed(Ped,Emote) then return false end
		PlayEmoteSound(Emote)

		if IsGroupOwner() and Group.enabled and GroupCount() > 0 then
			TriggerServerEvent("core-influencers:GroupPlay",Command,NetStart,SyncId)
		end
		return true
	end

	local Shared = Emote.Options and Emote.Options.Shared or {}
	if not Shared.OtherEmote then
		Functions.Notify(nil,"Influencers",Influencers.Language.SyncNoPair,"aviso",5000)
		return false
	end

	local TargetSid = ClosestPlayer(Influencers.SyncDistance)
	if not TargetSid then
		Functions.Notify(nil,"Influencers",Influencers.Language.SyncNoTarget,"aviso",5000)
		return false
	end
	if not PedFromServerId(TargetSid) then
		Functions.Notify(nil,"Influencers",Influencers.Language.SyncTargetNotFound,"aviso",5000)
		return false
	end

	PendingSync = {
		targetSid = TargetSid,
		cmd = Command,
		otherCmd = Shared.OtherEmote,
		attach = Shared.Attach == true,
	}
	Functions.Notify(nil,"Influencers",Influencers.Language.SyncWaiting,"aviso",5000)
	TriggerServerEvent("core-influencers:SyncRequest",TargetSid,Command)
	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CAMERA (CREATOR)
-----------------------------------------------------------------------------------------------------------------------------------------
local CameraAspects = { "1:1","4:3","3:4","16:9","9:16" }

local Cam = {
	active = false, cam = nil, mode = "selfie", fov = 55.0,
	pitch = -4.0, yaw = 0.0, roll = 0.0,
	offsetX = 0.342, offsetY = 0.032, offsetZ = -0.136,
	sway = true, faceTrack = true, grid = true, cleanCapture = false,
	dof = false, dofStrength = 0.22, light = false, aspect = "16:9",
	activeKeys = {},
}

local function LerpScalar(A,B,T) return A + ((B - A) * T) end

local function LerpVec(A,B,T)
	if not A then return B end
	return vector3(LerpScalar(A.x,B.x,T),LerpScalar(A.y,B.y,T),LerpScalar(A.z,B.z,T))
end

local function LerpAngle(A,B,T) return A + (WrapAngle(B - A) * T) end

local function RotationToDirection(Rot)
	local Z,X = math.rad(Rot.z),math.rad(Rot.x)
	local Num = math.abs(math.cos(X))
	return vector3(-math.sin(Z) * Num,math.cos(Z) * Num,math.sin(X))
end

local function DirectionToRotation(Dir)
	local Length = math.sqrt((Dir.x * Dir.x) + (Dir.y * Dir.y) + (Dir.z * Dir.z))
	if Length <= 0.0001 then return vector3(0.0,0.0,0.0) end
	return vector3(math.deg(math.asin(Dir.z / Length)),0.0,math.deg(math.atan2(-Dir.x / Length,Dir.y / Length)))
end

local function CameraPayload()
	return {
		mode = Cam.mode or "selfie",
		aspect = Cam.aspect or "16:9",
		zoom = string.format("%.1fx",55.0 / math.max(1.0,Cam.fov or 55.0)),
		light = Cam.light == true,
		dof = Cam.dof == true,
		grid = Cam.grid ~= false,
		faceTrack = Cam.faceTrack == true,
		cleanCapture = Cam.cleanCapture == true,
		keys = Cam.activeKeys or {},
	}
end

local LastCameraSig = nil
local function SendCameraState()
	if not Cam.active then return end
	local Payload = CameraPayload()
	local Sig = Payload.mode..Payload.aspect..Payload.zoom..tostring(Payload.light)..tostring(Payload.dof)
		..tostring(Payload.grid)..tostring(Payload.faceTrack)..tostring(Payload.cleanCapture)
	for Key,Value in pairs(Payload.keys) do
		if Value then Sig = Sig.."|"..Key end
	end
	if Sig == LastCameraSig then return end
	LastCameraSig = Sig
	SendNUIMessage({ action = "cameraUpdate", payload = Payload })
end

local function PlayCameraHoldAnim()
	local Ped = PlayerPedId()
	if LoadAnimDict("cellphone@self") then
		TaskPlayAnim(Ped,"cellphone@self","selfie",8.0,-8.0,-1,49,0.0,false,false,false)
	end
end

local function KeepCameraHoldAnim()
	local Ped = PlayerPedId()
	if HasAnimDictLoaded("cellphone@self") and not IsEntityPlayingAnim(Ped,"cellphone@self","selfie",3) then
		TaskPlayAnim(Ped,"cellphone@self","selfie",8.0,-8.0,-1,49,0.0,false,false,false)
	end
end

local function DestroyCamera()
	if not Cam.active then return end
	Cam.active = false
	RenderScriptCams(false,true,350,true,true)
	if Cam.cam and DoesCamExist(Cam.cam) then DestroyCam(Cam.cam,false) end
	Cam.cam = nil
	Cam.smoothCoord,Cam.smoothPitch,Cam.smoothYaw,Cam.smoothRoll,Cam.smoothFov = nil,nil,nil,nil,nil
	ClearTimecycleModifier()
	ClearPedSecondaryTask(PlayerPedId())
	LastCameraSig = nil
	TriggerEvent("hud:Active",true)
	SendNUIMessage({ action = "camera", payload = { open = false } })
end

local function CycleAspect()
	local Index = 1
	for I,Aspect in ipairs(CameraAspects) do
		if Aspect == (Cam.aspect or "16:9") then
			Index = (I % #CameraAspects) + 1
			break
		end
	end
	Cam.aspect = CameraAspects[Index]
end

local function StartCamera(Mode)
	DestroyCamera()

	Cam.active = true
	Cam.mode = Mode or "selfie"
	Cam.fov = 55.0
	Cam.pitch = -4.0
	Cam.yaw = 0.0
	Cam.roll = 0.0
	Cam.sway = true
	Cam.faceTrack = true
	Cam.grid = true
	Cam.cleanCapture = false
	Cam.dof = false
	Cam.light = false
	Cam.aspect = Cam.aspect or "16:9"
	Cam.activeKeys = {}
	Cam.freePitch,Cam.freeYaw,Cam.freeBasePitch,Cam.freeBaseYaw = nil,nil,nil,nil

	Cam.cam = CreateCam("DEFAULT_SCRIPTED_CAMERA",true)
	SetCamActive(Cam.cam,true)
	SetCamFov(Cam.cam,Cam.fov)
	SetCamUseShallowDofMode(Cam.cam,true)
	SetCamNearDof(Cam.cam,0.55)
	SetCamFarDof(Cam.cam,7.0)
	SetCamDofStrength(Cam.cam,0.0)
	RenderScriptCams(true,true,350,true,true)
	SetTimecycleModifier("scanline_cam_cheap")
	SetTimecycleModifierStrength(0.18)

	if Cam.mode == "selfie" then PlayCameraHoldAnim() end

	TriggerEvent("hud:Active",false)

	LastCameraSig = nil
	local Payload = CameraPayload()
	Payload.open = true
	SendNUIMessage({ action = "camera", payload = Payload })

	CreateThread(function()
		while Cam.active do
			Wait(0)
			local Ped = PlayerPedId()

			DisableControlAction(0,37,true)
			DisableControlAction(0,199,true)
			DisableControlAction(0,200,true)
			DisableControlAction(0,241,true)
			DisableControlAction(0,242,true)
			DisableControlAction(0,44,true)
			DisableControlAction(0,38,true)
			DisableControlAction(0,23,true)
			DisableControlAction(0,74,true)
			DisableControlAction(0,26,true)
			DisableControlAction(0,0,true)
			DisableControlAction(0,244,true)
			DisableControlAction(0,45,true)
			DisableControlAction(0,311,true)
			DisableControlAction(0,191,true)

			local LookX = GetDisabledControlNormal(0,1)
			local LookY = GetDisabledControlNormal(0,2)

			local Keys = {
				tab = IsDisabledControlPressed(0,37),
				enter = IsDisabledControlPressed(0,191),
				flash = Cam.light == true,
				dof = Cam.dof == true,
				rotate = IsDisabledControlPressed(0,44) or IsDisabledControlPressed(0,38),
				aspect = IsDisabledControlPressed(0,26),
				grid = Cam.grid == true,
				cleanCapture = Cam.cleanCapture == true,
				faceTrack = Cam.faceTrack == true,
				zoom = IsDisabledControlPressed(0,241) or IsDisabledControlPressed(0,242),
				exit = IsDisabledControlPressed(0,311),
			}

			if Cam.mode == "normal" then
				Cam.yaw = math.max(155.0,math.min(205.0,Cam.yaw - (LookX * 4.5)))
				Cam.pitch = math.max(-22.0,math.min(18.0,Cam.pitch - (LookY * 4.5)))
			elseif Cam.faceTrack == false then
				Cam.freeBaseYaw = Cam.freeBaseYaw or (Cam.freeYaw or Cam.smoothYaw or 0.0)
				Cam.freeBasePitch = Cam.freeBasePitch or (Cam.freePitch or Cam.smoothPitch or -4.0)
				Cam.freeYaw = (Cam.freeYaw or Cam.freeBaseYaw) - (LookX * 4.5)
				Cam.freePitch = (Cam.freePitch or Cam.freeBasePitch) - (LookY * 4.5)
				local YawDelta = math.max(-38.0,math.min(38.0,WrapAngle(Cam.freeYaw - Cam.freeBaseYaw)))
				Cam.freeYaw = Cam.freeBaseYaw + YawDelta
				Cam.freePitch = math.max(Cam.freeBasePitch - 26.0,math.min(Cam.freeBasePitch + 24.0,Cam.freePitch))
			end

			if IsDisabledControlPressed(0,241) then Cam.fov = math.max(28.0,Cam.fov - 1.0) end
			if IsDisabledControlPressed(0,242) then Cam.fov = math.min(85.0,Cam.fov + 1.0) end
			if IsDisabledControlPressed(0,44) then Cam.roll = math.max(-90.0,Cam.roll - 1.2) end
			if IsDisabledControlPressed(0,38) then Cam.roll = math.min(90.0,Cam.roll + 1.2) end

			if IsDisabledControlJustPressed(0,37) then
				if Cam.mode == "selfie" then
					Cam.mode = "normal"
					Cam.yaw,Cam.pitch,Cam.roll = 180.0,-4.0,0.0
				else
					Cam.mode = "selfie"
					Cam.yaw,Cam.pitch,Cam.roll = 0.0,-4.0,0.0
					PlayCameraHoldAnim()
				end
				Cam.freePitch,Cam.freeYaw,Cam.freeBasePitch,Cam.freeBaseYaw = nil,nil,nil,nil
			end

			if IsDisabledControlJustPressed(0,23) then Cam.light = not Cam.light end

			if IsDisabledControlJustPressed(0,74) then
				Cam.dof = not Cam.dof
				SetCamUseShallowDofMode(Cam.cam,Cam.dof)
				SetCamDofStrength(Cam.cam,Cam.dof and Cam.dofStrength or 0.0)
			end

			if IsDisabledControlJustPressed(0,26) then CycleAspect() end
			if IsDisabledControlJustPressed(0,0) then Cam.grid = not Cam.grid end

			if IsDisabledControlJustPressed(0,244) then
				Cam.faceTrack = not Cam.faceTrack
				if Cam.faceTrack then
					Cam.freePitch,Cam.freeYaw,Cam.freeBasePitch,Cam.freeBaseYaw = nil,nil,nil,nil
					Cam.pitch,Cam.yaw = -4.0,0.0
				else
					Cam.freePitch = Cam.smoothPitch or Cam.pitch
					Cam.freeYaw = Cam.smoothYaw or Cam.yaw
					Cam.freeBasePitch,Cam.freeBaseYaw = Cam.freePitch,Cam.freeYaw
				end
			end

			if IsDisabledControlJustPressed(0,45) then
				Cam.pitch,Cam.roll,Cam.fov = -4.0,0.0,55.0
				Cam.yaw = (Cam.mode == "normal") and 180.0 or 0.0
			end

			if IsDisabledControlJustPressed(0,191) then Cam.cleanCapture = not Cam.cleanCapture end

			if IsControlJustPressed(0,177) or IsControlJustPressed(0,202) or IsDisabledControlJustPressed(0,311) then
				ClearPedTasks(Ped)
				DestroyCamera()
				break
			end

			if Cam.mode == "selfie" then KeepCameraHoldAnim() end

			local Heading = GetEntityHeading(Ped)
			local Timer = GetGameTimer() / 1000.0
			local SwayPitch,SwayYaw,SwayRoll = 0.0,0.0,0.0
			if Cam.sway then
				SwayPitch = math.sin(Timer * 1.55) * 0.28
				SwayYaw = math.cos(Timer * 1.22) * 0.22
				SwayRoll = math.sin(Timer * 1.85) * 0.16
			end

			local TargetPos,TargetPitch,TargetYaw
			local TargetRoll = Cam.roll + SwayRoll

			if Cam.mode == "selfie" then
				TargetPos = GetPedBoneCoords(Ped,57005,Cam.offsetX,Cam.offsetY,Cam.offsetZ)
				SetIkTarget(Ped,1,Ped,GetPedBoneIndex(Ped,57005),TargetPos.x,TargetPos.y,TargetPos.z,0,0,0)

				local HeadTarget = GetPedBoneCoords(Ped,31086,0.0,0.02,0.025)
				local BaseRot = DirectionToRotation(HeadTarget - TargetPos)

				if Cam.faceTrack then
					TargetPitch = math.max(-72.0,math.min(72.0,BaseRot.x + Cam.pitch + SwayPitch))
					TargetYaw = BaseRot.z + Cam.yaw + SwayYaw
				else
					Cam.freePitch = Cam.freePitch or (BaseRot.x + Cam.pitch)
					Cam.freeYaw = Cam.freeYaw or (BaseRot.z + Cam.yaw)
					TargetPitch = math.max(-72.0,math.min(72.0,Cam.freePitch + SwayPitch))
					TargetYaw = Cam.freeYaw + SwayYaw
				end
			else
				TargetPos = GetPedBoneCoords(Ped,31086,0.0,0.10,0.04)
				TargetPitch = Cam.pitch + SwayPitch
				TargetYaw = Heading + Cam.yaw + SwayYaw
			end

			Cam.smoothCoord = LerpVec(Cam.smoothCoord,TargetPos,0.42)
			Cam.smoothPitch = Cam.smoothPitch and LerpScalar(Cam.smoothPitch,TargetPitch,0.28) or TargetPitch
			Cam.smoothYaw = Cam.smoothYaw and LerpAngle(Cam.smoothYaw,TargetYaw,0.28) or TargetYaw
			Cam.smoothRoll = Cam.smoothRoll and LerpScalar(Cam.smoothRoll,TargetRoll,0.24) or TargetRoll
			Cam.smoothFov = Cam.smoothFov and LerpScalar(Cam.smoothFov,Cam.fov,0.18) or Cam.fov

			SetCamCoord(Cam.cam,Cam.smoothCoord.x,Cam.smoothCoord.y,Cam.smoothCoord.z)
			SetCamRot(Cam.cam,Cam.smoothPitch,Cam.smoothRoll,Cam.smoothYaw,2)
			SetCamFov(Cam.cam,Cam.smoothFov)

			if Cam.light then
				local Dir = RotationToDirection(vector3(Cam.smoothPitch,Cam.smoothRoll,Cam.smoothYaw))
				DrawSpotLight(Cam.smoothCoord.x,Cam.smoothCoord.y,Cam.smoothCoord.z,Dir.x,Dir.y,Dir.z,255,245,225,7.5,1.25,0.0,18.0,0.8)
			end

			Cam.activeKeys = Keys
			SendCameraState()
		end
	end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UI
-----------------------------------------------------------------------------------------------------------------------------------------
local function OpenUI()
	UIOpen = true
	SetNuiFocus(true,true)

	SendNUIMessage({ action = "setData", payload = {
		order = CatalogPayload.order,
		groups = CatalogPayload.groups,
		muted = Muted,
		colors = ResolveColors(),
		group = {
			owner = Group.owner,
			members = Group.members or {},
			enabled = Group.enabled == true,
			isOwner = Group.isOwner == true,
		},
	} })
end

local function CloseUI()
	UIOpen = false
	SetNuiFocus(false,false)
	SendNUIMessage({ action = "setVisible", payload = false })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI CALLBACKS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("get:colors",function(_,cb)
	cb(ResolveColors())
end)

RegisterNUICallback("close",function(_,cb)
	UIOpen = false
	SetNuiFocus(false,false)
	cb(true)
end)

RegisterNUICallback("play",function(Data,cb)
	local Command = Data and Data.command
	if Command and Command ~= "" then PlayEmote(Command) end
	cb(true)
end)

RegisterNUICallback("toggleMute",function(_,cb)
	SetMuted(not Muted)
	cb(true)
end)

RegisterNUICallback("openCamera",function(_,cb)
	CloseUI()
	StartCamera("selfie")
	cb(true)
end)

RegisterNUICallback("groupInvite",function(Data,cb)
	local Sid = tonumber(Data and Data.sid)
	if Sid and Sid > 0 then TriggerServerEvent("core-influencers:GroupInvite",Sid) end
	cb(true)
end)

RegisterNUICallback("groupRemove",function(Data,cb)
	local Sid = tonumber(Data and Data.sid)
	if Sid and Sid > 0 then TriggerServerEvent("core-influencers:GroupRemove",Sid) end
	cb(true)
end)

RegisterNUICallback("groupLeave",function(_,cb)
	TriggerServerEvent("core-influencers:GroupLeave")
	cb(true)
end)

RegisterNUICallback("groupToggle",function(Data,cb)
	if Group.isOwner then
		Group.enabled = Data and Data.enabled == true
		TriggerServerEvent("core-influencers:GroupToggle",Group.enabled)
		RefreshGroupUI()
	end
	cb(true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMMANDS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand(Influencers.Command,function()
	if Cam.active then return end
	if UIOpen then
		CloseUI()
		return
	end
	if vSERVER.CheckPermission() then
		OpenUI()
	else
		Functions.Notify(nil,"Influencers",Influencers.Language.NoPermission,"negado",5000)
	end
end,false)

RegisterCommand(Influencers.CancelCommand,function()
	StopEmote(true)
end,false)

CreateThread(function()
	while true do
		if HasActiveEmote() then
			Wait(0)
			if IsControlJustPressed(0,167) and GetEntityHealth(PlayerPedId()) > 101 then
				StopEmote(true)
			end
		else
			Wait(500)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GROUP EVENTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-influencers:GroupState",function(Data)
	Group.owner = Data and Data.owner or nil
	Group.members = Data and Data.members or {}
	Group.isOwner = Data and Data.isOwner == true or false
	Group.enabled = (Data and Data.enabled == true) and (#(Group.members or {}) > 1)
	RefreshGroupUI()
end)

RegisterNetEvent("core-influencers:GroupJoined",function(OwnerName)
	Functions.Notify(nil,"Influencers",(Influencers.Language.GroupJoined):format(OwnerName or "líder"),"verde",5000)
end)

RegisterNetEvent("core-influencers:GroupRemoved",function()
	Functions.Notify(nil,"Influencers",Influencers.Language.GroupRemoved,"aviso",5000)
	Group = { owner = nil, members = {}, enabled = false, isOwner = false }
	RefreshGroupUI()
end)

RegisterNetEvent("core-influencers:GroupClosed",function()
	Functions.Notify(nil,"Influencers",Influencers.Language.GroupClosed,"aviso",5000)
	Group = { owner = nil, members = {}, enabled = false, isOwner = false }
	RefreshGroupUI()
end)

RegisterNetEvent("core-influencers:GroupPlay",function(Command,NetStart)
	local Emote = EmotesByCmd[Command]
	if not Emote or Emote.Synchronized then return end

	StopEmote(false)
	local Ped = PlayerPedId()
	if Emote.Options and Emote.Options.Props then SpawnProps(Ped,Emote.Options.Props,Command) end
	WaitNetStart(NetStart)
	PlayEmoteOnPed(Ped,Emote)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYNC EVENTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-influencers:ForceCancel",function()
	StopEmote(false)
end)

RegisterNetEvent("core-influencers:SyncRequest",function(FromSid)
	if not Influencers.SyncAutoAccept then return end
	TriggerServerEvent("core-influencers:SyncAccept",FromSid)
end)

RegisterNetEvent("core-influencers:SyncDenied",function(TargetSid)
	if PendingSync and tonumber(PendingSync.targetSid) == tonumber(TargetSid) then
		PendingSync = nil
		Functions.Notify(nil,"Influencers",Influencers.Language.SyncDenied,"negado",5000)
	end
end)

RegisterNetEvent("core-influencers:SyncAccepted",function(TargetSid)
	if not PendingSync or tonumber(PendingSync.targetSid) ~= tonumber(TargetSid) then return end

	local Data = PendingSync
	PendingSync = nil

	local Emote = EmotesByCmd[Data.cmd]
	local MyPed = PlayerPedId()
	local TargetPed = PedFromServerId(tonumber(TargetSid))
	if not Emote or not TargetPed then
		Functions.Notify(nil,"Influencers",Influencers.Language.SyncTargetNotFound,"negado",5000)
		return
	end
	if #(GetEntityCoords(MyPed) - GetEntityCoords(TargetPed)) > 6.0 then
		Functions.Notify(nil,"Influencers",Influencers.Language.SyncTooFar,"negado",5000)
		return
	end

	StopEmote(true)
	ActivePartner = tonumber(TargetSid)

	if Emote.Options and Emote.Options.Props then SpawnProps(MyPed,Emote.Options.Props,Data.cmd) end

	local Shared = Emote.Options and Emote.Options.Shared or {}
	local NetStart = GetNetworkTime() + 650
	local SyncId = ("%s:%s:%s"):format(GetPlayerServerId(PlayerId()),Data.cmd,NetStart)
	CurrentSyncId = SyncId

	ApplySenderSync(MyPed,TargetPed,Shared)
	WaitNetStart(NetStart)
	PlayEmoteOnPed(MyPed,Emote)
	PlayEmoteSound(Emote)

	TriggerServerEvent("core-influencers:SyncToTarget",tonumber(TargetSid),GetPlayerServerId(PlayerId()),
		Data.otherCmd,Data.attach == true,NetStart,SyncId)
end)

RegisterNetEvent("core-influencers:PlayOther",function(FromSid,OtherCommand,SenderAttachFlag,NetStart,SyncId)
	SyncId = tostring(SyncId or "")
	if SyncId ~= "" and LastPlayOtherSync == SyncId then return end
	LastPlayOtherSync = SyncId
	CurrentSyncId = SyncId

	StopEmote(false)
	ActivePartner = FromSid

	local MyPed = PlayerPedId()
	local SenderPed = PedFromServerId(FromSid)
	local Other = EmotesByCmd[OtherCommand]
	if not SenderPed or not Other then return end

	if Other.Options and Other.Options.Props then SpawnProps(MyPed,Other.Options.Props,OtherCommand) end

	local Shared = Other.Options and Other.Options.Shared or {}
	ApplyTargetSync(MyPed,SenderPed,Shared,SenderAttachFlag == true)
	WaitNetStart(NetStart)
	PlayEmoteOnPed(MyPed,Other)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- LIFECYCLE
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onResourceStop",function(Resource)
	if Resource ~= GetCurrentResourceName() then return end
	SetNuiFocus(false,false)
	StopEmote(false)
	DestroyCamera()
	Active3DSounds = {}
	SendNUIMessage({ action = "soundStopAll" })
end)

LoadCatalog()
