-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local InteractionIds = {}
local CreatedPeds = {}
local NUIOpen = false
local OpenedPointKey = nil

local InRoute = false
local RouteZone = nil
local RouteCoords = {}
local RouteIndex = 1
local RouteTotalPoints = 0
local RouteCollected = 0
local RouteStartTime = nil
local CollectCooldown = 0

local RouteBlip = nil
local Flare = false
local Smoke = nil
local IsPlayingAnim = false
local RouteCam = nil

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------

local function HexToRGB(hex)
    hex = hex:gsub("#", "")
    return {
        tonumber(hex:sub(1, 2), 16) or 0,
        tonumber(hex:sub(3, 4), 16) or 0,
        tonumber(hex:sub(5, 6), 16) or 0,
    }
end

local function ResolveThemeColor()
    if Theme and type(Theme.main) == "string" and Theme.main ~= "" then
        return Theme.main
    end
    return Routes.ThemeColor or "#dc1553"
end

local ThemeRGB = HexToRGB(ResolveThemeColor())

local function SendNUI(action, data)
    SendNUIMessage({ action = action, data = data })
end

local function DrawText3D(coords, text)
    local onScreen, sx, sy = GetScreenCoordFromWorldCoord(coords[1], coords[2], coords[3])
    if not onScreen then return end

    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringKeyboardDisplay(text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextColour(255, 255, 255, 200)
    SetTextCentre(true)
    EndTextCommandDisplayText(sx, sy)

    local width = (string.len(text) + 6) / 370
    DrawRect(sx, sy + 0.0125, width, 0.03, 15, 15, 15, 120)
end

local function GetCurrentTimeString()
    local h = GetClockHours()
    local m = GetClockMinutes()
    return string.format("%02d:%02d", h, m)
end

local function CreateSmokeAt(coords)
    RequestNamedPtfxAsset("core")
    while not HasNamedPtfxAssetLoaded("core") do
        Wait(1)
    end
    SetPtfxAssetNextCall("core")
    Smoke = StartParticleFxLoopedAtCoord("exp_grd_flare", coords[1], coords[2], coords[3] + 0.80, 0.0, 0.0, 0.0, 2.0, false, false, false, false)
    SetParticleFxLoopedColour(Smoke, 0.004, 0.263, 0.733, 0)
    SetParticleFxLoopedAlpha(Smoke, 100.0)
    Flare = true
end

local function StopSmoke()
    if Smoke then
        StopParticleFxLooped(Smoke)
        Smoke = nil
        Flare = false
    end
end

local function PlayCollectAnimation(zoneConfig, callback)
    if not zoneConfig.collectAnim then
        if callback then callback() end
        return
    end

    local ped = PlayerPedId()
    local animDict = zoneConfig.collectAnim.dict
    local animName = zoneConfig.collectAnim.anim
    local duration = zoneConfig.collectAnim.duration or 2000

    IsPlayingAnim = true

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
    end

    TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, duration, 1, 0, false, false, false)

    SetTimeout(duration, function()
        ClearPedTasks(ped)
        IsPlayingAnim = false
        if callback then callback() end
    end)
end

local function HideRoutePlayer()
    CreateThread(function()
        local ped = PlayerPedId()
        while RouteCam do
            SetEntityLocallyInvisible(ped)
            Wait(0)
        end
        SetEntityLocallyVisible(ped)
    end)
end

local function DeleteRouteCam()
    if RouteCam and DoesCamExist(RouteCam) then
        RenderScriptCams(false, true, 1500, true, false)
        SetCamActive(RouteCam, false)
        DestroyCam(RouteCam, false)
    end
    RouteCam = nil
end

local function CreateRouteCam(ped)
    if not ped or ped == 0 or not DoesEntityExist(ped) then return end

    while IsCamInterpolating(GetRenderingCam()) do Wait(1) end

    if RouteCam and DoesCamExist(RouteCam) then
        RenderScriptCams(false, false, 0, false, false)
        SetCamActive(RouteCam, false)
        DestroyCam(RouteCam, false)
        RouteCam = nil
    end

    local coordsCam = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.5)

    RouteCam = CreateCam("DEFAULT_SCRIPTED_CAMERA")
    SetCamCoord(RouteCam, coordsCam.x, coordsCam.y, coordsCam.z)
    SetCamRot(RouteCam, GetCamRot(RouteCam, 1))
    SetCamFov(RouteCam, 20.0)
    SetCamActive(RouteCam, true)
    PointCamAtPedBone(RouteCam, ped, 31086, 0.0, 0.0, 0.0)
    RenderScriptCams(true, true, 1500, true, true)
end

local function OpenPanel(pointKey, payload)
    if NUIOpen then return end

    OpenedPointKey = pointKey
    NUIOpen = true

    LocalPlayer.state.Hud = false
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)

    local npc = CreatedPeds[pointKey]
    if npc and DoesEntityExist(npc) then
        CreateRouteCam(npc)
        HideRoutePlayer()
    end

    SendNUI("routes:ui:open", {
        title         = payload.title,
        description   = payload.description,
        items         = payload.items,
        routeCost     = payload.routeCost,
        themeColor    = ResolveThemeColor(),
        allowedStyles = payload.allowedStyles,
    })
end

local function ClosePanel(notifyServer)
    if notifyServer and OpenedPointKey then
        TriggerServerEvent("core-routes:closePanelServer")
    end

    DeleteRouteCam()

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUI("routes:ui:visible", { visible = false })
    OpenedPointKey = nil
    NUIOpen = false
    LocalPlayer.state.Hud = true
end

local function OpenRoute(pointKey)
    if NUIOpen or InRoute then return end
    TriggerServerEvent("core-routes:requestOpen", pointKey)
end

local function CreateRouteBlip(coords)
    if RouteBlip and DoesBlipExist(RouteBlip) then
        RemoveBlip(RouteBlip)
        RouteBlip = nil
    end

    RouteBlip = AddBlipForCoord(coords[1], coords[2], coords[3])
    SetBlipSprite(RouteBlip, 12)
    SetBlipColour(RouteBlip, 38)
    SetBlipScale(RouteBlip, 0.9)
    SetBlipRoute(RouteBlip, true)
    SetBlipAsShortRange(RouteBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Coletar")
    EndTextCommandSetBlipName(RouteBlip)
end

local function RemoveRouteBlip()
    if RouteBlip and DoesBlipExist(RouteBlip) then
        RemoveBlip(RouteBlip)
        RouteBlip = nil
    end
end

local function UpdateNotification()
    SendNUI("routes:notification:show", {
        userName             = GetPlayerName(PlayerId()),
        time                 = RouteStartTime or GetCurrentTimeString(),
        collected            = RouteCollected,
        total                = RouteTotalPoints,
        themeColor           = ResolveThemeColor(),
        notificationPosition = Routes.NotificationPosition or "bottom-left",
    })
end

local function HideNotification()
    SendNUI("routes:notification:hide", {})
end

local function StartRouteExecution(zoneKey, poolName)
    local coordsPool = Routes.Coords[poolName]

    if not coordsPool or #coordsPool == 0 then
        TriggerEvent("Notify", "Rotas", "Sem coordenadas disponíveis para este estilo.", "vermelho", 5000)
        return
    end

    InRoute = true
    RouteZone = zoneKey
    RouteCollected = 0
    RouteStartTime = GetCurrentTimeString()
    CollectCooldown = 0

    RouteCoords = coordsPool
    RouteTotalPoints = #RouteCoords

    RouteIndex = 1
    CreateRouteBlip(RouteCoords[RouteIndex])
    UpdateNotification()

    TriggerEvent("Notify", "Rotas", "Rota iniciada. Siga o GPS até o ponto de coleta.", "azul", 5000)
end

local function FinishRoute()
    InRoute = false
    RouteZone = nil
    RouteCoords = {}
    RouteIndex = 1
    RouteTotalPoints = 0
    RouteCollected = 0
    RouteStartTime = nil
    CollectCooldown = 0

    RemoveRouteBlip()
    StopSmoke()
    HideNotification()
end

local function CancelRoute()
    if not InRoute then return end

    TriggerServerEvent("core-routes:cancelRoute")
    FinishRoute()

    TriggerEvent("sounds:source", "notify", 0.5)
    TriggerEvent("Notify", "Rotas", "Rota cancelada.", "vermelho", 3000)
end

local function AdvanceToNextPoint()
    RouteIndex = RouteIndex + 1

    StopSmoke()

    if RouteIndex > #RouteCoords then
        RouteIndex = 1
    end

    CreateRouteBlip(RouteCoords[RouteIndex])
    UpdateNotification()
end

local function DoCollect()
    if CollectCooldown > 0 or IsPlayingAnim then return end

    CollectCooldown = 3

    local zoneConfig = Routes.ZoneSettings[RouteZone] or Routes.ZoneSettings.terrestrial

    if zoneConfig.collectAnim then
        PlayCollectAnimation(zoneConfig, function()
            TriggerServerEvent("core-routes:collect")
        end)
    else
        TriggerServerEvent("core-routes:collect")
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    while true do
        local sleep = 999

        if InRoute and #RouteCoords >= RouteIndex then
            local ped = PlayerPedId()
            local playerCoords = GetEntityCoords(ped)
            local target = RouteCoords[RouteIndex]
            local targetVec = vector3(target[1], target[2], target[3])
            local distance = #(playerCoords - targetVec)

            local zoneConfig = Routes.ZoneSettings[RouteZone] or Routes.ZoneSettings.terrestrial

            if distance <= zoneConfig.markerDistance then
                sleep = 0

                if zoneConfig.showFlare and not Flare and distance <= zoneConfig.flareDistance then
                    CreateSmokeAt(target)
                end

                DrawMarker(
                    zoneConfig.markerType,
                    target[1], target[2], target[3] - 0.5,
                    0, 0, 0, 0, 0, 0,
                    zoneConfig.markerScale, zoneConfig.markerScale, zoneConfig.markerScale,
                    ThemeRGB[1], ThemeRGB[2], ThemeRGB[3], 150,
                    true, true, 2, false, nil, nil, false
                )

                if not zoneConfig.autoCollect then
                    local inVehicle = IsPedInAnyVehicle(ped)
                    if zoneConfig.requiresOnFoot and inVehicle then
                        DrawText3D(target, "~r~SAIA DO VEÍCULO~w~")
                    else
                        DrawText3D(target, "~g~E~w~   COLETAR")
                    end
                end

                local shouldCollect = false
                local inVehicle = IsPedInAnyVehicle(ped)

                if zoneConfig.requiresOnFoot and inVehicle then
                    shouldCollect = false
                elseif zoneConfig.autoCollect then
                    if distance <= zoneConfig.collectDistance and CollectCooldown <= 0 and not IsPlayingAnim then
                        shouldCollect = true
                    end
                else
                    if distance <= zoneConfig.collectDistance and CollectCooldown <= 0 and not IsPlayingAnim and IsControlJustPressed(1, 38) then
                        shouldCollect = true
                    end
                end

                if shouldCollect then
                    DoCollect()
                end
            end
        end

        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        if CollectCooldown > 0 then
            CollectCooldown = CollectCooldown - 1
        end
        Wait(1000)
    end
end)

CreateThread(function()
    while true do
        local sleep = 999

        if InRoute then
            sleep = 0
            if IsControlJustReleased(0, 168) then
                CancelRoute()
            end
        end

        Wait(sleep)
    end
end)

local function RemoveInteractions()
    for routeId, interactionId in pairs(InteractionIds) do
        if interactionId then
            if type(interactionId) == "string" and GetResourceState("ox_target") == "started" and exports.ox_target then
                pcall(function()
                    exports.ox_target:removeZone(interactionId)
                end)
            elseif GetResourceState("sleepless_interact") == "started" and exports.sleepless_interact then
                pcall(function()
                    exports.sleepless_interact:removeCoords(interactionId)
                end)
            end
        end

        InteractionIds[routeId] = nil
    end
end

local function RegisterSleeplessInteractions()
    local settings = Routes.Interaction.Sleepless or {}

    if GetResourceState("sleepless_interact") ~= "started" or not exports.sleepless_interact then
        return
    end

    RemoveInteractions()

    for pointKey, point in pairs(Routes.Points) do
        local coords = point.Coords
        local interactionId = exports.sleepless_interact:addCoords(vec3(coords.x, coords.y, coords.z), {
            name = "core_routes_" .. pointKey,
            label = settings.Label or "Abrir Rotas",
            icon = settings.Icon or "route",
            distance = settings.Distance or 2.0,
            onSelect = function()
                OpenRoute(pointKey)
            end,
            canInteract = function(_, distance)
                return not NUIOpen and not InRoute and distance <= (settings.InteractDistance or settings.Distance or 2.0)
            end,
        })

        InteractionIds[pointKey] = interactionId
    end
end

local function RegisterOxTargetInteractions()
    local settings = Routes.Interaction.OxTarget or {}

    if GetResourceState("ox_target") ~= "started" or not exports.ox_target then
        return
    end

    RemoveInteractions()

    for pointKey, point in pairs(Routes.Points) do
        local coords = point.Coords
        local zoneName = "core_routes_" .. pointKey

        exports.ox_target:addSphereZone({
            name = zoneName,
            coords = vec3(coords.x, coords.y, coords.z),
            radius = settings.Radius or 1.0,
            options = {
                {
                    name = zoneName,
                    label = settings.Label or "Abrir Rotas",
                    icon = settings.Icon or "fa-solid fa-route",
                    distance = settings.Distance or 2.0,
                    onSelect = function()
                        OpenRoute(pointKey)
                    end,
                    canInteract = function()
                        return not NUIOpen and not InRoute
                    end,
                },
            },
        })

        InteractionIds[pointKey] = zoneName
    end
end

local function RegisterInteractions()
    if Routes.Interaction.System == "sleepless" then
        RegisterSleeplessInteractions()
        return
    end

    if Routes.Interaction.System == "ox_target" then
        RegisterOxTargetInteractions()
        return
    end

    RemoveInteractions()
end


CreateThread(function()
    while not LocalPlayer.state.Active do
        Wait(1000)
    end

    while true do
        local ped = PlayerPedId()
        local playerCoords = GetEntityCoords(ped)

        for pointKey, point in pairs(Routes.Points) do
            if point.NPC and point.Hash then
                local coords = point.Coords
                local distance = #(playerCoords - vec3(coords.x, coords.y, coords.z))

                if distance <= 50 then
                    if not CreatedPeds[pointKey] or not DoesEntityExist(CreatedPeds[pointKey]) then
                        if CreatedPeds[pointKey] then CreatedPeds[pointKey] = nil end

                        if LoadModel(point.Hash) then
                            local npc = CreatePed(26, point.Hash, coords.x, coords.y, coords.z - 1.0, coords.w, false, false)

                            SetEntityInvincible(npc, true)
                            FreezeEntityPosition(npc, true)
                            DecorSetBool(npc, "CREATIVE_PED", true)
                            SetEntityAsMissionEntity(npc, true, true)
                            SetBlockingOfNonTemporaryEvents(npc, true)

                            CreatedPeds[pointKey] = npc

                            if point.anim and point.anim[1] and LoadAnim(point.anim[1]) then
                                TaskPlayAnim(npc, point.anim[1], point.anim[2], 8.0, 8.0, -1, 1, 0, 0, 0, 0)
                            end
                        end
                    else
                        local animDict = point.anim and point.anim[1]
                        local animName = point.anim and point.anim[2]
                        if animDict and not IsEntityPlayingAnim(CreatedPeds[pointKey], animDict, animName, 3) then
                            if LoadAnim(animDict) then
                                TaskPlayAnim(CreatedPeds[pointKey], animDict, animName, 8.0, 8.0, -1, 1, 0, 0, 0, 0)
                            end
                        end
                    end
                else
                    if CreatedPeds[pointKey] then
                        DeleteEntity(CreatedPeds[pointKey])
                        CreatedPeds[pointKey] = nil
                    end
                end
            end
        end

        Wait(1000)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local playerCoords = GetEntityCoords(ped)

        if Routes.Interaction.System == "marker" and not InRoute then
            local markerSettings = Routes.Interaction.Marker or {}

            for pointKey, point in pairs(Routes.Points) do
                local coords = point.Coords
                local distance = #(playerCoords - vec3(coords.x, coords.y, coords.z))

                if distance <= (markerSettings.DrawDistance or 12.0) then
                    sleep = 0

                    local ms = markerSettings.Scale or vec3(0.18, 0.18, 0.18)
                    DrawMarker(
                        markerSettings.Type or 2,
                        coords.x, coords.y, coords.z + (markerSettings.ZOffset or 0.15),
                        0, 0, 0, 0, 0, 0,
                        ms.x, ms.y, ms.z,
                        ThemeRGB[1], ThemeRGB[2], ThemeRGB[3], 160,
                        false, false, 2, false, nil, nil, false
                    )

                    if distance <= (markerSettings.OpenDistance or 1.5) and not NUIOpen then
                        DrawText3D(
                            { coords.x, coords.y, coords.z + (markerSettings.TextZOffset or 0.35) },
                            markerSettings.Text or "~g~E~w~  ABRIR ROTAS"
                        )

                        if IsControlJustPressed(0, markerSettings.Key or 38) then
                            OpenRoute(pointKey)
                        end
                    end
                end
            end
        end

        if NUIOpen and OpenedPointKey then
            local point = Routes.Points[OpenedPointKey]
            if point and point.Coords then
                local coords = point.Coords
                local distance = #(playerCoords - vec3(coords.x, coords.y, coords.z))

                if distance > (Routes.Interaction.AutoCloseDistance or 4.0) then
                    ClosePanel(true)
                end
            end
        end

        Wait(sleep)
    end
end)

CreateThread(function()
    while not LocalPlayer.state.Active do
        Wait(1000)
    end

    RegisterInteractions()
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTS
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent("core-routes:openPanel", function(pointKey, payload)
    OpenPanel(pointKey, payload)
end)

RegisterNetEvent("core-routes:routeStarted", function(zoneKey, poolName)
    ClosePanel(false)
    StartRouteExecution(zoneKey, poolName)
end)

RegisterNetEvent("core-routes:collectSuccess", function(collected)
    RouteCollected = collected
    UpdateNotification()

    StopSmoke()

    AdvanceToNextPoint()
end)

RegisterNetEvent("core-routes:routeFinished", function()
    FinishRoute()
    TriggerEvent("Notify", "Rotas", "Rota finalizada com sucesso!", "sucesso", 5000)
end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= GetCurrentResourceName() and resourceName ~= "sleepless_interact" and resourceName ~= "ox_target" then
        return
    end

    Wait(1500)
    RegisterInteractions()
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    ClosePanel(false)
    RemoveInteractions()

    for key, ped in pairs(CreatedPeds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
        CreatedPeds[key] = nil
    end

    if InRoute then
        FinishRoute()
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI CALLBACKS
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback("routes:start", function(data, cb)
    cb({ ok = true })

    if not OpenedPointKey then return end

    local pointKey = OpenedPointKey
    local items = data.items or {}
    local style = data.style or "terrestre"

    ClosePanel(false)
    TriggerServerEvent("core-routes:startRoute", pointKey, items, style)
end)

RegisterNUICallback("routes:close", function(_, cb)
    cb({ ok = true })
    ClosePanel(true)
end)
