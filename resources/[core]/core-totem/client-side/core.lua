-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local SpawnedMachines = {}
local InteractionIds  = {}
local OpenedTotemId   = nil
local NUIOpen         = false
local NAME_PREFIX     = "core_totem_"
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------

local function LoadModel(model)
    local modelHash = type(model) == "string" and GetHashKey(model) or model
    local timeout = GetGameTimer() + 5000

    if not IsModelInCdimage(modelHash) then
        return nil
    end

    RequestModel(modelHash)

    while not HasModelLoaded(modelHash) and GetGameTimer() < timeout do
        Wait(10)
    end

    if not HasModelLoaded(modelHash) then
        return nil
    end

    return modelHash
end

local function DrawText3D(x, y, z, text)
    local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(x, y, z)

    if not onScreen then
        return
    end

    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringKeyboardDisplay(text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextColour(255, 255, 255, 200)
    SetTextCentre(true)
    EndTextCommandDisplayText(screenX, screenY)

    local width = (string.len(text) + 6) / 370
    DrawRect(screenX, screenY + 0.0125, width, 0.03, 15, 15, 15, 120)
end

local function LoadAnimDict(dict)
    local timeout = GetGameTimer() + 5000
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do
        Wait(10)
    end
    return HasAnimDictLoaded(dict)
end

local function PlayTotemAnim()
    CreateThread(function()
        local dict = "amb@prop_human_atm@male@idle_a"
        local anim = "idle_a"
        if LoadAnimDict(dict) then
            TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 8.0, -1, 15, 1, false, false, false)
            RemoveAnimDict(dict)
        end
    end)
end

local function StopTotemAnim()
    ClearPedTasksImmediately(PlayerPedId())
end

local function SendInterfaceMessage(action, data)
    SendNUIMessage({
        action = action,
        data = data,
    })
end

local function OpenTotem(totemId)
    if NUIOpen then
        return
    end

    TriggerServerEvent("core-totem:requestOpen", totemId)
end

local function ClosePanel(notifyServer)
    if notifyServer then
        TriggerServerEvent("core-totem:closeTotem")
    end

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendInterfaceMessage("setVisible", false)
    StopTotemAnim()
    OpenedTotemId = nil
    NUIOpen = false
end

local function OpenPanel(totemId, configPayload)
    OpenedTotemId = totemId
    NUIOpen = true

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)

    PlayTotemAnim()
    SendInterfaceMessage("setVisible", true)
    SendInterfaceMessage("openTotem", configPayload)
end

local function RemoveInteractions()
    for totemId, interactionId in pairs(InteractionIds) do
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

        InteractionIds[totemId] = nil
    end
end

local function RegisterSleeplessInteractions()
    local settings = Totem.Interaction.Sleepless or {}

    if GetResourceState("sleepless_interact") ~= "started" or not exports.sleepless_interact then
        return
    end

    RemoveInteractions()

    for totemId, totem in pairs(Totem.Restaurants) do
        local coords = totem.Machine.Coords
        local zOffset = totem.Machine.Object and 1.0 or 0.0
        local interactionId = exports.sleepless_interact:addCoords(vec3(coords.x, coords.y, coords.z + zOffset), {
            name = NAME_PREFIX .. tostring(totemId),
            label = settings.Label or "Abrir Totem",
            icon = settings.Icon or "utensils",
            distance = settings.Distance or 2.5,
            onSelect = function()
                OpenTotem(totemId)
            end,
            canInteract = function(entity, distance)
                return not NUIOpen and distance <= (settings.InteractDistance or settings.Distance or 2.5)
            end,
        })

        InteractionIds[totemId] = interactionId
    end
end

local function RegisterOxTargetInteractions()
    local settings = Totem.Interaction.OxTarget or {}

    if GetResourceState("ox_target") ~= "started" or not exports.ox_target then
        return
    end

    RemoveInteractions()

    for totemId, totem in pairs(Totem.Restaurants) do
        local coords = totem.Machine.Coords
        local zOffset = totem.Machine.Object and 1.0 or 0.0
        local zoneName = NAME_PREFIX .. tostring(totemId)

        exports.ox_target:addSphereZone({
            name = zoneName,
            coords = vec3(coords.x, coords.y, coords.z + zOffset),
            radius = settings.Radius or 1.0,
            options = {
                {
                    name = zoneName,
                    label = settings.Label or "Abrir Totem",
                    icon = settings.Icon or "fa-solid fa-utensils",
                    distance = settings.Distance or 2.5,
                    onSelect = function()
                        OpenTotem(totemId)
                    end,
                    canInteract = function()
                        return not NUIOpen
                    end,
                },
            },
        })

        InteractionIds[totemId] = zoneName
    end
end

local function RegisterInteractions()
    if Totem.Interaction.System == "sleepless" then
        RegisterSleeplessInteractions()
        return
    end

    if Totem.Interaction.System == "ox_target" then
        RegisterOxTargetInteractions()
        return
    end

    RemoveInteractions()
end

local function SpawnConfiguredMachines()
    for totemId, entity in pairs(SpawnedMachines) do
        if entity and DoesEntityExist(entity) then
            DeleteEntity(entity)
        end

        SpawnedMachines[totemId] = nil
    end

    for totemId, totem in pairs(Totem.Restaurants) do
        local machineData = totem.Machine or {}

        if machineData.Object then
            local machineObj = Totem.MachineObject or {}
            local modelHash = LoadModel(machineData.Model or machineObj.Model or "totem")

            if modelHash then
                local coords = machineData.Coords
                local entity = CreateObjectNoOffset(modelHash, coords.x + 0.0, coords.y + 0.0, coords.z + 0.0, false, false, false)

                if entity and entity > 0 then
                    SetEntityHeading(entity, coords.w + 0.0)
                    FreezeEntityPosition(entity, machineObj.Freeze ~= false)
                    SetEntityAsMissionEntity(entity, true, true)
                    PlaceObjectOnGroundProperly(entity)
                    SpawnedMachines[totemId] = entity
                end

                SetModelAsNoLongerNeeded(modelHash)
            end
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    Wait(1000)
    SpawnConfiguredMachines()
end)

CreateThread(function()
    while not LocalPlayer.state.Active do
        Wait(1000)
    end

    RegisterInteractions()
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local playerCoords = GetEntityCoords(ped)

        if Totem.Interaction.System == "marker" then
            local markerSettings = Totem.Interaction.Marker or {}

            for totemId, totem in pairs(Totem.Restaurants) do
                local machineData = totem.Machine or {}
                local coords = machineData.Coords
                local distance = #(playerCoords - vec3(coords.x + 0.0, coords.y + 0.0, coords.z + 0.0))

                if distance <= (markerSettings.DrawDistance or 12.0) then
                    sleep = 0

                    local markerColor = markerSettings.Color or { 59, 130, 246, 160 }
                    local markerScale = markerSettings.Scale or vec3(0.18, 0.18, 0.18)
                    DrawMarker(markerSettings.Type or 2, coords.x + 0.0, coords.y + 0.0, coords.z + (markerSettings.ZOffset or 0.15), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, markerScale.x + 0.0, markerScale.y + 0.0, markerScale.z + 0.0, markerColor[1], markerColor[2], markerColor[3], markerColor[4], false, false, 2, false, nil, nil, false)

                    if distance <= (markerSettings.OpenDistance or 1.5) and not NUIOpen then
                        DrawText3D(coords.x + 0.0, coords.y + 0.0, coords.z + (markerSettings.TextZOffset or 0.35), markerSettings.Text or "~g~E~w~  ABRIR TOTEM")

                        if IsControlJustPressed(0, markerSettings.Key or 38) then
                            OpenTotem(totemId)
                        end
                    end
                end
            end
        end

        if NUIOpen and OpenedTotemId then
            local totem = Totem.Restaurants[OpenedTotemId]

            if totem and totem.Machine and totem.Machine.Coords then
                local coords = totem.Machine.Coords
                local distance = #(playerCoords - vec3(coords.x + 0.0, coords.y + 0.0, coords.z + 0.0))

                if distance > (Totem.Interaction.AutoCloseDistance or 5.0) then
                    ClosePanel(true)
                end
            end
        end

        Wait(sleep)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-totem:openPanel", function(totemId, configPayload)
    OpenPanel(totemId, configPayload)
end)

RegisterNetEvent("core-totem:nuiMessage", function(action, data)
    SendInterfaceMessage(action, data)
end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= GetCurrentResourceName() and resourceName ~= "sleepless_interact" and resourceName ~= "ox_target" then
        return
    end

    Wait(1500)
    RegisterInteractions()
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    ClosePanel(false)
    RemoveInteractions()

    for totemId, entity in pairs(SpawnedMachines) do
        if entity and DoesEntityExist(entity) then
            DeleteEntity(entity)
        end

        SpawnedMachines[totemId] = nil
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI CALLBACKS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("close", function(data, cb)
    ClosePanel(true)
    cb({ ok = true })
end)

RegisterNUICallback("confirm", function(data, cb)
    TriggerServerEvent("core-totem:handleAction", "confirm", data)
    cb({ ok = true })
end)

RegisterNUICallback("withdraw", function(data, cb)
    TriggerServerEvent("core-totem:handleAction", "withdraw", data)
    cb({ ok = true })
end)

RegisterNUICallback("setPrice", function(data, cb)
    TriggerServerEvent("core-totem:handleAction", "setPrice", data)
    cb({ ok = true })
end)

RegisterNUICallback("restock", function(data, cb)
    TriggerServerEvent("core-totem:handleAction", "restock", data)
    cb({ ok = true })
end)
