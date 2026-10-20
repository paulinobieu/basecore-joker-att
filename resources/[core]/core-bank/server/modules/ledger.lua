-----------------------------------------------------------------------------------------------------------------------------------------
-- EXTRATO
-- Uma linha por movimento, cobrindo os dois lados. A conta 0 representa o
-- mundo fora do banco: dinheiro em mãos, sistema, corretora.
-----------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------
-- RECORD
-----------------------------------------------------------------------------------------------------------------------------------------
function Record(PayerId, PayeeId, Type, Amount, Description, Author)
    InsertTransaction(
        PayerId or 0,
        PayeeId or 0,
        Type,
        Amount,
        LimitText(Description, 96),
        LimitText(Author, 64),
        Now()
    )
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDSTATEMENT
-- Direção resolvida no servidor: a interface só desenha.
-----------------------------------------------------------------------------------------------------------------------------------------
local function Normalize(Rows, AccountId)
    local Result = {}

    for _, Row in ipairs(Rows) do
        local Outgoing = parseInt(Row.payer_id) == AccountId

        Result[#Result + 1] = {
            id          = parseInt(Row.id),
            type        = Row.type,
            amount      = parseInt(Row.amount),
            description = Row.description,
            author      = Row.author,
            date        = parseInt(Row.created_at),
            outgoing    = Outgoing,
        }
    end

    return Result
end

function BuildStatement(AccountId, Type)
    if Type then
        return Normalize(FindTransactionsByType(AccountId, Type, Bank.PageSize), AccountId)
    end

    return Normalize(FindTransactions(AccountId, Bank.PageSize), AccountId)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SNAPSHOT
-- Fecha o saldo do dia sempre que a conta se movimenta. Chave é o dia, então
-- gravar várias vezes no mesmo dia só sobrescreve.
-----------------------------------------------------------------------------------------------------------------------------------------
function Snapshot(Account)
    SaveChartPoint(Today(), parseInt(Account.id), BalanceOf(Account))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BUILDCHART
-----------------------------------------------------------------------------------------------------------------------------------------
function BuildChart(AccountId)
    local Rows = FindChart(AccountId, Bank.ChartDays)
    local Result = {}

    -- A consulta vem do dia mais novo para o mais antigo.
    for Index = #Rows, 1, -1 do
        Result[#Result + 1] = {
            day     = parseInt(Rows[Index].day),
            balance = parseInt(Rows[Index].balance),
        }
    end

    return Result
end
