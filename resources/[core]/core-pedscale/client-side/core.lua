-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local NUIOpen          = false
local scaleThreadActive = false
local nearbyPlayers    = {}
local debounceTimers   = {}
local currentScale     = PedScale.DefaultScale
local ScaleCam         = nil
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------

local function GetSavedScale()
    local saved = GetResourceKvpFloat("PedScale")
    if saved == 0 then
        return PedScale.DefaultScale
    end
    return saved
end

local function Debounce(key, delay, cb)
    if debounceTimers[key] then
        debounceTimers[key]:cancel()
    end

    local timer = {
        Active = true,
        cancel = function(self) self.Active = false end,
    }

    debounceTimers[key] = timer

    CreateThread(function()
        Wait(delay)
        if timer.Active then
            cb()
            debounceTimers[key] = nil
        end
    end)
end

local function Normalize(v)
    local mag = v.x * v.x + v.y * v.y + v.z * v.z
    if mag > 0 then
        return v * (1 / math.sqrt(mag))
    end
    return v
end

local function SetEntityScale(entity, scale)
    if GetEntityHealth(entity) <= 101 then
        return
    end

    local right, forward, up, pos = GetEntityMatrix(entity)
    local heightAboveGround = GetEntityHeightAboveGround(entity)
    local newZ

    if IsEntityStatic(entity) and heightAboveGround < 2 then
        newZ = pos.z - (heightAboveGround - scale)
    else
        newZ = pos.z - (GetEntityUprightValue(entity) - scale)
    end

    TaskLookAtEntity(entity, entity, 1, 2048, 3)
    SetEntityMatrix(
        entity,
        Normalize(right)   * scale,
        Normalize(forward) * scale,
        Normalize(up)      * scale,
        pos.x, pos.y, newZ
    )
end

local function ScaleThread()
    while next(nearbyPlayers) do
        local localCoords = GetEntityCoords(PlayerPedId())

        for serverId, data in pairs(nearbyPlayers) do
            local targetPed = GetPlayerPed(data.Pid)

            if not DoesEntityExist(targetPed) then
                nearbyPlayers[serverId] = nil
            else
                local dist = #(GetEntityCoords(targetPed) - localCoords)

                if dist < PedScale.SyncDistance and IsEntityOnScreen(targetPed) and not IsEntityOccluded(targetPed) then
                    SetEntityScale(targetPed, data.Scale)
                end
            end
        end

        Wait(0)
    end

    scaleThreadActive = false
end

local function SendInterfaceMessage(action, data)
    SendNUIMessage({ action = action, data = data })
end

local function OpenCamera()
    if DoesCamExist(ScaleCam) then
        return
    end

    local ped = PlayerPedId()
    local camera = PedScale.Camera

    ScaleCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

    SetCamCoord(ScaleCam, GetOffsetFromEntityInWorldCoords(ped, table.unpack(camera.Offset)))
    PointCamAtCoord(ScaleCam, GetOffsetFromEntityInWorldCoords(ped, table.unpack(camera.Point)))
    SetCamFov(ScaleCam, camera.Fov)
    SetCamActive(ScaleCam, true)

    RenderScriptCams(true, true, camera.Blend, true, true)
end

local function CloseCamera()
    if not DoesCamExist(ScaleCam) then
        return
    end

    RenderScriptCams(false, true, PedScale.Camera.Blend, true, false)
    DestroyCam(ScaleCam, false)

    ScaleCam = nil
end

local function ResolveThemeColor()
    if Theme and type(Theme.main) == "string" and Theme.main ~= "" then
        return Theme.main
    end
    return PedScale.ThemeColor or "#dc1553"
end

local function BuildOpenPayload()
    local presets = {}
    for _, p in ipairs(PedScale.Presets) do
        presets[#presets + 1] = { id = p.id, label = p.label, value = p.value }
    end

    return {
        themeColor   = ResolveThemeColor(),
        currentScale = currentScale,
        presets      = presets,
        range        = PedScale.Range,
    }
end

local function OpenPanel()
    if NUIOpen then return end

    NUIOpen = true
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)

    OpenCamera()

    SendInterfaceMessage("setVisible", true)
    SendInterfaceMessage("openPanel", BuildOpenPayload())
end

local function ClosePanel()
    NUIOpen = false
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendInterfaceMessage("setVisible", false)

    CloseCamera()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INITIALIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
currentScale = GetSavedScale()
LocalPlayer.state:set("PedScale", currentScale, true)
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMMANDS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-pedscale:toggle", function()
    if GetEntityHealth(PlayerPedId()) <= 101 then return end

    if NUIOpen then
        ClosePanel()
    else
        OpenPanel()
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI CALLBACKS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("close", function(_, cb)
    ClosePanel()
    cb({ ok = true })
end)

RegisterNUICallback("resetScale", function(_, cb)
    currentScale = PedScale.DefaultScale

    local playerId = PlayerId()
    local serverId = GetPlayerServerId(playerId)
    local ped = GetPlayerPed(playerId)

    if DoesEntityExist(ped) then
        SetEntityScale(ped, PedScale.DefaultScale)
    end

    nearbyPlayers[serverId] = nil

    LocalPlayer.state:set("PedScale", currentScale, true)
    SetResourceKvpFloat("PedScale", currentScale)

    cb({ ok = true })
end)

RegisterNUICallback("applyScale", function(data, cb)
    local newScale = tonumber(data.scale)
    if not newScale then
        cb({ ok = false })
        return
    end

    if newScale < PedScale.Range.Min then newScale = PedScale.Range.Min end
    if newScale > PedScale.Range.Max then newScale = PedScale.Range.Max end

    currentScale = newScale

    local playerId = PlayerId()
    local serverId = GetPlayerServerId(playerId)

    nearbyPlayers[serverId] = { Pid = playerId, Scale = newScale }

    if not scaleThreadActive then
        scaleThreadActive = true
        CreateThread(ScaleThread)
    end

    Debounce("PedScale", 1000, function()
        LocalPlayer.state:set("PedScale", currentScale, true)
        SetResourceKvpFloat("PedScale", currentScale)
    end)

    cb({ ok = true })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ONRESOURCESTOP
-- Sem isso, reiniciar o resource com o painel aberto deixaria o jogador preso
-- na câmera e sem controle.
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onResourceStop", function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)

    if DoesCamExist(ScaleCam) then
        RenderScriptCams(false, false, 0, true, false)
        DestroyCam(ScaleCam, false)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- STATEBAG HANDLER
-----------------------------------------------------------------------------------------------------------------------------------------
AddStateBagChangeHandler("PedScale", nil, function(bagName, _, value)
    local playerId = GetPlayerFromStateBagName(bagName)
    if playerId == 0 then return end

    local serverId = tonumber((bagName:gsub("player:", "")))

    if value and value ~= PedScale.DefaultScale then
        nearbyPlayers[serverId] = { Pid = playerId, Scale = value }

        if not scaleThreadActive then
            scaleThreadActive = true
            CreateThread(ScaleThread)
        end
    else
        nearbyPlayers[serverId] = nil
    end
end)
