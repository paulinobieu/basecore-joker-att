-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (CLIENT)
-----------------------------------------------------------------------------------------------------------------------------------------
Tunnel = module("vrp", "lib/Tunnel")

vSERVER = Tunnel.getInterface("core-booster")

Framework = {
    Open = function()
        TriggerEvent("hud:Active", false)
    end,

    Close = function()
        TriggerEvent("hud:Active", true)
    end,
}
