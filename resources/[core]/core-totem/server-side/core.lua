-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local TotemCache      = {}
local ItemCache       = {}
local TotemWatchers   = {}
local SourceTotem     = {}
local PurchaseLocks   = {}
local DatabaseReady   = false
local TableState      = "core_totem_state"
local TableItems      = "core_totem_items"

local function CoreLog(category, data)
    if GetResourceState("core_logs") == "started" then
        exports["core_logs"]:AddLog(category, data)
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- AUTO-ORDERING
-- Lê config/config.lua como texto e extrai a ordem das chaves de Items
-- para que a UI exiba na mesma ordem escrita no arquivo.
-----------------------------------------------------------------------------------------------------------------------------------------
local function BuildItemOrders()
    local src = LoadResourceFile(GetCurrentResourceName(), "config/config.lua")
    if not src then return end

    local fileKeys = {}
    for line in src:gmatch("[^\r\n]+") do
        local key = line:match("^%s*([%w_]+)%s*=%s*{")
        if not key then
            key = line:match('^%s*%["([^"]+)"%]%s*=%s*{')
        end
        if key then
            fileKeys[#fileKeys + 1] = key
        end
    end

    for _, restaurant in pairs(Totem.Restaurants) do
        if restaurant.Items then
            local order = {}
            for _, key in ipairs(fileKeys) do
                if restaurant.Items[key] then
                    order[#order + 1] = key
                end
            end
            if #order > 0 then
                restaurant._itemOrder = order
            end
        end
    end
end

BuildItemOrders()
-----------------------------------------------------------------------------------------------------------------------------------------
-- DATABASE
-----------------------------------------------------------------------------------------------------------------------------------------

local function DatabaseQuery(query, parameters)
    parameters = parameters or {}

    if MySQL and MySQL.query and MySQL.query.await then
        return MySQL.query.await(query, parameters)
    end

    return exports.oxmysql:query_async(query, parameters)
end

local function CreateTablesIfNotExists()
    DatabaseQuery(([[
        CREATE TABLE IF NOT EXISTS `%s` (
            `totem_id`     VARCHAR(64) NOT NULL,
            `revenue`      BIGINT      NOT NULL DEFAULT 0,
            `total_revenue` BIGINT     NOT NULL DEFAULT 0,
            `total_sales`  BIGINT      NOT NULL DEFAULT 0,
            `updated_at`   BIGINT      NOT NULL DEFAULT 0,
            PRIMARY KEY (`totem_id`)
        )
    ]]):format(TableState))

    DatabaseQuery(([[
        CREATE TABLE IF NOT EXISTS `%s` (
            `totem_id`   VARCHAR(64)  NOT NULL,
            `item_id`    VARCHAR(128) NOT NULL,
            `stock`      INT          NOT NULL DEFAULT 0,
            `price`      BIGINT       NOT NULL DEFAULT 0,
            `updated_at` BIGINT       NOT NULL DEFAULT 0,
            PRIMARY KEY (`totem_id`, `item_id`)
        )
    ]]):format(TableItems))

    local totalRevenueColumn = DatabaseQuery(
        ("SHOW COLUMNS FROM `%s` LIKE 'total_revenue'"):format(TableState)
    ) or {}

    if #totalRevenueColumn == 0 then
        DatabaseQuery(
            ("ALTER TABLE `%s` ADD COLUMN `total_revenue` BIGINT NOT NULL DEFAULT 0 AFTER `revenue`"):format(TableState)
        )
        DatabaseQuery(("UPDATE `%s` SET `total_revenue` = `revenue`"):format(TableState))
    end
end

local function LoadAllTotemStates()
    return DatabaseQuery(("SELECT * FROM `%s`"):format(TableState)) or {}
end

local function LoadAllTotemItems()
    return DatabaseQuery(("SELECT * FROM `%s`"):format(TableItems)) or {}
end

local function SaveTotemState(totemId)
    local state = TotemCache[totemId]
    if not state then return end

    state.updated_at = os.time()

    DatabaseQuery(([[
        INSERT INTO `%s` (`totem_id`, `revenue`, `total_revenue`, `total_sales`, `updated_at`)
        VALUES (?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            `revenue`       = VALUES(`revenue`),
            `total_revenue` = VALUES(`total_revenue`),
            `total_sales`   = VALUES(`total_sales`),
            `updated_at`    = VALUES(`updated_at`)
    ]]):format(TableState), {
        totemId, state.revenue, state.total_revenue, state.total_sales, state.updated_at,
    })
end

local function SaveTotemItem(totemId, itemId)
    local items = ItemCache[totemId]
    if not items or not items[itemId] then return end

    local item = items[itemId]
    item.updated_at = os.time()

    DatabaseQuery(([[
        INSERT INTO `%s` (`totem_id`, `item_id`, `stock`, `price`, `updated_at`)
        VALUES (?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            `stock`      = VALUES(`stock`),
            `price`      = VALUES(`price`),
            `updated_at` = VALUES(`updated_at`)
    ]]):format(TableItems), {
        totemId, itemId, item.stock, item.price, item.updated_at,
    })
end

local function InsertTotemIfNotExists(totemId)
    DatabaseQuery(
        ("INSERT IGNORE INTO `%s` (`totem_id`, `updated_at`) VALUES (?, ?)"):format(TableState),
        { totemId, os.time() }
    )
end

local function InsertItemIfNotExists(totemId, itemId, defaultPrice, defaultStock)
    DatabaseQuery(
        ("INSERT IGNORE INTO `%s` (`totem_id`, `item_id`, `stock`, `price`, `updated_at`) VALUES (?, ?, ?, ?, ?)"):format(TableItems),
        { totemId, itemId, defaultStock, defaultPrice, os.time() }
    )
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UTILS
-----------------------------------------------------------------------------------------------------------------------------------------

local function Clamp(value, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, value))
end

local function IsPurchaseLocked(totemId)
    local expiresAt = PurchaseLocks[totemId]

    if not expiresAt then
        return false
    end

    if expiresAt <= GetGameTimer() then
        PurchaseLocks[totemId] = nil
        return false
    end

    return true
end

local function AcquirePurchaseLock(totemId)
    if IsPurchaseLocked(totemId) then
        return false
    end

    PurchaseLocks[totemId] = GetGameTimer() + 30000
    return true
end

local function ReleasePurchaseLock(totemId)
    PurchaseLocks[totemId] = nil
end

local function FormatThousands(value)
    local sep = (Totem.Currency and Totem.Currency.Separator) or "."
    local formatted = tostring(math.floor(tonumber(value) or 0))

    while true do
        local updated, matches = formatted:gsub("^(%-?%d+)(%d%d%d)", "%1" .. sep .. "%2")
        formatted = updated
        if matches == 0 then break end
    end

    return formatted
end

local function FormatCurrency(value)
    local cfg = Totem.Currency or {}
    return (cfg.Prefix or "R$ ") .. FormatThousands(value) .. (cfg.Suffix or "")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------

local function GetTotem(totemId)
    return Totem.Restaurants[tostring(totemId)]
end

local function GetTotemName(totemId)
    return tostring(totemId)
end

local function HasAdminAccess(user_id, totemId)
    local totem = GetTotem(totemId)

    if not totem then
        return false
    end

    if not totem.AdminPermission then
        return false
    end

    return Functions.hasPermission(user_id, totem.AdminPermission)
end

local function GetCoreGroupsAppId(totem)
    if Totem.UseCoreGroups ~= true then
        return nil
    end

    if GetResourceState("core-groups") ~= "started" then
        print("[core-totem] core-groups nao esta iniciado.")
        return nil
    end

    local permission = totem and totem.ServicePermission
    if type(permission) ~= "string" or permission == "" then
        print("[core-totem] ServicePermission invalida para integracao com core-groups.")
        return nil
    end

    local ok, appId = pcall(function()
        return exports["core-groups"]:getAppIdByPermission(permission)
    end)

    if not ok or not appId then
        print(("[core-totem] Organizacao com a permissao %s nao encontrada no core-groups."):format(permission))
        return nil
    end

    return appId
end

local function AddCoreGroupsBalance(appId, amount, description)
    local ok, success = pcall(function()
        return exports["core-groups"]:addGroupBalance(appId, amount, description)
    end)

    return ok and success == true
end

local function IsTotemBlocked(totemId)
    local blocking = Totem.Blocking

    if not blocking or not blocking.Enabled then
        return false
    end

    local totem = GetTotem(totemId)

    if not totem or not totem.ServicePermission then
        return false
    end

    local radius = blocking.Radius or 25.0
    local coords = totem.Machine and totem.Machine.Coords

    if not coords then
        return false
    end

    local serviceUsers = Functions.getUsersByPermission(totem.ServicePermission)

    for _, src in ipairs(serviceUsers) do
        if GetPlayerPing(src) > 0 then
            local ped = GetPlayerPed(src)

            if ped and ped > 0 then
                local pedCoords = GetEntityCoords(ped)
                local distance = #(pedCoords - vec3(coords.x + 0.0, coords.y + 0.0, coords.z + 0.0))

                if distance <= radius then
                    return true
                end
            end
        end
    end

    return false
end

local function BuildDefaultTotemState(totemId)
    return {
        totem_id = tostring(totemId),
        revenue = 0,
        total_revenue = 0,
        total_sales = 0,
        updated_at = os.time(),
    }
end

local function NormalizeTotemState(totemId, row)
    local state = BuildDefaultTotemState(totemId)

    if not row then
        return state
    end

    state.revenue = tonumber(row.revenue) or 0
    state.total_revenue = tonumber(row.total_revenue) or state.revenue
    state.total_sales = tonumber(row.total_sales) or 0
    state.updated_at = tonumber(row.updated_at) or os.time()

    return state
end

local function NormalizeItem(row)
    return {
        stock = tonumber(row.stock) or 0,
        price = tonumber(row.price) or 0,
        updated_at = tonumber(row.updated_at) or os.time(),
    }
end

local function GetItemImageUrl(itemId)
    local images = Totem.Images or {}
    local baseUrl = images.BaseUrl or "https://cfx-nui-ox_inventory/web/images/"
    local extension = images.Extension or ".png"
    return baseUrl .. itemId .. extension
end

local function BuildItemList(totem, items)
    local list = {}
    local orderKeys = totem._itemOrder

    if orderKeys then
        for _, itemId in ipairs(orderKeys) do
            local itemDef = totem.Items[itemId]
            if itemDef then
                local cached = items[itemId] or { stock = 0, price = itemDef.DefaultPrice }
                list[#list + 1] = {
                    id    = itemId,
                    name  = Functions.getItemName(itemId),
                    price = cached.price,
                    stock = cached.stock,
                    image = GetItemImageUrl(itemId),
                }
            end
        end
    else
        for itemId, itemDef in pairs(totem.Items or {}) do
            local cached = items[itemId] or { stock = 0, price = itemDef.DefaultPrice }
            list[#list + 1] = {
                id    = itemId,
                name  = Functions.getItemName(itemId),
                price = cached.price,
                stock = cached.stock,
                image = GetItemImageUrl(itemId),
            }
        end
    end

    return list
end

local function EnsureTotemLoaded(totemId)
    totemId = tostring(totemId)

    if TotemCache[totemId] then
        return
    end

    InsertTotemIfNotExists(totemId)

    local totem = GetTotem(totemId)
    if not totem then return end

    local defaultStock = (Totem.Stock and Totem.Stock.DefaultStock) or 50
    for itemId, itemDef in pairs(totem.Items or {}) do
        InsertItemIfNotExists(totemId, itemId, itemDef.DefaultPrice, defaultStock)
    end

    local stateRows = DatabaseQuery(
        ("SELECT * FROM `%s` WHERE `totem_id` = ? LIMIT 1"):format(TableState),
        { totemId }
    ) or {}
    TotemCache[totemId] = NormalizeTotemState(totemId, stateRows[1])

    local itemRows = DatabaseQuery(
        ("SELECT * FROM `%s` WHERE `totem_id` = ?"):format(TableItems),
        { totemId }
    ) or {}

    ItemCache[totemId] = {}
    for _, row in ipairs(itemRows) do
        ItemCache[totemId][row.item_id] = NormalizeItem(row)
    end
end

local function BuildOpenPayload(totemId, isAdmin)
    EnsureTotemLoaded(totemId)

    local totem = GetTotem(totemId) or {}
    local state = TotemCache[totemId] or BuildDefaultTotemState(totemId)
    local items = ItemCache[totemId] or {}

    return {
        totemId = GetTotemName(totemId),
        themeColor = totem.ThemeColor or (Theme and type(Theme.main) == "string" and Theme.main ~= "" and Theme.main) or Totem.DefaultThemeColor or "#dc1553",
        banner = totem.Banner or "",
        isAdmin = isAdmin,
        useCoreGroups = Totem.UseCoreGroups == true,
        revenue = Totem.UseCoreGroups == true and state.total_revenue or state.revenue,
        totalSales = state.total_sales,
        items = BuildItemList(totem, items),
        priceMin = (Totem.PriceRange and Totem.PriceRange.Min) or 100,
        priceMax = (Totem.PriceRange and Totem.PriceRange.Max) or 50000,
        maxStock = (Totem.Stock and Totem.Stock.MaxStock) or 200,
        maxPurchasePerItem = math.max(1, math.floor(tonumber(Totem.Stock and Totem.Stock.MaxPurchasePerItem) or 200)),
        currencyPrefix    = (Totem.Currency and Totem.Currency.Prefix)    or "R$ ",
        currencySuffix    = (Totem.Currency and Totem.Currency.Suffix)    or "",
        currencySeparator = (Totem.Currency and Totem.Currency.Separator) or ".",
    }
end

local function RemoveWatcher(source)
    local totemId = SourceTotem[source]

    if not totemId then
        return
    end

    if TotemWatchers[totemId] then
        TotemWatchers[totemId][source] = nil

        if not next(TotemWatchers[totemId]) then
            TotemWatchers[totemId] = nil
        end
    end

    SourceTotem[source] = nil
end

local function AddWatcher(source, totemId)
    RemoveWatcher(source)

    TotemWatchers[totemId] = TotemWatchers[totemId] or {}
    TotemWatchers[totemId][source] = true
    SourceTotem[source] = totemId
end

local function SendWatcherMessage(totemId, action, data)
    local watchers = TotemWatchers[totemId]

    if not watchers then
        return
    end

    for src in pairs(watchers) do
        if GetPlayerPing(src) <= 0 then
            RemoveWatcher(src)
        else
            TriggerClientEvent("core-totem:nuiMessage", src, action, data)
        end
    end
end

local function BroadcastTotemUpdate(totemId)
    EnsureTotemLoaded(totemId)

    local totem = GetTotem(totemId) or {}
    local state = TotemCache[totemId] or BuildDefaultTotemState(totemId)
    local items = ItemCache[totemId] or {}

    SendWatcherMessage(totemId, "updateTotemState", {
        items      = BuildItemList(totem, items),
        revenue    = Totem.UseCoreGroups == true and state.total_revenue or state.revenue,
        totalSales = state.total_sales,
    })
end

local function OpenTotem(source, totemId)
    EnsureTotemLoaded(totemId)

    local user_id = Functions.getUserId(source)
    local isAdmin = user_id and HasAdminAccess(user_id, totemId) or false

    AddWatcher(source, totemId)
    TriggerClientEvent("core-totem:openPanel", source, totemId, BuildOpenPayload(totemId, isAdmin))
end

local function ValidateTotemAction(source)
    local user_id = Functions.getUserId(source)
    local totemId = SourceTotem[source]

    if not user_id or not totemId then
        return nil, nil
    end

    return user_id, totemId
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STARTUP
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    CreateTablesIfNotExists()

    for totemId, totem in pairs(Totem.Restaurants) do
        InsertTotemIfNotExists(totemId)

        local defaultStock = (Totem.Stock and Totem.Stock.DefaultStock) or 50
        for itemId, itemDef in pairs(totem.Items or {}) do
            InsertItemIfNotExists(totemId, itemId, itemDef.DefaultPrice, defaultStock)
        end
    end

    local stateRows = LoadAllTotemStates()
    for _, row in ipairs(stateRows) do
        local id = tostring(row.totem_id)
        if Totem.Restaurants[id] then
            TotemCache[id] = NormalizeTotemState(id, row)
        end
    end

    local itemRows = LoadAllTotemItems()
    for _, row in ipairs(itemRows) do
        local tid = tostring(row.totem_id)
        if Totem.Restaurants[tid] then
            ItemCache[tid] = ItemCache[tid] or {}
            ItemCache[tid][row.item_id] = NormalizeItem(row)
        end
    end

    DatabaseReady = true
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-totem:requestOpen", function(totemId)
    local source = source

    if not DatabaseReady then
        Functions.notify(source, Functions.NotifyTypes.Denied, "O sistema ainda esta inicializando.")
        return
    end

    local user_id = Functions.getUserId(source)
    if not user_id then
        return
    end

    local totem = GetTotem(totemId)
    if not totem then
        Functions.notify(source, Functions.NotifyTypes.Denied, "Totem invalido.")
        return
    end

    local isAdmin = HasAdminAccess(user_id, totemId)

    if not isAdmin and IsTotemBlocked(totemId) then
        local msg = (Totem.Blocking and Totem.Blocking.BlockedMessage) or "O totem esta fechado. Ha funcionarios em servico no restaurante."
        Functions.notify(source, Functions.NotifyTypes.Denied, msg)
        return
    end

    OpenTotem(source, totemId)
end)

RegisterNetEvent("core-totem:closeTotem", function()
    RemoveWatcher(source)
end)

RegisterNetEvent("core-totem:handleAction", function(action, data)
    local source = source
    local user_id, totemId = ValidateTotemAction(source)

    if not user_id or not totemId then
        return
    end

    local totemName = GetTotemName(totemId)
    local totem = GetTotem(totemId)

    if action == "confirm" then
        local order = type(data) == "table" and data.order or nil

        if not order or type(order) ~= "table" or #order == 0 then
            Functions.notify(source, Functions.NotifyTypes.Denied, "Dados de compra invalidos.")
            return
        end

        if IsTotemBlocked(totemId) then
            local msg = (Totem.Blocking and Totem.Blocking.BlockedMessage) or "O totem esta fechado. Ha funcionarios em servico no restaurante."
            Functions.notify(source, Functions.NotifyTypes.Denied, msg)
            return
        end

        EnsureTotemLoaded(totemId)
        local items = ItemCache[totemId] or {}

        local maxPurchasePerItem = math.max(1, math.floor(tonumber(Totem.Stock and Totem.Stock.MaxPurchasePerItem) or 200))
        local requestedItems = {}
        local requestedOrder = {}

        local availableItemCount = 0
        for _ in pairs(totem.Items or {}) do
            availableItemCount = availableItemCount + 1
        end

        if #order > availableItemCount then
            Functions.notify(source, Functions.NotifyTypes.Denied, "Dados de compra invalidos.")
            return
        end

        for _, entry in ipairs(order) do
            if type(entry) ~= "table" then
                Functions.notify(source, Functions.NotifyTypes.Denied, "Dados de compra invalidos.")
                return
            end

            local itemId = entry.id
            local quantity = tonumber(entry.quantity)

            if type(itemId) ~= "string" or #itemId == 0 or #itemId > 128 or not quantity or quantity ~= math.floor(quantity) or quantity <= 0 then
                Functions.notify(source, Functions.NotifyTypes.Denied, "Dados de compra invalidos.")
                return
            end

            local item = items[itemId]

            if not item then
                Functions.notify(source, Functions.NotifyTypes.Denied, "Item nao encontrado neste totem.")
                return
            end

            local requestedAmount = (requestedItems[itemId] or 0) + quantity

            if requestedAmount > maxPurchasePerItem then
                Functions.notify(source, Functions.NotifyTypes.Denied, "Quantidade maxima por item excedida.")
                return
            end

            if not requestedItems[itemId] then
                requestedOrder[#requestedOrder + 1] = itemId
            end

            requestedItems[itemId] = requestedAmount
        end

        local useCoreGroups = Totem.UseCoreGroups == true
        local coreGroupsAppId = nil

        if not AcquirePurchaseLock(totemId) then
            Functions.notify(source, Functions.NotifyTypes.Denied, "Outro pagamento esta sendo processado neste totem. Tente novamente.")
            return
        end

        local totalCost = 0
        local restaurantRevenue = 0
        local validEntries = {}

        for _, itemId in ipairs(requestedOrder) do
            local item = items[itemId]
            local quantity = requestedItems[itemId]
            local price = math.floor(tonumber(item.price) or 0)

            if price <= 0 then
                ReleasePurchaseLock(totemId)
                Functions.notify(source, Functions.NotifyTypes.Denied, "Preco invalido para este item.")
                return
            end

            local stockUsed = math.min(math.max(0, math.floor(tonumber(item.stock) or 0)), quantity)
            totalCost = totalCost + (price * quantity)
            restaurantRevenue = restaurantRevenue + (price * stockUsed)
            validEntries[#validEntries + 1] = {
                itemId = itemId,
                quantity = quantity,
                stockUsed = stockUsed,
                price = price,
                item = item,
            }
        end

        if useCoreGroups and restaurantRevenue > 0 then
            coreGroupsAppId = GetCoreGroupsAppId(totem)

            if not coreGroupsAppId then
                ReleasePurchaseLock(totemId)
                Functions.notify(source, Functions.NotifyTypes.Denied, "Nao foi possivel localizar a organizacao deste totem.")
                return
            end
        end

        if not Functions.tryPayment(user_id, totalCost) then
            ReleasePurchaseLock(totemId)
            Functions.notify(source, Functions.NotifyTypes.Denied, "Dinheiro insuficiente.")
            return
        end

        if useCoreGroups and restaurantRevenue > 0 then
            local description = ("Venda no totem %s"):format(totemName)

            if not AddCoreGroupsBalance(coreGroupsAppId, restaurantRevenue, description) then
                Functions.giveBankMoney(user_id, totalCost)
                ReleasePurchaseLock(totemId)
                Functions.notify(source, Functions.NotifyTypes.Denied, "Pagamento cancelado: nao foi possivel creditar a organizacao.")
                print(("[core-totem] Falha ao creditar %s no core-groups para o totem %s."):format(FormatCurrency(restaurantRevenue), totemName))
                return
            end
        end

        local state = TotemCache[totemId]
        local totalQuantity = 0

        for _, entry in ipairs(validEntries) do
            Functions.giveInventoryItem(user_id, entry.itemId, entry.quantity)

            entry.item.stock = math.max(0, entry.item.stock - entry.stockUsed)

            SaveTotemItem(totemId, entry.itemId)
            totalQuantity = totalQuantity + entry.quantity
            Webhooks.onPurchase(user_id, totemName, entry.itemId, entry.price * entry.quantity, entry.stockUsed)
        end

        state.total_revenue = state.total_revenue + restaurantRevenue
        if not useCoreGroups then
            state.revenue = state.revenue + restaurantRevenue
        end
        state.total_sales = state.total_sales + totalQuantity
        SaveTotemState(totemId)

        ReleasePurchaseLock(totemId)

        BroadcastTotemUpdate(totemId)
        Functions.notify(source, Functions.NotifyTypes.Success, "Compra realizada com sucesso.")

        local purchased = ""
        for _, entry in ipairs(validEntries) do
            purchased = purchased .. (purchased ~= "" and ", " or "") .. entry.quantity .. "x " .. entry.itemId
        end

        CoreLog("TOTEM-COMPROU", {
            message    = Functions.getUserName(user_id) .. " #" .. user_id .. " comprou " .. purchased .. " no totem " .. totemName .. " por R$ " .. totalCost,
            playerName = Functions.getUserName(user_id),
            playerId   = user_id,
            Totem      = totemName,
            Itens      = purchased,
            Valor      = totalCost,
            ReceitaRestaurante = restaurantRevenue,
        })

        return
    end

    if action == "setPrice" then
        if not HasAdminAccess(user_id, totemId) then
            Functions.notify(source, Functions.NotifyTypes.Denied, "Voce nao possui acesso administrativo a este totem.")
            return
        end

        local itemId = data.itemId
        local newPrice = math.floor(tonumber(data.price) or 0)
        local priceRange = Totem.PriceRange or { Min = 100, Max = 50000 }

        if not itemId then
            Functions.notify(source, Functions.NotifyTypes.Denied, "Item invalido.")
            return
        end

        EnsureTotemLoaded(totemId)
        local items = ItemCache[totemId] or {}
        local item = items[itemId]

        if not item then
            Functions.notify(source, Functions.NotifyTypes.Denied, "Item nao encontrado neste totem.")
            return
        end

        newPrice = Clamp(newPrice, priceRange.Min, priceRange.Max)
        local oldPrice = item.price
        item.price = newPrice
        SaveTotemItem(totemId, itemId)

        BroadcastTotemUpdate(totemId)
        Functions.notify(source, Functions.NotifyTypes.Success, "Preco atualizado com sucesso.")
        Webhooks.onPriceChange(user_id, totemName, itemId, oldPrice, newPrice)

        CoreLog("TOTEM-PRECO", {
            message     = Functions.getUserName(user_id) .. " #" .. user_id .. " alterou o preço de " .. itemId .. " no totem " .. totemName .. " de R$ " .. oldPrice .. " para R$ " .. newPrice,
            playerName  = Functions.getUserName(user_id),
            playerId    = user_id,
            Totem       = totemName,
            Item        = itemId,
            PrecoAntigo = oldPrice,
            PrecoNovo   = newPrice,
        })

        return
    end

    if action == "restock" then
        if not HasAdminAccess(user_id, totemId) then
            Functions.notify(source, Functions.NotifyTypes.Denied, "Voce nao possui acesso administrativo a este totem.")
            return
        end

        if IsPurchaseLocked(totemId) then
            Functions.notify(source, Functions.NotifyTypes.Denied, "Ha um pagamento sendo processado neste totem. Tente novamente.")
            return
        end

        local itemId = data.itemId
        local amount = math.floor(tonumber(data.amount) or 0)
        local maxStock = (Totem.Stock and Totem.Stock.MaxStock) or 200

        if not itemId or amount <= 0 then
            Functions.notify(source, Functions.NotifyTypes.Denied, "Dados de reabastecimento invalidos.")
            return
        end

        EnsureTotemLoaded(totemId)
        local items = ItemCache[totemId] or {}
        local item = items[itemId]

        if not item then
            Functions.notify(source, Functions.NotifyTypes.Denied, "Item nao encontrado neste totem.")
            return
        end

        if item.stock >= maxStock then
            Functions.notify(source, Functions.NotifyTypes.Denied, "O estoque deste item ja esta no maximo.")
            return
        end

        if Totem.Stock and Totem.Stock.RequireItems then
            local invAmount = Functions.getInventoryItemAmount(user_id, itemId)

            if invAmount < amount then
                Functions.notify(source, Functions.NotifyTypes.Denied, "Voce nao possui itens suficientes no inventario.")
                return
            end

            if not Functions.tryGetInventoryItem(user_id, itemId, amount) then
                Functions.notify(source, Functions.NotifyTypes.Denied, "Nao foi possivel remover os itens do inventario.")
                return
            end
        end

        local actualAdd = math.min(amount, maxStock - item.stock)
        item.stock = item.stock + actualAdd
        SaveTotemItem(totemId, itemId)

        BroadcastTotemUpdate(totemId)
        Functions.notify(source, Functions.NotifyTypes.Success, "Estoque reabastecido com sucesso.")
        Webhooks.onRestock(user_id, totemName, itemId, actualAdd, item.stock)

        CoreLog("TOTEM-ABASTECEU", {
            message     = Functions.getUserName(user_id) .. " #" .. user_id .. " abasteceu " .. actualAdd .. "x " .. itemId .. " no totem " .. totemName,
            playerName  = Functions.getUserName(user_id),
            playerId    = user_id,
            Totem       = totemName,
            Item        = itemId,
            Quantidade  = actualAdd,
            EstoqueNovo = item.stock,
        })

        return
    end

    if action == "withdraw" then
        if not HasAdminAccess(user_id, totemId) then
            Functions.notify(source, Functions.NotifyTypes.Denied, "Voce nao possui acesso administrativo a este totem.")
            return
        end

        if IsPurchaseLocked(totemId) then
            Functions.notify(source, Functions.NotifyTypes.Denied, "Ha um pagamento sendo processado neste totem. Tente novamente.")
            return
        end

        if Totem.UseCoreGroups == true then
            Functions.notify(source, Functions.NotifyTypes.Denied, "A receita deste totem e enviada diretamente para a organizacao.")
            return
        end

        EnsureTotemLoaded(totemId)
        local state = TotemCache[totemId]

        if not state or state.revenue <= 0 then
            Functions.notify(source, Functions.NotifyTypes.Denied, "Nao ha receita disponivel para retirada.")
            return
        end

        local amount = state.revenue
        local withdrawItem = (Totem.Withdraw and Totem.Withdraw.Item)

        if withdrawItem then
            Functions.giveInventoryItem(user_id, withdrawItem, amount)
        else
            Functions.giveBankMoney(user_id, amount)
        end

        state.revenue = 0
        state.total_sales = 0
        SaveTotemState(totemId)

        BroadcastTotemUpdate(totemId)
        Functions.notify(source, Functions.NotifyTypes.Success, "Receita retirada com sucesso.")
        Webhooks.onWithdraw(user_id, totemName, amount)

        CoreLog("TOTEM-SAQUE", {
            message    = Functions.getUserName(user_id) .. " #" .. user_id .. " retirou R$ " .. amount .. " de receita do totem " .. totemName,
            playerName = Functions.getUserName(user_id),
            playerId   = user_id,
            Totem      = totemName,
            Valor      = amount,
        })

        return
    end
end)

AddEventHandler("playerDropped", function()
    RemoveWatcher(source)
end)
