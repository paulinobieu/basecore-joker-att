-----------------------------------------------------------------------------------------------------------------------------------------
-- IDIOMAS
-- Todos os textos do script. Idioma ativo em Character.Language (config.lua).
-- Placeholders no formato {var}. Pra adicionar um idioma, copie um bloco e
-- traduza os VALORES (não as chaves).
-----------------------------------------------------------------------------------------------------------------------------------------
local Languages = {
    ["pt-BR"] = {
        -- Seleção de personagem
        selectSlotBought   = "Você comprou um novo slot de personagem.",
        selectSlotNoFunds  = "Você não possui {price} moedas para comprar o slot.",
        selectSlotMax      = "Você já atingiu o limite de personagens.",
        selectInvalidChar  = "Personagem inválido.",
        selectLicenseFail  = "License não reconhecida, relogue.",
        selectCharacterFail = "Seu personagem está com problemas, informe à administração.",

        -- Criação
        createInvalidName  = "Nome ou sobrenome inválido.",

        -- Barbearia
        barberSaved        = "Alterações salvas.",
        barberDiscarded    = "Alterações descartadas.",
        barberNoPermission = "Sem permissão para acessar a barbearia.",
        barberLabel        = "Acessar Barbearia",

        -- Spawn
        spawnLastLocation  = "Última Localização",
        spawnInvalid       = "Localização inválida.",

        -- Comandos administrativos
        commandNoTarget    = "Jogador não disponível.",
        resetSent          = "Personagem {id} enviado para o criador.",
    },

    ["en-US"] = {
        -- Character selection
        selectSlotBought   = "You bought a new character slot.",
        selectSlotNoFunds  = "You don't have {price} coins to buy the slot.",
        selectSlotMax      = "You already reached the character limit.",
        selectInvalidChar  = "Invalid character.",
        selectLicenseFail  = "License not recognized, please relog.",
        selectCharacterFail = "Your character has issues, contact the staff.",

        -- Creation
        createInvalidName  = "Invalid first or last name.",

        -- Barbershop
        barberSaved        = "Changes saved.",
        barberDiscarded    = "Changes discarded.",
        barberNoPermission = "No permission to use the barbershop.",
        barberLabel        = "Open Barbershop",

        -- Spawn
        spawnLastLocation  = "Last Location",
        spawnInvalid       = "Invalid location.",

        -- Admin commands
        commandNoTarget    = "Player not available.",
        resetSent          = "Character {id} sent back to the creator.",
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- RESOLUÇÃO
-- Expõe os globais Locale (dicionário do idioma ativo) e L(key, vars) (interpola {var}).
-----------------------------------------------------------------------------------------------------------------------------------------
Locale = Languages[Character.Language] or Languages["pt-BR"] or {}

function L(key, vars)
    local str = Locale[key] or key
    if vars then
        str = str:gsub("{(%w+)}", function(name)
            local v = vars[name]
            return v ~= nil and tostring(v) or ("{" .. name .. "}")
        end)
    end
    return str
end
