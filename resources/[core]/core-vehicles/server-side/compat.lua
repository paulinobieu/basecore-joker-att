-- ------------------------------------------------
-- # Backward Compatibility: garages Tunnel
-- ------------------------------------------------

local GaragesCompat = {}
r_tunnel.bindInterface('garages',GaragesCompat)

function GaragesCompat.ServerVehicle(Model,Coords,Plate,Nitro,Doors,Body,Fuel,Seatbelt,Drift)
    if not Model or not Coords then
        return false
    end

    local CurrentTimer = os.time() + 10
    local modelHash = type(Model) == 'number' and Model or GetHashKey(Model)
    local Vehicle = CreateVehicle(modelHash,Coords.x,Coords.y,Coords.z,Coords.w or 0.0,true,false)

    while not DoesEntityExist(Vehicle) or NetworkGetNetworkIdFromEntity(Vehicle) == 0 do
        if os.time() >= CurrentTimer then
            return false
        end
        Wait(100)
    end

    Plate = Plate or generateNewPlate()
    SetVehicleNumberPlateText(Vehicle,Plate)
    SetVehicleBodyHealth(Vehicle,(Body or 1000) + 0.0)

    if Doors then
        local Decoded = json.decode(Doors)
        if type(Decoded) == 'table' then
            for Number,Broken in pairs(Decoded) do
                if Broken then
                    SetVehicleDoorBroken(Vehicle,parseInt(Number),true)
                end
            end
        end
    end

    -- Callers legados passam 0 nesta posição, e `0 or 100` continua 0 em Lua.
    -- Com o tanque zerado o sistema de combustível desliga o motor a cada frame
    -- e o veículo não anda. Veículo recém-criado nunca nasce sem combustível.
    local FuelLevel = tonumber(Fuel) or 0.0
    if FuelLevel <= 0.0 then
        FuelLevel = 100.0
    end

    local State = Entity(Vehicle).state
    -- Marca como veículo de script. Sem isto o bloqueio de veículo de NPC no
    -- client trata tudo que vem por aqui (fuelstations, empregos, etc) como
    -- carro de NPC e deixa o motor desligado.
    State:set('veh-mods',true,true)
    State:set('Nitro',Nitro or 0,true)
    State:set('Fuel',FuelLevel,true)
    State:set('Drift',Drift or false,true)
    State:set('Seatbelt',Seatbelt or false,true)

    return true,NetworkGetNetworkIdFromEntity(Vehicle),Vehicle,Plate
end

function GaragesCompat.Delete(Network,Doors,Tyres,Plate,Save)
    if Network then
        deleteNetVehicle(Network)
    end
end

-- ------------------------------------------------
-- # Backward Compatibility: garages events
-- ------------------------------------------------

RegisterServerEvent('garages:Key')
AddEventHandler('garages:Key',function(entityData)
    local src = source
    local characterId = getCharacterId(src)
    if not characterId then
        return false
    end

    local Plate = (entityData[1] or ''):gsub(' ','')
    local Network = entityData[4]
    local Entitys = NetworkGetEntityFromNetworkId(Network)
    if not DoesEntityExist(Entitys) then
        return false
    end

    local State = Entity(Entitys).state
    if State and State.Lockpick == characterId then
        vRP.GiveItem(characterId,'vehiclekey-'..os.time()..'-'..Plate,1,true)
    end
end)

RegisterServerEvent('garages:Delete')
AddEventHandler('garages:Delete',function(netEntity,plate)
    if netEntity then
        deleteNetVehicle(netEntity)
    end
end)

RegisterServerEvent('garages:Deleted')
AddEventHandler('garages:Deleted',function(netEntity,plate)
    if netEntity then
        deleteNetVehicle(netEntity)
    end
end)

RegisterServerEvent('garages:LockVehicle')
AddEventHandler('garages:LockVehicle',function(src,networkVehicle)
    if networkVehicle then
        local vehicle = NetworkGetEntityFromNetworkId(networkVehicle)
        if vehicle and DoesEntityExist(vehicle) and GetEntityType(vehicle) == 2 then
            local lockState = GetVehicleDoorLockStatus(vehicle)
            if lockState <= 1 then
                SetVehicleDoorsLocked(vehicle,2)
                TriggerClientEvent('Notify',src,'Aviso','Veículo trancado.','default',5000)
            else
                SetVehicleDoorsLocked(vehicle,1)
                TriggerClientEvent('Notify',src,'Aviso','Veículo destrancado.','default',5000)
            end
            CL.vehicleLockToggle(-1,networkVehicle)
        end
    end
end)

RegisterServerEvent('garages:ChangePlate')
AddEventHandler('garages:ChangePlate',function(oldPlate,newPlate)
    changeVehiclePlateIRT(oldPlate,newPlate)
end)

RegisterServerEvent('garages:Lock')
AddEventHandler('garages:Lock',function(networkVehicle)
    local src = source
    if networkVehicle then
        local vehicle = NetworkGetEntityFromNetworkId(networkVehicle)
        if vehicle and DoesEntityExist(vehicle) and GetEntityType(vehicle) == 2 then
            local plate = GetVehicleNumberPlateText(vehicle):gsub(' ','')
            local characterId = getCharacterId(src)
            if characterId then
                local vehicleData = getVehicleData(plate)
                if vehicleData then
                    local hasPermission = (vehicleData.owner == characterId or getVehicleBorrowed(plate) == characterId)
                    if hasPermission then
                        local lockState = GetVehicleDoorLockStatus(vehicle)
                        if lockState <= 1 then
                            SetVehicleDoorsLocked(vehicle,2)
                        else
                            SetVehicleDoorsLocked(vehicle,1)
                        end
                        CL.vehicleLockToggle(-1,networkVehicle)
                    end
                else
                    local cVehicles = GlobalState['core-cVehicles']
                    if cVehicles and cVehicles[plate] and cVehicles[plate].owner == characterId then
                        local lockState = GetVehicleDoorLockStatus(vehicle)
                        if lockState <= 1 then
                            SetVehicleDoorsLocked(vehicle,2)
                        else
                            SetVehicleDoorsLocked(vehicle,1)
                        end
                        CL.vehicleLockToggle(-1,networkVehicle)
                    end
                end
            end
        end
    end
end)
