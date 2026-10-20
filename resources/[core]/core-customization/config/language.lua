-----------------------------------------------------------------------------------------------------------------------------------------
-- IDIOMAS
-- Todos os textos do script. Idioma ativo em Customization.Language (config.lua).
-- Placeholders no formato {var}. Pra adicionar um idioma, copie um bloco e
-- traduza os VALORES (não as chaves).
-----------------------------------------------------------------------------------------------------------------------------------------
local Languages = {
    ["pt-BR"] = {
        -- Interação
        clothesLabel      = "Trocar Roupas",
        tattooLabel       = "Fazer Tatuagem",

        -- Loja de roupas
        clothesLoading    = "Aguarde alguns instantes até que o sistema esteja pronto.",
        clothesInVehicle  = "Você não pode trocar de roupa dentro do veículo.",
        clothesUniform    = "Você não pode utilizar a loja de roupas de uniforme.",
        clothesBlocked    = "Você não pode usar essa roupa.",
        clothesLocked     = "Você não pode alterar seu uniforme.",
        clothesNoItem     = "Você não possui <b>Roupas Secundárias</b> na mochila.",
        clothesSaved      = "Roupas salvas.",

        -- Loja de tatuagem
        tattooSaved       = "Tatuagens salvas.",
        tattooInvalid     = "Tatuagem inválida.",

        -- Comandos
        commandNoTarget   = "Jogador não disponível.",
        presetCopied      = "Roupas prontas:",
    },

    ["en-US"] = {
        -- Interaction
        clothesLabel      = "Change Clothes",
        tattooLabel       = "Get a Tattoo",

        -- Clothing store
        clothesLoading    = "Please wait until the system is ready.",
        clothesInVehicle  = "You can't change clothes inside a vehicle.",
        clothesUniform    = "You can't use the clothing store while in uniform.",
        clothesBlocked    = "You can't wear this piece.",
        clothesLocked     = "You can't change your uniform.",
        clothesNoItem     = "You don't have <b>Spare Clothes</b> in your backpack.",
        clothesSaved      = "Clothes saved.",

        -- Tattoo store
        tattooSaved       = "Tattoos saved.",
        tattooInvalid     = "Invalid tattoo.",

        -- Commands
        commandNoTarget   = "Player not available.",
        presetCopied      = "Outfit commands:",
    },
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOCALE
-----------------------------------------------------------------------------------------------------------------------------------------
Locale = Languages[Customization.Language] or Languages["pt-BR"]
-----------------------------------------------------------------------------------------------------------------------------------------
-- L
-----------------------------------------------------------------------------------------------------------------------------------------
-- L("clothesNoItem") ou L("selectPrice", { price = 30 }) para os placeholders.
function L(key, args)
    local text = Locale[key] or key

    if args then
        for name, value in pairs(args) do
            text = text:gsub("{"..name.."}", tostring(value))
        end
    end

    return text
end
