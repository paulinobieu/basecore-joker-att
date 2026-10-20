-----------------------------------------------------------------------------------------------------------------------------------------
-- CHAVES PIX
-- A chave é escolhida pelo jogador e é única no servidor inteiro: a coluna é
-- primary key, então quem inserir primeiro fica com ela.
-----------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------
-- VALIDKEY
-- Letras, números, ponto e traço. Nada de espaço nem acento, para a chave ser
-- fácil de ditar e de digitar.
-----------------------------------------------------------------------------------------------------------------------------------------
local function ValidKey(Key)
    if type(Key) ~= "string" then return false end

    local Clean = Key:gsub("%s", "")
    if #Clean < Bank.Pix.KeyLength.Min or #Clean > Bank.Pix.KeyLength.Max then return false end
    if Clean:match("^[%w%.%-]+$") == nil then return false end

    return Clean:lower()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDPIXKEYS
-----------------------------------------------------------------------------------------------------------------------------------------
function BuildPixKeys(AccountId)
    local Result = {}

    for _, Row in ipairs(FindPixKeys(AccountId)) do
        Result[#Result + 1] = {
            key  = Row.key,
            date = parseInt(Row.created_at),
        }
    end

    return Result
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATEPIXKEY
-----------------------------------------------------------------------------------------------------------------------------------------
function CreatePixKey(Passport, AccountId, Value)
    local Key = ValidKey(Value)
    if not Key then
        return false, Bank.Language.PixKeyInvalid:format(Bank.Pix.KeyLength.Min, Bank.Pix.KeyLength.Max)
    end

    local Account = AccessibleAccount(Passport, AccountId)
    if not Account then return false, Bank.Language.NoAccess end

    if #FindPixKeys(parseInt(Account.id)) >= Bank.Pix.MaxKeys then
        return false, Bank.Language.PixKeyLimit:format(Bank.Pix.MaxKeys)
    end

    if not InsertPixKey(parseInt(Account.id), Key, Now()) then
        return false, Bank.Language.PixKeyTaken
    end

    return true, Bank.Language.PixKeyCreated:format(Key)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DestroyPixKey
-----------------------------------------------------------------------------------------------------------------------------------------
function DestroyPixKey(Passport, AccountId, Value)
    local Account = AccessibleAccount(Passport, AccountId)
    if not Account then return false, Bank.Language.NoAccess end

    local Key = ValidKey(Value)
    if not Key then return false, Bank.Language.Failed end

    DeletePixKey(parseInt(Account.id), Key)

    return true, Bank.Language.PixKeyRemoved
end
