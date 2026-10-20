Laundry = {}

-- Cor hexadecimal padrão exibida nos painéis de lavagem
-- Pode ser sobrescrita individualmente em cada entrada de Laundry.Laundries
Laundry.DefaultThemeColor = "#dc1553"

-- Logo exibida no centro superior da tela enquanto o painel está aberto (link direto de imagem; "" desativa)
Laundry.Logo = "https://cdn.corenetwork.dev/IDCore/LOGO%20-%20BRANCO.png"

-----------------------------------------------------------------------------------------------------------------------------------------
-- MOEDA
-----------------------------------------------------------------------------------------------------------------------------------------

Laundry.Currency = {
    -- Prefixo exibido antes do valor monetário (ex: "R$ ", "$ ", "€ ")
    Prefix = "R$ ",
    -- Sufixo exibido após o valor monetário (ex: "", " BRL")
    Suffix = "",
    -- Separador de milhar (ex: "." para 1.000.000 ou "," para 1,000,000)
    Separator = ".",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- ADMINISTRAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------

Laundry.Admin = {
    -- Comando de chat para abrir o painel administrativo de máquinas
    Command = "laundryadmin",
    -- Permissão necessária para acessar o painel administrativo
    Permission = "Admin",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- LAVAGENS
-- Máquinas são gerenciadas dinamicamente pelo painel administrativo.
-- Não adicione entradas manualmente — use o painel admin in-game.
-----------------------------------------------------------------------------------------------------------------------------------------

Laundry.Laundries = {}
