-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
-- Catálogo é estático (vem da config), então é montado uma vez por loja.
local CatalogCache = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- SHOPPRICE
-- Preço unitário do item na loja. Fonte única de verdade para a cobrança.
-----------------------------------------------------------------------------------------------------------------------------------------
function ShopPrice(ShopId, Item)
    local Shop = Shops.List[ShopId]
    if not Shop then
        return false
    end

    for _, Entry in ipairs(Shop.Items) do
        if Entry.Item == Item then
            return Entry.Price
        end
    end

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDCATALOG
-- Payload consumido pela interface: identidade da loja, abas e produtos.
-----------------------------------------------------------------------------------------------------------------------------------------
function BuildCatalog(ShopId)
    if CatalogCache[ShopId] then
        return CatalogCache[ShopId]
    end

    local Shop = Shops.List[ShopId]
    if not Shop then
        return false
    end

    local Categories = {}
    if Shop.Categories then
        Categories[#Categories + 1] = { id = "all", label = "Tudo" }

        for _, Category in ipairs(Shop.Categories) do
            Categories[#Categories + 1] = { id = Category.Id, label = Category.Label }
        end
    end

    local Products = {}
    for _, Entry in ipairs(Shop.Items) do
        if not Framework.ItemExist(Entry.Item) then
            print("^3[CORE-SHOPS]^7 item inexistente em " .. ShopId .. ": " .. tostring(Entry.Item))
        else
            Products[#Products + 1] = {
                id       = Entry.Item,
                name     = Framework.ItemName(Entry.Item),
                image    = ItemsURL .. Framework.ItemIndex(Entry.Item) .. ".png",
                price    = Entry.Price,
                stock    = -1,
                category = Entry.Category or "all",
            }
        end
    end

    CatalogCache[ShopId] = {
        shop = {
            id       = ShopId,
            label    = Shop.Title,
            subtitle = Shop.Description,
        },
        categories = Categories,
        products   = Products,
    }

    return CatalogCache[ShopId]
end
