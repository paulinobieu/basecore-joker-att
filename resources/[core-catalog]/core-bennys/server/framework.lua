-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (SERVER)
-- Camada de adaptação com a sua base (vRP por padrão). Adapte só o CORPO das funções.
-----------------------------------------------------------------------------------------------------------------------------------------
Proxy = module("vrp", "lib/Proxy")
vRP   = Proxy.getInterface("vRP")

Framework = {
    -------------------------------------------------------------------------------------------------------------------------------------
    -- IDENTIDADE
    -------------------------------------------------------------------------------------------------------------------------------------
    Passport = function(source)
        return vRP.Passport(source)
    end,

    Source = function(Passport)
        return vRP.Source(Passport)
    end,

    FullName = function(Passport)
        local Identity = vRP.Identity(Passport)
        return Identity and (Identity.Name .. " " .. Identity.Lastname)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- PERMISSÕES
    -------------------------------------------------------------------------------------------------------------------------------------
    HasPermission = function(Passport, Permission)
        return vRP.HasPermission(Passport, Permission)
    end,

    UsersByPermission = function(Permission)
        return vRP.NumPermission(Permission)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- VEÍCULO
    -------------------------------------------------------------------------------------------------------------------------------------
    PlateOwner = function(Plate)
        return vRP.PassportPlate(Plate)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- PAGAMENTO
    -------------------------------------------------------------------------------------------------------------------------------------
    TryPayment = function(Passport, Price)
        return vRP.PaymentBank(Passport, Price)
    end,

    GiveBank = function(Passport, Amount)
        return vRP.GiveBank(Passport, Amount)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- BANCO DE DADOS
    -------------------------------------------------------------------------------------------------------------------------------------
    DatabaseReady = function(Callback)
        return MySQL.ready(Callback)
    end,

    Query = function(Sql, Params)
        return MySQL.query.await(Sql, Params or {})
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- NOTIFICAÇÕES
    -------------------------------------------------------------------------------------------------------------------------------------
    Notify = function(Source, Style, Content, Time)
        if Source then
            TriggerClientEvent("core-bennys:notifyBennys", Source, Style, Content, Time)
        else
            TriggerEvent("core-bennys:notifyBennys", Style, Content, Time)
        end
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- CICLO DE VIDA
    -------------------------------------------------------------------------------------------------------------------------------------
    -- O Handler recebe (Passport, Source), nessa ordem. É por aqui que orçamentos e serviços
    -- em andamento são encerrados quando alguém cai; se a sua base usar outra assinatura,
    -- ajuste aqui para entregar o PASSAPORTE como primeiro argumento.
    OnConnect = function(Handler)
        AddEventHandler("Connect", Handler)
    end,

    OnDisconnect = function(Handler)
        AddEventHandler("Disconnect", Handler)
    end,
}
