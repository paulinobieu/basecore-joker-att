local vehMenuCd = false
RegisterCommand("@core/vehicles/vehicleMenu",function()
    if not _intloaded then
        return
    end
    vehMenuCd = true
    if vehMenu and vehMenu.enabled then
        if LocalPlayer.state.disableVehMenu then
            return
        end
        local vehicle = GetVehiclePedIsIn(PlayerPedId())
        if vehicle then
            local currentSeat = nil
            if GetPedInVehicleSeat(vehicle,-1) == PlayerPedId() then
                currentSeat = "P1"
            elseif GetPedInVehicleSeat(vehicle,0) == PlayerPedId() then
                currentSeat = "P2"
            elseif GetPedInVehicleSeat(vehicle,1) == PlayerPedId() then
                currentSeat = "P3"
            elseif GetPedInVehicleSeat(vehicle,2) == PlayerPedId() then
                currentSeat = "P4"
            end
            if currentSeat then
                SetNuiFocus(true,true)
                SendNUIMessage({ action = "showVehicleMenu", key = vehMenu.key:lower() or "m", backSeats = (GetVehicleMaxNumberOfPassengers(vehicle) > 1), currentSeat = currentSeat }) 
            end
        end
        SetTimeout(500,function() vehMenuCd = false end)
    end
end)
RegisterKeyMapping("@core/vehicles/vehicleMenu", "Menu do Veículo", "keyboard", vehMenu.key:lower() or "m")

toggleVehMenuItem = function(item)
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    if vehicle then
        local itemData = splitStr(item,"-")
        if itemData[1] == "seat" then
            local seatIndex = nil
            if itemData[2] == "P1" then
                seatIndex = -1
            elseif itemData[2] == "P2" then
                seatIndex = 0
            elseif itemData[2] == "P3" then
                seatIndex = 1
            elseif itemData[2] == "P4" then
                seatIndex = 2
            end
            if seatIndex ~= nil then
                if IsVehicleSeatFree(vehicle,seatIndex) then
                    SetPedIntoVehicle(PlayerPedId(),vehicle,seatIndex)
                    return true
                end
            end
        elseif item == "lock" then
            if GetPedInVehicleSeat(vehicle,-1) == PlayerPedId() then
                ExecuteCommand("@core/vehicles/toggleVehicleLock")
            end
        elseif item == "power" then
            if GetPedInVehicleSeat(vehicle,-1) == PlayerPedId() then
                SetVehicleEngineOn(vehicle,not GetIsVehicleEngineRunning(vehicle),true,true)
            end
        else
            TriggerServerEvent("core/vehicles/syncVehMenuItem",NetworkGetNetworkIdFromEntity(vehicle),item)
        end
    end
end

RegisterNetEvent("core/vehicles/vMenuItem")
AddEventHandler("core/vehicles/vMenuItem",function(vehicleNetId,item) 
    local t = 0
    while not NetworkDoesNetworkIdExist(vehicleNetId) and t < 1000 do
        t = t + 1
        Wait(200)
    end
    if NetworkDoesNetworkIdExist(vehicleNetId) then 
        local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId) 
        local itemData = splitStr(item,"-")
        if itemData[1] == "door" then
            local doorIndex = nil
            if itemData[2] == "P1" then
                doorIndex = 0
            elseif itemData[2] == "P2" then
                doorIndex = 1
            elseif itemData[2] == "P3" then
                doorIndex = 2
            elseif itemData[2] == "P4" then
                doorIndex = 3
            elseif itemData[2] == "frontHood" then
                doorIndex = 4
            elseif itemData[2] == "rearHood" then
                doorIndex = 5
            end
            if doorIndex ~= nil then
                if GetVehicleDoorAngleRatio(vehicle,doorIndex) > 0.0 then
                    SetVehicleDoorShut(vehicle,doorIndex,false)
                else
                    SetVehicleDoorOpen(vehicle,doorIndex,false)
                end
            end
        elseif itemData[1] == "win" then
            local winIndex = nil
            if itemData[2] == "P1" then
                winIndex = 0
            elseif itemData[2] == "P2" then
                winIndex = 1
            elseif itemData[2] == "P3" then
                winIndex = 2
            elseif itemData[2] == "P4" then
                winIndex = 3
            end
            if winIndex ~= nil then
                if Entity(vehicle).state["windowDown-"..winIndex] then
                    RollUpWindow(vehicle,winIndex)
                    Entity(vehicle).state["windowDown-"..winIndex] = false
                else
                    RollDownWindow(vehicle,winIndex)
                    Entity(vehicle).state["windowDown-"..winIndex] = true
                end
            end
        end
    end 
end)
