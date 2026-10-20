-- ------------------------------------------------
-- # Dealership
-- ------------------------------------------------

local _notify = notify
local function notify(src, msgKey, extras) _notify(src, msgKey, extras, 'Concessionária') end

local function coreLog(category, data)
    if GetResourceState("core_logs") == "started" then
        exports["core_logs"]:AddLog(category, data)
    end
end

SV.changeMyRoute = function()
    local src = source
    if src then
        SetPlayerRoutingBucket(src,(6767+src))
    end
    return true
end

SV.resetMyRoute = function()
    local src = source
    if src then
        SetPlayerRoutingBucket(src,0)
    end
    return true
end

SV.tryBuyDealerVehicle = function(dealerId,vehicleIndex,vehicleColors,paymentMode)

    local src = source
    local characterId = getCharacterId(src)

    if characterId and dealerId and vehicleIndex then

        local vehicleInfo = getVehicleInfo(GetHashKey(vehicleIndex))
        if not vehicleInfo then
            notify(src,'VEHICLE_UNAVAILABLE')
            return { error = 1 }
        end

        Wait(math.random(600,2500))

        local _list,_count = getCharacterVehicles(characterId)
        if not canCharacterBuyVehicle(characterId,_count) then
            notify(src,'GARAGE_FULL')
            return { error = 1 }
        end

        if not infiniteStock and vehicleInfo.stock and vehicleInfo.stock > 0 then
            local currentStock = getDealerVehicleStock(vehicleInfo.index) or 0
            if currentStock <= 0 then
                notify(src,'VEHICLE_OUT_OF_STOCK')
                return { error = 1 }
            end
        end

        local payWithGems = paymentMode == "secondary" and vehicleInfo.gemstone
        local _paymentType = payWithGems and "secondary" or vehicleInfo.paymentType
        local _price = payWithGems and vehicleInfo.gemstone or vehicleInfo.price

        if not payWithGems and permissionDiscounts then
            for perm,discount in pairs(permissionDiscounts) do
                if hasPermission(characterId,perm) then
                    _price = _price - (_price * (discount/100))
                    break
                end
            end
        end

        if removeCurrency(characterId,parseInt(_price),_paymentType) then

            local succs,result = generateVehicle(characterId,vehicleInfo.index,vehicleColors)
            if succs then
                local _generatedPlate,_generatedVehicleData = false,false
                local cVehicles = getCharacterVehicles(characterId)
                if cVehicles[result] then
                    _generatedPlate = result
                    _generatedVehicleData = cloneTable(cVehicles[result])
                    for kInfo,kValue in pairs(vehicleInfo) do
                        _generatedVehicleData[kInfo] = kValue
                    end
                end

                if not infiniteStock and vehicleInfo.stock and vehicleInfo.stock > 0 then
                    local currentStock = getDealerVehicleStock(vehicleInfo.index) or 0
                    setDealerVehicleStock(vehicleInfo.index,currentStock-1)
                end

                local _log = 'Vehicle purchased.\n```prolog\n[ID]: '..characterId..'\n[VEHICLE]: '..vehicleInfo.index..'\n[PLATE]: '.._generatedPlate..'\n[VALUE]: '..formatCurrency(parseInt(_price))..' ('.._paymentType..')\n```'
                _LOG(logsWebhooks['dealershipPurchase'],_log)

                coreLog("COMPROU-VEICULO", {
                    message = vRP.FullName(characterId).." #"..characterId.." comprou o veículo "..(vehicleInfo.name or vehicleInfo.index).." por "..formatCurrency(parseInt(_price)),
                    playerName = vRP.FullName(characterId),
                    playerId = characterId,
                    Veiculo = (vehicleInfo.name or vehicleInfo.index).." ("..vehicleInfo.index..")",
                    Placa = _generatedPlate,
                    Valor = parseInt(_price),
                    Pagamento = _paymentType == "secondary" and "Diamantes" or "Dinheiro",
                    Concessionaria = dealerId
                })

                notify(src,'PURCHASE_COMPLETED')
                return { success = true, plate = _generatedPlate, nvdata = _generatedVehicleData }
            end

            giveCurrency(characterId,parseInt(_price),_paymentType)
            _vehiclesVPrint('Error while generating vehicle -> ID: '..characterId..' | RESULT:\n'..result)
            notify(src,'UNKNOWN_ERROR')
            return { error = 1 }

        end

        notify(src,'MONEY_NOT_ENOUGH')
        return { error = 1 }

    end

    notify(src,'INVALID_IDENTITY')
    return { error = 1 }

end

SV.tryDealerSellVehicle = function(plate)

    local src = source
    local characterId = getCharacterId(src)

    if characterId and plate then

        plate = plate:gsub(' ','')
        local vehicleData = getVehicleData(plate)
        if not vehicleData then
            notify(src,'VEHICLE_NOT_FOUND')
            return { error = 1 }
        end

        if vehicleData.owner ~= characterId then
            notify(src,'NOT_YOUR_VEHICLE')
            return { error = 1 }
        end

        local vehicleInfo = getVehicleInfo(vehicleData.index)
        if not vehicleInfo then
            notify(src,'VEHICLE_UNAVAILABLE')
            return { error = 1 }
        end

        if vehicleData.expire_time > 0 then
            notify(src,'CANT_SELL_RENTAL_VEHICLES')
            return { error = 1 }
        end

        if sellBack.blockedModels and sellBack.blockedModels[vehicleInfo.index] then
            notify(src,'CANT_SELL_THIS_VEHICLE')
            return { error = 1 }
        end

        if sellBack.blockedCategories and sellBack.blockedCategories[vehicleInfo.category] then
            notify(src,'CANT_SELL_THIS_VEHICLE')
            return { error = 1 }
        end

        Wait(math.random(600,2500))

        local networkVehicle,entityCoords = getNetVehicle(vehicleData.plate,vehicleData.index)
        if networkVehicle then
            notify(src,'CANT_SELL_PARKED_OUT_VEHICLES')
            return { error = 1 }
        end

        local _price = parseInt(vehicleInfo.price * sellBack.percentFromPrice)
        giveCurrency(characterId,_price,vehicleInfo.paymentType)
        deleteVehicle(vehicleData.plate)

        local _log = 'Vehicle sold to dealer.\n```prolog\n[ID]: '..characterId..'\n[VEHICLE]: '..vehicleInfo.index..'\n[PLATE]: '..plate..'\n[VALUE]: '..formatCurrency(_price)..' ('..vehicleInfo.paymentType..')\n```'
        _LOG(logsWebhooks['dealershipSold'],_log)

        coreLog("VENDEU-VEICULO", {
            message = vRP.FullName(characterId).." #"..characterId.." vendeu o veículo "..(vehicleInfo.name or vehicleInfo.index).." para a concessionária por "..formatCurrency(_price),
            playerName = vRP.FullName(characterId),
            playerId = characterId,
            Veiculo = (vehicleInfo.name or vehicleInfo.index).." ("..vehicleInfo.index..")",
            Placa = plate,
            Valor = _price
        })

        notify(src,'SELL_COMPLETED')
        return { success = true }

    end

    notify(src,'INVALID_IDENTITY')
    return { error = 1 }

end

SV.tryRentDealerVehicle = function(dealerId,vehicleIndex,paymentMode)

    local src = source
    local characterId = getCharacterId(src)

    if characterId and dealerId and vehicleIndex then

        local vehicleInfo = getVehicleInfo(GetHashKey(vehicleIndex))
        if not vehicleInfo or not vehicleInfo.rental or not vehicleInfo.rental.days then
            notify(src,'VEHICLE_UNAVAILABLE')
            return { error = 1 }
        end

        local days = vehicleInfo.rental.days

        Wait(math.random(600,2500))

        local payWithGems = paymentMode == "secondary" and vehicleInfo.gemstone
        local _paymentType = payWithGems and "secondary" or vehicleInfo.paymentType
        local _price = payWithGems and vehicleInfo.gemstone or vehicleInfo.price

        local hasRented,vehicleRentalPlate,vehicleRentalExpireTime = hasVehicleModelRented(characterId,vehicleInfo.index)

        if hasRented and vehicleRentalExpireTime >= os.time() then
            notify(src,'MODEL_ALREADY_RENTED')
            return { error = 1 }
        end

        local _generatedPlate,_generatedVehicleData = false,false
        if not hasRented then
            local _list,_count = getCharacterVehicles(characterId)
            if not canCharacterBuyVehicle(characterId,_count) then
                notify(src,'GARAGE_FULL')
                return { error = 1 }
            end
            if removeCurrency(characterId,parseInt(_price),_paymentType) then
                local succs,result = generateRentalVehicle(characterId,vehicleInfo.index,days)
                if succs then
                    local cVehicles = getCharacterVehicles(characterId)
                    if cVehicles[result] then
                        _generatedPlate = result
                        _generatedVehicleData = cloneTable(cVehicles[result])
                        for kInfo,kValue in pairs(vehicleInfo) do
                            _generatedVehicleData[kInfo] = kValue
                        end
                    end
                    local _log = 'Vehicle rented.\n```prolog\n[ID]: '..characterId..'\n[VEHICLE]: '..vehicleInfo.index..'\n[PLATE]: '.._generatedPlate..'\n[VALUE]: '..formatCurrency(parseInt(_price))..' ('.._paymentType..')\n[DAYS]: '..days..'\n```'
                    _LOG(logsWebhooks['dealershipRented'],_log)

                    coreLog("ALUGOU-VEICULO", {
                        message = vRP.FullName(characterId).." #"..characterId.." alugou o veículo "..(vehicleInfo.name or vehicleInfo.index).." por "..days.." dias",
                        playerName = vRP.FullName(characterId),
                        playerId = characterId,
                        Veiculo = (vehicleInfo.name or vehicleInfo.index).." ("..vehicleInfo.index..")",
                        Placa = _generatedPlate,
                        Valor = parseInt(_price),
                        Dias = days,
                        Pagamento = _paymentType == "secondary" and "Diamantes" or "Dinheiro",
                        Modo = "Novo aluguel"
                    })

                    notify(src,'RENT_COMPLETED')
                    return { success = true, plate = _generatedPlate, nvdata = _generatedVehicleData }
                else
                    giveCurrency(characterId,parseInt(_price),_paymentType)
                    _vehiclesVPrint('Error while generating RENTAL vehicle -> ID: '..characterId..' | RESULT:\n'..result)
                    notify(src,'UNKNOWN_ERROR')
                    return { error = 1 }
                end
            end
            notify(src,'MONEY_NOT_ENOUGH')
            return { error = 1 }
        else
            if removeCurrency(characterId,parseInt(_price),_paymentType) then
                forceLoadVehicleByPlate(vehicleRentalPlate)
                local success,newTime = updateRentalVehicleDays(vehicleRentalPlate,days)
                if success then
                    local cVehicles = getCharacterVehicles(characterId)
                    if cVehicles[vehicleRentalPlate] then
                        _generatedPlate = vehicleRentalPlate
                        _generatedVehicleData = cloneTable(cVehicles[vehicleRentalPlate])
                        for kInfo,kValue in pairs(vehicleInfo) do
                            _generatedVehicleData[kInfo] = kValue
                        end
                    end
                    local _log = 'Vehicle rented (renewed).\n```prolog\n[ID]: '..characterId..'\n[VEHICLE]: '..vehicleInfo.index..'\n[PLATE]: '.._generatedPlate..'\n[VALUE]: '..formatCurrency(parseInt(_price))..' ('.._paymentType..')\n[DAYS]: '..days..'\n```'
                    _LOG(logsWebhooks['dealershipRented'],_log)

                    coreLog("ALUGOU-VEICULO", {
                        message = vRP.FullName(characterId).." #"..characterId.." renovou o aluguel do veículo "..(vehicleInfo.name or vehicleInfo.index).." por "..days.." dias",
                        playerName = vRP.FullName(characterId),
                        playerId = characterId,
                        Veiculo = (vehicleInfo.name or vehicleInfo.index).." ("..vehicleInfo.index..")",
                        Placa = _generatedPlate,
                        Valor = parseInt(_price),
                        Dias = days,
                        Pagamento = _paymentType == "secondary" and "Diamantes" or "Dinheiro",
                        Modo = "Renovação"
                    })

                    notify(src,'RENT_COMPLETED')
                    return { success = true, plate = _generatedPlate, nvdata = _generatedVehicleData }
                else
                    giveCurrency(characterId,parseInt(_price),_paymentType)
                    _vehiclesVPrint('Error while renewing EXPIRED vehicle -> ID: '..characterId..' | PLATE: '..vehicleRentalPlate..' | RESULT:\n'..newTime)
                    notify(src,'UNKNOWN_ERROR')
                    return { error = 1 }
                end
            end
            notify(src,'MONEY_NOT_ENOUGH')
            return { error = 1 }
        end

    end

    notify(src,'INVALID_IDENTITY')
    return { error = 1 }

end

SV.tryRenewDealerRentalVehicle = function(plate,paymentMode)

    local src = source
    local characterId = getCharacterId(src)

    if characterId and plate then

        plate = plate:gsub(' ','')

        local vehicleData = getVehicleData(plate)
        if not vehicleData then
            notify(src,'VEHICLE_NOT_FOUND')
            return { error = 1 }
        end

        if vehicleData.owner ~= characterId then
            notify(src,'NOT_YOUR_VEHICLE')
            return { error = 1 }
        end

        local vehicleInfo = getVehicleInfo(vehicleData.index)
        if not vehicleInfo or not vehicleInfo.rental or not vehicleInfo.rental.days then
            notify(src,'VEHICLE_UNAVAILABLE')
            return { error = 1 }
        end

        local days = vehicleInfo.rental.days

        Wait(math.random(600,2500))

        if vehicleData.expire_time and vehicleData.expire_time <= 0 then
            notify(src,'YOU_CANT_RENEW_THIS_VEHICLE')
            return { error = 1 }
        end

        local payWithGems = paymentMode == "secondary" and vehicleInfo.gemstone
        local _paymentType = payWithGems and "secondary" or vehicleInfo.paymentType
        local _price = payWithGems and vehicleInfo.gemstone or vehicleInfo.price

        if removeCurrency(characterId,parseInt(_price),_paymentType) then

            forceLoadVehicleByPlate(plate)
            local success,newTime = updateRentalVehicleDays(plate,days)
            if success then
                local cVehicles = getCharacterVehicles(characterId)
                if cVehicles[plate] then
                    _generatedPlate = plate
                    _generatedVehicleData = cloneTable(cVehicles[plate])
                    for kInfo,kValue in pairs(vehicleInfo) do
                        _generatedVehicleData[kInfo] = kValue
                    end
                end

                local _log = 'Vehicle renewed.\n```prolog\n[ID]: '..characterId..'\n[VEHICLE]: '..vehicleInfo.index..'\n[PLATE]: '.._generatedPlate..'\n[VALUE]: '..formatCurrency(parseInt(_price))..' ('.._paymentType..')\n[DAYS]: '..days..'\n```'
                _LOG(logsWebhooks['dealershipRented'],_log)

                notify(src,'RENT_COMPLETED')
                return { success = true, newExpireTime = newTime }
            else
                giveCurrency(characterId,parseInt(_price),_paymentType)
                _vehiclesVPrint('Error while renewing CURRENT vehicle -> ID: '..characterId..' | PLATE: '..plate..' | RESULT:\n'..newTime)
                notify(src,'UNKNOWN_ERROR')
                return { error = 1 }
            end

        end

        notify(src,'MONEY_NOT_ENOUGH')
        return { error = 1 }

    end

    notify(src,'INVALID_IDENTITY')
    return { error = 1 }

end

SV.getCharacterVehicles = function()
    local src = source
    local characterId = getCharacterId(src)
    if characterId then
        return getCharacterVehicles(characterId,false) or {}
    end
    return {}
end

SV.tryPayTestDrive = function()
    local src = source
    if src then
        local characterId = getCharacterId(src)
        if characterId then
            return removeCurrency(characterId,testDrive.payment)
        end
    end
    return false
end

SV.getDealerBalance = function()
    local src = source
    local characterId = getCharacterId(src)
    if not characterId then
        return { money = 0, gems = 0 }
    end

    local gems = 0
    local identity = vRP.Identity(characterId)
    if identity and identity.License then
        gems = parseInt(vRP.UserGemstone(identity.License) or 0)
    end

    return { money = parseInt(vRP.GetBank(characterId) or 0), gems = gems }
end
