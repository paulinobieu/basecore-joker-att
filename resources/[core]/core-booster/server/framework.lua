-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (SERVER)
-----------------------------------------------------------------------------------------------------------------------------------------
Tunnel = module("vrp", "lib/Tunnel")
Proxy  = module("vrp", "lib/Proxy")
vRP    = Proxy.getInterface("vRP")

Core = {}
Tunnel.bindInterface("core-booster", Core)

Framework = {
    -------------------------------------------------------------------------------------------------------------------------------------
    -- IDENTIDADE
    -------------------------------------------------------------------------------------------------------------------------------------
    Passport = function(Source)
        return vRP.Passport(Source)
    end,

    Players = function()
        return vRP.Players()
    end,

    FullName = function(Passport)
        return vRP.FullName(Passport)
    end,

    DiscordId = function(Source, Passport)
        local Account = Passport and vRP.AccountInformation(Passport, "Discord")
        if Account and tostring(Account) ~= "0" then
            return tostring(Account)
        end

        local Identifier = Source and GetPlayerIdentifierByType(Source, "discord")
        if not Identifier then
            return false
        end

        return (Identifier:gsub("discord:", ""))
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- ITENS
    -------------------------------------------------------------------------------------------------------------------------------------
    ItemExist = function(Item)
        return ItemExist(Item) and true or false
    end,

    ItemName = function(Item)
        return ItemName(Item) or Item
    end,

    ItemIndex = function(Item)
        return ItemIndex(Item) or Item
    end,

    ItemWeight = function(Item)
        return ItemWeight(Item) or 0
    end,

    GiveItem = function(Passport, Item, Amount)
        return vRP.GenerateItem(Passport, Item, Amount, false) and true or false
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
    -- ECONOMIA
    -------------------------------------------------------------------------------------------------------------------------------------
    GiveBank = function(Passport, Amount)
        return vRP.GiveBank(Passport, Amount) and true or false
    end,

    GiveGems = function(Passport, Amount)
        if Amount <= 0 then
            return false
        end

        vRP.UpgradeGemstone(Passport, Amount)

        return true
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- VEÍCULOS
    -------------------------------------------------------------------------------------------------------------------------------------
    VehicleInfo = function(Model)
        if GetResourceState("core-vehicles") ~= "started" then
            return false
        end

        return exports["core-vehicles"]:getVehicleInfo(Model) or false
    end,

    GiveVehicle = function(Passport, Model)
        if GetResourceState("core-vehicles") ~= "started" then
            return false
        end

        local Result = exports["core-vehicles"]:giveVehicle(Passport, Model)
        if type(Result) ~= "table" or not Result.ok then
            return false, type(Result) == "table" and Result.error or false
        end

        return true, Result.plate
    end,

    DeleteVehicle = function(Plate)
        if GetResourceState("core-vehicles") ~= "started" then
            return false
        end

        return exports["core-vehicles"]:deleteVehicle(Plate) and true or false
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

    Execute = function(Statement, Params)
        return MySQL.update.await(Statement, Params or {})
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- CICLO DE VIDA
    -------------------------------------------------------------------------------------------------------------------------------------
    OnCharacterChosen = function(Handler)
        AddEventHandler("CharacterChosen", function(Passport, Source)
            Handler(parseInt(Passport), Source)
        end)
    end,

    OnPlayerDropped = function(Handler)
        AddEventHandler("Disconnect", function(Passport)
            Handler(parseInt(Passport))
        end)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- SAÍDA
    -------------------------------------------------------------------------------------------------------------------------------------
    Notify = function(Source, Message, Color)
        TriggerClientEvent("Notify", Source, Booster.Language.Title, Message, Color or "amarelo", 5000)
    end,

    OpenPanel = function(Source, Data)
        TriggerClientEvent("core-booster:OpenPanel", Source, Data)
    end,

    Log = function(Category, Data)
        if GetResourceState("core_logs") ~= "started" then
            return
        end

        exports["core_logs"]:AddLog(Category, Data)
    end,
}
