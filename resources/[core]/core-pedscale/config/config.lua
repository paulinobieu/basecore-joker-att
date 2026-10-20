PedScale = {}

-- Cor hexadecimal padrão exibida no painel de ajuste de altura
-- Pode ser alterada para combinar com a identidade visual do servidor
PedScale.ThemeColor = "#dc1553"

-- Escala padrão do ped no FiveM (1.0 = tamanho original, sem modificações)
PedScale.DefaultScale = 1.0

-- Distância máxima em metros para sincronizar a escala de outros jogadores
-- Jogadores além dessa distância não terão a escala visual aplicada no client local
PedScale.SyncDistance = 30.0

-----------------------------------------------------------------------------------------------------------------------------------------
-- CÂMERA
-- Enquadramento do personagem enquanto o painel está aberto.
-----------------------------------------------------------------------------------------------------------------------------------------

PedScale.Camera = {
    -- Posição da câmera em relação ao personagem, em metros:
    --   x = lateral (positivo à direita dele), y = frente, z = altura
    Offset = { 0.0, 2.6, 0.2 },

    -- Ponto que a câmera mira, também relativo ao personagem. O x negativo
    -- empurra o personagem para a direita da tela, longe do painel.
    Point = { -0.55, 0.0, -0.1 },

    -- Abertura da lente: quanto menor, mais fechado no personagem.
    Fov = 45.0,

    -- Duração em milissegundos da transição de entrada e de saída.
    Blend = 600,
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- COMANDOS
-----------------------------------------------------------------------------------------------------------------------------------------

-- Lista de comandos que abrem/fecham o painel de ajuste de altura
PedScale.Commands = { "altura", "tamanho" }

-----------------------------------------------------------------------------------------------------------------------------------------
-- RANGE (slider)
-----------------------------------------------------------------------------------------------------------------------------------------

PedScale.Range = {
    -- Valor mínimo permitido no slider (deve coincidir com o menor preset)
    Min  = 0.93,
    -- Valor máximo permitido no slider (deve coincidir com o maior preset)
    Max  = 1.038,
    -- Incremento por passo do slider — quanto menor, mais preciso o ajuste
    Step = 0.001,
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- PRESETS
-- Atalhos exibidos como botões no painel, cada um aplica uma escala fixa.
-- Os valores devem estar dentro do Range definido acima.
-----------------------------------------------------------------------------------------------------------------------------------------

PedScale.Presets = {
    { id = "small",  label = "Baixo",  value = 0.93  },
    { id = "medium", label = "Médio",  value = 0.965 },
    { id = "normal", label = "Normal", value = 1.0   },
    { id = "large",  label = "Alto",   value = 1.038 },
}
