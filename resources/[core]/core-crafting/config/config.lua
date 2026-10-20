-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CRAFTING · CONFIGURAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Bancadas de fabricação com interface própria. Cada jogador tem uma fila de
-- produção que continua correndo com ele offline e só entrega os itens quando
-- ele coleta na bancada.
-----------------------------------------------------------------------------------------------------------------------------------------
-- Outros arquivos da pasta config/:
--   stations.lua → bancadas espalhadas no mapa
--   recipes.lua  → receitas agrupadas por categoria
--   language.lua → textos e notificações do resource
-----------------------------------------------------------------------------------------------------------------------------------------
-- Índice deste arquivo:
--   1. Interface & Interação
--   2. Regras de fabricação
--   3. Cache da fila
-----------------------------------------------------------------------------------------------------------------------------------------

Crafting = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 1. INTERFACE & INTERAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Distance em metros. Icon usa o catálogo do sleepless_interact.
Crafting.Interaction = {
    Icon     = "hammer",
    Distance = 2.0,
}

-- Distância máxima, em metros, entre o jogador e a bancada em qualquer ação.
-- Revalidada no servidor a cada pedido da interface.
Crafting.MaxDistance = 5.0

-- Cores enviadas para a interface no momento em que ela abre.
Crafting.Colors = {
    primaryColor   = "#df1553",
    secondaryColor = "#9e0f3c",
    thirdyColor    = "#670a27",
}

-- Espaços de ingrediente que a interface desenha por receita. Receitas com mais
-- ingredientes que isso são avisadas no console durante a validação da config.
Crafting.MaxIngredients = 8

-----------------------------------------------------------------------------------------------------------------------------------------
-- 2. REGRAS DE FABRICAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
-- MaxEntries: produções em andamento por jogador, somando todas as bancadas.
-- MaxAmount:  fabricações por pedido (mesmo teto usado pela interface).
-- Refund:     cancelar uma produção devolve os materiais gastos.
Crafting.Queue = {
    MaxEntries = 5,
    MaxAmount  = 50,
    Refund     = true,
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 3. CACHE DA FILA
-----------------------------------------------------------------------------------------------------------------------------------------
-- A fila fica em memória enquanto o jogador está conectado: abrir a bancada,
-- fabricar e coletar não consultam o banco. A gravação é agrupada, então uma
-- sequência de ações vira uma única escrita.
--   SaveInterval → segundos entre gravações das filas alteradas
Crafting.Cache = {
    SaveInterval = 2,
}
