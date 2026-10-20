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
    TriggerClientEvent("Notify", source, "Admin", message, notifyType, duration or 5000)
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

function Functions.getUserIdentity(user_id)
    return vRP.Identity(user_id)
end

function Functions.hasGroup(user_id, permission, level)
    return vRP.HasGroup(user_id, permission, level)
end

function Functions.hasPermission(user_id, permission)
    if not permission then return true end
    if type(permission) == "table" then return vRP.HasTable(user_id, permission) end
    return vRP.HasPermission(user_id, permission)
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

function Functions.getInventoryItemAmount(user_id, item)
    local data = vRP.InventoryItemAmount(user_id, item)
    return tonumber(data[1]) or 0, data[2] or item
end

function Functions.giveInventoryItem(user_id, item, amount)
    return vRP.GenerateItem(user_id, item, amount, true)
end

function Functions.tryPayment(user_id, amount)
    return vRP.PaymentFull(user_id, amount)
end

function Functions.getBank(user_id)
    return vRP.GetBank(user_id) or 0
end

function Functions.addBank(user_id, amount)
    return vRP.GiveBank(user_id, amount)
end

function Functions.getUserGroup(user_id)
    return vRP.GetUserType(user_id, "Work") or "Civil"
end

function Functions.setPermission(user_id, group, level, mode)
    return vRP.SetPermission(user_id, group, level, mode)
end

function Functions.remPermission(user_id, group)
    return vRP.RemovePermission(user_id, group)
end

-- Membros do grupo direto da tabela de permissoes do vRP: { [Passport] = Level }.
-- Inclui quem esta offline, ao contrario de varrer GetPlayers().
-- Save = false pra nao marcar a chave como persistente so por consultar.
function Functions.getGroupMembers(group)
    if not group then return {} end
    return vRP.GetSrvData("Permissions:" .. group, false) or {}
end

-- Hierarquia do grupo (vrp/config/Global.lua -> Groups[group].Hierarchy).
-- vRP.NameHierarchy devolve o proprio nome do grupo quando o nivel nao existe,
-- e isso delimita o fim da lista.
function Functions.getHierarchy(group)
    local list = {}
    if not group then return list end

    for level = 1, 32 do
        local name = vRP.NameHierarchy(group, level)
        if not name or name == group then break end
        list[level] = name
    end

    return list
end

function Functions.getHierarchyName(group, level)
    if not group or not level then return nil end
    local name = vRP.NameHierarchy(group, level)
    return (name ~= group) and name or nil
end

function Functions.kick(user_id, reason)
    return vRP.Kick(user_id, reason)
end

function Functions.getDatatable(user_id)
    return vRP.Datatable(user_id) or {}
end

function Functions.upgradeThirst(user_id, amount)
    return vRP.UpgradeThirst(user_id, amount)
end

function Functions.upgradeHunger(user_id, amount)
    return vRP.UpgradeHunger(user_id, amount)
end

function Functions.downgradeStress(user_id, amount)
    return vRP.DowngradeStress(user_id, amount)
end

function Functions.generatePlate()
    return vRP.GeneratePlate()
end

function Functions.getItemDisplayName(itemSpawn)
    if ItemName then
        local name = ItemName(itemSpawn)
        if name and name ~= "" then return name end
    end
    return itemSpawn
end

function Functions.getItemImageName(itemSpawn)
    local specialItems = {
        ["identity-1"]         = "identity",
        ["WEAPON_PISTOL_AMMO"]  = "pistolammo",
        ["WEAPON_RIFLE_AMMO"]   = "rifleammo",
        ["WEAPON_SMG_AMMO"]     = "smgammo",
        ["WEAPON_SHOTGUN_AMMO"] = "shotgunammo",
        ["WEAPON_SNIPER_AMMO"]  = "sniperammo",
        ["WEAPON_HEAVY_AMMO"]   = "heavyammo",
    }
    if specialItems[itemSpawn] then return specialItems[itemSpawn] end
    if string.find(itemSpawn, "WEAPON_") then
        local weaponType = string.match(itemSpawn, "(WEAPON_[%w_]+)")
        if weaponType then return weaponType:lower():gsub("weapon_", "") end
    end
    return itemSpawn:lower()
end

function Functions.getVehicleDisplayName(vehicleSpawn)
    if VehicleName then
        local name = VehicleName(vehicleSpawn)
        if name and name ~= "" then return name end
    end
    return vehicleSpawn
end

function Functions.getGroups()
    return vRP.Groups() or {}
end
