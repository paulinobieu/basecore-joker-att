-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (SERVER)
-- Camada de adaptação com a sua base (vRP por padrão). Adapte só o CORPO das funções.
-----------------------------------------------------------------------------------------------------------------------------------------
Tunnel = module("vrp", "lib/Tunnel")
Proxy  = module("vrp", "lib/Proxy")
vRP    = Proxy.getInterface("vRP")

Framework = {
    -------------------------------------------------------------------------------------------------------------------------------------
    -- IDENTIDADE
    -------------------------------------------------------------------------------------------------------------------------------------
    Passport = function(Source)
        return vRP.Passport(Source)
    end,

    Source = function(Passport)
        return vRP.Source(Passport)
    end,

    FullName = function(Passport)
        return vRP.FullName(Passport) or "Desconhecido"
    end,

    Exists = function(Passport)
        return vRP.Identity(Passport) and true or false
    end,

    --- Usado só para o desconto de imposto por VIP.
    HasService = function(Passport, Permission)
        return vRP.HasService(Passport, Permission) and true or false
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- NOTIFICAÇÕES
    -------------------------------------------------------------------------------------------------------------------------------------
    Notify = function(Source, Message, Color)
        TriggerClientEvent("Notify", Source, Bank.Language.Title, Message, Color or "amarelo", 5000)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- DINHEIRO
    -- O saldo da conta pessoal é o saldo bancário da vRP: o resto do servidor
    -- continua lendo e escrevendo pelo mesmo lugar.
    -------------------------------------------------------------------------------------------------------------------------------------
    GetBank = function(Passport)
        return vRP.GetBank(Passport) or 0
    end,

    GiveBank = function(Passport, Amount)
        return vRP.GiveBank(Passport, Amount) and true or false
    end,

    TakeBank = function(Passport, Amount)
        return vRP.PaymentBank(Passport, Amount) and true or false
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- DINHEIRO EM MÃOS
    -------------------------------------------------------------------------------------------------------------------------------------
    CashAmount = function(Passport)
        return vRP.ItemAmount(Passport, "dollar") or 0
    end,

    TakeCash = function(Passport, Amount)
        return vRP.TakeItem(Passport, "dollar", Amount, true) and true or false
    end,

    GiveCash = function(Passport, Amount)
        return vRP.GenerateItem(Passport, "dollar", Amount, true) and true or false
    end,

    CashFits = function(Passport, Amount)
        return vRP.CheckWeight(Passport, "dollar", Amount) and true or false
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- PERSISTÊNCIA
    -------------------------------------------------------------------------------------------------------------------------------------
    DatabaseReady = function(Handler)
        return MySQL.ready(Handler)
    end,

    Query = function(Sql, Params)
        return MySQL.query.await(Sql, Params or {})
    end,

    Insert = function(Sql, Params)
        return MySQL.insert.await(Sql, Params or {})
    end,

    Execute = function(Sql, Params)
        return MySQL.update.await(Sql, Params or {})
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- REDE EXTERNA
    -- Só o servidor fala com a internet, e só com o endpoint fixo da config.
    -------------------------------------------------------------------------------------------------------------------------------------
    Request = function(Url, Handler)
        PerformHttpRequest(Url, Handler, "GET", "", { ["Accept"] = "application/json" })
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- CICLO DE VIDA
    -------------------------------------------------------------------------------------------------------------------------------------
    OnPlayerDropped = function(Handler)
        AddEventHandler("Disconnect", function(Passport)
            Handler(parseInt(Passport))
        end)
    end,

    OnResourceStop = function(Handler)
        AddEventHandler("onResourceStop", function(Resource)
            if Resource ~= GetCurrentResourceName() then return end
            Handler()
        end)
    end,
}
