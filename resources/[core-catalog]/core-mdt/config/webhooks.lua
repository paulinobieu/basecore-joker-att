-----------------------------------------------------------------------------------------------------------------------------------------
-- WEBHOOK
-----------------------------------------------------------------------------------------------------------------------------------------
-- Fallback de logs quando o "core_logs" NÃO está rodando.
-- Basta preencher a URL "default" que TODOS os logs saem por ela. Se quiser
-- separar por canal, preencha as específicas; quando uma específica está
-- vazia, o log cai automaticamente na "default".
Webhooks = {}

local WebhookURLs = {
    -- Painel administrativo (apps, patentes, código penal, cursos, licenças, cópia)
    admin      = "",

    -- Central de ocorrências (novos QRUs enviados via export addDispatch)
    dispatch   = "",

    -- Boletins de ocorrência (criação e edição)
    occurrence = "",

    -- Processamento do boletim (artigos aplicados, multas e penas geradas)
    process    = "",

    -- Gestão do efetivo (contratação, demissão e alteração de patente)
    officer    = "",

    -- Prisão (entrada, soltura e tentativa de fuga)
    prison     = "",

    -- Investigação (quadro criado, editado, status alterado e excluído)
    investigation = "",

    -- Fotos de cidadão e de oficial
    photo      = "",

    -- Canal padrão: recebe qualquer log cuja URL específica esteja vazia
    default    = "",
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local PerformHttpRequest = PerformHttpRequest
local json_encode        = json.encode
local os_date            = os.date
local tostring           = tostring
local tonumber           = tonumber
local type               = type
local concat             = table.concat
local str_format         = string.format
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

local function StaffField(data)
    return Named(data.adminName, data.adminId)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AÇÃO ADMINISTRATIVA
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.AdminAction(data)
    SendLog(WebhookURLs.admin, {
        "[PAINEL ADMINISTRATIVO]",
        Field("Staff", StaffField(data)),
        Field("Ação", data.description),
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CENTRAL DE OCORRÊNCIAS
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Dispatch(data)
    SendLog(WebhookURLs.dispatch, {
        "[NOVA OCORRÊNCIA]",
        Field("Código", data.code),
        Field("Título", data.title),
        Field("Local", data.location),
        Field("Prioridade", data.priority),
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BOLETIM
-----------------------------------------------------------------------------------------------------------------------------------------
local OccurrenceTitles = {
    criado  = "[BOLETIM CRIADO]",
    editado = "[BOLETIM EDITADO]",
}

function Webhooks.Occurrence(data)
    local lines = {
        OccurrenceTitles[data.action] or "[BOLETIM]",
        Field("Policial", Named(data.officer, data.officerId)),
        Field("Boletim", "#" .. tostring(data.id) .. " — " .. tostring(data.title)),
        Field("Corporação", data.corporation),
    }

    if data.requester and data.requester ~= "" then
        lines[#lines + 1] = Field("Requerente", data.requester)
    end

    if data.involved and data.involved ~= "" then
        lines[#lines + 1] = Field("Envolvidos", data.involved)
    end

    SendLog(WebhookURLs.occurrence, lines)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROCESSAMENTO DO BOLETIM
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Process(data)
    local lines = {
        "[BOLETIM PROCESSADO]",
        Field("Policial", Named(data.officer, data.officerId)),
        Field("Boletim", "#" .. tostring(data.id) .. " — " .. tostring(data.title)),
        Field("Corporação", data.corporation),
        Field("Envolvidos", data.involved),
    }

    if data.crimes and data.crimes ~= "" then
        lines[#lines + 1] = Field("Artigos", data.crimes)
    end

    lines[#lines + 1] = Field("Pena", tostring(data.prisonMonths or 0) .. " mês(es)")
    lines[#lines + 1] = Field("Multa", "$" .. tostring(data.fine or 0))

    if (tonumber(data.arrestReduction) or 0) > 0 or (tonumber(data.fineReduction) or 0) > 0 then
        lines[#lines + 1] = Field("Reduções", str_format("pena -%s%% · multa -%s%%",
            tostring(data.arrestReduction or 0), tostring(data.fineReduction or 0)))
    end

    if data.bailPaid then
        lines[#lines + 1] = Field("Fiança", "$" .. tostring(data.bailAmount or 0) .. " (paga)")
    end

    SendLog(WebhookURLs.process, lines)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EFETIVO
-----------------------------------------------------------------------------------------------------------------------------------------
local OfficerTitles = {
    contratacao      = "[CONTRATAÇÃO]",
    demissao         = "[DEMISSÃO]",
    patente          = "[ALTERAÇÃO DE PATENTE]",
    curso            = "[CURSO CONCEDIDO]",
    curso_removido   = "[CURSO REMOVIDO]",
    licenca          = "[LICENÇA CONCEDIDA]",
    licenca_removida = "[LICENÇA REMOVIDA]",
}

function Webhooks.Officer(data)
    local lines = {
        OfficerTitles[data.action] or "[EFETIVO]",
        Field("Policial", Named(data.officer, data.officerId)),
        Field("Alvo", Named(data.target, data.targetId)),
        Field("Corporação", data.corporation),
    }

    if data.rank and data.rank ~= "" then
        lines[#lines + 1] = Field("Patente", data.rank)
    end

    if data.item and data.item ~= "" then
        lines[#lines + 1] = Field("Item", data.item)
    end

    SendLog(WebhookURLs.officer, lines)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PRISÃO
-----------------------------------------------------------------------------------------------------------------------------------------
local PrisonTitles = {
    prisao  = "[PRISÃO]",
    soltura = "[SOLTURA]",
    fuga    = "[TENTATIVA DE FUGA]",
}

function Webhooks.Prison(data)
    local lines = {
        PrisonTitles[data.action] or "[PRISÃO]",
        Field("Preso", Named(data.name, data.passport)),
        Field("Pena", tostring(data.months or 0) .. " mês(es)"),
    }

    if data.reason and data.reason ~= "" then
        lines[#lines + 1] = Field("Motivo", data.reason)
    end

    if data.by and data.by ~= "" then
        lines[#lines + 1] = Field("Responsável", Named(data.by, data.byId))
    end

    SendLog(WebhookURLs.prison, lines)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVESTIGAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
local InvestigationTitles = {
    criada   = "[INVESTIGAÇÃO CRIADA]",
    editada  = "[INVESTIGAÇÃO EDITADA]",
    status   = "[INVESTIGAÇÃO — STATUS]",
    excluida = "[INVESTIGAÇÃO EXCLUÍDA]",
}

function Webhooks.Investigation(data)
    local lines = {
        InvestigationTitles[data.action] or "[INVESTIGAÇÃO]",
        Field("Investigação", "#" .. tostring(data.id) .. " — " .. tostring(data.title)),
        Field("Policial", Named(data.officer, data.officerId)),
        Field("Corporação", data.corporation),
    }

    if data.status and data.status ~= "" then
        lines[#lines + 1] = Field("Status", data.status)
    end

    if data.cards then
        lines[#lines + 1] = Field("Cards", tostring(data.cards) .. " · " .. tostring(data.connections or 0) .. " conexões")
    end

    SendLog(WebhookURLs.investigation, lines)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FOTOS
-----------------------------------------------------------------------------------------------------------------------------------------
local PhotoKindLabels = {
    citizen = "Cidadão",
    officer = "Oficial",
}

function Webhooks.Photo(data)
    local lines = {
        data.action == "removida" and "[FOTO REMOVIDA]" or "[FOTO DEFINIDA]",
        Field(PhotoKindLabels[data.kind] or "Alvo", Named(data.target, data.targetId)),
        Field("Policial", Named(data.officer, data.officerId)),
        Field("Corporação", data.corporation),
    }

    if data.url and data.url ~= "" then
        lines[#lines + 1] = Field("Imagem", data.url)
    end

    SendLog(WebhookURLs.photo, lines)
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
    MDT_ADMIN      = Webhooks.AdminAction,
    MDT_DISPATCH   = Webhooks.Dispatch,
    MDT_OCCURRENCE = Webhooks.Occurrence,
    MDT_PROCESS    = Webhooks.Process,
    MDT_OFFICER    = Webhooks.Officer,
    MDT_PRISON     = Webhooks.Prison,
    MDT_INVESTIGATION = Webhooks.Investigation,
    MDT_PHOTO      = Webhooks.Photo,
}

function Webhooks.Log(category, data)
    local fn = Dispatch[category]

    if fn and type(data) == "table" then
        fn(data)
        return
    end

    Webhooks.Generic(category, data)
end
