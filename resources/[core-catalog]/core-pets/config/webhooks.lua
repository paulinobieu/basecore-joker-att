-----------------------------------------------------------------------------------------------------------------------------------------
-- WEBHOOK
-----------------------------------------------------------------------------------------------------------------------------------------
-- Fallback de logs quando o "core_logs" NÃO está rodando. Preencha os links que
-- quiser (deixe "" pra desativar aquele tipo).
Webhooks = {}

local WebhookURLs = {
    -- Jogador
    purchase = "",   -- compra de pelúcia na loja (Diamantes)
    deposit  = "",   -- depósito de pelúcia no painel
    withdraw = "",   -- saque de pelúcia do painel
    featured = "",   -- alteração de destaque
    trade    = "",   -- trocas (enviada/aceita/recusada)

    -- Staff (admin)
    adminGive    = "",   -- staff entregou uma pelúcia (coleção)
    adminRemove  = "",   -- staff removeu uma pelúcia da coleção
    adminGiveAll = "",   -- staff entregou a coleção completa
    adminGiveInv = "",   -- staff entregou item de pelúcia no inventário
    adminCoins   = "",   -- staff deu/removeu PetCoins

    -- Qualquer log que, por algum motivo, não se encaixe nos tipos acima
    default  = "",
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- HELPERS INTERNOS
-----------------------------------------------------------------------------------------------------------------------------------------
local function SendLog(webhook, message)
    if not webhook or webhook == "" then return end

    PerformHttpRequest(webhook, function() end, "POST", json.encode({
        content = message,
    }), { ["Content-Type"] = "application/json" })
end

local function DateField()
    return os.date("[Data]: %d/%m/%Y [Hora]: %H:%M:%S")
end

local function StaffField(data)
    return tostring(data.adminName)..(data.adminId and (" #"..data.adminId) or "")
end

local function PlayerField(data)
    return tostring(data.playerName)..(data.playerId and (" #"..data.playerId) or "")
end

local function ItemsField(items)
    if type(items) ~= "table" or #items == 0 then return "—" end
    return table.concat(items, ", ")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMPRA (LOJA)
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Purchase(data)
    SendLog(WebhookURLs.purchase, "```prolog\n"
        .."[COMPRA DE PELÚCIA]\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Pelúcia]: "..tostring(data.item).."\n"
        .."[Preço]: "..tostring(data.price).." Diamantes\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DEPÓSITO
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Deposit(data)
    SendLog(WebhookURLs.deposit, "```prolog\n"
        .."[DEPÓSITO NO PAINEL]\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Pelúcia]: "..tostring(data.item).."\n"
        .."[Qtd]: "..tostring(data.qty).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SAQUE
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Withdraw(data)
    SendLog(WebhookURLs.withdraw, "```prolog\n"
        .."[SAQUE DO PAINEL]\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Pelúcia]: "..tostring(data.item).."\n"
        .."[Qtd]: "..tostring(data.qty).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DESTAQUE
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Featured(data)
    SendLog(WebhookURLs.featured, "```prolog\n"
        .."[DESTAQUE ALTERADO]\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Pelúcia]: "..tostring(data.item).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TROCA - ENVIADA
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.TradeSent(data)
    SendLog(WebhookURLs.trade, "```prolog\n"
        .."[TROCA ENVIADA]\n"
        .."[De]: "..tostring(data.fromName).." #"..tostring(data.fromId).."\n"
        .."[Para]: "..tostring(data.toName).." #"..tostring(data.toId).."\n"
        .."[Oferecendo]: "..ItemsField(data.offer).."\n"
        .."[Pedindo]: "..ItemsField(data.request).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TROCA - ACEITA
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.TradeAccepted(data)
    SendLog(WebhookURLs.trade, "```prolog\n"
        .."[TROCA ACEITA]\n"
        .."[De]: "..tostring(data.fromName).." #"..tostring(data.fromId).."\n"
        .."[Para]: "..tostring(data.toName).." #"..tostring(data.toId).."\n"
        .."[Recebido]: "..ItemsField(data.offer).."\n"
        .."[Cedido]: "..ItemsField(data.request).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TROCA - RECUSADA
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.TradeDeclined(data)
    SendLog(WebhookURLs.trade, "```prolog\n"
        .."[TROCA RECUSADA]\n"
        .."[De]: "..tostring(data.fromName).." #"..tostring(data.fromId).."\n"
        .."[Para]: "..tostring(data.toName).." #"..tostring(data.toId).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADMIN - ENTREGOU PELÚCIA
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.AdminGive(data)
    SendLog(WebhookURLs.adminGive, "```prolog\n"
        .."[ADMIN - ENTREGOU PELÚCIA]\n"
        .."[Staff]: "..StaffField(data).."\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Pelúcia]: "..tostring(data.pet).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADMIN - REMOVEU PELÚCIA
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.AdminRemove(data)
    SendLog(WebhookURLs.adminRemove, "```prolog\n"
        .."[ADMIN - REMOVEU PELÚCIA]\n"
        .."[Staff]: "..StaffField(data).."\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Pelúcia]: "..tostring(data.pet).."\n"
        .."[Qtd]: "..tostring(data.qty).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADMIN - ENTREGOU COLEÇÃO COMPLETA
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.AdminGiveAll(data)
    SendLog(WebhookURLs.adminGiveAll, "```prolog\n"
        .."[ADMIN - ENTREGOU COLEÇÃO COMPLETA]\n"
        .."[Staff]: "..StaffField(data).."\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Pelúcias entregues]: "..tostring(data.count).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADMIN - ENTREGOU ITEM NO INVENTÁRIO
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.AdminGiveInv(data)
    SendLog(WebhookURLs.adminGiveInv, "```prolog\n"
        .."[ADMIN - ENTREGOU ITEM NO INVENTÁRIO]\n"
        .."[Staff]: "..StaffField(data).."\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Item]: "..tostring(data.item).."\n"
        .."[Qtd]: "..tostring(data.qty).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADMIN - PETCOINS
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.AdminCoins(data)
    SendLog(WebhookURLs.adminCoins, "```prolog\n"
        .."[ADMIN - PETCOINS]\n"
        .."[Staff]: "..StaffField(data).."\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Operação]: "..(data.op == "remove" and "REMOVEU" or "DEU").."\n"
        .."[Quantidade]: "..tostring(data.amount).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FALLBACK GENÉRICO
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Generic(category, data)
    SendLog(WebhookURLs.default, "```prolog\n"
        .."[LOG]: "..tostring(category).."\n"
        ..(((data and data.message)) or "").."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROTEAMENTO
-----------------------------------------------------------------------------------------------------------------------------------------
local Dispatch = {
    -- Jogador
    PET_PURCHASE   = Webhooks.Purchase,
    PET_DEPOSIT    = Webhooks.Deposit,
    PET_WITHDRAW   = Webhooks.Withdraw,
    PET_FEATURED   = Webhooks.Featured,
    TRADE_SENT     = Webhooks.TradeSent,
    TRADE_ACCEPTED = Webhooks.TradeAccepted,
    TRADE_DECLINED = Webhooks.TradeDeclined,

    -- Staff (admin)
    ADMIN_GIVE     = Webhooks.AdminGive,
    ADMIN_REMOVE   = Webhooks.AdminRemove,
    ADMIN_GIVEALL  = Webhooks.AdminGiveAll,
    ADMIN_GIVEINV  = Webhooks.AdminGiveInv,
    ADMIN_COINS    = Webhooks.AdminCoins,
}

function Webhooks.Log(category, data)
    local fn = Dispatch[category]
    if fn then
        fn(data)
        return
    end

    Webhooks.Generic(category, data)
end
