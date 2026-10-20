-----------------------------------------------------------------------------------------------------------------------------------------
-- WEBHOOK
-----------------------------------------------------------------------------------------------------------------------------------------
-- Fallback de logs quando o "core_logs" NAO esta rodando.
-- Preencha "default" para enviar todos os logs ao mesmo canal ou use
-- "purchase" para separar as compras de capinhas.
Webhooks = {}

local WebhookURLs = {
    -- Compras unitarias e compras realizadas pelo carrinho.
    purchase = "",

    -- Canal padrao: recebe o log quando a URL especifica esta vazia.
    default = "",
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
local PerformHttpRequest = PerformHttpRequest
local json_encode = json.encode
local os_date = os.date
local tostring = tostring
local type = type
local concat = table.concat
-----------------------------------------------------------------------------------------------------------------------------------------
-- HELPERS
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
    name = tostring(name or "-")

    if not id then return name end

    return name .. " #" .. tostring(id)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMPRAS
-----------------------------------------------------------------------------------------------------------------------------------------
function Webhooks.Purchase(data)
    local itemLabels = {}
    local items = type(data.items) == "table" and data.items or {}

    for i = 1, #items do
        local item = items[i]
        local label = tostring(item.name or item.id or "Capinha")

        if item.id and item.id ~= "" then
            label = label .. " (" .. tostring(item.id) .. ")"
        end

        itemLabels[i] = label
    end

    local lines = {
        "[COMPRA DE CAPINHAS]",
        Field("Comprador", Named(data.player, data.passport)),
        Field("Capinhas", #itemLabels > 0 and concat(itemLabels, ", ") or "-"),
        Field("Quantidade", data.amount or #itemLabels),
        Field("Valor total", tostring(data.total or 0) .. " " .. tostring(data.currencyLabel or data.currency or "")),
    }

    if data.balance ~= nil then
        lines[#lines + 1] = Field("Saldo restante", tostring(data.balance) .. " " .. tostring(data.currencyLabel or data.currency or ""))
    end

    SendLog(WebhookURLs.purchase, lines)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FALLBACK GENERICO
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
    CASES_PURCHASE = Webhooks.Purchase,
}

function Webhooks.Log(category, data)
    local fn = Dispatch[category]

    if fn and type(data) == "table" then
        fn(data)
        return
    end

    Webhooks.Generic(category, data)
end
