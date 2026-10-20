-------------------------------------------------------------------------------------------------------------------------------------
-- WEBHOOK
-------------------------------------------------------------------------------------------------------------------------------------
-- Fallback de logs pra quem NÃO tem o resource "core_logs" instalado. Cada tipo de ação tem
-- seu próprio webhook e seu próprio formato de mensagem (logo abaixo). Preencha só os links
-- que quiser; deixe "" pra desativar aquele tipo. Isto só é usado quando o "core_logs" não
-- está rodando (com ele rodando, os logs vão pra lá normalmente).
webhooks = {}

-- Um webhook do Discord por tipo de ação. As trocas e o equipar/desequipar compartilham um
-- link cada. As ações de staff estão separadas uma a uma na parte de baixo.
local webhookURLs = {
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
	default     = "",
}
-------------------------------------------------------------------------------------------------------------------------------------
-- HELPERS INTERNOS
-------------------------------------------------------------------------------------------------------------------------------------
-- Envia uma mensagem de texto simples pro webhook do Discord. Não faz nada se o link estiver vazio.
local function sendLog(webhook, message)
	if not webhook or webhook == "" then return end

	PerformHttpRequest(webhook, function() end, "POST", json.encode({
		content = message,
	}), { ["Content-Type"] = "application/json" })
end

-- Data e hora atual, formatadas pro rodapé de todos os logs.
local function dateField()
	return os.date("[Data]: %d/%m/%Y [Hora]: %H:%M:%S")
end

-- "Nome #id" do staff que fez a ação (o console não tem id).
local function staffField(data)
	return tostring(data.adminName)..(data.adminId and (" #"..data.adminId) or "")
end

-- "Nome #id" do jogador alvo da ação.
local function playerField(data)
	return tostring(data.playerName)..(data.playerId and (" #"..data.playerId) or "")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- COMPRA DE SKIN
-------------------------------------------------------------------------------------------------------------------------------------
function webhooks.purchase(data)
	sendLog(webhookURLs.purchase, "```prolog\n"
		.."[COMPRA DE SKIN]\n"
		.."[Jogador]: "..tostring(data.playerName).." #"..tostring(data.playerId).."\n"
		.."[Skin]: "..tostring(data.skin).."\n"
		.."[Tipo]: "..(((tonumber(data.days) or 0) > 0) and (data.days.." dias") or "Permanente").."\n"
		.."[Preço]: "..tostring(data.price).." SkinsCoins\n"
		..dateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- VENDA DE SKIN
-------------------------------------------------------------------------------------------------------------------------------------
function webhooks.sell(data)
	sendLog(webhookURLs.sell, "```prolog\n"
		.."[VENDA DE SKIN]\n"
		.."[Jogador]: "..tostring(data.playerName).." #"..tostring(data.playerId).."\n"
		.."[Skin]: "..tostring(data.skin).."\n"
		.."[Valor]: "..tostring(data.value).." SkinsCoins\n"
		..dateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- GANHO EM CAIXA
-------------------------------------------------------------------------------------------------------------------------------------
function webhooks.caseWin(data)
	sendLog(webhookURLs.case, "```prolog\n"
		.."[GANHOU EM CAIXA]\n"
		.."[Jogador]: "..tostring(data.playerName).." #"..tostring(data.playerId).."\n"
		.."[Caixa]: "..tostring(data.caseName).."\n"
		.."[Skin]: "..tostring(data.skin).." ("..tostring(data.rarity)..")\n"
		.."[Custo]: "..(((tonumber(data.price) or 0) > 0) and (data.price.." SkinsCoins") or "Grátis").."\n"
		..dateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- APRIMORAMENTO
-------------------------------------------------------------------------------------------------------------------------------------
function webhooks.improvement(data)
	sendLog(webhookURLs.improvement, "```prolog\n"
		.."[APRIMORAMENTO]\n"
		.."[Jogador]: "..tostring(data.playerName).." #"..tostring(data.playerId).."\n"
		.."[Resultado]: "..string.upper(tostring(data.result)).."\n"
		.."[Alvo]: "..tostring(data.target).."\n"
		.."[Chance]: "..tostring(data.chance).."%\n"
		.."[Investido]: "..tostring(data.inputSkins).." skin(s) + "..tostring(data.balance).." SkinsCoins\n"
		..dateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- TROCA - ENVIADA
-------------------------------------------------------------------------------------------------------------------------------------
function webhooks.tradeSent(data)
	sendLog(webhookURLs.trade, "```prolog\n"
		.."[TROCA ENVIADA]\n"
		.."[De]: "..tostring(data.fromName).." #"..tostring(data.fromId).."\n"
		.."[Para]: "..tostring(data.toName).." #"..tostring(data.toId).."\n"
		.."[Proposta]: "..tostring(data.tradeId).."\n"
		..dateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- TROCA - ACEITA
-------------------------------------------------------------------------------------------------------------------------------------
function webhooks.tradeAccepted(data)
	sendLog(webhookURLs.trade, "```prolog\n"
		.."[TROCA ACEITA]\n"
		.."[De]: "..tostring(data.fromName).." #"..tostring(data.fromId).."\n"
		.."[Para]: "..tostring(data.toName).." #"..tostring(data.toId).."\n"
		.."[Proposta]: "..tostring(data.tradeId).."\n"
		..dateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- TROCA - RECUSADA
-------------------------------------------------------------------------------------------------------------------------------------
function webhooks.tradeDeclined(data)
	sendLog(webhookURLs.trade, "```prolog\n"
		.."[TROCA RECUSADA]\n"
		.."[De]: "..tostring(data.fromName).." #"..tostring(data.fromId).."\n"
		.."[Para]: "..tostring(data.toName).." #"..tostring(data.toId).."\n"
		.."[Proposta]: "..tostring(data.tradeId).."\n"
		..dateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- EQUIPAR / DESEQUIPAR
-------------------------------------------------------------------------------------------------------------------------------------
function webhooks.equip(data)
	sendLog(webhookURLs.equip, "```prolog\n"
		.."["..((data.action == "unequip") and "DESEQUIPOU" or "EQUIPOU").." SKIN]\n"
		.."[Jogador]: "..tostring(data.playerName).." #"..tostring(data.playerId).."\n"
		.."[Skin]: "..tostring(data.skin).."\n"
		..dateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- TESTE DE ARMA
-------------------------------------------------------------------------------------------------------------------------------------
function webhooks.weaponTest(data)
	sendLog(webhookURLs.weaponTest, "```prolog\n"
		.."[TESTE DE ARMA]\n"
		.."[Jogador]: "..tostring(data.playerName).." #"..tostring(data.playerId).."\n"
		.."[Skin]: "..tostring(data.skin).."\n"
		..dateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- SKIN EXPIRADA
-------------------------------------------------------------------------------------------------------------------------------------
function webhooks.skinExpired(data)
	sendLog(webhookURLs.expired, "```prolog\n"
		.."[SKIN EXPIRADA]\n"
		.."[Jogador]: "..tostring(data.playerName).." #"..tostring(data.playerId).."\n"
		.."[Skin]: "..tostring(data.skin).."\n"
		..dateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- ADMIN - DEU SKIN
-------------------------------------------------------------------------------------------------------------------------------------
function webhooks.adminGiveSkin(data)
	sendLog(webhookURLs.adminGiveSkin, "```prolog\n"
		.."[ADMIN - DEU SKIN]\n"
		.."[Staff]: "..staffField(data).."\n"
		.."[Jogador]: "..playerField(data).."\n"
		.."[Skin]: "..tostring(data.skin).."\n"
		.."[Quantidade]: "..tostring(data.quantidade).."\n"
		.."[Duração]: "..(((tonumber(data.dias) or 0) > 0) and (data.dias.." dias") or "Permanente").."\n"
		..dateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- ADMIN - REMOVEU SKIN
-------------------------------------------------------------------------------------------------------------------------------------
function webhooks.adminRemoveSkin(data)
	sendLog(webhookURLs.adminRemoveSkin, "```prolog\n"
		.."[ADMIN - REMOVEU SKIN]\n"
		.."[Staff]: "..staffField(data).."\n"
		.."[Jogador]: "..playerField(data).."\n"
		.."[Skin]: "..tostring(data.skin).."\n"
		.."[Quantidade]: "..tostring(data.quantidade).."\n"
		..dateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- ADMIN - DEU SKIN A TODOS ONLINE
-------------------------------------------------------------------------------------------------------------------------------------
function webhooks.adminGiveAll(data)
	sendLog(webhookURLs.adminGiveAll, "```prolog\n"
		.."[ADMIN - DEU SKIN A TODOS]\n"
		.."[Staff]: "..staffField(data).."\n"
		.."[Skin]: "..tostring(data.skin).."\n"
		.."[Quantidade]: "..tostring(data.quantidade).."\n"
		.."[Jogadores]: "..tostring(data.jogadores).."\n"
		..dateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- ADMIN - DEU TODAS AS SKINS
-------------------------------------------------------------------------------------------------------------------------------------
function webhooks.adminGiveAllSkins(data)
	sendLog(webhookURLs.adminGiveAllSkins, "```prolog\n"
		.."[ADMIN - DEU TODAS AS SKINS]\n"
		.."[Staff]: "..staffField(data).."\n"
		.."[Jogador]: "..playerField(data).."\n"
		.."[Skins entregues]: "..tostring(data.quantidade).."\n"
		..dateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- ADMIN - ZEROU SKINS
-------------------------------------------------------------------------------------------------------------------------------------
function webhooks.adminWipe(data)
	sendLog(webhookURLs.adminWipe, "```prolog\n"
		.."[ADMIN - ZEROU SKINS]\n"
		.."[Staff]: "..staffField(data).."\n"
		.."[Jogador]: "..playerField(data).."\n"
		.."[Skins removidas]: "..tostring(data.removidas).."\n"
		..dateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- ADMIN - MOEDA
-------------------------------------------------------------------------------------------------------------------------------------
-- Cobre tanto o painel de admin (SKINSADM_CURRENCY) quanto os comandos /addskin.., /remskin..,
-- /setskin.. — todos mexem no saldo de moeda do jogador.
function webhooks.adminCurrency(data)
	sendLog(webhookURLs.adminCurrency, "```prolog\n"
		.."[ADMIN - MOEDA]\n"
		.."[Staff]: "..staffField(data).."\n"
		.."[Jogador]: "..playerField(data).."\n"
		.."[Moeda]: "..tostring(data.moeda).."\n"
		..((data.operacao and ("[Operação]: "..tostring(data.operacao).."\n")) or "")
		.."[Quantidade]: "..tostring(data.quantidade).."\n"
		.."[Saldo novo]: "..tostring(data.saldoNovo or "-").."\n"
		..dateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- FALLBACK GENÉRICO
-------------------------------------------------------------------------------------------------------------------------------------
-- Segurança: qualquer categoria de log que não tenha função própria cai aqui, usando o
-- resumo em texto (data.message). No fluxo normal do core-skins isto não é usado.
function webhooks.generic(category, data)
	sendLog(webhookURLs.default, "```prolog\n"
		.."[LOG]: "..tostring(category).."\n"
		..(((data and data.message)) or "").."\n"
		..dateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- ROTEAMENTO
-------------------------------------------------------------------------------------------------------------------------------------
-- Liga cada categoria de log (o 1º argumento do coreLog no server) à função de webhook certa.
-- Se você criar uma nova categoria, adicione-a aqui apontando pra função dela acima.
local dispatch = {
	-- Jogador
	SKIN_PURCHASE  = webhooks.purchase,
	SKIN_SELL      = webhooks.sell,
	CASE_WIN       = webhooks.caseWin,
	IMPROVEMENT    = webhooks.improvement,
	TRADE_SENT     = webhooks.tradeSent,
	TRADE_ACCEPTED = webhooks.tradeAccepted,
	TRADE_DECLINED = webhooks.tradeDeclined,
	SKIN_EQUIP     = webhooks.equip,
	WEAPON_TEST    = webhooks.weaponTest,
	SKIN_EXPIRED   = webhooks.skinExpired,

	-- Staff (admin)
	SKINSADM_GIVESKIN     = webhooks.adminGiveSkin,
	SKINSADM_REMOVESKIN   = webhooks.adminRemoveSkin,
	SKINSADM_GIVEALL      = webhooks.adminGiveAll,
	SKINSADM_GIVEALLSKINS = webhooks.adminGiveAllSkins,
	GIVEALLSKINS          = webhooks.adminGiveAllSkins,
	SKINSADM_WIPE         = webhooks.adminWipe,
	SKINSADM_CURRENCY     = webhooks.adminCurrency,
}

-- Ponto de entrada chamado pelo server/core.lua (via coreLog) quando o core_logs está off.
function webhooks.log(category, data)
	local fn = dispatch[category]
	if fn then
		fn(data)
		return
	end

	-- Comandos de moeda do staff têm categoria dinâmica (ADDSKIN.., REMSKIN.., SETSKIN..).
	category = tostring(category)
	if category:find("^ADDSKIN") or category:find("^REMSKIN") or category:find("^SETSKIN") then
		webhooks.adminCurrency(data)
		return
	end

	webhooks.generic(category, data)
end
