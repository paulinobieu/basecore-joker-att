-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENSHOP
-- O catálogo é buscado antes de abrir: sem permissão a interface nem aparece.
-----------------------------------------------------------------------------------------------------------------------------------------
function OpenShop(ShopId)
    if ShopOpen or not Shops.List[ShopId] then
        return
    end

    if Framework.Wanted() then
        Framework.Notify(Shops.Language.Wanted, "vermelho")
        return
    end

    local Catalog = vSERVER.GetShop(ShopId)
    if not Catalog then
        return
    end

    ShopOpen = ShopId
    ShopData = Catalog

    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)

    SendNUIMessage({ action = "shop:setColors", payload = Shops.Colors })
    SendNUIMessage({ action = "setVisible", payload = ShopId })

    Framework.Open()
    Framework.PlaySound(Shops.Sounds.Open)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-SHOPS:OPEN
-- Ponto de entrada para máquinas e objetos que já resolvem a loja por conta
-- própria (ox_target do core-modules, props colocados, etc).
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("core-shops:Open", function(ShopId)
    if type(ShopId) ~= "string" then
        return
    end

    OpenShop(ShopId)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSESHOP
-----------------------------------------------------------------------------------------------------------------------------------------
function CloseShop()
    if not ShopOpen then
        return
    end

    ShopOpen = false
    ShopData = false

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ action = "setVisible", payload = false })

    Framework.Close()
end
