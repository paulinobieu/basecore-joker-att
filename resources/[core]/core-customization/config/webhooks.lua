-----------------------------------------------------------------------------------------------------------------------------------------
-- WEBHOOK
-----------------------------------------------------------------------------------------------------------------------------------------
-- Fallback de logs quando o "core_logs" NÃO está rodando. Preencha os links que
-- quiser (deixe "" pra desativar aquele tipo).
Webhooks = {}

local WebhookURLs = {
    -- Jogador
    clothes  = "",   -- roupas salvas na loja
    tattoos  = "",   -- tatuagens salvas na loja

    -- Administração
    preset   = "",   -- roupa de um jogador copiada em comandos

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
-- ROUPAS
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Clothes(data)
    SendLog(WebhookURLs.clothes, "```prolog\n"
        .."[ROUPAS SALVAS]\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TATUAGENS
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Tattoos(data)
    SendLog(WebhookURLs.tattoos, "```prolog\n"
        .."[TATUAGENS SALVAS]\n"
        .."[Jogador]: "..PlayerField(data).."\n"
        .."[Quantidade]: "..tostring(data.amount).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PRESET
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Preset(data)
    SendLog(WebhookURLs.preset, "```prolog\n"
        .."[ROUPA COPIADA]\n"
        .."[Administrador]: "..PlayerField(data).."\n"
        .."[Alvo]: "..tostring(data.targetId).."\n"
        ..DateField().."\n"
        .."```")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOG
-----------------------------------------------------------------------------------------------------------------------------------------
local Categories = {
    CUSTOMIZATION_CLOTHES = Webhooks.Clothes,
    CUSTOMIZATION_TATTOOS = Webhooks.Tattoos,
    CUSTOMIZATION_PRESET  = Webhooks.Preset,
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
