local r_tunnel = _G["lib-tunnel"]()
CL = {}
r_tunnel.bindInterface(GetCurrentResourceName(),CL)
SV = r_tunnel.getInterface(GetCurrentResourceName())

cooldown = false
_intloaded = false

interfaceOpen = false

dealerStock = nil
CL.updateDealerStock = function(index,amount)
    if type(dealerStock) == "table" then
        dealerStock[index] = amount
    end
end

-- Mantem o dealerStock local sincronizado com o servidor em tempo real.
-- Antes o cliente lia o GlobalState so uma vez no init e ficava stale, entao
-- mudancas de estoque (inclusive esconder um veiculo zerando o estoque) nao
-- apareciam para os outros players ate reiniciar. Fallback para ler o
-- GlobalState direto pois o `value` do handler pode vir nil em alguns builds.
AddStateBagChangeHandler('core-dStock', 'global', function(_, _, value)
    if type(value) ~= "table" then
        value = GlobalState["core-dStock"]
    end
    if type(value) == "table" then
        dealerStock = value
    end
end)

testDriveVehicle = nil

currentGarage = -1
currentDealer = -1
currentModelViewer = nil
modelViewerCamera = nil

MV_OLD_MODS = nil
MV_RESET_MODS = nil
mechanicVehicle = 0
currentMechanic = nil
mechanicVehicleData = {}
mechanicCart = { total = 0, items = {} }

tableNumberMods = {
    [0] = "spoilers",
    [1] = "frontBumpers",
    [2] = "rearBumpers",
    [3] = "skirts",
    [4] = "ehxausts",
    [5] = "frames",
    [6] = "grilles",
    [7] = "hoods",
    [8] = "fenders",
    [10] = "roofs",
    [14] = "horns",
    [25] = "plates1",
    [27] = "seats1",
    [28] = "ornaments",
    [29] = "dashboards",
    [31] = "speakers1",
    [32] = "seats2",
    [33] = "steeringWheels",
    [34] = "shiftLevers",
    [35] = "plates2",
    [36] = "speakers2",
    [37] = "trunks",
    [38] = "hidraulics",
    [40] = "airFilters",
    [41] = "supports",
    [42] = "headlights",
    [43] = "aerials",
    [44] = "trimDesigns",
    [45] = "tanks",
    [46] = "windows",
    [48] = "liveries",
}

perfKeys = {
    [11] = "engine",
    [12] = "brakes",
    [13] = "transmission",
    [15] = "suspension",
    [16] = "armour"
}

currentColorIndex = 0
currentPearlIndex = 0
currentWheelColorIndex = 0
metalColorIndex = 0
pearlColorIndex = 0
wheelColorIndex = 0
chameleonColorIndex = 0
mechanicFocused = false

vehModList = {

    [0] = "Aerofólios",
    [1] = "Parachoques (F)",
    [2] = "Parachoques (T)",
    [3] = "Saias",
    [4] = "Escapamentos",
    [5] = "Chassis",
    [6] = "Grelhas",
    [7] = "Capôs",
    [8] = "Paralamas",
    [10] = "Tetos",
    [11] = "Motores",
    [12] = "Freios",
    [13] = "Transmissões",
    [14] = "Buzinas",
    [15] = "Suspensões",
    [16] = "Blindagens",
    [18] = "Turbo",
    [23] = "Rodas",
    [24] = "Rodas",
    [25] = "Placas",
    [27] = "Assentos #1",
    [28] = "Ornamentos",
    [29] = "Painéis",
    [31] = "Auto Falantes",
    [32] = "Assentos #2",
    [33] = "Volantes",
    [34] = "Câmbios",
    [35] = "Placas #2",
    [36] = "Auto Falantes #2",
    [37] = "Bagageiras",
    [38] = "Hidráulicas",
    [40] = "Filtros de Ar",
    [41] = "Suportes",
    [42] = "Faróis",
    [43] = "Aerials",
    [44] = "Trim",
    [45] = "Tank",
    [46] = "Janelas",
    [48] = "Livery",

}

vehColorTypes = {
	["chroma"] = {120},
	["basic"] = {0,147,1,11,2,3,4,5,6,7,8,9,10,27,28,29,150,30,31,32,33,34,143,35,135,137,136,36,38,138,99,90,88,89,91,49,50,51,52,53,54,92,141,61,62,63,64,65,66,67,68,69,73,70,74,96,101,95,94,97,103,104,98,100,102,99,105,106,71,72,142,145,107,111,112},
	["opaque"] = {12,13,14,131,83,82,84,149,148,39,40,41,42,55,128,151,155,152,153,154},
	["metal"] = {117,118,119},
    ["chameleon"] = {158,159,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,23,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242}
}

vehWheelTypes = {
    ["VWT_SPORT"] = 0,
    ["VWT_MUSCLE"] = 1,
    ["VWT_LOWRIDER"] = 2,
    ["VWT_SUV"] = 3,
    ["VWT_OFFROAD"] = 4,
    ["VWT_TUNER"] = 5,
    ["VWT_BIKE"] = 6,
    ["VWT_HIEND"] = 7,
    ["VWT_SUPERMOD1"] = 8,
    ["VWT_SUPERMOD2"] = 9, 
    ["VWT_SUPERMOD3"] = 10, 
    ["VWT_SUPERMOD4"] = 11, 
    ["VWT_SUPERMOD5"] = 12, 
}

lockCd = false

------------------------------------------------------------------------------------------------------------------------
-- # Init Threads
------------------------------------------------------------------------------------------------------------------------

CreateThread(function()
    DoScreenFadeIn()
    Wait(2000)
    while dealerStock == nil do
        dealerStock = GlobalState["core-dStock"]
        Wait(500)
    end
end)

CreateThread(function()

    local externalGarages = SV.getExternalGarages() or {}
    for id,garage in pairs(externalGarages) do
        CL.insertGarage(id,garage)
    end

    RegisterKeyMapping("@core/vehicles/toggleVehicleLock","Trancar/destrancar um veículo","keyboard","L")
    RegisterCommand("@core/vehicles/toggleVehicleLock",function(src,args,rc)
        if lockCd or isDead() then return end
        lockCd = true
        local hash,plate,lockState,vehicleNetId = getNearestVehicle(8)
        if plate and vehicleNetId then
            local succs,result = SV.tryToggleVehicleLock(plate,vehicleNetId)
            if succs then
                if loadAnimDict("anim@mp_player_intmenu@key_fob@") then
                    TaskPlayAnim(PlayerPedId(),"anim@mp_player_intmenu@key_fob@","fob_click",2.0,2.0,-1,48,0,0,0,0)
                end
                if result <= 1 then
                    notify(nil,'VEHICLE_LOCKED')
                else
                    notify(nil,'VEHICLE_UNLOCKED')
                end
            end
        end
        SetTimeout(500,function() lockCd = false end)
    end)

end)

------------------------------------------------------------------------------------------------------------------------
-- # Garage Insert/Remove
------------------------------------------------------------------------------------------------------------------------

CL.insertGarage = function(id,garage)
    if not id or not garage or type(garage) ~= "table" then
        return
    end
    garages[id] = garage
    createGarageBlip(id,garage)
end

CL.removeGarage = function(id)
    if garages[id] then
        garages[id] = nil
    end
    if removeGarageBlip then
        removeGarageBlip(id)
    end
end

------------------------------------------------------------------------------------------------------------------------
-- # NUI Router
------------------------------------------------------------------------------------------------------------------------

RegisterNUICallback("_GET", function(d,cb)

    local action = d.action

    if action == "interface-loaded" then 
        _intloaded = true
        SendNUIMessage({ action = "setTheme", color = (Theme and type(Theme.main) == "string" and Theme.main ~= "" and Theme.main) or ThemeColor or "#dc1553" })
        cb(true) 
        return 
    end

    if action == "close" then
        cooldown = true
        SetNuiFocus(false,false)
        if LocalPlayer.state.testDriveExit then
            SetPlayerControl(PlayerId(),true)
            deleteDealerModel()
        else
            deleteDealerModel(true)
        end
        if type(currentMechanic) == "table"then
            resetMechanic()
        end
        SetTimeout(1000,function()
            interfaceOpen = false
            currentGarage = -1
            currentDealer = -1
            cooldown = false
            toggleHud(true)
        end)
        cb(true)
        return
    end

    ----------------------------------------------------
    -- # DEALER
    ----------------------------------------------------
    
    if action == "tryUpdateDealerVehicleStock" then
        if d.index and d.amount then
            cb(SV.tryUpdateDealerVehicleStock(d.index,parseInt(d.amount)))
            return
        end
        cb({ error = 1 })
        return
    end

    if action == "tryBuyDealerVehicle" then
        if d.index and d.primary and d.secondary and not cooldown then
            cooldown = true
            cb(SV.tryBuyDealerVehicle(currentDealer,d.index,{d.primary,d.secondary},d.paymentMode))
            SetTimeout(1500,function() cooldown = false end)
            return
        end
        cb(true)
        return
    end

    if action == "tryRentDealerVehicle" then
        if d.index and not cooldown then
            cooldown = true
            cb(SV.tryRentDealerVehicle(currentDealer,d.index,d.paymentMode))
            SetTimeout(1500,function() cooldown = false end)
            return
        end
        cb(true)
        return
    end

    if action == "tryRenewDealerRentalVehicle" then
        if d.plate and not cooldown then
            cooldown = true
            cb(SV.tryRenewDealerRentalVehicle(d.plate,d.paymentMode))
            SetTimeout(1500,function() cooldown = false end)
            return
        end
        cb(true)
        return
    end

    if action == "tryDealerSellVehicle" then
        if d.plate and not cooldown then
            cooldown = true
            cb(SV.tryDealerSellVehicle(d.plate))
            SetTimeout(1500,function() cooldown = false end)
            return
        end
        cb(true)
        return
    end

    if action == "dealerSelectedVehicle" then
        cb(createDealerViewModel(d.index,d.plate or false))
        return
    end

    if action == "updateModelViewerColor" then
        if d.primary and d.secondary and currentModelViewer and DoesEntityExist(currentModelViewer) and IsEntityAVehicle(currentModelViewer) then
            SetVehicleModKit(currentModelViewer,0)
            local pR,pG,pB = table.unpack(d.primary)
            ClearVehicleCustomPrimaryColour(currentModelViewer)
            SetVehicleCustomPrimaryColour(currentModelViewer,pR,pG,pB)
            local sR,sG,sB = table.unpack(d.secondary)
            ClearVehicleCustomSecondaryColour(currentModelViewer)
            SetVehicleCustomSecondaryColour(currentModelViewer,sR,sG,sB)
        end
        cb(true)
        return
    end

    if action == "rotateModelViewer" then
        if currentModelViewer and DoesEntityExist(currentModelViewer) and not disable_dealership_rotation then
            if d.side then
                SetEntityHeading(currentModelViewer,GetEntityHeading(currentModelViewer)+5)
            else
                SetEntityHeading(currentModelViewer,GetEntityHeading(currentModelViewer)-5)
            end
        end
        if mechanicVehicle and DoesEntityExist(mechanicVehicle) and not disable_mechanic_rotation then
            if d.side then
                SetEntityHeading(mechanicVehicle,GetEntityHeading(mechanicVehicle)+5)
            else
                SetEntityHeading(mechanicVehicle,GetEntityHeading(mechanicVehicle)-5)
            end
        end
        cb(true)
        return
    end

    if action == "tryTestDrive" then
        if d.model then
            if not IsModelValid(GetHashKey(d.model)) then
                notify(nil,"VEHICLE_UNAVAILABLE")
                return 
            end
            if not testDrive.payment or testDrive.payment <= 0 or (testDrive.payment > 0 and SV.tryPayTestDrive()) then
                cb({ success = true })
                tryTestDrive(d.model)
                return
            end
        end
        notify(nil,"MONEY_NOT_ENOUGH")
        cb({ error = 1 })
        return
    end

    ----------------------------------------------------
    -- # GARAGES
    ----------------------------------------------------

    if action == "tryParkNearVehicle" then
        SV.tryParkNearVehicle(currentGarage)
        cb(true)
        return
    end

    if action == "parkOutVehicle" then
        cb(SV.parkVehicle("OUT",d.vehicle,d.type,currentGarage))
        return
    end

    if action == "parkInVehicle" then
        cb(SV.parkVehicle("IN",d.vehicle,d.type,currentGarage))
        return
    end

    if action == "setVehicleFavorite" then
        if type(d.plate) == "string" and type(d.favorite) == "boolean" then
            cb(SV.setVehicleFavorite(d.plate,d.favorite))
            return
        end
        cb({ error = "INVALID_PARAMS" })
        return
    end

    if action == "trackVehicle" then
        local res = SV.trackVehicle(d.vehicle,d.type)
        if res.pos then
            cb({ success = true})
            trackVehicle(res.name,d.vehicle,res.pos)
        else
            cb(res)
        end
        return
    end

    if action == "tryBorrowVehicle" then
        cb(SV.tryBorrowVehicle(d.plate,d.friendId))
        return
    end

    if action == "tryRevokeVehicle" then
        cb(SV.tryRevokeVehicle(d.plate))
        return
    end

    if action == "trySellVehicle" then
        cb(SV.trySellVehicle(d.plate,d.targetId,d.sellPrice))
        return
    end

    if action == "tryGarageForm" then
        cb(true)
        SV.tryGarageForm()
        return
    end

    ----------------------------------------------------
    -- # VEH MENU
    ----------------------------------------------------

    if action == "remove-focus" then
        SetNuiFocus(false,false)
        cb(true)
        return
    end

    if action == "toggleVehMenuItem" then
        if d.item then
            cb(toggleVehMenuItem(d.item))
            return
        end
        cb(true)
        return
    end

    ----------------------------------------------------
    -- # CHARACTER VEHICLES MANAGER
    ----------------------------------------------------

    if action == "cvmTryRemove" then
        cb(SV.cvmTryRemove(d.plate))
        return
    end

    if action == "cvmTryFind" then
        local res = SV.cvmTryFind(d.plate)
        if res and type(res) == "table" and res.coords then
            local x,y,z = table.unpack(res.coords)
            SetEntityCoords(PlayerPedId(),x,y,z+2.5)
        end
        cb(res)
        return
    end

    if action == "cvmTryRenew" then
        cb(SV.cvmTryRenew(d.plate,d.days))
        return
    end

    if action == "cvmTryAdd" then
        cb(SV.cvmTryAdd(d.id,d.model,d.days,d.plate))
        return
    end

    if action == "cvmTryRemoveAll" then
        cb(SV.cvmTryRemoveAll(d.id))
        return
    end

    ----------------------------------------------------
    -- # GARAGE MANAGER (gmanager)
    ----------------------------------------------------

    if type(action) == "string" and action:sub(1,2) == "gm" and gmHandleNuiAction then
        if gmHandleNuiAction(action,d,cb) then return end
    end

    ----------------------------------------------------
    -- # VEHICLE REGISTER (vregister)
    ----------------------------------------------------

    if type(action) == "string" and action:sub(1,2) == "vr" and vrHandleNuiAction then
        if vrHandleNuiAction(action,d,cb) then return end
    end

    ----------------------------------------------------
    -- # MECHANICS
    ----------------------------------------------------

    if action == "tryCancelMechanicInvoice" then
        if d.plate then
            SV.tryCancelMechanicInvoice(d.plate)
        end
        cb(true)
        return
    end

    if action == "tryCallMechanicInvoice" then
        cb(SV.tryCallMechanicInvoice(d.plate))
        return
    end

    if action == "tryApplyMechanicInvoice" then
        cb(SV.tryApplyMechanicInvoice(d.plate))
        return
    end

    if not isValidMechanicVehicle() then
        SendNUIMessage({ action = "forceClose" })
        cb(false)
        return 
    end

    if action == "changeVehicleMod" then
        if d.modType ~= nil and d.modId ~= nil then
            local modType = (vehModList[tonumber(d.modType)] ~= nil) and tonumber(d.modType) or false
            if modType then
                local modId = tonumber(d.modId) or false
                if modId ~= false then
                    SetVehicleMod(mechanicVehicle,modType,modId)
                    cb(true)
                    updateMechanicCart(modType,modId)
                    return
                end
            end
        end
        cb(false)
        return
    end

    if action == "changeVehicleColor" then
        if d.type and d.color then
            if d.type == "primary" then
                local r,g,b = table.unpack(d.color)
                ClearVehicleCustomPrimaryColour(mechanicVehicle)
                SetVehicleCustomPrimaryColour(mechanicVehicle,r,g,b)
                updateMechanicCart("rbg-primary-color",d.color)
            elseif d.type == "secondary" then
                local r,g,b = table.unpack(d.color)
                ClearVehicleCustomSecondaryColour(mechanicVehicle)
                SetVehicleCustomSecondaryColour(mechanicVehicle,r,g,b)
                updateMechanicCart("rbg-secondary-color",d.color)
            elseif d.type == "smoke" then
                local r,g,b = table.unpack(d.color)
                ToggleVehicleMod(mechanicVehicle,20,true)
                SetVehicleTyreSmokeColor(mechanicVehicle,r,g,b)
                updateMechanicCart("rbg-smoke-color",d.color)
            end
            cb(true)
            return
        end
        cb(false)
        return
    end

    if action == "changeVehicleColorType" then
        if d.type then
            if vehColorTypes[d.type] then
                currentColorIndex = currentColorIndex + 1
                if currentColorIndex > #vehColorTypes[d.type] then currentColorIndex = 1 end
                if vehColorTypes[d.type][currentColorIndex] then
                    SetVehicleColours(mechanicVehicle,vehColorTypes[d.type][currentColorIndex],vehColorTypes[d.type][currentColorIndex])
                    updateMechanicCart("color-type",d.type)
                end
            end
        end
        cb(true)
        return
    end

    if action == "setVehicleExtraColour" then
        local pearlColor,wheelColor = GetVehicleExtraColours(mechanicVehicle)
        if d.type == "wheel" then
            if d._action == "remove" then
                SetVehicleExtraColours(mechanicVehicle,pearlColor,0)
                cb(true)
                updateMechanicCart("wheel-color",0)
                return
            end
            wheelColorIndex = (d._action == true) and (wheelColorIndex + 1) or (wheelColorIndex - 1)
            local max = #vehColorTypes["basic"]
            if wheelColorIndex <= 0 then wheelColorIndex = max elseif wheelColorIndex > max then wheelColorIndex = 1 end
            SetVehicleExtraColours(mechanicVehicle,pearlColor,wheelColorIndex)
            cb(true)
            updateMechanicCart("wheel-color",wheelColorIndex)
            return
        elseif d.type == "pearl" then
            if d._action == "remove" then
                SetVehicleExtraColours(mechanicVehicle,0,wheelColor)
                cb(true)
                updateMechanicCart("pearl-color",0)
                return
            end
            pearlColorIndex = (d._action == true) and (pearlColorIndex + 1) or (pearlColorIndex - 1)
            local max = #vehColorTypes["basic"]
            if pearlColorIndex <= 0 then pearlColorIndex = max elseif pearlColorIndex > max then pearlColorIndex = 1 end
            SetVehicleExtraColours(mechanicVehicle,pearlColorIndex,wheelColor)
            cb(true)
            updateMechanicCart("pearl-color",pearlColorIndex)
            return
        elseif d.type == "chameleon" then
            if d._action == "remove" then
                SetVehicleColours(mechanicVehicle,vehColorTypes["basic"][1],vehColorTypes["basic"][1])
                cb(true)
                updateMechanicCart("color-type","from-chameleon")
                return
            end
            chameleonColorIndex = (d._action == true) and (chameleonColorIndex + 1) or (chameleonColorIndex - 1)
            local max = #vehColorTypes["chameleon"]
            if chameleonColorIndex <= 0 then chameleonColorIndex = max elseif chameleonColorIndex > max then chameleonColorIndex = 1 end
            SetVehicleColours(mechanicVehicle,vehColorTypes[d.type][chameleonColorIndex],vehColorTypes[d.type][chameleonColorIndex])
            cb(true)
            updateMechanicCart("chameleon-color",chameleonColorIndex)
            return
        end
        cb(false)
        return
    end

    if action == "setVehicleLightStatus" then
        if d.type then
            if d.type == "neon" then
                for n = 0,3 do
                    SetVehicleNeonLightEnabled(mechanicVehicle,n,d.status)
                end
                updateMechanicCart("neon-enabled",d.status)
            elseif d.type == "xenon" then
                ToggleVehicleMod(mechanicVehicle,22,d.status)
                updateMechanicCart("xenon-enabled",d.status)
            end
        end
        cb(true)
        return
    end

    if action == "changeVehicleLightColor" then
        if d.type and d.color then
            if d.type == "neon" then
                local r,g,b = table.unpack(d.color)
                SetVehicleNeonLightsColour(mechanicVehicle,r,g,b)
                updateMechanicCart("neon-color",d.color)
            elseif d.type == "xenon" then
                local r,g,b = table.unpack(d.color)
                SetVehicleXenonLightsCustomColor(mechanicVehicle,r,g,b)
                updateMechanicCart("xenon-color",d.color)
            end
        end
        cb(true)
        return
    end

    if action == "changeVehicleWheel" then
        if d.type and d.id then
            local wheelType = (vehWheelTypes[d.type] ~= nil) and vehWheelTypes[d.type] or false
            if wheelType then
                SetVehicleWheelType(mechanicVehicle,wheelType)
                SetVehicleMod(mechanicVehicle,23,tonumber(d.id),GetVehicleModVariation(mechanicVehicle,23))
                if GetVehicleClass(mechanicVehicle) == 8 then
                    SetVehicleMod(mechanicVehicle,24,tonumber(d.id),GetVehicleModVariation(mechanicVehicle,24))
                end
                updateMechanicCart("wheel-type",d.type,d.id)
            end
        end
        cb(true)
        return
    end

    if action == "setVehicleCustomTyresEnabled" then
        SetVehicleMod(mechanicVehicle,23,GetVehicleMod(mechanicVehicle,23),d.status)
        if GetVehicleClass(mechanicVehicle) == 8 then
            SetVehicleMod(mechanicVehicle,24,GetVehicleMod(mechanicVehicle,24),d.status)
        end
        updateMechanicCart("atomic-custom",d.status)
        cb(true)
        return 
    end

    if action == "setVehicleTurboEnabled" then
        ToggleVehicleMod(mechanicVehicle,18,d.status)
        updateMechanicCart("turbo",d.status)
        cb(true)
        return
    end

    if action == "toggleFocus" then
        cb(true)
        mechanicFocused = not mechanicFocused
        SetNuiFocus(mechanicFocused,mechanicFocused)
        if not mechanicFocused then
            destroyMechanicCamera()
        end
        while not mechanicFocused and interfaceOpen do
            if IsControlJustPressed(0,47) then
                mechanicFocused = true
                SetNuiFocus(mechanicFocused,true)
                createMechanicCamera()
                break
            end
            Wait(0)
        end
        return
    end

    if action == "setVehicleWindowTint" then
        if d.id ~= nil and tonumber(d.id) ~= nil then
            SetVehicleWindowTint(mechanicVehicle,tonumber(d.id))
            updateMechanicCart("windowTint",tonumber(d.id))
        end
        cb(true)
        return
    end

    if action == "setVehiclePlateColor" then
        if d.id ~= nil and tonumber(d.id) ~= nil then
            SetVehicleNumberPlateTextIndex(mechanicVehicle,tonumber(d.id))
            updateMechanicCart("plate-color",tonumber(d.id))
        end
        cb(true)
        return
    end

    if action == "getCartTotal" then
        cb({ cart = mechanicCart.total })
        return
    end

    if action == "tryMechanicPayment" then
        local res = SV.tryMechanicPayment(mechanicCart.total,{ NetworkGetNetworkIdFromEntity(mechanicVehicle), mechanicVehicleData.model, mechanicVehicleData.plate })
        if res.saveNow then
            MV_OLD_MODS = getVehicleMods(mechanicVehicle)
            MV_RESET_MODS = getVehicleModsForSave(mechanicVehicle)
        end
        cb(res)
        return
    end

end)

------------------------------------------------------------------------------------------------------------------------
-- # Garage/Dealer NUI helpers
------------------------------------------------------------------------------------------------------------------------

CL.removeVehicleFromGarage = function(plate)
    if currentGarage ~= -1 or currentDealer ~= -1 then
        SendNUIMessage({ action = "removeVehicle", plate = plate })
    end
end

CL.updateVehicleTax = function(plate,time)
    if currentGarage ~= -1 then
        SendNUIMessage({ action = "updateVehicleTax", plate = plate, time = time })
    end
end

------------------------------------------------------------------------------------------------------------------------
-- # Resource Start
------------------------------------------------------------------------------------------------------------------------

AddEventHandler("onResourceStart",function(resource)
    if tostring(resource) == tostring(GetCurrentResourceName()) then
        if LocalPlayer.state.testDriveExit then
            DoScreenFadeIn()
            SetEntityCoords(PlayerPedId(),LocalPlayer.state.testDriveExit)
            DeleteEntity(testDriveVehicle)
            LocalPlayer.state.testDriveExit = nil
            SetPlayerControl(PlayerId(),true)
            TriggerServerEvent("core/resetRoute")
        else
            if LocalPlayer.state.modelViwerLC then
                LocalPlayer.state.modelViwerLC = nil
                SetPlayerControl(PlayerId(),true)
                deleteDealerModel(true,true)
                TriggerServerEvent("core/resetRoute")
            end
        end
    end
end)

------------------------------------------------------------------------------------------------------------------------
-- # Character Vehicle Manager
------------------------------------------------------------------------------------------------------------------------

CL.openCharacterVehManager = function(id,vehicles)
    if cooldown or interfaceOpen or not _intloaded or not dealerStock then
        return
    end
    SendNUIMessage({ action = "openCharacterVehManager", data = { id = id, vehicles = vehicles } })
    toggleHud(false)
    SetNuiFocus(true,true)
end

------------------------------------------------------------------------------------------------------------------------
-- # Apply Mods Event
------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent('core/vehicles/applyMods')
AddEventHandler('core/vehicles/applyMods',function(networkVehicle,mods)
    local t = 0
    while not NetworkDoesNetworkIdExist(networkVehicle) and t < 100 do
        t = t + 1
        Wait(50)
    end
    if NetworkDoesNetworkIdExist(networkVehicle) then
        local vehicle = NetworkGetEntityFromNetworkId(networkVehicle)
        if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
            if not isEmptyTable(mods) then
                setVehicleMods(vehicle,mods)
            end
        end
    end
end)
