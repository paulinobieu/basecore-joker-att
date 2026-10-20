-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADING · CONFIGURAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Tudo que é visual ou textual fica neste arquivo. As consultas e adaptações
-- da base ficam abertas em server/framework.lua.
--
-- Font Awesome:
--   Use a classe completa do ícone, por exemplo "fa-solid fa-car".
--   Esta loading inclui localmente os estilos solid, regular e brands.
-----------------------------------------------------------------------------------------------------------------------------------------

Loading = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- CACHE
-----------------------------------------------------------------------------------------------------------------------------------------
-- Evita executar as consultas de ranking a cada conexão simultânea.
-- Use 0 para consultar o banco em toda conexão.
Loading.CacheSeconds = 120

-----------------------------------------------------------------------------------------------------------------------------------------
-- APARÊNCIA
-----------------------------------------------------------------------------------------------------------------------------------------
Loading.Appearance = {
    Accent          = "#dc1553",
    AccentSecondary = "#ff4f87",
    Text             = "#fff8fb",
    MutedText        = "rgba(255, 235, 243, 0.62)",
    Panel            = "rgba(13, 7, 11, 0.62)",
    PanelSoft        = "rgba(220, 21, 83, 0.14)",
    Overlay          = "rgba(16, 5, 10, 0.12)",
}

Loading.Texts = {
    PageTitle  = "Core Network",
    NowPlaying = "Tocando agora:",
    EmptyName  = "Sem dados",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNDO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Type aceita "video" ou "image". File pode ser um arquivo em web/assets
-- ou uma URL completa.
Loading.Background = {
    Type = "video",
    File = "video.webm",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- MÚSICAS
-----------------------------------------------------------------------------------------------------------------------------------------
-- File e Cover podem ser arquivos em web/assets ou URLs completas.
-- Playlist vazia esconde o player.
Loading.Audio = {
    Autoplay       = true,
    StartCollapsed = true, -- true = inicia no modo compacto
    Volume         = 0.50,
    Playlist = {
        {
            Title  = "VOU TACAR NA PEKA DAS BB",
            Artist = "Mc Kauan PV",
            File   = "musica.mp3",
            Cover  = "musica1.jpg",
        },
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- NOVIDADES
-----------------------------------------------------------------------------------------------------------------------------------------
-- Image aceita arquivo em web/assets ou URL. Link abre no navegador externo.
-- Items vazio esconde o painel.
Loading.News = {
    Interval       = 10000,
    StartCollapsed = true, -- true = inicia mostrando apenas o cabeçalho
    Items = {
        {
            Title = "NOVIDADE NA LOJA VIP",
            Subtitle = "Seu lugar no camarote mais exclusivo de Madrid.",
            Image = "novidade.png",
            Link  = "https://loja.seuservidor.com",
        },
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- RANKING
-----------------------------------------------------------------------------------------------------------------------------------------
-- Key liga o card à função de mesmo nome em Framework.Rankings, no arquivo
-- server/framework.lua. Title, Icon, Color, SecondaryColor, Prefix e Suffix
-- são livres e podem ser diferentes em cada card.
--
-- HideWhenEmpty = true remove o card quando a consulta não encontra ninguém.
-- Enabled = false desliga apenas aquele card.
Loading.Ranking = {
    Enabled = true,
    Cards = {
        {
            Key            = "money",
            Title          = "MAIS DINHEIRO",
            Icon           = "fa-solid fa-sack-dollar",
            Color          = "#dc1553",
            SecondaryColor = "#ff4f87",
            Prefix         = "$ ",
            Suffix         = "",
            Enabled        = true,
            HideWhenEmpty  = false,
        },
        {
            Key            = "vehicles",
            Title          = "MAIS VEÍCULOS",
            Icon           = "fa-solid fa-car",
            Color          = "#dc1553",
            SecondaryColor = "#ff4f87",
            Prefix         = "",
            Suffix         = "",
            Enabled        = true,
            HideWhenEmpty  = false,
        },
        {
            Key            = "playtime",
            Title          = "MAIS HORAS JOGADAS",
            Icon           = "fa-solid fa-clock",
            Color          = "#dc1553",
            SecondaryColor = "#ff4f87",
            Prefix         = "",
            Suffix         = "h",
            Enabled        = true,
            HideWhenEmpty  = false,
        },
    },
}
