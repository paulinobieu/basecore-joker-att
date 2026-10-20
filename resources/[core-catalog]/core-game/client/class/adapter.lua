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
-- ADAPTER (client)
-- =============================================================================
-- Integração com o rádio do time (pma-voice) e com o sistema de skins de
-- arma (core-skins). Ponto de adaptação pra quem usa outro resource de rádio
-- ou de skins — só trocar as duas funções abaixo mantendo a assinatura.

adapter = adapter or {}

--- Coloca o jogador no canal de rádio do time (chamado ao entrar num time).
--- Troca pma-voice por outro resource de rádio aqui, se necessário.
---@param radio number|string Canal de rádio (0 ou menor = sem rádio)
---@return boolean success
function adapter.setRadio(radio)
    radio = tonumber(radio)

    exports["pma-voice"]:removePlayerFromRadio()

    if not radio or radio <= 0 then
        return false
    end

    Wait(50)

    exports["pma-voice"]:setRadioChannel(radio)

    return true
end

--- Aplica a skin equipada do jogador na arma recém-recebida. Chamada após
--- toda entrega de arma (loadout do round, compra na loja, pegar arma do
--- chão). Sem o resource "core-skins" rodando, o evento simplesmente não tem
--- handler (no-op seguro) — comente o Trigger ou adapte pro seu sistema de
--- skins aqui.
---@param weaponName string Nome da arma (ex.: "WEAPON_CARBINERIFLE")
function adapter.applyWeaponSkin(weaponName)
    if not weaponName then return end

    TriggerServerEvent("core-skins:TryApplyComponent", weaponName)
end
