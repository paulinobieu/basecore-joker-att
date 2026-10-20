-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (CLIENT)
-- Ganchos de client (hud, sons, notificações). Adapte só o CORPO das funções.
-----------------------------------------------------------------------------------------------------------------------------------------
Framework = {
    -- Painel de pets ABERTO.
    Open = function()
        -- TriggerEvent("hud:Active", false)
    end,

    -- Painel de pets FECHADO.
    Close = function()
        -- TriggerEvent("hud:Active", true)
    end,

    Notify = function(message)
        TriggerEvent("Notify", "Pets", tostring(message or ""), "azul", 5000)
    end,
}
