-----------------------------------------------------------------------------------------------------------------------------------------
-- WEBHOOK
-----------------------------------------------------------------------------------------------------------------------------------------
-- Fallback de logs quando o "core_logs" NÃO está rodando. Preencha os links que
-- quiser (deixe "" pra desativar aquele tipo).
Webhooks = {}

local WebhookURLs = {
    -- Jogador
    create   = "",   -- personagem criado
    select   = "",   -- personagem escolhido na seleção
    barber   = "",   -- alterações salvas na barbearia
    slot     = "",   -- compra de slot de personagem

    -- Administração
    model    = "",   -- modelo do ped trocado por comando
    reset    = "",   -- personagem devolvido ao criador por comando

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

local function PlayerField(data)
    return tostring(data.playerName)..(data.playerId and (" #"..data.playerId) or "")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CRIAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Create(data)
    SendLog(WebhookURLs.create, "```prolog\n"
        .."[PERSONAGEM CRIADO]\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Nome]: "..tostring(data.name).."\n"
        .."[Sexo]: "..tostring(data.gender).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SELEÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Select(data)
    SendLog(WebhookURLs.select, "```prolog\n"
        .."[PERSONAGEM ESCOLHIDO]\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BARBEARIA
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Barber(data)
    SendLog(WebhookURLs.barber, "```prolog\n"
        .."[BARBEARIA]\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SLOT
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Slot(data)
    SendLog(WebhookURLs.slot, "```prolog\n"
        .."[SLOT COMPRADO]\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Preço]: "..tostring(data.price).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MODELO
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Model(data)
    SendLog(WebhookURLs.model, "```prolog\n"
        .."[MODELO TROCADO]\n"
        .."[Administrador]: "..PlayerField(data).."\n"
        .."[Alvo]: "..tostring(data.targetId).."\n"
        .."[Modelo]: "..tostring(data.model).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESET
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Reset(data)
    SendLog(WebhookURLs.reset, "```prolog\n"
        .."[PERSONAGEM DEVOLVIDO AO CRIADOR]\n"
        .."[Administrador]: "..PlayerField(data).."\n"
        .."[Alvo]: "..tostring(data.targetId).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOG
-----------------------------------------------------------------------------------------------------------------------------------------
local Categories = {
    CHARACTER_CREATE = Webhooks.Create,
    CHARACTER_SELECT = Webhooks.Select,
    CHARACTER_BARBER = Webhooks.Barber,
    CHARACTER_SLOT   = Webhooks.Slot,
    CHARACTER_MODEL  = Webhooks.Model,
    CHARACTER_RESET  = Webhooks.Reset,
}

function Webhooks.Log(category, data)
    local handler = Categories[category]
    if handler then return handler(data or {}) end

    SendLog(WebhookURLs.default, "```prolog\n"
        .."["..tostring(category).."]\n"
        ..json.encode(data or {}).."\n"
        ..DateField().."\n"
        .."```")
end
