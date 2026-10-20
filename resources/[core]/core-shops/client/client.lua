-----------------------------------------------------------------------------------------------------------------------------------------
-- INTERACTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
    if GetResourceState("sleepless_interact") ~= "started" or not exports.sleepless_interact then
        print("^3[CORE-SHOPS]^7 sleepless_interact indisponível: nenhuma loja foi registrada.")
        return
    end

    for Index, Point in ipairs(Shops.Locations) do
        local Shop = Shops.List[Point.Shop]

        if not Shop then
            print("^3[CORE-SHOPS]^7 ponto " .. Index .. " aponta para uma loja inexistente: " .. tostring(Point.Shop))
        else
            exports.sleepless_interact:addCoords(Point.Coords, {
                name     = "core-shops:" .. Index,
                label    = Shops.Language.InteractOpen,
                icon     = Shops.Interaction.Icon,
                distance = Point.Distance or Shops.Interaction.Distance,
                onSelect = function()
                    OpenShop(Point.Shop)
                end,
                canInteract = function()
                    return not ShopOpen
                end,
            })
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ONRESOURCESTOP
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onResourceStop", function(Resource)
    if Resource ~= GetCurrentResourceName() or not ShopOpen then
        return
    end

    ShopOpen = false
    ShopData = false

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    Framework.Close()
end)
