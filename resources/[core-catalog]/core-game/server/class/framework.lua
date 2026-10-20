-- ══════════════════════════════════════════════
--              CORE NETWORK LTDA
-- ══════════════════════════════════════════════
-- Todos os direitos reservados © Core Network Ltda.
--
-- ATENÇÃO: arquivo de configuração aberto para adaptação. NÃO altere nada
-- aqui se você não tem conhecimento de programação — mudanças incorretas
-- podem quebrar o funcionamento do sistema.
-- ══════════════════════════════════════════════

-- =============================================================================
-- FRAMEWORK
-- =============================================================================
-- Ponto único de acoplamento ao framework (vRP, por padrão). Nenhum outro
-- arquivo do resource chama vRP diretamente — tudo passa por aqui. Pra usar
-- outro framework (ESX, QBCore, etc.), basta reescrever as funções abaixo
-- mantendo a mesma assinatura (mesmo nome, mesmos parâmetros, mesmo retorno).

local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

framework = {}

local getUserPassport = vRP.Passport
local getUserIdentity = vRP.Identity
local getUserBalance = vRP.GetBank

--- Avisa no console quando alguma função abaixo falha (ex.: função do
--- framework renomeada/removida na adaptação) — ajuda a achar o erro de
--- configuração sem derrubar a partida inteira.
local function warn(fnName, extra)
    print(("^1[framework.lua] %s falhou (%s) — confira se o framework foi adaptado corretamente.^0")
        :format(fnName, tostring(extra)))
end

--- Retorna o identificador único do jogador a partir do source da conexão.
--- No vRP isso é o "passport". Em outro framework, troque por citizenid,
--- identifier, etc.
---@param source number Source do jogador
---@return number|nil passport Identificador único do jogador ou nil se inválido
function framework.requestPassport(source)
    local ok, passport = pcall(getUserPassport, source)

    if not ok then
        warn("requestPassport", passport)
        return nil
    end

    return passport or nil
end

--- Retorna a identidade completa do jogador (nome, sobrenome, saldo...) a
--- partir do identificador único.
---@param passport number Identificador do jogador
---@return table|nil identity Tabela da identidade ou nil se inválido
function framework.requestIdentity(passport)
    local ok, identity = pcall(getUserIdentity, passport)

    if not ok then
        warn("requestIdentity", identity)
        return nil
    end

    return identity
end

--- Nome completo exibido em kill feed, ranking e perfil.
---@param passport number Identificador do jogador
---@return string|nil name Nome completo ou nil se inválido
function framework.requestFullName(passport)
    local identity = framework.requestIdentity(passport)

    if not identity or not identity.Name then
        return nil
    end

    if not identity.Lastname or identity.Lastname == "" then
        return identity.Name
    end

    return string.format("%s %s", identity.Name, identity.Lastname)
end

--- Só o primeiro nome (usado nas tags de time do lobby).
---@param passport number Identificador do jogador
---@return string|nil name Nome do jogador ou nil se inválido
function framework.requestName(passport)
    local identity = framework.requestIdentity(passport)

    if not identity then
        return nil
    end

    return identity.Name
end

--- Saldo disponível pra apostas de partida.
---@param passport number Identificador do jogador
---@return number balance Saldo do jogador (0 se não encontrado)
function framework.requestBalance(passport)
    local ok, balance = pcall(getUserBalance, passport)

    if not ok then
        warn("requestBalance", balance)
        return 0
    end

    return tonumber(balance) or 0
end

--- Debita o valor da aposta ao entrar numa partida apostada.
--- Troque por `Framework.Functions.RemoveMoney` (ESX) ou equivalente.
---@param passport number Identificador do jogador
---@param amount number Valor a ser removido
function framework.payment(passport, amount)
    local ok, result = pcall(vRP.PaymentBank, passport, amount)

    if not ok then
        warn("payment", result)
        return false
    end

    return result
end

--- Paga o prêmio aos vencedores no fim da partida.
--- Troque por `Framework.Functions.AddMoney` (ESX) ou equivalente.
---@param passport number Identificador do jogador
---@param amount number Valor a ser adicionado
function framework.addMoney(passport, amount)
    local ok, result = pcall(vRP.GiveBank, passport, amount)

    if not ok then
        warn("addMoney", result)
        return false
    end

    return result
end

--- Verifica se o jogador é admin. Usado pra liberar acesso a coisas
--- restritas independente de configuração do jogador/partida (ex: espectar
--- partidas com espectadores desativados). Troque pela checagem de permissão
--- equivalente do seu framework (ESX: checar o group; QBCore: checar o job).
---@param passport number Identificador do jogador
---@return boolean isAdmin
function framework.isAdmin(passport)
    if not passport then return false end

    local ok, result = pcall(vRP.HasGroup, passport, "Admin")

    if not ok then
        warn("isAdmin", result)
        return false
    end

    return result and true or false
end
