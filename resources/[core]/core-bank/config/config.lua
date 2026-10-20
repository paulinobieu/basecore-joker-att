-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-BANK · CONFIGURAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Banco do servidor: contas pessoais e empresariais, PIX, transferências,
-- extrato, faturas, multas, investimentos e criptomoedas.
-----------------------------------------------------------------------------------------------------------------------------------------
-- Outros arquivos da pasta config/:
--   investments.lua  → catálogo de aplicações e suas alíquotas fixas
--   cryptos.lua      → allowlist de criptomoedas e provedor de cotação
--   language.lua     → textos e notificações do resource
-----------------------------------------------------------------------------------------------------------------------------------------
-- Índice deste arquivo:
--   1. Identidade & Acesso
--   2. Contas
--   3. PIX
--   4. Movimentação
--   5. Faturas
--   6. Multas
-----------------------------------------------------------------------------------------------------------------------------------------

Bank = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 1. IDENTIDADE & ACESSO
-----------------------------------------------------------------------------------------------------------------------------------------
--- Cor da interface. Theme.main (vrp/config/Global.lua) tem prioridade quando definido.
Bank.ThemeColor = "#dc1553"

--- Balcões onde a interface pode ser aberta.
Bank.Locations = {
    vec3(149.64, -1041.36, 29.59),
    vec3(313.95, -279.74, 54.39),
    vec3(-351.2, -50.57, 49.26),
    vec3(-2961.85, 482.87, 15.92),
    vec3(1175.09, 2707.53, 38.31),
    vec3(-1212.37, -331.37, 38.0),
    vec3(-112.86, 6470.46, 31.85),
}

Bank.Interaction = {
    Label  = "Abrir Banco",
    Icon   = "fa-solid fa-building-columns",
    Radius = 1.75,
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 2. CONTAS
-- A conta pessoal espelha o saldo bancário da vRP. Empresas guardam o próprio
-- saldo e podem ter sócios.
-----------------------------------------------------------------------------------------------------------------------------------------
Bank.Accounts = {
    --- Custo, em R$, para abrir uma empresa.
    BusinessPrice = 250000,

    --- Quantas empresas um passaporte pode ter como dono.
    MaxBusiness = 3,

    --- Sócios por empresa, sem contar o dono.
    MaxMembers = 9,

    --- Limites do nome da empresa, em caracteres.
    NameLength = { Min = 3, Max = 32 },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 3. PIX
-- A chave é escolhida pelo jogador e precisa ser única no servidor inteiro.
-----------------------------------------------------------------------------------------------------------------------------------------
Bank.Pix = {
    --- Chaves por conta.
    MaxKeys = 3,

    --- Limites da chave, em caracteres. Só letras, números, ponto e traço.
    KeyLength = { Min = 3, Max = 32 },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 4. MOVIMENTAÇÃO
-- Todo valor em R$ e sempre inteiro: centavos não existem na economia do jogo.
-----------------------------------------------------------------------------------------------------------------------------------------
Bank.Limits = {
    Deposit  = { Min = 1, Max = 10000000 },
    Withdraw = { Min = 1, Max = 10000000 },
    Transfer = { Min = 1, Max = 10000000 },
}

--- Como o dinheiro aparece na interface, antes do valor. Vale para o banco
--- inteiro: saldo, extrato, faturas, multas, aplicações e cotação de cripto.
Bank.Symbol = "R$"

--- Quantas linhas o extrato e as listas devolvem por consulta.
Bank.PageSize = 50

--- Dias de saldo guardados para o gráfico do resumo.
Bank.ChartDays = 14

-----------------------------------------------------------------------------------------------------------------------------------------
-- 5. FATURAS
-----------------------------------------------------------------------------------------------------------------------------------------
Bank.Invoices = {
    Amount        = { Min = 1, Max = 5000000 },
    ReasonLength  = { Min = 3, Max = 64 },

    --- Faturas em aberto que um passaporte pode ter emitido ao mesmo tempo.
    MaxPending = 10,
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 6. MULTAS E IMPOSTOS
-- O banco não aplica nenhum dos dois: ele cobra. Multas entram pelo export
-- AddFine (usado pelo MDT) e impostos pelo export AddTaxes (usado pelas
-- propriedades). Imposto vira uma fatura emitida pelo sistema.
-----------------------------------------------------------------------------------------------------------------------------------------
Bank.Fines = {
    Amount = { Min = 1, Max = 5000000 },
}

Bank.Taxes = {
    --- Fração cobrada sobre o valor que o resource informa ao AddTaxes.
    Rate = 0.10,

    --- Desconto por VIP: quanto menor o multiplicador, maior o desconto.
    --- Vale o primeiro vínculo encontrado na ordem desta lista.
    VipDiscounts = {
        { Permission = "Ouro",   Multiplier = 0.65 },
        { Permission = "Prata",  Multiplier = 0.75 },
        { Permission = "Bronze", Multiplier = 0.85 },
    },

    --- Nome que aparece na fatura do imposto quando o resource não informa um.
    Label = "Imposto",
}

--- Carência, em horas, antes de uma dívida bloquear loja e garagem.
--- Consultada pelos exports CheckFines e CheckTaxes.
Bank.DebtGrace = 24
