trackVehicle = function(name,plate,pos)

    local x,y,z = table.unpack(pos)
    local blip = AddBlipForCoord(x,y,z)
    SetBlipSprite(blip,119)
    SetBlipColour(blip,47)
    SetBlipScale(blip,1.0)
    SetBlipAsShortRange(blip,true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name.." #"..plate)
    EndTextCommandSetBlipName(blip)
    SetTimeout(120000,function()
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end)

end

openGarage = function(garageId)
    
    if cooldown or not _intloaded or not garages then
        return
    end

    local data = SV.getGarageData(garageId)
    if data then
        interfaceOpen = true
        currentGarage = parseInt(garageId)
        toggleHud(false)
        SetNuiFocus(true,true)
        SendNUIMessage({ action = "openGarage", data = data })
    end

end

CL.getFreeGarageSpawn = function()
    local garage = garages[parseInt(currentGarage)] or false
    if not (garage and garage.spawns and type(garage.spawns) == "table") then
        return false
    end
    
    local vehicles = GetGamePool('CVehicle')
    local occupied = {}

    for _, vehicle in pairs(vehicles) do
        local vehicleCoords = GetEntityCoords(vehicle)
        local bestIdx, bestDist = nil, 7.0

        for idx, pos in ipairs(garage.spawns) do
            if pos and type(pos) == "table" and #pos >= 4 then
                local distance = #(vector3(pos[1], pos[2], pos[3]) - vehicleCoords)
                if distance < bestDist then
                    bestDist = distance
                    bestIdx = idx
                end
            end
        end

        if bestIdx then
            occupied[bestIdx] = true
        end
    end

    for idx, pos in ipairs(garage.spawns) do
        if pos and type(pos) == "table" and #pos >= 4 and not occupied[idx] then
            return pos
        end
    end

    return false
end

CL.isValidModel = function(modelName)
    return IsModelValid(GetHashKey(modelName))
end

CL.vehicleLockToggle = function(networkVehicle)
    CreateThread(function()
        local t = 0
        while not NetworkDoesNetworkIdExist(networkVehicle) and t < 1000 do
            t = t + 1
            Wait(200)
        end
        if NetworkDoesNetworkIdExist(networkVehicle) then
            local vehicle = NetworkGetEntityFromNetworkId(networkVehicle)
            if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
                SetVehicleLights(vehicle,2)
                Wait(200)
                SetVehicleLights(vehicle,0)
                Wait(200)
                SetVehicleLights(vehicle,2)
                Wait(200)
                SetVehicleLights(vehicle,0)
            end
            if #(GetEntityCoords(vehicle)-GetEntityCoords(PlayerPedId())) <= 10 then
                SendNUIMessage({ action = "playLockSound" })
            end
        end
    end)
end
