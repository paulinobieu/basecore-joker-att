-----------------------------------------------------------------------------------------------------------------------------------------
-- CORE-BENNYS · CONFIGURAÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Oficina de tunagem/mecânica (Benny's Motorworks) com orçamentos e múltiplas oficinas.
-----------------------------------------------------------------------------------------------------------------------------------------
-- Outros arquivos da pasta config/:
--   language.lua  → todos os textos/notificações do resource
--   colors.lua    → paletas de roda, camaleão e xênon com seus respectivos RGBs
--   mods.lua      → categorias, opções disponíveis e o flag enabled
--   prices.lua    → preço de cada tunagem
--   engines.lua   → sons de motor
-----------------------------------------------------------------------------------------------------------------------------------------
-- Índice deste arquivo:
--   1. Identidade & Acesso
--   2. Aparência
--   3. Regras de Serviço
--   4. Oficinas (mecânicas)
-----------------------------------------------------------------------------------------------------------------------------------------

Bennys = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 1. IDENTIDADE & ACESSO
-----------------------------------------------------------------------------------------------------------------------------------------
-- Comandos que abrem cada painel.
Bennys.Commands = {
    OpenBennys      = "bennys",   -- admin abre a tunagem e aplica direto (sem orçamento)
    OpenBudgetPanel = "pedidos",  -- mecânico: abre o serviço em andamento, ou a lista de orçamentos
}

-- Permissões GLOBAIS. As permissões POR OFICINA ficam em Bennys.Mechanics (seção 4).
Bennys.Permissions = {
    Admin = "Admin",  -- exigido pelo /bennys (aplica tunagem direto, sem gerar pedido)
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 2. APARÊNCIA
-----------------------------------------------------------------------------------------------------------------------------------------
-- Logo do painel (topo do menu). Link direto de um PNG.
Bennys.Logo = "https://cdn.corenetwork.dev/IDCore/LOGO%20-%20BRANCO.png"

-- Cores de destaque da NUI.
Bennys.Colors = {
    primaryColor   = "#0143bb",
    secondaryColor = "#012f83",
    thirdyColor    = "#001f59",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- 3. REGRAS DE SERVIÇO
-----------------------------------------------------------------------------------------------------------------------------------------
Bennys.MinMechanics            = 1     -- mínimo de mecânicos online p/ liberar tunagem
Bennys.OnlyOwner               = false -- só o dono do veículo pode tunar
Bennys.OnlyMechanic            = false -- só mecânicos podem tunar (desliga o autosserviço)
Bennys.TuningCarIfNotMechanics = false -- permite tunar pagando na hora quando não há mecânico
Bennys.PercentageMechanic      = 70    -- % do valor que vai pro mecânico que atende

-- Timers (segundos).
Bennys.TimeInstallMod    = 10  -- tempo de instalação de cada peça pelo mecânico
Bennys.RequestRepairTime = 30  -- intervalo entre solicitações de reparo
Bennys.TimeRepairMotor   = 5   -- tempo do reparo de motor

-----------------------------------------------------------------------------------------------------------------------------------------
-- 4. OFICINAS (MECÂNICAS)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Estilo do marcador (DrawMarker) usado em TODAS as oficinas.
Bennys.Marker = {
    id           = 36,
    color        = { 255, 255, 255, 255 },
    scale        = vec3(0.9, 0.9, 0.9),
    rotacao      = vec3(0.0, 0.0, 130.0),
    bobUpAndDown = false,
    faceCamera   = false,
    rotation     = true,
}

-- Cada oficina é uma entrada. Duplique o bloco para criar quantas quiser.
--   Label            → nome exibido/identificação da oficina
--   Type             → o que pode ser tunado aqui:
--                        "allCustoms"    = tudo (estética + performance)
--                        "customization" = só estética (exterior, rodas, pintura, luzes)
--                        "performance"   = só performance (motor, freio, turbo, etc.)
--   AccessPermission → quem pode ABRIR o balcão. false = público (qualquer um)
--   WorkPermission   → quem TRABALHA como mecânico aqui (recebe orçamentos e atende)
--   Coords           → pontos com marcador onde a oficina abre
Bennys.Mechanics = {
    ["motorworks"] = {
        Label            = "Benny's Motorworks",
        Type             = "allCustoms",
        AccessPermission = false,
        WorkPermission   = "Bennys",
        Coords = {
            vector3(-213.95, -1348.08, 31.54),
            vector3(-214.27, -1342.94, 31.54),
            vector3(-214.14, -1337.98, 31.54),
            vector3(-214.10, -1333.02, 31.54),
            vector3(-204.58, -1333.01, 31.54),
            vector3(-204.51, -1337.98, 31.54),
            vector3(-204.63, -1342.94, 31.54),
            vector3(-204.64, -1348.11, 31.54),
        },
    },
}
