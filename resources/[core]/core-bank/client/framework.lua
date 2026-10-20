-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (CLIENT)
-- Ganchos de client (hud, interface). Adapte só o CORPO das funções.
-----------------------------------------------------------------------------------------------------------------------------------------
Tunnel = module("vrp", "lib/Tunnel")
Proxy  = module("vrp", "lib/Proxy")

vSERVER = Tunnel.getInterface(GetCurrentResourceName())

Framework = {
    Open = function()
        SetNuiFocus(true, true)
        TriggerEvent("hud:Active", false)
    end,

    Close = function()
        SetNuiFocus(false, false)
        TriggerEvent("hud:Active", true)
    end,

    --- Cor da interface: Theme.main tem prioridade sobre a config do resource.
    ThemeColor = function()
        if Theme and type(Theme.main) == "string" and Theme.main ~= "" then
            return Theme.main
        end

        return Bank.ThemeColor
    end,

    OnResourceStop = function(Handler)
        AddEventHandler("onResourceStop", function(Resource)
            if Resource ~= GetCurrentResourceName() then return end
            Handler()
        end)
    end,
}
