local VRPServer = Framework.VRPServer
local InventoryServer = Framework.Server
local ChestServer = CoreInventoryChest or Framework.Server
local InspectServer = Framework.Server
local PropertyServer = Framework.Property
local TrunkServer = Framework.Trunk

local opened = false
local context = "inventory"
local readOnly = false
local containerContext = {}
local externalLabel = "Inventario"
local initialMount = nil
local drops = {}
local primary = {}
local groundLookup = {}
local cooldown = 0
local headshotHandle = nil
local headshotTexture = ""

local function releaseHeadshot()
    if headshotHandle and headshotHandle ~= -1 then
        UnregisterPedheadshot(headshotHandle)
    end

    headshotHandle = nil
    headshotTexture = ""
end


local function getHeadshotTexture()
    if headshotHandle and IsPedheadshotReady(headshotHandle) and IsPedheadshotValid(headshotHandle) then
        return headshotTexture
    end

    releaseHeadshot()

    local ped = PlayerPedId()
    local blendTimeout = GetGameTimer() + 2000
    while IsPedHuman(ped) and not HasPedHeadBlendFinished(ped) and GetGameTimer() < blendTimeout do
        Wait(25)
    end

    local handle = RegisterPedheadshot(ped)
    if not handle or handle == -1 then return "" end

    local readyTimeout = GetGameTimer() + Inventory.General.Interface.HeadshotTimeout
    while not IsPedheadshotReady(handle) and GetGameTimer() < readyTimeout do
        Wait(25)
    end

    if not IsPedheadshotReady(handle) or not IsPedheadshotValid(handle) then
        UnregisterPedheadshot(handle)
        return ""
    end

    headshotHandle = handle
    headshotTexture = GetPedheadshotTxdString(handle) or ""
    return headshotTexture
end

local function backendSlot(slot)
    local number = tonumber(slot)
    return number and tostring(number - 1) or tostring(slot)
end

local function frontendSlot(slot)
    local number = tonumber(slot)
    return number and tostring(number + 1) or tostring(slot)
end

local function normalizeItem(value)
    local item = value.item or value.key
    if not item then return nil end
    local index = Framework.ItemIndex(item)

    -- o meta guarda o acessorio pela chave do item: a tooltip da arma quer o nome
    local attachNames = nil
    if type(value.attachs) == "table" then
        attachNames = {}
        for component in pairs(value.attachs) do
            attachNames[#attachNames + 1] = Framework.ItemName(component) or component
        end

        table.sort(attachNames)
        if #attachNames == 0 then attachNames = nil end
    end

    return {
        id = value.id,
        key = item,
        item = item,
        peso = Framework.ItemWeight(item),
        name = Framework.ItemName(item),
        amount = tonumber(value.amount) or 0,
        maxAmount = Framework.ItemMaxAmount(item) or nil,
        remaningUse = value.charges,
        image = index and ("%s%s.png"):format(Inventory.General.ImageBaseUrl,index) or "",
        description = value.desc or Framework.ItemDescription(item) or "",
        days = value.days,
        durability = value.durability,
        type = Framework.ItemType(item),
        serial = value.serial,
        ammo = value.ammo,
        attachs = value.attachs,
        attachNames = attachNames
    }
end

local function normalizeInventory(inventory,maxSlots)
    local result = {}
    if type(inventory) ~= "table" then return result end

    for slot,value in pairs(inventory) do
        local normalized = normalizeItem(value)
        local displaySlot = frontendSlot(slot)
        local numericSlot = tonumber(displaySlot)
        if normalized and normalized.amount > 0 and (not maxSlots or not numericSlot or numericSlot <= maxSlots) then
            result[displaySlot] = normalized
        end
    end
    return result
end

local function inventoryWeight(items)
    local weight = 0.0
    if type(items) ~= "table" then return weight end

    for _,value in pairs(items) do
        weight = weight + ((tonumber(value.peso) or 0.0) * (tonumber(value.amount) or 0))
    end
    return weight
end

local function sendBaseState(items,maxWeight,slots)
    local state = LocalPlayer.state
    local normalized = normalizeInventory(items)
    primary = type(items) == "table" and items or {}

    SendNUIMessage({ action = "setProfile", data = {
        image = getHeadshotTexture(),
        name = state.Name or Framework.NameDefault or "Cidadao",
        id = state.Passport or 0,
        gens = state.Gems or 0,
        weight = inventoryWeight(normalized),
        maxWeight = tonumber(maxWeight) or 0
    } })
    SendNUIMessage({ action = "setInventory", data = {
        slot = tonumber(slots) or Framework.Theme.inventory.slots.default,
        unlockedSlots = tonumber(slots) or Framework.Theme.inventory.slots.default,
        maxSlots = Framework.Theme.inventory.slots.max,
        accent = Inventory.General.Interface.Accent,
        shop = "",
        vip = false
    } })
    SendNUIMessage({ action = "updateBackpack", data = normalized })
end

-- o state so recebe a rota quando o jogador entra num bucket; quem nunca entrou
-- esta no 0, que e onde o servidor guarda as sacolas do mundo aberto
local function currentRoute()
    return LocalPlayer.state.Route or 0
end

local function nearbyDrops()
    local result = {}
    groundLookup = {}
    if not Inventory.General.Features.GroundDrops then return result,0 end
    local ped = PlayerPedId()
    local route = currentRoute()
    if IsPedInAnyVehicle(ped) or not drops[route] then return result,0 end

    local coords = GetEntityCoords(ped)
    local radius = tonumber(Inventory.General.Ground.Radius) or 2.0
    local nearby = {}
    for id,value in pairs(drops[route]) do
        if value.coords and #(coords - value.coords) <= radius then
            nearby[#nearby + 1] = id
        end
    end

    -- pairs() nao tem ordem: sem ordenar, cada refresh embaralharia os slots do chao
    table.sort(nearby)

    local total = 0
    for _,id in ipairs(nearby) do
        local entry = normalizeItem(drops[route][id])
        if entry then
            total = total + 1
            local slot = tostring(total)
            entry.id = id
            result[slot] = entry
            groundLookup[slot] = id
        end
    end

    return result,total
end

local function performRefresh()
    if context == "chest" then
        local playerItems,chestItems,maxWeight,chestWeight,slots,chestSlots
        if initialMount then
            playerItems = initialMount.Primary
            chestItems = initialMount.Secondary
            maxWeight = initialMount.PrimaryWeight
            chestWeight = initialMount.SecondaryWeight
            slots = initialMount.PrimarySlots
            chestSlots = initialMount.SecondarySlots
            initialMount = nil
        else
            playerItems,chestItems,maxWeight,chestWeight,slots,chestSlots = ChestServer.Mount()
        end
        if type(playerItems) ~= "table" then return false end
        if type(chestItems) ~= "table" then chestItems = {} end
        local externalSlots = math.min(Inventory.General.Slots.ExternalLimit,math.max(1,tonumber(chestSlots) or Framework.Theme.inventory.slots.default))
        local normalizedChest = normalizeInventory(chestItems,externalSlots)
        sendBaseState(playerItems,maxWeight,slots)
        SendNUIMessage({ action = "setGroundSection", data = {
            label = "Bau",
            description = "Armazenamento compartilhado",
            slot = externalSlots,
            weight = inventoryWeight(normalizedChest),
            maxWeight = tonumber(chestWeight) or 0,
            canUpgrade = ChestServer.CanUpgrade() == true
        } })
        SendNUIMessage({ action = "updateDrop", data = normalizedChest })
    elseif context == "propertys" then
        local playerItems,propertyItems,maxWeight,propertyWeight,slots = PropertyServer.Mount(containerContext.Name,containerContext.Mode)
        if type(playerItems) ~= "table" then return false end
        if type(propertyItems) ~= "table" then propertyItems = {} end
        local externalSlots = math.min(Inventory.General.Slots.ExternalLimit,math.max(Inventory.General.Slots.DefaultExternal,Framework.CountTable(propertyItems)))
        local normalizedProperty = normalizeInventory(propertyItems,externalSlots)
        sendBaseState(playerItems,maxWeight,slots)
        SendNUIMessage({ action = "setGroundSection", data = {
            label = externalLabel,
            description = "Armazenamento da propriedade",
            slot = externalSlots,
            weight = inventoryWeight(normalizedProperty),
            maxWeight = tonumber(propertyWeight) or 0,
            canUpgrade = false
        } })
        SendNUIMessage({ action = "updateDrop", data = normalizedProperty })
    elseif context == "trunkchest" then
        local playerItems,trunkItems,maxWeight,trunkWeight,slots = TrunkServer.Mount()
        if type(playerItems) ~= "table" then return false end
        if type(trunkItems) ~= "table" then trunkItems = {} end
        local externalSlots = math.min(Inventory.General.Slots.ExternalLimit,math.max(Inventory.General.Slots.DefaultExternal,Framework.CountTable(trunkItems)))
        local normalizedTrunk = normalizeInventory(trunkItems,externalSlots)
        sendBaseState(playerItems,maxWeight,slots)
        SendNUIMessage({ action = "setGroundSection", data = {
            label = externalLabel,
            description = "Armazenamento do veiculo",
            slot = externalSlots,
            weight = inventoryWeight(normalizedTrunk),
            maxWeight = tonumber(trunkWeight) or 0,
            canUpgrade = false
        } })
        SendNUIMessage({ action = "updateDrop", data = normalizedTrunk })
    elseif context == "inspect" then
        local playerItems,targetItems,maxWeight,targetWeight,slots,targetSlots = InspectServer.InspectMount()
        if type(playerItems) ~= "table" then return false end
        if type(targetItems) ~= "table" then targetItems = {} end
        local externalSlots = math.min(Inventory.General.Slots.ExternalLimit,math.max(1,tonumber(targetSlots) or Framework.Theme.inventory.slots.default))
        local normalizedTarget = normalizeInventory(targetItems,externalSlots)
        sendBaseState(playerItems,maxWeight,slots)
        SendNUIMessage({ action = "setGroundSection", data = {
            label = "Jogador",
            description = "Itens da pessoa revistada",
            slot = externalSlots,
            weight = inventoryWeight(normalizedTarget),
            maxWeight = tonumber(targetWeight) or 0,
            canUpgrade = false
        } })
        SendNUIMessage({ action = "updateDrop", data = normalizedTarget })
    else
        groundLookup = {}
        local playerItems,maxWeight,slots = InventoryServer.Mount()
        if type(playerItems) ~= "table" then return false end
        sendBaseState(playerItems,maxWeight,slots)
        local ground,groundCount = nearbyDrops()
        SendNUIMessage({ action = "setGroundSection", data = groundCount > 0 and {
            label = "Chao",
            description = "Itens proximos",
            slot = math.min(Inventory.General.Slots.ExternalLimit,math.max(Inventory.General.Slots.DefaultExternal,groundCount)),
            canUpgrade = false,
            drops = true
        } or nil })
        SendNUIMessage({ action = "updateDrop", data = ground })
    end

    return true
end

local refreshing = false
local refreshPending = false

-- Mount() cede a thread: sem a trava dois refreshes simultaneos terminam fora de
-- ordem e o painel do chao recebe a lista antiga por cima da nova.
local function refresh()
    if not opened then return false end

    if refreshing then
        refreshPending = true
        return true
    end

    refreshing = true
    local success = performRefresh()
    refreshing = false

    if refreshPending then
        refreshPending = false
        CreateThread(refresh)
    end

    return success
end

RegisterNetEvent("inventory:Open")
AddEventHandler("inventory:Open",function(data,ignore)
    if Framework.IsInCoreGameMatch() then return end
    local ped = PlayerPedId()
    if not LocalPlayer.state.Active or IsPauseMenuActive() or GetEntityHealth(ped) <= 100 then return end
    if opened and not (data and data.Force) and not ignore then return end
	if data and data.Type == "Inspect" and not Inventory.General.Features.Inspect then return end
	if data and data.Type == "Chest" then
		local resource = tostring(data.Resource or "chest")
		if resource == "propertys" and not Inventory.General.Features.Properties then return end
		if resource == "trunkchest" and not Inventory.General.Features.Trunks then return end
		if resource ~= "propertys" and resource ~= "trunkchest" and not Inventory.General.Features.Chests then return end
	end

    if data and data.Type == "Inspect" then
        context = "inspect"
    elseif data and data.Type == "Chest" then
        local resource = tostring(data.Resource or "chest")
        context = (resource == "propertys" or resource == "trunkchest") and resource or "chest"
    else
        context = "inventory"
    end
    readOnly = data and data.ReadOnly == true or false
    containerContext = data and type(data.Container) == "table" and data.Container or {}
    initialMount = data and type(data.MountData) == "table" and data.MountData or nil
    externalLabel = data and data.Right or "Inventario"
    opened = true
    SetCursorLocation(0.5,0.5)
    SetNuiFocus(true,true)
    TransitionToBlurred(250)
    Framework.Open()
    SendNUIMessage({ action = "setContainer", data = nil })
    SendNUIMessage({ action = "setChestUpgrade", data = nil })
    SendNUIMessage({ action = "setVisibility", data = true })
    refresh()
end)

RegisterNetEvent("inventory:Close")
AddEventHandler("inventory:Close",function()
    if not opened then return end
    opened = false
    context = "inventory"
    containerContext = {}
    initialMount = nil
    SetNuiFocus(false,false)
    SetCursorLocation(0.5,0.5)
    TransitionFromBlurred(250)
    Framework.Close()
    SendNUIMessage({ action = "setVisibility", data = false })
    SendNUIMessage({ action = "setGroundSection", data = nil })
    SendNUIMessage({ action = "setChestUpgrade", data = nil })
    releaseHeadshot()
end)

AddStateBagChangeHandler("inCoreGameMatch",("player:%s"):format(LocalPlayer.state.Source),function(Name,Key,Value)
    if Value and opened and GetResourceState("core-game") == "started" then
        TriggerEvent("inventory:Close")
    end
end)

AddEventHandler("onResourceStop",function(resource)
    if resource == GetCurrentResourceName() then releaseHeadshot() end
end)

RegisterNetEvent("inventory:Update")
AddEventHandler("inventory:Update",refresh)

RegisterNetEvent("inventory:Drops")
AddEventHandler("inventory:Drops",function(data) drops = data or {} end)

-- os eventos de drop saem para o servidor inteiro: so vale remontar quando a
-- sacola esta na mesma rota do jogador, senao todo descarte alheio custa um Mount
local function groundChanged(route)
    if route == currentRoute() then refresh() end
end

RegisterNetEvent("inventory:DropsRemover")
AddEventHandler("inventory:DropsRemover",function(route,id)
    if drops[route] then drops[route][id] = nil end
    groundChanged(route)
end)

RegisterNetEvent("inventory:DropsAtualizar")
AddEventHandler("inventory:DropsAtualizar",function(route,id,amount)
    if drops[route] and drops[route][id] then drops[route][id].amount = amount end
    groundChanged(route)
end)

RegisterNetEvent("inventory:DropsAdicionar")
AddEventHandler("inventory:DropsAdicionar",function(route,id,data)
    drops[route] = drops[route] or {}
    drops[route][id] = data
    groundChanged(route)
end)

RegisterNUICallback("removeFocus",function(_,cb)
    TriggerEvent("inventory:Close")
    cb({ ok = true })
end)

RegisterNUICallback("useItem",function(data,cb)
    local success = false
    if (data.section or "inventory") == "inventory" and GetGameTimer() >= cooldown then
        success = InventoryServer.Use(backendSlot(data.slot),math.max(1,math.floor(tonumber(data.amount) or 1)))
        cooldown = GetGameTimer() + Inventory.General.Interface.UseCooldown
    end
    cb(success == true)
end)

RegisterNUICallback("sendItem",function(data,cb)
    local amount = math.max(1,math.floor(tonumber(data.amount) or 1))
    local slot = backendSlot(data.slot)
    local success = false
    if data.target and context == "chest" then
        success = ChestServer.Store(nil,slot,amount,backendSlot(data.target),readOnly)
    elseif data.target and context == "propertys" then
        local item = primary[slot] and primary[slot].item
        if item then
            PropertyServer.Store(item,slot,amount,backendSlot(data.target),containerContext.Name,containerContext.Mode)
            success = true
        end
    elseif data.target and context == "trunkchest" then
        local item = primary[slot] and primary[slot].item
        if item then
            TrunkServer.Store(item,slot,amount,backendSlot(data.target))
            success = true
        end
    elseif data.target and context == "inspect" then
        success = InspectServer.InspectStore(nil,slot,amount,backendSlot(data.target))
    elseif data.target and context == "inventory" and not Framework.IsInCoreGameMatch() then
        local item = primary[slot] and primary[slot].item
        success = item and InventoryServer.Drops(item,slot,amount) or false
    elseif MumbleIsConnected() and not Framework.IsInCoreGameMatch() then
        success = InventoryServer.Send(slot,amount)
    end
    refresh()
    cb(success == true)
end)

RegisterNUICallback("dropItem",function(data,cb)
    local slot = backendSlot(data.slot)
    local item = primary[slot] and primary[slot].item
    local success = not Framework.IsInCoreGameMatch() and item and InventoryServer.Drops(item,slot,math.max(1,math.floor(tonumber(data.amount) or 1))) or false
    refresh()
    cb(success == true)
end)

RegisterNUICallback("updateSlot",function(data,cb)
    local success = VRPServer.invUpdate(backendSlot(data.slot),backendSlot(data.target),math.max(1,math.floor(tonumber(data.amount) or 1)))
    refresh()
    cb(success ~= false)
end)

RegisterNUICallback("updateGroundSlot",function(data,cb)
    local amount = math.max(1,math.floor(tonumber(data.amount) or 1))
    local slot = backendSlot(data.slot)
    local target = backendSlot(data.target)
    local success = false
    if context == "chest" then
        success = ChestServer.Update(slot,target,amount)
    elseif context == "propertys" then
        PropertyServer.Update(slot,target,amount,containerContext.Name,containerContext.Mode)
        success = true
    elseif context == "trunkchest" then
        TrunkServer.Update(slot,target,amount)
        success = true
    end
    refresh()
    cb(success == true)
end)

RegisterNUICallback("pickupItem",function(data,cb)
    local amount = math.max(1,math.floor(tonumber(data.amount) or 1))
    local slot = backendSlot(data.slot)
    local target = backendSlot(data.target)
    local success = false
    if context == "chest" then
        success = ChestServer.Take(nil,slot,amount,target)
    elseif context == "propertys" then
        PropertyServer.Take(slot,amount,target,containerContext.Name,containerContext.Mode)
        success = true
    elseif context == "trunkchest" then
        TrunkServer.Take(slot,amount,target)
        success = true
    elseif context == "inspect" then
        success = InspectServer.InspectTake(nil,slot,target,amount)
    else
        local dropId = groundLookup[tostring(data.slot)]
        success = dropId and InventoryServer.Pickup(dropId,currentRoute(),target,amount) or false
    end
    refresh()
    cb(success == true)
end)

RegisterNUICallback("requestChestUpgrade",function(_,cb)
    local quote = context == "chest" and ChestServer.QuoteUpgrade() or false
    if quote then SendNUIMessage({ action = "setChestUpgrade", data = quote }) end
    cb(quote or false)
end)

RegisterNUICallback("confirmChestUpgrade",function(_,cb)
    local success = context == "chest" and ChestServer.ConfirmUpgrade() or false
    SendNUIMessage({ action = "setChestUpgrade", data = nil })
    refresh()
    cb(success == true)
end)

RegisterNUICallback("reloadWeapon",function(data,cb)
    local success = InventoryServer.ReloadWeapon(backendSlot(data.slot),backendSlot(data.target),math.max(1,math.floor(tonumber(data.amount) or 1)))
    refresh()
    cb(success == true)
end)

RegisterNUICallback("attachWeapon",function(data,cb)
    local success = InventoryServer.AttachWeapon(backendSlot(data.slot),backendSlot(data.target))
    refresh()
    cb(success == true)
end)

RegisterNUICallback("unloadWeapon",function(data,cb)
    local success = InventoryServer.UnloadWeapon(backendSlot(data.slot))
    refresh()
    cb(success == true)
end)

RegisterNUICallback("detachWeapon",function(data,cb)
    local success = InventoryServer.DetachWeapon(backendSlot(data.slot))
    refresh()
    cb(success == true)
end)

RegisterNetEvent("inventory:Lunchbag")
AddEventHandler("inventory:Lunchbag",function(data)
    SendNUIMessage({ action = "setContainer", data = {
        title = data.title,
        description = data.description,
        slots = data.slots,
        items = normalizeInventory(data.items,data.slots)
    } })
end)

RegisterNUICallback("moveContainerItem",function(data,cb)
    local success = InventoryServer.MoveLunchbag(data.fromSection,backendSlot(data.fromSlot),data.toSection,backendSlot(data.toSlot),math.max(1,math.floor(tonumber(data.amount) or 1)))
    refresh()
    cb(success == true)
end)

RegisterNUICallback("emptyContainer",function(_,cb)
    local success = InventoryServer.EmptyLunchbag()
    refresh()
    cb(success == true)
end)

RegisterNUICallback("closeContainer",function(_,cb)
    SendNUIMessage({ action = "setContainer", data = nil })
    cb(InventoryServer.CloseLunchbag() == true)
end)

for _,name in ipairs({ "offerTradeItem","withdrawTradeItem","setTradeMoney","confirmTrade","cancelTrade" }) do
    RegisterNUICallback(name,function(_,cb) cb(false) end)
end

local function useInventorySlot(slot,amount)
    if opened or not LocalPlayer.state.Active or LocalPlayer.state.Buttons or IsPauseMenuActive() then return false end
    if GetEntityHealth(PlayerPedId()) <= 100 or GetGameTimer() < cooldown then return false end

    cooldown = GetGameTimer() + Inventory.General.Interface.UseCooldown
    return InventoryServer.Use(tostring(slot),math.max(1,math.floor(tonumber(amount) or 1)))
end

AddEventHandler("inventory:Use",function(slot,amount)
    useInventorySlot(slot,amount)
end)

RegisterCommand("Inventory",function()
    if opened then
        TriggerEvent("inventory:Close")
    else
        TriggerEvent("inventory:Open",{ Type = "Inventory", Resource = "core-inventory", Right = "Proximidade" },true)
    end
end)

RegisterKeyMapping("Inventory","Abrir/Fechar a mochila.","keyboard","OEM_3")
