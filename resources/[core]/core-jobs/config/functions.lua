-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

Functions = {}

function Functions.notify(source, title, message, color, duration)
    TriggerClientEvent("Notify", source, title, message, color, duration or 5000)
end

function Functions.getUserId(source)
    return vRP.Passport(source)
end

function Functions.getUserSource(user_id)
    return vRP.Source(user_id)
end

function Functions.getIdentity(user_id)
    return vRP.Identity(user_id)
end

function Functions.getFullName(user_id)
    local identity = vRP.Identity(user_id)
    if identity then
        local first = identity.Name or identity.name or "Sem Nome"
        local last = identity.Lastname or identity.name2 or ""
        return first .. " " .. last
    end
    return "Desconhecido"
end

function Functions.checkWeight(user_id, item, amount)
    return vRP.CheckWeight(user_id, item, amount) and not vRP.MaxItens(user_id, item, amount)
end

function Functions.giveItem(user_id, item, amount)
    return vRP.GenerateItem(user_id, item, amount, true)
end

function Functions.generatePlate()
    return vRP.GeneratePlate()
end

function Functions.kick(source, reason)
    if vRP and vRP.Kick then
        vRP.Kick(source, reason)
    else
        DropPlayer(source, reason)
    end
end

function Functions.log(category, data)
    if GetResourceState("core_logs") == "started" then
        exports["core_logs"]:AddLog(category, data)
    elseif webhooks and webhooks.log then
        webhooks.log(category, data)
    end
end

function Functions.consultItem(user_id, item, amount)
    return vRP.ConsultItem(user_id, item, amount)
end

function Functions.takeItem(user_id, item, amount)
    return vRP.TakeItem(user_id, item, amount)
end
