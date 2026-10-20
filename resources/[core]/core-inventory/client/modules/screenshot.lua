-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Settings = Inventory.ClientItems.Camera
local FovMin = Settings.Fov.Minimum
local FovMax = Settings.Fov.Maximum
local Camera = false
local Binoculars = false
local Total = (FovMax + FovMin) * 0.5
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:CAMERA
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:Camera")
AddEventHandler("inventory:Camera",function(Action)
	if not Camera then
		Binoculars = Action
		local Ped = PlayerPedId()
		local Heading = GetEntityHeading(Ped)

		if Binoculars then
			Scaleform = RequestScaleformMovie(Settings.Scaleform)
			while not HasScaleformMovieLoaded(Scaleform) do
				Wait(1)
			end
		end

		Camera = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA",true)
		LocalPlayer["state"]:set("ItemCamera",true,true)
		AttachCamToEntity(Camera,Ped,0.0,0.0,1.0,true)
		RenderScriptCams(true,false,0,false,false)
		SetCamRot(Camera,0.0,0.0,Heading)
		TriggerEvent("hud:Active",false)
		SetCamActive(Camera,true)
		SetCamFov(Camera,Total)

		while Camera do
			Wait(1)

			local Zoom = (1.0 / (FovMax - FovMin)) * (Total - FovMin)
			CheckInputRotation(Zoom)
			HandleZoom()

			if Binoculars then
				DrawScaleformMovieFullscreen(Scaleform,255,255,255,255)
			end

			local Ped = PlayerPedId()
			if IsPedArmed(Ped,7) then
				RemoveCamera()
			end
		end
	else
		RemoveCamera()
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVECAMERA
-----------------------------------------------------------------------------------------------------------------------------------------
function RemoveCamera()
	Total = (FovMax + FovMin) * 0.5

	LocalPlayer["state"]:set("ItemCamera",false,true)

	if DoesCamExist(Camera) then
		RenderScriptCams(false,false,0,false,false)
		DestroyCam(Camera,false)
		Camera = nil
	end

	TriggerEvent("hud:Active",true)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKINPUTROTATION
-----------------------------------------------------------------------------------------------------------------------------------------
function CheckInputRotation(Zoom)
	local AxisX = GetDisabledControlNormal(0,220)
	local AxisY = GetDisabledControlNormal(0,221)
	local Rotation = GetCamRot(Camera,2)
	if AxisX ~= 0.0 or AxisY ~= 0.0 then
		local NewZ = Rotation["z"] + AxisX * -1.0 * Settings.RotationSpeed * (Zoom + 0.1)
		local NewX = math.max(math.min(Settings.Pitch.Maximum,Rotation["x"] + AxisY * -1.0 * Settings.RotationSpeed * (Zoom + 0.1)),Settings.Pitch.Minimum)
		SetCamRot(Camera,NewX,0.0,NewZ,2)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDLEZOOM
-----------------------------------------------------------------------------------------------------------------------------------------
function HandleZoom()
	if IsControlJustPressed(1,241) then
		Total = math.max(Total - Settings.Fov.Step,FovMin)
	end

	if IsControlJustPressed(1,242) then
		Total = math.min(Total + Settings.Fov.Step,FovMax)
	end

	local Current = GetCamFov(Camera)
	if math.abs(Total - Current) < 0.1 then
		Total = Current
	end

	SetCamFov(Camera,Current + (Total - Current) * Settings.Smoothing)
end
