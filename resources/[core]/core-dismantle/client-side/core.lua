------------------------------------------------------------------------------------------------------------------------------------------------
-- VARIÁVEIS
------------------------------------------------------------------------------------------------------------------------------------------------
local ResourceName         = GetCurrentResourceName()
local NuiFocusActive       = false
local NuiPanelOpen         = false
local CurrentDismantleId   = nil
local ActionCooldown       = false
local ShelfModelHash       = GetHashKey("prop_shelves_02")
local ShelfObjects         = {}
local AnimBlocked          = false
local RemovedBones         = {}
local BreakCooldown        = false
local PendingBone          = nil
local PendingPropData      = nil
local LocationMoverActive  = false
local PreviewShelfEntity   = nil
local NearbyVehiclesLobby  = {}
local CustomCoords         = nil
local DebugMode            = false

------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES UTILITÁRIAS
------------------------------------------------------------------------------------------------------------------------------------------------

local function IsDead()
    return (GetEntityHealth(PlayerPedId()) <= 101)
end

local function DrawText3D(x, y, z, text)
    local _, screenX, screenY = World3dToScreen2d(x, y, z)
    SetTextFont(4)
    SetTextScale(0.35, 0.35)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(screenX, screenY)
end

local function DrawText2D(text, font, x, y, scale, r, g, b, a)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextOutline()
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

local function LoadAnimDict(dict)
    if HasAnimDictLoaded(dict) then return true end
    RequestAnimDict(dict)
    local timeout = 0
    while not HasAnimDictLoaded(dict) and timeout < 5000 do
        Wait(1)
        timeout = timeout + 1
    end
    return HasAnimDictLoaded(dict)
end

local function LoadModel(model)
    if type(model) == "string" then model = GetHashKey(model) end
    if HasModelLoaded(model) then return true end
    RequestModel(model)
    local timeout = 0
    while not HasModelLoaded(model) and timeout < 5000 do
        Wait(1)
        timeout = timeout + 1
    end
    return HasModelLoaded(model)
end

local function GetNearestVehicles(maxDistance)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicles = {}

    for _, vehicle in pairs(GetGamePool("CVehicle")) do
        if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
            local vehicleCoords = GetEntityCoords(vehicle)
            local distance = #(playerCoords - vehicleCoords)
            if distance <= maxDistance then
                vehicles[vehicle] = distance
            end
        end
    end

    return vehicles
end

local function Round2(value)
    return math.floor(value * 100 + 0.5) / 100
end

local function SendUI(action, payload)
    SendNUIMessage({ action = action, payload = payload })
end

local function SetNUI(hasFocus, hasCursor)
    SetNuiFocus(hasFocus, hasCursor)
end

------------------------------------------------------------------------------------------------------------------------------------------------
-- DEFINIÇÃO DE BONES DO VEÍCULO
-- Cada bone define animações de quebra e transporte, e a função de destruição da peça.
------------------------------------------------------------------------------------------------------------------------------------------------
local VehicleBones = {
    ["door_dside_f"] = {
        anim = {
            breaking = { task = "WORLD_HUMAN_WELDING" },
            carrying = {
                dict = "anim@heists@box_carry@", anim = "idle",
                walk = true, loop = true,
                prop = "prop_car_door_01", bone = 28422, clearProps = true,
                propPlacement = { 0.0, -0.1, -0.15, 0.0, 0.0, 0.0 },
            },
        },
        broke = function(vehicle) SetVehicleDoorBroken(vehicle, 0, true) end,
    },
    ["door_dside_r"] = {
        anim = {
            breaking = { task = "WORLD_HUMAN_WELDING" },
            carrying = {
                dict = "anim@heists@box_carry@", anim = "idle",
                walk = true, loop = true,
                prop = "prop_car_door_01", bone = 28422, clearProps = true,
                propPlacement = { 0.0, -0.1, -0.15, 0.0, 0.0, 0.0 },
            },
        },
        broke = function(vehicle) SetVehicleDoorBroken(vehicle, 2, true) end,
    },
    ["door_pside_f"] = {
        anim = {
            breaking = { task = "WORLD_HUMAN_WELDING" },
            carrying = {
                dict = "anim@heists@box_carry@", anim = "idle",
                walk = true, loop = true,
                prop = "prop_car_door_01", bone = 28422, clearProps = true,
                propPlacement = { 0.0, -0.1, -0.15, 0.0, 0.0, 0.0 },
            },
        },
        broke = function(vehicle) SetVehicleDoorBroken(vehicle, 1, true) end,
    },
    ["door_pside_r"] = {
        anim = {
            breaking = { task = "WORLD_HUMAN_WELDING" },
            carrying = {
                dict = "anim@heists@box_carry@", anim = "idle",
                walk = true, loop = true,
                prop = "prop_car_door_01", bone = 28422, clearProps = true,
                propPlacement = { 0.0, -0.1, -0.15, 0.0, 0.0, 0.0 },
            },
        },
        broke = function(vehicle) SetVehicleDoorBroken(vehicle, 3, true) end,
    },
    ["wheel_lf"] = {
        anim = {
            breaking = {
                dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                anim = "machinic_loop_mechandplayer", loop = true, walk = false,
            },
            carrying = {
                dict = "anim@heists@box_carry@", anim = "idle",
                walk = true, loop = true,
                prop = "prop_wheel_tyre", bone = 28422, clearProps = true,
                propPlacement = { 0.0, -0.1, -0.15, 0.0, 0.0, 0.0 },
            },
        },
        broke = function(vehicle)
            if GetVehicleClass(vehicle) == 8 then
                BreakOffVehicleWheel(vehicle, 1, false, true, false, false)
            else
                BreakOffVehicleWheel(vehicle, 0, false, true, false, false)
            end
        end,
    },
    ["wheel_lr"] = {
        anim = {
            breaking = {
                dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                anim = "machinic_loop_mechandplayer", loop = true, walk = false,
            },
            carrying = {
                dict = "anim@heists@box_carry@", anim = "idle",
                walk = true, loop = true,
                prop = "prop_wheel_tyre", bone = 28422, clearProps = true,
                propPlacement = { 0.0, -0.1, -0.15, 0.0, 0.0, 0.0 },
            },
        },
        broke = function(vehicle)
            if GetVehicleClass(vehicle) == 8 then
                BreakOffVehicleWheel(vehicle, 0, false, true, false, false)
            else
                BreakOffVehicleWheel(vehicle, 2, false, true, false, false)
            end
        end,
    },
    ["wheel_rf"] = {
        anim = {
            breaking = {
                dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                anim = "machinic_loop_mechandplayer", loop = true, walk = false,
            },
            carrying = {
                dict = "anim@heists@box_carry@", anim = "idle",
                walk = true, loop = true,
                prop = "prop_wheel_tyre", bone = 28422, clearProps = true,
                propPlacement = { 0.0, -0.1, -0.15, 0.0, 0.0, 0.0 },
            },
        },
        broke = function(vehicle) BreakOffVehicleWheel(vehicle, 1, false, true, false, false) end,
    },
    ["wheel_rr"] = {
        anim = {
            breaking = {
                dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                anim = "machinic_loop_mechandplayer", loop = true, walk = false,
            },
            carrying = {
                dict = "anim@heists@box_carry@", anim = "idle",
                walk = true, loop = true,
                prop = "prop_wheel_tyre", bone = 28422, clearProps = true,
                propPlacement = { 0.0, -0.1, -0.15, 0.0, 0.0, 0.0 },
            },
        },
        broke = function(vehicle) BreakOffVehicleWheel(vehicle, 3, false, true, false, false) end,
    },
    ["wheel_lm1"] = {
        anim = {
            breaking = {
                dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                anim = "machinic_loop_mechandplayer", loop = true, walk = false,
            },
            carrying = {
                dict = "anim@heists@box_carry@", anim = "idle",
                walk = true, loop = true,
                prop = "prop_wheel_tyre", bone = 28422, clearProps = true,
                propPlacement = { 0.0, -0.1, -0.15, 0.0, 0.0, 0.0 },
            },
        },
        broke = function(vehicle) BreakOffVehicleWheel(vehicle, 4, false, true, false, false) end,
    },
    ["wheel_rm1"] = {
        anim = {
            breaking = {
                dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                anim = "machinic_loop_mechandplayer", loop = true, walk = false,
            },
            carrying = {
                dict = "anim@heists@box_carry@", anim = "idle",
                walk = true, loop = true,
                prop = "prop_wheel_tyre", bone = 28422, clearProps = true,
                propPlacement = { 0.0, -0.1, -0.15, 0.0, 0.0, 0.0 },
            },
        },
        broke = function(vehicle) BreakOffVehicleWheel(vehicle, 5, false, true, false, false) end,
    },
    ["engine"] = {
        anim = {
            breaking = {
                dict = "mini@repair", anim = "fixing_a_ped", walk = false, loop = true,
            },
            carrying = {
                dict = "anim@heists@box_carry@", anim = "idle",
                walk = true, loop = true,
                prop = "prop_car_battery_01", bone = 28422, clearProps = true,
                propPlacement = { 0.0, -0.1, -0.1, 0.0, 0.0, 0.0 },
            },
        },
        dist = 1.8,
    },
    ["exhaust"] = {
        anim = {
            breaking = {
                dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                anim = "machinic_loop_mechandplayer", loop = true, walk = false,
            },
            carrying = {
                dict = "anim@heists@box_carry@", anim = "idle",
                walk = true, loop = true,
                prop = "prop_car_exhaust_01", bone = 28422, clearProps = true,
                propPlacement = { -0.2, -0.15, -0.15, 0.0, 0.0, 90.0 },
            },
        },
        dist = 1.8,
    },
}

------------------------------------------------------------------------------------------------------------------------------------------------
-- COORDENADAS CUSTOMIZADAS (sync do servidor)
------------------------------------------------------------------------------------------------------------------------------------------------

local function UpdateCustomDismantleCoords()
    CustomCoords = nil
    TriggerServerEvent("core-dismantle:server:getCustomCoords")
end

RegisterNetEvent("core-dismantle:client:receiveCustomCoords", function(coords)
    if coords and type(coords) == "table" then
        for id, coordsData in pairs(coords) do
            if Dismantle.Locations[id] then
                Dismantle.Locations[id].coords = coordsData
            end
        end
        CustomCoords = coords
    end
    -- Server respondeu com nil → init ainda não terminou. Mantém CustomCoords nil pra retry.
end)

RegisterNetEvent("core-dismantle:client:updateDismantleCoords", function(id, coords)
    if id and coords and Dismantle.Locations[id] then
        Dismantle.Locations[id].coords = coords
    end
end)

CreateThread(function()
    while CustomCoords == nil do
        UpdateCustomDismantleCoords()
        Wait(2000)
    end
end)

------------------------------------------------------------------------------------------------------------------------------------------------
-- SHELF (ESTANTE) — SINCRONIZAÇÃO
------------------------------------------------------------------------------------------------------------------------------------------------

local function ShelfAttachObject(shelfEntity, partEntity, boneName)
    if not shelfEntity or not DoesEntityExist(shelfEntity) or not partEntity or not DoesEntityExist(partEntity) then
        return
    end

    local attachments = {
        ["door_dside_f"] = { -1.3, 0, 1.85, 0, 0, 90.0 },
        ["door_dside_r"] = { -1.05, 0, 1.85, 0, 0, 90.0 },
        ["door_pside_f"] = { -0.8, 0, 1.85, 0, 0, 90.0 },
        ["door_pside_r"] = { -0.55, 0, 1.85, 0, 0, 90.0 },
        ["wheel_lf"]     = { 1.2, 0.0, 0.4, 0.0, 0, 90.0 },
        ["wheel_lr"]     = { 0.9, 0.0, 0.4, 0.0, 0, 90.0 },
        ["wheel_rf"]     = { 0.6, 0.0, 0.4, 0.0, 0, 90.0 },
        ["wheel_rr"]     = { 0.3, 0.0, 0.4, 0.0, 0, 90.0 },
        ["wheel_lm1"]    = { 0.0, 0.0, 0.4, 0.0, 0, 90.0 },
        ["wheel_rm1"]    = { -0.3, 0.0, 0.4, 0.0, 0, 90.0 },
        ["engine"]       = { 0.0, 0, 1.08, 0, 0, 0.0 },
        ["exhaust"]      = { 1.3, 0, 1.85, 0, 0, 0.0 },
    }

    local offset = attachments[boneName]
    if offset then
        AttachEntityToEntity(partEntity, shelfEntity, -1, offset[1], offset[2], offset[3], offset[4], offset[5], offset[6], true, true, false, false, 1, true)
        FreezeEntityPosition(partEntity, true)
        DetachEntity(partEntity)
    end
end

local function CheckShelf(dismantleId)
    CreateThread(function()
        local shelfState = GlobalState["HD-CS"]
        local shelfEntity = false

        if shelfState and type(shelfState) == "table" then
            local shelfData = shelfState[dismantleId]
            if shelfData and shelfData[2] and shelfData[3] then
                local shelfNetId = shelfData[2]
                if NetworkDoesNetworkIdExist(shelfNetId) then
                    shelfEntity = NetworkGetEntityFromNetworkId(shelfNetId)
                    if shelfEntity and DoesEntityExist(shelfEntity) then
                        if GetEntityModel(shelfEntity) == ShelfModelHash then
                            FreezeEntityPosition(shelfEntity, true)
                            local currentHeading = GetEntityHeading(shelfEntity)
                            if currentHeading ~= shelfData[3] then
                                SetEntityHeading(shelfEntity, shelfData[3])
                            end
                        end
                    end
                end
            end
        end

        if shelfEntity then
            local objectsState = GlobalState["HD-SO-" .. dismantleId]
            if objectsState and type(objectsState) == "table" and next(objectsState) ~= nil then
                if not ShelfObjects[dismantleId] then
                    ShelfObjects[dismantleId] = {}
                end

                for boneName, objectData in pairs(objectsState) do
                    local objectNetId = objectData[2]
                    if NetworkDoesNetworkIdExist(objectNetId) then
                        local objectEntity = NetworkGetEntityFromNetworkId(objectNetId)
                        if objectEntity and DoesEntityExist(objectEntity) then
                            if not ShelfObjects[dismantleId][boneName] then
                                ShelfObjects[dismantleId][boneName] = true
                                ShelfAttachObject(shelfEntity, objectEntity, boneName)
                            end
                        end
                    end
                end
            end
        else
            ShelfObjects[dismantleId] = {}
        end
    end)
end

------------------------------------------------------------------------------------------------------------------------------------------------
-- PARTES DISPONÍVEIS DO VEÍCULO
------------------------------------------------------------------------------------------------------------------------------------------------

local function GetVehicleAvailableParts(vehicle)
    local parts = {}
    local partsCount = 0

    if vehicle then
        local vehicleCoords = GetEntityCoords(vehicle)

        for boneName, boneConfig in pairs(VehicleBones) do
            local boneIndex = GetEntityBoneIndexByName(vehicle, boneName)
            if boneIndex ~= -1 then
                local bonePos = GetWorldPositionOfEntityBone(vehicle, boneIndex)
                local distance = #(bonePos - vehicleCoords)

                if distance > 0.05 then
                    partsCount = partsCount + 1
                    parts[boneName] = {
                        name  = boneName,
                        index = boneIndex,
                        pos   = bonePos,
                        anim  = boneConfig.anim,
                        broke = boneConfig.broke,
                        dist  = boneConfig.dist,
                    }
                end
            end
        end
    end

    return parts, partsCount
end

------------------------------------------------------------------------------------------------------------------------------------------------
-- ANIMAÇÕES E PROPS
------------------------------------------------------------------------------------------------------------------------------------------------
local AttachPropToPed

local function PlayAnim(animData)
    if animData.task then
        if IsPedUsingAnyScenario(PlayerPedId()) then return end
        TaskStartScenarioInPlace(PlayerPedId(), animData.task, 0, true)
    else
        if animData.prop and animData.bone then
            if animData.clearProps then
                TriggerServerEvent("core-dismantle:server:clearMyObjects")
            end
            AttachPropToPed(animData)
        end

        if animData.dict and animData.anim then
            if LoadAnimDict(animData.dict) then
                local animFlags = 0
                if animData.walk then animFlags = animFlags + 48 end
                if animData.loop then animFlags = animFlags + 1 end
                if animData.flag ~= nil then animFlags = animData.flag end
                TaskPlayAnim(PlayerPedId(), animData.dict, animData.anim, 2.0, 2.0, -1, animFlags, 0, 0, 0, 0)
            end
        end
    end
end

AttachPropToPed = function(propData)
    if not propData.prop or not propData.bone then return end

    if not LoadModel(propData.prop) then return end

    local spawnCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, -2.0)

    PendingPropData = propData
    TriggerServerEvent("core-dismantle:server:createObject", propData.prop, spawnCoords.x, spawnCoords.y, spawnCoords.z, false)
end

RegisterNetEvent("core-dismantle:client:objectCreated", function(objectNetId)
    local propData = PendingPropData
    PendingPropData = nil

    if objectNetId and NetworkDoesNetworkIdExist(objectNetId) then
        if NetworkDoesEntityExistWithNetworkId(objectNetId) then
            local objectEntity = NetworkGetEntityFromNetworkId(objectNetId)
            local ox, oy, oz, rx, ry, rz = 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
            if propData and propData.propPlacement then
                ox, oy, oz, rx, ry, rz = table.unpack(propData.propPlacement)
            end
            AttachEntityToEntity(objectEntity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), propData and propData.bone or 28422), ox, oy, oz, rx, ry, rz, true, true, false, true, 1, true)
        end
    end
end)

local function ClearAnims()
    ClearPedTasks(PlayerPedId())
    ClearPedSecondaryTask(PlayerPedId())
    TriggerServerEvent("core-dismantle:server:clearMyObjects")
    collectgarbage()
end

local function CreateProgressBar(time)
    TriggerEvent("Progress", "Desmanchando", time)
end

------------------------------------------------------------------------------------------------------------------------------------------------
-- INICIAR DESMANCHE
------------------------------------------------------------------------------------------------------------------------------------------------

local function TryStartDismantle(dismantleId)
    if ActionCooldown then return end

    ActionCooldown = true
    SetTimeout(1000, function() ActionCooldown = false end)

    local playerPed = PlayerPedId()
    local currentProgress = LocalPlayer.state["HD-DD"]

    if currentProgress ~= nil then return end
    if not Dismantle.Locations[dismantleId] then return end
    if not IsPedInAnyVehicle(playerPed) then return end

    local vehicle = GetVehiclePedIsIn(playerPed)
    if not vehicle then return end
    if GetPedInVehicleSeat(vehicle, -1) ~= playerPed then return end

    if not NetworkGetEntityIsNetworked(vehicle) then
        if not Dismantle.AllowNpcVehicles then return end

        -- Registra veículo de NPC (não-networked) e toma controle pra permitir desmanche
        NetworkRegisterEntityAsNetworked(vehicle)
        local timeout = 0
        while not NetworkGetEntityIsNetworked(vehicle) and timeout < 50 do
            Wait(10)
            timeout = timeout + 1
        end
        if not NetworkGetEntityIsNetworked(vehicle) then return end

        NetworkRequestControlOfEntity(vehicle)
        SetEntityAsMissionEntity(vehicle, true, true)
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    end

    local vehicleNetId = NetworkGetNetworkIdFromEntity(vehicle)
    if not NetworkDoesNetworkIdExist(vehicleNetId) then return end

    local vehicleClass = tostring(GetVehicleClass(vehicle))
    local _, partsCount = GetVehicleAvailableParts(vehicle)

    TriggerServerEvent("core-dismantle:server:tryStartDismantle", dismantleId, vehicleNetId, vehicleClass, partsCount)
end

------------------------------------------------------------------------------------------------------------------------------------------------
-- LOBBY — PARTICIPANTES
------------------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent("core-dismantle:client:getLobbyParticipants", function(targetPlate, requestId)
    local participants = false
    local playerPed = PlayerPedId()

    if IsPedInAnyVehicle(playerPed) then
        local vehicle = GetVehiclePedIsIn(playerPed)
        if vehicle and DoesEntityExist(vehicle) then
            local plate = GetVehicleNumberPlateText(vehicle):gsub(" ", "")
            if plate == targetPlate then
                participants = {}
                local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
                for seatId = 0, maxSeats, 1 do
                    local occupant = GetPedInVehicleSeat(vehicle, seatId)
                    if occupant > 0 then
                        local serverId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(occupant))
                        table.insert(participants, serverId)
                    end
                end
            end
        end
    end

    TriggerServerEvent("core-dismantle:server:lobbyParticipantsResult", requestId, participants)
end)

------------------------------------------------------------------------------------------------------------------------------------------------
-- PROGRESSO DO DESMANCHE
------------------------------------------------------------------------------------------------------------------------------------------------
local ProgressThread
local TryBreakBone

RegisterNetEvent("core-dismantle:client:setDismantleProgress", function(lobbyId, dismantleId, plate, model, location)
    local playerPed = PlayerPedId()

    if IsPedInAnyVehicle(playerPed) then
        local vehicle = GetVehiclePedIsIn(playerPed)
        if vehicle and DoesEntityExist(vehicle) then
            local vehiclePlate = GetVehicleNumberPlateText(vehicle):gsub(" ", "")
            if vehiclePlate == plate and GetEntityModel(vehicle) == model then
                TaskLeaveVehicle(playerPed, vehicle, 16)

                local availableParts = GetVehicleAvailableParts(vehicle)

                LocalPlayer.state["HD-DD"] = {
                    lobbyId  = lobbyId,
                    id       = dismantleId,
                    location = location,
                    plate    = plate,
                    model    = model,
                    entity   = vehicle,
                    bones    = availableParts,
                }

                ProgressThread()
                TriggerServerEvent("core-dismantle:server:progressSetConfirm", dismantleId, true)
                return
            end
        end
    end

    TriggerServerEvent("core-dismantle:server:progressSetConfirm", dismantleId, false)
end)

RegisterNetEvent("core-dismantle:client:setRemovedBone", function(boneName)
    RemovedBones[boneName] = true
end)

RegisterNetEvent("core-dismantle:client:getDismantleProgress", function(requestId)
    local data = LocalPlayer.state["HD-DD"]
    TriggerServerEvent("core-dismantle:server:dismantleProgressResult", requestId, data)
end)

RegisterNetEvent("core-dismantle:client:syncBrokeVehicleBone", function(vehicleNetId, boneName)
    if vehicleNetId and NetworkDoesNetworkIdExist(vehicleNetId) and NetworkDoesEntityExistWithNetworkId(vehicleNetId) then
        local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
        if vehicle and DoesEntityExist(vehicle) then
            local boneConfig = VehicleBones[boneName]
            if boneConfig and type(boneConfig.broke) == "function" then
                boneConfig.broke(vehicle)
            end
        end
    end
end)

------------------------------------------------------------------------------------------------------------------------------------------------
-- THREAD DE PROGRESSO
------------------------------------------------------------------------------------------------------------------------------------------------

ProgressThread = function()
    RemovedBones = {}

    -- Thread auxiliar: mantém o veículo (especialmente carro de NPC) vivo durante o desmanche.
    -- Re-aplica mission entity / request control a cada 1s pra evitar que o population manager limpe.
    CreateThread(function()
        while LocalPlayer.state["HD-DD"] ~= nil do
            local data = LocalPlayer.state["HD-DD"]
            if data and data.entity and DoesEntityExist(data.entity) then
                if not NetworkHasControlOfEntity(data.entity) then
                    NetworkRequestControlOfEntity(data.entity)
                end
                SetEntityAsMissionEntity(data.entity, true, true)
                SetVehicleHasBeenOwnedByPlayer(data.entity, true)
                SetVehicleIsStolen(data.entity, false)
            end
            Wait(1000)
        end
    end)

    CreateThread(function()
        while true do
            local playerPed = PlayerPedId()
            local dismantleData = LocalPlayer.state["HD-DD"]

            if not dismantleData then break end
            if IsDead() then
                LocalPlayer.state["HD-DD"] = nil
                break
            end

            if not DoesEntityExist(dismantleData.entity) or not IsEntityAVehicle(dismantleData.entity) then
                LocalPlayer.state["HD-DD"] = nil
                break
            end

            local playerCoords = GetEntityCoords(playerPed)
            local vehicleCoords = GetEntityCoords(dismantleData.entity)
            local distance = #(playerCoords - vehicleCoords)

            if distance > 50 then
                LocalPlayer.state["HD-DD"] = nil
                break
            end

            local vehiclePlate = GetVehicleNumberPlateText(dismantleData.entity):gsub(" ", "")
            if vehiclePlate ~= dismantleData.plate or GetEntityModel(dismantleData.entity) ~= dismantleData.model then
                LocalPlayer.state["HD-DD"] = nil
                break
            end

            local lobbyStatus = GlobalState["HD-DL-" .. dismantleData.plate]
            if not lobbyStatus then lobbyStatus = "?" end
            DrawText3D(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, "~w~RESTAM ~r~" .. lobbyStatus .. " ~w~SEGUNDOS PARA FINALIZAR.")

            if not IsPedInAnyVehicle(playerPed) then
                for _, boneData in pairs(dismantleData.bones) do
                    if not AnimBlocked and not RemovedBones[boneData.name] then
                        DrawMarker(20, boneData.pos.x, boneData.pos.y, boneData.pos.z + 1.0, 0, 0, 0, 0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 0, 0, 150, 1, 0, 0, 1)

                        local distanceToBone = #(playerCoords - boneData.pos)
                        if distanceToBone <= 5 then
                            if IsControlJustPressed(0, 38) then
                                TryBreakBone()
                            end
                        end
                    end
                end
            end

            Wait(3)
        end
    end)
end

------------------------------------------------------------------------------------------------------------------------------------------------
-- LOBBY — MONITORAMENTO DE VEÍCULOS PRÓXIMOS
------------------------------------------------------------------------------------------------------------------------------------------------

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()

        if not IsPedInAnyVehicle(playerPed) then
            local playerLobby = Entity(playerPed).state.dismantleLobby
            if playerLobby ~= nil then
                TriggerServerEvent("core-dismantle:server:cancelMyLobby")
            end
        end

        for vehicle, distance in pairs(GetNearestVehicles(15)) do
            if vehicle and DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
                local driver = GetPedInVehicleSeat(vehicle, -1)
                if driver then
                    local driverLobby = Entity(driver).state.dismantleLobby
                    if driverLobby ~= nil then
                        SetVehicleEngineOn(vehicle, false, true, true)

                        if distance <= 8 and not NearbyVehiclesLobby[vehicle] then
                            local plate = GetVehicleNumberPlateText(vehicle):gsub(" ", "")
                            local coords = GetEntityCoords(vehicle)
                            NearbyVehiclesLobby[vehicle] = { plate, coords.x, coords.y, coords.z }
                        end
                    end
                end
            end
        end

        for vehicle, data in pairs(NearbyVehiclesLobby) do
            if not DoesEntityExist(vehicle) or not IsEntityAVehicle(vehicle) then
                NearbyVehiclesLobby[vehicle] = nil
            else
                local playerCoords = GetEntityCoords(playerPed)
                local vehicleCoords = GetEntityCoords(vehicle)
                local dist = #(playerCoords - vehicleCoords)

                if dist > 8 then
                    NearbyVehiclesLobby[vehicle] = nil
                else
                    local driver = GetPedInVehicleSeat(vehicle, -1)
                    if not driver or not Entity(driver).state.dismantleLobby then
                        NearbyVehiclesLobby[vehicle] = nil
                    end
                end
            end
        end

        Wait(2000)
    end
end)

CreateThread(function()
    while true do
        local sleep = 2000
        local playerPed = PlayerPedId()

        for vehicle, data in pairs(NearbyVehiclesLobby) do
            if data and data[1] and data[2] then
                sleep = 0
                local lobbyStatus = GlobalState["HD-DL-" .. data[1]]
                if not lobbyStatus then lobbyStatus = "?" end

                if IsPedInAnyVehicle(playerPed) then
                    if GetVehiclePedIsIn(playerPed) == vehicle then
                        DrawText3D(data[2], data[3], data[4], "~y~AGUARDE, O DESMANCHE SERÁ INICIADO EM " .. lobbyStatus .. " SEGUNDOS.")
                    end
                else
                    DrawText3D(data[2], data[3], data[4], "~y~ENTRE NO VEÍCULO PARA PARTICIPAR DO DESMANCHE. (" .. lobbyStatus .. ")")
                end
            end
        end

        Wait(sleep)
    end
end)

------------------------------------------------------------------------------------------------------------------------------------------------
-- QUEBRA DE PEÇAS
------------------------------------------------------------------------------------------------------------------------------------------------

TryBreakBone = function()
    local dismantleData = LocalPlayer.state["HD-DD"]
    if not dismantleData then return end

    local closestBone = false
    local closestDistance = nil
    local playerCoords = GetEntityCoords(PlayerPedId())

    for _, boneData in pairs(dismantleData.bones) do
        if not RemovedBones[boneData.name] then
            local dist = #(playerCoords - boneData.pos)
            local maxDist = boneData.dist or 1.2

            if dist <= maxDist and (closestDistance == nil or closestDistance > dist) then
                closestBone = boneData
                closestDistance = dist
            end
        end
    end

    if not closestBone then return end
    if BreakCooldown then return end
    if AnimBlocked then return end
    if LocalPlayer.state["HD-DD"] == nil then return end

    BreakCooldown = true
    SetTimeout(1200, function() BreakCooldown = false end)

    -- Verifica no servidor se pode quebrar
    TriggerServerEvent("core-dismantle:server:checkBoneBreaker", dismantleData.lobbyId, closestBone.name)

    -- O resultado e a continuação serão feitos via evento de retorno
    PendingBone = closestBone
end

RegisterNetEvent("core-dismantle:client:boneBreakResult", function(canBreak)
    local closestBone = PendingBone
    PendingBone = nil

    if not canBreak or not closestBone then return end
    if LocalPlayer.state["HD-DD"] == nil then return end

    AnimBlocked = closestBone.name

    SetPlayerControl(PlayerId(), false)

    TaskTurnPedToFaceCoord(PlayerPedId(), closestBone.pos.x, closestBone.pos.y, closestBone.pos.z, 1000)
    Wait(1010)

    PlayAnim(closestBone.anim.breaking)

    local breakTime = Dismantle.PartsTimes[closestBone.name] or 10000
    if breakTime < 1000 then breakTime = breakTime * 1000 end

    CreateProgressBar(breakTime)
    Wait(breakTime)

    SetPlayerControl(PlayerId(), true)
    ClearAnims()

    StartCarryBone(closestBone)
end)

------------------------------------------------------------------------------------------------------------------------------------------------
-- TRANSPORTE DE PEÇA ATÉ A ESTANTE
------------------------------------------------------------------------------------------------------------------------------------------------

function StartCarryBone(boneData)
    local dismantleData = LocalPlayer.state["HD-DD"]
    if not dismantleData then return end

    local carryAnim = boneData.anim.carrying
    local shelfCoords = Dismantle.Locations[dismantleData.location].coords.shelf
    local targetShelfPos = vec3(shelfCoords[1], shelfCoords[2], shelfCoords[3])
    local vehicleNetId = NetworkGetNetworkIdFromEntity(dismantleData.entity)

    -- Notifica servidor sobre a quebra visual
    TriggerServerEvent("core-dismantle:server:brokeVehicleBone", vehicleNetId, boneData.name)

    PlayAnim(carryAnim)

    CreateThread(function()
        while true do
            if not AnimBlocked then break end

            local currentProgress = LocalPlayer.state["HD-DD"]
            if not currentProgress then
                AnimBlocked = nil
                ClearAnims()
                return
            end

            if IsPedInAnyVehicle(PlayerPedId()) then
                TaskLeaveVehicle(PlayerPedId(), GetVehiclePedIsIn(PlayerPedId()), 16)
            end

            local playerCoords = GetEntityCoords(PlayerPedId())

            if not IsEntityPlayingAnim(PlayerPedId(), carryAnim.dict, carryAnim.anim, 3) then
                PlayAnim(carryAnim)
            end

            local distanceToShelf = #(playerCoords - targetShelfPos)

            if distanceToShelf <= 1.8 then
                DrawText2D("~w~PRESSIONE ~r~[E] ~w~PARA DEPOSITAR A PEÇA", 4, 0.2, 0.93, 0.4, 255, 255, 255, 200)

                if IsControlJustPressed(0, 38) then
                    if LocalPlayer.state["HD-DD"] then
                        TriggerServerEvent("core-dismantle:server:deliveryBoneToShelf", currentProgress.lobbyId, AnimBlocked, currentProgress.location)
                        AnimBlocked = nil
                        ClearAnims()
                        break
                    end
                end
            else
                DrawText2D("~w~LEVE A PEÇA ATÉ A ESTANTE", 4, 0.2, 0.93, 0.4, 255, 255, 255, 200)
            end

            Wait(2)
        end
    end)
end

------------------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFICAÇÕES DO SERVIDOR
------------------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent("core-dismantle:client:notify", function(notifyType, message, duration)
    TriggerEvent("Notify", "Desmanche", message, notifyType, duration or 5000)
end)

RegisterNetEvent("core-dismantle:client:dismantleStarted", function()
    TriggerEvent("Notify", "Desmanche", "Desmanche iniciado!", "sucesso", 5000)
end)

RegisterNetEvent("core-dismantle:client:youAreLeader", function()
    TriggerEvent("Notify", "Desmanche", "Você é o líder do desmanche, não morra ou vá para longe.", "amarelo", 5000)
end)

RegisterNetEvent("core-dismantle:client:dismantleTimeEnded", function()
    TriggerEvent("Notify", "Desmanche", "O tempo para desmanchar foi encerrado.", "amarelo", 5000)
end)

RegisterNetEvent("core-dismantle:client:dismantleFinished", function()
    TriggerEvent("Notify", "Desmanche", "Desmanche concluído.", "sucesso", 5000)
end)

------------------------------------------------------------------------------------------------------------------------------------------------
-- THREADS DE INTERAÇÃO (MARCADORES)
------------------------------------------------------------------------------------------------------------------------------------------------

CreateThread(function()
    while true do
        local sleep = 3000
        local playerCoords = GetEntityCoords(PlayerPedId())

        for id, dismantle in pairs(Dismantle.Locations) do
            local point = dismantle.coords["vehicle"]
            local dist = #(playerCoords - vec3(point[1], point[2], point[3]))

            if dist < Dismantle.Interaction.DrawDistance then
                CheckShelf(id)
                sleep = 200
            end

            if dist <= Dismantle.Interaction.InteractDistance and not IsDead() and LocalPlayer.state["HD-DD"] == nil then
                DrawMarker(36, point[1], point[2], point[3] - 0.5, 0, 0, 0, 0, 0.0, 0.0, 0.6, 0.6, 0.6, 255, 0, 0, 150, 1, 0, 0, 1)
                DrawMarker(27, point[1], point[2], point[3] - 0.99, 0, 0, 0, 0, 0.0, 0.0, 5.5, 5.5, 5.5, 255, 0, 0, 50, 0, 0, 0, 0)
                sleep = 3

                if dist <= Dismantle.Interaction.StartDistance then
                    if IsControlJustPressed(0, Dismantle.Interaction.Key) then
                        TryStartDismantle(id)
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

------------------------------------------------------------------------------------------------------------------------------------------------
-- NUI — PAINEL DE GERENCIAMENTO
------------------------------------------------------------------------------------------------------------------------------------------------

local function ResolveThemeColor()
    if Theme and type(Theme.main) == "string" and Theme.main ~= "" then
        return Theme.main
    end
    return Dismantle.ThemeColor or "#dc1553"
end

RegisterNetEvent("core-dismantle:client:openPanel", function(dismantleId, panelData)
    if not Dismantle.Locations[dismantleId] then return end

    CurrentDismantleId = dismantleId
    local dismantleInfo = Dismantle.Locations[dismantleId]

    SendUI("openPanel", {
        name         = dismantleInfo.name,
        primaryColor = ResolveThemeColor(),
        panelData    = panelData,
    })
    SetNUI(true, true)
end)

RegisterNUICallback("post:closeUi", function(_, cb)
    SetNUI(false, false)
    NuiPanelOpen = false
    cb(true)
end)

RegisterNUICallback("get:colors", function(_, cb)
    cb({
        primaryColor   = ResolveThemeColor(),
        secondaryColor = "#ffffff",
        thirdyColor    = "#000000",
    })
end)

RegisterNUICallback("tryMarkDismantleLocation", function(_, cb)
    if CurrentDismantleId and Dismantle.Locations[CurrentDismantleId] then
        local coords = Dismantle.Locations[CurrentDismantleId].coords.vehicle
        SetNewWaypoint(coords[1] + 0.00001, coords[2] + 0.00001)
        TriggerEvent("Notify", "Desmanche", "Localização marcada em seu GPS!", "amarelo", 3000)
    end
    cb(true)
end)

RegisterNUICallback("tryChangeDismantleLocation", function(_, cb)
    cb(true)
    if CurrentDismantleId and Dismantle.Locations[CurrentDismantleId] then
        SendUI("setVisible", false)
        SetNUI(false, false)
        NuiPanelOpen = false
        StartDismantleMover()
    end
end)

RegisterNUICallback("updateStatus", function(data, cb)
    if CurrentDismantleId and Dismantle.Locations[CurrentDismantleId] then
        TriggerServerEvent("core-dismantle:server:updatePublicStatus", CurrentDismantleId, data.isPublic)
        cb({ success = true })
    else
        cb({ success = false })
    end
end)

RegisterNUICallback("updatePercent", function(data, cb)
    if CurrentDismantleId and Dismantle.Locations[CurrentDismantleId] and data.percent then
        TriggerServerEvent("core-dismantle:server:updatePercent", CurrentDismantleId, data.percent)
        cb({ success = true })
    else
        cb({ success = false })
    end
end)

RegisterNUICallback("withdraw", function(data, cb)
    if CurrentDismantleId and Dismantle.Locations[CurrentDismantleId] and data.item then
        TriggerServerEvent("core-dismantle:server:withdrawPanelItem", CurrentDismantleId, data.item, data.amount)
        cb({ success = true })
    else
        cb({ success = false })
    end
end)

------------------------------------------------------------------------------------------------------------------------------------------------
-- MOVER LOCALIZAÇÃO DO DESMANCHE
------------------------------------------------------------------------------------------------------------------------------------------------

local function GetCoordsFromCam(distance, coords)
    local camRot = GetGameplayCamRot()
    local rotInRad = vector3(
        (math.pi / 180) * camRot.x,
        (math.pi / 180) * camRot.y,
        (math.pi / 180) * camRot.z
    )

    local direction = vector3(
        -math.sin(rotInRad[3]) * math.abs(math.cos(rotInRad[1])),
        math.cos(rotInRad[3]) * math.abs(math.cos(rotInRad[1])),
        math.sin(rotInRad[1])
    )

    return vector3(
        coords[1] + direction[1] * distance,
        coords[2] + direction[2] * distance,
        coords[3] + direction[3] * distance
    )
end

function StartDismantleMover()
    if LocationMoverActive then return end

    CreateThread(function()
        LocationMoverActive = true

        if PreviewShelfEntity and DoesEntityExist(PreviewShelfEntity) then
            DeleteEntity(PreviewShelfEntity)
        end

        local playerPed = PlayerPedId()
        local vehiclePosition = nil

        -- Etapa 1: Posicionar veículo
        while vehiclePosition == nil do
            DisableControlAction(0, 24)
            DisableControlAction(0, 25)

            local playerCoords = GetEntityCoords(playerPed)
            local camCoords = GetGameplayCamCoord()
            local hitCoords = GetCoordsFromCam(10.0, camCoords)
            local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(camCoords, hitCoords, -1, playerPed, 4)
            local _, _, endCoords = GetShapeTestResult(rayHandle)

            DrawMarker(36, endCoords.x, endCoords.y, playerCoords.z - 0.5, 0, 0, 0, 0, 0.0, 0.0, 0.6, 0.6, 0.6, 255, 0, 0, 150, 1, 0, 0, 1)
            DrawMarker(27, endCoords.x, endCoords.y, playerCoords.z - 0.99, 0, 0, 0, 0, 0.0, 0.0, 5.5, 5.5, 5.5, 255, 0, 0, 50, 0, 0, 0, 0)

            DrawText2D("~r~1. ~w~POSICIONE O LOCAL DO VEÍCULO", 4, 0.2, 0.87, 0.4, 255, 255, 255, 200)
            DrawText2D("~r~[CLIQUE ESQUERDO] ~w~SALVAR", 4, 0.2, 0.9, 0.4, 255, 255, 255, 200)
            DrawText2D("~r~[CLIQUE DIREITO] ~w~CANCELAR", 4, 0.2, 0.93, 0.4, 255, 255, 255, 200)

            if IsControlJustPressed(0, 24) or IsDisabledControlJustPressed(0, 24) then
                local candidate = vec3(Round2(endCoords.x), Round2(endCoords.y), Round2(playerCoords.z))
                local outOfArea = false

                local relocationArea = CurrentDismantleId and Dismantle.Locations[CurrentDismantleId] and Dismantle.Locations[CurrentDismantleId].allowedRelocationArea
                if relocationArea and relocationArea.center and relocationArea.radius then
                    if #(candidate - relocationArea.center) > relocationArea.radius then
                        outOfArea = true
                    end
                end

                if outOfArea then
                    TriggerEvent("Notify", "Desmanche", "Posicione o desmanche dentro da área permitida desta organização.", "negado", 4000)
                else
                    vehiclePosition = { candidate.x, candidate.y, candidate.z }
                end
            end

            if IsControlJustPressed(0, 25) or IsDisabledControlJustPressed(0, 25) then
                vehiclePosition = false
                break
            end

            Wait(0)
        end

        if vehiclePosition and type(vehiclePosition) == "table" and #vehiclePosition == 3 then
            local shelfPosition = nil

            if LoadModel("prop_shelves_02") then
                local playerCoords = GetEntityCoords(playerPed)
                local playerHeading = GetEntityHeading(playerPed)

                PreviewShelfEntity = CreateObject(ShelfModelHash, playerCoords.x, playerCoords.y, playerCoords.z, false, false, false)
                SetEntityCollision(PreviewShelfEntity, false, false)
                SetEntityHeading(PreviewShelfEntity, playerHeading)
                SetEntityAlpha(PreviewShelfEntity, 100, false)

                -- Etapa 2: Posicionar estante
                while shelfPosition == nil do
                    playerCoords = GetEntityCoords(playerPed)

                    DisableControlAction(0, 24)
                    DisableControlAction(0, 25)

                    local camCoords = GetGameplayCamCoord()
                    local hitCoords = GetCoordsFromCam(10.0, camCoords)
                    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(camCoords, hitCoords, -1, playerPed, 4)
                    local _, _, endCoords = GetShapeTestResult(rayHandle)

                    SetEntityCoordsNoOffset(PreviewShelfEntity, endCoords.x, endCoords.y, playerCoords.z - 1.0, 1, 0, 0)

                    DrawMarker(36, vehiclePosition[1], vehiclePosition[2], vehiclePosition[3] - 0.5, 0, 0, 0, 0, 0.0, 0.0, 0.6, 0.6, 0.6, 255, 0, 0, 150, 1, 0, 0, 1)
                    DrawMarker(27, vehiclePosition[1], vehiclePosition[2], vehiclePosition[3] - 0.99, 0, 0, 0, 0, 0.0, 0.0, 5.5, 5.5, 5.5, 255, 0, 0, 50, 0, 0, 0, 0)

                    DrawText2D("~r~2. ~w~POSICIONE O LOCAL DA ESTANTE", 4, 0.2, 0.84, 0.4, 255, 255, 255, 200)
                    DrawText2D("~r~[CLIQUE ESQUERDO] ~w~SALVAR", 4, 0.2, 0.87, 0.4, 255, 255, 255, 200)
                    DrawText2D("~r~[CLIQUE DIREITO] ~w~CANCELAR", 4, 0.2, 0.9, 0.4, 255, 255, 255, 200)
                    DrawText2D("~r~[SCROLL] ~w~: GIRAR", 4, 0.2, 0.93, 0.4, 255, 255, 255, 200)

                    if IsControlJustPressed(0, 24) or IsDisabledControlJustPressed(0, 24) then
                        local shelfCoords = vec3(Round2(endCoords.x), Round2(endCoords.y), Round2(playerCoords.z))
                        local vehicleCoordsVec = vec3(vehiclePosition[1], vehiclePosition[2], vehiclePosition[3])
                        local dist = #(shelfCoords - vehicleCoordsVec)

                        local outOfArea = false
                        local relocationArea = CurrentDismantleId and Dismantle.Locations[CurrentDismantleId] and Dismantle.Locations[CurrentDismantleId].allowedRelocationArea
                        if relocationArea and relocationArea.center and relocationArea.radius then
                            if #(shelfCoords - relocationArea.center) > relocationArea.radius then
                                outOfArea = true
                            end
                        end

                        if dist > 20 then
                            TriggerEvent("Notify", "Desmanche", "A estante não pode ser colocada muito distante da posição de desmanche do veículo.", "negado", 5000)
                        elseif outOfArea then
                            TriggerEvent("Notify", "Desmanche", "Posicione a estante dentro da área permitida desta organização.", "negado", 4000)
                        else
                            shelfPosition = {
                                Round2(endCoords.x),
                                Round2(endCoords.y),
                                Round2(playerCoords.z),
                                Round2(GetEntityHeading(PreviewShelfEntity)),
                            }
                        end
                    end

                    if IsControlJustPressed(0, 25) or IsDisabledControlJustPressed(0, 25) then
                        shelfPosition = false
                        break
                    end

                    if IsControlJustPressed(1, 180) then
                        SetEntityHeading(PreviewShelfEntity, GetEntityHeading(PreviewShelfEntity) + 6.0)
                    end

                    if IsControlJustPressed(1, 181) then
                        SetEntityHeading(PreviewShelfEntity, GetEntityHeading(PreviewShelfEntity) - 6.0)
                    end

                    Wait(0)
                end

                if shelfPosition and type(shelfPosition) == "table" and #shelfPosition == 4 then
                    if PreviewShelfEntity and DoesEntityExist(PreviewShelfEntity) then
                        DeleteEntity(PreviewShelfEntity)
                    end

                    LocationMoverActive = false
                    TriggerServerEvent("core-dismantle:server:changeDismantleLocation", CurrentDismantleId, vehiclePosition, shelfPosition)
                    return
                end
            end
        end

        if PreviewShelfEntity and DoesEntityExist(PreviewShelfEntity) then
            DeleteEntity(PreviewShelfEntity)
        end

        TriggerEvent("Notify", "Desmanche", "Alteração cancelada!", "amarelo", 3000)
        LocationMoverActive = false
    end)
end

------------------------------------------------------------------------------------------------------------------------------------------------
-- CLEANUP
------------------------------------------------------------------------------------------------------------------------------------------------

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    if PreviewShelfEntity and DoesEntityExist(PreviewShelfEntity) then
        DeleteEntity(PreviewShelfEntity)
    end

    local dismantleState = LocalPlayer.state["HD-DD"]
    if dismantleState ~= nil then
        SetPlayerControl(PlayerId(), true)
        LocalPlayer.state["HD-DD"] = nil
    end

    SetNUI(false, false)
end)
