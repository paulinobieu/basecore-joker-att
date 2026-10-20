-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (CLIENT)
-----------------------------------------------------------------------------------------------------------------------------------------
Framework = {
    Open = function()
    end,

    Close = function()
    end,

    Notify = function(message)
        TriggerEvent("Notify", "Organização", tostring(message or ""), "azul", 5000)
    end,

    ConnectRadio = function(frequency)
        TriggerServerEvent("core-radio:connect", frequency)
    end,

    DisconnectRadio = function(frequency)
        TriggerServerEvent("core-radio:disconnect", frequency)
    end,
}
