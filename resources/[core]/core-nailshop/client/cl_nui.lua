local Config <const> = require 'config.main'
local handCameraPosition = {
    ['left_hand'] = vec3(-0.33, -0.05, 0.1),
    ['right_hand'] = vec3(0.2, -0.05, 0.1)
}

RegisterNUICallback('nui/checked', function(data, cb)
    NuiLoaded = true
    cb('ok')
end)

RegisterNUICallback('nui/save-naildesign', function(data, cb)
    TriggerServerEvent(Scriptname .. ':server:saveNailDesign', Config.NailStudios[StudioIndex].tables[TableIndex].customer.coords)
    cb('ok')
end)

RegisterNUICallback('nui/restore-naildesign', function(data, cb)
    TriggerServerEvent(Scriptname .. ':server:restoreNailDesign', Config.NailStudios[StudioIndex].tables[TableIndex].customer.coords)
    cb('ok')
end)

RegisterNUICallback('nui/close', function(data, cb)
    InNailShop = false
    SetNuiFocus(false, false)
    if Camera then
        RenderScriptCams(false, true, 2000, true, true)
        DestroyCam(Camera, false)
        Camera = nil
    end
    ClearPedTasks(PlayerPedId())

    local customerCoords = Config.NailStudios[StudioIndex].tables[TableIndex].customer.coords
    TriggerServerEvent(Scriptname .. ':server:setBusyTable', StudioIndex, TableIndex, false)
    TriggerServerEvent(Scriptname .. ':server:clearPedTask', customerCoords)
    cb('ok')
end)

RegisterNUICallback('nui/apply-naildesign', function(data, cb)
    TriggerServerEvent(Scriptname .. ':server:previewNailDesign', Config.NailStudios[StudioIndex].tables[TableIndex].customer.coords, data)
    cb('ok')
end)

RegisterNUICallback('nui/set-hand', function(data, cb)
    cb('ok')
end)

RegisterNUICallback('nui/clear-finger-design', function(data, cb)
    TriggerServerEvent(Scriptname .. ':server:clearFingerDesign', Config.NailStudios[StudioIndex].tables[TableIndex].customer.coords, data.fingerId, data.hand)
    cb('ok')
end)