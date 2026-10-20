----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (SERVER)
-----------------------------------------------------------------------------------------------------------------------------------------
Tunnel = module("vrp", "lib/Tunnel")
Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPC = Tunnel.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local pcall          = pcall
local type           = type
local next           = next
local tonumber       = tonumber
local tostring       = tostring
local json_encode    = json.encode
local json_decode    = json.decode
local str_format     = string.format
local GetPlayerPed   = GetPlayerPed
local GetEntityModel = GetEntityModel
local GetHashKey     = GetHashKey
-----------------------------------------------------------------------------------------------------------------------------------------
-- QUERIES
-----------------------------------------------------------------------------------------------------------------------------------------
local queries        = nil

local function Queries()
    if queries then return queries end

    local c = Groups.database.characters

    queries = {
        getCharacter = str_format([[
            SELECT `%s` AS id, `%s` AS name, `%s` AS lastname, `%s` AS phone
            FROM `%s` WHERE `%s` = ? LIMIT 1
        ]], c.id, c.name, c.lastname, c.phone, c.table, c.id),
    }

    return queries
end
Framework = {
    -------------------------------------------------------------------------------------------------------------------------------------
    -- IDENTIDADE
    -------------------------------------------------------------------------------------------------------------------------------------
    Passport = function(source)
        return vRP.Passport(source) or vRP.passport(source) or vRP.GetUserId(source) or vRP.getUserId(source)
    end,

    Source = function(passport)
        local check = vRP.Source or vRP.source or vRP.getUserSource or vRP.GetUserSource
        if not check then return nil end

        local ok, result = pcall(check, passport)
        if not ok then return nil end

        local src = tonumber(result)
        return (src and src > 0) and src or nil
    end,

    Identity = function(passport)
        if not passport then return nil end

        local check = vRP.Identity or vRP.identity
        if not check then return nil end

        local ok, result = pcall(check, passport)
        if not ok or type(result) ~= "table" then return nil end

        return result
    end,

    FullName = function(passport)
        local identity = Framework.Identity(passport)
        if not identity then return nil end

        local firstName = identity.name or identity.Name or identity.firstname or identity.firstName
        local lastName  = identity.name2 or identity.Name2 or identity.lastname or identity.Lastname

        if not firstName then return nil end
        if not lastName or lastName == "" then return firstName end

        return str_format("%s %s", firstName, lastName)
    end,

    Phone = function(passport)
        local identity = Framework.Identity(passport)
        local phone = identity and (identity.phone or identity.Phone)

        if not phone or phone == "" then
            local row = Framework.GetCharacter(passport)
            phone = row and row.phone
        end

        if not phone or phone == "" then return nil end

        return tostring(phone)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- PERMISSÕES
    -------------------------------------------------------------------------------------------------------------------------------------
    HasPermission = function(passport, permission)
        if not passport then return false end

        local check = vRP.hasPermission or vRP.HasPermission
        if not check then return false end

        local ok, result = pcall(check, passport, permission)
        if not ok then return false end

        if type(result) == "number" then return result > 0 end

        return result == true or result == 1
    end,

    GroupData = function(permission)
        local check = vRP.DataGroups or vRP.dataGroups
        if not check then return {}, 0 end

        local ok, members, amount = pcall(check, permission)
        if not ok or type(members) ~= "table" then return {}, 0 end

        return members, tonumber(amount) or 0
    end,

    PermissionLevel = function(passport, permission)
        if not passport then return 0 end

        local members = Framework.GroupData(permission)
        local level = members[passport] or members[tostring(passport)]

        return tonumber(level) or 0
    end,

    OnlineAmount = function(permission)
        local members = Framework.GroupData(permission)
        local amount = 0

        for passport in next, members do
            if Framework.Source(tonumber(passport)) then
                amount = amount + 1
            end
        end

        return amount
    end,

    GroupAmount = function(permission)
        local _, amount = Framework.GroupData(permission)
        return amount
    end,

    SetPermission = function(passport, permission, level)
        return vRP.SetPermission(passport, permission, level)
    end,

    RemovePermission = function(passport, permission)
        return vRP.RemovePermission(passport, permission)
    end,

    InService = function(passport, permission)
        local check = vRP.HasService or vRP.hasService
        if not check then return false end

        local ok, result = pcall(check, passport, permission)
        if not ok then return false end

        if type(result) == "number" then return result > 0 end
        if type(result) == "string" then return result ~= "" end

        return result == true
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- GRUPOS (sincronização de cargos)
    -------------------------------------------------------------------------------------------------------------------------------------
    Groups = function()
        local check = vRP.Groups or vRP.groups
        if not check then return {} end

        local ok, result = pcall(check)
        if not ok or type(result) ~= "table" then return {} end

        return result
    end,

    GroupExists = function(permission)
        if not permission or permission == "" then return false end

        local groups = Framework.Groups()

        if next(groups) == nil then return true end

        return groups[permission] ~= nil
    end,

    GroupHierarchy = function(permission)
        if not permission or permission == "" then return {} end

        local group = Framework.Groups()[permission]
        if type(group) ~= "table" or type(group.Hierarchy) ~= "table" then return {} end

        local names = {}
        for i = 1, #group.Hierarchy do
            local name = tostring(group.Hierarchy[i] or "")
            if name ~= "" then names[#names + 1] = name end
        end

        return names
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- BANCO (dinheiro do jogador)
    -------------------------------------------------------------------------------------------------------------------------------------
    GetBank = function(passport)
        local check = vRP.GetBank or vRP.getBank
        if not check then return 0 end

        local ok, result = pcall(check, passport)
        if not ok then return 0 end

        return tonumber(result) or 0
    end,

    TakeBank = function(passport, amount)
        local value = tonumber(amount) or 0
        if not passport or value <= 0 then return false end

        local check = vRP.PaymentBank or vRP.paymentBank
        if not check then return false end

        local ok, result = pcall(check, passport, value)

        return ok and result ~= false
    end,

    GiveBank = function(passport, amount)
        local value = tonumber(amount) or 0
        if not passport or value <= 0 then return false end

        local check = vRP.GiveBank or vRP.giveBank
        if not check then return false end

        local ok, result = pcall(check, passport, value)

        return ok and result ~= false
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- INVENTARIO (itens da meta)
    -------------------------------------------------------------------------------------------------------------------------------------
    ItemAmount = function(passport, item)
        if not passport or type(item) ~= "string" or item == "" then return 0 end

        local ok, amount = pcall(vRP.ItemAmount, passport, item)

        return ok and (tonumber(amount) or 0) or 0
    end,

    RemoveItem = function(passport, item, amount, notify)
        amount = math.floor(tonumber(amount) or 0)
        if not passport or type(item) ~= "string" or item == "" or amount <= 0 then return false end

        local ok, removed = pcall(vRP.RemoveItem, passport, item, amount, notify == true)

        return ok and removed ~= false
    end,

    GenerateItem = function(passport, item, amount, notify, slot)
        amount = math.floor(tonumber(amount) or 0)
        if not passport or type(item) ~= "string" or item == "" or amount <= 0 then return false end

        local ok, generated = pcall(vRP.GenerateItem, passport, item, amount, notify == true, slot)

        return ok and generated ~= false
    end,

    AddTransaction = function(passport, kind, amount, reference)
        if GetResourceState("core-bank") ~= "started" then return end

        pcall(function()
            exports["core-bank"]:AddTransactions(passport, kind, amount, reference)
        end)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- UNIFORME (roupa do personagem)
    -------------------------------------------------------------------------------------------------------------------------------------
    Gender = function(userSource)
        local ped = GetPlayerPed(userSource)
        if not ped or ped <= 0 then return "male" end

        if GetEntityModel(ped) == GetHashKey("mp_f_freemode_01") then
            return "female"
        end

        return "male"
    end,

    GetClothings = function(passport)
        local ok, rows = pcall(vRP.Query, "core-creator/getCharacterData", {
            Passport = passport,
            Name = "Clothings",
        })

        if not ok or type(rows) ~= "table" or not rows[1] then return nil end

        local raw = rows[1].Information
        if type(raw) ~= "string" or raw == "" then return nil end

        local parsed
        ok, parsed = pcall(json_decode, raw)

        if not ok or type(parsed) ~= "table" then return nil end

        return parsed
    end,

    SetClothings = function(passport, clothings)
        if not passport or type(clothings) ~= "table" then return false end

        local ok = pcall(vRP.Update, "core-creator/setCharacterData", {
            Passport = passport,
            Name = "Clothings",
            Information = json_encode(clothings),
        })

        if not ok then return false end

        local userSource = Framework.Source(passport)

        if userSource then
            TriggerClientEvent("core-creator:Client:Skinshop:SaveDefault", userSource, clothings)
        end

        return true
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- RÁDIO
    -------------------------------------------------------------------------------------------------------------------------------------
    ConnectRadio = function(userSource, frequency)
        TriggerClientEvent("core-groups:radio", userSource, "connect", frequency)
    end,

    DisconnectRadio = function(userSource, frequency)
        TriggerClientEvent("core-groups:radio", userSource, "disconnect", frequency)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- PERSONAGENS (tabela `characters` — nomes em Groups.database.characters)
    -------------------------------------------------------------------------------------------------------------------------------------
    GetCharacter = function(id)
        local passport = tonumber(id)
        if not passport then return nil end

        return Framework.Single(Queries().getCharacter, { passport })
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- BANCO DE DADOS
    -------------------------------------------------------------------------------------------------------------------------------------
    Query = function(query, params)
        return MySQL.query.await(query, params or {})
    end,

    Insert = function(query, params)
        return MySQL.insert.await(query, params or {})
    end,

    Update = function(query, params)
        return MySQL.update.await(query, params or {})
    end,

    Transaction = function(queries)
        return MySQL.transaction.await(queries)
    end,

    Single = function(query, params)
        return MySQL.single.await(query, params or {})
    end,
}
