-------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-------------------------------------------------------------------------------------------------------------------------------------
-- Tabela principal. Todas as configurações do core-skins ficam dentro dela.
globalConfig = {}
-------------------------------------------------------------------------------------------------------------------------------------
-- COMMAND
-------------------------------------------------------------------------------------------------------------------------------------
-- Comando de chat que abre o menu de skins pro jogador.
globalConfig.command = "skins"

-- Comando de chat que abre o painel de administração das skins (dar/remover skins, moedas, etc).
-- Só quem tem a permissão staffPermission abaixo consegue usar.
globalConfig.adminCommand = "skinsadm"
-------------------------------------------------------------------------------------------------------------------------------------
-- PERMISSION
-------------------------------------------------------------------------------------------------------------------------------------
-- Permissão/grupo exigido pra usar o comando de admin e as ações administrativas.
-- Pode ser o nome de uma permissão (texto), "grupo@nível" (ex: "Admin@1") ou uma lista.
globalConfig.staffPermission = "Admin"
-------------------------------------------------------------------------------------------------------------------------------------
-- THEME
-------------------------------------------------------------------------------------------------------------------------------------
-- Cor base do tema da interface, em hexadecimal. A partir dela o script gera automaticamente
-- as cores secundária e terciária. Se o seu servidor tem um sistema de tema global, ele tem
-- prioridade sobre essa cor; senão, é essa que vale.
globalConfig.themeColor = "#0095f3"
-------------------------------------------------------------------------------------------------------------------------------------
-- URLS
-------------------------------------------------------------------------------------------------------------------------------------
-- URL da imagem do logo mostrado na interface. Deixe "" pra usar o padrão da interface.
globalConfig.logoUrl = "https://cdn.corenetwork.dev/IDCore/HUD_GIF.gif"

-- URL da imagem do banner mostrado na interface. Deixe "" pra usar o padrão da interface.
globalConfig.bannerUrl = ""

-- URL/link da loja onde o jogador compra SkinsCoins (abre ao clicar em "comprar moedas").
-- Deixe "" pra esconder/desativar o botão.
globalConfig.skinCoinsShopUrl = ""
-------------------------------------------------------------------------------------------------------------------------------------
-- RARITY
-------------------------------------------------------------------------------------------------------------------------------------
-- Liga a raridade interna de cada skin (usada no config/weapons.lua) ao texto que aparece
-- pro jogador na interface. Altere só o texto do lado direito se quiser outros nomes.
globalConfig.rarityMap = {
	common    = "comum",
	rare      = "raro",
	epic      = "epico",
	legendary = "lendario",
}
-------------------------------------------------------------------------------------------------------------------------------------
-- SYNC
-------------------------------------------------------------------------------------------------------------------------------------
-- De quanto em quanto tempo (em milissegundos) as skins alteradas em memória são gravadas
-- no banco de dados. Aqui está em 5 minutos. Menor = grava mais vezes; maior = menos escrita.
globalConfig.syncInterval = 60000 * 5
-------------------------------------------------------------------------------------------------------------------------------------
-- LASTWINS
-------------------------------------------------------------------------------------------------------------------------------------
-- Quantas vitórias recentes de caixa ficam guardadas no feed de "últimas vitórias" mostrado
-- na interface. Ao passar desse número, as mais antigas vão saindo.
globalConfig.lastWinsSize = 20
-------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORKCOINS
-------------------------------------------------------------------------------------------------------------------------------------
-- true: o core-skins usa a moeda premium do seu framework (gemstone do vRP) no lugar do
-- SkinsCoins interno. false: usa o SkinsCoins interno, guardado por jogador na chave abaixo.
-- Ao usar true, adapte as funções de framework.frameworkCoins no config/framework.lua.
globalConfig.useFrameworkCoins = false
-------------------------------------------------------------------------------------------------------------------------------------
-- SKINSCOINS
-------------------------------------------------------------------------------------------------------------------------------------
-- Chave usada pra salvar o saldo de SkinsCoins de cada jogador (dado persistente por personagem).
-- Só precisa mexer se colidir com outra chave já usada no seu servidor.
globalConfig.skinsCoinsUDataKey = "core_skins:skinsCoins"
-------------------------------------------------------------------------------------------------------------------------------------
-- VOUCHERS
-------------------------------------------------------------------------------------------------------------------------------------
-- Chave usada pra salvar o saldo de vouchers de cada jogador (ganhos nas trocas). Mesma regra
-- da chave acima: só troque se colidir com algo no seu servidor.
globalConfig.vouchersUDataKey = "core_skins:vouchers"
-------------------------------------------------------------------------------------------------------------------------------------
-- TRADES
-------------------------------------------------------------------------------------------------------------------------------------
-- Tempo de validade (em ms) de uma proposta de troca. Passou disso sem aceitar, ela expira. (24h)
globalConfig.tradeExpireMs   = 86400000

-- Taxa de vouchers gerada numa troca, proporcional ao preço da skin. 0.02 = 2% do preço da
-- skin vira voucher pro jogador. Deixe 0 pra não gerar voucher nenhum nas trocas.
globalConfig.tradeVoucherRate = 0.02

-- De quanto em quanto tempo (em ms) o script varre e limpa as propostas de troca expiradas.
globalConfig.tradeSweepMs    = 60000
-------------------------------------------------------------------------------------------------------------------------------------
-- DAILY
-------------------------------------------------------------------------------------------------------------------------------------
-- Chave usada pra salvar o controle das caixas diárias (quando o jogador abriu a última).
-- Mesma regra das outras chaves de dado persistente.
globalConfig.dailyUDataKey = "core_skins:dailyCases"
-------------------------------------------------------------------------------------------------------------------------------------
-- WEAPONTEST
-------------------------------------------------------------------------------------------------------------------------------------
-- Configurações da área onde o jogador testa uma skin de arma antes de decidir. O jogador é
-- levado (isolado em um bucket próprio) pra esse local, com a arma, por um tempo limitado.
globalConfig.weaponTest = {
	-- Liga (true) ou desliga (false) o teste de arma com teleporte pra área de tiro. Com false,
	-- o jogador só consegue inspecionar o modelo 3D da skin — o botão "Testar" some da NUI e o
	-- server recusa qualquer tentativa de iniciar o teste.
	enabled      = true,

	-- Coordenadas (x, y, z, heading) pra onde o jogador é teleportado durante o teste.
	coords       = vec4(13.57,-1097.23,29.82,343.0),

	-- Quantidade de munição entregue pra testar a arma.
	ammo         = 250,

	-- Raio máximo (em metros) que o jogador pode se afastar do ponto de teste. Passou disso,
	-- o teste é encerrado automaticamente.
	maxRadius    = 30.0,

	-- Tempo máximo do teste, em segundos. Ao acabar, o jogador volta e o teste encerra.
	maxSeconds   = 600,

	-- Tecla que o jogador aperta pra sair do teste antes do tempo (177 = Backspace/ESC padrão do FiveM).
	exitKey      = 177,

	-- Valor somado ao id do jogador pra criar um routing bucket exclusivo, isolando quem está
	-- testando dos outros jogadores. Só mude se colidir com buckets usados por outro sistema.
	bucketOffset = 75000,
}
-------------------------------------------------------------------------------------------------------------------------------------
-- PREVIEW 3D
-------------------------------------------------------------------------------------------------------------------------------------
-- Configurações da inspeção 3D da skin (quando o jogador arrasta o mouse pra girar a arma).
globalConfig.preview = {
	-- Velocidade da rotação, em graus por pixel de mouse arrastado. Quanto maior, mais rápido a
	-- arma gira com menos arrasto; quanto menor, mais lento e preciso. Padrão 0.35 (~180° a cada
	-- ~510px). Valores comuns: 0.2 (lento) a 0.6 (bem rápido).
	rotationSpeed = 0.35,
}
-------------------------------------------------------------------------------------------------------------------------------------
-- IMPROVEMENT
-------------------------------------------------------------------------------------------------------------------------------------
-- Sistema de aprimoramento: o jogador aposta skins (e opcionalmente SkinsCoins) tentando
-- trocá-las por uma skin de maior valor, com uma chance de sucesso baseada nos valores envolvidos.
globalConfig.improvement = {
	-- Liga (true) ou desliga (false) todo o sistema de aprimoramento.
	enabled           = true,

	-- true: exige que o jogador coloque pelo menos uma skin própria na aposta.
	requirePlayerSkin = true,

	-- Curva da chance de sucesso. A chance vem de (valor investido / valor do alvo) elevado a
	-- esse expoente. Maior = curva mais dura (fica mais difícil mirar em skins muito acima).
	chanceExponent    = 1.5,

	-- Chance mínima de sucesso, em %, mesmo em apostas muito desfavoráveis.
	minChance         = 1,

	-- Chance máxima de sucesso, em %, mesmo em apostas muito favoráveis.
	maxChance         = 95,

	-- Multiplicador mínimo do alvo: a skin alvo precisa valer pelo menos (valor investido x isto).
	-- Ex: 1.2 = o alvo tem que valer no mínimo 20% a mais do que foi apostado.
	minTargetMarkup   = 1.2,

	-- Multiplicador máximo do alvo: a skin alvo pode valer no máximo (valor investido x isto).
	-- Ex: 5.0 = não dá pra mirar em algo que valha mais de 5x o que foi apostado.
	maxTargetMarkup   = 5.0,
}
-------------------------------------------------------------------------------------------------------------------------------------
-- TEMPORARY DURATIONS
-------------------------------------------------------------------------------------------------------------------------------------
-- Opções de período que aparecem na compra de uma skin. Cada opção tem:
--   id    = identificador interno da opção (não repita).
--   label = texto mostrado pro jogador.
--   days  = duração em dias; use 0 pra "permanente" (a skin não expira).
--   price = preço fixo em SkinsCoins daquela opção; use nil pra usar o preço base da skin
--           definido no config/weapons.lua.
globalConfig.temporaryDurations = {
	{ id = "7d",   label = "7 Dias",     days = 7,  price = 5000 },
	{ id = "30d",  label = "30 Dias",    days = 30, price = 15000 },
	{ id = "perm", label = "Permanente", days = 0,  price = nil },
}

-- Quantos dias antes de expirar uma skin temporária começa a ser destacada como "expirando
-- em breve" na interface.
globalConfig.expiringSoonDays = 3

-- Limite máximo (em ms) de cada agendamento de expiração. Mantém o timer seguro para valores
-- grandes (int32) e re-checa periodicamente as expirações distantes; as próximas disparam na
-- hora exata. Normalmente não precisa mexer. (24h)
globalConfig.expireMaxScheduleMs = 86400000
-------------------------------------------------------------------------------------------------------------------------------------
-- LANGUAGE
-------------------------------------------------------------------------------------------------------------------------------------
-- Todas as mensagens mostradas ao jogador. Pode editar o texto livremente. As que têm %s
-- recebem valores na ordem em que aparecem (ex: "%s por %s dias por %s SkinsCoins" = nome da
-- skin, dias e preço). Mantenha a mesma quantidade de %s ao traduzir/editar.
globalConfig.language = {
	buyTempSuccess                    = "Você comprou a skin %s por %s dias por %s SkinsCoins.",
	invalidDuration                   = "Período de compra inválido.",
	skinExpired                       = "A skin %s expirou e foi removida do seu inventário.",
	noPriceForSell                    = "Skin sem valor comercial, não pode ser vendida!",
	sellSuccess                       = "Você vendeu a skin %s por %s SkinsCoins.",
	noPriceForBuy                     = "Skin sem valor comercial, não pode ser comprada!",
	buySuccess                        = "Você comprou a skin %s por %s SkinsCoins.",
	insufficientSkinsCoinsBuy         = "Você não possui SkinsCoins suficientes para comprar esta skin.",
	equippedSuccess                   = "Skin %s equipada com sucesso.",
	unequippedSuccess                 = "Skin %s desequipada com sucesso.",
	insufficientSkinsCoins            = "Você não possui SkinsCoins suficientes para abrir esta caixa.",
	noPermission                      = "Você não tem permissão para abrir esta caixa.",
	cooldownActive                    = "Esta caixa ainda está em cooldown.",
	improvementSuccess                = "Aprimoramento bem-sucedido! Você recebeu %s.",
	improvementFailed                 = "O aprimoramento falhou. Os itens foram consumidos.",
	improvementInvalid                = "Seleção de itens inválida para aprimoramento.",
	improvementInsufficientSkinsCoins = "Você não possui SkinsCoins suficientes para esta aposta.",
	improvementNoTarget               = "Selecione um alvo válido para o aprimoramento.",
	improvementNoPlayerSkin           = "Selecione pelo menos uma skin sua para aprimorar.",
	improvementInvalidTarget          = "O item alvo está fora da faixa de valor permitida para o que você investiu.",
	improvementDisabled               = "O aprimoramento está desativado no momento.",
	weaponTestInvalid                 = "Skin inválida para teste.",
	tradeExpired                      = "Proposta expirou.",
	tradeMissingSkins                 = "Uma das partes não possui mais as skins ofertadas.",
	tradeMissingVouchers              = "Uma das partes não possui vouchers suficientes para concluir a troca.",
	tradeProposalSent                 = "Proposta enviada com sucesso.",
	tradeProposalReceived             = "Você recebeu uma nova proposta de troca.",
	tradeAccepted                     = "Troca concluída com sucesso.",
	tradeDeclined                     = "Proposta recusada.",
}
