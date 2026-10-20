-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local CreateCamWithParams = CreateCamWithParams
local DestroyCam = DestroyCam
local DoScreenFadeIn = DoScreenFadeIn
local DoScreenFadeOut = DoScreenFadeOut
local DoesCamExist = DoesCamExist
local FreezeEntityPosition = FreezeEntityPosition
local GetEntityCoords = GetEntityCoords
local GetGameTimer = GetGameTimer
local GetGroundZFor_3dCoord = GetGroundZFor_3dCoord
local GetStreetNameAtCoord = GetStreetNameAtCoord
local GetStreetNameFromHashKey = GetStreetNameFromHashKey
local HasCollisionLoadedAroundEntity = HasCollisionLoadedAroundEntity
local PlayerPedId = PlayerPedId
local RegisterNetEvent = RegisterNetEvent
local RenderScriptCams = RenderScriptCams
local RequestCollisionAtCoord = RequestCollisionAtCoord
local SetCamActive = SetCamActive
local SetCamCoord = SetCamCoord
local SetCamRot = SetCamRot
local SetEntityCoords = SetEntityCoords
local SetEntityInvincible = SetEntityInvincible
local SetEntityVisible = SetEntityVisible
local Wait = Wait
local ipairs = ipairs
local pairs = pairs
local type = type
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local SpawnPoints = {}
local SpawnCam = nil
local Descending = false

local CAM_HEIGHT = 200.0
-----------------------------------------------------------------------------------------------------------------------------------------
-- STREETAT
-----------------------------------------------------------------------------------------------------------------------------------------
local function StreetAt(x, y, z)
    return GetStreetNameFromHashKey(GetStreetNameAtCoord(x, y, z))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GROUNDZ
-----------------------------------------------------------------------------------------------------------------------------------------
local function GroundZ(x, y, z)
    local _, ground = GetGroundZFor_3dCoord(x, y, z, false)
    return ground + 0.1
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDSPAWNPOINTS
-----------------------------------------------------------------------------------------------------------------------------------------
local function BuildSpawnPoints(data)
    local points = {}

    local last = data.last or {}
    points[#points + 1] = {
        x = last.x, y = last.y, z = last.z,
        name = L("spawnLastLocation"),
        text = StreetAt(last.x, last.y, last.z),
        image = Character.Images.LastLocation,
    }

    for name, coords in pairs(data.homes or {}) do
        points[#points + 1] = {
            x = coords[1], y = coords[2], z = coords[3],
            name = name,
            text = StreetAt(coords[1], coords[2], coords[3]),
            image = Character.Images.Homes,
        }
    end

    for name, coords in pairs(data.groups or {}) do
        points[#points + 1] = {
            x = coords[1], y = coords[2], z = coords[3],
            name = name,
            text = StreetAt(coords[1], coords[2], coords[3]),
            image = Character.Images.Groups,
        }
    end

    for _, entry in ipairs(Character.SpawnLocations) do
        points[#points + 1] = {
            x = entry[1], y = entry[2], z = entry[3],
            name = entry[5],
            text = entry[4],
            image = entry[6] or Character.Images.Location,
        }
    end

    for index = 1, #points do
        points[index].hash = index
    end

    return points
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CHARACTER:OPENSPAWN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-character:openSpawn", function(data)
    if type(data) ~= "table" then return end
    if InBarber or InCreator or InSelect then return end

    DoScreenFadeOut(0)

    InSpawn = true
    SpawnPoints = BuildSpawnPoints(data)

    local ped = PlayerPedId()
    local first = SpawnPoints[1]

    SetEntityVisible(ped, false, false)
    SetEntityInvincible(ped, true)

    Wait(1000)

    SpawnCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA",
        first.x, first.y, first.z + CAM_HEIGHT,
        270.0, 0.0, 0.0, 80.0, false, 0
    )

    SetCamActive(SpawnCam, true)
    RenderScriptCams(true, false, 1, true, true)

    OpenScreen("spawn", { locations = SpawnPoints })

    DoScreenFadeIn(1000)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PREVIEWLOCATION
-----------------------------------------------------------------------------------------------------------------------------------------
function PreviewLocation(index)
    local point = SpawnPoints[index]
    if not point or not DoesCamExist(SpawnCam) then return end

    Descending = false
    DoScreenFadeOut(0)
    Wait(1000)

    SetCamRot(SpawnCam, 270.0)
    SetCamActive(SpawnCam, true)
    Descending = true

    DoScreenFadeIn(1000)

    local ped = PlayerPedId()
    local z = GroundZ(point.x, point.y, point.z)

    RequestCollisionAtCoord(point.x, point.y, z)

    local timeout = GetGameTimer() + 10000

    while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < timeout do
        Wait(1)
    end

    SetEntityCoords(ped, point.x, point.y, z + 0.5, true, false, false, false)

    local coords = GetEntityCoords(ped)
    local height = coords.z + CAM_HEIGHT
    local speed = 0.7
    local pitch = 270.0

    SetCamCoord(SpawnCam, coords.x, coords.y, height)

    while height > point.z + 1.5 do
        height = height - speed
        SetCamCoord(SpawnCam, coords.x, coords.y, height)

        if height <= point.z + 35.0 and pitch < 360.0 then
            if speed - 0.0078 >= 0.05 then
                speed = speed - 0.0078
            end

            pitch = pitch + 0.75
            SetCamRot(SpawnCam, pitch)
        end

        if not Descending then break end

        Wait(0)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIRMSPAWN
-----------------------------------------------------------------------------------------------------------------------------------------
function ConfirmSpawn(index)
    local point = SpawnPoints[index]

    -- Sem isso a tela de spawn fica aberta para sempre se a interface mandar
    -- um índice que não existe.
    if not point then
        return Notify(L("spawnInvalid"), "error")
    end

    DoScreenFadeOut(0)

    Descending = false
    InSpawn = false

    CloseScreen()
    RenderScriptCams(false, false, 0, true, true)

    if DoesCamExist(SpawnCam) then
        SetCamActive(SpawnCam, false)
        DestroyCam(SpawnCam, true)
    end

    SpawnCam = nil

    local ped = PlayerPedId()

    SetEntityVisible(ped, true, false)
    FreezeEntityPosition(ped, false)
    SetEntityInvincible(ped, false)
    SetEntityCoords(ped, point.x, point.y, point.z + 0.5, true, false, false, false)

    SendServerAction("exitCreator")

    Wait(1000)
    DoScreenFadeIn(1000)

    Framework.OnSpawned()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CHARACTER:SPAWNPLAYER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-character:spawnPlayer", function(coords)
    SpawnAfterCreate(coords)
end)
