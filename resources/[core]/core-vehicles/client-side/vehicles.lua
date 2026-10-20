local uncommonMods = { [18] = true,  [23] = true,  [24] = true }

getVehicleModsForSave = function(vehicle)

    local data = {}
    local vehMods = getVehicleMods(vehicle)

    if vehMods and type(vehMods) == "table" then
        data.m = vehMods.current
        data.c = { t = vehMods.colors.id, p = vehMods.colors.primary, s = vehMods.colors.secondary, ws = vehMods.colors.smoke, wc = vehMods.wheelColor, pl = vehMods.pearlColor }
        data.l = { n = vehMods.lights.neon or nil, x = vehMods.lights.xenon or nil }
        data.w = { t = vehMods.wheels.type, i = vehMods.wheels.id, c = vehMods.wheels.custom }
        data.t = vehMods.turbo
        data.wt = vehMods.wtint
        data.pc = vehMods.pcolor
    end

    return data

end

setVehicleMods = function(vehicle,data)

    if not vehicle or not DoesEntityExist(vehicle) then
        if debugMode then print("[DEBUG] : setVehicleMods : VEHICLE_NOT_EXISTS : "..vehicle) end
        return
    end

    if not data or type(data) ~= "table" then
        if debugMode then print("[DEBUG] : setVehicleMods : data ~= table : "..vehicle.." - "..data) end
        return 
    end

    SetVehicleModKit(vehicle,0)

    local m = (data.m and type(data.m) == "table") and data.m or false
    if m then
        for k,v in pairs(data.m) do
            SetVehicleMod(vehicle,tonumber(k),tonumber(v))
        end
    end

    local c = (data.c and type(data.c) == "table") and data.c or false
    if c then
        if c.t ~= nil and tonumber(c.t) ~= nil then
            SetVehicleColours(vehicle,tonumber(c.t),tonumber(c.t))
        end
        ClearVehicleCustomPrimaryColour(vehicle)
        ClearVehicleCustomSecondaryColour(vehicle)
        if c.p and type(c.p) == "table" and #c.p >= 3 then
            local pR,pG,pB = table.unpack(c.p)
            SetVehicleCustomPrimaryColour(vehicle,pR,pG,pB)
        end
        if c.s and type(c.s) == "table" and #c.s >= 3 then
            local sR,sG,sB = table.unpack(c.s)
            SetVehicleCustomSecondaryColour(vehicle,sR,sG,sB)
        end
        if c.ws and type(c.ws) == "table" and #c.ws >= 3 then
            ToggleVehicleMod(vehicle,20,true)
            local wR,wG,wB = table.unpack(c.ws)
            SetVehicleTyreSmokeColor(vehicle,wR,wG,wB)
        end
        local _wc,_pl = GetVehicleExtraColours(vehicle)
        if c.wc ~= nil and tonumber(c.wc) ~= nil then
            _wc = tonumber(c.wc)
        end
        if c.pl ~= nil and tonumber(c.pl) ~= nil then
            _pl = tonumber(c.pl)
        end
        SetVehicleExtraColours(vehicle,_pl,_wc)
    end

    local l = (data.l and type(data.l) == "table") and data.l or false
    if l then
        if l.n and type(l.n) == "table" and #l.n >= 3 then
            local nR,nG,nB = table.unpack(l.n)
            for n = 0,3 do
                SetVehicleNeonLightEnabled(vehicle,n,true)
            end
            SetVehicleNeonLightsColour(vehicle,nR,nG,nB)
        else
            for n = 0,3 do
                SetVehicleNeonLightEnabled(vehicle,n,false)
            end 
        end
        if l.x and type(l.x) == "table" and #l.x >= 3 then
            local xR,xG,xB = table.unpack(l.x)
            ToggleVehicleMod(vehicle,22,true)
            SetVehicleXenonLightsCustomColor(vehicle,xR,xG,xB)
        else
            ToggleVehicleMod(vehicle,22,false)
        end
    end

    ToggleVehicleMod(vehicle,18,parseInt(data.t))
    SetVehicleWindowTint(vehicle,tonumber(data.wt))
    SetVehicleNumberPlateTextIndex(vehicle,tonumber(data.pc))

    local w =  (data.w and type(data.w) == "table") and data.w or false
    if w then
        if w.t and w.i ~= nil and tonumber(w.i) ~= nil then
            local wt = (vehWheelTypes[w.t] ~= nil) and vehWheelTypes[w.t] or false
            if wt then
                SetVehicleWheelType(vehicle,wt)
                SetVehicleMod(vehicle,23,tonumber(w.i),w.c or false)
                if GetVehicleClass(vehicle) == 8 then
                    SetVehicleMod(vehicle,24,tonumber(w.i),w.c or false)
                end
            end
        end
    end

    if debugMode then print("[DEBUG] : setVehicleMods : mods setted : "..vehicle.." :\n"..json.encode(data,{ indent = true })) end

end

getVehicleMods = function(vehicle)

    local mods = { available = {}, current = {}, lights = {} }

    if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
        
        for modId,modName in pairs(vehModList) do
            if not uncommonMods[modId] then
                mods.available[modId] = GetNumVehicleMods(vehicle,modId)
                mods.current[modId] = GetVehicleMod(vehicle,modId)
            end
        end

        local vehColor,_ = GetVehicleColours(vehicle)
        local _colorType = ""
        for colorType,colorIds in pairs(vehColorTypes) do
            for _,colorId in pairs(colorIds) do
                if colorId == vehColor then
                    _colorType = colorType
                    break
                end
            end
        end

        mods.colors = {
            type = _colorType,
            id = vehColor,
            primary = table.pack(GetVehicleCustomPrimaryColour(vehicle)),
            secondary = table.pack(GetVehicleCustomSecondaryColour(vehicle)),
            smoke = table.pack(GetVehicleTyreSmokeColor(vehicle))
        }

        if mods.colors.primary.n then mods.colors.primary.n = nil end
        if mods.colors.secondary.n then mods.colors.secondary.n = nil end
        if mods.colors.smoke.n then mods.colors.smoke.n = nil end

        local pearlColor,wheelColor = GetVehicleExtraColours(vehicle)
        mods.pearlColor = pearlColor
        mods.wheelColor = wheelColor

        for n = 0,3 do
            if IsVehicleNeonLightEnabled(vehicle,n) then
                mods.lights.neon = table.pack(GetVehicleNeonLightsColour(vehicle))
                break
            end
        end

        if IsToggleModOn(vehicle,22) then
            local xenonColors = table.pack(GetVehicleXenonLightsCustomColor(vehicle))
            if xenonColors.n then
                xenonColors.n = nil
                table.remove(xenonColors,1)
            end
            mods.lights.xenon = xenonColors
        end

        local vehWheel = GetVehicleWheelType(vehicle)
        local _wheelType = ""
        for wheelType,wheelTypeIndex in pairs(vehWheelTypes) do
            if vehWheel == wheelTypeIndex then
                _wheelType = wheelType
                break
            end
        end
      
        local _customTyres = GetVehicleModVariation(vehicle,23) and 1 or 0
        mods.wheels = { type = _wheelType, id = GetVehicleMod(vehicle,23), custom = _customTyres }
        mods.available.wheels = {}
        for wheelType,wheelTypeIndex in pairs(vehWheelTypes) do
            SetVehicleWheelType(vehicle,wheelTypeIndex)
            local numWheels = GetNumVehicleMods(vehicle,23)
            if numWheels > 0 then
                mods.available.wheels[wheelType] = numWheels
            end
        end
        SetVehicleWheelType(vehicle,vehWheelTypes[mods.wheels.type])
        SetVehicleMod(vehicle,23,mods.wheels.id,mods.wheels.custom)
        if GetVehicleClass(vehicle) == 8 then
            for a,b in pairs(mods.available.wheels) do
                if not a:find("BIKE") then
                    mods.available.wheels[a] = nil
                end
            end
            SetVehicleMod(vehicle,24,mods.wheels.id,mods.wheels.custom)
        else
            mods.available.wheels["VWT_BIKE"] = nil
        end

        mods.turbo = IsToggleModOn(vehicle,18) and 1 or 0 

        mods.wtint = GetVehicleWindowTint(vehicle)

        mods.pcolor = GetVehicleNumberPlateTextIndex(vehicle)

    end

    return mods

end

getHexFromRGB = function(rgb)
    rgb = {rgb[1],rgb[2],rgb[3]}
	local hexadecimal = '#'
	for key,value in pairs(rgb) do
		local hex = ''
		while(value > 0)do
			local index = math.fmod(value, 16) + 1
			value = math.floor(value / 16)
			hex = string.sub('0123456789ABCDEF', index, index) .. hex			
		end
		if(string.len(hex) == 0)then
			hex = '00'
		elseif(string.len(hex) == 1)then
			hex = '0' .. hex
		end
		hexadecimal = hexadecimal .. hex
	end
	return hexadecimal
end

getDrivingVehicle = function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(),false)
    if vehicle then
        if GetPedInVehicleSeat(vehicle,-1) == PlayerPedId() then
            return vehicle
        end
    end
    return false
end

------------------------------------------------------------------------------------------------------------------------
-- # Vehicle Setup / Apply Mods
------------------------------------------------------------------------------------------------------------------------

CL.setupVehicle = function(networkVehicle,data)

    local t = 0
    while not NetworkDoesNetworkIdExist(networkVehicle) and t < 100 do
        t = t + 1
        Wait(50)
    end

    if NetworkDoesNetworkIdExist(networkVehicle) then
        local vehicle = NetworkGetEntityFromNetworkId(networkVehicle)
        if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
            if not isEmptyTable(data.m) then
                setVehicleMods(vehicle,data.m)
            end
            SetVehicleIsStolen(vehicle,false)
            SetVehicleNeedsToBeHotwired(vehicle,false)
            SetVehicleOnGroundProperly(vehicle)
            SetVehRadioStation(vehicle,"OFF")
            SetVehicleHasBeenOwnedByPlayer(vehicle,true)
            if data.h and type(data.h) and #data.h == 3 then
                SetVehicleEngineHealth(vehicle,data.h[2]+0.0)
                SetVehicleBodyHealth(vehicle,data.h[1]+0.0)
                SetVehicleFuelLevel(vehicle,data.h[3]+0.0)
            end
            local damages = data.d or false
            if damages then
                if damages.d and type(damages.d) == "table" then
                    for _,ds in pairs(damages.d) do
                        SetVehicleDoorBroken(vehicle,parseInt(ds),true)
                    end
                end
                if damages.w and type(damages.w) == "table" then
                    for _,ws in pairs(damages.w) do
                        SmashVehicleWindow(vehicle,parseInt(ws))
                    end
                end
                if damages.t and type(damages.t) == "table" then
                    for _,ts in pairs(damages.t) do
                        SetVehicleTyreBurst(vehicle,parseInt(ts),true,1000.01)
                    end
                end
                if damages.dl then
                    SetVehicleDirtLevel(vehicle,damages.dl+0.0)
                end
                if damages.df and type(damages.df) == "table" and not isEmptyTable(damages.df) then
                    _setVehicleDeforms(vehicle,damages.df)
                end
            end
        end
    end

end

CL.applyVehicleMods = function(networkVehicle,mods)

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

end

------------------------------------------------------------------------------------------------------------------------
-- # Vehicle Health / Deforms
------------------------------------------------------------------------------------------------------------------------

CL.getVehicleHealth = function(networkVehicle)
    if NetworkDoesNetworkIdExist(networkVehicle) then 
        local vehicle = NetworkGetEntityFromNetworkId(networkVehicle)
        if IsEntityAVehicle(vehicle) then
            local damages = { d = {}, w = {}, t = {} }
            for i = 0,5 do
                if IsVehicleDoorDamaged(vehicle,i) then
                    table.insert(damages.d,tostring(i)) 
                end
            end
            for i = 0,7 do
                if not IsVehicleWindowIntact(vehicle,i) then
                    table.insert(damages.w,tostring(i)) 
                end
            end
            for i = 0,7 do
                if GetTyreHealth(vehicle,i) < 900.0 then
                    table.insert(damages.t,tostring(i)) 
                end
            end
            damages.dl = GetVehicleDirtLevel(vehicle)
            damages.df = _getVehicleDeforms(vehicle)
            return { parseInt(GetVehicleBodyHealth(vehicle)),parseInt(GetVehicleEngineHealth(vehicle)),parseInt(GetVehicleFuelLevel(vehicle)) },damages
        end
    end
    return {1000,1000,100},{} 
end

getVehicleHealth = function(vehicle)
    if vehicle and DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
        local damages = { d = {}, w = {}, t = {} }
        for i = 0,5 do
            if IsVehicleDoorDamaged(vehicle,i) then
                table.insert(damages.d,tostring(i)) 
            end
        end
        for i = 0,7 do
            if not IsVehicleWindowIntact(vehicle,i) then
                table.insert(damages.w,tostring(i)) 
            end
        end
        for i = 0,7 do
            if GetTyreHealth(vehicle,i) < 900.0 then
                table.insert(damages.t,tostring(i)) 
            end
        end
        damages.dl = GetVehicleDirtLevel(vehicle)
        damages.df = _getVehicleDeforms(vehicle)
        return { parseInt(GetVehicleBodyHealth(vehicle)),parseInt(GetVehicleEngineHealth(vehicle)),parseInt(GetVehicleFuelLevel(vehicle)) },damages
    end
    return {1000,1000,100},{} 
end

_getVehicleDeforms = function(vehicle)
	local min, max = GetModelDimensions(GetEntityModel(vehicle))
	local X = (max.x - min.x) * 0.5
	local Y = (max.y - min.y) * 0.5
	local Z = (max.z - min.z) * 0.5
	local halfY = Y * 0.5
	local positions = {
		vector3(-X, Y,  0.0),
		vector3(-X, Y,  Z),
		vector3(0.0, Y,  0.0),
		vector3(0.0, Y,  Z),
		vector3(X, Y,  0.0),
		vector3(X, Y,  Z),
		vector3(-X, halfY,  0.0),
		vector3(-X, halfY,  Z),
		vector3(0.0, halfY,  0.0),
		vector3(0.0, halfY,  Z),
		vector3(X, halfY,  0.0),
		vector3(X, halfY,  Z),
		vector3(X, halfY,  Z),
		vector3(-X, 0.0,  0.0),
		vector3(-X, 0.0,  Z),
		vector3(0.0, 0.0,  0.0),
		vector3(0.0, 0.0,  Z),
		vector3(X, 0.0,  0.0),
		vector3(X, 0.0,  Z),
		vector3(-X, -halfY,  0.0),
		vector3(-X, -halfY,  Z),
		vector3(0.0, -halfY,  0.0),
		vector3(0.0, -halfY,  Z),
		vector3(X, -halfY,  0.0),
		vector3(X, -halfY,  Z),
		vector3(-X, -Y,  0.0),
		vector3(-X, -Y,  Z),
		vector3(0.0, -Y,  0.0),
		vector3(0.0, -Y,  Z),
		vector3(X, -Y,  0.0),
		vector3(X, -Y,  Z),
	}
	local deformationPoints = {}
	for i, pos in ipairs(positions) do
		local dmg = #(GetVehicleDeformationAtPos(vehicle, pos))
		if (dmg > 0.05) then
			table.insert(deformationPoints, { pos, dmg })
		end
	end
	return deformationPoints
end

_setVehicleDeforms = function(vehicle,deformationPoints)
	CreateThread(function()
		local min, max = GetModelDimensions(GetEntityModel(vehicle))
		local radius = #(max - min) * 40.0
		local damageMult = #(max - min) * 30.0
		for i, def in ipairs(deformationPoints) do
			def[1] = vector3(def[1].x, def[1].y, def[1].z)
		end
		local deform = true
		local iteration = 0
		while (deform and iteration < 200) do
			deform = false
			for i, def in ipairs(deformationPoints) do
				if (#(GetVehicleDeformationAtPos(vehicle, def[1])) < def[2]) then
					SetVehicleDamage(
						vehicle, 
						def[1] * 2.0, 
						def[2] * damageMult, 
						radius, 
						true
					)
					deform = true
				end
			end
			iteration = iteration + 1
			Wait(100)
		end
	end)
end

------------------------------------------------------------------------------------------------------------------------
-- # Admin Spawn / Despawn / Fix
------------------------------------------------------------------------------------------------------------------------

CL.getAdminSpawnPos = function()
    local ped = PlayerPedId()
    local x,y,z = table.unpack(GetEntityCoords(ped))
    local h = GetEntityHeading(ped)
    return {tD(x),tD(y),tD(z),tD(h)}
end

CL.getNearestVehicleForDespawn = function(fromGarage)
    local radius = (fromGarage ~= nil) and 30 or 10
    local hash,plate,lockState,networkVehicle = getNearestVehicle(radius)
    if plate and networkVehicle then
        local vehicle = NetworkGetEntityFromNetworkId(networkVehicle)
        if vehicle and IsEntityAVehicle(vehicle) then
            if fromGarage ~= nil and GetPedInVehicleSeat(vehicle,-1) ~= 0 then
                return false
            end
            plate = plate:gsub(" ","")
            local health,damages = CL.getVehicleHealth(networkVehicle)
            return networkVehicle,plate,health,damages,getVehicleIndex(hash),GetEntityCoords(PlayerPedId())
        end
    end
    return false
end

CL.getNearestVehiclesForDespawn = function(radius)
    local list = {}
    for vehicle,dist in pairs(getNearestVehicles(radius)) do
        if Entity(vehicle).state["veh-mods"] ~= nil then
            local hasPassengers = false
            for i = -1,10 do
                if GetPedInVehicleSeat(vehicle,i) ~= 0 then
                    hasPassengers = true
                    break
                end
            end
            if not hasPassengers then
                local health,damages = getVehicleHealth(vehicle)
                local _vehicle = {NetworkGetNetworkIdFromEntity(vehicle),GetVehicleNumberPlateText(vehicle):gsub(" ",""),health,damages}
                table.insert(list,_vehicle)
            end
        end
    end
    return list,GetEntityCoords(PlayerPedId())
end

CL.fixVehicle = function(networkVehicle)
    local t = 0
    while not NetworkDoesNetworkIdExist(networkVehicle) and t < 1000 do
        t = t + 1
        Wait(200)
    end
    if NetworkDoesNetworkIdExist(networkVehicle) then
        local vehicle = NetworkGetEntityFromNetworkId(networkVehicle)
        local fuel = GetVehicleFuelLevel(vehicle)
        SetVehicleEngineHealth(vehicle,1000.0)
        SetVehicleBodyHealth(vehicle,1000.0)
        SetVehicleFixed(vehicle)
        SetVehicleDirtLevel(vehicle,0.0)
        SetVehicleUndriveable(vehicle,false)
        InvokeNative(0xAD738C3085FE7E11,vehicle,true,true)
        SetVehicleOnGroundProperly(vehicle)
        SetVehicleFuelLevel(vehicle,fuel)
    end
end

CL.getInvoiceVehicle = function(plate)
    local invoiceVehicle = nil
    local vehicle = getDrivingVehicle()
    if vehicle then
        local vplate = GetVehicleNumberPlateText(vehicle):gsub(" ","")
        if vplate == plate then
            invoiceVehicle = NetworkGetNetworkIdFromEntity(vehicle)
        end
    end
    return invoiceVehicle
end

------------------------------------------------------------------------------------------------------------------------
-- # Plotagem (Liveries)
------------------------------------------------------------------------------------------------------------------------

local LIV_VEHICLES = {
    ['AGSg63hp'] = true,
    ['AGSquattrohp'] = true,
    ['AGSb412hp'] = true,
    ['AGSxrehp'] = true,
    ['AGSsprinterhp'] = true,
    ['AGSgt86pm'] = true,
    ['AGSlc500pm'] = true,
    ['AGSb412pm'] = true,
    ['AGSmd500pm'] = true,
    ['AGScb650pm'] = true,
    ['AGStigerpm'] = true,
    ['AGSm5pm'] = true,
    ['AGSquattropm'] = true,
    ['AGSteslapm'] = true,
    ['AGSamarokpm'] = true,
    ['AGSinsurgentpm'] = true,
    ['AGStundrapm'] = true,
    ['AGSx6pm'] = true,
}

RegisterCommand('plotagem',function(_,args)
    local ped = PlayerPedId()
    if not LocalPlayer.state['isPolice'] and not LocalPlayer.state['isHospital'] then
        return 
    end
    if IsPedSittingInAnyVehicle(ped) and args[1] then
        local vehicle = GetVehiclePedIsIn(ped)
        if vehicle and DoesEntityExist(vehicle) and LIV_VEHICLES[GetEntityModel(vehicle)] then
            local max = GetNumVehicleMods(vehicle,48)
            if max <= 0 then
                return TriggerEvent('Notify','negado','Nenhuma plotagem disponível para este veículo!',5000)
            end
            local index = tonumber(args[1])
            if index == nil or (index ~= nil and (index < -1 or index > max)) then
                return TriggerEvent('Notify','negado','Insira o ID de uma plotagem, entre <b>-1</b> e <b>'..max..'</b>',5000)
            end
            SetVehicleModKit(vehicle,0)
            SetVehicleMod(vehicle,48,index)
            return TriggerEvent('Notify','sucesso','Plotagem aplicada: <b>'..index..'</b>!',3000)
        end
    end
end)
