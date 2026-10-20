Config = {}

-- Configurações de agência
Config.jobsAgencies = {
    coords = { {-268.97,-956.1,31.22,18.57} },
    blip = { show = true, id = 642, color = 50, size = 0.8, name = "Agência de Empregos" },
    command = { enabled = true, name = "empregos", permission = {"cadmin","admin","founder"} }
}

-- Cor global dos markers e contornos de entidades (hex)
Config.markerColor = "#ca27f4"

-- Cor principal do tema da interface (hex) — troca todos os azuis do frontend
Config.ThemeColor = "#ca27f4"

-- Posição do painel de dica do emprego (JobTip)
-- Valores aceitos: "bottom-left" (default, evita o minimap), "bottom-center",
-- "bottom-right", "top-left", "top-center", "top-right", "middle-left", "middle-right".
Config.jobTipPosition = "bottom-left"

-- Configurações de Níveis e Experiência (geral)
Config.workerLevels = {
    [1] = 1000,
    [2] = 15000,
    [3] = 45000,
    [4] = 80000,
    [5] = 130000
}

-- Multiplicador bônus do nível geral do trabalhador
Config.workerLevelMultiplier = {
    [0] = 0,
    [1] = 0.05,  -- +5% no nível geral 1
    [2] = 0.10,  -- +10% no nível geral 2
    [3] = 0.15,  -- +15% no nível geral 3
    [4] = 0.20,
    [5] = 0.25,
}

-- Níveis por emprego (XP necessário para cada nível dentro do emprego)
Config.perJobLevels = {
    [1] = 500,
    [2] = 1200,
    [3] = 2500,
    [4] = 4500,
    [5] = 7000,
    [6] = 10000,
    [7] = 14000,
    [8] = 19000,
    [9] = 25000,
    [10] = 35000,
}

-- Multiplicador de recompensa por nível do emprego (0 = sem bônus, 0.1 = +10%, 0.5 = +50%, 1.0 = +100%)
Config.perLevelMultiplier = {
    [0] = 0,
    [1] = 0.05,
    [2] = 0.10,
    [3] = 0.20,
    [4] = 0.30,
    [5] = 0.45,
    [6] = 0.60,
    [7] = 0.80,
    [8] = 1.00,
    [9] = 1.25,
    [10] = 1.50,
}

-- Configuração de bônus por horas trabalhadas
Config.bonusByWorkedHours = {
    enabled = true,
    resetEveryDays = 12,
    rewards = {
        { workedHours = 1,  reward = 400   },
        { workedHours = 3,  reward = 1400  },
        { workedHours = 5,  reward = 2600  },
        { workedHours = 10, reward = 4500  },
        { workedHours = 15, reward = 6700  },
        { workedHours = 20, reward = 8500  },
        { workedHours = 25, reward = 12500 },
        { workedHours = 30, reward = 18000 },
        { workedHours = 35, reward = 25000 },
        { workedHours = 40, reward = 31000 },
        { workedHours = 45, reward = 39000 },
        { workedHours = 50, reward = 45000 },
        { workedHours = 55, reward = 50000 },
        { workedHours = 60, reward = 55000 },
        { workedHours = 65, reward = 55000 },
        { workedHours = 70, reward = 61000 },
        { workedHours = 75, reward = 67000 },
    }
}

-- Missões baseadas nos empregos (targets, XP, etc.)
Config.missions = {
    { id = 1,  jobId = "motorista",           title = "Pegar 25 passageiros",          description = "Colete e entregue 25 passageiros no ônibus.",                  target = 25,  xp = 5000  },
    { id = 2,  jobId = "motorista",           title = "Pegar 100 passageiros",         description = "Colete e entregue 100 passageiros no ônibus.",                 target = 100, xp = 20000 },
    { id = 3,  jobId = "lenhador",            title = "Cortar 50 árvores",             description = "Realize o corte de 50 árvores na área de desmatamento.",       target = 50,  xp = 10000 },
    { id = 4,  jobId = "lenhador",            title = "Cortar 150 árvores",            description = "Realize o corte de 150 árvores na área de desmatamento.",      target = 150, xp = 30000 },
    { id = 5,  jobId = "minerador",           title = "Minerar 30 vezes",              description = "Realize a mineração em 30 pontos diferentes.",                 target = 30,  xp = 8000  },
    { id = 6,  jobId = "minerador",           title = "Minerar 100 vezes",             description = "Realize a mineração em 100 pontos diferentes.",                target = 100, xp = 25000 },
    { id = 7,  jobId = "lixeiro",             title = "Coletar 40 lixeiras",           description = "Realize a coleta de lixo em 40 lixeiras pela cidade.",         target = 40,  xp = 6000  },
    { id = 8,  jobId = "lixeiro",             title = "Coletar 100 lixeiras",          description = "Realize a coleta de lixo em 100 lixeiras pela cidade.",        target = 100, xp = 18000 },
    { id = 9,  jobId = "pescador",            title = "Pescar 20 vezes",               description = "Realize 20 pescas com sucesso.",                               target = 20,  xp = 5000  },
    { id = 10, jobId = "pescador",            title = "Pescar 80 vezes",               description = "Realize 80 pescas com sucesso.",                               target = 80,  xp = 20000 },
    { id = 11, jobId = "agricultor-trigo",    title = "Lavrar 25 áreas de trigo",      description = "Lavre 25 áreas de trigo com o trator na fazenda.",             target = 25,  xp = 5000  },
    { id = 12, jobId = "agricultor-laranjas", title = "Colher 30 laranjeiras",         description = "Colha laranjas de 30 árvores no campo.",                       target = 30,  xp = 6000  },
    { id = 13, jobId = "eletricista",         title = "Reparar 25 caixas elétricas",   description = "Repare 25 caixas elétricas pela cidade.",                      target = 25,  xp = 5000  },
    { id = 14, jobId = "entregador",          title = "Fazer 30 entregas",             description = "Realize 30 entregas por toda a cidade.",                       target = 30,  xp = 6000  },
    { id = 15, jobId = "entregador",          title = "Fazer 100 entregas",            description = "Realize 100 entregas por toda a cidade.",                      target = 100, xp = 22000 },
}
