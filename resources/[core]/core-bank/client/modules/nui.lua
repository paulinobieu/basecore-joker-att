-----------------------------------------------------------------------------------------------------------------------------------------
-- NUI
-- Ponte com a interface. Nada de regra aqui: leitura e operação vão direto
-- para o servidor, que é quem decide.
-----------------------------------------------------------------------------------------------------------------------------------------
NUIOpen = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOGGLEBANK
-----------------------------------------------------------------------------------------------------------------------------------------
function ToggleBank(State)
    NUIOpen = State

    if State then
        Framework.Open()
    else
        Framework.Close()
    end

    SendNUIMessage({ action = "setVisible", payload = State })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FECHAMENTO E TEMA
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("post:closeUi", function(_, cb)
    ToggleBank(false)
    cb(true)
end)

RegisterNUICallback("get:colors", function(_, cb)
    cb(Framework.ThemeColor())
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- LEITURAS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("get:bootstrap", function(_, cb)
    cb(vSERVER.Bootstrap())
end)

RegisterNUICallback("get:account", function(data, cb)
    cb(vSERVER.Account(data.account))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CAIXA E TRANSFERÊNCIAS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("post:deposit", function(data, cb)
    cb(vSERVER.Deposit(data.account, data.amount))
end)

RegisterNUICallback("post:withdraw", function(data, cb)
    cb(vSERVER.Withdraw(data.account, data.amount))
end)

RegisterNUICallback("post:transfer", function(data, cb)
    cb(vSERVER.Transfer(data.account, data.target, data.amount))
end)

RegisterNUICallback("post:pix", function(data, cb)
    cb(vSERVER.Pix(data.account, data.key, data.amount))
end)

RegisterNUICallback("post:pixKey", function(data, cb)
    cb(vSERVER.CreatePixKey(data.account, data.key))
end)

RegisterNUICallback("post:pixKeyRemove", function(data, cb)
    cb(vSERVER.RemovePixKey(data.account, data.key))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EMPRESAS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("post:business", function(data, cb)
    cb(vSERVER.CreateBusiness(data.name))
end)

RegisterNUICallback("post:invite", function(data, cb)
    cb(vSERVER.InviteMember(data.account, data.target))
end)

RegisterNUICallback("post:memberRemove", function(data, cb)
    cb(vSERVER.RemoveMember(data.account, data.target))
end)

RegisterNUICallback("post:inviteAnswer", function(data, cb)
    cb(vSERVER.AnswerInvite(data.account, data.accept))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FATURAS E MULTAS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("post:invoice", function(data, cb)
    cb(vSERVER.SendInvoice(data.account, data.target, data.amount, data.reason))
end)

RegisterNUICallback("post:invoicePay", function(data, cb)
    cb(vSERVER.PayInvoice(data.invoice))
end)

RegisterNUICallback("post:invoiceCancel", function(data, cb)
    cb(vSERVER.CancelInvoice(data.invoice))
end)

RegisterNUICallback("post:finePay", function(data, cb)
    cb(vSERVER.PayFine(data.account, data.fine))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVESTIMENTOS E CRIPTOMOEDAS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("post:invest", function(data, cb)
    cb(vSERVER.Invest(data.account, data.code, data.amount))
end)

RegisterNUICallback("post:redeem", function(data, cb)
    cb(vSERVER.Redeem(data.account, data.position))
end)

RegisterNUICallback("post:trade", function(data, cb)
    cb(vSERVER.Trade(data.account, data.asset, data.mode, data.amount))
end)
