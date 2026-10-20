-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CUSTOMIZATION · CONFIGURAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Loja de roupas e loja de tatuagem.
--
-- Outros arquivos da pasta config/:
--   clothes.lua   → peças, componentes do ped, animações e bloqueios
--   tattoos.lua   → catálogo de tatuagens por sexo e zona
--   language.lua  → todos os textos/idiomas da NUI e notificações
--   webhooks.lua  → logs de Discord
--
-- Índice deste arquivo:
--   1. Identidade & Acesso
--   2. Aparência & Idioma
--   3. Funcionalidades
--   4. Lojas de roupa
--   5. Lojas de tatuagem
--   6. Câmera
--   7. Imagens
--   8. Armazenamento
-----------------------------------------------------------------------------------------------------------------------------------------

Customization = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 1. IDENTIDADE & ACESSO
-----------------------------------------------------------------------------------------------------------------------------------------
Customization.ShopCommand   = "skinshop"    -- abre a loja de roupas de onde estiver
Customization.TattooCommand = "tattooshop"  -- abre a loja de tatuagem de onde estiver
Customization.PresetCommand = "printpreset" -- lista a roupa de um jogador em comandos

-- Grupo e nível exigidos por cada comando administrativo. O número é o RANK
-- dentro do grupo, e na base Core rank menor é rank MAIOR: passa quem tem o
-- número ou qualquer coisa acima dele.
Customization.AdminPermission = "Admin"
Customization.AdminLevels = {
    Shop   = 4, -- ShopCommand e TattooCommand (o grupo de PremiumGroup também passa)
    Preset = 3, -- PresetCommand
}

-- Grupo que compra vantagem: abre a loja de onde estiver com o ShopCommand e
-- não precisa do item dos comandos de peça. É um nome de grupo da SUA base,
-- conferido com vRP.HasGroup. Deixe "" para não ter exceção nenhuma.
Customization.PremiumGroup = ""

-- Comandos de peça (/camisa 15 0). A chave é a peça em config/clothes.lua.
-- Apague uma linha para tirar o comando do ar.
Customization.PartCommands = {
    ["mascara"]    = "mask",
    ["camisa"]     = "tshirt",
    ["colete"]     = "vest",
    ["jaqueta"]    = "torso",
    ["maos"]       = "arms",
    ["calca"]      = "pants",
    ["acessorios"] = "accessory",
    ["sapatos"]    = "shoes",
    ["chapeu"]     = "hat",
    ["oculos"]     = "glass",
}

-- Item da mochila que libera os comandos de peça. Quem está no PremiumGroup
-- também passa. Deixe "" para liberar para todo mundo.
Customization.PartCommandItem = "clothes"

-----------------------------------------------------------------------------------------------------------------------------------------
-- 2. APARÊNCIA & IDIOMA
-----------------------------------------------------------------------------------------------------------------------------------------
-- Cores de destaque da NUI, do mais claro pro mais escuro (mesma matiz).
-- Só primaryColor é obrigatória: as outras duas, se você apagar ou deixar
-- vazias, saem dela automaticamente — secondary a 71% e thirdy a 46% do
-- brilho da primária. Os valores abaixo são exatamente esse cálculo.
Customization.Colors = {
    primaryColor   = "#df155b",
    secondaryColor = "#9e0e40",
    thirdyColor    = "#660929"
}

-- Logo no topo da interface. Vazio = sem logo.
Customization.LogoUrl = "https://cdn.corenetwork.dev/IDCore/HUD_GIF.gif"

-- Idioma ativo (chave em config/language.lua). Todos os textos saem de lá.
Customization.Language = "pt-BR"

-----------------------------------------------------------------------------------------------------------------------------------------
-- 3. FUNCIONALIDADES
-----------------------------------------------------------------------------------------------------------------------------------------
-- Liga/desliga subsistemas. Desligado = some do jogo e os handlers rejeitam.
Customization.Features = {
    ClothesShop = true, -- lojas de roupa em Customization.ClothesShops
    TattooShop  = true, -- lojas de tatuagem em Customization.TattooShops
    PartCommands = true, -- comandos de peça (/camisa, /calca, ...)
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 4. LOJAS DE ROUPA
-----------------------------------------------------------------------------------------------------------------------------------------
-- Distância, em metros, para o marcador da loja aceitar o E. Vale para as
-- lojas de roupa e para as de tatuagem.
Customization.ShopDistance = 2.0

-- Pontos de interação: { x, y, z }.
Customization.ClothesShops = {
    { 71.66, -1398.46, 29.38 },
    { -708.57, -160.34, 37.42 },
    { -158.67, -296.99, 39.74 },
    { 428.92, -799.94, 29.5 },
    { -829.48, -1073.44, 11.33 },
    { -1192.07, -771.59, 17.33 },
    { -1456.77, -240.92, 49.81 },
    { 11.83, 6513.89, 31.88 },
    { 1696.83, 4829.46, 42.07 },
    { 122.97, -221.51, 54.56 },
    { 617.75, 2761.7, 42.09 },
    { 1190.47, 2713.55, 38.23 },
    { -3173.31, 1046.1, 20.87 },
    { -1108.26, 2708.85, 19.11 },
    { 105.66, -1303.04, 28.8 },
    { 1101.26, 197.48, -49.44 },
    { -332.16, 7209.34, 6.8 },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 5. LOJAS DE TATUAGEM
-----------------------------------------------------------------------------------------------------------------------------------------
Customization.TattooShops = {
    { 1322.93, -1652.29, 52.27 },
    { -1154.42, -1425.9, 4.95 },
    { 322.84, 180.16, 103.58 },
    { -3169.62, 1075.8, 20.83 },
    { 1864.07, 3747.9, 33.03 },
    { -293.57, 6199.85, 31.48 },
    { -331.24, 7187.46, 6.48 },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 6. CÂMERA
-----------------------------------------------------------------------------------------------------------------------------------------
-- Enquadramentos do botão de câmera, na ordem em que a interface mostra
-- (e nas teclas 1 a 4). `offset` é a posição relativa ao ped e `point` o
-- ponto que ela mira, também relativo.
Customization.Cameras = {
    [0] = { fov = 50.0, offset = { 0.15, 2.25, 0.28 },  point = { 0.0, 0.0, -0.1 } },  -- corpo inteiro
    [1] = { fov = 15.0, offset = { 0.15, 2.25, 0.65 },  point = { 0.0, 0.0, 0.65 } },  -- rosto
    [2] = { fov = 25.0, offset = { 0.15, 2.25, 0.30 },  point = { 0.0, 0.0, 0.30 } },  -- torso
    [3] = { fov = 35.0, offset = { 0.15, 2.25, -0.40 }, point = { 0.0, 0.0, -0.40 } }, -- pernas
}

-- Velocidade da interpolação de FOV e de rotação. Maior = mais seco.
Customization.CameraSpeed = 10.0

-- Para onde o personagem vira ao abrir uma loja.
Customization.ShopHeading = 4.2

-----------------------------------------------------------------------------------------------------------------------------------------
-- 7. IMAGENS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Base das miniaturas. O caminho final é montado assim:
--   Clothes → base .. sexo .. "/" .. peça .. "/" .. índice .. ".jpg"
--   Tattoos → base .. sexo .. "/" .. nome .. ".png"
Customization.Images = {
    Clothes = "https://cdn.corenetwork.dev/CoreCustomization/Clothes/",
    Tattoos = "https://cdn.corenetwork.dev/CoreCustomization/Tatoos/",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 8. ARMAZENAMENTO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Onde a roupa e a tatuagem são gravadas.
--
--   "character" → quem guarda é o resource de personagem (core-character).
--                 É o padrão, e é o que faz a seleção montar o preview de
--                 cada slot lendo a mesma linha.
--
--   "table"     → tabela SQL própria deste resource, criada sozinha no
--                 primeiro start. Para quem não usa o core-character e não
--                 quer mexer em código.
--
-- Usa OUTRO criador de personagem e quer gravar na tabela DELE? Deixe em
-- "table" e ajuste os nomes abaixo; se o formato for diferente do nosso,
-- troque o corpo de Framework.LoadOutfit e Framework.SaveOutfit em
-- server/framework.lua — é para isso que elas existem.
Customization.Storage = {
    Mode = "character",

    -- Daqui para baixo só vale no modo "table".
    Table = "core_customization",
    Columns = {
        Passport = "citizenid", -- coluna que identifica o personagem
        Clothes  = "clothes",   -- JSON { [peça] = { item, texture } }
        Tattoos  = "tattoos",   -- JSON { [nome] = { coleção } }
    },
}
