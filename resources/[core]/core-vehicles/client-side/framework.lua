isDead = function()
    return (GetEntityHealth(PlayerPedId()) <= 101)
end

detachAllObjectsFromPed = function()
    local objectList = GetGamePool("CObject")
    for ind,obj in pairs(objectList) do
        if GetEntityAttachedTo(obj) == PlayerPedId() then
            DetachEntity(obj)
            DeleteEntity(obj)
        end
    end
end

toggleHud = function(toggle)
    TriggerEvent("hud:Active",toggle)
end

createProgressBar = function(time,text)
    TriggerEvent("createProgressBar",time,text)
end

draw3dtext = function(x,y,z,t)
    local _,_x,_y = World3dToScreen2d(x,y,z)
    SetTextFont(4)
    SetTextScale(0.35,0.35)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(t)
    DrawText(_x,_y)
end

loadAnimDictionary = function(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        local t = 5000
        while not HasAnimDictLoaded(dict) and t > 0 do
            Citizen.Wait(0)
            t = t - 1
        end
    end
    return true
end

loadAnimDict = loadAnimDictionary

loadModel = function(modelName)
    local hash = type(modelName) == "string" and GetHashKey(modelName) or modelName
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        local t = 10000
        while not HasModelLoaded(hash) and t > 0 do
            Citizen.Wait(0)
            t = t - 1
        end
    end
    return hash
end

lockPlayerActions = function(bool)
    SetPlayerControl(PlayerId(),not bool)
    LocalPlayer.state.animBlocked = bool
    LocalPlayer.state.inventoryBlocked = bool
end
