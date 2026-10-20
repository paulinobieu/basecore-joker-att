-------------------------------------------------------------------------------------------------------------------------------------
-- WEBHOOK
-------------------------------------------------------------------------------------------------------------------------------------
-- Fallback de logs pra quem NÃO tem o resource "core_logs" instalado. Cada tipo de ação tem
-- seu próprio webhook e seu próprio formato de mensagem (logo abaixo). Preencha só os links
-- que quiser; deixe "" pra desativar aquele tipo. Isto só é usado quando o "core_logs" não
-- está rodando (com ele rodando, os logs vão pra lá normalmente).
Webhooks = {}

-- Um webhook do Discord por tipo de ação. Preencha os que quiser.
local WebhookURLs = {
	Wash     = "",   -- iniciar, cancelar e coletar lavagens
	Upgrade  = "",   -- upgrades de eficiência/potência
	Cleaners = "",   -- adição de limpadores
	Admin    = "",   -- criar/editar/remover máquina e salvar configurações

	-- Qualquer log que, por algum motivo, não se encaixe nos tipos acima
	Default  = "",
}
-------------------------------------------------------------------------------------------------------------------------------------
-- HELPERS INTERNOS
-------------------------------------------------------------------------------------------------------------------------------------
-- Envia uma mensagem de texto simples pro webhook do Discord. Não faz nada se o link estiver vazio.
local function SendLog(Webhook, Message)
	if not Webhook or Webhook == "" then return end

	PerformHttpRequest(Webhook, function() end, "POST", json.encode({
		content = Message,
	}), { ["Content-Type"] = "application/json" })
end

-- Data e hora atual, formatadas pro rodapé de todos os logs.
local function DateField()
	return os.date("[Data]: %d/%m/%Y [Hora]: %H:%M:%S")
end

-- "Nome #id" do jogador (ou admin) alvo da ação.
local function PlayerField(Data)
	local Name = Data.playerName or Data.adminName or "Desconhecido"
	local Id   = Data.playerId or Data.adminId
	return tostring(Name)..(Id and (" #"..Id) or "")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- LAVAGEM INICIADA
-------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.StartWash(Data)
	SendLog(WebhookURLs.Wash, "```prolog\n"
		.."[LAVAGEM INICIADA]\n"
		.."[Jogador]: "..PlayerField(Data).."\n"
		.."[Máquina]: "..tostring(Data.Maquina).."\n"
		.."[Valor Sujo]: R$ "..tostring(Data.Valor).."\n"
		.."[Valor Esperado]: R$ "..tostring(Data.Resultado).."\n"
		.."[Duração]: "..tostring(Data.Duracao).."\n"
		..DateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- LAVAGEM CANCELADA
-------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.CancelWash(Data)
	SendLog(WebhookURLs.Wash, "```prolog\n"
		.."[LAVAGEM CANCELADA]\n"
		.."[Jogador]: "..PlayerField(Data).."\n"
		.."[Máquina]: "..tostring(Data.Maquina).."\n"
		.."[Reembolso]: R$ "..tostring(Data.Reembolso).."\n"
		..DateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- DINHEIRO COLETADO
-------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.CollectWash(Data)
	SendLog(WebhookURLs.Wash, "```prolog\n"
		.."[DINHEIRO COLETADO]\n"
		.."[Jogador]: "..PlayerField(Data).."\n"
		.."[Máquina]: "..tostring(Data.Maquina).."\n"
		.."[Valor Coletado]: R$ "..tostring(Data.Valor).."\n"
		..DateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- UPGRADE
-------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Upgrade(Data)
	SendLog(WebhookURLs.Upgrade, "```prolog\n"
		.."[UPGRADE DE MÁQUINA]\n"
		.."[Jogador]: "..PlayerField(Data).."\n"
		.."[Máquina]: "..tostring(Data.Maquina).."\n"
		.."[Upgrade]: "..tostring(Data.Upgrade).."\n"
		.."[Nível]: "..tostring(Data.Nivel).."\n"
		.."[Custo]: R$ "..tostring(Data.Custo).."\n"
		..DateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- LIMPADORES
-------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Cleaners(Data)
	SendLog(WebhookURLs.Cleaners, "```prolog\n"
		.."[LIMPADORES ADICIONADOS]\n"
		.."[Jogador]: "..PlayerField(Data).."\n"
		.."[Máquina]: "..tostring(Data.Maquina).."\n"
		.."[Quantidade]: "..tostring(Data.Quantidade).."\n"
		..DateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- MÁQUINA (criar / editar / remover)
-------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Machine(Data)
	SendLog(WebhookURLs.Admin, "```prolog\n"
		.."[GERENCIAMENTO DE MÁQUINA]\n"
		.."[Admin]: "..PlayerField(Data).."\n"
		.."[Máquina]: "..tostring(Data.Maquina).."\n"
		..((Data.Permissao and ("[Permissão]: "..tostring(Data.Permissao).."\n")) or "")
		..((Data.CoordsMaquina and ("[Coords]: "..tostring(Data.CoordsMaquina).."\n")) or "")
		..((Data.message and ("[Ação]: "..tostring(Data.message).."\n")) or "")
		..DateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGURAÇÕES
-------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Config(Data)
	SendLog(WebhookURLs.Admin, "```prolog\n"
		.."[CONFIGURAÇÕES ATUALIZADAS]\n"
		.."[Admin]: "..PlayerField(Data).."\n"
		..DateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- FALLBACK GENÉRICO
-------------------------------------------------------------------------------------------------------------------------------------
-- Segurança: qualquer categoria de log que não tenha função própria cai aqui, usando o
-- resumo em texto (Data.message).
function Webhooks.Generic(Category, Data)
	SendLog(WebhookURLs.Default, "```prolog\n"
		.."[LOG]: "..tostring(Category).."\n"
		..(((Data and Data.message)) or "").."\n"
		..DateField().."\n"
		.."```")
end
-------------------------------------------------------------------------------------------------------------------------------------
-- ROTEAMENTO
-------------------------------------------------------------------------------------------------------------------------------------
-- Liga cada categoria de log (o 1º argumento do Functions.Log no server) à função certa.
local Dispatch = {
	["LAVAGEM-INICIOU"]    = Webhooks.StartWash,
	["LAVAGEM-CANCELOU"]   = Webhooks.CancelWash,
	["LAVAGEM-COLETOU"]    = Webhooks.CollectWash,
	["LAVAGEM-UPGRADE"]    = Webhooks.Upgrade,
	["LAVAGEM-LIMPADORES"] = Webhooks.Cleaners,
	["CRIOU-LAVAGEM"]      = Webhooks.Machine,
	["EDITOU-LAVAGEM"]     = Webhooks.Machine,
	["REMOVEU-LAVAGEM"]    = Webhooks.Machine,
	["LAVAGEM-CONFIG"]     = Webhooks.Config,
}

-- Ponto de entrada chamado pelo server-side/core.lua (via Functions.Log) quando o core_logs está off.
function Webhooks.Log(Category, Data)
	local Fn = Dispatch[Category]
	if Fn then
		Fn(Data)
		return
	end

	Webhooks.Generic(Category, Data)
end
