-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (CLIENT)
-- Ganchos de client (hud). Adapte só o CORPO das funções.
-----------------------------------------------------------------------------------------------------------------------------------------
Tunnel = module("vrp", "lib/Tunnel")

vSERVER = Tunnel.getInterface("core-crafting")

Framework = {
    Open = function()
        TriggerEvent("hud:Active", false)
    end,

    Close = function()
        TriggerEvent("hud:Active", true)
    end,
}
