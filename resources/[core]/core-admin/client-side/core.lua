local PanelOpen    = false
local AdminGodMode = false
local AdminNoclip  = false
local SpectateId   = nil
local OriginalCoords = nil

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES NUI
-----------------------------------------------------------------------------------------------------------------------------------------
local function SendInterfaceMessage(action, data)
    SendNUIMessage({ action = action, data = data })
end

local function ShowPanel(show)
    PanelOpen = show
    SetNuiFocus(show, show)
    if show then
        SendInterfaceMessage("setColors", Config.Colors)
    end
    SendInterfaceMessage("setVisible", show)

    if show then
        TriggerServerEvent("core-admin:getNotifications")
        TriggerServerEvent("core-admin:getOnlinePlayers")
        TriggerServerEvent("core-admin:getChatMessages")
        TriggerServerEvent("core-admin:getUserInfo")
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- COMANDOS / EVENTOS ABRIR PAINEL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-admin:openPanel", function()
    ShowPanel(true)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI CALLBACKS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("hideFrame", function(_, cb)
    ShowPanel(false)
    cb("ok")
end)

-- AVISOS
RegisterNUICallback("getNotifications", function(_, cb)
    TriggerServerEvent("core-admin:getNotifications")
    cb("ok")
end)

RegisterNUICallback("createNotification", function(data, cb)
    TriggerServerEvent("core-admin:createNotification", data)
    cb("ok")
end)

RegisterNUICallback("deleteNotification", function(data, cb)
    TriggerServerEvent("core-admin:deleteNotification", data.id)
    cb("ok")
end)

RegisterNUICallback("editNotification", function(data, cb)
    TriggerServerEvent("core-admin:editNotification", data)
    cb("ok")
end)

-- ANÚNCIOS
RegisterNUICallback("createAnnouncement", function(data, cb)
    TriggerServerEvent("core-admin:createAnnouncement", data)
    cb("ok")
end)

-- JOGADORES
RegisterNUICallback("getPlayers", function(data, cb)
    local searchTerm = ""
    if type(data) == "string" then
        searchTerm = data
    elseif type(data) == "table" and data.searchTerm then
        searchTerm = data.searchTerm
    end
    TriggerServerEvent("core-admin:getPlayers", searchTerm)
    cb("ok")
end)

RegisterNUICallback("getPlayerDetails", function(data, cb)
    local id = data
    if type(data) == "table" then id = data.playerId or data.id end
    TriggerServerEvent("core-admin:getPlayerDetails", id)
    cb("ok")
end)

RegisterNUICallback("teleportPlayer", function(data, cb)
    TriggerServerEvent("core-admin:teleportToPlayer", data.playerId or data.id)
    cb("ok")
end)

RegisterNUICallback("pullPlayer", function(data, cb)
    TriggerServerEvent("core-admin:pullPlayer", data.playerId or data.id)
    cb("ok")
end)

RegisterNUICallback("revivePlayer", function(data, cb)
    TriggerServerEvent("core-admin:revivePlayer", data.playerId or data.id)
    cb("ok")
end)

RegisterNUICallback("killPlayer", function(data, cb)
    TriggerServerEvent("core-admin:killPlayer", data.playerId or data.id)
    cb("ok")
end)

RegisterNUICallback("godPlayer", function(data, cb)
    TriggerServerEvent("core-admin:godPlayer", data.playerId or data.id)
    cb("ok")
end)

RegisterNUICallback("armorPlayer", function(data, cb)
    TriggerServerEvent("core-admin:armorPlayer", data.playerId or data.id)
    cb("ok")
end)

RegisterNUICallback("kickPlayer", function(data, cb)
    TriggerServerEvent("core-admin:kickPlayer", data.playerId or data.id)
    cb("ok")
end)

RegisterNUICallback("banPlayer", function(data, cb)
    TriggerServerEvent("core-admin:kickPlayer", data.playerId or data.id)
    cb("ok")
end)

-- WHITELIST
RegisterNUICallback("removeWhitelist", function(data, cb)
    TriggerServerEvent("core-admin:removeWhitelist", data.playerId or data.id)
    cb("ok")
end)

RegisterNUICallback("removePlayerWhitelist", function(data, cb)
    TriggerServerEvent("core-admin:removeWhitelist", data.playerId or data.id)
    cb("ok")
end)

RegisterNUICallback("addWhitelist", function(data, cb)
    TriggerServerEvent("core-admin:addWhitelist", data.playerId or data.id)
    cb("ok")
end)

-- AÇÕES EXTRAS DE JOGADORES

RegisterNUICallback("giveMoneyToPlayer", function(data, cb)
    TriggerServerEvent("core-admin:addBank", data.playerId or data.id, data.amount or 0)
    cb("ok")
end)

RegisterNUICallback("fixPlayerVehicle", function(data, cb)
    TriggerServerEvent("core-admin:fixVehicle")
    cb("ok")
end)

RegisterNUICallback("tunePlayerVehicle", function(data, cb)
    TriggerServerEvent("core-admin:fixVehicle")
    cb("ok")
end)

RegisterNUICallback("sendItemToPlayer", function(data, cb)
    TriggerServerEvent("core-admin:takeItem", data.item, data.quantity or 1)
    cb("ok")
end)

-- TELEPORT CDS
RegisterNUICallback("teleportCDS", function(data, cb)
    TriggerServerEvent("core-admin:teleportCDS", data.cds)
    cb("ok")
end)

-- BAÚS
RegisterNUICallback("getChests", function(_, cb)
    TriggerServerEvent("core-admin:getChests")
    cb("ok")
end)

RegisterNUICallback("getCurrentCoords", function(_, cb)
    local coords = GetEntityCoords(PlayerPedId())
    cb({ x = coords.x, y = coords.y, z = coords.z })
end)

RegisterNUICallback("createChest", function(data, cb)
    local payload = data or {}
    if not payload.coords then
        local coords = GetEntityCoords(PlayerPedId())
        payload.coords = { x = coords.x, y = coords.y, z = coords.z }
    end
    TriggerServerEvent("core-admin:createChest", payload)
    cb("ok")
end)

RegisterNUICallback("updateChest", function(data, cb)
    TriggerServerEvent("core-admin:updateChest", data)
    cb("ok")
end)

RegisterNUICallback("deleteChest", function(data, cb)
    TriggerServerEvent("core-admin:deleteChest", data.id)
    cb("ok")
end)

-- Modo de seleção de posição (raycast a partir da câmera)
local PlacementActive = false

RegisterNUICallback("selectChestPosition", function(_, cb)
    if PlacementActive then cb("ok") return end
    PlacementActive = true

    -- Esconde painel temporariamente sem chamar ShowPanel (mantém estado React)
    PanelOpen = false
    SetNuiFocus(false, false)
    SendInterfaceMessage("setVisible", false)

    cb("ok")

    CreateThread(function()
        local function restorePanel()
            PlacementActive = false
            PanelOpen = true
            SetNuiFocus(true, true)
            SendInterfaceMessage("setVisible", true)
        end

        while PlacementActive do
            local ped = PlayerPedId()
            local cam = GetGameplayCamCoord()
            local rot = GetGameplayCamRot(2)
            local pitch = math.rad(rot.x)
            local yaw   = math.rad(rot.z)
            local dir = vector3(
                -math.sin(yaw) * math.cos(pitch),
                math.cos(yaw)  * math.cos(pitch),
                math.sin(pitch)
            )
            local endPos = cam + dir * 75.0

            local ray = StartShapeTestRay(cam.x, cam.y, cam.z, endPos.x, endPos.y, endPos.z, -1, ped, 0)
            local _, hit, hitCoords = GetShapeTestResult(ray)

            local target = nil
            if hit ~= 0 then
                target = hitCoords
            else
                target = endPos
            end

            -- marker no chão
            DrawMarker(
                28,
                target.x, target.y, target.z,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                0.4, 0.4, 0.4,
                0, 200, 120, 180,
                false, false, 2, false, nil, nil, false
            )

            -- HUD text simples
            SetTextScale(0.4, 0.4)
            SetTextFont(4)
            SetTextProportional(1)
            SetTextColour(255, 255, 255, 255)
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString("[E] Confirmar  ~r~[X] Cancelar")
            DrawText(0.5, 0.92)

            DisableControlAction(0, 142, true)
            DisableControlAction(0, 18, true)

            if IsControlJustPressed(0, 38) then -- E
                SendInterfaceMessage("chestPositionSelected", {
                    x = target.x + 0.0,
                    y = target.y + 0.0,
                    z = target.z + 0.0,
                })
                restorePanel()
                return
            elseif IsControlJustPressed(0, 73) then -- X
                SendInterfaceMessage("chestPositionSelected", nil)
                restorePanel()
                return
            end

            Wait(0)
        end
    end)
end)

RegisterNUICallback("teleportToChest", function(data, cb)
    TriggerServerEvent("core-admin:teleportToChest", data.id)
    cb("ok")
end)

-- VEÍCULOS
RegisterNUICallback("getServerVehicles", function(data, cb)
    TriggerServerEvent("core-admin:getServerVehicles", data.page, data.limit, data.searchTerm, data.category)
    cb("ok")
end)

RegisterNUICallback("spawnVehicle", function(data, cb)
    local spawn = data.spawn
    if data.vehicle and data.vehicle.spawn then
        spawn = data.vehicle.spawn
    end
    TriggerServerEvent("core-admin:spawnVehicle", spawn)
    cb("ok")
end)

RegisterNetEvent("core-admin:executeSpawn")
AddEventHandler("core-admin:executeSpawn", function(model)
    if not model or model == "" then return end

    local mHash = GetHashKey(model)
    if not IsModelInCdimage(mHash) or not IsModelAVehicle(mHash) then
        TriggerServerEvent("core-admin:vehicleSpawned", model, nil)
        return
    end

    RequestModel(mHash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(mHash) and GetGameTimer() < timeout do
        Wait(10)
    end

    if not HasModelLoaded(mHash) then
        SetModelAsNoLongerNeeded(mHash)
        TriggerServerEvent("core-admin:vehicleSpawned", model, nil)
        return
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local veh = CreateVehicle(mHash, coords.x, coords.y, coords.z + 0.5, heading, true, false)
    SetModelAsNoLongerNeeded(mHash)

    if not DoesEntityExist(veh) then
        TriggerServerEvent("core-admin:vehicleSpawned", model, nil)
        return
    end

    local plate = "ADM" .. math.random(10000, 99999)
    SetVehicleNumberPlateText(veh, plate)
    SetPedIntoVehicle(ped, veh, -1)

    -- O resource 'engine' depende do Entity().state.Fuel; sem isso a thread
    -- de consumo desliga o motor porque CurrentFuel é nil. Como SetPedIntoVehicle
    -- não dispara CEventNetworkPlayerEnteredVehicle, setamos manualmente.
    Entity(veh).state:set("Fuel", 100.0, true)
    -- Marca o veiculo como "unlocked" pra bypassar o lockAIVehicle do core-vehicles
    -- (threads.lua linha 159) que desliga o motor de qualquer carro nao-marcado
    -- quando o player entra naturalmente via CEventNetworkPlayerEnteredVehicle.
    Entity(veh).state:set("unlocked", true, true)
    SetVehicleFuelLevel(veh, 100.0)
    SetVehicleNeedsToBeHotwired(veh, false)
    SetPedConfigFlag(ped, 35, false)
    SetVehicleUndriveable(veh, false)
    SetVehicleEngineOn(veh, true, true, false)
    SetVehicleEngineHealth(veh, 1000.0)
    SetVehicleBodyHealth(veh, 1000.0)
    SetVehicleOnGroundProperly(veh)

    TriggerServerEvent("core-admin:vehicleSpawned", model, plate)
end)

RegisterNUICallback("addVehicleToUser", function(data, cb)
    local spawn = data.spawn
    if data.vehicle and data.vehicle.spawn then
        spawn = data.vehicle.spawn
    end
    TriggerServerEvent("core-admin:addVehicleToUser", spawn, data.userId, data.duration)
    cb("ok")
end)

RegisterNUICallback("fixVehicle", function(_, cb)
    TriggerServerEvent("core-admin:fixVehicle")
    cb("ok")
end)

RegisterNUICallback("tuningVehicle", function(_, cb)
    TriggerServerEvent("core-admin:tuningVehicle")
    cb("ok")
end)

RegisterNUICallback("destroyAllVehicles", function(_, cb)
    TriggerServerEvent("core-admin:destroyAllVehicles")
    cb("ok")
end)

-- ITENS
RegisterNUICallback("getServerItems", function(_, cb)
    TriggerServerEvent("core-admin:getServerItems")
    cb("ok")
end)

RegisterNUICallback("takeItem", function(data, cb)
    TriggerServerEvent("core-admin:takeItem", data.item, data.quantity)
    cb("ok")
end)

-- ORGANIZAÇÕES
RegisterNUICallback("getServerOrganizations", function(_, cb)
    TriggerServerEvent("core-admin:getServerOrganizations")
    cb("ok")
end)

RegisterNUICallback("getOrganizationMembers", function(data, cb)
    TriggerServerEvent("core-admin:getOrganizationMembers", data.groupName)
    cb("ok")
end)

-- STAFF
RegisterNUICallback("getServerStaff", function(_, cb)
    TriggerServerEvent("core-admin:getServerStaff")
    cb("ok")
end)

RegisterNUICallback("promoteStaff", function(data, cb)
    TriggerServerEvent("core-admin:promoteStaff", data.targetUserId, data.currentGroup, data.newGroup)
    cb("ok")
end)

RegisterNUICallback("removeStaff", function(data, cb)
    TriggerServerEvent("core-admin:removeStaff", data.targetUserId, data.currentGroup)
    cb("ok")
end)

-- PROPRIEDADES
RegisterNUICallback("getProperties", function(_, cb)
    TriggerServerEvent("core-admin:getProperties")
    cb("ok")
end)

RegisterNUICallback("teleportToProperty", function(data, cb)
    TriggerServerEvent("core-admin:teleportToProperty", data.name)
    cb("ok")
end)

RegisterNUICallback("updateProperty", function(data, cb)
    TriggerServerEvent("core-admin:updateProperty", data)
    cb("ok")
end)

RegisterNUICallback("removeProperty", function(data, cb)
    TriggerServerEvent("core-admin:removeProperty", data)
    cb("ok")
end)

-- (Garagens migradas para o comando /gmanager no core-vehicles)

-- CHAT ADMIN
RegisterNUICallback("sendChatMessage", function(data, cb)
    TriggerServerEvent("core-admin:sendChatMessage", data.message)
    cb("ok")
end)

RegisterNUICallback("getChatMessages", function(_, cb)
    TriggerServerEvent("core-admin:getChatMessages")
    cb("ok")
end)

-- JOGADORES ONLINE
RegisterNUICallback("getOnlinePlayers", function(_, cb)
    TriggerServerEvent("core-admin:getOnlinePlayers")
    cb("ok")
end)

-- INFO DO USUÁRIO
RegisterNUICallback("getUserInfo", function(_, cb)
    TriggerServerEvent("core-admin:getUserInfo")
    cb("ok")
end)

-- DADOS DO SERVIDOR
RegisterNUICallback("getServerData", function(_, cb)
    TriggerServerEvent("core-admin:getServerData")
    cb("ok")
end)

-- SPECTATE
RegisterNUICallback("spectatePlayer", function(data, cb)
    local targetId = tonumber(data.playerId or data.id)
    if not targetId then cb("ok") return end

    if SpectateId then
        local ped = PlayerPedId()
        SpectateId = nil
        NetworkSetInSpectatorMode(false, 0)
        if OriginalCoords then
            SetEntityCoords(ped, OriginalCoords.x, OriginalCoords.y, OriginalCoords.z)
            OriginalCoords = nil
        end
        cb("ok")
        return
    end

    local serverId = GetPlayerFromServerId(targetId)
    if serverId ~= 0 then
        local ped        = PlayerPedId()
        OriginalCoords   = GetEntityCoords(ped)
        local targetPed  = GetPlayerPed(serverId)
        SpectateId       = targetId
        local tCoords    = GetEntityCoords(targetPed)
        SetEntityCoords(ped, tCoords.x, tCoords.y, tCoords.z)
        NetworkSetInSpectatorMode(true, targetPed)
    end
    cb("ok")
end)

-- NOCLIP
RegisterNUICallback("toggleNoclip", function(_, cb)
    AdminNoclip = not AdminNoclip
    cb("ok")
end)

-- GODMODE
RegisterNUICallback("toggleGodMode", function(_, cb)
    AdminGodMode = not AdminGodMode
    local ped    = PlayerPedId()
    SetEntityInvincible(ped, AdminGodMode)
    cb("ok")
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTOS DO SERVIDOR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-admin:receiveNotifications", function(data)
    SendInterfaceMessage("receiveNotifications", data)
end)

RegisterNetEvent("core-admin:newNotification", function(data)
    SendInterfaceMessage("newNotification", data)
end)

RegisterNetEvent("core-admin:notificationDeleted", function(id)
    SendInterfaceMessage("notificationDeleted", id)
end)

RegisterNetEvent("core-admin:notificationUpdated", function(data)
    SendInterfaceMessage("notificationUpdated", data)
end)

RegisterNetEvent("core-admin:notificationResult", function(data)
    SendInterfaceMessage("notificationResult", data)
end)

RegisterNetEvent("core-admin:announcementResult", function(data)
    SendInterfaceMessage("announcementResult", data)
end)

RegisterNetEvent("core-admin:receiveOnlinePlayers", function(data)
    SendInterfaceMessage("receiveOnlinePlayers", data)
end)

RegisterNetEvent("core-admin:requestServerData", function()
    local pedCount     = 0
    local vehicleCount = 0
    local objectCount  = 0

    for _, ped in pairs(GetGamePool("CPed")) do
        if DoesEntityExist(ped) then pedCount = pedCount + 1 end
    end
    for _, veh in pairs(GetGamePool("CVehicle")) do
        if DoesEntityExist(veh) then vehicleCount = vehicleCount + 1 end
    end
    for _, obj in pairs(GetGamePool("CObject")) do
        if DoesEntityExist(obj) then objectCount = objectCount + 1 end
    end

    TriggerServerEvent("core-admin:receiveClientServerData", {
        peds     = pedCount,
        vehicles = vehicleCount,
        objects  = objectCount,
    })
end)

RegisterNetEvent("core-admin:receiveServerData", function(data)
    SendInterfaceMessage("receiveServerData", data)
end)

RegisterNetEvent("core-admin:receivePlayers", function(data)
    SendInterfaceMessage("receivePlayers", data)
end)

RegisterNetEvent("core-admin:receivePlayerDetails", function(data)
    SendInterfaceMessage("receivePlayerDetails", data)
end)

RegisterNetEvent("core-admin:receiveServerVehicles", function(data)
    SendInterfaceMessage("receiveServerVehicles", data)
end)

RegisterNetEvent("core-admin:receiveServerItems", function(data)
    SendInterfaceMessage("receiveServerItems", data)
end)

RegisterNetEvent("core-admin:receiveServerOrganizations", function(data)
    SendInterfaceMessage("receiveServerOrganizations", data)
end)

RegisterNetEvent("core-admin:receiveOrganizationMembers", function(data)
    SendInterfaceMessage("receiveOrganizationMembers", data)
end)

RegisterNetEvent("core-admin:receiveServerStaff", function(data)
    SendInterfaceMessage("receiveServerStaff", data)
end)

RegisterNetEvent("core-admin:receiveChatMessages", function(data)
    SendInterfaceMessage("receiveChatMessages", data)
end)

RegisterNetEvent("core-admin:receiveChatMessage", function(data)
    SendInterfaceMessage("receiveChatMessage", data)
end)

RegisterNetEvent("core-admin:setCurrentUserId", function(userId)
    SendInterfaceMessage("setCurrentUserId", userId)
end)

RegisterNetEvent("core-admin:receiveUserInfo", function(data)
    SendInterfaceMessage("receiveUserInfo", data)
end)

RegisterNetEvent("core-admin:receiveChests", function(data)
    SendInterfaceMessage("receiveChests", data)
end)

RegisterNetEvent("core-admin:receiveProperties", function(data)
    SendInterfaceMessage("receiveProperties", data)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- AÇÕES LOCAIS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-admin:setEntityHealth", function(value)
    local ped = PlayerPedId()
    SetEntityHealth(ped, value)
end)

RegisterNetEvent("core-admin:setEntityArmour", function(value)
    local ped = PlayerPedId()
    SetPedArmour(ped, value)
end)

RegisterNetEvent("core-admin:repairVehicle", function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh and veh ~= 0 then
        SetVehicleFixed(veh)
        SetVehicleEngineHealth(veh, 1000.0)
        SetVehicleBodyHealth(veh, 1000.0)
        SetVehiclePetrolTankHealth(veh, 1000.0)
    end
end)

RegisterNetEvent("core-admin:tuneVehicle", function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh and veh ~= 0 then
        SetVehicleModKit(veh, 0)
        for i = 0, 48 do
            local max = GetNumVehicleMods(veh, i)
            if max > 0 then
                SetVehicleMod(veh, i, max - 1, false)
            end
        end
    end
end)

RegisterNetEvent("core-admin:destroyVehicles", function()
    for _, veh in pairs(GetGamePool("CVehicle")) do
        if DoesEntityExist(veh) then
            local driver = GetPedInVehicleSeat(veh, -1)
            if driver == 0 or not IsEntityAPed(driver) or not IsPedAPlayer(driver) then
                SetEntityAsMissionEntity(veh, true, true)
                DeleteEntity(veh)
            end
        end
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- NOCLIP THREAD
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    local noclipSpeed = 1.0
    local wasNoclip = false
    while true do
        if AdminNoclip then
            wasNoclip = true
            local ped = PlayerPedId()
            SetEntityCollision(ped, false, false)
            FreezeEntityPosition(ped, true)
            SetEntityVisible(ped, false, false)

            local camRot = GetGameplayCamRot(2)
            local fwd    = vector3(
                -math.sin(math.rad(camRot.z)) * math.cos(math.rad(camRot.x)),
                math.cos(math.rad(camRot.z)) * math.cos(math.rad(camRot.x)),
                math.sin(math.rad(camRot.x))
            )
            local pos    = GetEntityCoords(ped)
            local newPos = pos

            if IsControlPressed(0, 32) then newPos = newPos + fwd * noclipSpeed end
            if IsControlPressed(0, 33) then newPos = newPos - fwd * noclipSpeed end
            if IsControlPressed(0, 21) then noclipSpeed = 3.0 else noclipSpeed = 1.0 end

            SetEntityCoordsNoOffset(ped, newPos.x, newPos.y, newPos.z)
            Wait(0)
        else
            if wasNoclip then
                wasNoclip = false
                local ped = PlayerPedId()
                SetEntityVisible(ped, true, false)
                SetEntityCollision(ped, true, true)
                FreezeEntityPosition(ped, false)
            end
            Wait(500)
        end
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- ESC FECHAR PAINEL
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    while true do
        if PanelOpen then
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 18, true)
            DisableControlAction(0, 322, true)
            DisableControlAction(0, 106, true)
            Wait(0)
        else
            Wait(500)
        end
    end
end)
