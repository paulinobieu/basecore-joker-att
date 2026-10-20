-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (CLIENT)
-- Ganchos de client (hud, sons, notificações). Adapte só o CORPO das funções.
-----------------------------------------------------------------------------------------------------------------------------------------
Framework = {
    -- Tablet ABERTO.
    Open = function()
        -- TriggerEvent("hud:Active", false)
    end,

    -- Tablet FECHADO.
    Close = function()
        -- TriggerEvent("hud:Active", true)
    end,

    Notify = function(message)
        TriggerEvent("Notify", "MDT", tostring(message or ""), "azul", 5000)
    end,
}
