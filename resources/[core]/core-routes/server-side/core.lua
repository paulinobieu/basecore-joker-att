-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local ActiveRoutes = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------

local DayNames = { [0] = "Domingo", "Segunda", "Terca", "Quarta", "Quinta", "Sexta", "Sabado" }

local function getTimeFarmMultiplier(zone)
    local cfg = Routes.FarmBuff
    if not cfg or not cfg.Enabled then return 1, 1 end

    local base = 1
    local dayIndex = tonumber(os.date("%w"))
    local dayName = DayNames[dayIndex]
    local schedule = cfg.Schedule and cfg.Schedule[dayName]

    if schedule and schedule.Enabled ~= false then
        local h = tonumber(os.date("%H"))
        local startH = schedule.StartHour or 0
        local endH   = schedule.EndHour or 24

        if h >= startH and h < endH then
            base = tonumber(cfg.Multiplier) or 1
        end
    end

    local zm = 1
    if cfg.ZoneMultiplier and zone then
        zm = tonumber(cfg.ZoneMultiplier[zone]) or 1
    end

    return base * zm, base
end

local function getVipBonus(userId)
    local cfg = Routes.VipBonus
    if not cfg or not cfg.Enabled then return 0 end

    local ok, result = pcall(function()
        return exports[cfg.Export][cfg.Function](userId)
    end)

    if ok and result then
        return tonumber(result) or 0
    end

    return 0
end

local function getTotalFarmMultiplier(userId, zone)
    local generalMult, baseMult = getTimeFarmMultiplier(zone)
    local vipBonus = getVipBonus(userId)

    local total = generalMult
    if vipBonus > 0 then
        if vipBonus >= 1 then
            total = total * vipBonus
        else
            total = total * (1 + vipBonus)
        end
    end

    return total, baseMult, vipBonus
end

local function callPolice(source, routeConfig)
    if not routeConfig.CallPolice then return end
    if math.random(100) < 40 then return end

    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return end

    local coords = GetEntityCoords(ped)
    exports.vrp:CallPolice({
        Permission = "Policia",
        Name = "Atividade Suspeita",
        Coords = coords,
        Code = 20,
        Color = 6
    })
end

local function mergePointRoutes(point)
    local merged = {
        Items         = {},
        RouteCost     = 0,
        UpgradeStress = 0,
        CallPolice    = false,
        UsingVehicle  = true,
    }

    for _, routeKey in ipairs(point.Routes or {}) do
        local routeCfg = Routes.Routes[routeKey]
        if routeCfg then
            for _, item in ipairs(routeCfg.Items or {}) do
                merged.Items[#merged.Items + 1] = item
            end

            merged.RouteCost = merged.RouteCost + (routeCfg.RouteCost or 0)

            if (routeCfg.UpgradeStress or 0) > merged.UpgradeStress then
                merged.UpgradeStress = routeCfg.UpgradeStress
            end

            if routeCfg.CallPolice then
                merged.CallPolice = true
            end

            if routeCfg.UsingVehicle == false then
                merged.UsingVehicle = false
            end
        end
    end

    return merged
end

local function buildItemsPayload(mergedConfig)
    local items = {}

    for _, item in ipairs(mergedConfig.Items or {}) do
        items[#items + 1] = {
            id    = item.id,
            name  = Functions.getItemName(item.id),
            image = Functions.getItemImage(item.id),
            price = item.price or 0,
        }
    end

    return items
end

local function findItemInMerged(mergedConfig, itemId)
    for _, item in ipairs(mergedConfig.Items or {}) do
        if item.id == itemId then
            return item
        end
    end
    return nil
end

local function validateSelectedItems(mergedConfig, selectedItems)
    local validated = {}

    for _, sel in ipairs(selectedItems) do
        local configItem = findItemInMerged(mergedConfig, sel.id)
        if configItem then
            validated[#validated + 1] = configItem
        end
    end

    return validated
end

local function calculateTotalCost(mergedConfig, validatedItems)
    local total = mergedConfig.RouteCost or 0

    for _, item in ipairs(validatedItems) do
        total = total + (item.price or 0)
    end

    return total
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTS
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent("core-routes:requestOpen")
AddEventHandler("core-routes:requestOpen", function(pointKey)
    local source = source
    local userId = Functions.getUserId(source)
    if not userId then return end

    if type(pointKey) ~= "string" then
        Functions.notify(source, Functions.NotifyTypes.Error, "Ponto inválido.")
        return
    end

    local point = Routes.Points[pointKey]
    if not point then
        Functions.notify(source, Functions.NotifyTypes.Error, "Ponto inválido.")
        return
    end

    if not Functions.hasPermission(userId, { pointKey }) then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Você não tem permissão para acessar esta rota.")
        return
    end

    if ActiveRoutes[userId] then
        Functions.notify(source, Functions.NotifyTypes.Warning, "Você já está em uma rota ativa.")
        return
    end

    local merged = mergePointRoutes(point)
    local items = buildItemsPayload(merged)

    local allStyles = { "terrestre", "aquatica", "aerea" }
    local allowedStyles = point.AllowedStyles or allStyles

    TriggerClientEvent("core-routes:openPanel", source, pointKey, {
        title         = "IMPORTAÇÃO",
        description   = "Selecione os insumos desejados e continue na ação abaixo.",
        items         = items,
        routeCost     = merged.RouteCost or 0,
        allowedStyles = allowedStyles,
    })
end)

RegisterNetEvent("core-routes:startRoute")
AddEventHandler("core-routes:startRoute", function(pointKey, selectedItems, style)
    local source = source
    local userId = Functions.getUserId(source)
    if not userId then return end

    if type(pointKey) ~= "string" then
        Functions.notify(source, Functions.NotifyTypes.Error, "Ponto inválido.")
        return
    end

    local point = Routes.Points[pointKey]
    if not point then
        Functions.notify(source, Functions.NotifyTypes.Error, "Ponto inválido.")
        return
    end

    if not Functions.hasPermission(userId, { pointKey }) then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Sem permissão.")
        return
    end

    if ActiveRoutes[userId] then
        Functions.notify(source, Functions.NotifyTypes.Warning, "Você já está em uma rota ativa.")
        return
    end

    local allStyles = { "terrestre", "aquatica", "aerea" }
    local allowedStyles = point.AllowedStyles or allStyles
    local styleAllowed = false
    for _, s in ipairs(allowedStyles) do
        if s == style then styleAllowed = true; break end
    end
    if not styleAllowed then
        Functions.notify(source, Functions.NotifyTypes.Error, "Estilo de rota inválido para este ponto.")
        return
    end

    local merged = mergePointRoutes(point)

    local validatedItems = validateSelectedItems(merged, selectedItems or {})
    if #validatedItems == 0 then
        Functions.notify(source, Functions.NotifyTypes.Warning, "Selecione pelo menos um insumo.")
        return
    end

    local totalCost = calculateTotalCost(merged, validatedItems)

    if totalCost > 0 then
        if not Functions.tryPayment(userId, totalCost) then
            Functions.notify(source, Functions.NotifyTypes.Error, "Dinheiro insuficiente. Necessário: R$" .. totalCost)
            return
        end
    end

    local zoneKey = Routes.StyleToZone[style] or "terrestrial"
    local coordsZones = point.CoordsZones or Routes.DefaultCoordsZones
    local poolName = coordsZones[zoneKey] or "New"

    if not Routes.Coords[poolName] then
        Functions.notify(source, Functions.NotifyTypes.Error, "Pool de coordenadas indisponível.")
        return
    end

    ActiveRoutes[userId] = {
        pointKey      = pointKey,
        items         = validatedItems,
        zone          = zoneKey,
        poolName      = poolName,
        collected     = 0,
        source        = source,
        upgradeStress = merged.UpgradeStress or 0,
        callPolice    = merged.CallPolice or false,
    }

    TriggerClientEvent("core-routes:routeStarted", source, zoneKey, poolName)
end)

RegisterNetEvent("core-routes:collect")
AddEventHandler("core-routes:collect", function()
    local source = source
    local userId = Functions.getUserId(source)
    if not userId then return end

    local route = ActiveRoutes[userId]
    if not route then return end

    local items = route.items
    if #items == 0 then return end

    local totalMult, baseMult, vipBonus = getTotalFarmMultiplier(userId, route.zone)
    local currentWeight = Functions.getInventoryWeight(userId)
    local maxWeight = Functions.getMaxWeight(userId)

    local collectedLog = ""
    for _, selectedItem in ipairs(items) do
        local amount = math.random(selectedItem.reward.min or 1, selectedItem.reward.max or 1)
        local finalAmount = math.ceil(amount * totalMult)

        local iw = Functions.getItemWeight(selectedItem.id)
        if currentWeight + (iw * finalAmount) > maxWeight then
            Functions.notify(source, Functions.NotifyTypes.Error, "Mochila cheia.")
            return
        end

        Functions.giveItem(userId, selectedItem.id, finalAmount)
        currentWeight = currentWeight + (iw * finalAmount)
        collectedLog = collectedLog .. (collectedLog ~= "" and ", " or "") .. finalAmount .. "x " .. selectedItem.id
    end

    if baseMult > 1 then
        local cfg = Routes.FarmBuff
        if cfg and cfg.Notify and cfg.Notify.Enabled then
            Functions.notify(source, cfg.Notify.Color or "azul", cfg.Notify.Message or "Bônus de farm ativo.", 5000)
        end
    end

    if vipBonus > 0 then
        Functions.notify(source, "azul", "Bônus VIP aplicado: +" .. math.floor(vipBonus * 100) .. "%.", 5000)
    end

    if route.upgradeStress and route.upgradeStress > 0 then
        Functions.upgradeStress(userId, route.upgradeStress)
    end

    if route.callPolice then
        local policeCallConfig = { CallPolice = true }
        callPolice(source, policeCallConfig)
    end

    route.collected = route.collected + 1

    TriggerClientEvent("core-routes:collectSuccess", source, route.collected)

    if GetResourceState("core_logs") == "started" then
        exports["core_logs"]:AddLog("COLETA-ROTA", {
            message    = Functions.getUserName(userId) .. " #" .. userId .. " coletou " .. collectedLog .. " na rota " .. tostring(route.pointKey),
            playerName = Functions.getUserName(userId),
            playerId   = userId,
            Rota       = route.pointKey,
            Zona       = route.zone,
            Itens      = collectedLog,
            Coleta     = route.collected,
        })
    end
end)

RegisterNetEvent("core-routes:cancelRoute")
AddEventHandler("core-routes:cancelRoute", function()
    local source = source
    local userId = Functions.getUserId(source)
    if not userId then return end

    ActiveRoutes[userId] = nil
end)

RegisterNetEvent("core-routes:routeComplete")
AddEventHandler("core-routes:routeComplete", function()
    local source = source
    local userId = Functions.getUserId(source)
    if not userId then return end

    ActiveRoutes[userId] = nil
end)

RegisterNetEvent("core-routes:closePanelServer")
AddEventHandler("core-routes:closePanelServer", function()
    -- Placeholder para lógica futura (logs, etc.)
end)

AddEventHandler("playerDropped", function()
    local source = source
    local userId = Functions.getUserId(source)
    if userId and ActiveRoutes[userId] then
        ActiveRoutes[userId] = nil
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    ActiveRoutes = {}
end)
