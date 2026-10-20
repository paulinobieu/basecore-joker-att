-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-LOVE · CONFIGURAÇÃO
-- Namoro, noivado, casamento, separação e o correio do amor.
-- Textos e notificações ficam em config/language.lua.
-----------------------------------------------------------------------------------------------------------------------------------------

Love = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 1. ACESSO
-----------------------------------------------------------------------------------------------------------------------------------------
Love.Command = "love"  -- comando que abre o painel

-----------------------------------------------------------------------------------------------------------------------------------------
-- 2. APARÊNCIA & IDIOMA
-----------------------------------------------------------------------------------------------------------------------------------------
-- Nome e logo que aparecem no topo do painel. O nome também assina as
-- notificações e o anúncio no chat. LogoUrl vazio = logo padrão da interface.
Love.Brand = {
    Title   = "Corelove",
    LogoUrl = "",
}

-- Cores da interface, em HEX.
Love.Colors = {
    primaryColor   = "#D96C8F",
    secondaryColor = "#FFF0F3",
    thirdyColor    = "#EC7FA0",
}

Love.Language = "pt-BR"  -- chave do idioma em config/language.lua

-----------------------------------------------------------------------------------------------------------------------------------------
-- 3. PEDIDOS
-----------------------------------------------------------------------------------------------------------------------------------------
Love.Request = {
    MaxDistance = 3.0,    -- metros máximos entre as duas pessoas
    Timeout     = 20000,  -- ms que o pedido fica na tela de quem recebe
    Cooldown    = 10000,  -- ms entre dois pedidos do mesmo jogador
    AcceptKey   = "Y",    -- tecla de aceitar (o jogador pode trocar no FiveM)
    RefuseKey   = "U",    -- tecla de recusar
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 4. ETAPAS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Cada pedido só sai de um status de From e leva o casal para To.
-- RequiresPartner: true = o alvo tem que ser o par atual, false = tem que estar solteiro.
-- Os nomes são o contrato com a interface: não renomeie.
Love.Flow = {
    dating     = { From = { "single" },                       To = "dating",  RequiresPartner = false },
    engagement = { From = { "dating" },                       To = "engaged", RequiresPartner = true },
    marriage   = { From = { "engaged" },                      To = "married", RequiresPartner = true },
    separation = { From = { "dating", "engaged", "married" }, To = "single",  RequiresPartner = true },
}

-- false = a separação acontece na hora, sem pedir o aceite do parceiro.
Love.SeparationRequiresConsent = true

-----------------------------------------------------------------------------------------------------------------------------------------
-- 5. ANÚNCIO GLOBAL
-----------------------------------------------------------------------------------------------------------------------------------------
-- Etapas que viram anúncio no chat de todo mundo.
-- Quem envia é Framework.OnRelationshipChanged, em server/framework.lua.
Love.Announce = {
    dating  = true,
    engaged = true,
    married = true,
    single  = false,
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 6. CORREIO DO AMOR
-----------------------------------------------------------------------------------------------------------------------------------------
Love.Mail = {
    MaxLength      = 320,               -- máximo de caracteres por carta
    InboxLimit     = 30,                -- cartas guardadas por pessoa
    Cooldown       = 30000,             -- ms entre duas cartas do mesmo jogador
    RequirePartner = false,             -- true = só escreve para o próprio par
    DateFormat     = "%d/%m · %H:%M",   -- data exibida na carta
}
