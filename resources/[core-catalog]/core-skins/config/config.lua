-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-SKINS · CONFIGURAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Skins de armas com caixas, loja, trocas, aprimoramento e ranking.
--
-- Outros arquivos da pasta config/:
--   language.lua  → todos os textos/idiomas das notificações
--   weapons.lua   → catálogo de armas e skins (modelo, raridade, preço)
--   cases.lua     → caixas e o que cada uma sorteia
--   webhooks.lua  → logs de Discord
--
-- Índice deste arquivo:
--   1. Identidade & Acesso
--   2. Aparência & Idioma
--   3. Economia (moedas)
--   4. Caixas & Prêmios
--   5. Compra de skins (durações)
--   6. Trocas
--   7. Aprimoramento
--   8. Teste de arma
--   9. Inspeção 3D
--  10. Banco de dados
-----------------------------------------------------------------------------------------------------------------------------------------

Skins = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 1. IDENTIDADE & ACESSO
-----------------------------------------------------------------------------------------------------------------------------------------
Skins.Command         = "skins"     -- comando que abre o painel
Skins.AdminCommand    = "skinsadm"  -- comando do painel admin
Skins.AdminPermission = "Admin"     -- permissão exigida pelo admin. Aceita "Admin",
                                    -- "grupo@nível" (ex: "Admin@1") ou uma lista de permissões.

-----------------------------------------------------------------------------------------------------------------------------------------
-- 2. APARÊNCIA & IDIOMA
-----------------------------------------------------------------------------------------------------------------------------------------
-- Cores de destaque da NUI. Só primaryColor é obrigatória: as outras duas, se você
-- apagar ou deixar vazias, saem dela automaticamente girando a matiz (secundária
-- +120°, terciária +60°) e mantendo saturação e brilho.
Skins.Colors = {
    primaryColor   = "#0095f3",
    secondaryColor = "",
    thirdColor     = "",
}

-- Logo do painel. Vazio = logo padrão da interface.
Skins.LogoUrl = ""

-- Banner do topo do painel. Vazio = banner padrão da interface.
Skins.BannerUrl = ""

-- Link da loja onde o jogador compra SkinsCoins (botão "comprar moedas").
-- Vazio = o botão some da NUI.
Skins.ShopUrl = ""

-- Idioma ativo (chave em config/language.lua). Todos os textos saem de lá.
Skins.Language = "pt-BR"

-- Liga a raridade interna de cada skin (config/weapons.lua) ao texto exibido na NUI.
Skins.RarityMap = {
    common    = "comum",
    rare      = "raro",
    epic      = "epico",
    legendary = "lendario",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 3. ECONOMIA (MOEDAS)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SkinsCoins = moeda das caixas/loja. Vouchers = taxa cobrada nas trocas.
Skins.Economy = {
    -- true  = usa a moeda premium do framework (Framework.Coins, ex. Gemstone do vRP).
    -- false = usa o SkinsCoins interno, persistido na chave CoinDataKey abaixo.
    UseFrameworkCoins = false,

    -- Chaves de dado persistente por personagem. Só troque se colidir com outra
    -- chave já usada no seu servidor.
    CoinDataKey    = "core_skins:skinsCoins",
    VoucherDataKey = "core_skins:vouchers",
    DailyDataKey   = "core_skins:dailyCases",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 4. CAIXAS & PRÊMIOS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Quantas vitórias recentes ficam no feed de "últimas vitórias" da NUI.
Skins.LastWinsSize = 20

-- Quantas posições o ranking devolve por período.
Skins.RankingLimit = 20

-----------------------------------------------------------------------------------------------------------------------------------------
-- 5. COMPRA DE SKINS (DURAÇÕES)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Opções de período que aparecem na compra de uma skin. Cada opção tem:
--   id    = identificador interno da opção (não repita).
--   label = texto mostrado pro jogador.
--   days  = duração em dias; 0 = permanente (a skin não expira).
--   price = preço fixo em SkinsCoins da opção; nil usa o preço base da skin
--           definido no config/weapons.lua.
-- Uma skin pode sobrescrever essa lista com o campo `durations` dela.
Skins.Durations = {
    { id = "7d",   label = "7 Dias",     days = 7,  price = 5000 },
    { id = "30d",  label = "30 Dias",    days = 30, price = 15000 },
    { id = "perm", label = "Permanente", days = 0,  price = nil },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 6. TROCAS
-----------------------------------------------------------------------------------------------------------------------------------------
Skins.Trade = {
    -- Validade de uma proposta, em ms. Passou disso sem aceitar, ela expira. (24h)
    ExpireMs = 86400000,

    -- Taxa em vouchers cobrada de quem RECEBE cada skin, proporcional ao preço dela.
    -- 0.02 = 2% do preço vira custo. 0 = trocas sem custo de voucher.
    VoucherRate = 0.02,

    -- De quanto em quanto tempo (ms) o script varre e expira as propostas vencidas.
    SweepMs = 60000,

    -- Quantas propostas ficam guardadas em memória (as mais antigas saem).
    HistoryLimit = 50,
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 7. APRIMORAMENTO
-----------------------------------------------------------------------------------------------------------------------------------------
-- O jogador aposta skins (e opcionalmente SkinsCoins) tentando trocá-las por uma
-- skin de maior valor, com chance baseada nos valores envolvidos.
Skins.Improvement = {
    Enabled           = true,   -- desligado, a aba some da NUI e o server recusa
    RequirePlayerSkin = true,   -- exige ao menos uma skin própria na aposta

    -- Curva da chance: (valor investido / valor do alvo) ^ ChanceExponent.
    -- Maior = mais difícil mirar em skins muito acima.
    ChanceExponent = 1.5,

    MinChance = 1,    -- chance mínima (%), mesmo em apostas ruins
    MaxChance = 95,   -- chance máxima (%), mesmo em apostas ótimas

    -- Faixa de valor do alvo. 1.2 = o alvo precisa valer no mínimo 20% a mais do
    -- que foi apostado; 5.0 = no máximo 5x o que foi apostado.
    MinTargetMarkup = 1.2,
    MaxTargetMarkup = 5.0,
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 8. TESTE DE ARMA
-----------------------------------------------------------------------------------------------------------------------------------------
-- O jogador é levado (isolado em um bucket próprio) pra uma área de tiro, com a
-- arma da skin, por tempo limitado.
Skins.WeaponTest = {
    -- Desligado, o botão "Testar" some da NUI e o server recusa qualquer tentativa;
    -- o jogador só consegue inspecionar o modelo 3D.
    Enabled = true,

    Coords     = vec4(13.57, -1097.23, 29.82, 343.0), -- destino (x, y, z, heading)
    Ammo       = 250,    -- munição entregue
    MaxRadius  = 30.0,   -- distância máxima do ponto antes de encerrar (metros)
    MaxSeconds = 600,    -- duração máxima do teste
    ExitKey    = 177,    -- tecla pra sair antes do tempo (177 = Backspace)

    -- Somado ao id do jogador pra criar um routing bucket exclusivo. Só mude se
    -- colidir com buckets usados por outro sistema.
    BucketOffset = 75000,
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 9. INSPEÇÃO 3D
-----------------------------------------------------------------------------------------------------------------------------------------
Skins.Preview = {
    -- Graus por pixel de mouse arrastado. Maior = gira mais rápido com menos
    -- arrasto. Padrão 0.35 (~180° a cada ~510px). Comuns: 0.2 (lento) a 0.6 (rápido).
    RotationSpeed = 0.35,
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 10. BANCO DE DADOS
-----------------------------------------------------------------------------------------------------------------------------------------
Skins.Database = {
    -- De quanto em quanto tempo (ms) as skins alteradas em memória vão pro banco.
    -- Menor = grava mais vezes; maior = menos escrita.
    SyncInterval = 60000 * 5,

    -- Teto de cada agendamento de expiração (ms). Mantém o timer seguro para
    -- valores grandes e re-checa as expirações distantes; as próximas disparam na
    -- hora exata. Normalmente não precisa mexer. (24h)
    ExpireMaxScheduleMs = 86400000,
}
