-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local SpawnedMachines = {}
local OpenedMachineId = nil
local NUIOpen = false
local AdminNUIOpen = false
local IsPlacing = false
local MachineCam = nil

local Props = {
    off = "bkr_prop_prtmachine_dryer",
    on = "bkr_prop_prtmachine_dryer_spin",
    starting = "bkr_prop_prtmachine_dryer_op",
}

local MachineStates = {}
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

local function SendInterfaceMessage(action, data)
    SendNUIMessage({
        action = action,
        payload = data
    })
end

local function OpenMachine(machineId)
    if NUIOpen then
        return
    end

    TriggerServerEvent("core-laundry:requestOpen", machineId)
end

local function HideMachinePlayer()
    CreateThread(function()
        local ped = PlayerPedId()
        while MachineCam do
            SetEntityLocallyInvisible(ped)
            Wait(0)
        end
        SetEntityLocallyVisible(ped)
    end)
end

local function DeleteMachineCam()
    if MachineCam and DoesCamExist(MachineCam) then
        RenderScriptCams(false, true, 1500, true, false)
        SetCamActive(MachineCam, false)
        DestroyCam(MachineCam, false)
    end
    MachineCam = nil
end

local function CreateMachineCam(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return end

    while IsCamInterpolating(GetRenderingCam()) do Wait(1) end

    if MachineCam and DoesCamExist(MachineCam) then
        RenderScriptCams(false, false, 0, false, false)
        SetCamActive(MachineCam, false)
        DestroyCam(MachineCam, false)
        MachineCam = nil
    end

    local coordsCam = GetOffsetFromEntityInWorldCoords(entity, 0.0, -2.2, 1.5)

    MachineCam = CreateCam("DEFAULT_SCRIPTED_CAMERA")
    SetCamCoord(MachineCam, coordsCam.x, coordsCam.y, coordsCam.z)
    SetCamRot(MachineCam, GetCamRot(MachineCam, 1))
    SetCamFov(MachineCam, 46.0)
    SetCamActive(MachineCam, true)
    PointCamAtEntity(MachineCam, entity, 0.0, 0.0, 1.0, true)
    RenderScriptCams(true, true, 1500, true, true)
end

local function ClosePanel(notifyServer)
    if notifyServer then
        TriggerServerEvent("core-laundry:closeMachine")
    end

    DeleteMachineCam()

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendInterfaceMessage("setVisible", false)
    OpenedMachineId = nil
    NUIOpen = false

    TriggerEvent("hud:Active", true)
end

LaundryBridge = {
    Open = function(machineId) OpenMachine(machineId) end,
    Close = function(notify) ClosePanel(notify) end,
    IsOpen = function() return NUIOpen end,
    OpenedId = function() return OpenedMachineId end,
}

local function OpenPanel(machineId, configPayload, statusPayload)
    OpenedMachineId = machineId
    NUIOpen = true

    TriggerEvent("hud:Active", false)

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)

    local machineEntity = SpawnedMachines[machineId]
    if machineEntity and DoesEntityExist(machineEntity) then
        CreateMachineCam(machineEntity)
        HideMachinePlayer()
    end

    configPayload.initialStatus = statusPayload
    configPayload.logoUrl = Laundry.Logo or ""
    SendInterfaceMessage("openLaundry", configPayload)

    if statusPayload and statusPayload.isDone then
        SendInterfaceMessage("washDone")
    end
end

local function SpawnConfiguredMachines()
    for machineId, entity in pairs(SpawnedMachines) do
        if entity and DoesEntityExist(entity) then
            DeleteEntity(entity)
        end

        SpawnedMachines[machineId] = nil
    end

    for machineId, laundry in pairs(Laundry.Laundries) do
        local machineData = laundry.Machine or {}

        if machineData.Object then
            local model = Props[MachineStates[machineId] or "off"] or Props.off
            local modelHash = LoadModel(model)

            if modelHash then
                local coords = machineData.Coords
                local entity = CreateObjectNoOffset(modelHash, coords.x + 0.0, coords.y + 0.0, coords.z + 0.0, false, false, false)

                if entity and entity > 0 then
                    SetEntityHeading(entity, coords.w + 0.0)
                    FreezeEntityPosition(entity, true)
                    SetEntityAsMissionEntity(entity, true, true)
                    PlaceObjectOnGroundProperly(entity)
                    SpawnedMachines[machineId] = entity
                end

                SetModelAsNoLongerNeeded(modelHash)
            end
        end
    end
end

local function SwapMachineProp(machineId, state)
    MachineStates[machineId] = state

    local laundry = Laundry.Laundries[machineId]
    if not laundry or not laundry.Machine or not laundry.Machine.Object then return end

    local entity = SpawnedMachines[machineId]
    if not entity or not DoesEntityExist(entity) then return end

    local coords = laundry.Machine.Coords
    local modelHash = LoadModel(Props[state] or Props.off)
    if not modelHash then return end

    DeleteEntity(entity)

    local newEntity = CreateObjectNoOffset(modelHash, coords.x + 0.0, coords.y + 0.0, coords.z + 0.0, false, false, false)
    if newEntity and newEntity > 0 then
        SetEntityHeading(newEntity, coords.w + 0.0)
        FreezeEntityPosition(newEntity, true)
        SetEntityAsMissionEntity(newEntity, true, true)
        PlaceObjectOnGroundProperly(newEntity)
        SpawnedMachines[machineId] = newEntity
    end

    SetModelAsNoLongerNeeded(modelHash)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    while not LocalPlayer.state.Active do
        Wait(1000)
    end

    TriggerServerEvent("core-laundry:requestLaundries")
end)

local function PlayWashAnim(duration)
    CreateThread(function()
        local ped = PlayerPedId()
        local dict = "amb@prop_human_parking_meter@female@idle_a"
        local anim = "idle_a_female"

        RequestAnimDict(dict)
        local timeout = GetGameTimer() + 2000
        while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do
            Wait(10)
        end

        if not HasAnimDictLoaded(dict) then return end

        TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 1, 0.0, false, false, false)
        Wait(duration or 4000)
        ClearPedTasks(ped)
        RemoveAnimDict(dict)
    end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-laundry:openPanel", function(machineId, configPayload, statusPayload)
    OpenPanel(machineId, configPayload, statusPayload)
end)

RegisterNetEvent("core-laundry:nuiMessage", function(action, data)
    SendInterfaceMessage(action, data)
end)

RegisterNetEvent("core-laundry:syncLaundries", function(laundries)
    Laundry.Laundries = laundries or {}
    SpawnConfiguredMachines()
    RegisterInteractions()
end)

RegisterNetEvent("core-laundry:machineProp", function(machineId, state)
    SwapMachineProp(machineId, state)
end)

RegisterNetEvent("core-laundry:playWashAnim", function(duration)
    PlayWashAnim(duration)
end)

RegisterNetEvent("core-laundry:notify", function(style, content, time)
    local map = {
        verde = "success", sucesso = "success", success = "success",
        vermelho = "error", negado = "error", error = "error",
        amarelo = "warn", aviso = "warn", warn = "warn",
        azul = "info", info = "info",
    }

    SendInterfaceMessage("sendNotify", {
        type = map[style] or "warn",
        desc = content,
        time = time or 5000,
    })
end)

RegisterNetEvent("core-laundry:openAdminPanel", function(machines, settings)
    AdminNUIOpen = true
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    SendInterfaceMessage("openAdmin", { machines = machines, settings = settings, logoUrl = Laundry.Logo or "" })
end)

RegisterNetEvent("core-laundry:openAdminRestore", function()
    if AdminNUIOpen then
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(false)
        SendInterfaceMessage("showPlacement", {})
    end
end)

RegisterNetEvent("core-laundry:teleport", function(x, y, z, h)
    local ped = PlayerPedId()
    SetEntityCoords(ped, x + 0.0, y + 0.0, z + 0.0, false, false, false, false)
    SetEntityHeading(ped, h + 0.0)
end)

RegisterNetEvent("core-laundry:startPlacement", function(spawnObject)
    if IsPlacing then return end
    IsPlacing = true

    SetNuiFocus(false, false)
    SendInterfaceMessage("hidePlacement", {})

    CreateThread(function()
        local confirmed, coords

        if spawnObject == false then
            confirmed, coords = CoordinatePlacement()
        else
            confirmed, coords = ObjectPlacement(Props.off)
        end

        IsPlacing = false
        TriggerServerEvent("core-laundry:placementResult", confirmed, coords)
    end)
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

    for machineId, entity in pairs(SpawnedMachines) do
        if entity and DoesEntityExist(entity) then
            DeleteEntity(entity)
        end

        SpawnedMachines[machineId] = nil
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI CALLBACKS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("core-laundry", function(data, cb)
    local action = data.action

    if action == "close" then
        if AdminNUIOpen then
            AdminNUIOpen = false
            SetNuiFocus(false, false)
            SendInterfaceMessage("setVisible", false)
            cb({ ok = true })
            return
        end
        ClosePanel(true)
        cb({ ok = true })
        return
    end

    local AdminActions = {
        getLocation = true,
        createMachine = true,
        editMachine = true,
        deleteMachine = true,
        saveSettings = true,
        teleportToMachine = true,
        refreshMachines = true,
        openAdmin = true,
    }

    if AdminActions[action] then
        TriggerServerEvent("core-laundry:handleAdminAction", action, data)
        cb({ ok = true })
        return
    end

    if action == "startWash" then
        TriggerServerEvent("core-laundry:handleAction", action, data)
        ClosePanel(true)
        cb({ ok = true })
        return
    end

    TriggerServerEvent("core-laundry:handleAction", action, data)
    cb({ ok = true })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- STANDALONE OBJECT PLACEMENT
-----------------------------------------------------------------------------------------------------------------------------------------
local function RoundCoord(n)
    return math.ceil(n * 100) / 100
end

local function GetCameraForward(distance, camCoords)
    local rotation = GetGameplayCamRot(0)
    local pitch = math.rad(rotation.x)
    local yaw = math.rad(rotation.z)

    local dir = vec3(
        -math.sin(yaw) * math.abs(math.cos(pitch)),
        math.cos(yaw) * math.abs(math.cos(pitch)),
        math.sin(pitch)
    )

    return vec3(
        camCoords.x + dir.x * distance,
        camCoords.y + dir.y * distance,
        camCoords.z + dir.z * distance
    )
end

local function PlacementDrawOutline(obj)
    local pos = GetEntityCoords(obj)
    local ox = GetOffsetFromEntityInWorldCoords(obj, 2.0, 0.0, 0.0)
    local oy = GetOffsetFromEntityInWorldCoords(obj, 0.0, 2.0, 0.0)
    local oz = GetOffsetFromEntityInWorldCoords(obj, 0.0, 0.0, 2.0)

    DrawLine(pos.x - ox.x, pos.y, pos.z, pos.x + ox.x, pos.y, pos.z, 255, 0, 0, 255)
    DrawLine(pos.x, pos.y - oy.y, pos.z, pos.x, pos.y + oy.y, pos.z, 0, 0, 255, 255)
    DrawLine(pos.x, pos.y, pos.z - oz.z, pos.x, pos.y, pos.z + oz.z, 0, 255, 0, 255)
end

local function PlacementMoveObject(obj)
    local step = 0.005

    if IsDisabledControlPressed(1, 172) then
        local off = GetOffsetFromEntityInWorldCoords(obj, step, 0.0, 0.0)
        SetEntityCoordsNoOffset(obj, off.x, off.y, off.z, false, false, false)
    elseif IsDisabledControlPressed(1, 173) then
        local off = GetOffsetFromEntityInWorldCoords(obj, -step, 0.0, 0.0)
        SetEntityCoordsNoOffset(obj, off.x, off.y, off.z, false, false, false)
    end

    if IsDisabledControlPressed(1, 174) then
        local off = GetOffsetFromEntityInWorldCoords(obj, 0.0, -step, 0.0)
        SetEntityCoordsNoOffset(obj, off.x, off.y, off.z, false, false, false)
    elseif IsDisabledControlPressed(1, 175) then
        local off = GetOffsetFromEntityInWorldCoords(obj, 0.0, step, 0.0)
        SetEntityCoordsNoOffset(obj, off.x, off.y, off.z, false, false, false)
    end

    if IsDisabledControlPressed(1, 314) then
        local off = GetOffsetFromEntityInWorldCoords(obj, 0.0, 0.0, step)
        SetEntityCoordsNoOffset(obj, off.x, off.y, off.z, false, false, false)
    elseif IsDisabledControlPressed(1, 315) then
        local off = GetOffsetFromEntityInWorldCoords(obj, 0.0, 0.0, -step)
        SetEntityCoordsNoOffset(obj, off.x, off.y, off.z, false, false, false)
    end
end

local function DrawPlacementKey(keyText, label, posX, posY)
    local keyW = 0.018
    local keyH = 0.032
    local gap = 0.004
    local scale = 0.30

    -- Key box background
    DrawRect(posX, posY, keyW, keyH, 0, 0, 0, 180)
    -- Key box border
    DrawRect(posX, posY - keyH / 2, keyW, 0.002, 255, 255, 255, 100)
    DrawRect(posX, posY + keyH / 2, keyW, 0.002, 255, 255, 255, 100)
    DrawRect(posX - keyW / 2, posY, 0.001, keyH, 255, 255, 255, 100)
    DrawRect(posX + keyW / 2, posY, 0.001, keyH, 255, 255, 255, 100)

    -- Key letter
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(true)
    SetTextDropshadow(1, 0, 0, 0, 200)
    SetTextEntry("STRING")
    AddTextComponentString(keyText)
    DrawText(posX, posY - 0.013)

    -- Label text
    local labelX = posX + keyW / 2 + gap
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextColour(200, 200, 200, 255)
    SetTextCentre(false)
    SetTextDropshadow(1, 0, 0, 0, 200)
    SetTextEntry("STRING")
    AddTextComponentString(label)
    DrawText(labelX, posY - 0.013)
end

local function DrawPlacementButtons(buttons)
    local startX = 0.015
    local startY = 0.30
    local rowHeight = 0.038

    for i, btn in ipairs(buttons) do
        DrawPlacementKey(btn[1], btn[2], startX + 0.009, startY + (i - 1) * rowHeight)
    end
end

function ObjectPlacement(model)
    local confirmed = false
    local resultCoords = nil

    local modelHash = type(model) == "string" and GetHashKey(model) or model

    if not IsModelInCdimage(modelHash) then
        return false, nil
    end

    RequestModel(modelHash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(modelHash) and GetGameTimer() < timeout do
        Wait(10)
    end

    if not HasModelLoaded(modelHash) then
        return false, nil
    end

    local ped = PlayerPedId()
    local heading = GetEntityHeading(ped)
    local startCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, 0.0)
    local obj = CreateObjectNoOffset(modelHash, startCoords.x, startCoords.y, startCoords.z, false, false, false)

    SetEntityAlpha(obj, 200, false)
    PlaceObjectOnGroundProperly(obj)
    SetEntityCollision(obj, false, false)
    SetEntityHeading(obj, heading)

    local freeMode = false
    local running = true

    local DefaultButtons = {
        { "F", "Cancelar" },
        { "H", "Posicionar" },
        { "Q", "Rot. Esquerda" },
        { "E", "Rot. Direita" },
        { "Z", "Trocar Modo" },
    }

    local ExtendedButtons = {
        { "F", "Cancelar" },
        { "H", "Posicionar" },
        { "Q", "Rot. Esquerda" },
        { "E", "Rot. Direita" },
        { "-", "Descer" },
        { "+", "Subir" },
        { "^", "Mover Frente" },
        { "v", "Mover Tras" },
        { "<", "Mover Esquerda" },
        { ">", "Mover Direita" },
        { "Z", "Trocar Modo" },
    }

    local activeButtons = DefaultButtons

    while running do
        Wait(0)

        DrawPlacementButtons(activeButtons)

        -- Rotation: E / Q
        if IsControlPressed(0, 38) then
            SetEntityHeading(obj, GetEntityHeading(obj) + 0.25)
        elseif IsControlPressed(0, 52) then
            SetEntityHeading(obj, GetEntityHeading(obj) - 0.25)
        end

        PlacementDrawOutline(obj)

        if not freeMode then
            local cam = GetGameplayCamCoord()
            local target = GetCameraForward(10.0, cam)
            local handle = StartExpensiveSynchronousShapeTestLosProbe(cam, target, -1, ped, 4)
            local _, _, hitCoords = GetShapeTestResult(handle)
            SetEntityCoords(obj, hitCoords.x, hitCoords.y, hitCoords.z, false, false, false, false)
        else
            PlacementMoveObject(obj)
        end

        -- Z - toggle mode
        if IsControlJustPressed(0, 48) then
            freeMode = not freeMode
            activeButtons = freeMode and ExtendedButtons or DefaultButtons
        end

        -- H - confirm (74)
        if IsControlJustPressed(1, 74) then
            confirmed = true
            running = false
        end

        -- F - cancel (49)
        if IsControlJustPressed(0, 49) then
            confirmed = false
            running = false
        end
    end

    if DoesEntityExist(obj) then
        local oCoords = GetEntityCoords(obj)
        local oHeading = GetEntityHeading(obj)
        resultCoords = { RoundCoord(oCoords.x), RoundCoord(oCoords.y), RoundCoord(oCoords.z), RoundCoord(oHeading) }
        DeleteEntity(obj)
    end

    SetModelAsNoLongerNeeded(modelHash)

    if not resultCoords or (resultCoords[1] == 0.0 and resultCoords[2] == 0.0) then
        confirmed = false
    end

    return confirmed, resultCoords
end

function CoordinatePlacement()
    local confirmed = false
    local resultCoords = nil

    local Buttons = {
        { "E", "Confirmar" },
        { "Backspace", "Cancelar" },
    }

    while true do
        Wait(0)

        local ped = PlayerPedId()
        local cam = GetGameplayCamCoord()
        local target = GetCameraForward(25.0, cam)
        local handle = StartExpensiveSynchronousShapeTestLosProbe(cam, target, -1, ped, 4)
        local _, _, hitCoords = GetShapeTestResult(handle)

        DrawMarker(28, hitCoords.x, hitCoords.y, hitCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, 50, 121, 201, 175, false, false, 2, false, nil, nil, false)
        DrawPlacementButtons(Buttons)

        if IsControlJustPressed(1, 38) then
            resultCoords = { RoundCoord(hitCoords.x), RoundCoord(hitCoords.y), RoundCoord(hitCoords.z), RoundCoord(GetEntityHeading(ped)) }
            confirmed = true
            break
        end

        if IsControlJustPressed(0, 177) then
            confirmed = false
            break
        end
    end

    if not resultCoords or (resultCoords[1] == 0.0 and resultCoords[2] == 0.0) then
        confirmed = false
    end

    return confirmed, resultCoords
end
