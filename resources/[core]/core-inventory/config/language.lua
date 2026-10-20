-----------------------------------------------------------------------------------------------------------------------------------------
-- LANGUAGES
-----------------------------------------------------------------------------------------------------------------------------------------
local Languages = {
    ["pt-BR"] = {
        inventory = "Inventario",
        chest = "Bau",
        chestDescription = "Armazenamento compartilhado",
        inspect = "Jogador",
        inspectDescription = "Itens da pessoa revistada",
        property = "Propriedade",
        trunk = "Porta-Malas",
        ground = "Chao",
        backpackEquipped = "Mochila acoplada.",
        backpackFull = "Voce ja esta com a capacidade maxima.",
        ammoMismatch = "Essa municao nao serve nesse armamento.",
        ammoFull = "O armamento ja esta com o pente cheio.",
        attachPolice = "Acessorio de uso exclusivo policial.",
        attachUnsupported = "O armamento nao possui suporte ao componente.",
        attachDuplicated = "O armamento ja possui um componente equipado.",
        attachEmpty = "O armamento nao possui acessorios.",
        overweight = "Mochila sobrecarregada.",
        lunchbagFood = "A lancheira guarda somente alimentos.",
        lunchbagFull = "A lancheira esta cheia."
    }
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- LOCALE
-----------------------------------------------------------------------------------------------------------------------------------------
InventoryLocale = Languages[Inventory.General.Language] or Languages["pt-BR"]
