-----------------------------------------------------------------------------------------------------------------------------------------
-- IDIOMA
-----------------------------------------------------------------------------------------------------------------------------------------
-- Todos os textos devolvidos pelo servidor à interface. Traduza só os valores
-- à direita. %s e %d são substituídos em tempo de execução — mantenha-os.
-----------------------------------------------------------------------------------------------------------------------------------------
Bank.Language = {
    -------------------------------------------------------------------------------------------------------------------------------------
    -- GERAL
    -------------------------------------------------------------------------------------------------------------------------------------
    --- Título das notificações que o banco manda para o HUD.
    Title           = "Banco",

    InvalidAmount   = "Valor inválido.",
    InvalidAccount  = "Conta indisponível.",
    NoAccess        = "Você não tem acesso a essa conta.",
    NoFunds         = "Saldo insuficiente.",
    Busy            = "Aguarde a operação anterior terminar.",
    Failed          = "O banco não conseguiu concluir a operação.",

    -------------------------------------------------------------------------------------------------------------------------------------
    -- CAIXA
    -------------------------------------------------------------------------------------------------------------------------------------
    NoCash          = "Você não tem esse dinheiro em mãos.",
    NoPocketSpace   = "Você não tem espaço para carregar esse dinheiro.",
    Deposited       = "Depósito de R$ %s realizado.",
    Withdrawn       = "Saque de R$ %s realizado.",

    -------------------------------------------------------------------------------------------------------------------------------------
    -- TRANSFERÊNCIAS E PIX
    -------------------------------------------------------------------------------------------------------------------------------------
    SameAccount     = "A conta de destino é a mesma de origem.",
    TargetNotFound  = "Não encontramos essa conta de destino.",
    Transferred     = "R$ %s enviados para %s.",
    Received        = "Você recebeu R$ %s de %s.",

    PixKeyTaken     = "Essa chave já está em uso.",
    PixKeyInvalid   = "Use de %d a %d caracteres, apenas letras, números, ponto e traço.",
    PixKeyLimit     = "Essa conta já tem o máximo de %d chaves.",
    PixKeyCreated   = "Chave %s cadastrada.",
    PixKeyRemoved   = "Chave removida.",

    -------------------------------------------------------------------------------------------------------------------------------------
    -- CONTAS E SOCIEDADE
    -------------------------------------------------------------------------------------------------------------------------------------
    NameInvalid     = "O nome da empresa precisa ter de %d a %d caracteres.",
    BusinessLimit   = "Você já tem o máximo de %d empresas.",
    BusinessCreated = "Empresa %s aberta.",
    NotOwner        = "Só o dono da empresa pode fazer isso.",
    MemberLimit     = "Essa empresa já tem o máximo de %d sócios.",
    MemberExists    = "Esse passaporte já faz parte da empresa.",
    MemberInvited   = "Convite enviado para %s.",
    MemberRemoved   = "Sócio removido.",
    InviteMissing   = "Convite indisponível.",
    InviteAccepted  = "Você entrou em %s.",
    InviteRejected  = "Convite recusado.",

    -------------------------------------------------------------------------------------------------------------------------------------
    -- FATURAS
    -------------------------------------------------------------------------------------------------------------------------------------
    ReasonInvalid   = "O motivo precisa ter de %d a %d caracteres.",
    InvoiceLimit    = "Você já tem %d faturas em aberto.",
    InvoiceSent     = "Fatura de R$ %s enviada para %s.",
    InvoiceIncoming = "%s te cobrou R$ %s.",
    InvoicePaid     = "Fatura de R$ %s quitada.",
    InvoiceMissing  = "Fatura indisponível.",
    InvoiceCanceled = "Fatura cancelada.",

    -------------------------------------------------------------------------------------------------------------------------------------
    -- MULTAS
    -------------------------------------------------------------------------------------------------------------------------------------
    FineMissing     = "Multa indisponível.",
    FinePaid        = "Multa de R$ %s paga.",
    FineIncoming    = "Você recebeu uma multa de R$ %s.",

    -------------------------------------------------------------------------------------------------------------------------------------
    -- INVESTIMENTOS
    -------------------------------------------------------------------------------------------------------------------------------------
    ProductMissing  = "Aplicação indisponível.",
    ProductMinimum  = "A aplicação mínima é de R$ %s.",
    ProductMaximum  = "O teto dessa aplicação é de R$ %s.",
    Invested        = "R$ %s aplicados em %s.",
    RedeemLocked    = "Resgate antes do prazo: você perde parte do rendimento.",
    Redeemed        = "Resgate de R$ %s concluído.",
    PositionMissing = "Aplicação não encontrada.",

    -------------------------------------------------------------------------------------------------------------------------------------
    -- CRIPTOMOEDAS
    -------------------------------------------------------------------------------------------------------------------------------------
    AssetMissing    = "Moeda indisponível.",
    QuoteStale      = "Cotação desatualizada. Tente de novo em instantes.",
    TradeMinimum    = "A negociação mínima é de R$ %s.",
    NoAsset         = "Você não tem essa quantidade na carteira.",
    Bought          = "Compra de %s %s concluída.",
    Sold            = "Venda de %s %s concluída.",
}
