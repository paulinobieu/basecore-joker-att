Webhooks = {}

local webhookURLs = {
    purchase    = "",
    restock     = "",
    withdraw    = "",
    priceChange = "",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- HELPER INTERNO
-----------------------------------------------------------------------------------------------------------------------------------------

local function sendWebhook(url, embed)
    if not url or url == "" then return end

    PerformHttpRequest(url, function() end, "POST", json.encode({
        username = "Core Totem",
        embeds   = { embed },
    }), { ["Content-Type"] = "application/json" })
end

local function playerField(user_id)
    return "```ini\n[" .. tostring(user_id) .. "] " .. Functions.getUserName(user_id) .. "\n```"
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTOS
-----------------------------------------------------------------------------------------------------------------------------------------

function Webhooks.onPurchase(user_id, totemId, itemNames, totalCost, stockUsed)
    sendWebhook(webhookURLs.purchase, {
        author = {
            name     = "Compra no Totem",
            icon_url = "https://cdn-icons-png.flaticon.com/512/3514/3514491.png",
        },
        fields = {
            { name = "Jogador",           value = playerField(user_id) },
            { name = "Totem",             value = "```" .. totemId .. "```",            inline = true },
            { name = "Itens",             value = "```" .. itemNames .. "```",          inline = true },
            { name = "Valor",             value = "```" .. tostring(totalCost) .. "```", inline = true },
            { name = "Estoque Consumido", value = "```" .. tostring(stockUsed) .. "```", inline = true },
        },
        color = 3066993,
    })
end

function Webhooks.onRestock(user_id, totemId, itemName, amount, newStock)
    sendWebhook(webhookURLs.restock, {
        author = {
            name     = "Reabastecimento",
            icon_url = "https://cdn-icons-png.flaticon.com/512/3514/3514491.png",
        },
        fields = {
            { name = "Admin",         value = playerField(user_id) },
            { name = "Totem",         value = "```" .. totemId .. "```",           inline = true },
            { name = "Item",          value = "```" .. itemName .. "```",          inline = true },
            { name = "Adicionado",    value = "```+" .. tostring(amount) .. "```", inline = true },
            { name = "Estoque Atual", value = "```" .. tostring(newStock) .. "```", inline = true },
        },
        color = 15105570,
    })
end

function Webhooks.onWithdraw(user_id, totemId, amount)
    sendWebhook(webhookURLs.withdraw, {
        author = {
            name     = "Retirada de Caixa",
            icon_url = "https://cdn-icons-png.flaticon.com/512/3514/3514491.png",
        },
        fields = {
            { name = "Admin", value = playerField(user_id) },
            { name = "Totem", value = "```" .. totemId .. "```",          inline = true },
            { name = "Valor", value = "```" .. tostring(amount) .. "```", inline = true },
        },
        color = 15158332,
    })
end

function Webhooks.onPriceChange(user_id, totemId, itemName, oldPrice, newPrice)
    sendWebhook(webhookURLs.priceChange, {
        author = {
            name     = "Alteracao de Preco",
            icon_url = "https://cdn-icons-png.flaticon.com/512/3514/3514491.png",
        },
        fields = {
            { name = "Admin",  value = playerField(user_id) },
            { name = "Totem",  value = "```" .. totemId .. "```",           inline = true },
            { name = "Item",   value = "```" .. itemName .. "```",          inline = true },
            { name = "Antes",  value = "```" .. tostring(oldPrice) .. "```", inline = true },
            { name = "Depois", value = "```" .. tostring(newPrice) .. "```", inline = true },
        },
        color = 3447003,
    })
end
