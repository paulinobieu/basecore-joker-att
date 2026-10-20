-----------------------------------------------------------------------------------------------------------------------------------------
-- CRIPTOMOEDAS
-- O servidor é o único que fala com a CoinGecko, em um pedido só para todas as
-- moedas da allowlist. A interface recebe o snapshot pronto e nunca manda
-- preço: ela manda intenção, o servidor calcula.
-----------------------------------------------------------------------------------------------------------------------------------------
local Assets = {}
local Quotes = {}
local ProviderIds = {}
local UpdatedAt = 0
local Refreshing = false

for _, Asset in ipairs(Bank.Crypto.Assets) do
    Assets[Asset.Asset] = Asset
    ProviderIds[#ProviderIds + 1] = Asset.Provider
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- QUOTEFRESH
-- A cotação vencida continua aparecendo na tela, mas trava a negociação.
-----------------------------------------------------------------------------------------------------------------------------------------
local function QuoteFresh()
    return UpdatedAt > 0 and (Now() - UpdatedAt) <= (Bank.Crypto.Provider.Freshness * 60)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- APPLYSNAPSHOT
-- Só substitui o cache quando a resposta traz todas as moedas com preço
-- válido. Resposta parcial não derruba um snapshot bom.
-----------------------------------------------------------------------------------------------------------------------------------------
local function ApplySnapshot(Payload)
    local Snapshot = {}

    -- A resposta é uma lista; indexamos pelo id do provedor.
    local ById = {}
    for _, Entry in ipairs(Payload) do
        if type(Entry) == "table" and Entry.id then
            ById[Entry.id] = Entry
        end
    end

    for Key, Asset in pairs(Assets) do
        local Entry = ById[Asset.Provider]
        local Price = Entry and tonumber(Entry.current_price)

        if not Price or Price ~= Price or Price <= 0 then return false end

        local Previous = Quotes[Key]
        if Previous and Previous.price > 0 then
            local Deviation = math.abs(Price - Previous.price) / Previous.price
            if Deviation > Bank.Crypto.Provider.MaxDeviation then
                print("^3[CORE-BANK]^7 cotação suspeita de " .. Asset.Symbol .. ": variação de " ..
                    math.floor(Deviation * 100) .. "% em uma atualização.")
                return false
            end
        end

        Snapshot[Key] = {
            price  = Price,
            hour   = tonumber(Entry.price_change_percentage_1h_in_currency) or 0.0,
            day    = tonumber(Entry.price_change_percentage_24h_in_currency) or 0.0,
            week   = tonumber(Entry.price_change_percentage_7d_in_currency) or 0.0,
        }
    end

    Quotes = Snapshot
    UpdatedAt = Now()

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REFRESHQUOTES
-- Uma atualização por vez: se vários jogadores abrirem o banco juntos, todos
-- leem o mesmo cache.
-----------------------------------------------------------------------------------------------------------------------------------------
local function RefreshQuotes()
    if Refreshing then return end

    Refreshing = true

    local Url = ("%s?vs_currency=%s&ids=%s&price_change_percentage=1h,24h,7d"):format(
        Bank.Crypto.Provider.Endpoint,
        Bank.Crypto.Provider.Currency,
        table.concat(ProviderIds, ",")
    )

    Framework.Request(Url, function(Status, Body)
        Refreshing = false

        if Status ~= 200 or type(Body) ~= "string" or Body == "" then
            print("^3[CORE-BANK]^7 cotação indisponível (HTTP " .. tostring(Status) .. ").")
            return
        end

        local Ok, Payload = pcall(json.decode, Body)
        if not Ok or type(Payload) ~= "table" or #Payload == 0 then
            print("^3[CORE-BANK]^7 cotação com resposta inválida.")
            return
        end

        ApplySnapshot(Payload)
    end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDMARKET
-----------------------------------------------------------------------------------------------------------------------------------------
function BuildMarket()
    local Result = {}

    for _, Asset in ipairs(Bank.Crypto.Assets) do
        local Quote = Quotes[Asset.Asset]

        Result[#Result + 1] = {
            asset    = Asset.Asset,
            symbol   = Asset.Symbol,
            name     = Asset.Name,
            decimals = Asset.Decimals,
            price    = Quote and Quote.price or 0,
            hour     = Quote and Quote.hour or 0,
            day      = Quote and Quote.day or 0,
            week     = Quote and Quote.week or 0,
        }
    end

    return {
        assets    = Result,
        fee       = Bank.Crypto.Fee,
        minimum   = Bank.Crypto.Minimum,
        fresh     = QuoteFresh(),
        updatedAt = UpdatedAt,
    }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDWALLET
-----------------------------------------------------------------------------------------------------------------------------------------
function BuildWallet(AccountId)
    local Result = {}

    for _, Row in ipairs(FindWallet(AccountId)) do
        local Asset = Assets[Row.asset]

        if Asset then
            local Amount = tonumber(Row.amount) or 0.0
            local Quote = Quotes[Row.asset]

            Result[#Result + 1] = {
                asset  = Row.asset,
                symbol = Asset.Symbol,
                name   = Asset.Name,
                amount = Amount,
                value  = Quote and math.floor(Amount * Quote.price) or 0,
            }
        end
    end

    return Result
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRADE
-- Mode "buy": o jogador informa quanto quer gastar em R$.
-- Mode "sell": o jogador informa quanto da moeda quer vender.
-- O valor em R$ é sempre inteiro; centavo é descartado no servidor.
-----------------------------------------------------------------------------------------------------------------------------------------
function Trade(Passport, AccountId, AssetKey, Mode, Value)
    local Asset = type(AssetKey) == "string" and Assets[AssetKey] or nil
    if not Asset then return false, Bank.Language.AssetMissing end

    if not QuoteFresh() then return false, Bank.Language.QuoteStale end

    local Quote = Quotes[Asset.Asset]
    if not Quote or Quote.price <= 0 then return false, Bank.Language.QuoteStale end

    if not Acquire(Passport) then return false, Bank.Language.Busy end

    local Success, Message = false, Bank.Language.Failed

    local Ok, Error = pcall(function()
        local Account = AccessibleAccount(Passport, AccountId)
        if not Account then
            Message = Bank.Language.NoAccess
            return
        end

        local AccountKey = parseInt(Account.id)
        local Author = Framework.FullName(Passport)
        local Factor = 10 ^ Asset.Decimals

        if Mode == "buy" then
            local Spend = NormalizeAmount(Value)
            if not Spend then
                Message = Bank.Language.InvalidAmount
                return
            end

            if Spend < Bank.Crypto.Minimum then
                Message = Bank.Language.TradeMinimum:format(Bank.Crypto.Minimum)
                return
            end

            if BalanceOf(Account) < Spend then
                Message = Bank.Language.NoFunds
                return
            end

            -- A taxa sai do valor gasto: o resto vira moeda.
            local Net = Spend * (1 - Bank.Crypto.Fee)
            local Units = math.floor((Net / Quote.price) * Factor) / Factor

            if Units <= 0 then
                Message = Bank.Language.TradeMinimum:format(Bank.Crypto.Minimum)
                return
            end

            if not Debit(Account, Spend) then
                Message = Bank.Language.NoFunds
                return
            end

            SaveWalletAsset(AccountKey, Asset.Asset, FindWalletAsset(AccountKey, Asset.Asset) + Units)
            Record(AccountKey, 0, "crypto", Spend, "Compra de " .. Asset.Symbol, Author)
            Snapshot(Account)

            Success = true
            Message = Bank.Language.Bought:format(string.format("%." .. Asset.Decimals .. "f", Units), Asset.Symbol)
            return
        end

        local Units = tonumber(Value)
        if not Units or Units ~= Units or Units <= 0 then
            Message = Bank.Language.InvalidAmount
            return
        end

        Units = math.floor(Units * Factor) / Factor

        local Holding = FindWalletAsset(AccountKey, Asset.Asset)
        if Units <= 0 or Holding < Units then
            Message = Bank.Language.NoAsset
            return
        end

        local Gross = Units * Quote.price
        local Payout = math.floor(Gross * (1 - Bank.Crypto.Fee))

        if Payout < 1 then
            Message = Bank.Language.TradeMinimum:format(Bank.Crypto.Minimum)
            return
        end

        SaveWalletAsset(AccountKey, Asset.Asset, Holding - Units)

        if not Credit(Account, Payout) then
            SaveWalletAsset(AccountKey, Asset.Asset, Holding)
            return
        end

        Record(0, AccountKey, "crypto", Payout, "Venda de " .. Asset.Symbol, Author)
        Snapshot(Account)

        Success = true
        Message = Bank.Language.Sold:format(string.format("%." .. Asset.Decimals .. "f", Units), Asset.Symbol)
    end)

    Release(Passport)

    if not Ok then
        print("^1[CORE-BANK]^7 " .. tostring(Error))
        return false, Bank.Language.Failed
    end

    return Success, Message
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CICLO DE ATUALIZAÇÃO
-- Espera aleatória na largada para vários servidores não baterem juntos.
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    Wait(math.random(2000, 8000))

    while true do
        RefreshQuotes()
        Wait(Bank.Crypto.Provider.Interval * 60000)
    end
end)
