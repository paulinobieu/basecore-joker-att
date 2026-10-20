-----------------------------------------------------------------------------------------------------------------------------------------
-- INTERACTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    if GetResourceState("sleepless_interact") ~= "started" or not exports.sleepless_interact then
        print("^3[CORE-CRAFTING]^7 sleepless_interact indisponível: nenhuma bancada foi registrada.")
        return
    end

    for Index, Station in ipairs(Crafting.Stations) do
        exports.sleepless_interact:addCoords(Station.Coords, {
            name     = "core-crafting:" .. Index,
            label    = Crafting.Language.InteractOpen,
            icon     = Crafting.Interaction.Icon,
            distance = Crafting.Interaction.Distance,
            onSelect = function()
                OpenBench(Index)
            end,
            canInteract = function()
                return not CraftOpen
            end,
        })
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ONRESOURCESTOP
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onResourceStop", function(Resource)
    if Resource ~= GetCurrentResourceName() or not CraftOpen then
        return
    end

    CraftOpen = false
    CraftData = false

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    Framework.Close()
end)
