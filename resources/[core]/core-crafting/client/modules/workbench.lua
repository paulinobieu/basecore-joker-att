-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENBENCH
-- O painel é buscado antes de abrir: sem permissão a interface nem aparece.
-----------------------------------------------------------------------------------------------------------------------------------------
function OpenBench(StationId)
    local Station = Crafting.Stations[StationId]
    if CraftOpen or not Station then
        return
    end

    local Panel = vSERVER.GetStation(StationId)
    if not Panel then
        return
    end

    CraftOpen = StationId
    CraftData = Panel

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)

    SendNUIMessage({ action = "craft:setColors", payload = Crafting.Colors })
    SendNUIMessage({ action = "setVisible", payload = StationId })

    Framework.Open()

    -- Sair de perto da bancada fecha o painel; o servidor refaz a mesma
    -- checagem em cada ação.
    CreateThread(function()
        while CraftOpen == StationId do
            Wait(500)

            if #(GetEntityCoords(PlayerPedId()) - Station.Coords) > Crafting.MaxDistance then
                CloseBench()
            end
        end
    end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSEBENCH
-----------------------------------------------------------------------------------------------------------------------------------------
function CloseBench()
    if not CraftOpen then
        return
    end

    CraftOpen = false
    CraftData = false

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ action = "setVisible", payload = false })

    Framework.Close()
end
