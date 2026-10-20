local resourceName = 'vrp'

function GetPlayer(src)
    return src
end

function GetCharacterId(player)
    return vRP.Passport(player)
end

function IsPlayerAdmin(player)
    local Passport = vRP.Passport(player)
    return Passport and vRP.HasPermission(Passport,"Admin",1)
end

function IsPlayerInGroup(player, groups)
    local user_id = vRP.Passport(player)
    if not user_id then return end

    if vRP.HasGroup(user_id, "Admin") then
        return true
    end

    if type(groups) == "string" then
        return vRP.HasGroup(user_id, groups) and groups or nil
    end

    for k, v in pairs(groups) do
        local groupName = type(k) == "string" and k or v
        if vRP.HasGroup(user_id, groupName) then
            return groupName
        end
    end
end

function DoesPlayerHaveItem(player, items, removeItem)
    local user_id = vRP.Passport(player)
    if not user_id then return end

    for i = 1, #items do
        local item = items[i]
        local itemName = type(item) == "table" and item.name or item
        if vRP.ConsultItem(user_id, itemName, 1) then
            if removeItem or (type(item) == "table" and item.remove) then
                vRP.TakeItem(user_id, itemName, 1)
            end
            return itemName
        end
    end
end