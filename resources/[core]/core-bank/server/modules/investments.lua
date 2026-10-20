-----------------------------------------------------------------------------------------------------------------------------------------
-- INVESTIMENTOS
-- Catálogo fixo em config/investments.lua. A alíquota nunca vem de fora: o
-- servidor calcula o rendimento pelo ciclo já vencido.
-----------------------------------------------------------------------------------------------------------------------------------------
local Products = {}

for _, Product in ipairs(Bank.Investments) do
    Products[Product.Code] = Product
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDPRODUCTS
-----------------------------------------------------------------------------------------------------------------------------------------
function BuildProducts()
    local Result = {}

    for _, Product in ipairs(Bank.Investments) do
        Result[#Result + 1] = {
            code        = Product.Code,
            name        = Product.Name,
            description = Product.Description,
            rate        = Product.Rate,
            cycle       = Product.Cycle,
            lock        = Product.Lock,
            minimum     = Product.Minimum,
            maximum     = Product.Maximum,
            penalty     = Product.Penalty,
        }
    end

    return Result
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDPOSITIONS
-----------------------------------------------------------------------------------------------------------------------------------------
function BuildPositions(AccountId)
    local Result = {}
    local Timestamp = Now()

    for _, Row in ipairs(FindPositions(AccountId)) do
        local Product = Products[Row.code]
        if Product then
            local Created = parseInt(Row.created_at)

            Result[#Result + 1] = {
                id       = parseInt(Row.id),
                code     = Row.code,
                name     = Product.Name,
                amount   = parseInt(Row.amount),
                revenue  = parseInt(Row.revenue),
                date     = Created,
                yieldAt  = parseInt(Row.yield_at),
                unlockAt = Created + (Product.Lock * 3600),
                locked   = Timestamp < Created + (Product.Lock * 3600),
                penalty  = Product.Penalty,
            }
        end
    end

    return Result
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVEST
-----------------------------------------------------------------------------------------------------------------------------------------
function Invest(Passport, AccountId, Code, Value)
    local Product = type(Code) == "string" and Products[Code] or nil
    if not Product then return false, Bank.Language.ProductMissing end

    local Amount = NormalizeAmount(Value)
    if not Amount then return false, Bank.Language.InvalidAmount end

    if Amount < Product.Minimum then
        return false, Bank.Language.ProductMinimum:format(Product.Minimum)
    end

    if Product.Maximum > 0 and Amount > Product.Maximum then
        return false, Bank.Language.ProductMaximum:format(Product.Maximum)
    end

    if not Acquire(Passport) then return false, Bank.Language.Busy end

    local Success, Message = false, Bank.Language.Failed

    local Ok, Error = pcall(function()
        local Account = AccessibleAccount(Passport, AccountId)
        if not Account then
            Message = Bank.Language.NoAccess
            return
        end

        if BalanceOf(Account) < Amount then
            Message = Bank.Language.NoFunds
            return
        end

        if not Debit(Account, Amount) then
            Message = Bank.Language.NoFunds
            return
        end

        local Timestamp = Now()
        local PositionId = InsertPosition(
            parseInt(Account.id),
            Product.Code,
            Amount,
            Timestamp + (Product.Cycle * 3600),
            Timestamp
        )

        if not PositionId then
            Credit(Account, Amount)
            return
        end

        Record(parseInt(Account.id), 0, "invest", Amount, "Aplicação em " .. Product.Name, Framework.FullName(Passport))
        Snapshot(Account)

        Success = true
        Message = Bank.Language.Invested:format(Amount, Product.Name)
    end)

    Release(Passport)

    if not Ok then
        print("^1[CORE-BANK]^7 " .. tostring(Error))
        return false, Bank.Language.Failed
    end

    return Success, Message
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REDEEM
-- Resgate leva o principal mais o rendimento acumulado. Dentro da carência,
-- parte do rendimento fica com o banco.
-----------------------------------------------------------------------------------------------------------------------------------------
function Redeem(Passport, AccountId, PositionId)
    if not Acquire(Passport) then return false, Bank.Language.Busy end

    local Success, Message = false, Bank.Language.Failed

    local Ok, Error = pcall(function()
        local Position = FindPosition(NormalizeAmount(PositionId) or 0)
        if not Position then
            Message = Bank.Language.PositionMissing
            return
        end

        local Account = AccessibleAccount(Passport, AccountId)
        if not Account or parseInt(Position.account_id) ~= parseInt(Account.id) then
            Message = Bank.Language.NoAccess
            return
        end

        local Product = Products[Position.code]
        if not Product then
            Message = Bank.Language.ProductMissing
            return
        end

        local Principal = parseInt(Position.amount)
        local Revenue = parseInt(Position.revenue)
        local Locked = Now() < parseInt(Position.created_at) + (Product.Lock * 3600)

        if Locked and Product.Penalty > 0 then
            Revenue = math.floor(Revenue * (1 - Product.Penalty))
        end

        local Total = Principal + Revenue

        -- Apaga primeiro: se outra chamada já resgatou, esta para aqui.
        if not DeletePosition(parseInt(Position.id)) then
            Message = Bank.Language.PositionMissing
            return
        end

        Credit(Account, Total)
        Record(0, parseInt(Account.id), "redeem", Total, "Resgate de " .. Product.Name, Framework.FullName(Passport))
        Snapshot(Account)

        Success = true
        Message = Bank.Language.Redeemed:format(Total)
    end)

    Release(Passport)

    if not Ok then
        print("^1[CORE-BANK]^7 " .. tostring(Error))
        return false, Bank.Language.Failed
    end

    return Success, Message
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- YIELDCYCLE
-- Roda de hora em hora e paga todos os ciclos já vencidos de cada aplicação,
-- inclusive os que venceram com o servidor desligado.
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    while true do
        Wait(3600000)

        local Timestamp = Now()

        for _, Row in ipairs(FindMaturedPositions(Timestamp)) do
            local Product = Products[Row.code]

            if Product then
                local Cycle = Product.Cycle * 3600
                local YieldAt = parseInt(Row.yield_at)
                local Revenue = parseInt(Row.revenue)
                local Principal = parseInt(Row.amount)
                local Cycles = 0

                while YieldAt <= Timestamp and Cycles < 720 do
                    Revenue = Revenue + math.floor(Principal * Product.Rate)
                    YieldAt = YieldAt + Cycle
                    Cycles = Cycles + 1
                end

                if Cycles > 0 then
                    UpdatePositionYield(parseInt(Row.id), Revenue, YieldAt)
                end
            end
        end
    end
end)
