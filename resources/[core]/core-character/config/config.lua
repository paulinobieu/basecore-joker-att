-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-CHARACTER · CONFIGURAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Seleção, criação e edição de personagem, barbearia e escolha de spawn.
--
-- Outros arquivos da pasta config/:
--   language.lua    → todos os textos/idiomas da NUI e notificações
--   appearance.lua  → sobreposições de cabelo, roupas iniciais e animações
--   webhooks.lua    → logs de Discord
--
-- Índice deste arquivo:
--   1. Identidade & Acesso
--   2. Aparência & Idioma
--   3. Funcionalidades
--   4. Personagens (slots)
--   5. Cenário da seleção e da criação
--   6. Spawn
--   7. Barbearia
--   8. Imagens
-----------------------------------------------------------------------------------------------------------------------------------------

Character = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 1. IDENTIDADE & ACESSO
-----------------------------------------------------------------------------------------------------------------------------------------
Character.BarberCommand = "barbearia"  -- abre a barbearia
Character.ModelCommand  = "skin"       -- troca o modelo do ped de um jogador
Character.CreateCommand = "newchar"    -- cria um personagem novo para um jogador
Character.ResetCommand  = "resetchar"  -- devolve um personagem ao criador

-- Sem id, ModelCommand não faz nada e os outros três valem para quem digitou.
-- Com id (/resetchar 15), valem para o passaporte informado.
--
-- Grupo e nível exigidos por cada comando administrativo. O número é o RANK
-- dentro do grupo, e na base Core rank menor é rank MAIOR: passa quem tem o
-- número ou qualquer coisa acima dele.
Character.AdminPermission = "Admin"
Character.AdminLevels = {
    Barber = 4, -- BarberCommand
    Model  = 3, -- ModelCommand
    Create = 3, -- CreateCommand
    Reset  = 3, -- ResetCommand
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 2. APARÊNCIA & IDIOMA
-----------------------------------------------------------------------------------------------------------------------------------------
-- Cores de destaque da NUI, do mais claro pro mais escuro (mesma matiz).
-- Só primaryColor é obrigatória: as outras duas, se você apagar ou deixar
-- vazias, saem dela automaticamente — secondary a 71% e thirdy a 46% do
-- brilho da primária. Os valores abaixo são exatamente esse cálculo.
Character.Colors = {
    primaryColor   = "#df155b",
    secondaryColor = "#9e0e40",
    thirdyColor    = "#660929"
}

-- Logo no topo da interface. Vazio = sem logo.
Character.LogoUrl = "https://cdn.corenetwork.dev/IDCore/HUD_GIF.gif"

-- Idioma ativo (chave em config/language.lua). Todos os textos saem de lá.
Character.Language = "pt-BR"

-----------------------------------------------------------------------------------------------------------------------------------------
-- 3. FUNCIONALIDADES
-----------------------------------------------------------------------------------------------------------------------------------------
-- Liga/desliga subsistemas. Desligado = some da NUI e os handlers rejeitam.
Character.Features = {
    Barber        = true,  -- barbearia nos pontos de Character.BarberLocations
    EyesOnBarber  = true,  -- permite trocar a cor dos olhos dentro da barbearia
    SelectSpawn   = true,  -- tela de escolha de local ao terminar a criação
    Cutscene      = false, -- cutscene de chegada logo após criar o personagem
    Clothing      = true,  -- abre a loja de roupas logo após criar o personagem
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 4. PERSONAGENS (SLOTS)
-----------------------------------------------------------------------------------------------------------------------------------------
Character.Slots = {
    Max      = 8,     -- teto de personagens por conta; é também o número de cartões da seleção
    Buy      = false, -- permite comprar um slot novo com moeda premium
    BuyPrice = 30,    -- preço do slot em moeda premium
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 5. CENÁRIO DA SELEÇÃO E DA CRIAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
Character.Scene = {
    -- Onde o personagem fica na tela de seleção.
    SelectCoords = { -1006.79, -480.1, 50.03, 306.15 },
    -- Câmera fixa da seleção.
    SelectCamera = { -1003.03, -477.23, 50.72, -5.85, 0.0, 127.62, 21.0 },
    -- Onde o personagem fica durante a criação.
    CreateCoords = { -1537.38, -941.9, 11.56, 272.13 },

    SelectIpl = false,
    CreateIpl = false,
}

-- Fumaça ambiente do salão da criação. Deixe as listas vazias para desligar.
Character.Smoke = {
    Club = {
        { 249.17, -409.66, 28.05 },
        { 250.65, -409.53, 28.05 },
        { 250.15, -412.22, 28.05 },
        { 251.49, -410.06, 28.05 },
        { 252.54, -413.59, 28.05 },
        { 254.79, -411.43, 28.05 },
        { 254.44, -413.89, 28.05 },
        { 251.81, -409.95, 28.05 },
        { 255.49, -412.15, 28.05 },
    },
    Machines = {
        { 256.34, -410.29, 28.05 },
    },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 6. SPAWN
-----------------------------------------------------------------------------------------------------------------------------------------
-- Ponto onde o personagem aparece assim que é criado: { x, y, z, heading }.
Character.SpawnCoords = { -1537.38, -941.9, 11.56, 272.13 }

-- Locais oferecidos na tela de escolha de spawn.
-- Formato: { x, y, z, rua, nome, imagem }. A imagem é opcional e cai em
-- Character.Images.Location quando omitida.
Character.SpawnLocations = {
    { 195.47, -991.47, 30.09, "Strawberry Avenue", "Praça", "https://i.postimg.cc/YSbSn6x7/Captura-de-tela-2026-02-09-161744.png" },
    { -346.08, -872.78, 31.09, "Vespucci Boulevard", "Estacionamento Vermelho", "https://i.postimg.cc/d3rpgBVB/Vermelho742x417.png" },
    { -823.68, -1222.18, 6.93, "Palomino Avenue", "Hospital", "https://i.postimg.cc/Jz8JSQjL/Captura-de-tela-2026-02-09-161857.png" },
    { 1152.23, -1522.61, 34.85, "Elysian Fields Freeway", "Polícia Militar", "https://i.postimg.cc/7LMzxJMG/Captura-de-tela-2026-02-09-161556.png" },
    { 1710.89, 2672.99, 45.56, "Route 68", "Polícia Civil", "https://i.postimg.cc/1XpXKLC7/Captura-de-tela-2026-02-09-162106.png" },
    { -2058.94, -481.22, 12.1, "Del Perro Freeway", "Seattle Performance", "https://i.postimg.cc/jjJ8vcTW/Captura-de-tela-2026-02-09-160937.png" },
    { 887.41, -1579.26, 30.77, "Senora Freeway", "Mecanica Braba", "https://i.postimg.cc/mk8JTqBZ/Mec-Braba742x417.png" },
    { 317.82, 2624.72, 44.47, "Senora Road", "Estacionamento Sandy Shores", "https://seattlegg.com.br/ImagensSeattle/spawn/sandy.png" },
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 7. BARBEARIA
-----------------------------------------------------------------------------------------------------------------------------------------
-- Pontos que abrem a barbearia. Outro resource pode acrescentar em runtime
-- com o evento "core-character:addBarber".
Character.BarberLocations = {
    { 138.13, -1706.46, 29.3 },
    { -1280.92, -1117.07, 7.0 },
    { 1930.54, 3732.06, 32.85 },
    { 1214.2, -473.18, 66.21 },
    { -33.61, -154.52, 57.08 },
    { -276.65, 6226.76, 31.7 },
    { -817.46, -185.05, 37.56 },
}

Character.BarberDistance = 2.0

-----------------------------------------------------------------------------------------------------------------------------------------
-- 8. IMAGENS
-----------------------------------------------------------------------------------------------------------------------------------------
-- Base das miniaturas. O nome do arquivo é montado pelo índice do modelo:
--   Faces  → <Faces>paterno/0.png · <Faces>materno/21.png
--   Cabelo → <Hair>/Male/0.png · <Hair>/Female/0.png
Character.Images = {
    Faces = "https://cdn.corenetwork.dev/CoreCharacter/Faces/",
    Hair  = "https://cdn.corenetwork.dev/CoreCharacter/Hair",

    -- Cartões da tela de spawn.
    LastLocation = "https://i.postimg.cc/k4W7rWQD/Captura-de-tela-2026-02-09-162240.png",
    Homes        = "https://cdn.discordapp.com/attachments/673773756585345034/1196545020422008923/homeslocate.png",
    Groups       = "https://cdn.discordapp.com/attachments/673773756585345034/1196562550754652441/groups.png",
    Location     = "https://cdn.corenetwork.dev/CoreCharacter/Spawn/Senora_Road.png",
}
