-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (SERVER)
-----------------------------------------------------------------------------------------------------------------------------------------
local pcall = pcall
local string_lower = string.lower
local string_format = string.format
local tonumber = tonumber
local tostring = tostring
local type = type

local CurrencyHandlers = {
    Diamonds = {
        Label = "diamantes",

        GetBalance = function(passport)
            local identity = vRP.Identity(passport)
            return vRP.UserGemstone(identity.License)
        end,

        Payment = function(passport, amount)
            return vRP.PaymentGems(passport, amount)
        end,

        Refund = function(passport, amount)
            vRP.UpgradeGemstone(passport, amount)
        end,
    },

    Dollar = {
        Label = "dinheiro",

        GetBalance = function(passport)
            return vRP.GetBank(passport)
        end,

        Payment = function(passport, amount)
            return vRP.PaymentBank(passport, amount)
        end,

        Refund = function(passport, amount)
            vRP.GiveBank(passport, amount)
        end,
    },
}

local CurrencyNames = {
    diamonds = "Diamonds",
    dollar = "Dollar",
}

local configuredCurrency = CurrencyNames[string_lower(tostring(Cases.System.Currency or "Diamonds"))]
if not configuredCurrency then
    configuredCurrency = "Diamonds"
    print("^3[core-cases]^0 Cases.System.Currency invalida; usando Diamonds.")
end

local Currency = CurrencyHandlers[configuredCurrency]

Framework = {
    Passport = function(source)
        return vRP.Passport(source)
    end,

    Source = function(passport)
        return vRP.Source(passport)
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
        local lastName = identity.name2 or identity.Name2 or identity.lastname or identity.Lastname

        if not firstName then return nil end
        if not lastName or lastName == "" then return firstName end

        return string_format("%s %s", firstName, lastName)
    end,

    GetCurrency = function()
        return {
            type = configuredCurrency,
            label = Currency.Label,
        }
    end,

    GetBalance = function(passport)
        local ok, result = pcall(Currency.GetBalance, passport)
        return ok and (tonumber(result) or 0) or 0
    end,

    Payment = function(passport, amount)
        local ok, result = pcall(Currency.Payment, passport, amount)
        return ok and result == true
    end,

    Refund = function(passport, amount)
        local ok = pcall(Currency.Refund, passport, amount)
        return ok
    end,

    Query = function(query, params)
        return MySQL.query.await(query, params or {})
    end,

    Insert = function(query, params)
        return MySQL.insert.await(query, params or {})
    end,

    Update = function(query, params)
        return MySQL.update.await(query, params or {})
    end,

    Single = function(query, params)
        return MySQL.single.await(query, params or {})
    end,
}
