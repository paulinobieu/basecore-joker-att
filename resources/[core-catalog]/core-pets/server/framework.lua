-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (SERVER)
-- Camada de adaptação com a sua base (vRP por padrão). Adapte só o CORPO das funções.
-----------------------------------------------------------------------------------------------------------------------------------------
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

Framework = {
    -------------------------------------------------------------------------------------------------------------------------------------
    -- IDENTIDADE
    -------------------------------------------------------------------------------------------------------------------------------------
    UserId = function(source)
        return source and vRP.Passport(source) or nil
    end,

    Source = function(userId)
        return vRP.Source(userId)
    end,

    UserName = function(userId)
        local id = vRP.Identity(userId)
        return id and (id.Name .. " " .. id.Lastname) or nil
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- PERMISSÕES
    -------------------------------------------------------------------------------------------------------------------------------------
    HasGroup = function(userId, group, level)
        local r = vRP.HasGroup(userId, group, level or 1)
        return r == true or (type(r) == "number" and r >= 1)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- NOTIFICAÇÕES
    -------------------------------------------------------------------------------------------------------------------------------------
    Notify = function(source, message)
        if not source then return end
        TriggerClientEvent("Notify", source, "Pets", tostring(message or ""), "azul", 5000)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- BANCO DE DADOS
    -------------------------------------------------------------------------------------------------------------------------------------
    Query = function(query, params)
        return MySQL.query.await(query, params or {})
    end,

    Update = function(query, params)
        return MySQL.update.await(query, params or {})
    end,

    Single = function(query, params)
        return MySQL.single.await(query, params or {})
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- INVENTÁRIO
    -------------------------------------------------------------------------------------------------------------------------------------
    GetItemAmount = function(userId, item)
        return tonumber((vRP.InventoryItemAmount(userId, item) or {})[1]) or 0
    end,

    GetItemAmounts = function(userId)
        local inventory = vRP.Inventory(userId)
        if type(inventory) ~= "table" then return nil end

        local amounts = {}
        for _, slot in pairs(inventory) do
            local item = type(slot) == "table" and slot.item or nil
            if type(item) == "string" then
                local key = item:match("^[^-]+") or item
                amounts[key] = (amounts[key] or 0) + (tonumber(slot.amount) or 0)
            end
        end
        return amounts
    end,

    TryTakeItem = function(userId, item, amount)
        return vRP.TakeItem(userId, item, amount, true)
    end,

    GiveItem = function(userId, item, amount)
        return vRP.GenerateItem(userId, item, amount, true)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- PLAYERDATA
    -- Diamantes próprios (só quando Pets.Shop.UseFrameworkCoins = false).
    -------------------------------------------------------------------------------------------------------------------------------------
    GetUserData = function(userId, key)
        return vRP.UserData(userId, key)
    end,

    SetUserData = function(userId, key, value)
        vRP.Query("playerdata/SetData", { Passport = userId, Name = key, Information = json.encode(value) })
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- MOEDA PREMIUM (Diamantes = Gemstone)
    -- Usada quando Pets.Shop.UseFrameworkCoins = true. Já pronta pro Gemstone do vRP.
    -------------------------------------------------------------------------------------------------------------------------------------
    Coins = {
        Get = function(userId)
            local id = vRP.Identity(userId)
            return id and tonumber(vRP.UserGemstone(id.License)) or 0
        end,

        Give = function(userId, amount)
            vRP.UpgradeGemstone(userId, amount)
            return true
        end,

        Remove = function(userId, amount)
            return vRP.PaymentGems(userId, amount) == true
        end,
    },

    -------------------------------------------------------------------------------------------------------------------------------------
    -- HOOK: SPAWN DE PROP
    -- Chamado antes de spawnar o prop no client. Retornar false aborta (ex.: anticheat).
    -------------------------------------------------------------------------------------------------------------------------------------
    OnPropSpawn = function(source, data)
        -- exports["PL_PROTECT"]:setSpawnClient(source, data.prop)
        return true
    end,
}
