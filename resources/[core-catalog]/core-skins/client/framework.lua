-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (CLIENT)
-- Camada de adaptação do lado do jogador (hud, notificações, tema, armas).
-- É o ÚNICO arquivo do client que fala com a sua base direto. Pra adaptar o
-- core-skins a outro framework, reescreva só o CORPO das funções abaixo,
-- mantendo os mesmos nomes, parâmetros e tipos de retorno.
-----------------------------------------------------------------------------------------------------------------------------------------
Framework = {
    -------------------------------------------------------------------------------------------------------------------------------------
    -- PAINEL
    -------------------------------------------------------------------------------------------------------------------------------------
    -- Painel de skins ABERTO.
    Open = function()
        -- TriggerEvent("hud:Active", false)
    end,

    -- Painel de skins FECHADO.
    Close = function()
        -- TriggerEvent("hud:Active", true)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- NOTIFICAÇÕES
    -------------------------------------------------------------------------------------------------------------------------------------
    Notify = function(message, kind)
        TriggerEvent("Notify", "Skins", tostring(message or ""), kind or "amarelo", 5000)
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- TEMA
    -- Cor base do tema global do servidor, se ele tiver um. Tem prioridade sobre
    -- Skins.Colors.primaryColor. Retorne nil pra sempre usar a cor do config.
    -------------------------------------------------------------------------------------------------------------------------------------
    ThemeColor = function()
        return Theme and Theme.main or nil
    end,

    -------------------------------------------------------------------------------------------------------------------------------------
    -- ARMAS (TESTE DE SKIN)
    -- Chamado antes de teleportar o jogador pra área de teste: é a hora de tirar
    -- da mão as armas do inventário, pra ele só ficar com a arma da skin.
    -------------------------------------------------------------------------------------------------------------------------------------
    CleanWeapons = function()
        TriggerEvent("inventory:CleanWeapons")
    end,
}
