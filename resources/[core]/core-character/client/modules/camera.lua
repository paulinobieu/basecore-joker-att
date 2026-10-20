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
CreatorCam = nil

local TargetHeading = nil
local TargetFov = nil
local CurrentCam = 0
local Interpolating = false
local PointOffset = nil
local PointFactor = nil

local LERP_SPEED = 10.0
-----------------------------------------------------------------------------------------------------------------------------------------
-- CAMPRESETS
-----------------------------------------------------------------------------------------------------------------------------------------
local CamPresets = {
    [0] = { fov = 50.0, offset = { 0.15, 2.25, 0.28 }, point = -0.1 },
    [1] = { fov = 15.0, offset = { 0.15, 2.25, 0.65 }, point = 0.65 },
    [2] = { fov = 25.0, offset = { 0.15, 2.25, 0.30 }, point = 0.30 },
    [3] = { fov = 35.0, offset = { 0.15, 2.25, -0.40 }, point = -0.40 },
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- LERPANGLE
-----------------------------------------------------------------------------------------------------------------------------------------
function LerpAngle(from, to, speed, delta)
    local difference = (to - from + 360) % 360

    if abs(difference) > 180 then
        difference = difference - 360
    end

    return (from + difference * speed * delta) % 360
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATECREATORCAM
-----------------------------------------------------------------------------------------------------------------------------------------
function CreateCreatorCam(preset)
    if Interpolating then return end

    local params = CamPresets[preset]
    if not params then return end

    Interpolating = true
    TargetFov = nil

    local ped = PlayerPedId()

    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    local factor = 0.0096667 * params.fov + 0.0166665

    PointOffset = GetOffsetFromEntityInWorldCoords(ped, factor, 0.0, params.point)
    PointFactor = factor

    SetCamCoord(cam, GetOffsetFromEntityInWorldCoords(ped, unpack(params.offset)))
    PointCamAtCoord(cam, PointOffset)
    SetCamFov(cam, params.fov)

    if DoesCamExist(CreatorCam) then
        SetCamActiveWithInterp(cam, CreatorCam, 800, true, true)
        Wait(800)
        DestroyCam(CreatorCam)
    else
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, true)
    end

    CreatorCam = cam
    CurrentCam = preset
    Interpolating = false

    return params.fov
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DESTROYCREATORCAM
-----------------------------------------------------------------------------------------------------------------------------------------
function DestroyCreatorCam()
    TargetHeading = nil
    TargetFov = nil

    RenderScriptCams(false, false, 0, true, true)

    if DoesCamExist(CreatorCam) then
        DestroyCam(CreatorCam, false)
    end

    CreatorCam = nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETCAMFOVTARGET
-----------------------------------------------------------------------------------------------------------------------------------------
function SetCamFovTarget(value)
    TargetFov = Float(value)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETHEADINGTARGET
-----------------------------------------------------------------------------------------------------------------------------------------
function SetHeadingTarget(value)
    TargetHeading = Float(value)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROTATECHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
function RotateCharacter(side)
    local heading = GetEntityHeading(PlayerPedId())
    TargetHeading = heading + (side == "right" and -10 or 10)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREAD LERP
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    while true do
        local sleep = 999

        if TargetHeading ~= nil then
            sleep = 0

            local ped = PlayerPedId()
            local heading = LerpAngle(GetEntityHeading(ped), TargetHeading, LERP_SPEED, GetFrameTime())
            SetEntityHeading(ped, heading)
        end

        if TargetFov ~= nil and DoesCamExist(CreatorCam) then
            sleep = 0

            local fov = LerpAngle(GetCamFov(CreatorCam), TargetFov, LERP_SPEED, GetFrameTime())
            SetCamFov(CreatorCam, fov)

            if PointOffset then
                local factor = 0.0096667 * fov + 0.0166665
                PointCamAtCoord(CreatorCam, (PointOffset[1] - PointFactor) + factor, PointOffset[2], PointOffset[3])
            end
        end

        Wait(sleep)
    end
end)
