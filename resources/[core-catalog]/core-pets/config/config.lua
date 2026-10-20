-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-PETS · CONFIGURAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Coleção de pelúcias com loja de diamantes e trocas entre jogadores.
--
-- Outros arquivos da pasta config/:
--   language.lua  → todos os textos/idiomas da NUI e notificações
--   catalog.lua   → catálogo de pelúcias (modelos, ícones, props, preço)
--   webhooks.lua  → logs de Discord
--
-- Índice deste arquivo:
--   1. Identidade & Acesso
--   2. Aparência & Idioma
--   3. Funcionalidades
--   4. Loja (economia)
-----------------------------------------------------------------------------------------------------------------------------------------

Pets = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 1. IDENTIDADE & ACESSO
-----------------------------------------------------------------------------------------------------------------------------------------
Pets.Command         = "pets"     -- comando que abre o painel
Pets.AdminCommand    = "petsadm"  -- comando do painel admin
Pets.AdminPermission = "Admin"    -- grupo/permissão exigido pelo admin

-----------------------------------------------------------------------------------------------------------------------------------------
-- 2. APARÊNCIA & IDIOMA
-----------------------------------------------------------------------------------------------------------------------------------------
-- Cores de destaque da NUI, do mais claro pro mais escuro (mesma matiz).
-- Só primaryColor é obrigatória: as outras duas, se você apagar ou deixar
-- vazias, saem dela automaticamente — secondary a 71% e thirdy a 46% do
-- brilho da primária. Os valores abaixo são exatamente esse cálculo.
Pets.Colors = {
    primaryColor   = "#df155b",
    secondaryColor = "#9e0e40",
    thirdyColor    = "#660929"
}

-- Logo do painel (topo do menu e do admin). Vazio = logo Core padrão (SVG).
-- Para trocar, coloque o link direto de um PNG. Ex: "https://i.imgur.com/xxxx.png"
Pets.LogoUrl = ""

-- Idioma ativo (chave em config/language.lua). Todos os textos saem de lá.
Pets.Language = "pt-BR"

-----------------------------------------------------------------------------------------------------------------------------------------
-- 3. FUNCIONALIDADES
-----------------------------------------------------------------------------------------------------------------------------------------
-- Liga/desliga subsistemas. Desligado = some da NUI e os handlers rejeitam.
Pets.Features = {
    Trade = true,   -- aba Trocas
}

-- Pelúcia equipada aparece pra todo mundo, mas como objeto LOCAL: quem equipa
-- cria o dele e cada outro jogador cria a própria cópia. Nenhuma vira entidade
-- de rede, então todo objeto de rede com modelo do catálogo é sobra (versão
-- antiga, troca de dimensão, logout) e pode ser apagado. Ligado, o servidor
-- varre e limpa a cada 5 min. Só desligue se outro script spawnar esses modelos.
Pets.CleanupOrphanProps = true

-----------------------------------------------------------------------------------------------------------------------------------------
-- 4. LOJA (ECONOMIA)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Comprar/testar pelúcia na tela de detalhe. Buy e Test são independentes
-- (cada um esconde seu botão na NUI quando desligado). Diamantes = MOEDA, não item.
Pets.Shop = {
    Buy          = true,   -- habilita COMPRAR
    Test         = true,   -- habilita TESTAR (preview temporário)
    TestDuration = 15,     -- segundos do preview
    TestCooldown = 30,     -- cooldown entre testes (0 = sem)

    -- true = moeda premium do framework (Framework.Coins, ex. Gemstone do vRP — pronto).
    -- false = Diamantes próprios do resource, persistidos em CoinDataKey.
    UseFrameworkCoins = true,
    CoinDataKey       = "pets_diamonds",

    -- Preço em Diamantes usado quando a pelúcia não define `price`
    -- na sua entrada do config/catalog.lua.
    DefaultPrice = 120,
}
