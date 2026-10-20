-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (SERVER)
-- Camada de adaptação com a base. Adapte só o CORPO das funções.
-----------------------------------------------------------------------------------------------------------------------------------------
Tunnel = module("vrp", "lib/Tunnel")
Proxy  = module("vrp", "lib/Proxy")
vRP    = Proxy.getInterface("vRP")

Core = {}
Tunnel.bindInterface("core-shops", Core)

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

    Route = function(Source)
        return GetPlayerRoutingBucket(Source)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- ACESSO
    -------------------------------------------------------------------------------------------------------------------------------------
    HasService = function(Passport, Permission)
        return vRP.HasService(Passport, Permission) and true or false
    end,

    -- Impostos ou multas em aberto no core-bank.
    HasDebt = function(Passport)
        if GetResourceState("core-bank") ~= "started" then
            return false
        end

        local Taxes = exports["core-bank"]:CheckTaxes(Passport)
        local Fines = exports["core-bank"]:CheckFines(Passport)

        return (Taxes or Fines) and true or false
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- ITENS
    -------------------------------------------------------------------------------------------------------------------------------------
    ItemExist = function(Item)
        return ItemExist(Item) and true or false
    end,

    ItemName = function(Item)
        return ItemName(Item)
    end,

    -- Índice usado para montar a URL da imagem no CDN.
    ItemIndex = function(Item)
        return ItemIndex(Item) or Item
    end,

    ItemWeight = function(Item)
        return ItemWeight(Item)
    end,

    -- Itens únicos ou com carga não empilham: a compra é limitada a 1 unidade.
    ItemSingle = function(Item)
        return (ItemUnique(Item) or ItemLoads(Item)) and true or false
    end,

    GiveItem = function(Passport, Item, Amount)
        return vRP.GenerateItem(Passport, Item, Amount, false)
    end,

    TakeItem = function(Passport, Item, Amount)
        return vRP.TakeItem(Passport, Item, Amount) and true or false
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
    -- PAGAMENTO
    -------------------------------------------------------------------------------------------------------------------------------------
    -- Dinheiro em mãos e, na falta dele, saldo bancário.
    PaymentCash = function(Passport, Amount)
        return vRP.PaymentFull(Passport, Amount) and true or false
    end,

    PaymentGems = function(Passport, Amount)
        return vRP.PaymentGems(Passport, Amount) and true or false
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- SAÍDA
    -------------------------------------------------------------------------------------------------------------------------------------
    Notify = function(Source, Message, Color)
        TriggerClientEvent("Notify", Source, Shops.Language.Title, Message, Color or "amarelo", 5000)
    end,

    Log = function(Category, Data)
        if GetResourceState("core_logs") ~= "started" then
            return
        end

        exports["core_logs"]:AddLog(Category, Data)
    end,
}
