-----------------------------------------------------------------------------------------------------------------------------------------
-- SHOP:GETDATA
-- Responde com o catálogo já validado na abertura.
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("shop:getData", function(_, Callback)
    if not ShopOpen or not ShopData then
        Callback(false)
        return
    end

    Callback(ShopData)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SHOP:CHECKOUT
-- A interface manda apenas identificador e quantidade; o servidor refaz preço,
-- permissão e capacidade.
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("shop:checkout", function(Data, Callback)
    if not ShopOpen or type(Data) ~= "table" or type(Data.items) ~= "table" then
        Callback({ success = false, message = Shops.Language.InvalidCart })
        return
    end

    local Cart = {}
    for _, Line in ipairs(Data.items) do
        if type(Line) == "table" and type(Line.id) == "string" then
            Cart[#Cart + 1] = { id = Line.id, amount = Line.amount }
        end
    end

    if #Cart == 0 then
        Callback({ success = false, message = Shops.Language.EmptyCart })
        return
    end

    local Result = vSERVER.Checkout(ShopOpen, Cart)
    if Result and Result.success then
        Framework.PlaySound(Shops.Sounds.Purchase)
    end

    Callback(Result)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SHOP:CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("shop:close", function(_, Callback)
    CloseShop()
    Callback(true)
end)
