local Config = require 'config.main'
PlayerNails = {}
PreviewNails = {}
TableBusy = {}

lib.callback.register(Scriptname .. ':server:isTableBusy', function(source, studioIndex, tableIndex)
    if not source then return false end

    local studio = Config.NailStudios[studioIndex]
    if not studio then return false end

    local table = studio.tables[tableIndex]
    if not table or not table.customer.coords then return false end

    local customerCoords = vector3(table.customer.coords.x, table.customer.coords.y, table.customer.coords.z)
    local playerId = lib.getClosestPlayer(customerCoords, 1.0, false)
    if not playerId then return false end

    local busy = TableBusy[studioIndex] and TableBusy[studioIndex][tableIndex]

    if busy and playerId ~= source then
        return true
    end

    return false
end)

-- ██████╗ ███████╗███████╗ █████╗ ██╗   ██╗██╗  ████████╗    ███████╗██╗   ██╗███████╗███╗   ██╗████████╗███████╗
-- ██╔══██╗██╔════╝██╔════╝██╔══██╗██║   ██║██║  ╚══██╔══╝    ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
-- ██║  ██║█████╗  █████╗  ███████║██║   ██║██║     ██║       █████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║   ███████╗
-- ██║  ██║██╔══╝  ██╔══╝  ██╔══██║██║   ██║██║     ██║       ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ╚════██║
-- ██████╔╝███████╗██║     ██║  ██║╚██████╔╝███████╗██║       ███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████║
-- ╚═════╝ ╚══════╝╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝       ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝

AddEventHandler(Scriptname .. ":server:OnPlayerLoaded", function(src)
    local playerId = src or source
    if not playerId then return end
    Wait(2000)

    Debug('info', 'Player %d loaded, loading nail data', playerId)

    local Player = Framework.GetPlayer(playerId)
    if not Player then
        Debug('warning', 'Player object not found for player %d', playerId)
        return
    end

    local nailData = LoadOrCreatePlayerNailData(playerId)
    SetPlayerNails(playerId, nailData)

    if nailData and next(nailData) then
        TriggerClientEvent(Scriptname .. ':client:createNailDesign', -1, playerId, nailData)
    end

    for k, v in pairs(PlayerNails) do
        if tonumber(k) == playerId then
            goto continue
        end

        local TargetPlayer = Framework.GetPlayer(tonumber(k))

        if not TargetPlayer then
            goto continue
        end

        if not v or not next(v) then
            goto continue
        end

        TriggerClientEvent(Scriptname .. ':client:createNailDesign', playerId, tonumber(k), v)

        ::continue::
    end
    Debug('success', 'Nail data loaded for player %d', playerId)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    Debug('info', 'Resource %s started, loading nail data for online players', resource)
    Wait(1500)

    local loadedCount = 0
    for _, playerId in pairs(Framework.GetPlayers()) do
        playerId = tonumber(playerId)
        if not playerId or playerId == 0 then goto continue end

        local nailData, exists = LoadPlayerNailDataFromDB(playerId)
        if exists and nailData then
            SetPlayerNails(playerId, nailData)
            loadedCount = loadedCount + 1

            if not nailData or not next(nailData) then
                Debug('info', 'No nail data to load for player %d', playerId)
                goto continue
            end

            TriggerClientEvent(Scriptname .. ':client:createNailDesign', -1, playerId, nailData)
        end
        ::continue::
    end
    Debug('success', 'Loaded nail data for %d player(s)', loadedCount)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for k, v in pairs(GetPlayers()) do
            local playerId = tonumber(v)
            if not playerId or playerId == 0 then goto continue end
            local ped = GetPlayerPed(playerId)

            Entity(ped).state:set('nailData', {}, true)
            ::continue::
        end
    end
end)

-- ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗     ███████╗██╗   ██╗███████╗███╗   ██╗████████╗███████╗
-- ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗    ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
-- ███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝    █████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║   ███████╗
-- ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗    ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ╚════██║
-- ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║    ███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████║
-- ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝    ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝

RegisterNetEvent(Scriptname .. ':server:setBusyTable', function(studioIndex, tableIndex, isBusy)
    local playerId = source
    if not playerId then return end

    Debug('info', 'Player %d setting busy state for studio %d table %d to %s', playerId, studioIndex, tableIndex, tostring(isBusy))

    TableBusy[studioIndex] = TableBusy[studioIndex] or {}
    TableBusy[studioIndex][tableIndex] = isBusy and playerId or nil
end)

RegisterNetEvent(Scriptname .. ':server:inviteCustomerById', function(targetId, studioIndex, tableIndex)
    local studio = Config.NailStudios[studioIndex]
    if not studio then
        Debug('error', 'Studio index %d not found for invitation', studioIndex)
        Notify.SendNotify(source, _T("notify.studio_not_found"), 'error', 5000)
        return
    end

    local table = studio.tables[tableIndex]
    if not table or not table.customer.coords then
        Debug('error', 'Table index %d not found in studio %d for invitation', tableIndex, studioIndex)
        Notify.SendNotify(source, _T("notify.table_not_found"), 'error', 5000)
        return
    end

    local customerCoords = vector3(table.customer.coords.x, table.customer.coords.y, table.customer.coords.z)
    local playerId = lib.getClosestPlayer(customerCoords, 1.0, false)
    if playerId and playerId ~= source then
        Debug('warning', 'Player %d attempted to invite to occupied table %d in studio %d', source, tableIndex, studioIndex)
        Notify.SendNotify(source, _T("notify.table_occupied"), 'error', 5000)
        return
    end

    local busy = TableBusy[studioIndex] and TableBusy[studioIndex][tableIndex]

    if busy and playerId ~= source then
        Notify.SendNotify(source, _T("notify.table_occupied"), 'error', 5000)
        Debug('warning', 'Player %d attempted to invite to busy table %d in studio %d', source, tableIndex, studioIndex)
        return
    end

    local targetPed = GetPlayerPed(targetId)
    local myped = GetPlayerPed(source)
    if not targetPed or not myped then
        Debug('error', 'Invalid ped for source %d or target %d during invitation', source, targetId)
        Notify.SendNotify(source, _T("notify.invitation_failed"), 'error', 5000)
        return
    end

    local distance = #(GetEntityCoords(myped) - GetEntityCoords(targetPed))
    if distance > 3.0 then
        Debug('warning', 'Player %d is too far from target %d to send invitation (distance: %.2f)', source, targetId, distance)
        Notify.SendNotify(source, _T("notify.too_far_for_invitation"), 'error', 5000)
        return
    end

    TriggerClientEvent(Scriptname .. ':client:receiveInvitation', targetId, studioIndex, tableIndex, source)
    Debug('success', 'Invitation sent to player %d for studio %d table %d by player %d', targetId, studioIndex, tableIndex, source)
end)

RegisterNetEvent(Scriptname .. ':server:declineInvitation', function(studioIndex, tableIndex, jobberId)
    local playerId = source
    if not playerId then return end

    Debug('info', 'Player %d declined invitation to studio %d table %d', playerId, studioIndex, tableIndex)
    Notify.SendNotify(jobberId, _T("notify.invitation_declined"), 'info', 5000)
end)

RegisterNetEvent(Scriptname .. ':server:joinStudioSession', function(studioIndex, tableIndex, jobberId)
    local playerId = source
    if not playerId then return end

    Debug('info', 'Player %d joining studio %d table %d session', playerId, studioIndex, tableIndex)

    local studio = Config.NailStudios[studioIndex]
    if not studio then
        Debug('error', 'Studio index %d not found for player %d joining session', studioIndex, playerId)
        Notify.SendNotify(playerId, _T("notify.studio_not_found"), 'error', 5000)
        return
    end

    local table = studio.tables[tableIndex]
    if not table or not table.customer.coords then
        Debug('error', 'Table index %d not found in studio %d for player %d joining session', tableIndex, studioIndex, playerId)
        Notify.SendNotify(playerId, _T("notify.table_not_found"), 'error', 5000)
        return
    end

    TriggerClientEvent(Scriptname .. ':client:enterStudioSession', jobberId, studioIndex, tableIndex)
    Debug('success', 'Player %d entered studio %d table %d session', playerId, studioIndex, tableIndex)
end)

RegisterNetEvent(Scriptname .. ':server:requestPlayerNailData', function(coords)
    local playerId = source
    if not playerId then return end

    Debug('info', 'Player %d requested their nail data', playerId)

    local customerId = lib.getClosestPlayer(vector3(coords.x, coords.y, coords.z), 1.5, false)
    if not customerId then
        Debug('warning', 'No customer found near coords for player %d', playerId)
        return
    end

    local nailData = GetPlayerNailData(customerId) or {}

    if not nailData or not next(nailData) then
        Debug('info', 'No nail data found for player %d', customerId)
        return
    end
    UpdatePlayerPreviewNails(customerId, nailData)

    TriggerClientEvent(Scriptname .. ':client:previewNailDesign', -1, customerId, nailData)

    Debug('success', 'Nail design applied and previewed for customer %d', customerId)
end)

RegisterNetEvent(Scriptname .. ':server:previewNailDesign', function(coords, data)
    if not source then return end

    local playerId = source

    Debug('info', 'Player %d applying nail design', playerId)

    local customerId = lib.getClosestPlayer(vector3(coords.x, coords.y, coords.z), 1.5, false)
    if not customerId then
        Debug('warning', 'No customer found near coords for player %d', playerId)
        return
    end

    UpdatePlayerPreviewNails(customerId, data)
    TriggerClientEvent(Scriptname .. ':client:previewNailDesign', -1, customerId, data)
    Debug('success', 'Nail design applied and previewed for customer %d', customerId)
end)

RegisterNetEvent(Scriptname .. ':server:clearFingerDesign', function(coords, fingerId, hand)
    if not source then return end

    local playerId = source

    Debug('info', 'Player %d clearing finger design', playerId)

    local customerId = lib.getClosestPlayer(vector3(coords.x, coords.y, coords.z), 1.5, false)
    if not customerId then
        Debug('warning', 'No customer found near coords for player %d', playerId)
        return
    end

    ClearPlayerPreviewFingerDesign(customerId, fingerId, hand)
    TriggerClientEvent(Scriptname .. ':client:clearFingerDesign', -1, customerId, fingerId, hand)
    Debug('success', 'Finger design cleared for customer %d', customerId)
end)

RegisterNetEvent(Scriptname .. ':server:clearPedTask', function(coords)
    local playerId = source
    if not playerId then return end

    local customerId = lib.getClosestPlayer(vector3(coords.x, coords.y, coords.z), 1.5, false)
    if not customerId then
        Debug('warning', 'No customer found to clear ped task for player %d', playerId)
        return
    end

    Debug('info', 'Clearing ped task for customer %d', customerId)
    TriggerClientEvent(Scriptname .. ':client:clearPedTask', customerId)
end)

RegisterNetEvent(Scriptname .. ':server:clearNailDesign', function()
    local playerId = source
    if not playerId then return end

    Debug('info', 'Clearing nail design for player %d', playerId)
    ClearPlayerNails(playerId)
    Debug('success', 'Nail design cleared for player %d', playerId)
end)

RegisterNetEvent(Scriptname .. ':server:saveNailDesign', function(coords)
    local playerId = source
    if not playerId then return end

    Debug('info', 'Player %d saving nail design', playerId)

    local customerId = lib.getClosestPlayer(vector3(coords.x, coords.y, coords.z), 1.5, false)
    if not customerId then
        Debug('warning', 'No customer found to save nail design for player %d', playerId)
        return
    end

    local identifier = Framework.GetPlayerIdentifier(customerId)
    if not identifier then
        Debug('error', 'Failed to get identifier for customer %d', customerId)
        return
    end

    local nailData = GetPlayerPreviewNailData(customerId)
    ClearPreviewNailDesign(customerId)
    UpdatePlayerNails(customerId, nailData)

    MySQL.query.await([[
        INSERT INTO `nailshop` (identifier, nail_data) 
        VALUES (?, ?) 
        ON DUPLICATE KEY UPDATE nail_data = VALUES(nail_data)
    ]], { identifier, json.encode(nailData) })

    if not nailData or not next(nailData) then
        TriggerClientEvent(Scriptname .. ':client:deleteNailDesign', -1, customerId)
        return
    end

    TriggerClientEvent(Scriptname .. ':client:createNailDesign', -1, customerId, nailData)
    Debug('success', 'Nail design saved to database for customer %d', customerId)
end)

RegisterNetEvent(Scriptname .. ':server:restoreNailDesign', function(coords)
    local playerId = source
    if not playerId then return end

    Debug('info', 'Player %d restoring nail design', playerId)

    local customerId = lib.getClosestPlayer(vector3(coords.x, coords.y, coords.z), 1.5, false)
    if not customerId then
        Debug('warning', 'No customer found to restore nail design for player %d', playerId)
        return
    end

    local nailData = LoadOrCreatePlayerNailData(customerId)
    SetPlayerNails(customerId, nailData)
    ClearPreviewNailDesign(customerId)

    if not nailData or not next(nailData) then
        TriggerClientEvent(Scriptname .. ':client:deleteNailDesign', -1, customerId)
        return
    end

    TriggerClientEvent(Scriptname .. ':client:createNailDesign', -1, customerId, nailData)
    Debug('success', 'Nail design restored for customer %d', customerId)
end)

RegisterNetEvent(Scriptname .. ':server:onPedChanged', function()
    local playerId = source
    if not playerId then return end

    Debug('info', 'Ped changed for player %d, reloading nail data', playerId)
    local nailData = LoadOrCreatePlayerNailData(playerId)
    SetPlayerNails(playerId, nailData)
    Debug('success', 'Nail data reloaded for player %d', playerId)
end)