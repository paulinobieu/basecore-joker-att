-----------------------------------------------------------------------------------------------------------------------------------------
-- ENTRADA
-- Balcões de atendimento e o evento que outros resources usam para abrir o
-- banco (o core-c4 abre pelos caixas eletrônicos).
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    for Index, Coords in ipairs(Bank.Locations) do
        exports.ox_target:addSphereZone({
            coords = Coords,
            radius = Bank.Interaction.Radius,
            name = "CoreBank:" .. Index,
            options = {
                {
                    name = "core-bank:open:" .. Index,
                    label = Bank.Interaction.Label,
                    icon = Bank.Interaction.Icon,
                    distance = Bank.Interaction.Radius,
                    onSelect = function()
                        TriggerEvent("core-bank:open")
                    end,
                },
            },
        })
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-BANK:OPEN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("core-bank:open")
AddEventHandler("core-bank:open", function()
    if NUIOpen then return end
    if GetEntityHealth(PlayerPedId()) <= 100 then return end

    ToggleBank(true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLEANUP
-----------------------------------------------------------------------------------------------------------------------------------------
Framework.OnResourceStop(function()
    if not NUIOpen then return end

    ToggleBank(false)
end)
