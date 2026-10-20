-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-MDT · CONFIGURAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Tablet policial/MDT: springboard de apps, dashboard, patentes, código penal,
-- cursos/licenças e central de ocorrências.
--
-- ATENÇÃO: arquivo aberto para adaptação. Não altere nada aqui se você não tem
-- conhecimento de programação — mudanças incorretas podem quebrar o sistema.
--
-- Índice deste arquivo:
--   1. Sistema & Acesso
--   2. Fonte de dados (cidadãos / veículos)
--   3. Prisão
--   4. Processamento (reduções, limites e fiança)
--   5. Código penal padrão
-----------------------------------------------------------------------------------------------------------------------------------------

Mdt = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 1. SISTEMA & ACESSO
-----------------------------------------------------------------------------------------------------------------------------------------
-- command: comando que abre o tablet · permission: grupo que libera o painel
-- Administrativo · accent: cor de destaque padrão da NUI.
Mdt.system = {
    command    = "mdt",     -- comando de chat/console que abre o tablet
    permission = "Admin",   -- permissão que libera o painel Administrativo no tablet
    accent     = "#2563EB", -- cor de destaque (accent) padrão da interface

    -- O nível da permissão acima define cada capacidade do Administrativo.
    -- Na vRP, 1 é o cargo mais alto. Somente `true` libera a ação; capacidades
    -- ausentes e níveis fora da lista usam o conjunto `default`.
    admin = {
        levels = {
            [1] = {
                openPanel       = true,
                viewApps        = true,
                createApp       = true,
                editApp         = true,
                deleteApp       = true,
                manageRanks     = true,
                managePenalCode = true,
                manageCatalogs  = true,
                copyConfig      = true,
                viewLogs        = true,
            },
            [2] = {
                openPanel       = true,
                viewApps        = true,
                createApp       = true,
                editApp         = true,
                deleteApp       = false,
                manageRanks     = true,
                managePenalCode = true,
                manageCatalogs  = true,
                copyConfig      = false,
                viewLogs        = true,
            },
            [3] = {
                openPanel       = true,
                viewApps        = true,
                createApp       = false,
                editApp         = false,
                deleteApp       = false,
                manageRanks     = false,
                managePenalCode = false,
                manageCatalogs  = false,
                copyConfig      = false,
                viewLogs        = true,
            },
        },
        default = {
            openPanel       = true,
            viewApps        = true,
            createApp       = false,
            editApp         = false,
            deleteApp       = false,
            manageRanks     = false,
            managePenalCode = false,
            manageCatalogs  = false,
            copyConfig      = false,
            viewLogs        = false,
        },
    },

    -- Fundo da tela do tablet (aparece atrás dos ícones do springboard).
    -- Aceita uma cor ("#161616", "rgb(22,22,22)") ou a URL de uma imagem
    -- ("https://i.imgur.com/exemplo.png"). Vazio = cinza padrão do tema.
    background = "",

    -- Animação de tablet na mão enquanto o MDT está aberto.
    -- bone 28422 = mão direita, 60309 = mão esquerda. Os valores de offset e
    -- rotation quase sempre precisam de ajuste fino — abra o MDT no servidor
    -- e vá corrigindo até o prop encaixar direito na mão do personagem.
    animation  = {
        enabled  = true,
        dict     = "amb@world_human_tourist_map@male@base",
        anim     = "base",
        prop     = "prop_cs_tablet",
        bone     = 28422,
        offset   = { x = 0.0, y = 0.0, z = 0.0 },
        rotation = { x = 0.0, y = 0.0, z = 0.0 },
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 1.1 CÂMERA
-----------------------------------------------------------------------------------------------------------------------------------------
-- Usada nos cards de investigação e nas fotos de cidadão/oficial. A própria
-- interface captura a tela, o jogador recorta a área, a imagem sobe para a
-- API_FOTOS e o MDT guarda só a URL devolvida. Exige a API_FOTOS rodando e
-- acessível pelos jogadores (não só pelo servidor).
Mdt.screenshot = {
    enabled = true,
    api     = "http://131.196.197.3:5001", -- endereço da API_FOTOS (host:porta)
    delay   = 400,  -- ms com o tablet escondido antes de capturar
    quality = 0.92, -- 0.0 a 1.0 da imagem gerada
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 2. FONTE DE DADOS (CIDADÃOS / VEÍCULOS)
-----------------------------------------------------------------------------------------------------------------------------------------
-- As telas de Cidadãos e Veículos consultam as tabelas da SUA base. Os nomes de
-- tabela e coluna mudam por servidor — ajuste aqui (a lógica está em
-- server/framework.lua, seção CIDADÃOS/VEÍCULOS).
Mdt.database = {
    -- Tabela de personagens (cidadãos). O status preso/solto NÃO vem daqui —
    -- por enquanto é fixo ("solto"); depois virá do sistema de prisão do MDT.
    -- license = coluna da conta (usada, junto do id, pra gerar o registro único).
    characters = {
        table    = "characters",
        id       = "id",
        name     = "Name",
        lastname = "Lastname",
        phone    = "Phone",
        license  = "License",
    },

    -- Tabela de veículos.
    vehicles = {
        table  = "core_characters_vehicles",
        plate  = "plate",
        owner  = "owner", -- INT que referencia characters.id
        model  = "index", -- coluna que guarda o modelo/spawn do veículo
        status = "status",
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 3. PRISÃO (sistema próprio do MDT)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Pena em MESES. A cada `reduceInterval` cumprido preso, cai 1 mês. Trabalhando
-- nos locais (CDs) o preso reduz `workReduce` mês por trabalho. Câmeras e locais
-- são livres pra reposicionar a prisão.
Mdt.prison = {
    enabled         = true,
    reduceInterval  = 60000, -- ms cumpridos preso pra cair 1 mês de pena
    workReduce      = 1,    -- meses reduzidos por trabalho concluído
    workDistance    = 5.0,  -- distância pra aparecer/usar o [E] Trabalhar
    minMonthsToWork = 5,    -- só trabalha enquanto a pena for >= este valor
    escapePenalty   = 5,    -- meses somados na pena ao tentar fugir do perímetro

    -- Comando pra soltar um preso: /comando <passaporte> (só quem tem a permissão).
    release         = {
        command    = "rprender",
        permission = "Admin",
    },

    -- Mugshot: cutscene da foto de ficha tirada na hora da prisão. O preso
    -- aparece segurando a plaquinha, a interface fotografa a tela, a imagem
    -- sobe para a API_FOTOS e vira a foto do cidadão no MDT. Precisa da
    -- Mdt.screenshot ligada e da API acessível pelos jogadores.
    mugshot         = {
        enabled  = true,
        header   = "DEPARTAMENTO DE POLÍCIA", -- título no topo da plaquinha
        duration = 5000,                      -- ms que a cena fica na tela depois da foto
        timeout  = 20000,                     -- ms de espera máxima pela foto da interface
        coords   = vector3(402.91, -996.64, -99.90),
        heading  = 184.58,

        -- Câmera que fotografa o preso (posição e rotação).
        camera   = {
            pos      = vector3(402.95, -998.56, -98.39),
            rotation = vector3(-12.85, 0.0, 360.39),
        },
    },

    -- Onde o preso aparece / é solto.
    spawn           = vector3(3904.91, 19.15, 23.89),
    exit            = vector3(3867.47, -29.35, 6.71),

    -- Perímetro: o preso não pode sair daqui (é puxado de volta pro spawn).
    perimeter       = {
        center = vector3(3945.0, 35.0, 22.0),
        radius = 260.0,
    },

    -- Câmeras cinematográficas (vídeozinho pela prisão). Cada tomada tem:
    -- cam (posição inicial), look (pra onde aponta), move (posição final do
    -- movimento suave), duration (ms) e message (notify opcional).
    cameras         = {
        enter = {
            { cam = vector3(3806.17, -31.5, 50.62), look = vector3(3897.20, 14.00, 34.47), move = vector3(3907.81, -99.27, 48.65), duration = 8000 },
            { cam = vector3(3967.76, 45.22, 26.79), look = vector3(3967.53, 53.23, 22.92), move = vector3(3975.01, 48.69, 26.79),  duration = 5000, message = "Trabalhar no presídio reduz sua pena. Siga o blip no mapa." },
            { cam = vector3(3907.35, 22.98, 24.67), look = vector3(3904.66, 19.13, 24.24), move = vector3(3903.35, 24.19, 24.67),  duration = 5000, message = "Cuidado! Ninguém aqui é seu amigo. Boa sorte." },
        },
        exit = {
            { cam = vector3(3855.79, -38.66, 10.46), look = vector3(3867.47, -29.35, 6.71), move = vector3(3871.57, -49.87, 10.82), duration = 8000 },
        },
    },

    -- Locais de trabalho (CDs): cada um sorteia um tipo de animação.
    works           = {
        { coords = vector3(3944.21, 50.92, 22.34), work = "repair" },
        { coords = vector3(3973.48, 47.10, 22.36), work = "sweep" },
        { coords = vector3(3950.80, 45.09, 22.34), work = "clean" },
        { coords = vector3(3967.98, 32.04, 22.34), work = "repair" },
        { coords = vector3(3951.30, 49.02, 22.34), work = "sweep" },
        { coords = vector3(3989.45, 42.44, 22.36), work = "clean" },
    },

    -- Animações por tipo de trabalho.
    anims           = {
        sweep  = { dict = "amb@world_human_janitor@male@idle_a", anim = "idle_a", duration = 8000 },
        clean  = { dict = "amb@prop_human_parking_meter@female@idle_a", anim = "idle_a_female", duration = 8000 },
        repair = { dict = "amb@world_human_welding@male@base", anim = "base", duration = 8000 },
    },

    -- Desafio ao apertar [E] no local de trabalho. Um dos jogos de "list" é
    -- sorteado; errar não reduz a pena e aplica o cooldown de "failCooldown".
    -- enabled = false volta ao comportamento antigo (só a animação).
    minigames       = {
        enabled       = true,
        list          = { "timing", "sequence" },
        failCooldown  = 4000, -- ms de espera depois de errar o desafio

        -- Barra: um cursor vai e volta, aperte ESPAÇO dentro da zona marcada.
        -- rounds (acertos necessários), speed (voltas por segundo),
        -- zone (largura da zona, 0-1; encolhe a cada acerto), duration (ms).
        timing        = { rounds = 3, speed = 0.90, zone = 0.20, duration = 12000 },

        -- Sequência: digite as teclas mostradas, na ordem, antes do tempo.
        sequence      = { length = 5, duration = 6000 },
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 4. PROCESSAMENTO (tela de Prisões e Multas)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Regras da tela onde o oficial aplica os crimes nos envolvidos do boletim.
--
-- REDUÇÕES: dois sliders independentes (pena e multa) de 0% até o máximo abaixo.
-- Quanto maior a redução, menor a pena/multa aplicada.
--
-- LIMITES: os totais somados dos crimes são limitados por maxFinesValue e
-- maxArrestTime ANTES da redução ser aplicada.
--
-- FIANÇA: só aparece quando TODOS os crimes selecionados são afiançáveis
-- (bail = true no código penal). Se um único crime for inafiançável, o
-- indivíduo não pode pagar fiança por nenhum e cumpre a pena — valendo, nesse
-- caso, apenas as reduções. A fiança NÃO sofre redução dos sliders.
Mdt.process = {
    maxFineReduction   = 50,     -- (em porcentagem) Máxima redução do valor da multa que poderá ser selecionada no tablet
    maxArrestReduction = 50,     -- (em porcentagem) Máxima redução do tempo de prisão que poderá ser selecionada no tablet

    maxFinesValue      = 200000, -- Valor máximo da multa
    maxArrestTime      = 200,    -- Pena máxima

    bailToOfficer      = false,  -- Se, ao pagar a fiança, o valor pago será (ou não) destinado ao oficial que realizou a prisão
    bailPercentage     = 50.0,   -- Porcentagem da fiança que será destinada ao oficial que realizou a prisão (utilizado apenas se a opção acima estiver definida como TRUE)
                                 -- O repasse é dividido igualmente entre TODOS os oficiais listados no boletim.
    bailRemoveFine     = true,   -- TRUE = PRISÃO + MULTAS ignoradas / FALSE = Apenas PRISÃO ignorada
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 5. CÓDIGO PENAL PADRÃO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Lista usada pelo botão "Usar padrão" do código penal (painel Administrativo
-- do tablet). Ao usar o padrão, os artigos atuais do app são APAGADOS e
-- substituídos por esta lista.
--
--   name      = "Art.00 - Título do artigo" (o que vem antes do primeiro " - "
--               vira o artigo; o resto vira o título)
--   fine      = valor da multa
--   arrest    = tempo de prisão, SEMPRE em meses
--   bail      = true se o crime pode pagar fiança
--   bailValue = (opcional) valor da fiança. Sem esse campo (ou 0) a fiança
--               cobrada é o próprio valor da multa.
Mdt.penalCode = {
    -- Crimes Aéreos
    { name = "Art.01 - Roubo de veículo militar (VTR)", fine = 30000, arrest = 40, bail = false },
    { name = "Art.02 - Tentativa de roubo de veículo militar (VTR)", fine = 35000, arrest = 20, bail = false },
    { name = "Art.03 - Pouso de aeronave em local não apropriado", fine = 200000, arrest = 0, bail = true },
    { name = "Art.04 - Não possuir o registro da aeronave feito pelo órgão competente", fine = 300000, arrest = 0, bail = true },
    { name = "Art.05 - Manobra perigosa com aeronave", fine = 100000, arrest = 0, bail = true },
    { name = "Art.06 - Tráfego aéreo em local não apropriado", fine = 100000, arrest = 0, bail = true },
    -- Crimes de Trânsito
    { name = "Art.07 - Tentativa de atropelamento", fine = 5000, arrest = 25, bail = false },
    { name = "Art.08 - Alta velocidade", fine = 5000, arrest = 0, bail = true },
    { name = "Art.09 - Abandono de veículo", fine = 3000, arrest = 0, bail = true },
    { name = "Art.10 - Abandono de veículo Militar", fine = 10000, arrest = 0, bail = true },
    { name = "Art.11 - Estacionar em local proibido", fine = 5000, arrest = 0, bail = true },
    { name = "Art.12 - Veículo Danificado", fine = 2000, arrest = 0, bail = true },
    { name = "Art.13 - Utilização indevida de veículo público", fine = 15000, arrest = 0, bail = true },
    { name = "Art.14 - Condução imprudente", fine = 3500, arrest = 0, bail = true },
    { name = "Art.15 - Roubo de veiculo", fine = 5000, arrest = 20, bail = true },
    { name = "Art.16 - Desobediencia", fine = 5000, arrest = 35, bail = true },
    { name = "Art.17 - Corrida Ilegal", fine = 5000, arrest = 20, bail = true },
    { name = "Art.18 - Carteira de Motorista vencida", fine = 3000, arrest = 0, bail = true },
    { name = "Art.19 - Não possuir Carteira de Motorista", fine = 5000, arrest = 0, bail = true },
    { name = "Art.20 - Ocultação facial", fine = 10000, arrest = 0, bail = true },
    -- Crimes Comuns
    { name = "Art.21 - Extorsão", fine = 10000, arrest = 20, bail = false },
    { name = "Art.22 - Calúnia", fine = 10000, arrest = 20, bail = true },
    { name = "Art.23 - Ameaça", fine = 10000, arrest = 30, bail = true },
    { name = "Art.24 - Injúria", fine = 10000, arrest = 20, bail = true },
    { name = "Art.25 - Difamação", fine = 10000, arrest = 20, bail = true },
    { name = "Art.26 - Desacato", fine = 15000, arrest = 30, bail = true },
    { name = "Art.27 - Lesão corporal", fine = 10000, arrest = 15, bail = true },
    { name = "Art.28 - Falsidade ideológica", fine = 10000, arrest = 40, bail = true },
    { name = "Art.29 - Ato obsceno em público", fine = 10000, arrest = 50, bail = true },
    { name = "Art.30 - Importunação sexual", fine = 10000, arrest = 40, bail = false },
    { name = "Art.31 - Ocultação de provas", fine = 10000, arrest = 20, bail = false },
    { name = "Art.32 - Prevaricação", fine = 10000, arrest = 40, bail = false },
    { name = "Art.33 - Prisao Militar Nivel 1", fine = 15000, arrest = 40, bail = false },
    { name = "Art.34 - Prisao Militar Nivel 2", fine = 20000, arrest = 50, bail = false },
    { name = "Art.35 - Prisao Militar Nivel 3", fine = 35000, arrest = 60, bail = false },
    { name = "Art.36 - Dano ao patrimônio", fine = 3000, arrest = 25, bail = true },
    { name = "Art.37 - Roubo a Residencia", fine = 3000, arrest = 15, bail = false },
    { name = "Art.38 - Falsa comunicação de crime", fine = 10000, arrest = 20, bail = true },
    { name = "Art.39 - Perjúrio", fine = 10000, arrest = 60, bail = false },
    { name = "Art.40 - Posse de dinheiro marcado", fine = 5000, arrest = 20, bail = true },
    { name = "Art.41 - Roubo de Caixa Eletronico", fine = 5000, arrest = 20, bail = true },
    { name = "Art.42 - Roubo a Registradora", fine = 5000, arrest = 20, bail = true },
    { name = "Art.43 - Uso de equipamentos restritos (colete/coldre)", fine = 10000, arrest = 20, bail = true },
    -- Crimes Graves
    { name = "Art.44 - Tentativa de homicídio", fine = 8000, arrest = 30, bail = false },
    { name = "Art.45 - Fuga de prisão", fine = 8000, arrest = 30, bail = false },
    { name = "Art.46 - Tentativa de homicídio a oficial", fine = 8000, arrest = 40, bail = false },
    { name = "Art.47 - Sequestro", fine = 8000, arrest = 45, bail = false },
    { name = "Art.48 - Associação Criminosa", fine = 8000, arrest = 40, bail = false },
    { name = "Art.49 - Porte ilegal de arma leve", fine = 3500, arrest = 20, bail = false },
    { name = "Art.50 - Porte ilegal de arma pesada", fine = 5000, arrest = 30, bail = false },
    { name = "Art.51 - Tráfico de armas", fine = 10000, arrest = 55, bail = false },
    { name = "Art.52 - Tráfico de munições", fine = 10000, arrest = 55, bail = false },
    { name = "Art.53 - Corrupção ativa/passiva", fine = 250000, arrest = 250, bail = false },
    { name = "Art.54 - Posse de drogas (Ate 5 unidades)", fine = 3500, arrest = 25, bail = true },
    { name = "Art.55 - Tráfico de drogas (+5 unidades)", fine = 3500, arrest = 35, bail = false },
    { name = "Art.56 - Proteção de dados pessoais", fine = 120000, arrest = 30, bail = true },
    -- Ações de Porte Baixo
    { name = "Art.57 - Barbearia", fine = 8000, arrest = 15, bail = true },
    { name = "Art.58 - Loja de Tatuagem", fine = 8000, arrest = 15, bail = true },
    { name = "Art.59 - Ammunation", fine = 8000, arrest = 15, bail = true },
    { name = "Art.60 - Loja de Bebidas", fine = 8000, arrest = 15, bail = true },
    { name = "Art.61 - Roubo a Spitro", fine = 8000, arrest = 15, bail = true },
    { name = "Art.62 - Roubo ao Mc Donald", fine = 8000, arrest = 15, bail = true },
    { name = "Art.63 - Yellow Jack", fine = 8000, arrest = 15, bail = true },
    { name = "Art.64 - Loja de Departamento", fine = 8000, arrest = 15, bail = true },
    { name = "Art.65 - Estábulo", fine = 8000, arrest = 15, bail = true },
    { name = "Art.66 - Comedy Club", fine = 8000, arrest = 15, bail = true },
    { name = "Art.67 - Aeroporto do Trevor", fine = 8000, arrest = 15, bail = true },
    -- Ações de Porte Médio
    { name = "Art.68 - Observatório", fine = 10000, arrest = 15, bail = true },
    { name = "Art.69 - Galinheiro", fine = 10000, arrest = 15, bail = true },
    { name = "Art.70 - Mergulhador", fine = 10000, arrest = 15, bail = true },
    { name = "Art.71 - Campo de Golf", fine = 10000, arrest = 15, bail = true },
    { name = "Art.72 - Cemitério de aviões", fine = 10000, arrest = 15, bail = true },
    { name = "Art.73 - Life Invader", fine = 10000, arrest = 15, bail = true },
    { name = "Art.74 - Carro Forte", fine = 10000, arrest = 20, bail = true },
    { name = "Art.75 - Açougue", fine = 12000, arrest = 20, bail = true },
    { name = "Art.76 - Estacionamento Marrom", fine = 12000, arrest = 20, bail = true },
    { name = "Art.77 - Hotel", fine = 12000, arrest = 20, bail = true },
    -- Ações de Porte Hostil
    { name = "Art.78 - Joalheria", fine = 12000, arrest = 30, bail = false },
    { name = "Art.79 - Bancos Fleeca", fine = 12000, arrest = 30, bail = false },
    { name = "Art.80 - Banco Central", fine = 12000, arrest = 30, bail = false },
    { name = "Art.81 - Banco de RooxWood", fine = 12000, arrest = 30, bail = false },
    { name = "Art.82 - Nióbio", fine = 12000, arrest = 30, bail = false },
    { name = "Art.83 - Porta Aviões", fine = 15000, arrest = 30, bail = false },
}
