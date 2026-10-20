-- ------------------------------------------------
-- # Mechanics
-- ------------------------------------------------

local _notify = notify
local function notify(src, msgKey, extras) _notify(src, msgKey, extras, 'Mecânica') end

local atMechanic = {}

AddEventHandler('playerDropped',function(reason)
    local src = source
    if src and atMechanic[src] then
        local ent = NetworkGetEntityFromNetworkId(atMechanic[src][1])
        if ent and DoesEntityExist(ent) and GetEntityType(ent) == 2 then
            if GetEntityModel(ent) == atMechanic[src][2] and GetVehicleNumberPlateText(ent) == atMechanic[src][3] then
                DeleteEntity(ent)
            end
        end
    end
end)

SV.resetMechanicOpen = function()
    local src = source
    if atMechanic[src] then
        atMechanic[src] = nil
    end
end

SV.canOpenMechanic = function(id,networkVehicle)

    if not MechanicEnabled() then
        return false
    end

    local src = source
    local characterId = getCharacterId(src)

    if src and characterId and id and networkVehicle then
        if mechanics[id] then
            if mechanics[id].permission and not mechanics[id].autoMode then
                if not hasPermission(characterId,mechanics[id].permission) then
                    return false
                end
            end
            local vehicle = NetworkGetEntityFromNetworkId(networkVehicle[1])
            if not vehicle or (vehicle and DoesEntityExist(vehicle) and Entity(vehicle).state.mechBlocked and not fixed_rental_plates) then
                notify(src,'YOU_CANT_MODIFY_THIS_VEHICLE')
                return false
            end
            networkVehicle[4] = id
            atMechanic[src] = networkVehicle
            if mech_invoices[networkVehicle[3]] then
                local ok = requestResponse(src,'VEHICLE_INVOICE_REPLACE')
                if ok then
                    mech_invoices[networkVehicle[3]] = nil
                    mech_invoices_datas[networkVehicle[3]] = nil
                end
                return ok
            end
            return true
        end
    end

    return false

end

SV.canOpenMechanicAdmin = function(id,networkVehicle)

    if not MechanicEnabled() then
        return false
    end

    local src = source
    local characterId = getCharacterId(src)

    if src and characterId and id and networkVehicle then
        if not hasPermission(characterId,'Admin') then
            return false
        end
        if mechanics[id] then
            networkVehicle[4] = id
            networkVehicle[5] = true
            atMechanic[src] = networkVehicle
            return true
        end
    end

    return false

end

SV.getVehicleModsByPlate = function(plate)
    return getVehicleMods(plate)
end

-- ------------------------------------------------
-- # Mechanic Invoices
-- ------------------------------------------------

setMechanicInvoice = function(client,id,plate,mods)
    if id and plate and mods then
        mech_invoices[plate] = {id,client}
        mech_invoices_datas[plate] = mods
        if mechanics[id] then
            async(function()
                for id,src in pairs(getCharactersByPermission(mechanics[id].permission)) do
                    notify(src,'NEW_INVOICE_RECEIVED',{ ['@command'] = autoMode.commandName })
                end
            end)
        end
    end
end

getMechanicInvoices = function(id)
    local list = {}
    for plate,invoice in pairs(mech_invoices) do
        if invoice[1] == id then
            list[plate] = invoice
        end
    end
    return list
end

CreateThread(function()
    Wait(1000)
    if not MechanicEnabled() then
        return
    end

    RegisterCommand(autoMode.commandName,function(src,args,rc)
        if src == 0 then
            return
        end
        local characterId = getCharacterId(src)
        if args[1] then
            local id = false
            for _id,_ in pairs(mechanics) do
                if _id:lower() == args[1]:lower() then
                    id = _id
                    break
                end
            end
            if id and mechanics[id] and mechanics[id].permission then
                print('id - ',id,hasPermission(characterId,mechanics[id].permission),mechanics[id].permission)
                if hasPermission(characterId,mechanics[id].permission) then
                    local invoices = getMechanicInvoices(id)
                    CL.showMechanicInvoices(src,id,invoices)
                end
            end
        end
    end)
end)

SV.tryCallMechanicInvoice = function(plate)
    local src = source
    if src and plate then
        if mech_invoices[plate] then
            local characterId = getCharacterId(src)
            if mech_invoices[plate][1] and mechanics[mech_invoices[plate][1]] then
                if hasPermission(characterId,mechanics[mech_invoices[plate][1]].permission) then
                    if mech_invoices_calls[plate] and mech_invoices_calls[plate] > os.time() then
                        notify(src,'INVOICE_CALL_COOLDOWN')
                        return
                    end
                    local invOwner = (mech_invoices[plate][2] and mech_invoices[plate][2][1]) and mech_invoices[plate][2][1] or false
                    if invOwner then
                        local ownSrc = getCharacterSource(invOwner)
                        if ownSrc then
                            notify(ownSrc,'MECHANIC_CALL',{ ['@vehicle'] = mech_invoices[plate][2][3], ['@plate'] = plate })
                        end
                    end
                    notify(src,'INVOICE_CLIENT_CALLED',{ ['@vehicle'] = mech_invoices[plate][2][3], ['@plate'] = plate })
                    mech_invoices_calls[plate] = os.time() + 120
                    return 
                end
                notify(src,'NO_PERMISSION')
            end
        end
    end
    return { remove = 1 }
end

SV.tryCancelMechanicInvoice = function(plate)
    local src = source
    if src and plate then
        if mech_invoices[plate] then
            local characterId = getCharacterId(src)
            if mech_invoices[plate][1] and mechanics[mech_invoices[plate][1]] then
                if hasPermission(characterId,mechanics[mech_invoices[plate][1]].permission) then
                    local invOwner = (mech_invoices[plate][2] and mech_invoices[plate][2][1]) and mech_invoices[plate][2][1] or false
                    if invOwner then
                        local ownSrc = getCharacterSource(invOwner)
                        if ownSrc then
                            notify(ownSrc,'INVOICE_CANCELLED_2',{ ['@vehicle'] = mech_invoices[plate][2][3], ['@plate'] = plate })
                        end
                    end
                    mech_invoices[plate] = nil
                    if mech_invoices_datas[plate] then
                        mech_invoices_datas[plate] = nil
                    end
                    notify(src,'INVOICE_CANCELLED')
                    return 
                end
                notify(src,'NO_PERMISSION')
            end
        end
    end
end

SV.tryApplyMechanicInvoice = function(plate)
    local src = source
    if src and plate then
        if mech_invoices[plate] and mech_invoices_datas[plate] then
            local characterId = getCharacterId(src)
            if mech_invoices[plate][1] and mechanics[mech_invoices[plate][1]] then
                if hasPermission(characterId,mechanics[mech_invoices[plate][1]].permission) then
                    if mech_invoices_payments[plate] and mech_invoices_payments[plate] > os.time() then
                        notify(src,'INVOICE_PAYMENT_COOLDOWN')
                        return
                    end
                    local invOwner = (mech_invoices[plate][2] and mech_invoices[plate][2][1]) and mech_invoices[plate][2][1] or false
                    local ownerSrc = false
                    if invOwner then
                        ownerSrc = getCharacterSource(invOwner)
                    end
                    if not ownerSrc then
                        notify(src,'CLIENT_MUST_BE_NEAR')
                        return {}
                    end
                    local ped = GetPlayerPed(src)
                    local ownerPed = GetPlayerPed(ownerSrc)
                    if not ped or not ownerPed or #(GetEntityCoords(ped)-GetEntityCoords(ownerPed)) > 7 then
                        notify(src,'CLIENT_MUST_BE_NEAR')
                        return {}
                    end
                    if #(GetEntityCoords(ped)-vector3(mechanics[mech_invoices[plate][1]].coords[1][1],mechanics[mech_invoices[plate][1]].coords[1][2],mechanics[mech_invoices[plate][1]].coords[1][3])) > 50 then
                        notify(src,'TOO_FAR_FROM_MECHANIC')
                        return {}
                    end
                    local networkVehicle = CL.getInvoiceVehicle(src,plate)
                    if not networkVehicle then
                        notify(src,'MUST_BE_DRIVING_TO_APPLY')
                        return
                    end
                    mech_invoices_payments[plate] = os.time() + 32
                    notify(src,'PAYMENT_REQUESTED')
                    local payment = requestResponse(ownerSrc,'VEHICLE_INVOICE_PAYMENT',{ vehicle = mech_invoices[plate][2][1], plate = plate, value = mech_invoices[plate][2][4] })
                    if payment then
                        if removeCurrency(invOwner,mech_invoices[plate][2][4]) then
                            notify(src,'PAYMENT_SUCCESSFULL')
                            local mods = cloneTable(mech_invoices_datas[plate])
                            local vehicleData = getVehicleData(plate) or false
                            local serviceVehicle = (vehicleData and vehicleData.isServiceRental) and true or false
                            local table = serviceVehicle and 'core_characters_vehicles_srvc' or 'core_characters_vehicles' 
                            if not serviceVehicle then
                                updateVehicleMods(plate,mods)
                            end
                            execute([[
                                UPDATE `]]..table..[[` SET `mods` = ']]..json.encode(mods)..[[' WHERE `plate` = ']]..plate..[[';
                            ]])
                            local ent = NetworkGetEntityFromNetworkId(networkVehicle)
                            if ent and DoesEntityExist(ent) and GetEntityType(ent) == 2 then
                                if GetVehicleNumberPlateText(ent):gsub(' ','') == plate then
                                    CL._applyVehicleMods(-1,networkVehicle,mods)
                                end
                            end
                            local comission = parseInt(mech_invoices[plate][2][4] * autoMode.comission)
                            giveCurrency(characterId,comission)
                            notify(src,'INVOICE_COMPLETED',{ ['@comission'] = formatCurrency(comission) })
                            local _log = 'Applied mechanic invoice.\n```prolog\n[MECHANIC]: '..mech_invoices[plate][1]..'\n[WORKER]: '..characterId..'\n[CLIENT]: '..invOwner..'\n[PLATE]: '..plate..'\n[VALUE]: '..formatCurrency(mech_invoices[plate][2][4])..'\n[COMISSION]: '..formatCurrency(comission)..'\n[MODS]:\n'..json.encode(mods, { indent = true })..'\n```'
                            _LOG(logsWebhooks['tunnings'],_log)
                            mech_invoices[plate] = nil
                            mech_invoices_datas[plate] = nil
                            return { success = 1 }
                        else
                            notify(ownerSrc,'MONEY_NOT_ENOUGH')
                        end
                    end
                    notify(src,'INVOICE_PAYMENT_DECLINED')
                    return 
                end
                notify(src,'NO_PERMISSION')
            end
        end
    end
end

-- {VehToNet(_MECHANIC.vehicle),GetEntityModel(_MECHANIC.vehicle),GetVehicleNumberPlateText(_MECHANIC.vehicle):gsub(' ','')}
SV.tryMechanicPayment = function(value,srcData)

    local src = source
    if src and atMechanic[src] and srcData then
        local validAction = true
        for _,__ in pairs(atMechanic[src]) do
            if _ < 4 then
                if not srcData[_] or srcData[_] ~= __ then
                    validAction = false
                    break
                end
            end
        end
        if not validAction then
            notify(src,'INVALID_VEHICLE')
            return { error = 1 }
        end
        local characterId = getCharacterId(src)
        if validAction and characterId then

            local id = atMechanic[src][4]

            if mechanics[id] and mechanics[id].autoMode and not atMechanic[src][5] and not hasPermission(characterId,mechanics[id].permission) then

                local clientIdentity = getCharacterIdentity(characterId) or {}
                if clientIdentity then

                    local phone = clientIdentity.phone
                    if phone then

                        local networkVehicle,model,plate,mods = CL.getMechVehicleMods(src)

                        if plate and mods then

                            setMechanicInvoice({characterId,phone,getVehicleInfo(atMechanic[src][2]).name or '??',parseInt(value)},id,atMechanic[src][3],mods)
                            notify(src,'MECH_INVOICE_CREATED')
                            return { success = true }

                        end

                    end

                end
                
                 notify(src,'INVALID_IDENTITY')
                 return { error = 1 }

            else

                value = parseInt(value)
                local paid = false
                if value <= 0 then
                    paid = true
                else
                    paid = removeCurrency(characterId,value)
                end
    
                if paid then
    
                    local networkVehicle,model,plate,mods = CL.getMechVehicleMods(src)
                    if plate and mods then
    
                        local vehicleData = getVehicleData(plate) or false
                        local serviceVehicle = (vehicleData and vehicleData.isServiceRental) and true or false
                        local table = serviceVehicle and 'core_characters_vehicles_srvc' or 'core_characters_vehicles' 
                        if not serviceVehicle then
                            updateVehicleMods(plate,mods)
                        end
                        execute([[
                            UPDATE `]]..table..[[` SET `mods` = ']]..json.encode(mods)..[[' WHERE `plate` = ']]..plate..[[';
                        ]])

                        local ent = NetworkGetEntityFromNetworkId(networkVehicle)
                        if ent and DoesEntityExist(ent) and GetEntityType(ent) == 2 then
                            if GetVehicleNumberPlateText(ent):gsub(' ','') == plate and GetEntityModel(ent) == model then
                                CL._applyVehicleMods(-1,networkVehicle,mods)
                            end
                        end
                      
                        local _log = 'Vehicle tunning.\n```prolog\n[MECHANIC]: '..id..'\n[WORKER]: '..characterId..'\n[PLATE]: '..plate..'\n[VALUE]: '..formatCurrency(value)..'\n[MODS]:\n'..json.encode(mods, { indent = true })..'\n```'
                        _LOG(logsWebhooks['tunnings'],_log)

                        return { success = true, saveNow = true }

                    end
    
                    notify(src,'UNKNOWN_ERROR')
                    giveCurrency(characterId,value)
                    return { error = 1 }
    
                else
    
                    notify(src,'MONEY_NOT_ENOUGH')
                    return { error = 1 }
    
                end

            end

        end
    end

    notify(src,'INVALID_IDENTITY')
    return { error = 1 }

end
