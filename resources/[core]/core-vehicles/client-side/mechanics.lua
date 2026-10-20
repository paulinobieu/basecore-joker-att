isValidMechanicVehicle = function()
    if mechanicVehicle and DoesEntityExist(mechanicVehicle) and IsEntityAVehicle(mechanicVehicle) then
        if mechanicVehicleData and mechanicVehicleData.model and GetEntityModel(mechanicVehicle) == mechanicVehicleData.model and mechanicVehicleData.plate and GetVehicleNumberPlateText(mechanicVehicle):gsub(" ","") == mechanicVehicleData.plate then
            return true
        end
    end
    return false
end

getPriceFromTable = function(table,mod,id)

    local price = 0

    if table and type(table) == "table" then

        if type(mod) == "number" then

            if mod == 11 or mod == 12 or mod == 13 or mod == 15 or mod == 16 then
                local itemKey = perfKeys[mod]
                local levelCost = (table.performance and table.performance.levelCosts and table.performance.levelCosts[itemKey]) and table.performance.levelCosts[itemKey] or 0
                price = ((id + 1) * levelCost)
            else
                local itemKey = tableNumberMods[mod] or false
                if itemKey and table[itemKey] then
                    local defaultPrice = table[itemKey].defaultPrice
                    price = (table[itemKey].customPrices and type(table[itemKey].customPrices == "table") and table[itemKey].customPrices[id]) and table[itemKey].customPrices[id] or (table[itemKey].defaultPrice) or 0
                end
            end

        elseif mod == "rgbColors" then

            if id == "paint" then
                price = (table.colors and table.colors.rgb) and table.colors.rgb or 0
            elseif id == "smoke" then
                price = (table.colors and table.colors.smoke) and table.colors.smoke or 0
            end

        elseif mod == "colorTypes" then

            price = (table.colors and table.colors.types and table.colors.types[id]) and table.colors.types[id] or 0

        elseif mod == "wheel-color" then

            price = (table.colors and table.colors.wheel) and table.colors.wheel or 0

        elseif mod == "pearl-color" then

            price = (table.colors and table.colors.pearl) and table.colors.pearl or 0

        elseif mod == "lights" then

            if id == "neon" then
                price = (table.lights and table.lights.neon) and table.lights.neon or 0
            elseif id == "xenon" then
                price = (table.lights and table.lights.xenon) and table.lights.xenon or 0
            elseif id == "rgb" then
                price = (table.lights and table.lights.rgb) and table.lights.rgb or 0
            end

        elseif mod == "turbo" then

            price = (table.performance and table.performance.turbo) and table.performance.turbo or 0 

        elseif mod == "wheel-type" then

            price = (table.wheels and table.wheels.customPrices and table.wheels.customPrices[id]) and table.wheels.customPrices[id] or (table.wheels.defaultPrice or 0)

        elseif mod == "atomic-custom" then

            price = (table.wheels and table.wheels["atomicCustom"]) and table.wheels["atomicCustom"] or 1000

        elseif mod == "window-tint" then

            price = (table.windowTints and table.windowTints[id]) and table.windowTints[id] or 0

        elseif mod == "plate-color" then

            price = (table.plateColors and table.plateColors[id]) and table.plateColors[id] or 0
            
        end

    end

    return price

end

updateMechanicCart = function(modType,modId,extra)

    if currentMechanic and currentMechanic.tunnings then

        local prices = currentMechanic.tunnings

        if type(modType) == "number" then

            local itemKey = "m-"..modType
            if MV_OLD_MODS.m[modType] == nil or (MV_OLD_MODS.m[modType] ~= nil and MV_OLD_MODS.m[modType] ~= modId) then
                mechanicCart.items[itemKey] = getPriceFromTable(prices,modType,modId)
            else
                mechanicCart.items[itemKey] = nil
            end

        elseif modType == "rbg-primary-color" or modType == "rbg-secondary-color" then

            local itemKey = modType == "rbg-primary-color" and "p" or "s"
            if isEqualTables(MV_OLD_MODS.c[itemKey],modId) then
                mechanicCart.items[modType] = nil
            else
                mechanicCart.items[modType] = getPriceFromTable(prices,"rgbColors","paint")
            end

        elseif modType == "rbg-smoke-color" then

            if isEqualTables(MV_OLD_MODS.c["ws"],modId) then
                mechanicCart.items[modType] = nil
            else
                mechanicCart.items[modType] = getPriceFromTable(prices,"rgbColors","smoke")
            end

        elseif modType == "color-type" then

            local oldType = getColorTypeName(MV_OLD_MODS.c.t)
            if oldType ~= modId or modId == "from-chameleon" then
                if mechanicCart.items["chameleon-color"] then
                    mechanicCart.items["chameleon-color"] = nil
                end
                if modId == "from-chameleon" then
                    modId = "basic"
                end
                if oldType ~= modId then
                    mechanicCart.items[modType] = getPriceFromTable(prices,"colorTypes",modId)
                end
            else
                mechanicCart.items[modType] = nil
            end

        elseif modType == "chameleon-color" then

            if getColorTypeName(MV_OLD_MODS.c.t) ~= "chameleon" or (getColorTypeName(MV_OLD_MODS.c.t) == "chameleon" and MV_OLD_MODS.c.t ~= modId) then
                if mechanicCart.items["color-type"] then
                    mechanicCart.items["color-type"] = nil
                end
                mechanicCart.items[modType] = getPriceFromTable(prices,"colorTypes","chameleon")
            else
                mechanicCart.items[modType] = nil
            end

        elseif modType == "pearl-color" then

            if MV_OLD_MODS.c.pl == nil or (MV_OLD_MODS.c.pl ~= nil and MV_OLD_MODS.c.pl ~= modId) then
                mechanicCart.items[modType] = getPriceFromTable(prices,"pearl-color",modId)
            else
                mechanicCart.items[modType] = nil
            end

        elseif modType == "wheel-color" then

            if MV_OLD_MODS.c.wc == nil or (MV_OLD_MODS.c.wc ~= nil and MV_OLD_MODS.c.wc ~= modId) then
                mechanicCart.items[modType] = getPriceFromTable(prices,"wheel-color",modId)
            else
                mechanicCart.items[modType] = nil
            end

        elseif modType == "neon-enabled" then

            if modId and MV_OLD_MODS.l.n == nil then
                mechanicCart.items[modType] = getPriceFromTable(prices,"lights","neon")
            elseif not modId and MV_OLD_MODS.l.n ~= nil then
                mechanicCart.items[modType] = getPriceFromTable(prices,"lights","neon")
            else
                mechanicCart.items[modType] = nil
            end

        elseif modType == "xenon-enabled" then

            if modId and MV_OLD_MODS.l.x == nil then
                mechanicCart.items[modType] = getPriceFromTable(prices,"lights","xenon")
            elseif not modId and MV_OLD_MODS.l.x ~= nil then
                mechanicCart.items[modType] = getPriceFromTable(prices,"lights","xenon")
            else
                mechanicCart.items[modType] = nil
            end
          
        elseif modType == "neon-color" then

            if MV_OLD_MODS.l.n == nil or (MV_OLD_MODS.l.n ~= nil and not isEqualTables(MV_OLD_MODS.l.n,modId)) then
                mechanicCart.items[modType] = getPriceFromTable(prices,"lights","rgb")
            else
                mechanicCart.items[modType] = nil
            end

        elseif modType == "xenon-color" then

            if MV_OLD_MODS.l.x == nil or (MV_OLD_MODS.l.x ~= nil and not isEqualTables(MV_OLD_MODS.l.x,modId)) then
                mechanicCart.items[modType] = getPriceFromTable(prices,"lights","rgb")
            else
                mechanicCart.items[modType] = nil
            end

        elseif modType == "turbo" then

            modId = modId and 1 or 0
            if modId ~= parseInt(MV_OLD_MODS.t) then
                mechanicCart.items[modType] = getPriceFromTable(prices,"turbo")
            else
                mechanicCart.items[modType] = nil
            end

        elseif modType == "atomic-custom" then

            modId = modId and 1 or 0
            if not MV_OLD_MODS.w.c or MV_OLD_MODS.w.c and modId ~= parseInt(MV_OLD_MODS.w.c) then
                mechanicCart.items[modType] = getPriceFromTable(prices,"atomic-custom")
            else
                mechanicCart.items[modType] = nil
            end

        elseif modType == "wheel-type" then

            if modId ~= MV_OLD_MODS.w.t or extra ~= MV_OLD_MODS.w.i then
                mechanicCart.items[modType] = getPriceFromTable(prices,"wheel-type",modId)
            else
                mechanicCart.items[modType] = nil
            end

        elseif modType == "windowTint" then

            if modId ~= MV_OLD_MODS.wt then
                mechanicCart.items[modType] = getPriceFromTable(prices,"window-tint",modId)
            else
                mechanicCart.items[modType] = nil
            end

        elseif modType == "plate-color" then

            if modId ~= MV_OLD_MODS.pc then
                mechanicCart.items[modType] = getPriceFromTable(prices,"plate-color",modId)
            else
                mechanicCart.items[modType] = nil
            end

        end

    end

    local _total = 0
    for item,value in pairs(mechanicCart.items) do
        _total = _total + value
    end
    mechanicCart.total = _total

    SendNUIMessage({ action = "updateMechanicCart", total = mechanicCart.total })

end

getColorTypeName = function(colorTypeId)
    for name,ids in pairs(vehColorTypes) do
        for _,id in ipairs(ids) do
            if id == colorTypeId then
                return name
            end
        end
    end
    return ""
end

RegisterNUICallback("mechanic", function(d,cb)
    local action = d.action
end)

------------------------------------------------------------------------------------------------------------------------
-- # Mechanic Camera
------------------------------------------------------------------------------------------------------------------------

createMechanicCamera = function()
    if mechanicCamera then
        destroyMechanicCamera()
    end
    mechanicCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    local d = GetModelDimensions(GetEntityModel(mechanicVehicle))
    local length,width,height = d.y*-2, d.x*-2, d.z*-2
    local ox,oy,oz = table.unpack(GetOffsetFromEntityInWorldCoords(mechanicVehicle, -2.5, (length/2)+ 1.0, 1.0))
    SetCamCoord(mechanicCamera,ox,oy,oz) 
    PointCamAtCoord(mechanicCamera,GetOffsetFromEntityInWorldCoords(mechanicVehicle,0,0,_f(0))) 
    RenderScriptCams(true,false,0,true,false)
end

_f = function(n) return (n + 0.00001) end

destroyMechanicCamera = function()
    if mechanicCamera then
        RenderScriptCams(false, false, 0, true, false)
        SetCamActive(GetRenderingCam(),true)
        DestroyCam(mechanicCamera, false)
    end
end

------------------------------------------------------------------------------------------------------------------------
-- # Mechanic Reset/Open
------------------------------------------------------------------------------------------------------------------------

resetMechanic = function()
    DoScreenFadeOut(500)
    Wait(500)
    if mechanicVehicle and DoesEntityExist(mechanicVehicle) then
        FreezeEntityPosition(mechanicVehicle,false)
        SetVehicleLights(mechanicVehicle,0)
        setVehicleMods(mechanicVehicle,MV_RESET_MODS)
        MV_RESET_MODS = nil
        MV_OLD_MODS = nil
    end
    destroyMechanicCamera()
    Wait(50)
    SV.resetMechanicOpen()
    mechanicVehicle = nil
    mechanicVehicleData = nil
    currentMechanic = nil
    DoScreenFadeIn(500)
end

openMechanic = function(id)

    if not MechanicEnabled() then
        return
    end

    if cooldown or interfaceOpen or not _intloaded or not mechanics[id] then
        return
    end

    local currentVehicle = getDrivingVehicle()
    if not currentVehicle then
        return
    end

    cooldown = true

    currentColorIndex = 0
    metalColorIndex = 0
    pearlColorIndex = 0
    wheelColorIndex = 0
    chameleonColorIndex = 0

    local networkVehicle = NetworkGetNetworkIdFromEntity(currentVehicle)
    local vehicleModel = GetEntityModel(currentVehicle)
    local vehiclePlate = GetVehicleNumberPlateText(currentVehicle):gsub(" ","")

    local perm = SV.canOpenMechanic(id,{networkVehicle,vehicleModel,vehiclePlate})
    if perm then

        mechanicCart = { total = 0, items = {} }
        currentMechanic = mechanics[id]
        
        FreezeEntityPosition(currentVehicle,true)
        SetVehicleModKit(currentVehicle,0)

        MV_OLD_MODS = cloneTable(getVehicleModsForSave(currentVehicle))
        MV_RESET_MODS = cloneTable(MV_OLD_MODS)

        local _data = {
            modList = vehModList,
            vehicleMods = getVehicleMods(currentVehicle),
        }

        _data.vehicleMods.colors.primary = getHexFromRGB(_data.vehicleMods.colors.primary)
        _data.vehicleMods.colors.secondary = getHexFromRGB(_data.vehicleMods.colors.secondary)
        _data.vehicleMods.colors.smoke = getHexFromRGB(_data.vehicleMods.colors.smoke)

        if _data.vehicleMods.lights then
            if _data.vehicleMods.lights.neon then
                _data.vehicleMods.lights.neon = getHexFromRGB(_data.vehicleMods.lights.neon)
            end
            if _data.vehicleMods.lights.xenon then
                _data.vehicleMods.lights.xenon = getHexFromRGB(_data.vehicleMods.lights.xenon)
            end
        end

        toggleHud(false)
        SetVehicleLights(currentVehicle,2)

        DoScreenFadeOut(500)
        Wait(502)

        mechanicVehicle = currentVehicle
        mechanicVehicleData = { model = vehicleModel, plate = vehiclePlate }

        createMechanicCamera()
        cooldown = false
        interfaceOpen = true
        mechanicFocused = true

        _data.disablePerfTunnings = currentMechanic.disablePerfTunnings or false
        _data.onlyPerfTunnings = currentMechanic.onlyPerfTunnings or false
        SetNuiFocus(true,true)
        SendNUIMessage({ action = "openMechanic", data = _data })

        Wait(200)
        DoScreenFadeIn(500)

        return

    end
    
    SetTimeout(2000,function()
        cooldown = false
    end)


end

openAdminMechanic = function()

    if not MechanicEnabled() then
        return
    end

    if cooldown or interfaceOpen then
        return
    end

    if not _intloaded then
        _intloaded = true
    end

    local currentVehicle = GetVehiclePedIsIn(PlayerPedId(),false)
    if not currentVehicle or currentVehicle == 0 then
        local _,_,_,networkVehicle = getNearestVehicle(8)
        if networkVehicle and NetworkDoesNetworkIdExist(networkVehicle) then
            currentVehicle = NetworkGetEntityFromNetworkId(networkVehicle)
        end
    end

    if not currentVehicle or not DoesEntityExist(currentVehicle) or not IsEntityAVehicle(currentVehicle) then
        TriggerEvent("Notify","amarelo","Entre em um veículo ou aproxime-se dele para abrir a mecânica.",5000)
        return
    end

    local mechanicId = nil
    for id,_ in pairs(mechanics) do
        mechanicId = id
        break
    end
    if not mechanicId or not mechanics[mechanicId] then
        return
    end

    cooldown = true

    currentColorIndex = 0
    metalColorIndex = 0
    pearlColorIndex = 0
    wheelColorIndex = 0
    chameleonColorIndex = 0

    local networkVehicle = NetworkGetNetworkIdFromEntity(currentVehicle)
    local vehicleModel = GetEntityModel(currentVehicle)
    local vehiclePlate = GetVehicleNumberPlateText(currentVehicle):gsub(" ","")

    local perm = SV.canOpenMechanicAdmin(mechanicId,{ networkVehicle, vehicleModel, vehiclePlate })
    if perm then

        mechanicCart = { total = 0, items = {} }
        currentMechanic = mechanics[mechanicId]

        FreezeEntityPosition(currentVehicle,true)
        SetVehicleModKit(currentVehicle,0)

        MV_OLD_MODS = cloneTable(getVehicleModsForSave(currentVehicle))
        MV_RESET_MODS = cloneTable(MV_OLD_MODS)

        local data = {
            modList = vehModList,
            vehicleMods = getVehicleMods(currentVehicle),
        }

        data.vehicleMods.colors.primary = getHexFromRGB(data.vehicleMods.colors.primary)
        data.vehicleMods.colors.secondary = getHexFromRGB(data.vehicleMods.colors.secondary)
        data.vehicleMods.colors.smoke = getHexFromRGB(data.vehicleMods.colors.smoke)

        if data.vehicleMods.lights then
            if data.vehicleMods.lights.neon then
                data.vehicleMods.lights.neon = getHexFromRGB(data.vehicleMods.lights.neon)
            end
            if data.vehicleMods.lights.xenon then
                data.vehicleMods.lights.xenon = getHexFromRGB(data.vehicleMods.lights.xenon)
            end
        end

        toggleHud(false)
        SetVehicleLights(currentVehicle,2)

        DoScreenFadeOut(500)
        Wait(502)

        mechanicVehicle = currentVehicle
        mechanicVehicleData = { model = vehicleModel, plate = vehiclePlate }

        createMechanicCamera()
        cooldown = false
        interfaceOpen = true
        mechanicFocused = true

        data.disablePerfTunnings = false
        data.onlyPerfTunnings = false
        SetNuiFocus(true,true)
        SendNUIMessage({ action = "openMechanic", data = data })

        Wait(200)
        DoScreenFadeIn(500)

        return
    end

    TriggerEvent("Notify","amarelo","Você não tem permissão para usar a mecânica administrativa.",5000)
    SetTimeout(2000,function()
        cooldown = false
    end)
end

CL.getMechVehicleMods = function()
    if isValidMechanicVehicle() then
        return NetworkGetNetworkIdFromEntity(mechanicVehicle),mechanicVehicleData.model,mechanicVehicleData.plate,getVehicleModsForSave(mechanicVehicle)
    end
    return false,false,false,false
end

CL.showMechanicInvoices = function(_id,_invoices)

    if cooldown or interfaceOpen or not _intloaded or not mechanics[_id] then
        return
    end
    
    local _currentVehicle = false
    
    local vehicle = getDrivingVehicle()
    if vehicle then
        _currentVehicle = GetVehicleNumberPlateText(vehicle):gsub(" ","")
    end

    SetNuiFocus(true,true)
    SendNUIMessage({ action = "showMechanicInvoices", id = _id, invoices = _invoices, currentVehicle = _currentVehicle })

end

RegisterCommand("vtuning",function(source,args)
	local vehicle = GetVehiclePedIsUsing(PlayerPedId())
	if IsEntityAVehicle(vehicle) then
        
		local motor = GetVehicleMod(vehicle,11)
		local freio = GetVehicleMod(vehicle,12)
		local transmissao = GetVehicleMod(vehicle,13)
		local suspensao = GetVehicleMod(vehicle,15)
		local blindagem = GetVehicleMod(vehicle,16)
		local body = GetVehicleBodyHealth(vehicle)
		local engine = GetVehicleEngineHealth(vehicle)
		local fuel = GetVehicleFuelLevel(vehicle)

		if motor == -1 then
			motor = "Desativado"
		elseif motor == 0 then
			motor = "Nível 1 / "..GetNumVehicleMods(vehicle,11)
		elseif motor == 1 then
			motor = "Nível 2 / "..GetNumVehicleMods(vehicle,11)
		elseif motor == 2 then
			motor = "Nível 3 / "..GetNumVehicleMods(vehicle,11)
		elseif motor == 3 then
			motor = "Nível 4 / "..GetNumVehicleMods(vehicle,11)
		elseif motor == 4 then
			motor = "Nível 5 / "..GetNumVehicleMods(vehicle,11)
		end

		if freio == -1 then
			freio = "Desativado"
		elseif freio == 0 then
			freio = "Nível 1 / "..GetNumVehicleMods(vehicle,12)
		elseif freio == 1 then
			freio = "Nível 2 / "..GetNumVehicleMods(vehicle,12)
		elseif freio == 2 then
			freio = "Nível 3 / "..GetNumVehicleMods(vehicle,12)
		end

		if transmissao == -1 then
			transmissao = "Desativado"
		elseif transmissao == 0 then
			transmissao = "Nível 1 / "..GetNumVehicleMods(vehicle,13)
		elseif transmissao == 1 then
			transmissao = "Nível 2 / "..GetNumVehicleMods(vehicle,13)
		elseif transmissao == 2 then
			transmissao = "Nível 3 / "..GetNumVehicleMods(vehicle,13)
		elseif transmissao == 3 then
			transmissao = "Nível 4 / "..GetNumVehicleMods(vehicle,13)
		end

		if suspensao == -1 then
			suspensao = "Desativado"
		elseif suspensao == 0 then
			suspensao = "Nível 1 / "..GetNumVehicleMods(vehicle,15)
		elseif suspensao == 1 then
			suspensao = "Nível 2 / "..GetNumVehicleMods(vehicle,15)
		elseif suspensao == 2 then
			suspensao = "Nível 3 / "..GetNumVehicleMods(vehicle,15)
		elseif suspensao == 3 then
			suspensao = "Nível 4 / "..GetNumVehicleMods(vehicle,15)
		end

		if blindagem == -1 then
			blindagem = "Desativado"
		elseif blindagem == 0 then
			blindagem = "Nível 1 / "..GetNumVehicleMods(vehicle,16)
		elseif blindagem == 1 then
			blindagem = "Nível 2 / "..GetNumVehicleMods(vehicle,16)
		elseif blindagem == 2 then
			blindagem = "Nível 3 / "..GetNumVehicleMods(vehicle,16)
		elseif blindagem == 3 then
			blindagem = "Nível 4 / "..GetNumVehicleMods(vehicle,16)
		elseif blindagem == 4 then
			blindagem = "Nível 5 / "..GetNumVehicleMods(vehicle,16)
		end

		local turbo = IsToggleModOn(vehicle,18)
		if turbo then turbo = "Ativado" else turbo = "Desativado" end

		TriggerEvent("Notify","importante","<b>Turbo: </b>"..turbo.."<br><b>Motor:</b> "..motor.."<br><b>Freio:</b> "..freio.."<br><b>Transmissão:</b> "..transmissao.."<br><b>Suspensão:</b> "..suspensao.."<br><b>Blindagem:</b> "..blindagem.."<br><b>Chassi:</b> "..parseInt(body/10).."%<br><b>Engine:</b> "..parseInt(engine/10).."%<br><b>Gasolina:</b> "..parseInt(fuel).."%",30000)
	end
end)

RegisterCommand("lscustoms",function()
    openAdminMechanic()
end)

RegisterCommand("mecanica",function()
    openAdminMechanic()
end)
