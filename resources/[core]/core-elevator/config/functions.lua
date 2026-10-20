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
    TriggerClientEvent("Notify", source, "Elevador", message, notifyType, duration or 5000)
end

function Functions.getUserId(source)
    return vRP.Passport(source)
end

function Functions.hasPermission(user_id, permissions)
    if not permissions then return true end
    if type(permissions) == "table" then return vRP.HasTable(user_id, permissions) end
    return vRP.HasPermission(user_id, permissions)
end
