-----------------------------------------------------------------------------------------------------------------------------------------
-- CONTAS
-- A conta pessoal é um espelho do saldo bancário da vRP: ela existe para dar
-- um id ao jogador dentro do banco, mas quem guarda o dinheiro continua sendo
-- a base. Empresas guardam o próprio saldo na tabela do resource.
-----------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------
-- ENSUREACCOUNT
-- Garante a conta pessoal. É o primeiro passo de qualquer fluxo do banco.
-----------------------------------------------------------------------------------------------------------------------------------------
function EnsureAccount(Passport)
    local Account = FindPersonalAccount(Passport)
    if Account then return Account end

    local Name = Framework.FullName(Passport)
    local AccountId = InsertAccount(Passport, LimitText(Name, 32), 0, Now())
    if not AccountId then return false end

    return FindPersonalAccount(Passport)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NAMEOF
-- Nome de um passaporte. Cai no nome da conta pessoal quando a identidade não
-- existe mais, para listas não ficarem cheias de "Desconhecido".
-----------------------------------------------------------------------------------------------------------------------------------------
function NameOf(Passport)
    if Framework.Exists(Passport) then
        return Framework.FullName(Passport)
    end

    local Account = FindPersonalAccount(Passport)
    return Account and Account.name or "Desconhecido"
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BALANCEOF
-----------------------------------------------------------------------------------------------------------------------------------------
function BalanceOf(Account)
    if not Account then return 0 end

    if Truthy(Account.business) then
        return parseInt(Account.balance)
    end

    return Framework.GetBank(parseInt(Account.passport))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREDIT
-- Entrada de dinheiro na conta. Devolve false quando a base recusa.
-----------------------------------------------------------------------------------------------------------------------------------------
function Credit(Account, Amount)
    if Truthy(Account.business) then
        local Balance = parseInt(Account.balance) + Amount
        UpdateAccountBalance(parseInt(Account.id), Balance)
        Account.balance = Balance
        return true
    end

    return Framework.GiveBank(parseInt(Account.passport), Amount)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DEBIT
-- Saída de dinheiro. Relê o saldo imediatamente antes de escrever.
-----------------------------------------------------------------------------------------------------------------------------------------
function Debit(Account, Amount)
    if Truthy(Account.business) then
        local Current = FindAccount(parseInt(Account.id))
        if not Current or parseInt(Current.balance) < Amount then return false end

        local Balance = parseInt(Current.balance) - Amount
        UpdateAccountBalance(parseInt(Account.id), Balance)
        Account.balance = Balance
        return true
    end

    return Framework.TakeBank(parseInt(Account.passport), Amount)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ACCESSIBLEACCOUNT
-- Autorização de conta: dono, ou sócio quando é empresa. Toda operação passa
-- por aqui antes de mexer em dinheiro.
-----------------------------------------------------------------------------------------------------------------------------------------
function AccessibleAccount(Passport, AccountId)
    local Id = NormalizeAmount(AccountId)
    if not Id then return false end

    local Account = FindAccount(Id)
    if not Account then return false end

    if parseInt(Account.passport) == Passport then return Account end
    if Truthy(Account.business) and IsMember(Id, Passport) then return Account end

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDACCOUNTS
-- Lista que a interface usa para escolher a conta.
-----------------------------------------------------------------------------------------------------------------------------------------
function BuildAccounts(Passport)
    EnsureAccount(Passport)

    local Result = {}
    for _, Account in ipairs(FindAccountsOf(Passport)) do
        local Business = Truthy(Account.business)

        Result[#Result + 1] = {
            id       = parseInt(Account.id),
            name     = Account.name,
            business = Business,
            owner    = parseInt(Account.passport) == Passport,
            balance  = BalanceOf(Account),
            members  = Business and CountMembers(parseInt(Account.id)) or 0,
        }
    end

    return Result
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATEBUSINESS
-----------------------------------------------------------------------------------------------------------------------------------------
function CreateBusiness(Passport, Name)
    local Label = LimitText(Name, Bank.Accounts.NameLength.Max)
    if not Label or #Label < Bank.Accounts.NameLength.Min then
        return false, Bank.Language.NameInvalid:format(Bank.Accounts.NameLength.Min, Bank.Accounts.NameLength.Max)
    end

    if CountBusiness(Passport) >= Bank.Accounts.MaxBusiness then
        return false, Bank.Language.BusinessLimit:format(Bank.Accounts.MaxBusiness)
    end

    local Price = Bank.Accounts.BusinessPrice
    if Price > 0 and not Framework.TakeBank(Passport, Price) then
        return false, Bank.Language.NoFunds
    end

    local AccountId = InsertAccount(Passport, Label, 1, Now())
    if not AccountId then
        if Price > 0 then Framework.GiveBank(Passport, Price) end
        return false, Bank.Language.Failed
    end

    local Personal = EnsureAccount(Passport)
    if Price > 0 and Personal then
        Record(parseInt(Personal.id), 0, "business", Price, "Abertura da empresa " .. Label, Framework.FullName(Passport))
    end

    return true, Bank.Language.BusinessCreated:format(Label)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVITEMEMBER
-----------------------------------------------------------------------------------------------------------------------------------------
function InviteMember(Passport, AccountId, Target)
    local Account = FindAccount(NormalizeAmount(AccountId) or 0)
    if not Account or not Truthy(Account.business) then return false, Bank.Language.InvalidAccount end
    if parseInt(Account.passport) ~= Passport then return false, Bank.Language.NotOwner end

    local Invitee = NormalizeAmount(Target)
    if not Invitee or not Framework.Exists(Invitee) then return false, Bank.Language.TargetNotFound end
    if Invitee == Passport or IsMember(parseInt(Account.id), Invitee) then return false, Bank.Language.MemberExists end

    if CountMembers(parseInt(Account.id)) >= Bank.Accounts.MaxMembers then
        return false, Bank.Language.MemberLimit:format(Bank.Accounts.MaxMembers)
    end

    InsertInvite(parseInt(Account.id), Invitee, Now())

    local Source = Framework.Source(Invitee)
    if Source then
        Framework.Notify(Source, "Você foi convidado para " .. Account.name .. ".", "amarelo")
    end

    return true, Bank.Language.MemberInvited:format(Framework.FullName(Invitee))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ANSWERINVITE
-----------------------------------------------------------------------------------------------------------------------------------------
function AnswerInvite(Passport, AccountId, Accept)
    local Id = NormalizeAmount(AccountId)
    if not Id or not HasInvite(Id, Passport) then return false, Bank.Language.InviteMissing end

    DeleteInvite(Id, Passport)

    if not Accept then
        return true, Bank.Language.InviteRejected
    end

    local Account = FindAccount(Id)
    if not Account then return false, Bank.Language.InvalidAccount end

    if CountMembers(Id) >= Bank.Accounts.MaxMembers then
        return false, Bank.Language.MemberLimit:format(Bank.Accounts.MaxMembers)
    end

    InsertMember(Id, Passport, Now())

    return true, Bank.Language.InviteAccepted:format(Account.name)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVEMEMBER
-- O dono tira qualquer sócio; o sócio só sai dele mesmo.
-----------------------------------------------------------------------------------------------------------------------------------------
function RemoveMember(Passport, AccountId, Target)
    local Account = FindAccount(NormalizeAmount(AccountId) or 0)
    if not Account or not Truthy(Account.business) then return false, Bank.Language.InvalidAccount end

    local Member = NormalizeAmount(Target)
    if not Member then return false, Bank.Language.TargetNotFound end

    local IsOwner = parseInt(Account.passport) == Passport
    if not IsOwner and Member ~= Passport then return false, Bank.Language.NotOwner end

    DeleteMember(parseInt(Account.id), Member)

    return true, Bank.Language.MemberRemoved
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDINVITES
-----------------------------------------------------------------------------------------------------------------------------------------
function BuildInvites(Passport)
    local Result = {}

    for _, Invite in ipairs(FindInvites(Passport)) do
        Result[#Result + 1] = {
            account = parseInt(Invite.account_id),
            name    = Invite.name,
            owner   = NameOf(parseInt(Invite.owner)),
            date    = parseInt(Invite.created_at),
        }
    end

    return Result
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDMEMBERS
-----------------------------------------------------------------------------------------------------------------------------------------
function BuildMembers(Account)
    if not Truthy(Account.business) then return {} end

    local Result = {
        {
            passport = parseInt(Account.passport),
            name     = NameOf(parseInt(Account.passport)),
            owner    = true,
            date     = parseInt(Account.created_at),
        },
    }

    for _, Member in ipairs(FindMembers(parseInt(Account.id))) do
        Result[#Result + 1] = {
            passport = parseInt(Member.passport),
            name     = NameOf(parseInt(Member.passport)),
            owner    = false,
            date     = parseInt(Member.created_at),
        }
    end

    return Result
end
