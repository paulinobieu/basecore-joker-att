-----------------------------------------------------------------------------------------------------------------------------------------
-- IDIOMAS
-- Todos os textos do script. Idioma ativo em Skins.Language (config.lua).
-- Placeholders no formato {var}. Pra adicionar um idioma, copie um bloco e
-- traduza os VALORES (não as chaves).
-----------------------------------------------------------------------------------------------------------------------------------------
local Languages = {
    ["pt-BR"] = {
        -- Rótulos genéricos
        labelCitizen        = "Cidadão",
        labelUnknown        = "Desconhecido",
        labelConsole        = "Console",
        currencySkinsCoins  = "SkinsCoins",
        currencyVouchers    = "Vouchers",

        -- Inventário (equipar / vender / comprar)
        equippedSuccess           = "Skin {skin} equipada com sucesso.",
        unequippedSuccess         = "Skin {skin} desequipada com sucesso.",
        noPriceForSell            = "Skin sem valor comercial, não pode ser vendida!",
        sellSuccess               = "Você vendeu a skin {skin} por {price} SkinsCoins.",
        noPriceForBuy             = "Skin sem valor comercial, não pode ser comprada!",
        buySuccess                = "Você comprou a skin {skin} por {price} SkinsCoins.",
        buyTempSuccess            = "Você comprou a skin {skin} por {days} dias por {price} SkinsCoins.",
        invalidDuration           = "Período de compra inválido.",
        insufficientSkinsCoinsBuy = "Você não possui SkinsCoins suficientes para comprar esta skin.",
        skinExpired               = "A skin {skin} expirou e foi removida do seu inventário.",

        -- Caixas
        insufficientSkinsCoins = "Você não possui SkinsCoins suficientes para abrir esta caixa.",
        noPermission           = "Você não tem permissão para abrir esta caixa.",
        cooldownActive         = "Esta caixa ainda está em cooldown.",

        -- Trocas
        tradeProposalSent    = "Proposta enviada com sucesso.",
        tradeAccepted        = "Troca concluída com sucesso.",
        tradeDeclined        = "Proposta recusada.",
        tradeExpired         = "Proposta expirou.",
        tradeMissingSkins    = "Uma das partes não possui mais as skins ofertadas.",
        tradeMissingVouchers = "Uma das partes não possui vouchers suficientes para concluir a troca.",

        -- Aprimoramento
        improvementSuccess                = "Aprimoramento bem-sucedido! Você recebeu {skin}.",
        improvementFailed                 = "O aprimoramento falhou. Os itens foram consumidos.",
        improvementInvalid                = "Seleção de itens inválida para aprimoramento.",
        improvementTemporarySkin          = "Skins temporárias não podem ser usadas em aprimoramentos.",
        improvementInsufficientSkinsCoins = "Você não possui SkinsCoins suficientes para esta aposta.",
        improvementNoTarget               = "Selecione um alvo válido para o aprimoramento.",
        improvementNoPlayerSkin           = "Selecione pelo menos uma skin sua para aprimorar.",
        improvementInvalidTarget          = "O item alvo está fora da faixa de valor permitida para o que você investiu.",
        improvementDisabled               = "O aprimoramento está desativado no momento.",

        -- Teste de arma
        weaponTestInvalid = "Skin inválida para teste.",
        weaponTestHelp    = "Pressione ~INPUT_FRONTEND_DELETE~ para encerrar o teste.",

        -- Admin (avisos pro jogador alvo)
        adminNoPermission     = "Você não tem permissão para isso.",
        adminCurrencyChanged  = "Um administrador ajustou seu saldo de {currency}.",
        adminSkinReceived     = "Você recebeu a skin {skin}.",
        adminSkinReceivedTemp = "Você recebeu a skin {skin} por {days} dias.",
        adminAllSkinsReceived = "Você recebeu todas as skins disponíveis.",

        -- Admin (comandos de console/chat)
        cmdUsageAmount       = "Uso: /{command} <passport> <amount>",
        cmdUsagePassport     = "Uso: /{command} <passport>",
        cmdCurrencyGiven     = "Adicionado <b>{qty}</b> {currency} ao passport <b>{id}</b>. Total: {total}",
        cmdCurrencyGiveFail  = "Falha ao adicionar {currency}.",
        cmdCurrencyRemoved   = "Removido <b>{qty}</b> {currency} do passport <b>{id}</b>. Total: {total}",
        cmdCurrencyNoBalance = "Passport sem saldo suficiente de {currency}.",
        cmdCurrencySet       = "Saldo de {currency} do passport <b>{id}</b> definido em <b>{qty}</b>.",
        cmdCurrencyCheck     = "Passport <b>{id}</b> possui <b>{total}</b> {currency}.",
        cmdGiveAllSkinsDone  = "Foram entregues <b>{count}</b> skins ao passport <b>{id}</b>.",
    },

    ["en-US"] = {
        -- Generic labels
        labelCitizen        = "Citizen",
        labelUnknown        = "Unknown",
        labelConsole        = "Console",
        currencySkinsCoins  = "SkinsCoins",
        currencyVouchers    = "Vouchers",

        -- Inventory (equip / sell / buy)
        equippedSuccess           = "Skin {skin} equipped successfully.",
        unequippedSuccess         = "Skin {skin} unequipped successfully.",
        noPriceForSell            = "This skin has no market value and cannot be sold!",
        sellSuccess               = "You sold the skin {skin} for {price} SkinsCoins.",
        noPriceForBuy             = "This skin has no market value and cannot be bought!",
        buySuccess                = "You bought the skin {skin} for {price} SkinsCoins.",
        buyTempSuccess            = "You bought the skin {skin} for {days} days for {price} SkinsCoins.",
        invalidDuration           = "Invalid purchase period.",
        insufficientSkinsCoinsBuy = "You don't have enough SkinsCoins to buy this skin.",
        skinExpired               = "The skin {skin} expired and was removed from your inventory.",

        -- Cases
        insufficientSkinsCoins = "You don't have enough SkinsCoins to open this case.",
        noPermission           = "You don't have permission to open this case.",
        cooldownActive         = "This case is still on cooldown.",

        -- Trades
        tradeProposalSent    = "Proposal sent successfully.",
        tradeAccepted        = "Trade completed successfully.",
        tradeDeclined        = "Proposal declined.",
        tradeExpired         = "The proposal expired.",
        tradeMissingSkins    = "One of the parties no longer owns the offered skins.",
        tradeMissingVouchers = "One of the parties doesn't have enough vouchers to complete the trade.",

        -- Improvement
        improvementSuccess                = "Improvement succeeded! You received {skin}.",
        improvementFailed                 = "The improvement failed. The items were consumed.",
        improvementInvalid                = "Invalid item selection for improvement.",
        improvementTemporarySkin          = "Temporary skins can't be used in improvements.",
        improvementInsufficientSkinsCoins = "You don't have enough SkinsCoins for this bet.",
        improvementNoTarget               = "Select a valid target for the improvement.",
        improvementNoPlayerSkin           = "Select at least one of your skins to improve.",
        improvementInvalidTarget          = "The target item is outside the value range allowed for what you invested.",
        improvementDisabled               = "Improvement is currently disabled.",

        -- Weapon test
        weaponTestInvalid = "Invalid skin for testing.",
        weaponTestHelp    = "Press ~INPUT_FRONTEND_DELETE~ to end the test.",

        -- Admin (target player warnings)
        adminNoPermission     = "You don't have permission to do that.",
        adminCurrencyChanged  = "An administrator adjusted your {currency} balance.",
        adminSkinReceived     = "You received the skin {skin}.",
        adminSkinReceivedTemp = "You received the skin {skin} for {days} days.",
        adminAllSkinsReceived = "You received every available skin.",

        -- Admin (console/chat commands)
        cmdUsageAmount       = "Usage: /{command} <passport> <amount>",
        cmdUsagePassport     = "Usage: /{command} <passport>",
        cmdCurrencyGiven     = "Added <b>{qty}</b> {currency} to passport <b>{id}</b>. Total: {total}",
        cmdCurrencyGiveFail  = "Failed to add {currency}.",
        cmdCurrencyRemoved   = "Removed <b>{qty}</b> {currency} from passport <b>{id}</b>. Total: {total}",
        cmdCurrencyNoBalance = "Passport doesn't have enough {currency}.",
        cmdCurrencySet       = "{currency} balance of passport <b>{id}</b> set to <b>{qty}</b>.",
        cmdCurrencyCheck     = "Passport <b>{id}</b> has <b>{total}</b> {currency}.",
        cmdGiveAllSkinsDone  = "Delivered <b>{count}</b> skins to passport <b>{id}</b>.",
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- RESOLUÇÃO
-- Expõe os globais Locale (dicionário do idioma ativo) e L(key, vars) (interpola {var}).
-----------------------------------------------------------------------------------------------------------------------------------------
Locale = Languages[Skins.Language] or Languages["pt-BR"] or {}

function L(key, vars)
    local str = Locale[key] or key
    if vars then
        str = str:gsub("{(%w+)}", function(name)
            local value = vars[name]
            return value ~= nil and tostring(value) or ("{" .. name .. "}")
        end)
    end
    return str
end
