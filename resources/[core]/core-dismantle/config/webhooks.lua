Webhooks = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGURAÇÃO
-- Insira a URL do webhook do Discord para receber logs.
-- Deixe vazio ("") para desabilitar.
-----------------------------------------------------------------------------------------------------------------------------------------

Webhooks.DismantleCompleted = ""
Webhooks.PanelAction        = ""

-----------------------------------------------------------------------------------------------------------------------------------------
-- HELPER INTERNO
-----------------------------------------------------------------------------------------------------------------------------------------

local function playerField(userId)
    return Functions.getUserName(userId) .. " **#" .. tostring(userId) .. "**"
end

local function sendWebhook(webhookUrl, embed)
    if not webhookUrl or webhookUrl == "" then return end

    PerformHttpRequest(webhookUrl, function() end, "POST", json.encode({
        embeds = { embed },
    }), { ["Content-Type"] = "application/json" })
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTOS
-----------------------------------------------------------------------------------------------------------------------------------------

function Webhooks.onDismantleCompleted(userId, dismantleId, vehiclePlate, overTime)
    if not userId or not dismantleId then return end

    sendWebhook(Webhooks.DismantleCompleted, {
        description = "# DESMANCHE CONCLUÍDO",
        fields = {
            { name = "JOGADOR",    value = playerField(userId) },
            { name = "DESMANCHE",  value = dismantleId },
            { name = "PLACA",      value = vehiclePlate or "N/A" },
            { name = "TEMPO",      value = overTime and "Encerrado por tempo" or "Concluído a tempo" },
        },
        footer = { text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S") },
        color  = overTime and 16744448 or 2829875,
    })
end

function Webhooks.onPanelAction(userId, dismantleId, action, details)
    if not userId or not dismantleId then return end

    sendWebhook(Webhooks.PanelAction, {
        description = "# PAINEL DO DESMANCHE",
        fields = {
            { name = "JOGADOR",    value = playerField(userId) },
            { name = "DESMANCHE",  value = dismantleId },
            { name = "AÇÃO",       value = action or "N/A" },
            { name = "DETALHES",   value = details or "N/A" },
        },
        footer = { text = os.date("Dia: %d/%m/%Y - Horas: %H:%M:%S") },
        color  = 3447003,
    })
end
