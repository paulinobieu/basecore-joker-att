-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (SERVER)
-- Camada de adaptação com a base. Adapte só o CORPO das funções.
-----------------------------------------------------------------------------------------------------------------------------------------
Tunnel = module("vrp", "lib/Tunnel")
Proxy  = module("vrp", "lib/Proxy")
vRP    = Proxy.getInterface("vRP")

Core = {}
Tunnel.bindInterface("core-crafting", Core)

Framework = {
    -------------------------------------------------------------------------------------------------------------------------------------
    -- IDENTIDADE
    -------------------------------------------------------------------------------------------------------------------------------------
    Passport = function(Source)
        return vRP.Passport(Source)
    end,

    FullName = function(Passport)
        return vRP.FullName(Passport)
    end,

    Coords = function(Source)
        return vRP.GetEntityCoords(Source)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- CICLO DE VIDA
    -- Nomes de evento da base ficam só aqui: os módulos registram o que fazer.
    -------------------------------------------------------------------------------------------------------------------------------------
    OnPlayerLoaded = function(Handler)
        AddEventHandler("CharacterChosen", function(Passport)
            Handler(parseInt(Passport))
        end)
    end,

    OnPlayerDropped = function(Handler)
        AddEventHandler("Disconnect", function(Passport)
            Handler(parseInt(Passport))
        end)
    end,

    OnResourceStop = function(Handler)
        AddEventHandler("onResourceStop", function(Resource)
            if Resource ~= GetCurrentResourceName() then
                return
            end

            Handler()
        end)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- ACESSO
    -------------------------------------------------------------------------------------------------------------------------------------
    HasGroup = function(Passport, Group, Level)
        return vRP.HasGroup(Passport, Group, Level) and true or false
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- ITENS
    -------------------------------------------------------------------------------------------------------------------------------------
    ItemExist = function(Item)
        return ItemExist(Item) and true or false
    end,

    -- Nome nunca volta nulo: mensagens e ordenação dependem de uma string.
    ItemName = function(Item)
        return ItemName(Item) or Item
    end,

    -- Índice usado para montar a URL da imagem no CDN.
    ItemIndex = function(Item)
        return ItemIndex(Item) or Item
    end,

    ItemWeight = function(Item)
        return ItemWeight(Item) or 0
    end,

    ItemAmount = function(Passport, Item)
        return parseInt(vRP.ItemAmount(Passport, Item))
    end,

    GiveItem = function(Passport, Item, Amount)
        return vRP.GenerateItem(Passport, Item, Amount, false)
    end,

    TakeItem = function(Passport, Item, Amount)
        return vRP.TakeItem(Passport, Item, Amount, false) and true or false
    end,

    ReachedMax = function(Passport, Item, Amount)
        return vRP.MaxItens(Passport, Item, Amount) and true or false
    end,

    InventoryWeight = function(Passport)
        return vRP.InventoryWeight(Passport)
    end,

    MaxWeight = function(Passport)
        return vRP.GetWeight(Passport)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- BANCO DE DADOS
    -------------------------------------------------------------------------------------------------------------------------------------
    DatabaseReady = function(Handler)
        return MySQL.ready(Handler)
    end,

    Query = function(Statement, Params)
        return MySQL.query.await(Statement, Params or {})
    end,

    -- Escrita sem espera: continua valendo quando o resource está parando.
    Execute = function(Statement, Params)
        return MySQL.update(Statement, Params or {})
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- SAÍDA
    -------------------------------------------------------------------------------------------------------------------------------------
    Notify = function(Source, Message, Color)
        TriggerClientEvent("Notify", Source, Crafting.Language.Title, Message, Color or "amarelo", 5000)
    end,

    Log = function(Category, Data)
        if GetResourceState("core_logs") ~= "started" then
            return
        end

        exports["core_logs"]:AddLog(Category, Data)
    end,
}
