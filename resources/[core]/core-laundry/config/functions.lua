-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK
-----------------------------------------------------------------------------------------------------------------------------------------
-- Este arquivo é a ponte (bridge) entre o core-laundry e o seu framework.
-- Toda a lógica do sistema chama apenas Functions.* — ela nunca fala com o framework direto.
-- Para portar o script para outro framework, basta reescrever o CORPO de cada função abaixo,
-- mantendo o mesmo nome, os mesmos parâmetros e o mesmo tipo de retorno.
--
-- Abaixo está a implementação padrão para o vRP.
-----------------------------------------------------------------------------------------------------------------------------------------

local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

Functions = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- TIPOS DE NOTIFICAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Estilos usados nas notificações. Cada valor é convertido no client para o tipo visual
-- correspondente (verde = sucesso, vermelho = erro, amarelo = aviso, azul = info).

Functions.NotifyTypes = {
    Success = "verde",
    Denied  = "vermelho",
    Warning = "amarelo",
    Info    = "azul",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFY
-----------------------------------------------------------------------------------------------------------------------------------------
-- Envia uma notificação para o jogador. O core-laundry tem seu próprio sistema de notify
-- na interface (não use o notify do seu framework aqui). Mantenha o evento como está.

function Functions.Notify(source, notifyType, message, duration)
    TriggerClientEvent("core-laundry:notify", source, notifyType, message, duration or 5000)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- PASSPORT
-----------------------------------------------------------------------------------------------------------------------------------------
-- Recebe o source (id de rede do jogador) e retorna o identificador único/persistente dele.
-- É esse id que o sistema usa como "dono" das ações. Retorne nil/false se não existir.

function Functions.Passport(source)
    return vRP.Passport(source)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- SOURCE
-----------------------------------------------------------------------------------------------------------------------------------------
-- Caminho inverso do Passport: recebe o identificador único e retorna o source online (ou nil).

function Functions.Source(user_id)
    return vRP.Source(user_id)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- FULLNAME
-----------------------------------------------------------------------------------------------------------------------------------------
-- Retorna o nome completo do jogador a partir do identificador único. Usado apenas nos logs.

function Functions.FullName(user_id)
    return vRP.FullName(user_id)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- HASPERMISSION
-----------------------------------------------------------------------------------------------------------------------------------------
-- Verifica se o jogador tem uma permissão. O 2º argumento pode ser uma string (uma permissão)
-- ou uma tabela (lista de permissões — basta ter uma). Sem permissão definida = acesso liberado.
-- É isso que controla o acesso às máquinas com permissão configurada.

function Functions.HasPermission(user_id, permissions)
    if not permissions then return true end
    if type(permissions) == "table" then return vRP.HasTable(user_id, permissions) end
    return vRP.HasPermission(user_id, permissions)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- HASGROUP
-----------------------------------------------------------------------------------------------------------------------------------------
-- Verifica se o jogador pertence a um grupo em um nível mínimo. Usado para liberar o
-- painel administrativo (grupo/nível definidos em Laundry.Admin no config).

function Functions.HasGroup(user_id, group, level)
    return vRP.HasGroup(user_id, group, level)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- USERSBYPERMISSION
-----------------------------------------------------------------------------------------------------------------------------------------
-- Retorna uma lista de sources online que possuem determinada permissão.

function Functions.UsersByPermission(permission)
    if not permission then return {} end
    local users  = vRP.NumPermission(permission) or {}
    local result = {}
    for _, src in pairs(users) do
        if src then result[#result + 1] = src end
    end
    return result
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORYITEMAMOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
-- Retorna DOIS valores: a quantidade que o jogador tem de um item e o slot dele.
-- Usado para checar dinheiro sujo e limpadores antes de consumir.

function Functions.InventoryItemAmount(user_id, item)
    local data = vRP.InventoryItemAmount(user_id, item)
    return tonumber(data[1]) or 0, data[2] or item
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- TAKEITEM
-----------------------------------------------------------------------------------------------------------------------------------------
-- Remove uma quantidade de um item do jogador. Deve retornar true se conseguiu remover.

function Functions.TakeItem(user_id, item, amount)
    return vRP.TakeItem(user_id, item, amount, true)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- GIVEITEM
-----------------------------------------------------------------------------------------------------------------------------------------
-- Entrega uma quantidade de um item ao jogador (dinheiro limpo, reembolsos, etc.).

function Functions.GiveItem(user_id, item, amount)
    return vRP.GenerateItem(user_id, item, amount, true)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- PAYMENT
-----------------------------------------------------------------------------------------------------------------------------------------
-- Cobra um valor do jogador (usado para pagar os upgrades). Deve retornar true se pagou.

function Functions.Payment(user_id, amount)
    return vRP.PaymentFull(user_id, amount)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- LOG (não mexer)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Envia um log de cada ação. Se o core_logs estiver rodando, vai pra lá; senão, cai no
-- fallback por webhook (config/webhooks.lua). Não precisa alterar — configure os webhooks
-- no webhooks.lua ou instale o core_logs.

function Functions.Log(category, data)
    if GetResourceState("core_logs") == "started" then
        exports["core_logs"]:AddLog(category, data)
    elseif Webhooks and Webhooks.Log then
        Webhooks.Log(category, data)
    end
end
