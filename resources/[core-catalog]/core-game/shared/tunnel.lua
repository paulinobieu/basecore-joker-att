-- ══════════════════════════════════════════════
--              CORE NETWORK LTDA
-- ══════════════════════════════════════════════
-- Todos os direitos reservados © Core Network Ltda.
--
-- ATENÇÃO: arquivo de configuração aberto para adaptação. NÃO altere nada
-- aqui se você não tem conhecimento de programação — mudanças incorretas
-- podem quebrar o funcionamento do sistema.
-- ══════════════════════════════════════════════

if IsDuplicityVersion() then
    Tunnel = module("vrp", "lib/Tunnel")
    Proxy = module("vrp", "lib/Proxy")
    vRP = Proxy.getInterface("vRP")
    vRPC = Tunnel.getInterface("vRP")

    core = {}

    Tunnel.bindInterface("Core_Game", core)
    clientAPI = Tunnel.getInterface("Core_Game")
else
    Tunnel = module("vrp", "lib/Tunnel")
    Proxy = module("vrp", "lib/Proxy")
    vRP = Proxy.getInterface("vRP")
    vRPC = Tunnel.getInterface("vRP")

    core = {}

    Tunnel.bindInterface("Core_Game", core)
    serverAPI = Tunnel.getInterface("Core_Game")
end
