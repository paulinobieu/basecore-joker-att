-----------------------------------------------------------------------------------------------------------------------------------------
-- IDIOMAS
-- Traduza só os valores da direita. O que está entre {chaves} é preenchido em
-- tempo de execução: mantenha na frase.
-----------------------------------------------------------------------------------------------------------------------------------------
local Languages = {
    ["pt-BR"] = {
        -- Rótulos genéricos
        labelCitizen = "Cidadão",

        -- Alvo do pedido / da carta
        invalidTarget = "Passaporte inválido ou pessoa offline!",
        targetIsSelf  = "Você não pode fazer isso consigo mesmo.",
        targetTooFar  = "Você precisa estar perto da pessoa.",

        -- Pedidos
        requestUnavailable = "Esse pedido não está disponível para o seu status atual.",
        requestTargetBusy  = "{name} já está em um relacionamento.",
        requestNotPartner  = "Esse pedido só pode ser feito para a sua pessoa amada.",
        requestPending     = "{name} já tem um pedido aguardando resposta.",
        requestCooldown    = "Aguarde um pouco antes de enviar outro pedido.",
        requestSent        = "Pedido enviado para {name}.",
        requestExpired     = "O pedido para {name} expirou.",
        requestRefused     = "{name} recusou o seu pedido.",
        requestNotFound    = "Esse pedido não existe mais.",

        -- Transições de status
        nowDating  = "Agora você está namorando com {name}!",
        nowEngaged = "Agora você está noivo(a) de {name}!",
        nowMarried = "Agora você está casado(a) com {name}!",
        nowSingle  = "Seu relacionamento com {name} chegou ao fim.",

        -- Anúncio global no chat (Love.Announce, em config.lua)
        announceDating  = "{one} e {two} agora estão namorando!",
        announceEngaged = "{one} e {two} ficaram noivos!",
        announceMarried = "{one} e {two} se casaram!",
        announceSingle  = "{one} e {two} não estão mais juntos.",

        -- Correio do amor
        letterEmpty      = "Escreva alguma coisa antes de enviar.",
        letterTooLong    = "A carta passou do limite de {max} caracteres.",
        letterCooldown   = "Aguarde um pouco antes de mandar outra carta.",
        letterNotPartner = "Você só pode escrever para a sua pessoa amada.",
        letterSent       = "Carta entregue para {name}.",
        letterReceived   = "Você recebeu uma carta de {name}.",
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- RESOLUÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
Locale = Languages[Love.Language] or Languages["pt-BR"] or {}

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
