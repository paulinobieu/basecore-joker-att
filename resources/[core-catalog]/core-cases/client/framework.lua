-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (CLIENT)
-----------------------------------------------------------------------------------------------------------------------------------------
Framework = {
    Open = function()
        -- TriggerEvent("hud:Active", false)
    end,

    Close = function()
        -- TriggerEvent("hud:Active", true)
    end,

    Notify = function(message)
        TriggerEvent("Notify", "Cases", tostring(message or ""), "azul", 5000)
    end,
}
