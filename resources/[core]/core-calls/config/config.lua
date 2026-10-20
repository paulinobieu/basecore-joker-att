-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
Calls = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMMANDS
-----------------------------------------------------------------------------------------------------------------------------------------
Calls.PlayerCommand   = "chamado"
Calls.StaffCommand    = "chamados"
Calls.ToggleCommand   = "togglechamados"
Calls.FinishCommand   = "finalizarchamado"
-----------------------------------------------------------------------------------------------------------------------------------------
-- PERMISSION
-----------------------------------------------------------------------------------------------------------------------------------------
-- Grupo do vRP (vrp/config/Global.lua) usado pra:
--   - Liberar /chamados, /togglechamados, /finalizarchamado e o menu staff
--   - Definir quem RECEBE o toast de chamado novo (apenas membros em servico)
--   - Resolver o rank exibido no perfil/ranking via vRP.NameHierarchy
-- Aceita "Grupo@Nivel" (ex.: "Admin@2") pra exigir nivel minimo na hierarquia.
Calls.StaffPermission = "Admin"
-----------------------------------------------------------------------------------------------------------------------------------------
-- TIMING (segundos)
-----------------------------------------------------------------------------------------------------------------------------------------
Calls.PlayerCooldown  = 60   -- intervalo entre chamados do mesmo jogador
Calls.AcceptTimeout   = 30   -- duracao do toast de incoming
Calls.FastThreshold   = 60   -- atendimento e marcado "rapido" se finaliza ate aqui
-----------------------------------------------------------------------------------------------------------------------------------------
-- KEYS
-----------------------------------------------------------------------------------------------------------------------------------------
Calls.AcceptKey       = "Y"
Calls.DeclineKey      = "U"
Calls.StaffMenuKey    = "F2"
Calls.FinishKey       = "F7"
-----------------------------------------------------------------------------------------------------------------------------------------
-- THEME
-----------------------------------------------------------------------------------------------------------------------------------------
-- Cor base da UI (HEX). Theme.main em vrp/config/Global.lua tem prioridade quando definido.
Calls.ThemeColor      = "#dc1553"
-----------------------------------------------------------------------------------------------------------------------------------------
-- BLIP
-----------------------------------------------------------------------------------------------------------------------------------------
Calls.Blip = {
	Sprite     = 280,
	Color      = 5,
	Scale      = 1.0,
	ShortRange = false,
	Name       = "Atendimento",
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- GARAGE (acao "enviar para garagem")
-----------------------------------------------------------------------------------------------------------------------------------------
-- Le a tabela `garages` de outro resource via LoadResourceFile. Filtra por
-- tipo (apenas NORMAL por padrao, pra evitar AIR/WATER) e ignora entradas
-- com permission != nil pra mandar somente em garagens publicas.
Calls.Garage = {
	Resource = "core-vehicles",
	ConfigFile = "config/garages.lua",
	AllowedTypes = { NORMAL = true },
	OnlyPublic = true,
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- RANK LABELS
-----------------------------------------------------------------------------------------------------------------------------------------
-- O nome do rank exibido no perfil/ranking vem direto da `Hierarchy` do
-- grupo configurado em `Calls.StaffPermission` (vrp/config/Global.lua, ex.:
-- Groups.Admin.Hierarchy = { "Administrador","Diretor","Moderador",... }).
-- Use este mapa apenas se quiser SOBRESCREVER como um rank aparece na UI.
--   chave = nome do rank na Hierarchy
--   valor = label customizado
Calls.RankLabels = {
	-- ["Administrador"] = "Administrador Geral",
	-- ["Diretor"]       = "Coordenador",
}
