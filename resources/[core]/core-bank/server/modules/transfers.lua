-----------------------------------------------------------------------------------------------------------------------------------------
-- CAIXA E TRANSFERÊNCIAS
-- Todo fluxo aqui trava o passaporte antes de validar, revalida o saldo na
-- hora de escrever e devolve o dinheiro se a outra ponta recusar.
-----------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFYPASSPORT
-----------------------------------------------------------------------------------------------------------------------------------------
local function NotifyPassport(Passport, Message, Color)
    local Source = Framework.Source(Passport)
    if not Source then return end

    Framework.Notify(Source, Message, Color)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DEPOSIT
-- Tira dinheiro em mãos e credita a conta escolhida.
-----------------------------------------------------------------------------------------------------------------------------------------
function Deposit(Passport, AccountId, Value)
    local Amount = NormalizeAmount(Value)
    if not Amount or Amount < Bank.Limits.Deposit.Min or Amount > Bank.Limits.Deposit.Max then
        return false, Bank.Language.InvalidAmount
    end

    if not Acquire(Passport) then return false, Bank.Language.Busy end

    local Success, Message = false, Bank.Language.Failed

    local Ok, Error = pcall(function()
        local Account = AccessibleAccount(Passport, AccountId)
        if not Account then
            Message = Bank.Language.NoAccess
            return
        end

        if Framework.CashAmount(Passport) < Amount then
            Message = Bank.Language.NoCash
            return
        end

        if not Framework.TakeCash(Passport, Amount) then
            Message = Bank.Language.NoCash
            return
        end

        if not Credit(Account, Amount) then
            Framework.GiveCash(Passport, Amount)
            return
        end

        Record(0, parseInt(Account.id), "deposit", Amount, "Depósito em espécie", Framework.FullName(Passport))
        Snapshot(Account)

        Success = true
        Message = Bank.Language.Deposited:format(Amount)
    end)

    Release(Passport)

    if not Ok then
        print("^1[CORE-BANK]^7 " .. tostring(Error))
        return false, Bank.Language.Failed
    end

    return Success, Message
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- WITHDRAW
-- Debita a conta e devolve em espécie, respeitando o peso do inventário.
-----------------------------------------------------------------------------------------------------------------------------------------
function Withdraw(Passport, AccountId, Value)
    local Amount = NormalizeAmount(Value)
    if not Amount or Amount < Bank.Limits.Withdraw.Min or Amount > Bank.Limits.Withdraw.Max then
        return false, Bank.Language.InvalidAmount
    end

    if not Acquire(Passport) then return false, Bank.Language.Busy end

    local Success, Message = false, Bank.Language.Failed

    local Ok, Error = pcall(function()
        local Account = AccessibleAccount(Passport, AccountId)
        if not Account then
            Message = Bank.Language.NoAccess
            return
        end

        if not Framework.CashFits(Passport, Amount) then
            Message = Bank.Language.NoPocketSpace
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

        if not Framework.GiveCash(Passport, Amount) then
            Credit(Account, Amount)
            return
        end

        Record(parseInt(Account.id), 0, "withdraw", Amount, "Saque em espécie", Framework.FullName(Passport))
        Snapshot(Account)

        Success = true
        Message = Bank.Language.Withdrawn:format(Amount)
    end)

    Release(Passport)

    if not Ok then
        print("^1[CORE-BANK]^7 " .. tostring(Error))
        return false, Bank.Language.Failed
    end

    return Success, Message
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETTLE
-- Move dinheiro entre duas contas do banco. Quem chama já validou o acesso à
-- conta de origem.
-----------------------------------------------------------------------------------------------------------------------------------------
function Settle(Origin, Target, Type, Amount, Description, Author)
    if not Debit(Origin, Amount) then return false end

    if not Credit(Target, Amount) then
        Credit(Origin, Amount)
        return false
    end

    Record(parseInt(Origin.id), parseInt(Target.id), Type, Amount, Description, Author)
    Snapshot(Origin)
    Snapshot(Target)

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRANSFER
-- Resolve o destino por passaporte (aba Transferir) ou por chave PIX.
-----------------------------------------------------------------------------------------------------------------------------------------
function Transfer(Passport, AccountId, Destination, Value, Mode)
    local Amount = NormalizeAmount(Value)
    if not Amount or Amount < Bank.Limits.Transfer.Min or Amount > Bank.Limits.Transfer.Max then
        return false, Bank.Language.InvalidAmount
    end

    if not Acquire(Passport) then return false, Bank.Language.Busy end

    local Success, Message = false, Bank.Language.Failed

    local Ok, Error = pcall(function()
        local Origin = AccessibleAccount(Passport, AccountId)
        if not Origin then
            Message = Bank.Language.NoAccess
            return
        end

        local Target = false

        if Mode == "pix" then
            local Key = LimitText(Destination, Bank.Pix.KeyLength.Max)
            local Owner = Key and FindPixOwner(Key)
            Target = Owner and FindAccount(Owner) or false
        else
            local TargetPassport = NormalizeAmount(Destination)
            if TargetPassport and Framework.Exists(TargetPassport) then
                Target = EnsureAccount(TargetPassport)
            end
        end

        if not Target then
            Message = Bank.Language.TargetNotFound
            return
        end

        if parseInt(Target.id) == parseInt(Origin.id) then
            Message = Bank.Language.SameAccount
            return
        end

        if BalanceOf(Origin) < Amount then
            Message = Bank.Language.NoFunds
            return
        end

        local Author = Framework.FullName(Passport)

        if not Settle(Origin, Target, Mode == "pix" and "pix" or "transfer", Amount, "Para " .. Target.name, Author) then
            Message = Bank.Language.NoFunds
            return
        end

        NotifyPassport(parseInt(Target.passport), Bank.Language.Received:format(Amount, Origin.name), "verde")

        Success = true
        Message = Bank.Language.Transferred:format(Amount, Target.name)
    end)

    Release(Passport)

    if not Ok then
        print("^1[CORE-BANK]^7 " .. tostring(Error))
        return false, Bank.Language.Failed
    end

    return Success, Message
end
