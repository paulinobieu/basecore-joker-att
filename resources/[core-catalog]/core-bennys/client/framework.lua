-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (CLIENT)
-- Ganchos de client (hud, notificações). Adapte só o CORPO das funções.
-----------------------------------------------------------------------------------------------------------------------------------------
Proxy = module("vrp", "lib/Proxy")
vRP   = Proxy.getInterface("vRP")

Framework = {
    -- Painel de bennys ABERTO.
    Open = function()
        TriggerEvent("hud:Active", false)
    end,

    -- Painel de bennys FECHADO.
    Close = function()
        TriggerEvent("hud:Active", true)
    end,

    Notify = function(Source, Style, Content, Time)
        if Source then
            TriggerClientEvent("core-bennys:notifyBennys", Source, Style, Content, Time)
        else
            TriggerEvent("core-bennys:notifyBennys", Style, Content, Time)
        end
    end,

    VehicleList = function(Distance)
        return vRP.VehicleList(Distance)
    end,
}
