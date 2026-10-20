-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-BANK · INVESTIMENTOS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Catálogo de aplicações. As alíquotas são fixas no servidor: nada aqui
-- consulta mercado externo.
--
-- Campos de cada aplicação:
--   Code        → chave interna, imutável. É o que fica gravado na aplicação.
--   Name        → nome exibido na interface.
--   Description → uma linha explicando o produto.
--   Rate        → rendimento por ciclo, em fração (0.0115 = 1,15%).
--   Cycle       → duração do ciclo, em horas.
--   Lock        → carência antes de poder resgatar, em horas. 0 libera na hora.
--   Minimum     → aplicação mínima, em R$.
--   Maximum     → teto por aplicação, em R$. 0 remove o teto.
--   Penalty     → fração do rendimento perdida ao resgatar dentro da carência.
--
-- Para criar uma aplicação nova basta acrescentar uma entrada com Code novo.
-----------------------------------------------------------------------------------------------------------------------------------------

Bank.Investments = {
    {
        Code        = "poupanca",
        Name        = "Poupança",
        Description = "Rende pouco, mas o dinheiro sai quando você quiser.",
        Rate        = 0.004,
        Cycle       = 24,
        Lock        = 0,
        Minimum     = 500,
        Maximum     = 0,
        Penalty     = 0.0,
    },
    {
        Code        = "cdb",
        Name        = "CDB 115%",
        Description = "O clássico do banco: rende todo dia e libera em três dias.",
        Rate        = 0.0115,
        Cycle       = 24,
        Lock        = 72,
        Minimum     = 5000,
        Maximum     = 0,
        Penalty     = 0.5,
    },
    {
        Code        = "tesouro",
        Name        = "Tesouro Los Santos",
        Description = "Título do governo. Paga mais, mas prende o dinheiro por uma semana.",
        Rate        = 0.021,
        Cycle       = 24,
        Lock        = 168,
        Minimum     = 25000,
        Maximum     = 5000000,
        Penalty     = 1.0,
    },
    {
        Code        = "imobiliario",
        Name        = "Fundo Imobiliário",
        Description = "Aluguéis da cidade caindo na sua conta a cada doze horas.",
        Rate        = 0.008,
        Cycle       = 12,
        Lock        = 48,
        Minimum     = 10000,
        Maximum     = 2000000,
        Penalty     = 0.35,
    },
}
