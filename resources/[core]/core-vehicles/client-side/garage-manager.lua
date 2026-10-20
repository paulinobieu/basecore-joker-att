-- ------------------------------------------------
-- # Garage Manager (gmanager) - client
-- ------------------------------------------------

local STATEBAG_KEY    = 'coreAdminGarages'
local capturingCoords = false
local gmanagerOpen    = false
local renderedGarages = {} -- [gIdString] = data

local function sendUi(action, data)
    SendNUIMessage({ action = action, data = data })
end

-- ------------------------------------------------
-- # Sync via StateBag
-- ------------------------------------------------
local function shallowDiffersGarage(a, b)
    if a == b then return false end
    if type(a) ~= 'table' or type(b) ~= 'table' then return true end
    if a.name ~= b.name or a.type ~= b.type or a.payment ~= b.payment then return true end
    if a.permission ~= b.permission then return true end
    if type(a.open) == 'table' and type(b.open) == 'table' then
        if a.open[1] ~= b.open[1] or a.open[2] ~= b.open[2] or a.open[3] ~= b.open[3] then return true end
    elseif a.open ~= b.open then return true end
    -- compara blip (enabled/icon/color/size) pra que toggle do checkbox seja refletido em tempo real
    local ab = a.blip or {}
    local bb = b.blip or {}
    if (ab.enabled and true or false) ~= (bb.enabled and true or false) then return true end
    if ab.icon ~= bb.icon or ab.color ~= bb.color or ab.size ~= bb.size then return true end
    return false
end

local function applyState(newState)
    if type(newState) ~= 'table' then newState = {} end

    -- 1. Remove tudo que sumiu do estado novo (blip + interact + tabela client-side)
    for gIdStr in pairs(renderedGarages) do
        if newState[gIdStr] == nil then
            local gId = tonumber(gIdStr)
            if gId then
                if garages then garages[gId] = nil end
                if removeGarageBlip then removeGarageBlip(gId) end
            end
            renderedGarages[gIdStr] = nil
        end
    end

    -- 2. Adiciona / atualiza o resto
    for gIdStr, data in pairs(newState) do
        local gId = tonumber(gIdStr)
        if gId and type(data) == 'table' then
            local current = renderedGarages[gIdStr]
            if not current or shallowDiffersGarage(current, data) then
                if current and removeGarageBlip then
                    removeGarageBlip(gId)
                end
                if garages then garages[gId] = data end
                if createGarageBlip then createGarageBlip(gId, data) end
                renderedGarages[gIdStr] = data
            end
        end
    end
end

CreateThread(function()
    Wait(3000) -- aguarda blips estáticos (threads.lua)
    local current = GlobalState[STATEBAG_KEY]
    if current then applyState(current) end
end)

AddStateBagChangeHandler(STATEBAG_KEY, 'global', function(_, _, value)
    applyState(value)
end)

CL.openGarageManager = function(list)
    if cooldown or interfaceOpen or not _intloaded then return end
    interfaceOpen = true
    gmanagerOpen = true
    toggleHud(false)
    SetNuiFocus(true, true)
    sendUi('openGarageManager', { garages = list or {} })
end

-- Roteador chamado a partir do RegisterNUICallback("_GET") em core.lua.
-- Retorna `true` se a action foi tratada (e cb já foi chamado).
function gmHandleNuiAction(action, d, cb)
    if action == 'gmGetGarages' then
        cb(SV.gmGetGarages())
        return true
    end

    if action == 'gmCreate' then
        cb(SV.gmCreate(d.data))
        return true
    end

    if action == 'gmUpdate' then
        cb(SV.gmUpdate(d.data))
        return true
    end

    if action == 'gmDelete' then
        cb(SV.gmDelete(d.id))
        return true
    end

    if action == 'gmTeleport' then
        local res = SV.gmTeleport(d.id)
        if res and res.success and res.coords then
            local ped = PlayerPedId()
            local x, y, z = table.unpack(res.coords)
            SetEntityCoords(ped, x, y, z + 0.5)
        end
        cb(res)
        return true
    end

    if action == 'gmClose' then
        gmanagerOpen = false
        interfaceOpen = false
        SetNuiFocus(false, false)
        toggleHud(true)
        cb(true)
        return true
    end

    if action == 'gmStartCapture' then
        if capturingCoords then cb({ error = 1 }) return true end
        capturingCoords = true

        -- Tira foco do NUI e devolve controles ao player; o painel continua visível
        SetNuiFocus(false, false)
        sendUi('gmCaptureMode', { active = true })

        local label = d.label or 'posição'
        CreateThread(function()
            local startTime = GetGameTimer()
            while capturingCoords do
                SetTextFont(4)
                SetTextScale(0.45, 0.45)
                SetTextColour(255, 255, 255, 255)
                SetTextOutline()
                SetTextCentre(true)
                BeginTextCommandDisplayText('STRING')
                AddTextComponentSubstringPlayerName('Pressione ~g~E~w~ para capturar ' .. label .. ' | ~r~BACKSPACE~w~ para cancelar')
                EndTextCommandDisplayText(0.5, 0.92)

                if IsControlJustReleased(0, 38) then -- E
                    local ped = PlayerPedId()
                    local coords = GetEntityCoords(ped)
                    local heading = GetEntityHeading(ped)
                    capturingCoords = false
                    if gmanagerOpen then SetNuiFocus(true, true) end
                    sendUi('gmCaptureResult', {
                        success = true,
                        coords = {
                            x = math.floor(coords.x * 100 + 0.5) / 100,
                            y = math.floor(coords.y * 100 + 0.5) / 100,
                            z = math.floor(coords.z * 100 + 0.5) / 100,
                            h = math.floor(heading * 100 + 0.5) / 100,
                        },
                    })
                    break
                end

                if IsControlJustReleased(0, 177) or IsControlJustReleased(0, 322) then -- BACKSPACE / ESC
                    capturingCoords = false
                    if gmanagerOpen then SetNuiFocus(true, true) end
                    sendUi('gmCaptureResult', { success = false })
                    break
                end

                if GetGameTimer() - startTime > 60000 then -- timeout 60s
                    capturingCoords = false
                    if gmanagerOpen then SetNuiFocus(true, true) end
                    sendUi('gmCaptureResult', { success = false, timeout = true })
                    break
                end

                Wait(0)
            end
        end)

        cb({ success = true })
        return true
    end

    return false
end
