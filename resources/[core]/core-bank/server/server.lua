-----------------------------------------------------------------------------------------------------------------------------------------
-- INTERFACE
-- Ponto de entrada da NUI. Toda função resolve o passaporte pelo source, nunca
-- confia no que a interface manda e devolve sempre { success, message }.
-----------------------------------------------------------------------------------------------------------------------------------------
Core = {}
Tunnel.bindInterface(GetCurrentResourceName(), Core)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ANSWER
-----------------------------------------------------------------------------------------------------------------------------------------
local function Answer(Success, Message)
    return { success = Success and true or false, message = Message }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BOOTSTRAP
-- O que não depende da conta escolhida: lista de contas, convites, catálogo de
-- aplicações e mercado de cripto.
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Bootstrap()

    local Passport = Framework.Passport(source)
    if not Passport then return false end

    return {
        passport  = Passport,
        name      = Framework.FullName(Passport),
        symbol    = Bank.Symbol,
        accounts  = BuildAccounts(Passport),
        invites   = BuildInvites(Passport),
        products  = BuildProducts(),
        market    = BuildMarket(),
    }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ACCOUNT
-- Tudo que as abas mostram da conta escolhida, em uma consulta só.
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Account(AccountId)

    local Passport = Framework.Passport(source)
    if not Passport then return false end

    local Account = AccessibleAccount(Passport, AccountId)
    if not Account then return false end

    local Id = parseInt(Account.id)
    local Invoices = BuildInvoices(Id)

    return {
        id        = Id,
        name      = Account.name,
        business  = Truthy(Account.business),
        owner     = parseInt(Account.passport) == Passport,
        balance   = BalanceOf(Account),
        statement = BuildStatement(Id),
        chart     = BuildChart(Id),
        pix       = BuildPixKeys(Id),
        transfers = BuildStatement(Id, "transfer"),
        pixLog    = BuildStatement(Id, "pix"),
        invoices  = Invoices.received,
        issued    = Invoices.sent,
        fines     = BuildFines(Passport),
        positions = BuildPositions(Id),
        wallet    = BuildWallet(Id),
        members   = BuildMembers(Account),
    }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CAIXA
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Deposit(AccountId, Amount)

    local Passport = Framework.Passport(source)
    if not Passport then return Answer(false, Bank.Language.Failed) end

    return Answer(Deposit(Passport, AccountId, Amount))
end

function Core.Withdraw(AccountId, Amount)

    local Passport = Framework.Passport(source)
    if not Passport then return Answer(false, Bank.Language.Failed) end

    return Answer(Withdraw(Passport, AccountId, Amount))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRANSFERÊNCIAS
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Transfer(AccountId, Target, Amount)

    local Passport = Framework.Passport(source)
    if not Passport then return Answer(false, Bank.Language.Failed) end

    return Answer(Transfer(Passport, AccountId, Target, Amount, "transfer"))
end

function Core.Pix(AccountId, Key, Amount)

    local Passport = Framework.Passport(source)
    if not Passport then return Answer(false, Bank.Language.Failed) end

    return Answer(Transfer(Passport, AccountId, Key, Amount, "pix"))
end

function Core.CreatePixKey(AccountId, Key)

    local Passport = Framework.Passport(source)
    if not Passport then return Answer(false, Bank.Language.Failed) end

    return Answer(CreatePixKey(Passport, AccountId, Key))
end

function Core.RemovePixKey(AccountId, Key)

    local Passport = Framework.Passport(source)
    if not Passport then return Answer(false, Bank.Language.Failed) end

    return Answer(DestroyPixKey(Passport, AccountId, Key))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EMPRESAS
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.CreateBusiness(Name)

    local Passport = Framework.Passport(source)
    if not Passport then return Answer(false, Bank.Language.Failed) end

    return Answer(CreateBusiness(Passport, Name))
end

function Core.InviteMember(AccountId, Target)

    local Passport = Framework.Passport(source)
    if not Passport then return Answer(false, Bank.Language.Failed) end

    return Answer(InviteMember(Passport, AccountId, Target))
end

function Core.RemoveMember(AccountId, Target)

    local Passport = Framework.Passport(source)
    if not Passport then return Answer(false, Bank.Language.Failed) end

    return Answer(RemoveMember(Passport, AccountId, Target))
end

function Core.AnswerInvite(AccountId, Accept)

    local Passport = Framework.Passport(source)
    if not Passport then return Answer(false, Bank.Language.Failed) end

    return Answer(AnswerInvite(Passport, AccountId, Accept == true))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FATURAS E MULTAS
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.SendInvoice(AccountId, Target, Amount, Reason)

    local Passport = Framework.Passport(source)
    if not Passport then return Answer(false, Bank.Language.Failed) end

    return Answer(SendInvoice(Passport, AccountId, Target, Amount, Reason))
end

function Core.PayInvoice(InvoiceId)

    local Passport = Framework.Passport(source)
    if not Passport then return Answer(false, Bank.Language.Failed) end

    return Answer(PayInvoice(Passport, InvoiceId))
end

function Core.CancelInvoice(InvoiceId)

    local Passport = Framework.Passport(source)
    if not Passport then return Answer(false, Bank.Language.Failed) end

    return Answer(CancelInvoice(Passport, InvoiceId))
end

function Core.PayFine(AccountId, FineId)

    local Passport = Framework.Passport(source)
    if not Passport then return Answer(false, Bank.Language.Failed) end

    return Answer(PayFine(Passport, AccountId, FineId))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVESTIMENTOS E CRIPTOMOEDAS
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Invest(AccountId, Code, Amount)

    local Passport = Framework.Passport(source)
    if not Passport then return Answer(false, Bank.Language.Failed) end

    return Answer(Invest(Passport, AccountId, Code, Amount))
end

function Core.Redeem(AccountId, PositionId)

    local Passport = Framework.Passport(source)
    if not Passport then return Answer(false, Bank.Language.Failed) end

    return Answer(Redeem(Passport, AccountId, PositionId))
end

function Core.Trade(AccountId, Asset, Mode, Amount)

    local Passport = Framework.Passport(source)
    if not Passport then return Answer(false, Bank.Language.Failed) end

    if Mode ~= "buy" and Mode ~= "sell" then
        return Answer(false, Bank.Language.InvalidAmount)
    end

    return Answer(Trade(Passport, AccountId, Asset, Mode, Amount))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXPORTS
-- Contrato consumido por outros resources. Assinaturas e nomes de campo são
-- fixos: mdt, admin, painel, propertys, shops, player, core-shops e
-- core-vehicles dependem deles.
-----------------------------------------------------------------------------------------------------------------------------------------
exports("AddFine", function(Passport, Officer, Amount, Description, Infractions, ArrestId)

    return AddFine(Passport, Officer, Amount, Description, Infractions, ArrestId)
end)

exports("GetFineRecords", function(Passport, IncludePaid)

    return FineRecords(Passport, IncludePaid)
end)

exports("GetFine", function(FineId)

    return FineRecordById(FineId)
end)

exports("GetFineByArrest", function(ArrestId)

    return FineRecordByArrest(ArrestId)
end)

exports("RemoveFine", function(FineId)

    local Id = NormalizeAmount(FineId)
    return Id and DeleteFine(Id) or false
end)

exports("RemoveFineByArrest", function(ArrestId)

    local Id = NormalizeAmount(ArrestId)
    if not Id then return false end

    DeleteFinesByArrest(Id)
    return true
end)

exports("RemoveFines", function(Passport)

    local Target = NormalizeAmount(Passport)
    if not Target then return false end

    DeleteFinesOf(Target)
    return true
end)

exports("AddTaxes", function(Passport, Name, Valuation, Description)

    local Target = NormalizeAmount(Passport)
    return Target and AddTax(Target, Name, Valuation, Description) or false
end)

exports("AddTransactions", function(Passport, Type, Amount, Reference)

    local Target = NormalizeAmount(Passport)
    local Value = NormalizeAmount(Amount)
    if not Target or not Value then return false end

    local Account = EnsureAccount(Target)
    if not Account then return false end

    Record(0, parseInt(Account.id), LimitText(Type or "outros", 24), Value, Reference or Type, Reference)
    Snapshot(Account)

    return true
end)

--- Débito vencido bloqueia loja e garagem. Só avisa quando o jogador está on.
local function HasDebt(Passport, Overdue)
    local Target = NormalizeAmount(Passport)
    if not Target then return false end

    local Source = Framework.Source(Target)
    if not Source then return false end

    if not Overdue(Target) then return false end

    Framework.Notify(Source, "Você possui débitos bancários.", "amarelo")
    return true
end

exports("CheckFines", function(Passport)

    return HasDebt(Passport, function(Target)
        return HasOverdueFine(Target, Now() - (Bank.DebtGrace * 3600))
    end)
end)

exports("CheckTaxes", function(Passport)

    return HasDebt(Passport, function(Target)
        local Account = FindPersonalAccount(Target)
        if not Account then return false end

        return HasOverdueTax(parseInt(Account.id), Now() - (Bank.DebtGrace * 3600))
    end)
end)

exports("MigratePassport", function(OldPassport, NewPassport)

    local Old = NormalizeAmount(OldPassport)
    local New = NormalizeAmount(NewPassport)
    if not Old or not New or Old == New then return false end

    Framework.Execute("UPDATE `core_bank_accounts` SET `passport` = ? WHERE `passport` = ?", { New, Old })
    Framework.Execute("UPDATE `core_bank_members` SET `passport` = ? WHERE `passport` = ?", { New, Old })
    Framework.Execute("UPDATE `core_bank_invites` SET `passport` = ? WHERE `passport` = ?", { New, Old })
    Framework.Execute("UPDATE `core_bank_fines` SET `passport` = ? WHERE `passport` = ?", { New, Old })
    Framework.Execute("UPDATE `core_bank_fines` SET `officer` = ? WHERE `officer` = ?", { New, Old })

    return true
end)
