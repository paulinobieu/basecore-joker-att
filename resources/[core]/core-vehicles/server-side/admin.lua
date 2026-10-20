-- ------------------------------------------------
-- # Admin / CVM
-- ------------------------------------------------

createAdminVehicle = function(src,characterId,model)

    if not CL.isValidModel(src,model) then
        notify(src,'VEHICLE_UNAVAILABLE')
        return
    end

    if parkingVehicle[src] then
        notify(src,'COOLDOWN')
        return
    end
    parkingVehicle[src] = true
    
    local spawnPos = CL.getAdminSpawnPos(src)
    local rentalPlate,rentalMods = false,{}
    if fixed_rental_plates then
        rentalPlate,rentalMods = getServiceVehicleData(characterId,model)
    else
        rentalPlate = generateNewPlate()
    end
    if not rentalPlate then
        notify(src,'INVALID_IDENTITY')
        parkingVehicle[src] = false
        return { error = 1 }
    end
    local entity,networkVehicle = createNetVehicle(rentalPlate,model,spawnPos,characterId,not fixed_rental_plates)
    if networkVehicle then
        if GetResourceState("core-bennys") == "started" and exports["core-bennys"]:HasTuning(rentalPlate) then
            exports["core-bennys"]:ApplyStoredTuning(networkVehicle,rentalPlate)
        else
            CL._applyVehicleMods(-1,networkVehicle,rentalMods)
        end
        parkingVehicle[src] = false
        SetPedIntoVehicle(GetPlayerPed(src),entity,-1)
    end
    parkingVehicle[src] = false

    local _log = 'Vehicle spawned.\n```prolog\n[STAFF]: '..characterId..'\n[VEHICLE]: '..model..'\n[PLATE]: '..rentalPlate..'\n[COORDS]: '..spawnPos[1]..','..spawnPos[2]..','..spawnPos[3]..'\n```'
    _LOG(logsWebhooks['spawnVehicles'],_log)

end

-- ------------------------------------------------
-- # CVM Functions
-- ------------------------------------------------

SV.cvmTryRemove = function(plate)
    local src = source
    local characterId = getCharacterId(src)
    if characterId and plate and hasPermission(characterId,commands['characterVehManager']['permission']) then
        local vehicleData = getVehicleData(plate)
        if not vehicleData then
            notify(src,'VEHICLE_NOT_FOUND')
            return { error = 1 }
        end
        local networkVehicle,entityCoords = getNetVehicle(vehicleData.plate,vehicleData.index)
        if networkVehicle then
            deleteNetVehicle(networkVehicle)
        end
        local _log = 'Vehicle removed from character.\n```prolog\n[STAFF]: '..characterId..'\n[TARGET ID]: '..vehicleData.owner..'\n[VEHICLE]: '..vehicleData.index..'\n[PLATE]: '..plate..'\n[EXPIRE_TIME]: '..vehicleData.expire_time..'\n```'
        _LOG(logsWebhooks['characterVehManager'],_log)
        deleteVehicle(vehicleData.plate)
        notify(src,'CVM_DELETED')
        return { success = 1 }
    end
    notify(src,'INVALID_IDENTITY')
    return { error = 1 }
end

SV.cvmTryFind = function(plate)
    local src = source
    local characterId = getCharacterId(src)
    if characterId and plate and hasPermission(characterId,commands['characterVehManager']['permission']) then
        local vehicleData = getVehicleData(plate)
        if not vehicleData then
            notify(src,'VEHICLE_NOT_FOUND')
            return { error = 1 }
        end
        local networkVehicle,entityCoords = getNetVehicle(vehicleData.plate,vehicleData.index)
        if networkVehicle and entityCoords then
            notify(src,'CVM_TELEPORTED_TO')
            return { success = 1, coords = entityCoords }
        end
        notify(src,'CVM_PARKED_IN')
        return { error = 1 }
    end
    notify(src,'INVALID_IDENTITY')
    return { error = 1 }
end

SV.cvmTryRenew = function(plate,days)
    local src = source
    local characterId = getCharacterId(src)
    if characterId and plate and hasPermission(characterId,commands['characterVehManager']['permission']) then
        local vehicleData = getVehicleData(plate)
        if not vehicleData then
            notify(src,'VEHICLE_NOT_FOUND')
            return { error = 1 }
        end
        days = parseInt(days)
        if days <= 0 or days > 30 then
            notify(src,'INVALID_DAYS_AMOUNT')
            return { error = 1 }
        end
        local success,_newTime = updateRentalVehicleDays(plate,days)
        if success then
            local _log = 'Vehicle renewed for character.\n```prolog\n[STAFF]: '..characterId..'\n[TARGET ID]: '..vehicleData.owner..'\n[VEHICLE]: '..vehicleData.index..'\n[PLATE]: '..plate..'\n[DAYS]: '..days..'\n```'
            _LOG(logsWebhooks['characterVehManager'],_log)
            notify(src,'CVM_RENEWED')
            return { success = 1, newTime = _newTime }
        end
        notify(src,'UNKNOWN_ERROR')
        return { error = 1 }
    end
    notify(src,'INVALID_IDENTITY')
    return { error = 1 }
end

SV.cvmTryRemoveAll = function(targetCharacterId)
    local src = source
    local characterId = getCharacterId(src)
    if not characterId or not targetCharacterId or not hasPermission(characterId, commands['characterVehManager']['permission']) then
        return { error = 1 }
    end

    targetCharacterId = tonumber(targetCharacterId)
    if not targetCharacterId then return { error = 1 } end

    local userVehicles = getCharacterVehicles(targetCharacterId, true) or {}
    local removed = 0
    local removedPlates = {}

    for plate, vdata in pairs(userVehicles) do
        if plate and vdata and vdata.index then
            local networkVehicle = getNetVehicle(plate, vdata.index)
            if networkVehicle then
                deleteNetVehicle(networkVehicle)
            end
            deleteVehicle(plate)
            removedPlates[#removedPlates + 1] = plate
            removed = removed + 1
        end
    end

    if removed > 0 then
        local _log = 'TODOS os veiculos removidos do personagem.\n```prolog\n[STAFF]: '..characterId..'\n[TARGET ID]: '..targetCharacterId..'\n[REMOVED]: '..removed..'\n[PLATES]: '..table.concat(removedPlates, ', ')..'\n```'
        _LOG(logsWebhooks['characterVehManager'], _log)
        notify(src, 'CVM_DELETED')
        return { success = 1, removed = removed }
    end

    return { error = 1, message = 'O personagem nao possui veiculos.' }
end

SV.cvmTryAdd = function(id,model,days,plate)

    local src = source
    local characterId = getCharacterId(src)
    if id and model and hasPermission(characterId,commands['characterVehManager']['permission']) then

        id = parseInt(id)
        if id <= 0 then
            notify(src,'INVALID_ID')
            return { error = 1  }
        end

        local days = parseInt(days)

        local vehicleInfo = getVehicleInfo(GetHashKey(model))
        if not vehicleInfo then
            notify(src,'CVM_VEHICLE_NOT_REGISTERED')
            return { error = 1  }
        end

        local validPlate = nil
        if plate and type(plate) == 'string' and plate:gsub(' ','') ~= '' then
            plate = plate:gsub('[%p%c]','')
            plate = plate:gsub(' ','')
            plate = plate:upper()
            if plate:match('%W') ~= nil then
                notify(src,'INVALID_PLATE')
                return { error = 1 }
            end
            if plate:len() <= 0 or plate:len() > 8 then
                notify(src,'INVALID_PLATE')
                return { error = 1 }
            end
            local resultPlate = getVehicleData(plate)
            if resultPlate then
                notify(src,'PLATE_IN_USE')
                return { error = 1 }
            end
            validPlate = plate
        end

        if days <= 0 then

            local succs,result = generateVehicle(id,vehicleInfo.index,{{255,255,255},{0,0,0}},validPlate)
            if succs then
                local _generatedPlate,_generatedVehicleData = false,false
                local cVehicles = getCharacterVehicles(id)
                if cVehicles[result] then
                    _generatedPlate = result
                    _generatedVehicleData = cloneTable(cVehicles[result])
                    for kInfo,kValue in pairs(vehicleInfo) do
                        _generatedVehicleData[kInfo] = kValue
                    end
                end
                local _log = 'Vehicle generated for character.\n```prolog\n[STAFF]: '..characterId..'\n[TARGET ID]: '..id..'\n[VEHICLE]: '..vehicleInfo.index..'\n[PLATE]: '.._generatedPlate..'\n[DURATION]: PERMANENT\n```'
                _LOG(logsWebhooks['characterVehManager'],_log)
                notify(src,'CVM_ADDED')
                return { success = true, plate = _generatedPlate, nvdata = _generatedVehicleData }
            end

            _vehiclesVPrint('Error while generating vehicle -> ID: '..characterId..' | TARGET ID: '..id..' | RESULT:\n'..result)
            notify(src,'UNKNOWN_ERROR')
            return { error = 1 }

        else

            local hasRented,vehicleRentalPlate,vehicleRentalExpireTime = hasVehicleModelRented(id,vehicleInfo.index)
    
            if hasRented and vehicleRentalExpireTime >= os.time() then
                notify(src,'CVM_MODEL_ALREADY_RENTED')
                return { error = 1 }
            end
    
            local _generatedPlate,_generatedVehicleData = false,false
            if not hasRented then
                local succs,result = generateRentalVehicle(id,vehicleInfo.index,days)
                if succs then
                    notify(src,'CVM_ADDED')
                    local cVehicles = getCharacterVehicles(id)
                    if cVehicles[result] then
                        _generatedPlate = result
                        _generatedVehicleData = cloneTable(cVehicles[result])
                        for kInfo,kValue in pairs(vehicleInfo) do
                            _generatedVehicleData[kInfo] = kValue
                        end
                    end
                    local _log = 'Vehicle generated for character.\n```prolog\n[STAFF]: '..characterId..'\n[TARGET ID]: '..id..'\n[VEHICLE]: '..vehicleInfo.index..'\n[PLATE]: '.._generatedPlate..'\n[DURATION]: '..days..' DAYS\n```'
                    _LOG(logsWebhooks['characterVehManager'],_log)
                    return { success = true, plate = _generatedPlate, nvdata = _generatedVehicleData }
                else
                    _vehiclesVPrint('Error while generating vehicle -> ID: '..characterId..' | TARGET ID: '..id..' | RESULT:\n'..result)
                    notify(src,'UNKNOWN_ERROR')
                    return { error = 1 }
                end
            else
                forceLoadVehicleByPlate(vehicleRentalPlate)
                local success,newTime = updateRentalVehicleDays(vehicleRentalPlate,days)
                if success then
                    local cVehicles = getCharacterVehicles(id)
                    if cVehicles[vehicleRentalPlate] then
                        _generatedPlate = vehicleRentalPlate
                        _generatedVehicleData = cloneTable(cVehicles[vehicleRentalPlate])
                        for kInfo,kValue in pairs(vehicleInfo) do
                            _generatedVehicleData[kInfo] = kValue
                        end
                    end
                    local _log = 'Vehicle (re)generated for character.\n```prolog\n[STAFF]: '..characterId..'\n[TARGET ID]: '..id..'\n[VEHICLE]: '..vehicleInfo.index..'\n[PLATE]: '.._generatedPlate..'\n[DURATION]: '..days..' DAYS\n```'
                    _LOG(logsWebhooks['characterVehManager'],_log)
                    notify(src,'CVM_ADDED')
                    return { success = true, plate = _generatedPlate, nvdata = _generatedVehicleData }
                else
                    _vehiclesVPrint('Error while generating vehicle -> ID: '..characterId..' | TARGET ID: '..id..' | RESULT:\n'..result)
                    notify(src,'UNKNOWN_ERROR')
                    return { error = 1 }
                end
            end
    
        end

    end

    notify(src,'INVALID_IDENTITY')
    return { error = 1 }
    
end
