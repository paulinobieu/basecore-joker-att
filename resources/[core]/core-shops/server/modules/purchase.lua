-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
-- Uma compra por passaporte de cada vez.
local PurchaseLocks = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CANOPENSHOP
-- Revalidado na abertura e novamente no checkout.
-----------------------------------------------------------------------------------------------------------------------------------------
function CanOpenShop(Passport, Source, ShopId)
    local Shop = Shops.List[ShopId]
    if not Shop then
        return false
    end

    if Shop.Permission and not Framework.HasService(Passport, Shop.Permission) then
        return false, Shops.Language.NoPermission
    end

    if Shop.Route and Shop.Route ~= Framework.Route(Source) then
        return false
    end

    if Shops.BlockOnDebt and not Shop.IgnoreDebt and Framework.HasDebt(Passport) then
        return false, Shops.Language.PendingDebt
    end

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NORMALIZECART
-- A interface manda apenas identificador e quantidade: preço e limites saem
-- daqui.
-----------------------------------------------------------------------------------------------------------------------------------------
local function NormalizeCart(ShopId, Items)
    if type(Items) ~= "table" then
        return false, Shops.Language.InvalidCart
    end

    local Lines = {}
    local Seen  = {}
    local Total = 0

    for _, Entry in ipairs(Items) do
        if type(Entry) ~= "table" or type(Entry.id) ~= "string" or #Entry.id > 48 then
            return false, Shops.Language.InvalidCart
        end

        if Seen[Entry.id] then
            return false, Shops.Language.InvalidCart
        end

        local Price = ShopPrice(ShopId, Entry.id)
        if not Price then
            return false, Shops.Language.InvalidCart
        end

        local Amount = parseInt(Entry.amount)
        if Amount <= 0 then
            return false, Shops.Language.InvalidCart
        end

        if Amount > Shops.Cart.MaxAmount then
            Amount = Shops.Cart.MaxAmount
        end

        if Framework.ItemSingle(Entry.id) then
            Amount = 1
        end

        Seen[Entry.id] = true
        Lines[#Lines + 1] = { Item = Entry.id, Amount = Amount, Price = Price }
        Total = Total + (Price * Amount)

        if #Lines > Shops.Cart.MaxLines then
            return false, string.format(Shops.Language.CartTooBig, Shops.Cart.MaxLines)
        end
    end

    if #Lines == 0 then
        return false, Shops.Language.EmptyCart
    end

    return Lines, Total
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKCAPACITY
-- Peso e limite por item considerando o carrinho inteiro.
-----------------------------------------------------------------------------------------------------------------------------------------
local function CheckCapacity(Passport, Lines)
    local Weight = Framework.InventoryWeight(Passport)

    for _, Line in ipairs(Lines) do
        if Framework.ReachedMax(Passport, Line.Item, Line.Amount) then
            return false, string.format(Shops.Language.MaxAmount, Framework.ItemName(Line.Item))
        end

        Weight = Weight + (Framework.ItemWeight(Line.Item) * Line.Amount)
    end

    if Weight > Framework.MaxWeight(Passport) then
        return false, Shops.Language.NoSpace
    end

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHARGECART
-----------------------------------------------------------------------------------------------------------------------------------------
local function ChargeCart(Passport, Shop, Total)
    if Shop.Payment == "Gemstone" then
        if Framework.PaymentGems(Passport, Total) then
            return true, "Diamantes"
        end

        return false, Shops.Language.NoGemstone
    end

    if Shop.Payment == "Consume" then
        if Framework.TakeItem(Passport, Shop.PaymentItem, Total) then
            return true, Framework.ItemName(Shop.PaymentItem)
        end

        return false, string.format(Shops.Language.NoItem, Framework.ItemName(Shop.PaymentItem))
    end

    if Framework.PaymentCash(Passport, Total) then
        return true, "Dinheiro"
    end

    return false, Shops.Language.NoCash
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CARTSUMMARY
-----------------------------------------------------------------------------------------------------------------------------------------
local function CartSummary(Lines)
    local Parts = {}

    for _, Line in ipairs(Lines) do
        Parts[#Parts + 1] = Line.Amount .. "x " .. Framework.ItemName(Line.Item)
    end

    return table.concat(Parts, ", ")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROCESSCHECKOUT
-----------------------------------------------------------------------------------------------------------------------------------------
function ProcessCheckout(Passport, Source, ShopId, Items)
    local Shop = Shops.List[ShopId]
    if not Shop then
        return false, Shops.Language.Failed
    end

    if PurchaseLocks[Passport] then
        return false, Shops.Language.Failed
    end

    local Allowed, Denied = CanOpenShop(Passport, Source, ShopId)
    if not Allowed then
        return false, Denied or Shops.Language.NoPermission
    end

    local Lines, Total = NormalizeCart(ShopId, Items)
    if not Lines then
        return false, Total
    end

    local Fits, Reason = CheckCapacity(Passport, Lines)
    if not Fits then
        return false, Reason
    end

    PurchaseLocks[Passport] = true

    local Executed, Result = xpcall(function()
        local Paid, Payment = ChargeCart(Passport, Shop, Total)
        if not Paid then
            return { false, Payment }
        end

        for _, Line in ipairs(Lines) do
            Framework.GiveItem(Passport, Line.Item, Line.Amount)
        end

        Framework.Log("COMPROU-LOJA", {
            message    = Framework.FullName(Passport) .. " #" .. Passport .. " comprou " .. CartSummary(Lines) .. " na " .. Shop.Title,
            playerName = Framework.FullName(Passport),
            playerId   = Passport,
            Loja       = Shop.Title,
            Itens      = CartSummary(Lines),
            Valor      = Total,
            Pagamento  = Payment,
        })

        return { true, Shops.Language.Success }
    end, debug.traceback)

    PurchaseLocks[Passport] = nil

    if not Executed then
        print("^1[CORE-SHOPS]^7 " .. tostring(Result))
        return false, Shops.Language.Failed
    end

    return Result[1], Result[2]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("Disconnect", function(Passport)
    PurchaseLocks[Passport] = nil
end)
