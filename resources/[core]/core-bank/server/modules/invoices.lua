-----------------------------------------------------------------------------------------------------------------------------------------
-- FATURAS
-- Cobrança de um jogador para outro. Imposto é a mesma fatura com emissor 0:
-- é o sistema cobrando, e por isso não tem como ser cancelado por ninguém.
-----------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDINVOICE
-----------------------------------------------------------------------------------------------------------------------------------------
local function BuildInvoice(Row, AccountId)
    local IssuerId = parseInt(Row.issuer_id)
    local TargetId = parseInt(Row.target_id)
    local Issuer = IssuerId > 0 and FindAccount(IssuerId) or false
    local Target = FindAccount(TargetId)

    return {
        id       = parseInt(Row.id),
        amount   = parseInt(Row.amount),
        reason   = Row.reason,
        status   = Row.status,
        system   = IssuerId == 0,
        issuer   = Issuer and Issuer.name or Bank.Taxes.Label,
        target   = Target and Target.name or "—",
        outgoing = TargetId == AccountId,
        date     = parseInt(Row.created_at),
        paid     = Row.paid_at and parseInt(Row.paid_at) or false,
    }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDINVOICES
-----------------------------------------------------------------------------------------------------------------------------------------
function BuildInvoices(AccountId)
    local Received, Sent = {}, {}

    for _, Row in ipairs(FindInvoicesFor(AccountId, Bank.PageSize)) do
        Received[#Received + 1] = BuildInvoice(Row, AccountId)
    end

    for _, Row in ipairs(FindInvoicesBy(AccountId, Bank.PageSize)) do
        Sent[#Sent + 1] = BuildInvoice(Row, AccountId)
    end

    return { received = Received, sent = Sent }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SENDINVOICE
-- Cobra um passaporte. O destino é sempre a conta pessoal de quem foi cobrado.
-----------------------------------------------------------------------------------------------------------------------------------------
function SendInvoice(Passport, AccountId, Target, Value, Reason)
    local Amount = NormalizeAmount(Value)
    if not Amount or Amount < Bank.Invoices.Amount.Min or Amount > Bank.Invoices.Amount.Max then
        return false, Bank.Language.InvalidAmount
    end

    local Text = LimitText(Reason, Bank.Invoices.ReasonLength.Max)
    if not Text or #Text < Bank.Invoices.ReasonLength.Min then
        return false, Bank.Language.ReasonInvalid:format(Bank.Invoices.ReasonLength.Min, Bank.Invoices.ReasonLength.Max)
    end

    local Origin = AccessibleAccount(Passport, AccountId)
    if not Origin then return false, Bank.Language.NoAccess end

    local TargetPassport = NormalizeAmount(Target)
    if not TargetPassport or not Framework.Exists(TargetPassport) then
        return false, Bank.Language.TargetNotFound
    end

    local Destination = EnsureAccount(TargetPassport)
    if not Destination then return false, Bank.Language.TargetNotFound end

    if parseInt(Destination.id) == parseInt(Origin.id) then
        return false, Bank.Language.SameAccount
    end

    if CountPendingInvoices(parseInt(Origin.id)) >= Bank.Invoices.MaxPending then
        return false, Bank.Language.InvoiceLimit:format(Bank.Invoices.MaxPending)
    end

    if not InsertInvoice(parseInt(Origin.id), parseInt(Destination.id), Amount, Text, Now()) then
        return false, Bank.Language.Failed
    end

    local Source = Framework.Source(TargetPassport)
    if Source then
        Framework.Notify(Source, Bank.Language.InvoiceIncoming:format(Origin.name, Amount), "amarelo")
    end

    return true, Bank.Language.InvoiceSent:format(Amount, Framework.FullName(TargetPassport))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PAYINVOICE
-----------------------------------------------------------------------------------------------------------------------------------------
function PayInvoice(Passport, InvoiceId)
    if not Acquire(Passport) then return false, Bank.Language.Busy end

    local Success, Message = false, Bank.Language.Failed

    local Ok, Error = pcall(function()
        local Invoice = FindInvoice(NormalizeAmount(InvoiceId) or 0)
        if not Invoice or Invoice.status ~= "pending" then
            Message = Bank.Language.InvoiceMissing
            return
        end

        local Target = AccessibleAccount(Passport, parseInt(Invoice.target_id))
        if not Target then
            Message = Bank.Language.NoAccess
            return
        end

        local Amount = parseInt(Invoice.amount)
        if BalanceOf(Target) < Amount then
            Message = Bank.Language.NoFunds
            return
        end

        if not Debit(Target, Amount) then
            Message = Bank.Language.NoFunds
            return
        end

        -- Fecha depois de cobrar: se alguém já quitou, devolve o dinheiro.
        if not CloseInvoice(parseInt(Invoice.id), "paid", Now()) then
            Credit(Target, Amount)
            Message = Bank.Language.InvoiceMissing
            return
        end

        local IssuerId = parseInt(Invoice.issuer_id)
        local Issuer = IssuerId > 0 and FindAccount(IssuerId) or false

        if Issuer then
            Credit(Issuer, Amount)
            Snapshot(Issuer)

            local Source = Framework.Source(parseInt(Issuer.passport))
            if Source then
                Framework.Notify(Source, Bank.Language.Received:format(Amount, Target.name), "verde")
            end
        end

        Record(parseInt(Target.id), IssuerId, "invoice", Amount, Invoice.reason, Framework.FullName(Passport))
        Snapshot(Target)

        Success = true
        Message = Bank.Language.InvoicePaid:format(Amount)
    end)

    Release(Passport)

    if not Ok then
        print("^1[CORE-BANK]^7 " .. tostring(Error))
        return false, Bank.Language.Failed
    end

    return Success, Message
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CANCELINVOICE
-- Só o emissor cancela, e só enquanto estiver em aberto.
-----------------------------------------------------------------------------------------------------------------------------------------
function CancelInvoice(Passport, InvoiceId)
    local Invoice = FindInvoice(NormalizeAmount(InvoiceId) or 0)
    if not Invoice or Invoice.status ~= "pending" then return false, Bank.Language.InvoiceMissing end

    local IssuerId = parseInt(Invoice.issuer_id)
    if IssuerId == 0 then return false, Bank.Language.InvoiceMissing end

    if not AccessibleAccount(Passport, IssuerId) then return false, Bank.Language.NoAccess end

    if not CloseInvoice(parseInt(Invoice.id), "canceled", Now()) then
        return false, Bank.Language.InvoiceMissing
    end

    return true, Bank.Language.InvoiceCanceled
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDTAX
-- Entrada usada pelo export AddTaxes: aplica a alíquota e o desconto VIP em
-- cima do valor que o resource informou.
-----------------------------------------------------------------------------------------------------------------------------------------
function AddTax(Passport, Name, Valuation, Description)
    local Base = tonumber(Valuation)
    if not Base or Base <= 0 or not Framework.Exists(Passport) then return false end

    local Price = Base * Bank.Taxes.Rate

    for _, Vip in ipairs(Bank.Taxes.VipDiscounts) do
        if Framework.HasService(Passport, Vip.Permission) then
            Price = Price * Vip.Multiplier
            break
        end
    end

    local Amount = NormalizeAmount(Price)
    if not Amount then return false end

    local Account = EnsureAccount(Passport)
    if not Account then return false end

    local Reason = LimitText(Name or Description or Bank.Taxes.Label, Bank.Invoices.ReasonLength.Max)

    return InsertInvoice(0, parseInt(Account.id), Amount, Reason, Now()) and true or false
end
