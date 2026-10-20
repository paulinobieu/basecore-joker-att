-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local CreateCam = CreateCam
local CreateThread = CreateThread
local DestroyCam = DestroyCam
local DoesCamExist = DoesCamExist
local GetCamFov = GetCamFov
local GetEntityHeading = GetEntityHeading
local GetFrameTime = GetFrameTime
local GetOffsetFromEntityInWorldCoords = GetOffsetFromEntityInWorldCoords
local PlayerPedId = PlayerPedId
local PointCamAtCoord = PointCamAtCoord
local RenderScriptCams = RenderScriptCams
local SetCamActive = SetCamActive
local SetCamActiveWithInterp = SetCamActiveWithInterp
local SetCamCoord = SetCamCoord
local SetCamFov = SetCamFov
local SetEntityHeading = SetEntityHeading
local Wait = Wait
local abs = math.abs
local unpack = table.unpack
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
ShopCam = nil
CurrentPreset = 0

local TargetFov = nil
local TargetHeading = nil

local CamPoint = nil
local CamFactor = nil

local Switching = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- LERPANGLE
-----------------------------------------------------------------------------------------------------------------------------------------
local function LerpAngle(from, to, speed, delta)
    local difference = (to - from + 360) % 360

    if abs(difference) > 180 then
        difference = difference - 360
    end

    return (from + difference * speed * delta) % 360
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETHEADINGTARGET
-----------------------------------------------------------------------------------------------------------------------------------------
function SetHeadingTarget(angle)
    TargetHeading = angle
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROTATECHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
function RotateCharacter(side)
    local heading = GetEntityHeading(PlayerPedId())

    TargetHeading = heading + (side == "right" and -10.0 or 10.0)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETCAMFOVTARGET
-----------------------------------------------------------------------------------------------------------------------------------------
function SetCamFovTarget(fov)
    TargetFov = Float(fov)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATESHOPCAM
-----------------------------------------------------------------------------------------------------------------------------------------
function CreateShopCam(preset)
    if Switching then return nil end

    local params = Customization.Cameras[preset]
    if not params then return nil end

    Switching = true
    TargetFov = nil

    local ped = PlayerPedId()

    if GetEntityHeading(ped) ~= Customization.ShopHeading then
        TargetHeading = Customization.ShopHeading
        Wait(500)
    end

    local previous = ShopCam
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

    CamFactor = 0.0096667 * params.fov + 0.0166665
    CamPoint = GetOffsetFromEntityInWorldCoords(ped, CamFactor, 0.0, params.point[3])

    SetCamCoord(cam, GetOffsetFromEntityInWorldCoords(ped, unpack(params.offset)))
    PointCamAtCoord(cam, CamPoint)
    SetCamFov(cam, params.fov)

    if DoesCamExist(previous) then
        SetCamActiveWithInterp(cam, previous, 800, true, true)

        Wait(800)
        DestroyCam(previous)
    else
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, true)
    end

    ShopCam = cam
    CurrentPreset = preset
    Switching = false

    return params.fov
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DESTROYSHOPCAM
-----------------------------------------------------------------------------------------------------------------------------------------
function DestroyShopCam()
    TargetFov = nil
    TargetHeading = nil

    RenderScriptCams(false, true, 250, true, false)

    if DoesCamExist(ShopCam) then
        DestroyCam(ShopCam, false)
    end

    ShopCam = nil
    CamPoint = nil
    CamFactor = nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LERPFOV
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    while true do
        local wait = 999

        if TargetFov and DoesCamExist(ShopCam) then
            wait = 0

            local fov = LerpAngle(GetCamFov(ShopCam), TargetFov, Customization.CameraSpeed, GetFrameTime())
            SetCamFov(ShopCam, fov)

            if CamPoint then
                local factor = 0.0096667 * fov + 0.0166665
                PointCamAtCoord(ShopCam, (CamPoint[1] - CamFactor) + factor, CamPoint[2], CamPoint[3])
            end
        end

        Wait(wait)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- LERPHEADING
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    while true do
        local wait = 999

        if TargetHeading then
            wait = 0

            local ped = PlayerPedId()
            SetEntityHeading(ped, LerpAngle(GetEntityHeading(ped), TargetHeading, Customization.CameraSpeed, GetFrameTime()))
        end

        Wait(wait)
    end
end)
