-- ------------------------------------------------
-- # Garages
-- ------------------------------------------------

local _notify = notify
local function notify(src, msgKey, extras) _notify(src, msgKey, extras, 'Garagem') end

local favoriteCooldowns = {}

AddEventHandler('Disconnect', function(Passport)
    favoriteCooldowns[Passport] = nil
end)

SV.setVehicleFavorite = function(plate, favorite)
    local src = source
    local characterId = getCharacterId(src)
    if not characterId or type(plate) ~= 'string' or type(favorite) ~= 'boolean' then
        return { error = 'INVALID_PARAMS' }
    end

    local now = GetGameTimer()
    if favoriteCooldowns[characterId] and favoriteCooldowns[characterId] > now then
        return { error = 'COOLDOWN' }
    end
    favoriteCooldowns[characterId] = now + 500

    local success, result = updateVehicleFavorite(characterId, plate, favorite)
    if not success then
        return { error = result }
    end

    return { success = true, favorite = result }
end

SV.getGarageData = function(garageId,isPropertyGarage)

    local src = source
    local characterId = getCharacterId(src)

    if characterId and garageId and garages[garageId] then

        local garageData = garages[garageId]

        if garageData.permission then
            if type(garageData.permission) == 'table' or (type(garageData.permission) == 'string' and garageData.permission:gsub(' ','') ~= '') then
                if not hasPermission(characterId,garageData.permission) then
                    return false
                end
            end
        elseif garageData.type == 'PROPERTY' then
            if not hasPropertyPermission(src,characterId,garageData.propertyId,garageData.propertyType) then
                return false
            end
        end

        if garageData.type == 'NORMAL' or garageData.type == 'PROPERTY' or garageData.type == 'AIR' or garageData.type == 'WATER' then

            local characterVehicles = getCharacterVehicles(characterId,true)
            local vehicles = {}
            local validVehicles = garages_types[garageData.type] or {}
            for plate,vdata in pairs(characterVehicles) do
                if validVehicles[vdata.category] then
                    vehicles[plate] = vdata
                end
            end

            return { type = 'NORMAL', myVehicles = vehicles }

        elseif garageData.type == 'SERVICE' then

            local vehicles = {}
            for k,v in pairs(garageData.vehicles) do
                vehicles[k] = {
                    index = k,
                    price = v,
                    name = getVehicleName(k)
                }
            end

            if isEmptyTable(vehicles) then
                return false
            end
            
            return { type = 'SERVICE', myVehicles = vehicles }

        end
        
    end

    return false

end

SV.parkVehicle = function(action,identifier,_type,garageId)
    local src = source
    local characterId = getCharacterId(src)
    if parkingVehicle[src] then
        notify(src,'COOLDOWN')
        return { error = 1 }
    end
    if not garageId then
        notify(src,'GARAGE_UNAVAILABLE')
        return { error = 1 }
    end
    local currentGarageData = garages[garageId] or nil
    if not currentGarageData then
        notify(src,'GARAGE_UNAVAILABLE')
        return { error = 1 }
    end
    if characterId then
        if action == 'OUT' then
            if _type == 'personal' or _type == 'property' then
                local plate = identifier:gsub(' ','')
                local vehicleData = getVehicleData(plate)
                if not vehicleData then
                    notify(src,'VEHICLE_NOT_FOUND')
                    return { error = 1 }
                end
                local vehicleInfo = getVehicleInfo(vehicleData.index)
                if not vehicleInfo then
                    notify(src,'VEHICLE_NOT_FOUND')
                    return { error = 1 }
                end
                local taxesVerifiy = canParkOutVehicle(src,characterId,vehicleData,vehicleInfo)
                if taxesVerifiy and type(taxesVerifiy) == 'table' then
                    taxesVerifiy.plate = vehicleData.plate
                    g_forms[src] = taxesVerifiy
                    return { form = { title = taxesVerifiy.title, description = taxesVerifiy.description } } 
                end
                local hasVehiclePermission = false
                if vehicleData.owner == characterId or getVehicleBorrowed(plate) == characterId then
                    hasVehiclePermission = true
                end
                if not hasVehiclePermission then
                    notify(src,'NOT_YOUR_VEHICLE')
                    return { error = 1 }
                end
                if not CL.isValidModel(src,vehicleData.index) then
                    notify(src,'VEHICLE_UNAVAILABLE')
                    return { error = 1 }
                end
                local ftr = src
                if ftr > 1000 then
                    ftr = ftr / 1000
                end
                if ftr < 10 then
                    ftr = ftr + math.random(3,5)
                end
                local delay = (ftr + math.random(200,999))
                Wait(delay)
                if getNetVehicle(vehicleData.plate,vehicleData.index) then
                    notify(src,'VEHICLE_ALREADY_OUT')
                    return { error = 1 }
                end
                local spawnPos = CL.getFreeGarageSpawn(src)
                if spawnPos then
                    local g_payment = parseInt(currentGarageData.payment)
                    if g_payment > 0 then
                        local paid = false
                        if currentGarageData.freePaymentPermission and hasPermission(characterId,currentGarageData.freePaymentPermission) then
                            paid = true
                        end
                        if not paid then
                            paid = true -- removeCurrency(characterId,g_payment)
                        end
                        if not paid then
                            notify(src,'GARAGE_PAYMENT_NEEDED',{ ['@value'] = formatCurrency(g_payment) })
                            return { error = 1 }
                        end
                    end
                    parkingVehicle[src] = true
                    local entity,networkVehicle = createNetVehicle(vehicleData.plate,vehicleData.index,spawnPos,characterId,false)
                    if networkVehicle then
                        parkingVehicle[src] = false
                        local _health,_damages = getVehicleHealth(vehicleData.plate)
                        local _mods = getVehicleMods(vehicleData.plate)
                        local _bennys = GetResourceState("core-bennys") == "started" and exports["core-bennys"]:HasTuning(vehicleData.plate)
                        if setupCharacterVehicle and type(setupCharacterVehicle) == 'function' then
                            setupCharacterVehicle(src,characterId,networkVehicle,vehicleData.index,vehicleData.plate,spawnPos,_bennys and {} or _mods,_health,_damages)
                        else
                            async(function()
                                CL.setupVehicle(-1,networkVehicle,{ h = _health, d = _damages, m = _bennys and {} or _mods })
                            end)
                        end
                        if _bennys then
                            exports["core-bennys"]:ApplyStoredTuning(networkVehicle,vehicleData.plate)
                        end
                        notify(src,'VEHICLE_PARKED_OUT')
                        return { success = true }
                    end
                    parkingVehicle[src] = false
                else
                    notify(src,'SPACE_UNAVAILABLE')
                    return { error = 1 }
                end
                notify(src,'VEHICLE_UNAVAILABLE')
                return { error = 1 }
            elseif _type == 'rental' then
                local vehiclePrice = nil
                if currentGarageData.vehicles and currentGarageData.vehicles[identifier] ~= nil then
                    vehiclePrice = currentGarageData.vehicles[identifier]
                end
                if vehiclePrice == nil then
                    notify(src,'VEHICLE_UNAVAILABLE')
                    return { error = 1 }
                end
                local state = GlobalState['core-rVehicles']
                if type(state) ~= 'table' then state = {} end
                if type(state[characterId]) ~= 'table' then
                    state[characterId] = {}
                end
                local existingPlate = state[characterId][identifier]
                if existingPlate and getNetVehicle(existingPlate,identifier) then
                    notify(src,'ALREADY_RENTED')
                    return { error = 1 }
                end
                if not CL.isValidModel(src,identifier) then
                    notify(src,'VEHICLE_UNAVAILABLE')
                    return { error = 1 }
                end
                local spawnPos = CL.getFreeGarageSpawn(src)
                if spawnPos then
                    local paid = true
                    if vehiclePrice then
                        paid = removeCurrency(characterId,parseInt(vehiclePrice))
                    end
                    if not paid then
                        notify(src,'MONEY_NOT_ENOUGH')
                        return { error = 1}
                    end
                    parkingVehicle[src] = true
                    local rentalPlate,rentalMods = false,{}
                    if fixed_rental_plates then
                        rentalPlate,rentalMods = getServiceVehicleData(characterId,identifier)
                    else
                        rentalPlate = generateNewPlate()
                    end
                    if not rentalPlate then
                        notify(src,'INVALID_IDENTITY')
                        parkingVehicle[src] = false
                        return { error = 1 }
                    end
                    local entity,networkVehicle = createNetVehicle(rentalPlate,identifier,spawnPos,characterId,not fixed_rental_plates)
                    if networkVehicle then
                        if GetResourceState("core-bennys") == "started" and exports["core-bennys"]:HasTuning(rentalPlate) then
                            exports["core-bennys"]:ApplyStoredTuning(networkVehicle,rentalPlate)
                        else
                            CL._applyVehicleMods(-1,networkVehicle,rentalMods)
                        end
                        state[characterId][identifier] = rentalPlate
                        GlobalState:set('core-rVehicles',state,false)
                        parkingVehicle[src] = false
                        notify(src,'VEHICLE_PARKED_OUT')
                        return { success = true }
                    end
                    parkingVehicle[src] = false
                else
                    notify(src,'SPACE_UNAVAILABLE')
                    return { error = 1 }
                end
                notify(src,'VEHICLE_UNAVAILABLE')
                return { error = 1 }
            end
        elseif action == 'IN' then
            if _type == 'personal' or _type == 'property' then
                local plate = identifier:gsub(' ','')
                local vehicleData = getVehicleData(plate)
                if not vehicleData then
                    notify(src,'VEHICLE_NOT_FOUND')
                    return { error = 1 }
                end
                local hasVehiclePermission = false
                if vehicleData.owner == characterId or getVehicleBorrowed(plate) == characterId then
                    hasVehiclePermission = true
                end
                if not hasVehiclePermission then
                    notify(src,'NOT_YOUR_VEHICLE')
                    return { error = 1 }
                end
                local networkVehicle,entityCoords = getNetVehicle(vehicleData.plate,vehicleData.index)
                if networkVehicle then
                    if #(vector3(currentGarageData.open[1],currentGarageData.open[2],currentGarageData.open[3])-entityCoords) > 30 then
                        notify(src,'VEHICLE_TOO_FAR')
                        return { error = 1 }
                    end
                    updateVehicleHealth(vehicleData.plate,table.unpack({CL.getVehicleHealth(src,networkVehicle)}))
                    deleteNetVehicle(networkVehicle)
                    notify(src,'VEHICLE_PARKED_IN')
                    return { success = true }
                else
                    notify(src,'VEHICLE_ALREADY_IN')
                    return { error = 1 }
                end
                notify(src,'VEHICLE_UNAVAILABLE')
                return { error = 1 }
            elseif _type == 'rental' then
                local vehicleInfo = nil
                if currentGarageData.vehicles and currentGarageData.vehicles[identifier] then
                    vehicleInfo = currentGarageData.vehicles[identifier]
                end
                if not vehicleInfo then
                    notify(src,'VEHICLE_NOT_FOUND')
                    return { error = 1 }
                end
                local state = GlobalState['core-rVehicles']
                if type(state) ~= 'table' then state = {} end
                local userRentals = type(state[characterId]) == 'table' and state[characterId] or nil
                if userRentals and userRentals[identifier] then
                    local rentalPlate = userRentals[identifier]
                    local networkVehicle,entityCoords = getNetVehicle(rentalPlate,identifier)
                    if networkVehicle then
                        if #(vector3(currentGarageData.open[1],currentGarageData.open[2],currentGarageData.open[3])-entityCoords) > 30 then
                            notify(src,'VEHICLE_TOO_FAR')
                            return { error = 1 }
                        end
                        deleteNetVehicle(networkVehicle)
                        userRentals[identifier] = nil
                        GlobalState:set('core-rVehicles',state,false)
                        notify(src,'VEHICLE_PARKED_IN')
                        return { success = true }
                    else
                        notify(src,'NOT_RENTED')
                        return { error = 1 }
                    end
                end
                notify(src,'VEHICLE_UNAVAILABLE')
                return { error = 1 }
            end
        end
        notify(src,'INVALID_ACTION')
        return { error = 1 }
    end
    notify(src,'INVALID_IDENTITY')
    return { error = 1 }
end

SV.trackVehicle = function(identifier,_type)

    local src = source
    local characterId = getCharacterId(src)

    if characterId and identifier and _type then

        if trackerCooldown[characterId] and trackerCooldown[characterId] > os.time() then
            return { error = 'Aguarde para utilizar o <b>Rastreio</b> novamente.' }
        end
        trackerCooldown[characterId] = os.time() + 120

        if _type == 'personal' then

            local plate = identifier:gsub(' ','')
            local vehicleData = getVehicleData(plate)
            if vehicleData then

                local hasVehiclePermission = false
                if vehicleData.owner == characterId or getVehicleBorrowed(plate) == characterId then
                    hasVehiclePermission = true
                end
                if hasVehiclePermission then
                    local networkVehicle,entityCoords = getNetVehicle(vehicleData.plate,vehicleData.index)
                    if networkVehicle then
                        return { pos = entityCoords, name = vehicleData.name }
                    end
                end

            end

        elseif _type == 'rental' then

        end

    end

    return { error = 'Veículo não encontrado.' }

end

SV.tryParkNearVehicle = function(currentGarage)
    local src = source
    if src then
        local currentGarageData = garages[currentGarage] or nil
        if not currentGarageData then
            notify(src,'GARAGE_UNAVAILABLE')
            return { error = 1 }
        end
        local networkVehicle,plate,health,damages,model,coords = CL.getNearestVehicleForDespawn(src,1)
        if networkVehicle then
            if #(vector3(currentGarageData.open[1],currentGarageData.open[2],currentGarageData.open[3])-coords) > 30 then
                notify(src,'VEHICLE_TOO_FAR')
                return { error = 1 }
            end
            updateVehicleHealth(plate,health,damages)
            deleteNetVehicle(networkVehicle)
            notify(src,'VEHICLE_PARKED_IN')
        else
            notify(src,'NONE_VEHICLE_NEAR')
        end
    end
end

SV.tryGarageForm = function()
    local src = source
    if g_forms[src] then
        local characterId = getCharacterId(src)
        if characterId then
            local form = g_forms[src]
            if form.paymentValue ~= nil and type(form.paymentValue) == 'number' then
                form.paymentValue = parseInt(form.paymentValue)
                if removeCurrency(characterId,form.paymentValue) then
                    if form.updateTax then
                        local newTaxEndTime = updateVehicleTax(form.plate)
                        if newTaxEndTime and type(newTaxEndTime) == 'number' then
                            CL.updateVehicleTax(src,form.plate,newTaxEndTime)
                        end
                    end 
                    if form.resetStatus then
                        updateVehicleStatus(form.plate,'')
                    end
                    if form.afterPayment and type(form.afterPayment) == 'function' then
                        form.afterPayment(src,characterId,form.plate)
                    end
                    notify(src,'PAYMENT_COMPLETED')
                else
                    notify(src,'MONEY_NOT_ENOUGH')
                end
            end
        end
    end
end

SV.tryToggleVehicleLock = function(plate,networkVehicle)

    local src = source
    local characterId = getCharacterId(src)

    if characterId and plate and networkVehicle then
        local result = false
        local vehicle = NetworkGetEntityFromNetworkId(networkVehicle)
        if vehicle and DoesEntityExist(vehicle) then
            local vehicleData = getVehicleData(plate)
            if vehicleData then
                local hasVehiclePermission = false
                if vehicleData.owner == characterId or getVehicleBorrowed(plate) == characterId then
                    hasVehiclePermission = true
                end
                if hasVehiclePermission then
                    result = true
                end
            else
                local cVehicles = GlobalState['core-cVehicles']
                if cVehicles and type(cVehicles) == 'table' and cVehicles[plate] and cVehicles[plate].owner then
                    result = (cVehicles[plate].owner == characterId)
                end
            end
        end
        if result then
            local lockState = GetVehicleDoorLockStatus(vehicle)
            if lockState <= 1 then
                SetVehicleDoorsLocked(vehicle,2)
            else
                SetVehicleDoorsLocked(vehicle,1)
            end
            async(function()
                CL.vehicleLockToggle(-1,networkVehicle)
            end)
            return result,lockState
        end
    end
    return false,false

end

-- ------------------------------------------------
-- # Borrow System
-- ------------------------------------------------

SV.tryBorrowVehicle = function(plate,friendId)

    local src = source
    local characterId = getCharacterId(src)

    if not borrowSystem or not borrowSystem.enabled then
        notify(src,'NO_PERMISSION')
        return { error = 1}
    end

    if characterId and plate and friendId then

        local vehicleData = getVehicleData(plate)
        if not vehicleData then
            notify(src,'VEHICLE_NOT_FOUND')
            return { error = 1 }
        end

        friendId = parseInt(friendId)
        if friendId <= 0 then
            notify(src,'INVALID_PASSPORT')
            return { error = 1 }
        end

        if friendId == characterId then
            notify(src,'CANT_BORROW_TO_YOURSELF')
            return { error = 1 }
        end

        local identity = getCharacterIdentity(friendId)['name'] or nil
        if not identity then
            notify(src,'INVALID_PASSPORT')
            return { error = 1 }
        end

        local _borrowedTo = identity..' #'..friendId
        
        if vehicleData.owner == characterId then

            if getVehicleBorrowed(plate) > 0 then
                notify(src,'VEHICLE_ALREADY_BORROWED')
                return { error = 1 }
            end
            
            if (borrowSystem.blockedCategories and borrowSystem.blockedCategories[vehicleData.category]) or (borrowSystem.blockedModels and borrowSystem.blockedModels[vehicleData.index]) then
                notify(src,'CANT_BORROW_THIS_VEHICLE')
                return { error = 1 }
            end

            toggleVehicleBorrow(plate,friendId,true)
            notify(src,'VEHICLE_BORROWED')
            return { success = true, borrowedTo = _borrowedTo }

        else
            notify(src,'NOT_YOUR_VEHICLE')
            return { error = 1 }
        end

    end

    return { error = 'Identidade inválida.' }

end

SV.tryRevokeVehicle = function(plate)

    local src = source
    local characterId = getCharacterId(src)

    if characterId and plate then

        plate = plate:gsub(' ','')
        local vehicleData = getVehicleData(plate)
        if not vehicleData then
            notify(src,'VEHICLE_NOT_FOUND')
            return { error = 1 }
        end
       
        if vehicleData.owner == characterId then
            notify(src,'VEHICLE_UNBORROWED')
            local friendId = getVehicleBorrowed(plate)
            if friendId then
                local tSrc = getCharacterSource(friendId)
                if tSrc then
                    CL.removeVehicleFromGarage(tSrc,plate)
                end
            end
            toggleVehicleBorrow(plate)
            return { success = true }

        else
            notify(src,'NOT_YOUR_VEHICLE')
            return { error = 1 }
        end

    end

    notify(src,'INVALID_IDENTITY')
    return { error = 1 }

end

-- ------------------------------------------------
-- # Sell System
-- ------------------------------------------------

local sellingVehicles = {}

SV.trySellVehicle = function(plate,targetId,sellPrice)

    local src = source
    local characterId = getCharacterId(src)

    if not sellSystem or not sellSystem.enabled then
        notify(src,'NO_PERMISSION')
        return { error = 1 }
    end

    if characterId and plate then

        if sellingVehicles[plate] then
            notify(src,'ALREADY_SELLING_VEHICLE')
            return { error = 1 }
        end

        targetId = parseInt(targetId)
        if targetId <= 0 then
            notify(src,'INVALID_PASSPORT')
            return { error = 1 }
        end

        if targetId == characterId then
            notify(src,'INVALID_PASSPORT')
            return { error = 1 }
        end

        local _list,_count = getCharacterVehicles(targetId)
        if not canCharacterBuyVehicle(targetId,_count) then
            notify(src,'PERSON_DOSNT_HAVE_SPACE_AT_GARAGE')
            return { error = 1 }
        end

        sellPrice = parseInt(sellPrice)
        if sellPrice <= 0 or sellPrice > 1000000000 then
            notify(src,'INVALID_VALUE')
            return { error = 1 }
        end

        plate = plate:gsub(' ','')
        local vehicleData = getVehicleData(plate)
        if not vehicleData then
            notify(src,'VEHICLE_NOT_FOUND')
            return { error = 1 }
        end
        
        local vehicleInfo = getVehicleInfo(vehicleData.index)
        if not vehicleInfo then
            notify(src,'VEHICLE_NOT_FOUND')
            return { error = 1 }
        end

        if getNetVehicle(vehicleData.plate,vehicleData.index) then
            notify(src,'CANT_SELL_PARKED_OUT_VEHICLES')
            return { error = 1 }
        end

        if (sellSystem.blockedCategories and sellSystem.blockedCategories[vehicleData.category]) or (sellSystem.blockedModels and sellSystem.blockedModels[vehicleData.index]) then
            notify(src,'CANT_SELL_THIS_VEHICLE')
            return { error = 1 }
        end

        if vehicleData.expire_time > 0 then
            notify(src,'CANT_SELL_RENTAL_VEHICLES')
            return { error = 1 }
        end

        if vehicleData.owner == characterId then

            local targetSrc = getCharacterSource(targetId)
            if not targetSrc then
                notify(src,'PERSON_MUST_BE_NEAR')
                return { error = 1 }
            end
            
            if #(GetEntityCoords(GetPlayerPed(src))-GetEntityCoords(GetPlayerPed(targetSrc))) > 5 then
                notify(src,'PERSON_MUST_BE_NEAR')
                return { error = 1 }
            end

            sellingVehicles[plate] = { owner = characterId, ownerSrc = src, target = targetId, targetSrc = targetSrc }

            CreateThread(function()
                if requestResponse(targetSrc,'VEHICLE_SELL',{ vehicle = vehicleData.name, price = sellPrice }) then
                    if getNetVehicle(vehicleData.plate,vehicleData.index) then
                        notify(src,'CANT_SELL_PARKED_OUT_VEHICLES')
                        notify(targetSrc,'PURCHASE_CANCELLED')
                        if sellingVehicles[plate] then
                            sellingVehicles[plate] = nil
                        end
                        return
                    end
                    if removeCurrency(targetId,sellPrice) then
                        giveCurrency(characterId,sellPrice)
                        transferVehicle(plate,targetId)
                        notify(src,'VEHICLE_SELL_COMPLETED',{ ['@vehicle'] = vehicleData.name, ['@price'] = formatCurrency(sellPrice) })
                        notify(targetSrc,'VEHICLE_PURCHASE_COMPLETED',{ ['@vehicle'] = vehicleData.name, ['@price'] = formatCurrency(sellPrice) })
                        local _log = 'Vehicle sold to another character.\n```prolog\n[ID]: '..characterId..'\n[TARGET ID]: '..targetId..'\n[VEHICLE]: '..vehicleInfo.index..'\n[PLATE]: '..plate..'\n[VALUE]: '..formatCurrency(sellPrice)..' (primary)\n```'
                        _LOG(logsWebhooks['charSold'],_log)
                        CL.removeVehicleFromGarage(src,plate)
                    else
                        notify(src,'VEHICLE_SELL_DECLINED',{ ['@vehicle'] = vehicleData.name })
                        notify(targetSrc,'MONEY_NOT_ENOUGH')
                    end
                else
                    notify(src,'VEHICLE_SELL_DECLINED',{ ['@vehicle'] = vehicleData.name })
                end
                if sellingVehicles[plate] then
                    sellingVehicles[plate] = nil
                end
            end)
            
            notify(src,'VEHICLE_SELL_PROPOSE_SENT')
            return { success = true }
       
        else
            notify(src,'NOT_YOUR_VEHICLE')
            return { error = 1 }
        end

    end

    notify(src,'INVALID_IDENTITY')
    return { error = 1 }

end

-- ------------------------------------------------
-- # Property Garages (Backward Compat)
-- ------------------------------------------------

local propertyGarages = {}
local propertyActive = {}

CreateThread(function()
    Wait(2000)
    local Consult = vRP.Query("propertys/Garages")
    for _,v in ipairs(Consult or {}) do
        local Name = v.Name
        local GarageJson = v.Garage
        if GarageJson then
            local GarageTable = json.decode(GarageJson)
            if GarageTable and GarageTable["1"] and GarageTable["2"] then
                local gId = insertGarage({
                    name = 'Garagem',
                    type = 'NORMAL',
                    open = { GarageTable["1"][1], GarageTable["1"][2], GarageTable["1"][3], 0 },
                    spawns = { GarageTable["2"] },
                    propertyId = Name
                })
                propertyGarages[Name] = gId
            end
        end
    end
end)

RegisterServerEvent('garages:Propertys')
AddEventHandler('garages:Propertys',function(Name)
    local src = source
    local characterId = getCharacterId(src)
    if not characterId or propertyActive[characterId] then
        return
    end

    local Consult = vRP.SingleQuery("propertys/Exist",{ Name = Name })
    if not Consult or Consult.Passport ~= characterId then
        return
    end

    propertyActive[characterId] = true

    TriggerClientEvent("dynamic:Close",src)
    TriggerClientEvent("Notify",src,"Aviso","Selecione o local da garagem.","amarelo",5000)

    local Hash = "prop_offroad_tyres02"
    local Success,GarageCoords = vRPclient.ObjectControlling(src,Hash)
    if not Success then
        propertyActive[characterId] = nil
        return
    end

    local PropertyCoords = exports.propertys:Coords(Name)
    if #(vec3(GarageCoords[1],GarageCoords[2],GarageCoords[3]) - PropertyCoords) > 25 then
        TriggerClientEvent("Notify",src,"Aviso","A garagem precisa ser próximo da entrada.","amarelo",5000)
        propertyActive[characterId] = nil
        return
    end

    TriggerClientEvent("Notify",src,"Aviso","Selecione o local do veículo.","amarelo",5000)

    local VehicleHash = "sultanrs"
    local Success2,VehicleCoords = vRPclient.ObjectControlling(src,VehicleHash)
    if not Success2 then
        propertyActive[characterId] = nil
        return
    end

    if #(vec3(VehicleCoords[1],VehicleCoords[2],VehicleCoords[3]) - PropertyCoords) > 25 then
        TriggerClientEvent("Notify",src,"Aviso","A garagem precisa ser próximo da entrada.","amarelo",5000)
        propertyActive[characterId] = nil
        return
    end

    local NewGarage = {
        ["1"] = { GarageCoords[1],GarageCoords[2],GarageCoords[3] + 1 },
        ["2"] = { VehicleCoords[1],VehicleCoords[2],VehicleCoords[3] + 1,VehicleCoords[4] }
    }

    vRP.Update("propertys/Garage",{ Name = Name, Garage = json.encode(NewGarage) })

    if propertyGarages[Name] then
        local oldId = propertyGarages[Name]
        garages[oldId] = nil
        externalGarages[oldId] = nil
        CL.removeGarage(-1,oldId)
    end

    local gId = insertGarage({
        name = 'Garagem',
        type = 'NORMAL',
        open = { NewGarage["1"][1], NewGarage["1"][2], NewGarage["1"][3], 0 },
        spawns = { NewGarage["2"] },
        propertyId = Name
    })
    propertyGarages[Name] = gId

    propertyActive[characterId] = nil
end)

AddEventHandler('garages:Clean',function(Name)
    if propertyGarages[Name] then
        local gId = propertyGarages[Name]
        garages[gId] = nil
        externalGarages[gId] = nil
        CL.removeGarage(-1,gId)
        propertyGarages[Name] = nil
    end
end)
