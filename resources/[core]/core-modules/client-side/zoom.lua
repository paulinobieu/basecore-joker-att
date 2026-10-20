local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local ZoomCam = nil
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESET CAM
-----------------------------------------------------------------------------------------------------------------------------------------
local function ResetCam()
	if not ZoomCam then
		return
	end

	if DoesCamExist(ZoomCam) then
		if IsCamActive(ZoomCam) then
			SetCamActive(ZoomCam,false)
			RenderScriptCams(false,true,400,true,true)
		end
		DestroyCam(ZoomCam,false)
	end

	ZoomCam = nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ZOOM CAMERA
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("+general:zoomcamera",function()
	ResetCam()
	ZoomCam = CreateCam("DEFAULT_SCRIPTED_CAMERA",true)

	local CamCoord = GetGameplayCamCoord()
	local CamRot = GetGameplayCamRot(2)

	SetCamCoord(ZoomCam,CamCoord.x,CamCoord.y,CamCoord.z)
	SetCamRot(ZoomCam,CamRot.x,CamRot.y,CamRot.z,2)
	SetCamFov(ZoomCam,10.0)
	RenderScriptCams(true,true,400,true,true)

	CreateThread(function()
		while ZoomCam do
			CamCoord = GetGameplayCamCoord()
			CamRot = GetGameplayCamRot(2)
			SetCamCoord(ZoomCam,CamCoord.x,CamCoord.y,CamCoord.z)
			SetCamRot(ZoomCam,CamRot.x,CamRot.y,CamRot.z,2)
			Wait(0)
		end
	end)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ZOOM CAMERA RELEASE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("-general:zoomcamera",function()
	ResetCam()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- KEY MAPPING
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterKeyMapping("+general:zoomcamera","Zoom da câmera.","MOUSE_BUTTON","MOUSE_MIDDLE")
