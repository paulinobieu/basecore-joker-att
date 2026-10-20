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
    TriggerClientEvent("Notify", source, "Desmanche", message, notifyType, duration or 5000)
end

function Functions.getUserId(source)
    return vRP.Passport(source)
end

function Functions.getUserSource(userId)
    return vRP.Source(userId)
end

function Functions.getUserName(userId)
    return vRP.FullName(userId)
end

function Functions.hasPermission(userId, permission)
    if not permission then return true end
    if type(permission) == "table" then return vRP.HasTable(userId, permission) end
    return vRP.HasPermission(userId, permission)
end

function Functions.giveItem(userId, item, amount)
    return vRP.GenerateItem(userId, item, amount, true)
end

function Functions.getItemAmount(userId, item)
    return vRP.ItemAmount(userId, item)
end

function Functions.checkMaxItems(userId, item, amount)
    return vRP.MaxItens(userId, item, amount)
end

function Functions.getInventoryWeight(userId)
    return vRP.InventoryWeight(userId)
end

function Functions.getMaxWeight(userId)
    return vRP.GetWeight(userId)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- BANCO DE DADOS
-----------------------------------------------------------------------------------------------------------------------------------------

function Functions.query(command, params)
    return MySQL.query.await(command, params or {})
end

function Functions.execute(command, params)
    return MySQL.update.await(command, params or {})
end

function Functions.insert(command, params)
    return MySQL.insert.await(command, params or {})
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- UTILITÁRIOS
-----------------------------------------------------------------------------------------------------------------------------------------

Functions.parseInt = parseInt

function Functions.isEmptyTable(tbl)
    if not tbl or type(tbl) ~= "table" then return true end
    return next(tbl) == nil
end

function Functions.addItemsToDismantlePanel(dismantleId, itemType, amount)
    -- Implementada no server-side/core.lua
end
