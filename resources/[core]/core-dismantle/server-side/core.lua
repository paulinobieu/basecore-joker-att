------------------------------------------------------------------------------------------------------------------------------------------------
-- VARIÁVEIS
------------------------------------------------------------------------------------------------------------------------------------------------
local ResourceName         = GetCurrentResourceName()
local activeDismantles     = {}
local vehiclesInProgress   = {}
local dismantleLocations   = {}
local dismantleCache       = {}
local shelfObjects         = {}
local createdShelfEntities = {}
local customCoordsCache    = {}
local dismantleOnCooldown  = {}
local saveDismantleTimers  = {}
local playerObjects        = {}
local isSystemReady        = true
local DebugMode            = false

local PropHashes = {
    shelf   = GetHashKey("prop_shelves_02"),
    door    = GetHashKey("prop_car_door_01"),
    wheel   = GetHashKey("prop_wheel_tyre"),
    battery = GetHashKey("prop_car_battery_01"),
    exhaust = GetHashKey("prop_car_exhaust_01"),
}

local PartTypeMapping = {
    doors = {
        door_dside_f = true,
        door_dside_r = true,
        door_pside_f = true,
        door_pside_r = true,
    },
    wheels = {
        wheel_lf  = true,
        wheel_lr  = true,
        wheel_rf  = true,
        wheel_rr  = true,
        wheel_lm1 = true,
        wheel_rm1 = true,
    },
    batteries = {
        engine = true,
    },
    ehxausts = {
        exhaust = true,
    },
}

GlobalState["HD-CS"] = {}

------------------------------------------------------------------------------------------------------------------------------------------------
-- INICIALIZAÇÃO
------------------------------------------------------------------------------------------------------------------------------------------------

CreateThread(function()
    Citizen.Trace("\n^5[core-dismantle] ^0Servidor carregado!^0\n")

    -- Criação da tabela no banco de dados
    CreateThread(function()
        Functions.query([[
            CREATE TABLE IF NOT EXISTS `core_dismantle` (
                `id` varchar(255) NOT NULL,
                `vehicle_coords` text NOT NULL,
                `shelf_coords` text NOT NULL,
                `public` int(11) DEFAULT 0,
                `percent` int(11) DEFAULT 0,
                `money` int(11) DEFAULT 0,
                `wheels` int(11) DEFAULT 0,
                `doors` int(11) DEFAULT 0,
                `ehxausts` int(11) DEFAULT 0,
                `batteries` int(11) DEFAULT 0,
                UNIQUE KEY `id` (`id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
        ]])

        local dbResults = Functions.query("SELECT * FROM `core_dismantle`")
        if dbResults and type(dbResults) == "table" and #dbResults > 0 then
            for _, row in pairs(dbResults) do
                dismantleCache[row.id] = {
                    vehicle_coords = json.decode(row.vehicle_coords),
                    shelf_coords   = json.decode(row.shelf_coords),
                    public         = Functions.parseInt(row.public) or 0,
                    percent        = Functions.parseInt(row.percent) or 100,
                    money          = Functions.parseInt(row.money) or 0,
                    wheels         = Functions.parseInt(row.wheels) or 0,
                    doors          = Functions.parseInt(row.doors) or 0,
                    ehxausts       = Functions.parseInt(row.ehxausts) or 0,
                    batteries      = Functions.parseInt(row.batteries) or 0,
                }

                if Dismantle.Locations[row.id] and Dismantle.Locations[row.id].hasPanel then
                    Dismantle.Locations[row.id].coords = {
                        vehicle = dismantleCache[row.id].vehicle_coords,
                        shelf   = dismantleCache[row.id].shelf_coords,
                    }
                    customCoordsCache[row.id] = Dismantle.Locations[row.id].coords
                end
            end
        end

        -- Garante que todo desmanche da config tenha um cache
        for dismantleId, dismantleData in pairs(Dismantle.Locations) do
            if not dismantleCache[dismantleId] then
                dismantleCache[dismantleId] = {
                    vehicle_coords = dismantleData.coords.vehicle,
                    shelf_coords   = dismantleData.coords.shelf,
                    public         = 0,
                    percent        = 100,
                    money          = 0,
                    wheels         = 0,
                    doors          = 0,
                    ehxausts       = 0,
                    batteries      = 0,
                }
                SaveDismantleCache(dismantleId)
            end
        end

        isSystemReady = false
    end)

    -- Thread de timer do lobby e progresso
    CreateThread(function()
        while true do
            for lobbyId, lobby in pairs(activeDismantles) do
                if not lobby.inProgress then
                    if lobby.timer > 0 then
                        lobby.timer = lobby.timer - 1
                        GlobalState:set("HD-DL-" .. lobby.vehiclePlate, lobby.timer, true)
                    else
                        TryStartProgress(lobbyId)
                    end
                else
                    if lobby.endTimer > 0 then
                        lobby.endTimer = lobby.endTimer - 1
                        GlobalState:set("HD-DL-" .. lobby.vehiclePlate, lobby.endTimer, true)
                    end
                end
            end
            Wait(1000)
        end
    end)

    -- Thread de verificação de progresso
    CreateThread(function()
        while true do
            for lobbyId, lobby in pairs(activeDismantles) do
                if lobby.inProgress then
                    CheckProgressEnd(lobbyId)
                end
            end
            Wait(5000)
        end
    end)
end)

------------------------------------------------------------------------------------------------------------------------------------------------
-- BANCO DE DADOS — SALVAR CACHE
------------------------------------------------------------------------------------------------------------------------------------------------

function SaveDismantleCache(dismantleId)
    if dismantleId and dismantleCache[dismantleId] then
        Functions.insert(
            "INSERT INTO `core_dismantle` (id, vehicle_coords, shelf_coords, public, percent, money, wheels, doors, ehxausts, batteries) " ..
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE " ..
            "vehicle_coords = ?, shelf_coords = ?, public = ?, percent = ?, money = ?, wheels = ?, doors = ?, ehxausts = ?, batteries = ?",
            {
                dismantleId,
                json.encode(dismantleCache[dismantleId].vehicle_coords),
                json.encode(dismantleCache[dismantleId].shelf_coords),
                dismantleCache[dismantleId].public,
                dismantleCache[dismantleId].percent,
                dismantleCache[dismantleId].money,
                dismantleCache[dismantleId].wheels,
                dismantleCache[dismantleId].doors,
                dismantleCache[dismantleId].ehxausts,
                dismantleCache[dismantleId].batteries,
                json.encode(dismantleCache[dismantleId].vehicle_coords),
                json.encode(dismantleCache[dismantleId].shelf_coords),
                dismantleCache[dismantleId].public,
                dismantleCache[dismantleId].percent,
                dismantleCache[dismantleId].money,
                dismantleCache[dismantleId].wheels,
                dismantleCache[dismantleId].doors,
                dismantleCache[dismantleId].ehxausts,
                dismantleCache[dismantleId].batteries,
            }
        )
    end
end

function SaveDismantleCacheTimed(dismantleId)
    if saveDismantleTimers[dismantleId] then return end

    saveDismantleTimers[dismantleId] = true
    SetTimeout(3000, function()
        SaveDismantleCache(dismantleId)
        saveDismantleTimers[dismantleId] = false
    end)
end

------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS.addItemsToDismantlePanel — IMPLEMENTAÇÃO REAL
------------------------------------------------------------------------------------------------------------------------------------------------

function Functions.addItemsToDismantlePanel(dismantleId, itemType, amount)
    if dismantleId and dismantleCache[dismantleId] then
        local parsedAmount = Functions.parseInt(amount)
        if parsedAmount > 0 then
            local currentAmount = Functions.parseInt(dismantleCache[dismantleId][itemType])
            dismantleCache[dismantleId][itemType] = currentAmount + parsedAmount
            SaveDismantleCacheTimed(dismantleId)
        end
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------
-- COORDENADAS CUSTOMIZADAS
------------------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent("core-dismantle:server:getCustomCoords", function()
    local playerSource = source

    if isSystemReady then
        TriggerClientEvent("core-dismantle:client:receiveCustomCoords", playerSource, nil)
        return
    end

    TriggerClientEvent("core-dismantle:client:receiveCustomCoords", playerSource, customCoordsCache)
end)

------------------------------------------------------------------------------------------------------------------------------------------------
-- INICIAR DESMANCHE
------------------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent("core-dismantle:server:tryStartDismantle", function(dismantleId, vehicleNetId, vehicleClass, totalParts)
    local playerSource = source

    -- Verificação de sessão/dimensão
    if Dismantle.SessionVerifier and GetPlayerRoutingBucket(playerSource) ~= 0 then
        return
    end

    local userId = Functions.getUserId(playerSource)
    if not userId then return end

    if not Dismantle.Locations[dismantleId] then
        Functions.notify(playerSource, Functions.NotifyTypes.Denied, "Desmanche não encontrado.")
        return
    end

    if dismantleLocations[dismantleId] then
        Functions.notify(playerSource, Functions.NotifyTypes.Denied, "Este desmanche já está em uso.")
        return
    end

    if dismantleOnCooldown[dismantleId] and dismantleOnCooldown[dismantleId] > os.time() then
        Functions.notify(playerSource, Functions.NotifyTypes.Warning, "Aguarde o cooldown deste desmanche.")
        return
    end

    local dismantle = Dismantle.Locations[dismantleId]
    local hasAccess = false
    local workingPublic = false

    -- Se tem painel e está público, qualquer pessoa pode usar
    if dismantle.hasPanel and dismantleCache[dismantleId] and dismantleCache[dismantleId].public == 1 then
        workingPublic = true
        hasAccess = true
    end

    -- Se não tem acesso público, verifica permissão
    if not hasAccess then
        if dismantle.permissions and dismantle.permissions.use then
            if Functions.hasPermission(userId, dismantle.permissions.use) then
                hasAccess = true
            end
        else
            hasAccess = true
        end
    end

    if not hasAccess then
        Functions.notify(playerSource, Functions.NotifyTypes.Denied, "Você não tem permissão para usar este desmanche.")
        return
    end

    -- Verifica se já está em progresso
    for _, lobby in pairs(activeDismantles) do
        for _, participant in pairs(lobby.participants) do
            if participant.src == playerSource then
                Functions.notify(playerSource, Functions.NotifyTypes.Warning, "Você já está em um desmanche.")
                return
            end
        end
    end

    -- Verificação da classe do veículo
    if not dismantle.allowedClasses[vehicleClass] then
        Functions.notify(playerSource, Functions.NotifyTypes.Denied, "Este tipo de veículo não é permitido neste desmanche.")
        return
    end

    -- Verificação do veículo no servidor
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
    if not vehicle or not DoesEntityExist(vehicle) then
        Functions.notify(playerSource, Functions.NotifyTypes.Denied, "Veículo inválido.")
        return
    end

    local vehiclePlate = GetVehicleNumberPlateText(vehicle):gsub(" ", "")

    -- Verificação de veículo duplicado em progresso
    if vehiclesInProgress[vehiclePlate] then
        local existingVehicle = NetworkGetEntityFromNetworkId(vehiclesInProgress[vehiclePlate][1])
        if existingVehicle and DoesEntityExist(existingVehicle) and GetEntityType(existingVehicle) == 2 then
            local existingPlate = GetVehicleNumberPlateText(existingVehicle):gsub(" ", "")
            local existingModel = GetEntityModel(existingVehicle)
            if existingPlate == vehiclesInProgress[vehiclePlate][2] and existingModel == vehiclesInProgress[vehiclePlate][3] then
                Functions.notify(playerSource, Functions.NotifyTypes.Denied, "Este veículo já está sendo desmanchado.")
                return
            end
        end
    end

    local vehicleModel = GetEntityModel(vehicle)
    if not Dismantle.CanVehicleBeDismantled(vehicle, vehiclePlate, vehicleModel, vehicleClass) then
        Functions.notify(playerSource, Functions.NotifyTypes.Denied, "Este veículo não pode ser desmanchado.")
        return
    end

    -- Registrar lobby
    dismantleLocations[dismantleId] = true
    vehiclesInProgress[vehiclePlate] = { vehicleNetId, vehiclePlate, vehicleModel }
    FreezeEntityPosition(vehicle, true)

    -- Criar estante
    if dismantle.coords and dismantle.coords.shelf then
        local shelfCoords = dismantle.coords.shelf
        local shelfEntity = CreateObjectNoOffset(PropHashes.shelf, shelfCoords[1], shelfCoords[2], shelfCoords[3] - 1, true, true, false)

        local timeout = 0
        while not DoesEntityExist(shelfEntity) and timeout < 1000 do
            Wait(0)
            timeout = timeout + 1
        end

        if DoesEntityExist(shelfEntity) then
            FreezeEntityPosition(shelfEntity, true)

            createdShelfEntities[dismantleId] = {
                shelfEntity,
                NetworkGetNetworkIdFromEntity(shelfEntity),
                shelfCoords[4],
            }
        end

        shelfObjects[dismantleId] = {}
    end

    GlobalState:set("HD-SO-" .. dismantleId, {}, true)
    GlobalState:set("HD-CS", createdShelfEntities, true)

    activeDismantles[playerSource] = {
        location         = dismantleId,
        netVehicleEntity = vehicleNetId,
        vehiclePlate     = vehiclePlate,
        vehicleModel     = vehicleModel,
        leader           = userId,
        participants     = {},
        timer            = Dismantle.Timers.Lobby + 1,
        endTimer         = 0,
        inProgress       = false,
        totalParts       = totalParts,
        removedParts     = 0,
        boneBreakers     = {},
        vehicleClass     = vehicleClass,
        workingPublic    = workingPublic,
        paymentPercent   = dismantleCache[dismantleId].percent,
    }

    Entity(GetPlayerPed(playerSource)).state:set("dismantleLobby", true, true)
end)

------------------------------------------------------------------------------------------------------------------------------------------------
-- CANCELAR LOBBY
------------------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent("core-dismantle:server:cancelMyLobby", function()
    local playerSource = source
    if playerSource then
        ResetLobbyState(playerSource)
    end
end)

function ResetLobbyState(playerSource)
    if not playerSource or not activeDismantles[playerSource] then return end

    local lobby = activeDismantles[playerSource]

    if not lobby.inProgress then
        if vehiclesInProgress[lobby.vehiclePlate] then
            vehiclesInProgress[lobby.vehiclePlate] = nil
        end

        if dismantleLocations[lobby.location] then
            dismantleLocations[lobby.location] = nil
        end

        if createdShelfEntities[lobby.location] and createdShelfEntities[lobby.location][1] then
            if DoesEntityExist(createdShelfEntities[lobby.location][1]) then
                DeleteEntity(createdShelfEntities[lobby.location][1])
                createdShelfEntities[lobby.location] = nil
            end
        end

        if lobby.netVehicleEntity then
            local vehicle = NetworkGetEntityFromNetworkId(lobby.netVehicleEntity)
            if vehicle and DoesEntityExist(vehicle) then
                FreezeEntityPosition(vehicle, false)
            end
        end

        activeDismantles[playerSource] = nil
    end

    local playerPed = GetPlayerPed(playerSource)
    if playerPed and Entity(playerPed).state.dismantleLobby then
        Entity(playerPed).state:set("dismantleLobby", nil, true)
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------
-- INICIAR PROGRESSO (LOBBY → DESMANCHE)
------------------------------------------------------------------------------------------------------------------------------------------------

function TryStartProgress(lobbyId)
    if not lobbyId or not activeDismantles[lobbyId] then return end

    local lobby = activeDismantles[lobbyId]
    local userId = Functions.getUserId(lobbyId)

    if not userId then
        return ResetLobbyState(lobbyId)
    end

    if userId ~= lobby.leader then
        return ResetLobbyState(lobbyId)
    end

    local userSource = Functions.getUserSource(userId)
    if userSource ~= lobbyId then
        return ResetLobbyState(lobbyId)
    end

    local vehicle = NetworkGetEntityFromNetworkId(lobby.netVehicleEntity)
    if not vehicle or not DoesEntityExist(vehicle) then
        return ResetLobbyState(lobbyId)
    end

    local vehiclePlate = GetVehicleNumberPlateText(vehicle):gsub(" ", "")
    local vehicleModel = GetEntityModel(vehicle)

    if vehiclePlate ~= lobby.vehiclePlate or vehicleModel ~= lobby.vehicleModel then
        return ResetLobbyState(lobbyId)
    end

    local leaderPed = GetPlayerPed(lobbyId)
    local leaderVehicle = GetVehiclePedIsIn(leaderPed)

    if leaderVehicle ~= vehicle then
        return ResetLobbyState(lobbyId)
    end

    -- Solicitar a lista de participantes do veículo
    local requestId = "lobby-" .. lobbyId .. "-" .. os.time()
    local participants = nil
    local participantsReceived = false

    RegisterNetEvent("core-dismantle:server:lobbyParticipantsResult", function(reqId, result)
        if reqId == requestId then
            participants = result
            participantsReceived = true
        end
    end)

    TriggerClientEvent("core-dismantle:client:getLobbyParticipants", lobbyId, lobby.vehiclePlate, requestId)

    local timeout = 0
    while not participantsReceived and timeout < 5000 do
        Wait(10)
        timeout = timeout + 10
    end

    if not participants then
        return ResetLobbyState(lobbyId)
    end

    lobby.inProgress = true
    lobby.endTimer = Dismantle.Timers.Progress + 5

    -- Definir progresso no líder
    local leaderConfirmed = false
    local leaderConfirmReceived = false

    RegisterNetEvent("core-dismantle:server:progressSetConfirm", function(dId, success)
        if dId == lobby.location then
            leaderConfirmed = success
            leaderConfirmReceived = true
        end
    end)

    TriggerClientEvent("core-dismantle:client:setDismantleProgress", lobbyId, lobbyId, lobby.location, lobby.vehiclePlate, lobby.vehicleModel, lobby.location)

    timeout = 0
    while not leaderConfirmReceived and timeout < 5000 do
        Wait(10)
        timeout = timeout + 10
    end

    if leaderConfirmed then
        Entity(leaderPed).state:set("dismantleLobby", nil, true)
        SetVehicleDoorsLocked(vehicle, 2)

        table.insert(lobby.participants, {
            src       = lobbyId,
            userId    = userId,
            isLeader  = true,
        })

        -- Definir progresso nos passageiros
        for _, participantSource in pairs(participants) do
            if participantSource ~= lobbyId then
                local partUserId = Functions.getUserId(participantSource)
                if partUserId then
                    TriggerClientEvent("core-dismantle:client:setDismantleProgress", participantSource, lobbyId, lobby.location, lobby.vehiclePlate, lobby.vehicleModel, lobby.location)
                    table.insert(lobby.participants, {
                        src      = participantSource,
                        userId   = partUserId,
                        isLeader = false,
                    })
                end
            end
        end

        TriggerClientEvent("core-dismantle:client:youAreLeader", lobbyId)
        return true
    end

    lobby.inProgress = false
end

------------------------------------------------------------------------------------------------------------------------------------------------
-- VERIFICAÇÃO DE PROGRESSO
------------------------------------------------------------------------------------------------------------------------------------------------

function CheckProgressEnd(lobbyId)
    if not lobbyId or not activeDismantles[lobbyId] then return end

    local lobby = activeDismantles[lobbyId]

    if dismantleOnCooldown[lobbyId] then return end

    local disconnectedLeader = false

    for participantIdx, participant in pairs(lobby.participants) do
        local stillValid = true
        local participantSource = Functions.getUserSource(participant.userId)

        if participantSource then
            -- Verifica se o participante ainda tem dados de progresso válidos
            if participantSource ~= participant.src then
                stillValid = false
            end
        else
            stillValid = false
        end

        if not stillValid then
            if participant.isLeader then
                disconnectedLeader = true
            end
            lobby.participants[participantIdx] = nil
        end
    end

    if Functions.isEmptyTable(lobby.participants) then
        ResetLobbyData(lobbyId)
        return
    end

    if disconnectedLeader then
        local newLeaderSource = false
        for participantIdx, participant in pairs(lobby.participants) do
            lobby.participants[participantIdx].isLeader = true
            newLeaderSource = participant.src
            break
        end

        if not newLeaderSource then
            ResetLobbyData(lobbyId)
            return
        else
            TriggerClientEvent("core-dismantle:client:youAreLeader", newLeaderSource)
        end
    end

    if lobby.endTimer <= 0 then
        for _, participant in pairs(lobby.participants) do
            TriggerClientEvent("core-dismantle:client:dismantleTimeEnded", participant.src)
        end
        PaymentLobby(lobbyId, true)
    elseif lobby.removedParts >= lobby.totalParts then
        for _, participant in pairs(lobby.participants) do
            TriggerClientEvent("core-dismantle:client:dismantleFinished", participant.src)
        end
        PaymentLobby(lobbyId, false)
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------
-- PAGAMENTO
------------------------------------------------------------------------------------------------------------------------------------------------

function PaymentLobby(lobbyId, timedOut)
    local lobby = activeDismantles[lobbyId]
    if not lobby then return end

    dismantleOnCooldown[lobbyId] = true

    local removedPartsCount = shelfObjects[lobby.location] or {}
    local itemCounts = {}

    for categoryName, categoryParts in pairs(PartTypeMapping) do
        itemCounts[categoryName] = 0
        for boneName, _ in pairs(categoryParts) do
            if removedPartsCount[boneName] then
                itemCounts[categoryName] = itemCounts[categoryName] + 1
            end
        end
    end

    local leaderSource  = false
    local leaderUserId  = false

    for _, participant in pairs(lobby.participants) do
        if participant.isLeader then
            local currentSource = Functions.getUserSource(participant.userId)
            if currentSource == participant.src then
                leaderSource = participant.src
                leaderUserId = participant.userId
                break
            end
        end
    end

    if not leaderSource or not leaderUserId then
        for _, participant in pairs(lobby.participants) do
            local currentSource = Functions.getUserSource(participant.userId)
            if currentSource == participant.src then
                leaderSource = participant.src
                leaderUserId = participant.userId
                break
            end
        end
    end

    CreateThread(function()
        if leaderSource and leaderUserId then
            local paymentData = {
                dismantleId          = lobby.location,
                vehicleModel         = lobby.vehicleModel,
                vehicleClass         = lobby.vehicleClass,
                vehiclePlate         = lobby.vehiclePlate,
                isPublicWork         = lobby.workingPublic,
                publicPaymentPercent = lobby.paymentPercent,
                hasPanel             = Dismantle.Locations[lobby.location] and Dismantle.Locations[lobby.location].hasPanel or false,
                items                = itemCounts,
            }
            Dismantle.OnPayment(leaderSource, leaderUserId, paymentData, timedOut)

            Webhooks.onDismantleCompleted(leaderUserId, lobby.location, lobby.vehiclePlate, timedOut)
        end
    end)

    SetTimeout(2000, function()
        ResetLobbyData(lobbyId, true)
    end)
end

------------------------------------------------------------------------------------------------------------------------------------------------
-- RESET DO LOBBY
------------------------------------------------------------------------------------------------------------------------------------------------

local function RemoveVehicleEntity(netId)
    if netId then
        local entity = NetworkGetEntityFromNetworkId(netId)
        if entity and entity ~= 0 and DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end
end

function ResetLobbyData(lobbyId, applyPayment)
    if not lobbyId or not activeDismantles[lobbyId] then return end

    local lobby = activeDismantles[lobbyId]
    local vehicle = NetworkGetEntityFromNetworkId(lobby.netVehicleEntity)

    if vehicle and DoesEntityExist(vehicle) and GetEntityType(vehicle) == 2 then
        local plate = GetVehicleNumberPlateText(vehicle):gsub(" ", "")
        local model = GetEntityModel(vehicle)

        if plate == lobby.vehiclePlate and model == lobby.vehicleModel then
            RemoveVehicleEntity(lobby.netVehicleEntity)
        end
    end

    if vehiclesInProgress[lobby.vehiclePlate] then
        vehiclesInProgress[lobby.vehiclePlate] = nil
    end

    if dismantleLocations[lobby.location] then
        dismantleLocations[lobby.location] = nil
    end

    SetTimeout(2000, function()
        if applyPayment and Dismantle.Locations[lobby.location] and Dismantle.Locations[lobby.location].cooldown and Dismantle.Locations[lobby.location].cooldown > 0 then
            dismantleOnCooldown[lobby.location] = os.time() + Dismantle.Locations[lobby.location].cooldown
        end

        ClearShelfObjects(lobby.location)
        Wait(1000)

        if createdShelfEntities[lobby.location] and createdShelfEntities[lobby.location][1] then
            if DoesEntityExist(createdShelfEntities[lobby.location][1]) then
                DeleteEntity(createdShelfEntities[lobby.location][1])
                createdShelfEntities[lobby.location] = nil
            end
        end

        activeDismantles[lobbyId] = nil
        dismantleOnCooldown[lobbyId] = nil
    end)
end

------------------------------------------------------------------------------------------------------------------------------------------------
-- BONES — VERIFICAÇÃO E ENTREGA
------------------------------------------------------------------------------------------------------------------------------------------------

local function GetBoneModel(boneName)
    if boneName:find("door_")   then return PropHashes.door    end
    if boneName:find("wheel_")  then return PropHashes.wheel   end
    if boneName:find("engine")  then return PropHashes.battery end
    if boneName:find("exhaust") then return PropHashes.exhaust end
    return false
end

RegisterNetEvent("core-dismantle:server:checkBoneBreaker", function(lobbyId, boneName)
    local playerSource = source

    Wait(math.random(0, 300))

    local userId = Functions.getUserId(playerSource)
    if not userId or not activeDismantles[lobbyId] then
        TriggerClientEvent("core-dismantle:client:boneBreakResult", playerSource, false)
        return
    end

    local lobby = activeDismantles[lobbyId]

    if lobby.boneBreakers[boneName] then
        local breakerSource = Functions.getUserSource(lobby.boneBreakers[boneName][2])
        if breakerSource == lobby.boneBreakers[boneName][1] then
            Functions.notify(playerSource, Functions.NotifyTypes.Warning, "Alguém já está removendo essa peça.")
            TriggerClientEvent("core-dismantle:client:boneBreakResult", playerSource, false)
            return
        end
    end

    lobby.boneBreakers[boneName] = { playerSource, userId }
    TriggerClientEvent("core-dismantle:client:boneBreakResult", playerSource, true)
end)

RegisterNetEvent("core-dismantle:server:deliveryBoneToShelf", function(lobbyId, boneName, dismantleId)
    local playerSource = source
    local userId = Functions.getUserId(playerSource)

    if not userId or not activeDismantles[lobbyId] then return end

    local lobby = activeDismantles[lobbyId]

    if lobby.boneBreakers[boneName] and lobby.boneBreakers[boneName][1] == playerSource then
        lobby.removedParts = lobby.removedParts + 1

        -- Notifica todos os participantes
        for _, participant in pairs(lobby.participants) do
            TriggerClientEvent("core-dismantle:client:setRemovedBone", participant.src, boneName)
        end

        local boneModel = GetBoneModel(boneName)
        if boneModel then
            local modelKey = tostring(boneModel)
            local objectEntity = nil

            if playerObjects[playerSource] and playerObjects[playerSource][modelKey] then
                if DoesEntityExist(playerObjects[playerSource][modelKey]) then
                    objectEntity = playerObjects[playerSource][modelKey]
                end
            end

            if objectEntity then
                playerObjects[playerSource][modelKey] = nil
            end

            CreateShelfObject(dismantleId, boneName, objectEntity)
        end
    end
end)

RegisterNetEvent("core-dismantle:server:brokeVehicleBone", function(vehicleNetId, boneName)
    if vehicleNetId and boneName then
        TriggerClientEvent("core-dismantle:client:syncBrokeVehicleBone", -1, vehicleNetId, boneName)
    end
end)

------------------------------------------------------------------------------------------------------------------------------------------------
-- OBJETOS DA ESTANTE
------------------------------------------------------------------------------------------------------------------------------------------------

function CreateShelfObject(dismantleId, boneName, objectEntity)
    if not dismantleId or not boneName then return end
    if not shelfObjects[dismantleId] then shelfObjects[dismantleId] = {} end
    if shelfObjects[dismantleId][boneName] then return end

    local shelfCoords = Dismantle.Locations[dismantleId].coords.shelf
    local boneModel = GetBoneModel(boneName)

    if boneModel then
        local entity = objectEntity

        if objectEntity then
            SetEntityCoords(objectEntity, shelfCoords[1], shelfCoords[2], shelfCoords[3] - 5)
        else
            entity = CreateObjectNoOffset(boneModel, shelfCoords[1], shelfCoords[2], shelfCoords[3] - 5, true, true, false)

            local timeout = 0
            while not DoesEntityExist(entity) and timeout < 1000 do
                Wait(0)
                timeout = timeout + 1
            end
        end

        if entity and DoesEntityExist(entity) then
            FreezeEntityPosition(entity, true)
            shelfObjects[dismantleId][boneName] = {
                entity,
                NetworkGetNetworkIdFromEntity(entity),
            }
            GlobalState:set("HD-SO-" .. dismantleId, shelfObjects[dismantleId], true)
        end
    end
end

function ClearShelfObjects(dismantleId)
    if shelfObjects[dismantleId] then
        for boneName, objectData in pairs(shelfObjects[dismantleId]) do
            if objectData[1] and DoesEntityExist(objectData[1]) then
                DeleteEntity(objectData[1])
            end
        end
        shelfObjects[dismantleId] = {}
    end
    GlobalState:set("HD-SO-" .. dismantleId, {}, true)
end

------------------------------------------------------------------------------------------------------------------------------------------------
-- OBJETOS DO JOGADOR (PROPS DE CARREGAMENTO)
------------------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent("core-dismantle:server:createObject", function(modelHash, x, y, z, isExtra)
    local playerSource = source

    if not playerObjects[playerSource] then
        playerObjects[playerSource] = {}
    end

    local objectKey = tostring(modelHash)
    if isExtra then
        objectKey = objectKey .. "-" .. tostring(#playerObjects[playerSource])
    end

    if not isExtra and playerObjects[playerSource][objectKey] and DoesEntityExist(playerObjects[playerSource][objectKey]) then
        local netId = NetworkGetNetworkIdFromEntity(playerObjects[playerSource][objectKey])
        TriggerClientEvent("core-dismantle:client:objectCreated", playerSource, netId, nil)
        return
    end

    local object = CreateObject(modelHash, x, y, z, true, true, false)
    local timeout = 0

    while not DoesEntityExist(object) and timeout < 1000 do
        Wait(0)
        timeout = timeout + 1
    end

    if not DoesEntityExist(object) then return end

    playerObjects[playerSource][objectKey] = object
    local netId = NetworkGetNetworkIdFromEntity(object)
    TriggerClientEvent("core-dismantle:client:objectCreated", playerSource, netId, nil)
end)

RegisterNetEvent("core-dismantle:server:clearMyObjects", function()
    local playerSource = source

    if playerObjects[playerSource] then
        for _, object in pairs(playerObjects[playerSource]) do
            if DoesEntityExist(object) then
                DeleteEntity(object)
            end
        end
        playerObjects[playerSource] = {}
    end
end)

------------------------------------------------------------------------------------------------------------------------------------------------
-- PAINEL DE GERENCIAMENTO — COMANDO
------------------------------------------------------------------------------------------------------------------------------------------------

RegisterCommand(Dismantle.PanelCommand, function(source, args, rawCommand)
    if source == 0 then return end

    local userId = Functions.getUserId(source)
    if not userId then return end

    if args[1] then
        local searchTerm = args[1]:lower()
        local foundId = nil

        for dismantleId, dismantleData in pairs(Dismantle.Locations) do
            if dismantleId:lower() == searchTerm then
                if Functions.hasPermission(userId, dismantleData.permissions.manage) then
                    foundId = dismantleId
                end
            end
        end

        if foundId and dismantleCache[foundId] then
            TriggerClientEvent("core-dismantle:client:openPanel", source, foundId, dismantleCache[foundId])
        end
    else
        local foundId = false
        for dismantleId, dismantleData in pairs(Dismantle.Locations) do
            if Functions.hasPermission(userId, dismantleData.permissions.manage) then
                foundId = dismantleId
                break
            end
        end

        if foundId and dismantleCache[foundId] then
            TriggerClientEvent("core-dismantle:client:openPanel", source, foundId, dismantleCache[foundId])
        end
    end
end)

------------------------------------------------------------------------------------------------------------------------------------------------
-- PAINEL — AÇÕES
------------------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent("core-dismantle:server:changeDismantleLocation", function(dismantleId, vehicleCoords, shelfCoords)
    local playerSource = source

    if not Dismantle.Locations[dismantleId] then
        Functions.notify(playerSource, Functions.NotifyTypes.Denied, "Desmanche não encontrado.")
        return
    end

    local userId = Functions.getUserId(playerSource)
    if not userId then
        Functions.notify(playerSource, Functions.NotifyTypes.Denied, "Identificação inválida.")
        return
    end

    if not Functions.hasPermission(userId, Dismantle.Locations[dismantleId].permissions.manage) then
        Functions.notify(playerSource, Functions.NotifyTypes.Denied, "Sem permissão.")
        return
    end

    if type(vehicleCoords) ~= "table" or #vehicleCoords ~= 3 then
        Functions.notify(playerSource, Functions.NotifyTypes.Denied, "Posições inválidas.")
        return
    end

    if type(shelfCoords) ~= "table" or #shelfCoords ~= 4 then
        Functions.notify(playerSource, Functions.NotifyTypes.Denied, "Posições inválidas.")
        return
    end

    if dismantleLocations[dismantleId] then
        Functions.notify(playerSource, Functions.NotifyTypes.Warning, "O desmanche está em uso, não é possível alterar a localização.")
        return
    end

    -- Verificação de áreas bloqueadas
    local isBlocked = false
    for _, area in pairs(Dismantle.BlockedAreas) do
        local distance = #(vec3(vehicleCoords[1], vehicleCoords[2], vehicleCoords[3]) - area.center)
        if distance <= area.radius then
            isBlocked = true
            break
        end
    end

    if isBlocked then
        Functions.notify(playerSource, Functions.NotifyTypes.Denied, "Essa área está bloqueada para desmanches.")
        return
    end

    -- Verificação de área permitida para relocação (por org)
    local relocationArea = Dismantle.Locations[dismantleId].allowedRelocationArea
    if relocationArea and relocationArea.center and relocationArea.radius then
        local vehicleDist = #(vec3(vehicleCoords[1], vehicleCoords[2], vehicleCoords[3]) - relocationArea.center)
        local shelfDist   = #(vec3(shelfCoords[1], shelfCoords[2], shelfCoords[3]) - relocationArea.center)

        if vehicleDist > relocationArea.radius or shelfDist > relocationArea.radius then
            Functions.notify(playerSource, Functions.NotifyTypes.Denied, "O desmanche só pode ser instalado dentro da área permitida desta organização.")
            return
        end
    end

    Dismantle.Locations[dismantleId].coords = {
        vehicle = vehicleCoords,
        shelf   = shelfCoords,
    }

    customCoordsCache[dismantleId] = Dismantle.Locations[dismantleId].coords
    dismantleCache[dismantleId].vehicle_coords = vehicleCoords
    dismantleCache[dismantleId].shelf_coords = shelfCoords

    SaveDismantleCache(dismantleId)
    TriggerClientEvent("core-dismantle:client:updateDismantleCoords", -1, dismantleId, Dismantle.Locations[dismantleId].coords)

    Functions.notify(playerSource, Functions.NotifyTypes.Success, "Localização do desmanche alterada com sucesso!")
    Webhooks.onPanelAction(userId, dismantleId, "ALTEROU LOCALIZAÇÃO", "Nova posição definida")
end)

RegisterNetEvent("core-dismantle:server:updatePublicStatus", function(dismantleId, isPublic)
    local playerSource = source

    if not Dismantle.Locations[dismantleId] then
        Functions.notify(playerSource, Functions.NotifyTypes.Denied, "Desmanche não encontrado.")
        return
    end

    local userId = Functions.getUserId(playerSource)
    if not userId or not Functions.hasPermission(userId, Dismantle.Locations[dismantleId].permissions.manage) then
        Functions.notify(playerSource, Functions.NotifyTypes.Denied, "Sem permissão.")
        return
    end

    local publicStatus = isPublic and 1 or 0
    dismantleCache[dismantleId].public = publicStatus

    if publicStatus == 1 then
        Functions.notify(playerSource, Functions.NotifyTypes.Success, "Desmanche definido como público.")
    else
        Functions.notify(playerSource, Functions.NotifyTypes.Success, "Desmanche definido como privado.")
    end

    SaveDismantleCache(dismantleId)
    Webhooks.onPanelAction(userId, dismantleId, "ALTEROU STATUS", isPublic and "Público" or "Privado")
end)

RegisterNetEvent("core-dismantle:server:updatePercent", function(dismantleId, percent)
    local playerSource = source

    if not Dismantle.Locations[dismantleId] then
        Functions.notify(playerSource, Functions.NotifyTypes.Denied, "Desmanche não encontrado.")
        return
    end

    local userId = Functions.getUserId(playerSource)
    if not userId or not Functions.hasPermission(userId, Dismantle.Locations[dismantleId].permissions.manage) then
        Functions.notify(playerSource, Functions.NotifyTypes.Denied, "Sem permissão.")
        return
    end

    percent = Functions.parseInt(percent)
    if not percent or percent < 0 or percent > 100 then
        Functions.notify(playerSource, Functions.NotifyTypes.Warning, "Porcentagem inválida (0-100).")
        return
    end

    dismantleCache[dismantleId].percent = percent
    Functions.notify(playerSource, Functions.NotifyTypes.Success, "Porcentagem definida para " .. percent .. "%.")

    SaveDismantleCache(dismantleId)
    Webhooks.onPanelAction(userId, dismantleId, "ALTEROU PORCENTAGEM", tostring(percent) .. "%")
end)

RegisterNetEvent("core-dismantle:server:withdrawPanelItem", function(dismantleId, itemType, amount)
    local playerSource = source

    if not Dismantle.Locations[dismantleId] or not Dismantle.PartItems[itemType] then
        Functions.notify(playerSource, Functions.NotifyTypes.Denied, "Desmanche ou item inválido.")
        return
    end

    local userId = Functions.getUserId(playerSource)
    if not userId or not Functions.hasPermission(userId, Dismantle.Locations[dismantleId].permissions.manage) then
        Functions.notify(playerSource, Functions.NotifyTypes.Denied, "Sem permissão.")
        return
    end

    amount = Functions.parseInt(amount)
    if not amount or amount <= 0 or amount > 1000000000 then
        Functions.notify(playerSource, Functions.NotifyTypes.Warning, "Quantidade inválida.")
        return
    end

    if amount > dismantleCache[dismantleId][itemType] then
        Functions.notify(playerSource, Functions.NotifyTypes.Warning, "Quantidade insuficiente no painel.")
        return
    end

    if Functions.checkMaxItems(userId, Dismantle.PartItems[itemType], amount) then
        Functions.notify(playerSource, Functions.NotifyTypes.Warning, "Sem espaço no inventário.")
        return
    end

    Functions.giveItem(userId, Dismantle.PartItems[itemType], amount)
    dismantleCache[dismantleId][itemType] = dismantleCache[dismantleId][itemType] - amount

    Functions.notify(playerSource, Functions.NotifyTypes.Success, "Item coletado do painel!")
    SaveDismantleCache(dismantleId)

    Webhooks.onPanelAction(userId, dismantleId, "RETIROU ITEM", itemType .. " x" .. amount)
end)

------------------------------------------------------------------------------------------------------------------------------------------------
-- CLEANUP
------------------------------------------------------------------------------------------------------------------------------------------------

AddEventHandler("playerDropped", function()
    local playerSource = source

    -- Limpar objetos do jogador
    if playerObjects[playerSource] then
        for _, object in pairs(playerObjects[playerSource]) do
            if DoesEntityExist(object) then
                DeleteEntity(object)
            end
        end
        playerObjects[playerSource] = nil
    end

    -- Resetar lobby se era líder
    ResetLobbyState(playerSource)
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    -- Limpar objetos de jogadores
    for playerSource, objects in pairs(playerObjects) do
        for _, object in pairs(objects) do
            if DoesEntityExist(object) then
                DeleteEntity(object)
            end
        end
    end

    -- Limpar estantes
    for dismantleId, shelfData in pairs(createdShelfEntities) do
        if shelfData[1] and DoesEntityExist(shelfData[1]) then
            DeleteEntity(shelfData[1])
        end
    end

    -- Limpar objetos de peças nas estantes
    for dismantleId, objects in pairs(shelfObjects) do
        GlobalState:set("HD-SO-" .. dismantleId, {}, true)
        for boneName, objectData in pairs(objects) do
            if objectData[1] and DoesEntityExist(objectData[1]) then
                DeleteEntity(objectData[1])
            end
        end
    end

    -- Limpar states dos lobbies
    for lobbyId, lobby in pairs(activeDismantles) do
        local playerPed = GetPlayerPed(lobbyId)
        if playerPed then
            Entity(playerPed).state:set("dismantleLobby", nil, true)
        end
    end
end)
