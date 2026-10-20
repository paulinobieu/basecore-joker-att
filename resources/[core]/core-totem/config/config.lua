Totem = {}

-- Cor hexadecimal padrao exibida nos paineis do totem
-- Pode ser sobrescrita individualmente em cada entrada de Totem.Restaurants
Totem.DefaultThemeColor = "#dc1553"

-- Se true, o valor das vendas e enviado diretamente ao painel da organizacao
-- no core-groups. A organizacao e localizada exclusivamente pela ServicePermission.
-- Se false, a receita fica disponivel para retirada no painel administrativo do totem.
Totem.UseCoreGroups = false

-----------------------------------------------------------------------------------------------------------------------------------------
-- MOEDA
-----------------------------------------------------------------------------------------------------------------------------------------

Totem.Currency = {
    -- Prefixo exibido antes do valor monetario (ex: "R$ ", "$ ", "EUR ")
    Prefix = "R$ ",
    -- Sufixo exibido apos o valor monetario (ex: "", " BRL")
    Suffix = "",
    -- Separador de milhar (ex: "." para 1.000.000 ou "," para 1,000,000)
    Separator = ".",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- IMAGENS
-----------------------------------------------------------------------------------------------------------------------------------------

Totem.Images = {
    -- URL base para as imagens dos itens (consome ItemsURL do Global.lua)
    BaseUrl = ItemsURL,
    -- Extensao dos arquivos de imagem
    Extension = ".png",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- ESTOQUE
-----------------------------------------------------------------------------------------------------------------------------------------

Totem.Stock = {
    -- Estoque inicial ao criar o item no banco de dados
    DefaultStock = 0,
    -- Estoque maximo por item
    MaxStock = 200,
    -- Quantidade maxima do mesmo item permitida em uma unica compra, mesmo sem estoque
    MaxPurchasePerItem = 200,
    -- Se true, o admin precisa ter os itens no inventario para reabastecer
    RequireItems = true,
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- FAIXA DE PRECO
-----------------------------------------------------------------------------------------------------------------------------------------

Totem.PriceRange = {
    -- Preco minimo permitido ao alterar o valor de um item
    Min = 100,
    -- Preco maximo permitido ao alterar o valor de um item
    Max = 500,
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- RETIRADA
-----------------------------------------------------------------------------------------------------------------------------------------

Totem.Withdraw = {
    -- Nome do item entregue ao dono do totem ao retirar a receita
    -- Se nil ou false, o valor sera depositado na conta bancaria (giveBankMoney)
    Item = "dollars",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- BLOQUEIO
-- Verifica se ha funcionarios com ServicePermission online e dentro do raio do totem.
-- Se houver, o totem e bloqueado para compras de clientes.
-- Admins (AdminPermission) continuam podendo acessar o painel normalmente.
-- Essa configuracao e global — nao ha ajustes por totem.
-----------------------------------------------------------------------------------------------------------------------------------------

Totem.Blocking = {
    -- Se true, ativa a verificacao de bloqueio por funcionarios em servico
    Enabled = true,
    -- Raio em metros ao redor do totem para verificar presenca de funcionarios
    Radius = 25.0,
    -- Mensagem exibida ao jogador quando o totem esta bloqueado
    BlockedMessage = "O totem esta fechado. Ha funcionarios em servico no restaurante.",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- OBJETO / PROP
-- Modelo padrao utilizado para spawnar os totens no mundo.
-- Pode ser sobrescrito individualmente em cada totem via Machine.Model.
-----------------------------------------------------------------------------------------------------------------------------------------

Totem.MachineObject = {
    -- Nome do modelo do prop (hash ou string)
    Model = "totem",
    -- Se true, congela o objeto no lugar
    Freeze = true,
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- INTERACAO
-----------------------------------------------------------------------------------------------------------------------------------------

Totem.Interaction = {
    -- Sistema de interacao utilizado para abrir os totens
    -- Valores aceitos: "sleepless" | "ox_target" | "marker"
    System = "sleepless",

    -- Distancia em metros em que o painel e fechado automaticamente ao se afastar do totem
    AutoCloseDistance = 5.0,

    -- Configuracoes do sleepless_interact (utilizado quando System = "sleepless")
    Sleepless = {
        Label = "Abrir Totem",
        Icon = "utensils",
        -- Distancia maxima para exibir a interacao
        Distance = 2.5,
        -- Distancia maxima para permitir a interacao
        InteractDistance = 2.5,
    },

    -- Configuracoes do ox_target (utilizado quando System = "ox_target")
    OxTarget = {
        Label = "Abrir Totem",
        Icon = "fa-solid fa-utensils",
        -- Distancia maxima para exibir a opcao
        Distance = 2.5,
        -- Raio da zona esferica criada ao redor do totem
        Radius = 1.0,
    },

    -- Configuracoes do marcador 3D no chao (utilizado quando System = "marker")
    Marker = {
        -- Distancia em que o marcador comeca a ser desenhado
        DrawDistance = 12.0,
        -- Distancia em que a tecla de interacao e exibida e pode ser pressionada
        OpenDistance = 1.5,
        -- Tecla de interacao (38 = E)
        Key = 38,
        -- Texto exibido sobre o marcador quando o jogador esta proximo
        Text = "~g~E~w~  ABRIR TOTEM",
        -- Tipo do marcador GTA (2 = cilindro, 1 = seta)
        Type = 2,
        -- Deslocamento vertical do marcador em relacao a coordenada Z
        ZOffset = 0.15,
        -- Deslocamento vertical do texto em relacao a coordenada Z
        TextZOffset = 0.35,
        -- Escala do marcador
        Scale = vec3(0.18, 0.18, 0.18),
        -- Cor do marcador (R, G, B, A)
        Color = { 59, 130, 246, 160 },
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- RESTAURANTES
-- Cada entrada representa um totem (ponto de venda) independente com seu proprio estado no banco de dados.
-- O nome da chave e o identificador unico do totem — nunca reutilize um nome ja usado.
--
-- AdminPermission   -> Permissao para acessar o painel administrativo (estoque, precos e retirada quando UseCoreGroups = false).
--                      Aceita string unica ou tabela de permissoes (basta ter uma delas).
-- ServicePermission -> Permissao dos funcionarios do restaurante.
--                      Quando Totem.Blocking.Enabled = true, se algum jogador com essa permissao
--                      estiver online e dentro do raio configurado, o totem e bloqueado para clientes.
--                      Use false ou nil para nunca bloquear.
-----------------------------------------------------------------------------------------------------------------------------------------

Totem.Restaurants = {
    -- Soda Pop (permissão vRP: SodaPop) — comida > bebida > sobremesa
    SodaPop = {
        ThemeColor = "#dc1553",
        Banner = "https://cdn.corenetwork.dev/Totem/TOTEM-SODAPOP_fundo-rosa-2.png",

        Machine = {
            Object = true,
            Coords = vec4(-1381.35, -1397.01, 4.61, 351.5),
        },

        AdminPermission = "SodaPop@2",
        ServicePermission = "SodaPop",

        Items = {
            bibimbap       = { DefaultPrice = 500 },
            salada         = { DefaultPrice = 500 },
            milkcereja     = { DefaultPrice = 500 },
            aguadecoco     = { DefaultPrice = 500 },
            churros        = { DefaultPrice = 500 },
            bolodemorango  = { DefaultPrice = 500 },
        },
    },

    -- Moo Moo (permissão vRP: MooMoo) — comida > bebida > sobremesa
    MooMoo = {
        ThemeColor = "#dc1553",
        Banner = "https://cdn.corenetwork.dev/Totem/MooMoo.png",

        Machine = {
            Object = true,
            Coords = vec4(-576.43,-1071.78,21.33,87.88),
        },

        AdminPermission = "MooMoo@2",
        ServicePermission = "MooMoo",

        Items = {
            cereal          = { DefaultPrice = 500 },
            purebatata      = { DefaultPrice = 500 },
            leitedemorango  = { DefaultPrice = 500 },
            leitecomcanela  = { DefaultPrice = 500 },
            bolococo        = { DefaultPrice = 500 },
            tortadeamendoim = { DefaultPrice = 500 },
        },
    },

    -- Osaka Sushi (permissão vRP: OsakaSushi) — itens pendentes até definir o cardápio
    OsakaSushi = {
        ThemeColor = "#dc1553",
        Banner = "https://cdn.corenetwork.dev/Totem/OsakaSushi.png",

        Machine = {
            Object = true,
            Coords = vec4(-777.82,-136.89,36.81,212.6),
        },

        AdminPermission = "OsakaSushi@2",
        ServicePermission = "OsakaSushi",

        Items = {},
    },

    -- Marina Lounge (permissão vRP: MarinaLounge) — comida > bebida > sobremesa
    Marina = {
        ThemeColor = "#dc1553",
        Banner = "https://cdn.corenetwork.dev/Totem/MarinaLounge.png",

        Machine = {
            Object = true,
            Coords = vec4(1528.15,3776.63,33.51,133.23),
        },

        AdminPermission = "MarinaLounge@2",
        ServicePermission = "MarinaLounge",

        Items = {
            peixebatata           = { DefaultPrice = 500 },
            salmaomolho           = { DefaultPrice = 500 },
            sucodeuva             = { DefaultPrice = 500 },
            coquetellaranjaelimao = { DefaultPrice = 500 },
            wafflesgelado         = { DefaultPrice = 500 },
            cupcakedelaranja      = { DefaultPrice = 500 },
        },
    },
}
