-----------------------------------------------------------------------------------------------------------------------------------------
-- WEBHOOK
-----------------------------------------------------------------------------------------------------------------------------------------
-- Fallback de logs quando o "core_logs" NÃO está rodando. Cada tipo de ação tem
-- seu próprio webhook e seu próprio formato de mensagem. Preencha só os links que
-- quiser (deixe "" pra desativar aquele tipo).
Webhooks = {}

local WebhookURLs = {
    -- Jogador
    purchase    = "",   -- compra de skin
    sell        = "",   -- venda de skin
    case        = "",   -- abertura de caixa / ganho de skin
    improvement = "",   -- aprimoramento
    trade       = "",   -- trocas (enviada/aceita/recusada)
    equip       = "",   -- equipar / desequipar
    weaponTest  = "",   -- teste de arma
    expired     = "",   -- skin temporária expirada

    -- Staff (admin)
    adminGiveSkin     = "",   -- staff deu uma skin a um jogador
    adminRemoveSkin   = "",   -- staff removeu uma skin de um jogador
    adminGiveAll      = "",   -- staff deu uma skin a todos os jogadores online
    adminGiveAllSkins = "",   -- staff entregou TODAS as skins a um jogador
    adminWipe         = "",   -- staff zerou as skins de um jogador
    adminCurrency     = "",   -- staff mexeu no saldo de moeda (SkinsCoins/Vouchers)

    -- Qualquer log que, por algum motivo, não se encaixe nos tipos acima
    default = "",
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
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMPRA DE SKIN
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Purchase(data)
    SendLog(WebhookURLs.purchase, "```prolog\n"
        .."[COMPRA DE SKIN]\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Skin]: "..tostring(data.skin).."\n"
        .."[Tipo]: "..(((tonumber(data.days) or 0) > 0) and (data.days.." dias") or "Permanente").."\n"
        .."[Preço]: "..tostring(data.price).." SkinsCoins\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VENDA DE SKIN
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Sell(data)
    SendLog(WebhookURLs.sell, "```prolog\n"
        .."[VENDA DE SKIN]\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Skin]: "..tostring(data.skin).."\n"
        .."[Valor]: "..tostring(data.value).." SkinsCoins\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GANHO EM CAIXA
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.CaseWin(data)
    SendLog(WebhookURLs.case, "```prolog\n"
        .."[GANHOU EM CAIXA]\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Caixa]: "..tostring(data.caseName).."\n"
        .."[Skin]: "..tostring(data.skin).." ("..tostring(data.rarity)..")\n"
        .."[Custo]: "..(((tonumber(data.price) or 0) > 0) and (data.price.." SkinsCoins") or "Grátis").."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- APRIMORAMENTO
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Improvement(data)
    SendLog(WebhookURLs.improvement, "```prolog\n"
        .."[APRIMORAMENTO]\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Resultado]: "..string.upper(tostring(data.result)).."\n"
        .."[Alvo]: "..tostring(data.target).."\n"
        .."[Chance]: "..tostring(data.chance).."%\n"
        .."[Investido]: "..tostring(data.inputSkins).." skin(s) + "..tostring(data.balance).." SkinsCoins\n"
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
        .."[Proposta]: "..tostring(data.tradeId).."\n"
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
        .."[Proposta]: "..tostring(data.tradeId).."\n"
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
        .."[Proposta]: "..tostring(data.tradeId).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EQUIPAR / DESEQUIPAR
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Equip(data)
    SendLog(WebhookURLs.equip, "```prolog\n"
        .."["..((data.action == "unequip") and "DESEQUIPOU" or "EQUIPOU").." SKIN]\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Skin]: "..tostring(data.skin).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TESTE DE ARMA
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.WeaponTest(data)
    SendLog(WebhookURLs.weaponTest, "```prolog\n"
        .."[TESTE DE ARMA]\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Skin]: "..tostring(data.skin).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SKIN EXPIRADA
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.SkinExpired(data)
    SendLog(WebhookURLs.expired, "```prolog\n"
        .."[SKIN EXPIRADA]\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Skin]: "..tostring(data.skin).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADMIN - DEU SKIN
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.AdminGiveSkin(data)
    SendLog(WebhookURLs.adminGiveSkin, "```prolog\n"
        .."[ADMIN - DEU SKIN]\n"
        .."[Staff]: "..StaffField(data).."\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Skin]: "..tostring(data.skin).."\n"
        .."[Quantidade]: "..tostring(data.quantidade).."\n"
        .."[Duração]: "..(((tonumber(data.dias) or 0) > 0) and (data.dias.." dias") or "Permanente").."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADMIN - REMOVEU SKIN
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.AdminRemoveSkin(data)
    SendLog(WebhookURLs.adminRemoveSkin, "```prolog\n"
        .."[ADMIN - REMOVEU SKIN]\n"
        .."[Staff]: "..StaffField(data).."\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Skin]: "..tostring(data.skin).."\n"
        .."[Quantidade]: "..tostring(data.quantidade).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADMIN - DEU SKIN A TODOS ONLINE
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.AdminGiveAll(data)
    SendLog(WebhookURLs.adminGiveAll, "```prolog\n"
        .."[ADMIN - DEU SKIN A TODOS]\n"
        .."[Staff]: "..StaffField(data).."\n"
        .."[Skin]: "..tostring(data.skin).."\n"
        .."[Quantidade]: "..tostring(data.quantidade).."\n"
        .."[Jogadores]: "..tostring(data.jogadores).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADMIN - DEU TODAS AS SKINS
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.AdminGiveAllSkins(data)
    SendLog(WebhookURLs.adminGiveAllSkins, "```prolog\n"
        .."[ADMIN - DEU TODAS AS SKINS]\n"
        .."[Staff]: "..StaffField(data).."\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Skins entregues]: "..tostring(data.quantidade).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADMIN - ZEROU SKINS
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.AdminWipe(data)
    SendLog(WebhookURLs.adminWipe, "```prolog\n"
        .."[ADMIN - ZEROU SKINS]\n"
        .."[Staff]: "..StaffField(data).."\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Skins removidas]: "..tostring(data.removidas).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADMIN - MOEDA
-----------------------------------------------------------------------------------------------------------------------------------------
-- Cobre tanto o painel de admin (SKINSADM_CURRENCY) quanto os comandos /addskin..,
-- /remskin.., /setskin.. — todos mexem no saldo de moeda do jogador.
function Webhooks.AdminCurrency(data)
    SendLog(WebhookURLs.adminCurrency, "```prolog\n"
        .."[ADMIN - MOEDA]\n"
        .."[Staff]: "..StaffField(data).."\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Moeda]: "..tostring(data.moeda).."\n"
        ..((data.operacao and ("[Operação]: "..tostring(data.operacao).."\n")) or "")
        .."[Quantidade]: "..tostring(data.quantidade).."\n"
        .."[Saldo novo]: "..tostring(data.saldoNovo or "-").."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FALLBACK GENÉRICO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Segurança: qualquer categoria de log que não tenha função própria cai aqui,
-- usando o resumo em texto (data.message).
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
-- Liga cada categoria de log (o 1º argumento do CoreLog no server) à função de
-- webhook certa. Se você criar uma nova categoria, adicione-a aqui.
local Dispatch = {
    -- Jogador
    SKIN_PURCHASE  = Webhooks.Purchase,
    SKIN_SELL      = Webhooks.Sell,
    CASE_WIN       = Webhooks.CaseWin,
    IMPROVEMENT    = Webhooks.Improvement,
    TRADE_SENT     = Webhooks.TradeSent,
    TRADE_ACCEPTED = Webhooks.TradeAccepted,
    TRADE_DECLINED = Webhooks.TradeDeclined,
    SKIN_EQUIP     = Webhooks.Equip,
    WEAPON_TEST    = Webhooks.WeaponTest,
    SKIN_EXPIRED   = Webhooks.SkinExpired,

    -- Staff (admin)
    SKINSADM_GIVESKIN     = Webhooks.AdminGiveSkin,
    SKINSADM_REMOVESKIN   = Webhooks.AdminRemoveSkin,
    SKINSADM_GIVEALL      = Webhooks.AdminGiveAll,
    SKINSADM_GIVEALLSKINS = Webhooks.AdminGiveAllSkins,
    GIVEALLSKINS          = Webhooks.AdminGiveAllSkins,
    SKINSADM_WIPE         = Webhooks.AdminWipe,
    SKINSADM_CURRENCY     = Webhooks.AdminCurrency,
}

-- Ponto de entrada chamado pelo server (via CoreLog) quando o core_logs está off.
function Webhooks.Log(category, data)
    local fn = Dispatch[category]
    if fn then
        fn(data)
        return
    end

    -- Comandos de moeda do staff têm categoria dinâmica (ADDSKIN.., REMSKIN.., SETSKIN..).
    category = tostring(category)
    if category:find("^ADDSKIN") or category:find("^REMSKIN") or category:find("^SETSKIN") then
        Webhooks.AdminCurrency(data)
        return
    end

    Webhooks.Generic(category, data)
end
