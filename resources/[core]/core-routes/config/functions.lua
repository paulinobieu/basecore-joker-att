local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

-- Aliases para server-side (Item.lua usa PascalCase)
itemName   = ItemName
itemIndex  = ItemIndex
itemWeight = ItemWeight

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES
-----------------------------------------------------------------------------------------------------------------------------------------
Functions = {}

Functions.NotifyTypes = {
    Success = "verde",
    Denied  = "vermelho",
    Warning = "amarelo",
    Info    = "azul",
    Error   = "vermelho",
}

function Functions.notify(source, notifyType, message, duration)
    TriggerClientEvent("Notify", source, "Rotas", message, notifyType, duration or 5000)
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

function Functions.hasPermission(user_id, permissions)
    if not permissions then return true end
    if type(permissions) == "table" then return vRP.HasTable(user_id, permissions) end
    return vRP.HasPermission(user_id, permissions)
end

function Functions.getUsersByPermission(permission)
    if not permission then return {} end
    local users  = vRP.NumPermission(permission) or {}
    local result = {}
    for _, src in pairs(users) do
        if src then result[#result + 1] = src end
    end
    return result
end

function Functions.getItemAmount(user_id, item)
    return vRP.ItemAmount(user_id, item)
end

function Functions.giveItem(user_id, item, amount)
    return vRP.GenerateItem(user_id, item, amount, true)
end

function Functions.getInventoryWeight(user_id)
    return vRP.InventoryWeight(user_id)
end

function Functions.getMaxWeight(user_id)
    return vRP.GetWeight(user_id)
end

function Functions.tryPayment(user_id, amount)
    return vRP.PaymentFull(user_id, amount)
end

function Functions.upgradeStress(user_id, amount)
    if amount and amount > 0 then
        vRP.UpgradeStress(user_id, amount)
    end
end

function Functions.getItemImage(spawn)
    local index = ItemIndex(spawn) or SplitOne(spawn)
    return (Routes.Images.BaseUrl or "") .. index .. (Routes.Images.Extension or ".png")
end

function Functions.getItemName(spawn)
    return ItemName(spawn) or spawn
end

function Functions.getItemWeight(spawn)
    return ItemWeight(spawn) or 0
end
