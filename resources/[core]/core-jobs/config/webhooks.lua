-------------------------------------------------------------------------------------------------------------------------------------
-- WEBHOOK
-------------------------------------------------------------------------------------------------------------------------------------
-- Fallback de logs pra quem NÃO tem o resource "core_logs" instalado. Cada tipo de ação tem
-- seu próprio webhook e seu próprio formato de mensagem (logo abaixo). Preencha só os links
-- que quiser; deixe "" pra desativar aquele tipo. Isto só é usado quando o "core_logs" não
-- está rodando (com ele rodando, os logs vão pra lá normalmente).
webhooks = {}

-- Um webhook do Discord por tipo de ação. Preencha os que quiser.
local webhookURLs = {
	reward    = "",   -- recompensa de coleta de emprego (minerador, pescador, etc.)
	bonus     = "",   -- bônus por horas trabalhadas resgatado
	anticheat = "",   -- detecção de trigger/injeção ilegítima de eventos

	-- Qualquer log que, por algum motivo, não se encaixe nos tipos acima
	default   = "",
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

-- "Nome #id" do jogador alvo da ação.
local function playerField(data)
	return tostring(data.playerName)..(data.playerId and (" #"..data.playerId) or "")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- RECOMPENSA DE EMPREGO
-------------------------------------------------------------------------------------------------------------------------------------
function webhooks.reward(data)
	sendLog(webhookURLs.reward, "```prolog\n"
		.."[RECOMPENSA DE EMPREGO]\n"
		.."[Jogador]: "..playerField(data).."\n"
		.."[Emprego]: "..tostring(data.Emprego).."\n"
		.."[Recompensas]: "..tostring(data.Recompensas).."\n"
		..((data.Dinheiro and ("[Dinheiro]: R$ "..tostring(data.Dinheiro).."\n")) or "")
		..dateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- BÔNUS DE HORAS TRABALHADAS
-------------------------------------------------------------------------------------------------------------------------------------
function webhooks.bonus(data)
	sendLog(webhookURLs.bonus, "```prolog\n"
		.."[BÔNUS DE HORAS TRABALHADAS]\n"
		.."[Jogador]: "..playerField(data).."\n"
		.."[Valor]: R$ "..tostring(data.Valor).."\n"
		..dateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- ANTI-CHEAT
-------------------------------------------------------------------------------------------------------------------------------------
function webhooks.anticheat(data)
	sendLog(webhookURLs.anticheat, "```prolog\n"
		.."[ANTI-CHEAT - EMPREGO]\n"
		.."[Jogador]: "..playerField(data).."\n"
		.."[Motivo]: "..tostring(data.Motivo).."\n"
		.."[Violações]: "..tostring(data.Violacoes).."\n"
		..dateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- FALLBACK GENÉRICO
-------------------------------------------------------------------------------------------------------------------------------------
-- Segurança: qualquer categoria de log que não tenha função própria cai aqui, usando o
-- resumo em texto (data.message).
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
-- Liga cada categoria de log (o 1º argumento do Functions.log no server) à função certa.
local dispatch = {
	["EMPREGO-BONUS"]     = webhooks.bonus,
	["ANTICHEAT-EMPREGO"] = webhooks.anticheat,
}

-- Ponto de entrada chamado pelo server-side/core.lua (via Functions.log) quando o core_logs está off.
function webhooks.log(category, data)
	local fn = dispatch[category]
	if fn then
		fn(data)
		return
	end

	-- As recompensas de coleta têm categoria dinâmica (EMPREGO-MINERADOR, EMPREGO-PESCADOR, etc.).
	if tostring(category):find("^EMPREGO%-") then
		webhooks.reward(data)
		return
	end

	webhooks.generic(category, data)
end
