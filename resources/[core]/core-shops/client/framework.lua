-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (CLIENT)
-- Ganchos de client (hud, notificações, som). Adapte só o CORPO das funções.
-----------------------------------------------------------------------------------------------------------------------------------------
Tunnel = module("vrp", "lib/Tunnel")

vSERVER = Tunnel.getInterface("core-shops")

Framework = {
    Open = function()
        TriggerEvent("hud:Active", false)
    end,

    Close = function()
        TriggerEvent("hud:Active", true)
    end,

    Notify = function(Message, Color)
        TriggerEvent("Notify", Shops.Language.Title, Message, Color or "amarelo", 5000)
    end,

    -- Troque o corpo aqui caso a base use outro resource de som.
    PlaySound = function(Sound)
        if not Sound then
            return
        end

        TriggerEvent("sounds:Private", Sound.Name, Sound.Volume or 0.5)
    end,

    -- Procurado pela polícia não abre loja.
    Wanted = function()
        if GetResourceState("hud") ~= "started" then
            return false
        end

        return exports.hud:Wanted() and true or false
    end,
}
