if not Config.NoIdleCam then return end

RegisterCommand('idlecamoff', function() -- help2 31, 167, 9
    SimpleNotify("Idle Cam desativada.")
    DisableIdleCamera(true)
    SetPedCanPlayAmbientAnims(PlayerPedId(), false)
    SetResourceKvpInt("idleCamToggle", 1)
end, false)

RegisterCommand('idlecamon', function() -- help2 31, 167, 9
    SimpleNotify("Idle Cam ativada.")
    DisableIdleCamera(false)
    SetPedCanPlayAmbientAnims(PlayerPedId(), true)
    SetResourceKvpInt("idleCamToggle", 2)
end, false)

CreateThread(function()
    local idleCamKvp = GetResourceKvpInt("idleCamToggle")
    if idleCamKvp == 0 then
        return
    end

    DisableIdleCamera(idleCamKvp == 1)
end)
