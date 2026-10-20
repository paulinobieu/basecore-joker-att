-----------------------------------------------------------------------------------------------------------------------------------------
-- MULTAS
-- O banco não aplica multa: ele guarda e cobra. Quem aplica é o MDT, pelo
-- export AddFine. A multa é sempre do passaporte, nunca da empresa.
-----------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------
-- FINERECORD
-- Formato consumido pelo MDT. Os nomes dos campos são contrato: não renomear.
-----------------------------------------------------------------------------------------------------------------------------------------
local function FineRecord(Row)
    if not Row then return false end

    return {
        id          = parseInt(Row.id),
        Passport    = parseInt(Row.passport),
        Officer     = Row.officer and parseInt(Row.officer) or nil,
        Timestamp   = parseInt(Row.created_at),
        Infractions = Row.infractions,
        Fine        = parseInt(Row.amount),
        Description = Row.description,
        Paid        = Row.paid_at ~= nil,
        Arrest      = Row.arrest_id and parseInt(Row.arrest_id) or nil,
    }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDFINE
-----------------------------------------------------------------------------------------------------------------------------------------
function AddFine(Passport, Officer, Value, Description, Infractions, ArrestId)
    local Target = NormalizeAmount(Passport)
    local Amount = NormalizeAmount(Value)

    if not Target or not Amount or not Framework.Exists(Target) then return false end
    if Amount < Bank.Fines.Amount.Min or Amount > Bank.Fines.Amount.Max then return false end

    local FineId = InsertFine(
        Target,
        NormalizeAmount(Officer) or nil,
        Amount,
        LimitText(Description, 4000),
        LimitText(Infractions, 8000),
        NormalizeAmount(ArrestId) or nil,
        Now()
    )

    if not FineId then return false end

    local Source = Framework.Source(Target)
    if Source then
        Framework.Notify(Source, Bank.Language.FineIncoming:format(Amount), "vermelho")
    end

    return FineId
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FINERECORDS
-----------------------------------------------------------------------------------------------------------------------------------------
function FineRecords(Passport, IncludePaid)
    local Target = NormalizeAmount(Passport)
    if not Target then return {} end

    local Result = {}
    for _, Row in ipairs(FindFinesOf(Target, IncludePaid and true or false)) do
        Result[#Result + 1] = FineRecord(Row)
    end

    return Result
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FINERECORDBYID
-----------------------------------------------------------------------------------------------------------------------------------------
function FineRecordById(FineId)
    local Id = NormalizeAmount(FineId)
    return Id and FineRecord(FindFine(Id)) or false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FINERECORDBYARREST
-----------------------------------------------------------------------------------------------------------------------------------------
function FineRecordByArrest(ArrestId)
    local Id = NormalizeAmount(ArrestId)
    return Id and FineRecord(FindFineByArrest(Id)) or false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDFINES
-- Formato da interface, com o nome de quem aplicou já resolvido.
-----------------------------------------------------------------------------------------------------------------------------------------
function BuildFines(Passport)
    local Result = {}

    for _, Row in ipairs(FindFinesOf(Passport, true)) do
        local Officer = Row.officer and parseInt(Row.officer) or false

        Result[#Result + 1] = {
            id          = parseInt(Row.id),
            amount      = parseInt(Row.amount),
            description = Row.description or "Multa",
            infractions = Row.infractions,
            officer     = Officer and NameOf(Officer) or "Desconhecido",
            date        = parseInt(Row.created_at),
            paid        = Row.paid_at and parseInt(Row.paid_at) or false,
        }
    end

    return Result
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PAYFINE
-- A multa é do passaporte, mas pode ser quitada com o saldo de qualquer conta
-- que o jogador acesse.
-----------------------------------------------------------------------------------------------------------------------------------------
function PayFine(Passport, AccountId, FineId)
    if not Acquire(Passport) then return false, Bank.Language.Busy end

    local Success, Message = false, Bank.Language.Failed

    local Ok, Error = pcall(function()
        local Fine = FindFine(NormalizeAmount(FineId) or 0)
        if not Fine or Fine.paid_at ~= nil or parseInt(Fine.passport) ~= Passport then
            Message = Bank.Language.FineMissing
            return
        end

        local Account = AccessibleAccount(Passport, AccountId)
        if not Account then
            Message = Bank.Language.NoAccess
            return
        end

        local Amount = parseInt(Fine.amount)
        if BalanceOf(Account) < Amount then
            Message = Bank.Language.NoFunds
            return
        end

        if not Debit(Account, Amount) then
            Message = Bank.Language.NoFunds
            return
        end

        -- Fecha depois de cobrar: se alguém já quitou, devolve o dinheiro.
        if not CloseFine(parseInt(Fine.id), Now()) then
            Credit(Account, Amount)
            Message = Bank.Language.FineMissing
            return
        end

        Record(parseInt(Account.id), 0, "fine", Amount, Fine.description or "Multa", Framework.FullName(Passport))
        Snapshot(Account)

        Success = true
        Message = Bank.Language.FinePaid:format(Amount)
    end)

    Release(Passport)

    if not Ok then
        print("^1[CORE-BANK]^7 " .. tostring(Error))
        return false, Bank.Language.Failed
    end

    return Success, Message
end
