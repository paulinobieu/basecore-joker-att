blips = {}
garageBlips    = {} -- [id] = blipHandle
garageInteracts = {} -- [id] = { coordId = "...", name = "..." }

CreateThread(function()

    for id,garage in pairs(garages) do
        createGarageBlip(id,garage)
    end

    for _,dealer in pairs(dealerships) do
        if dealer.coords and type(dealer.coords) == "table" and #dealer.coords >= 3 then
            if dealer.blips and dealer.blips.enabled then
                local x,y,z = table.unpack(dealer.coords)
                local blip = AddBlipForCoord(x,y,z)
                SetBlipSprite(blip,dealer.blips.id)
                SetBlipColour(blip,dealer.blips.color)
                SetBlipScale(blip,dealer.blips.size)
                SetBlipAsShortRange(blip,true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(dealer.blips.name)
                EndTextCommandSetBlipName(blip)
            end
            local dx,dy,dz = table.unpack(dealer.coords)
            exports.sleepless_interact:addCoords(vec3(dx, dy, dz), {
                name = "dealership_" .. tostring(_),
                label = "Abrir Concessionária",
                icon = "car",
                distance = 5.0,
                onSelect = function()
                    openDealership(_)
                end,
                canInteract = function(entity, distance)
                    return not interfaceOpen
                end,
            })
        end
    end

    for id,mechanic in pairs(mechanics) do
        if not MechanicEnabled() then break end
        if mechanic.blips and mechanic.blips.enabled and mechanic.coords and mechanic.coords[1] and type(mechanic.coords[1]) == "table" and #mechanic.coords[1] >= 3 then
            local x,y,z = table.unpack(mechanic.coords[1])
            local blip = AddBlipForCoord(x,y,z)
            SetBlipSprite(blip,mechanic.blips.id)
            SetBlipColour(blip,mechanic.blips.color)
            SetBlipScale(blip,mechanic.blips.size)
            SetBlipAsShortRange(blip,true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(mechanic.blips.name)
            EndTextCommandSetBlipName(blip)
        end
        for ci,coord in pairs(mechanic.coords) do
            local mx,my,mz = table.unpack(coord)
            exports.sleepless_interact:addCoords(vec3(mx, my, mz), {
                name = "mechanic_" .. tostring(id) .. "_" .. tostring(ci),
                label = "Abrir Mecânica",
                icon = "wrench",
                distance = 3.0,
                allowInVehicle = true,
                onSelect = function()
                    openMechanic(id)
                end,
                canInteract = function(entity, distance)
                    return not interfaceOpen
                end,
            })
        end
    end

end)

createGarageBlip = function(id,garage)
    if garage.open and type(garage.open) == "table" and #garage.open >= 3 then
        if garage.blip and garage.blip.enabled then
            local x,y,z = table.unpack(garage.open)
            local blip = AddBlipForCoord(x,y,z)
            SetBlipSprite(blip,garage.blip.icon)
            SetBlipColour(blip,garage.blip.color)
            SetBlipScale(blip,garage.blip.size)
            SetBlipAsShortRange(blip,true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(garage.name)
            EndTextCommandSetBlipName(blip)
            garageBlips[id] = blip
        end
        local gx,gy,gz = table.unpack(garage.open)
        local interactName = "garage_" .. tostring(id)
        local ok,coordId = pcall(function()
            return exports.sleepless_interact:addCoords(vec3(gx, gy, gz), {
                name = interactName,
                label = "Abrir Garagem",
                icon = "warehouse",
                distance = 2.0,
                onSelect = function()
                    openGarage(id)
                end,
                canInteract = function(entity, distance)
                    return not interfaceOpen
                end,
            })
        end)
        if ok and coordId then
            garageInteracts[id] = { coordId = coordId, name = interactName }
        end
    end
end

removeGarageBlip = function(id)
    if garageBlips[id] then
        if DoesBlipExist(garageBlips[id]) then
            RemoveBlip(garageBlips[id])
        end
        garageBlips[id] = nil
    end
    if garageInteracts[id] then
        pcall(function()
            exports.sleepless_interact:removeCoords(garageInteracts[id].coordId, garageInteracts[id].name)
        end)
        garageInteracts[id] = nil
    end
end

-- Exports leves para integração via StateBag.
-- Outros recursos chamam estes diretamente no cliente; o estado do servidor
-- precisa estar populado em paralelo (via registerGarage/unregisterGarage).
exports('renderGarage',function(id,garage)
    if not id or type(garage) ~= 'table' then return end
    if garages then garages[id] = garage end
    createGarageBlip(id,garage)
end)

exports('unrenderGarage',function(id)
    if garages and garages[id] then garages[id] = nil end
    removeGarageBlip(id)
end)

------------------------------------------------------------------------------------------------------------------------
-- # AI Vehicle Lock
------------------------------------------------------------------------------------------------------------------------

local hotwiring = false
local hotwireCooldown = 0
local hotwiredVehicle = nil

CreateThread(function()
    if autoLockAIVehicles then
        AddEventHandler("gameEventTriggered",function(event,entity)
            if event == "CEventNetworkPlayerEnteredVehicle" then
                if entity[1] == PlayerId() then
                    local vehicle = entity[2]
                    local plate = GetVehicleNumberPlateText(vehicle):gsub(" ","")
                    -- Só o tráfego gerado pelo jogo entra no bloqueio. Antes bastava
                    -- não ter a State Bag `veh-mods` para o veículo ser tratado como
                    -- de NPC, então tudo que era criado fora do createNetVehicle
                    -- (valet do celular, fuelstations, empregos) nascia travado.
                    if plate ~= testDrive.plate and isAmbientVehicle(vehicle) and not isAIVehicleUnlocked(vehicle) then
                        lockAIVehicle(vehicle)
                    end
                end
            end
        end)
    end
end)

lockAIVehicle = function(vehicle)
    CreateThread(function()
        local hinted = false

        while IsPedInAnyVehicle(PlayerPedId(),true) and GetVehiclePedIsIn(PlayerPedId(),true) == vehicle do
            if not vehicle or not DoesEntityExist(vehicle) or not IsEntityAVehicle(vehicle) then
                break
            end
            if isAIVehicleUnlocked(vehicle) or hotwiredVehicle == vehicle then
                break
            end

            DisableControlAction(0,20)
            DisableControlAction(0,33)
            SetVehicleEngineOn(vehicle,false,true,true)

            if aiVehicleHotwire.enabled and GetPedInVehicleSeat(vehicle,-1) == PlayerPedId() then
                if not hinted then
                    hinted = true
                    notify(nil,'AI_VEHICLE_HOTWIRE_HINT',{ ['@key'] = aiVehicleHotwire.key })
                end

                if IsDisabledControlJustPressed(0,aiVehicleHotwire.control) then
                    hotwireAIVehicle(vehicle)
                end
            end

            Wait(0)
        end

        -- Liga o motor aqui, e não na thread do minigame, para não disputar o
        -- SetVehicleEngineOn(false) do último frame do bloqueio.
        if hotwiredVehicle == vehicle then
            hotwiredVehicle = nil

            if DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle,-1) == PlayerPedId() then
                SetVehicleUndriveable(vehicle,false)
                SetVehicleEngineOn(vehicle,true,false,true)
            end
        end
    end)
end

------------------------------------------------------------------------------------------------------------------------
-- # AI Vehicle Hotwire
------------------------------------------------------------------------------------------------------------------------

-- Veículo de NPC furtado permanece desligado: ligar o motor exige passar no
-- minigame de fios. O servidor é quem grava a State Bag `Hotwire`, que libera o
-- veículo em definitivo (inclusive para quem entrar depois).
hotwireAIVehicle = function(vehicle)
    if hotwiring or GetGameTimer() < hotwireCooldown then
        return false
    end

    hotwiring = true

    CreateThread(function()
        local success = exports.wiregame:WireGame(aiVehicleHotwire.duration)
        hotwireCooldown = GetGameTimer() + aiVehicleHotwire.cooldown

        if not success then
            notify(nil,'AI_VEHICLE_HOTWIRE_FAILED')
        elseif DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle,-1) == PlayerPedId() and SV.hotwireAIVehicle(VehToNet(vehicle)) then
            hotwiredVehicle = vehicle
            notify(nil,'AI_VEHICLE_HOTWIRE_SUCCESS')
        else
            notify(nil,'AI_VEHICLE_HOTWIRE_FAILED')
        end

        hotwiring = false
    end)

    return true
end

------------------------------------------------------------------------------------------------------------------------
-- # Test Drive Thread
------------------------------------------------------------------------------------------------------------------------

testDriveThread = function()
    CreateThread(function()
        while LocalPlayer.state.testDriveExit do
            DisableControlAction(0,75,true)
			DisableControlAction(27,75,true)
            if IsControlJustPressed(0,38) then
                tryEndTestDrive()
            end
            Wait(0)
        end
    end)
end

------------------------------------------------------------------------------------------------------------------------
-- # Vehicle Setup Event (legacy)
------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent('setupVehicleCustom')
AddEventHandler('setupVehicleCustom',function(networkVehicle,health,damages)
    if NetworkDoesNetworkIdExist(networkVehicle) and NetworkDoesEntityExistWithNetworkId(networkVehicle) then
        local vehicle = NetworkGetEntityFromNetworkId(networkVehicle)
        if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
            SetVehicleIsStolen(vehicle,false)
            SetVehicleNeedsToBeHotwired(vehicle,false)
            SetVehicleOnGroundProperly(vehicle)
            SetVehRadioStation(vehicle,"OFF")
            SetVehicleHasBeenOwnedByPlayer(vehicle,true)
            if type(health) == "table" and #health == 3 then
                SetVehicleEngineHealth(vehicle,health[2]+0.0)
                SetVehicleBodyHealth(vehicle,health[1]+0.0)
                SetVehicleFuelLevel(vehicle,health[3]+0.0)
            end
            if type(damages) == 'table' then
                if type(damages.d) == "table" then
                    for _,ds in pairs(damages.d) do
                        SetVehicleDoorBroken(vehicle,parseInt(ds),true)
                    end
                end
                if type(damages.w) == "table" then
                    for _,ws in pairs(damages.w) do
                        SmashVehicleWindow(vehicle,parseInt(ws))
                    end
                end
                if type(damages.t) == "table" then
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
end)

------------------------------------------------------------------------------------------------------------------------
-- # Anti-Eject Thread
------------------------------------------------------------------------------------------------------------------------

CreateThread(function()
    while true do
        local sleep = 200
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped)
        if vehicle ~= 0 and GetPedInVehicleSeat(vehicle,0) == ped then
            if GetIsTaskActive(ped,165) then
                SetPedIntoVehicle(ped,vehicle,0)
                sleep = 0
            end
        end
        Wait(sleep)
    end
end)
