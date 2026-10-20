local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES
-----------------------------------------------------------------------------------------------------------------------------------------
Functions = {}

Functions.NotifyTypes = {
    Success = "verde",
    Denied  = "vermelho",
    Warning = "amarelo",
    Info    = "azul",
}

function Functions.notify(source, notifyType, message, duration)
    TriggerClientEvent("Notify", source, "Totem", message, notifyType, duration or 5000)
end

function Functions.getUserId(source)
    return vRP.Passport(source)
end

function Functions.getUserSource(user_id)
    return vRP.Source(user_id)
end

function Functions.getUserName(user_id)
    return vRP.FullName(user_id)
end

local function parsePermission(perm)
    local at = string.find(perm, "@")
    if at then
        return string.sub(perm, 1, at - 1), tonumber(string.sub(perm, at + 1))
    end
    return perm, nil
end

function Functions.hasPermission(user_id, permissions)
    if not permissions then return true end
    if type(permissions) == "table" then
        for _, perm in ipairs(permissions) do
            local group, level = parsePermission(perm)
            if vRP.HasGroup(user_id, group, level) then
                return true
            end
        end
        return false
    end
    local group, level = parsePermission(permissions)
    return vRP.HasGroup(user_id, group, level)
end

function Functions.getUsersByPermission(permission)
    if not permission then return {} end
    local group, level = parsePermission(permission)
    local users  = vRP.NumPermission(group) or {}
    local result = {}
    for passport, src in pairs(users) do
        if src then
            if not level or vRP.HasGroup(passport, group, level) then
                result[#result + 1] = src
            end
        end
    end
    return result
end

function Functions.getItemName(itemId)
    return ItemName(itemId) or itemId
end

function Functions.getInventoryItemAmount(user_id, item)
    local data = vRP.InventoryItemAmount(user_id, item)
    return tonumber(data[1]) or 0, data[2] or item
end

function Functions.tryGetInventoryItem(user_id, item, amount)
    local result = vRP.TakeItem(user_id, item, amount, true)
    if result then return true end

    -- Fallback para itens com durabilidade
    for i = 1, amount do
        local data = vRP.InventoryItemAmount(user_id, item)
        local slotName   = data[2] or ""
        local slotAmount = tonumber(data[1]) or 0
        if slotName == "" or slotAmount <= 0 then return false end
        if not vRP.TakeItem(user_id, slotName, 1, false) then return false end
    end
    return true
end

function Functions.giveInventoryItem(user_id, item, amount)
    return vRP.GenerateItem(user_id, item, amount, true)
end

function Functions.tryPayment(user_id, amount)
    return vRP.PaymentFull(user_id, amount)
end

function Functions.giveBankMoney(user_id, amount)
    return vRP.GiveBank(user_id, amount)
end
