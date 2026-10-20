-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Core = {}
Tunnel.bindInterface("core-esc",Core)
-----------------------------------------------------------------------------------------------------------------------------------------
-- COUNT
-----------------------------------------------------------------------------------------------------------------------------------------
local function Count(Table)
    local Amount = 0
    for _ in pairs(Table or {}) do
        Amount = Amount + 1
    end

    return Amount
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROLE
-----------------------------------------------------------------------------------------------------------------------------------------
local function Role(Passport)
    local Permission = vRP.GetUserType(Passport,"Work")
    if not Permission then
        return "Cidadão"
    end

    local Group = vRP.Groups()[Permission]
    return (Group and Group.Name) or Permission
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYER
-----------------------------------------------------------------------------------------------------------------------------------------
local function Player(Passport)
    return {
        name = vRP.FullName(Passport),
        id = Passport,
        avatar = "",
        bank = vRP.GetBank(Passport) or 0,
        cash = vRP.ItemAmount(Passport,"dollar") or 0,
        diamonds = vRP.UserGemstone(vRP.License(Passport)) or 0,
        coins = 0,
        role = Role(Passport),
    }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERS
-----------------------------------------------------------------------------------------------------------------------------------------
local function Players()
    return {
        online = #GetPlayers(),
        cops = Count(vRP.NumPermission("Policia")),
        medics = Count(vRP.NumPermission("Medico")),
        mechanics = Count(vRP.NumPermission("Bennys")),
    }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ESCDATA
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.EscData()
    local source = source
    local Passport = vRP.Passport(source)
    if not Passport then
        return false
    end

    return {
        player = Player(Passport),
        players = Players(),
        battlepass = Config.BattlePass,
    }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SHOPDATA
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.ShopData()
    return Config.Shop
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SHOPBUY
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.ShopBuy(Payload)
    local source = source
    local Passport = vRP.Passport(source)
    if not Passport or type(Payload) ~= "table" or type(Payload.product) ~= "table" then
        return false
    end

    local Product
    for _,v in ipairs(Config.Shop.products) do
        if v.id == Payload.product.id then
            Product = v
            break
        end
    end

    if not Product then
        return false
    end

    if not Product.Item then
        TriggerClientEvent("core-esc:notify",source,"info","Produto indisponível no momento.",5000)
        return false
    end

    local Method = Payload.paymentMethod == "cash" and "cash" or "diamonds"
    local Price = parseInt((Method == "cash") and Product.price.cash or Product.price.diamonds)
    if Price <= 0 then
        TriggerClientEvent("core-esc:notify",source,"info","Forma de pagamento indisponível.",5000)
        return false
    end

    local Paid = (Method == "cash") and vRP.PaymentFull(Passport,Price) or vRP.PaymentGems(Passport,Price)
    if not Paid then
        TriggerClientEvent("core-esc:notify",source,"error","Saldo insuficiente.",5000)
        return false
    end

    vRP.GenerateItem(Passport,Product.Item,1,true)
    TriggerClientEvent("core-esc:notify",source,"success","Compra realizada com sucesso.",5000)

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RANKINGS [ Em breve ]
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Rankings(_CategoryId)
    return { rank = {}, weeklyRank = {}, dailyRank = {} }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PASSPORT
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Passport()
    return vRP.Passport(source)
end

---------------------------------------------------------------------------------------------------------------------------------------
-- AUTH / WEBHOOK
---------------------------------------------------------------------------------------------------------------------------------------
