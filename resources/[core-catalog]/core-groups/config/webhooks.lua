-----------------------------------------------------------------------------------------------------------------------------------------
-- WEBHOOK
-----------------------------------------------------------------------------------------------------------------------------------------
-- Fallback de logs quando o "core_logs" NÃO está rodando.
-- Basta preencher a URL "default" que TODOS os logs saem por ela. Se quiser
-- separar por canal, preencha as específicas; quando uma específica está
-- vazia, o log cai automaticamente na "default".
Webhooks = {}

local WebhookURLs = {
    -- Painel administrativo (organizações criadas, editadas, excluídas e cargos)
    admin    = "",

    -- Gestão do efetivo (contratação, demissão e alteração de cargo)
    member   = "",

    -- Metas (entregas e conclusão da meta diária)
    goal     = "",

    -- Banco da organização (depósitos e saques)
    bank     = "",

    -- Configurações (QG, rádio, uniforme e aparência)
    settings = "",

    -- Canal padrão: recebe qualquer log cuja URL específica esteja vazia
    default  = "",
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local PerformHttpRequest = PerformHttpRequest
local json_encode        = json.encode
local os_date            = os.date
local tostring           = tostring
local type               = type
local concat             = table.concat
-----------------------------------------------------------------------------------------------------------------------------------------
-- HELPERS INTERNOS
-----------------------------------------------------------------------------------------------------------------------------------------
local JSON_HEADERS = { ["Content-Type"] = "application/json" }

local function NoOp() end

local function SendLog(webhook, lines)
    if not webhook or webhook == "" then
        webhook = WebhookURLs.default
    end

    if not webhook or webhook == "" then return end

    lines[#lines + 1] = os_date("[Data]: %d/%m/%Y [Hora]: %H:%M:%S")

    PerformHttpRequest(webhook, NoOp, "POST", json_encode({
        content = "```prolog\n" .. concat(lines, "\n") .. "\n```",
    }), JSON_HEADERS)
end

local function Field(label, value)
    return "[" .. label .. "]: " .. tostring(value)
end

local function Named(name, id)
    name = tostring(name or "—")

    if not id then return name end

    return name .. " #" .. tostring(id)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AÇÃO ADMINISTRATIVA
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.AdminAction(data)
    SendLog(WebhookURLs.admin, {
        "[PAINEL ADMINISTRATIVO]",
        Field("Staff", Named(data.adminName, data.adminId)),
        Field("Ação", data.description),
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EFETIVO
-----------------------------------------------------------------------------------------------------------------------------------------
local MemberActionLabels = {
    contratacao = "[CONTRATAÇÃO]",
    demissao    = "[DEMISSÃO]",
    cargo       = "[ALTERAÇÃO DE CARGO]",
}

function Webhooks.Member(data)
    local lines = {
        MemberActionLabels[data.action] or "[EFETIVO]",
        Field("Organização", data.group),
        Field("Responsável", Named(data.actor, data.actorId)),
        Field("Alvo", Named(data.target, data.targetId)),
    }

    if data.rank then
        lines[#lines + 1] = Field("Cargo", data.rank)
    end

    SendLog(WebhookURLs.member, lines)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- METAS
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Goal(data)
    SendLog(WebhookURLs.goal, {
        "[META DIÁRIA]",
        Field("Organização", data.group),
        Field("Membro", Named(data.member, data.memberId)),
        Field("Itens entregues", data.amount),
        Field("Pagamento", "R$ " .. tostring(data.payment or 0)),
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BANCO
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Bank(data)
    local lines = {
        data.action == "saque" and "[SAQUE]" or "[DEPÓSITO]",
        Field("Organização", data.group),
        Field("Membro", Named(data.member, data.memberId)),
        Field("Valor", "R$ " .. tostring(data.amount or 0)),
    }

    if data.note then
        lines[#lines + 1] = Field("Motivo", data.note)
    end

    SendLog(WebhookURLs.bank, lines)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGURAÇÕES
-----------------------------------------------------------------------------------------------------------------------------------------
local SettingsActionLabels = {
    hq       = "[LOCALIZAÇÃO DEFINIDA]",
    radio    = "[RÁDIO ALTERADA]",
    uniforme = "[UNIFORME ATUALIZADO]",
}

function Webhooks.Settings(data)
    local lines = {
        SettingsActionLabels[data.action] or "[CONFIGURAÇÃO]",
        Field("Organização", data.group),
        Field("Responsável", Named(data.member, data.memberId)),
    }

    if data.frequency then
        lines[#lines + 1] = Field("Frequência", tostring(data.frequency) .. " MHz")
    end

    if data.gender then
        lines[#lines + 1] = Field("Slot", data.gender == "female" and "Feminino" or "Masculino")
    end

    SendLog(WebhookURLs.settings, lines)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FALLBACK GENÉRICO
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Generic(category, data)
    SendLog(WebhookURLs.default, {
        Field("LOG", category),
        (type(data) == "table" and data.message) or "",
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ROTEAMENTO
-----------------------------------------------------------------------------------------------------------------------------------------
local Dispatch = {
    GROUPS_ADMIN    = Webhooks.AdminAction,
    GROUPS_MEMBER   = Webhooks.Member,
    GROUPS_GOAL     = Webhooks.Goal,
    GROUPS_BANK     = Webhooks.Bank,
    GROUPS_SETTINGS = Webhooks.Settings,
}

function Webhooks.Log(category, data)
    local fn = Dispatch[category]

    if fn and type(data) == "table" then
        fn(data)
        return
    end

    Webhooks.Generic(category, data)
end
