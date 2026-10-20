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
    TriggerClientEvent("Notify", source, "Rádio", message, notifyType, duration or 5000)
end

function Functions.getUserId(source)
    return vRP.Passport(source)
end

function Functions.getUserSource(user_id)
    return vRP.Source(user_id)
end

function Functions.getUserName(user_id)
    local name = vRP.FullName(user_id)
    return name or "Desconhecido"
end

function Functions.hasPermission(user_id, permissions)
    if not permissions then return true end
    if type(permissions) == "table" then
        for _, perm in ipairs(permissions) do
            if vRP.HasGroup(user_id, perm) then
                return true
            end
        end
        return false
    end
    return vRP.HasGroup(user_id, permissions)
end

function Functions.hasItem(user_id, item, amount)
    return vRP.ConsultItem(user_id, item, amount or 1)
end
