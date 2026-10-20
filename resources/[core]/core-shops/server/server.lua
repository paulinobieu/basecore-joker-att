-----------------------------------------------------------------------------------------------------------------------------------------
-- GETSHOP
-- Entrada da interface: devolve o catálogo da loja quando o acesso é liberado.
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.GetShop(ShopId)

    local source = source
    local Passport = Framework.Passport(source)
    if not Passport then
        return false
    end

    if type(ShopId) ~= "string" or #ShopId > 48 or not Shops.List[ShopId] then
        return false
    end

    local Allowed, Denied = CanOpenShop(Passport, source, ShopId)
    if not Allowed then
        if Denied then
            Framework.Notify(source, Denied, "vermelho")
        end

        return false
    end

    return BuildCatalog(ShopId)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKOUT
-----------------------------------------------------------------------------------------------------------------------------------------
function Core.Checkout(ShopId, Items)

    local source = source
    local Passport = Framework.Passport(source)
    if not Passport then
        return { success = false, message = Shops.Language.Failed }
    end

    if type(ShopId) ~= "string" or #ShopId > 48 or not Shops.List[ShopId] then
        return { success = false, message = Shops.Language.InvalidCart }
    end

    local Success, Message = ProcessCheckout(Passport, source, ShopId, Items)

    return { success = Success, message = Message }
end
