-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-BOOSTER · CONFIGURAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Recompensas para quem dá boost na guild da cidade ou usa a tag do servidor.
-- O Discord é conferido no servidor toda vez que o painel abre e de tempos em
-- tempos: quem tira o boost ou a tag perde o que estiver vinculado.
-----------------------------------------------------------------------------------------------------------------------------------------
-- Outros arquivos da pasta config/:
--   bot.lua       → token e guild do bot do Discord
--   language.lua  → textos, notificações e rótulos da interface
-----------------------------------------------------------------------------------------------------------------------------------------
-- Índice deste arquivo:
--   1. Comandos
--   2. Interface
--   3. Benefícios
-----------------------------------------------------------------------------------------------------------------------------------------

Booster = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 1. COMANDOS
-----------------------------------------------------------------------------------------------------------------------------------------
Booster.Commands = {
    Open = "recompensas",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 2. INTERFACE
-----------------------------------------------------------------------------------------------------------------------------------------
-- Cor de destaque do painel. O benefício que declara Accent ignora estas cores
-- dentro do card dele.
Booster.Colors = {
    primaryColor   = "#6b89ff",
    secondaryColor = "#42559e",
    thirdyColor    = "#1e2647",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 3. BENEFÍCIOS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Cada entrada vira um card no painel.
--
--   Require → o que o jogador precisa ter: "boost", "tag" ou "both"
--   Icon    → rocket, bolt, tag, gift, crown, star, sparkles, money, vehicle, box, shield
--   Accent  → cor fixa do card em hex; remova para o card seguir Booster.Colors
--
-- Recompensas aceitas:
--   { Type = "bank",    Amount = 50000 }
--   { Type = "gems",    Amount = 10 }
--   { Type = "item",    Item = "medkit", Amount = 5 }
--   { Type = "vehicle", Model = "corehyper001" }
--
-- Dinheiro, diamantes e itens saem uma vez só e ficam com o jogador para
-- sempre, mesmo que ele perca o benefício depois. Veículo fica vinculado: sai
-- da garagem quando o boost ou a tag cai e volta a ficar disponível para
-- coletar se o jogador voltar a ter. Quem perde e recupera o benefício não
-- recebe de novo o que já é dele, só o que foi retirado.
Booster.Benefits = {
    {
        Id          = "boost",
        Title       = "Server Boost",
        Description = "Benefícios exclusivos para quem dá Boost no nosso servidor do Discord. Itens, veículos e saldo especiais!",
        Require     = "boost",
        Icon        = "rocket",
        Accent      = "#a855f7",
        Labels      = { Active = "Boost ativo", Inactive = "Boost inativo" },
        Rewards     = {
            { Type = "bank", Amount = 50000 },
            { Type = "gems", Amount = 10 },
            { Type = "vehicle", Model = "corehyper001" },
        },
    },
    {
        Id          = "tag",
        Title       = "Tag do Servidor",
        Description = "Recompensas para quem utiliza a tag do nosso servidor no Discord. Mantenha a tag ativa para manter o benefício!",
        Require     = "tag",
        Icon        = "tag",
        Labels      = { Active = "Tag ativa", Inactive = "Tag inativa" },
        Rewards     = {
            { Type = "bank", Amount = 25000 },
            { Type = "item", Item = "medkit", Amount = 5 },
        },
    },
}
