SV = {}
CL = nil
r_tunnel = _G["lib-tunnel"]()

r_tunnel.bindInterface(GetCurrentResourceName(), SV)
CreateThread(function()
    CL = r_tunnel.getInterface(GetCurrentResourceName())
end)

-- ------------------------------------------------
-- # State Variables
-- ------------------------------------------------

outPersonalVehicles = {}
parkingVehicle = {}
trackerCooldown = {}
dealerStock = {}
dealerOutStock = {}

mech_invoices = {}
mech_invoices_datas = {}
mech_invoices_calls = {}
mech_invoices_payments = {}
g_forms = {}

-- ------------------------------------------------
-- # Initialization
-- ------------------------------------------------

CreateThread(function()
    while loadingData do
        Wait(100)
    end


    _vehiclesVPrint('^5Data loaded. ^0Setting up stock...')

    local stockResult = query('SELECT * FROM `core_vehicles_stock`;')
    if stockResult and type(stockResult) == 'table' then
        for _, v in pairs(stockResult) do
            dealerStock[v.index] = v.stock
        end
    end
    GlobalState:set('core-dStock', dealerStock, true)

    for _, cmd in pairs(commands) do
        if cmd.enabled then
            RegisterCommand(cmd.name, function(src, args, rc)
                if src == 0 then
                    return
                end
                local characterId = getCharacterId(src)
                if not characterId then
                    return
                end
                if cmd.permission and not hasPermission(characterId, cmd.permission) then
                    return
                end
                if cmd.name == commands['spawnVehicles']['name'] then
                    local model = args[1]
                    if model then
                        createAdminVehicle(src, characterId, model)
                    end
                elseif cmd.name == commands['despawnVehicles']['name'] then
                    local networkVehicle, plate, health, damages, model, coords = CL.getNearestVehicleForDespawn(src)
                    if networkVehicle then
                        updateVehicleHealth(plate, health, damages)
                        deleteNetVehicle(networkVehicle)
                    end
                elseif cmd.name == commands['despawnAreaVehicles']['name'] then
                    local vehicles = CL.getNearestVehiclesForDespawn(src, 50)
                    if vehicles then
                        for _, v in pairs(vehicles) do
                            if v[1] then
                                updateVehicleHealth(v[2], v[3], v[4])
                                deleteNetVehicle(v[1])
                            end
                        end
                    end
                elseif cmd.name == commands['fixVehicles']['name'] then
                    CL.fixVehicle(src)
                elseif cmd.name == commands['characterVehManager']['name'] then
                    local targetId = args[1]
                    if targetId then
                        targetId = parseInt(targetId)
                        local vehicles = getCharacterVehicles(targetId, false) or {}
                        CL.openCharacterVehManager(src, targetId, vehicles)
                    end
                elseif cmd.name == commands['stockManager']['name'] then
                    CL.openStockManager(src)
                elseif cmd.name == commands['garageManager']['name'] then
                    CL.openGarageManager(src)
                end
            end)
        end
    end

    _vehiclesVPrint('^5Initialization ^0complete.')
end)

-- ------------------------------------------------
-- # Dealer Stock
-- ------------------------------------------------

getDealerVehicleStock = function(vehicleIndex)
    do
        return dealerStock[vehicleIndex] or nil
    end
end

setDealerVehicleStock = function(vehicleIndex, stock)
    stock = parseInt(stock)
    dealerStock[vehicleIndex] = stock
    GlobalState:set('core-dStock', dealerStock, true)
    -- Persiste no banco (fonte de verdade). Sem isto o estoque so vivia em
    -- memoria/GlobalState e se perdia em restart. Placeholders `?` reais
    -- (seguro), como em vehicle-register.lua/garage-manager.lua.
    exports.oxmysql:execute(
        'INSERT INTO `core_vehicles_stock` (`index`, `stock`) VALUES (?, ?) ON DUPLICATE KEY UPDATE `stock` = VALUES(`stock`)',
        { vehicleIndex, stock }
    )
end

SV.tryUpdateDealerVehicleStock = function(index, stock)
    local src = source
    local characterId = getCharacterId(src)
    if characterId and hasPermission(characterId, commands['stockManager']['permission']) then
        setDealerVehicleStock(index, parseInt(stock))
        return { success = true, newStock = parseInt(stock) }
    end
    return { success = false }
end

-- ------------------------------------------------
-- # External Garages
-- ------------------------------------------------

local externalGarages = {}
local externalGet = {}

SV.getExternalGarages = function()
    local src = source
    if not externalGet[src] then
        externalGet[src] = true
        return externalGarages
    end
end

AddEventHandler('playerDropped', function(reason)
    local src = source
    if externalGet[src] then
        externalGet[src] = nil
    end
end)

insertGarage = function(garage)
    local _garage = {
        name = garage.name or 'Garagem',
        permission = garage.permission or nil,
        type = garage.type or 'NORMAL',
        open = garage.open,
        spawns = garage.spawns,
        propertyId = garage.propertyId or nil,
        propertyType = garage.propertyType or nil,
        payment = tonumber(garage.payment) or 0,
        freePaymentPermission = garage.freePaymentPermission or nil,
        blip = garage.blip or nil,
        marker = garage.marker or nil,
        vehicles = garage.vehicles or nil
    }
    local gId = #garages + 1
    garages[gId] = _garage
    externalGarages[gId] = _garage
    CL.insertGarage(-1, gId, _garage)
    return gId
end
exports('insertGarage', insertGarage)

removeGarage = function(gId)
    gId = tonumber(gId)
    if not gId then return false end
    if not garages[gId] then return false end
    garages[gId] = nil
    externalGarages[gId] = nil
    CL.removeGarage(-1, gId)
    return true
end
exports('removeGarage', removeGarage)

-- Versão "leve": apenas registra no server (não dispara broadcast tunnel).
-- Útil para integrações via StateBag onde o cliente já tem a fonte de verdade.
registerGarage = function(garage)
    local _garage = {
        name = garage.name or 'Garagem',
        permission = garage.permission or nil,
        type = garage.type or 'NORMAL',
        open = garage.open,
        spawns = garage.spawns,
        propertyId = garage.propertyId or nil,
        propertyType = garage.propertyType or nil,
        payment = tonumber(garage.payment) or 0,
        freePaymentPermission = garage.freePaymentPermission or nil,
        blip = garage.blip or nil,
        marker = garage.marker or nil,
        vehicles = garage.vehicles or nil
    }
    local gId = #garages + 1
    garages[gId] = _garage
    return gId
end
exports('registerGarage', registerGarage)

unregisterGarage = function(gId)
    gId = tonumber(gId)
    if not gId or not garages[gId] then return false end
    garages[gId] = nil
    return true
end
exports('unregisterGarage', unregisterGarage)

-- ------------------------------------------------
-- # Net Vehicle Management
-- ------------------------------------------------

deleteNetVehicle = function(netEntity)
    local entity = NetworkGetEntityFromNetworkId(netEntity)
    if entity and DoesEntityExist(entity) and GetEntityType(entity) == 2 then
        local plate = (GetVehicleNumberPlateText(entity) or ''):gsub(' ', '')
        local state = GlobalState['core-cVehicles']
        if state and type(state) == 'table' and plate ~= '' and state[plate] then
            state[plate] = nil
            GlobalState:set('core-cVehicles', state, false)
        end
        DeleteEntity(entity)
    end
end

createNetVehicle = function(plate, model, coords, ownerId, mechBlocked)
    if plate and model and coords then
        local modelHash = GetHashKey(model)
        local t = 0
        local entity = CreateVehicle(modelHash, coords[1], coords[2], coords[3], coords[4], true, true)
        while not DoesEntityExist(entity) and t <= 1000 do
            t = t + 1
            Wait(100)
        end
        if DoesEntityExist(entity) then
            if mechBlocked then
                Entity(entity).state:set('mechBlocked', true, false)
            end
            Entity(entity).state:set('veh-mods', true, true)
            if ownerId then
                Entity(entity).state:set('Lockpick', ownerId, true)
            end
            onVehicleCreation(entity, modelHash, plate)
            SetVehicleDoorsLocked(entity, 2)
            SetVehicleNumberPlateText(entity, plate)
            local netEntity = NetworkGetNetworkIdFromEntity(entity)
            local state = GlobalState['core-cVehicles']
            if not state then
                state = {}
            end
            state[plate] = { id = netEntity, model = modelHash, owner = ownerId }
            GlobalState:set('core-cVehicles', state, false)
            return entity, netEntity
        end
    end
    return false
end

getNetVehicle = function(plate)
    if not plate then return false, false end
    local state = GlobalState['core-cVehicles']
    if state and type(state) == 'table' and state[plate] and type(state[plate]) == 'table' then
        local entity = NetworkGetEntityFromNetworkId(state[plate].id)
        local model = state[plate].model
        if entity and DoesEntityExist(entity) and GetEntityType(entity) == 2 then
            local _plate = (GetVehicleNumberPlateText(entity) or ''):gsub(' ', '')
            local _model = GetEntityModel(entity)
            if _plate == plate and _model == model then
                return state[plate].id, GetEntityCoords(entity)
            end
        end
    end
    return false, false
end
exports('getNetVehicle', getNetVehicle)

-- ------------------------------------------------
-- # AI Vehicle Hotwire
-- ------------------------------------------------
-- Libera o motor de um veículo de NPC depois que o player passa no minigame de
-- fios (wiregame). A gravação fica no servidor porque o client não pode escrever
-- a State Bag sozinho: exige estar no volante e o veículo não ser de player.

local hotwireRequests = {}

AddEventHandler('playerDropped', function()
    hotwireRequests[source] = nil
end)

SV.hotwireAIVehicle = function(networkVehicle)
    local src = source
    if not getCharacterId(src) then
        return false
    end

    local now = GetGameTimer()
    if hotwireRequests[src] and now < hotwireRequests[src] then
        return false
    end
    hotwireRequests[src] = now + 3000

    if not networkVehicle then
        return false
    end

    local entity = NetworkGetEntityFromNetworkId(networkVehicle)
    if not entity or not DoesEntityExist(entity) or GetEntityType(entity) ~= 2 then
        return false
    end

    if GetPedInVehicleSeat(entity, -1) ~= GetPlayerPed(src) then
        return false
    end

    local state = Entity(entity).state
    if state['veh-mods'] ~= nil then
        return false
    end

    state:set('Hotwire', getCharacterId(src), true)
    return true
end

-- ------------------------------------------------
-- # Vehicle Owner
-- ------------------------------------------------

getVehicleOwnerByPlate = function(plate)
    if plate then
        plate = plate:gsub(' ', '')
        local state = GlobalState['core-cVehicles']
        if state and type(state) == 'table' and state[plate] then
            return state[plate].owner or nil
        end
    end
    return nil
end
SV.getVehicleOwnerByPlate = getVehicleOwnerByPlate
exports('getVehicleOwnerByPlate', getVehicleOwnerByPlate)

-- ------------------------------------------------
-- # Verbose Print
-- ------------------------------------------------

function _vehiclesVPrint(text)
    if vehiclesVerbose then
        print('^5[M] ^0-> ' .. text .. '^0')
    end
end

-- ------------------------------------------------
-- # Sync Vehicle Menu Item
-- ------------------------------------------------

RegisterServerEvent('core/vehicles/syncVehMenuItem')
AddEventHandler('core/vehicles/syncVehMenuItem', function(vehicleNetId, item)
    TriggerClientEvent('core/vehicles/vMenuItem', -1, vehicleNetId, item)
end)

-- ------------------------------------------------
-- # Apply Vehicle Mods Export
-- ------------------------------------------------

exports('applyVehicleMods', function(networkVehicle, mods)
    if type(networkVehicle) == 'number' and type(mods) == 'table' then
        CL._applyVehicleMods(-1, networkVehicle, mods)
    end
end)
