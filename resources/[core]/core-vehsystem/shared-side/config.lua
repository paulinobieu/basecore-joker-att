Config = {}

Config.EnableDriveBy = true -- Permite atirar de dentro de veículos (true = ligado, false = desligado)
Config.EnableHeliDriveBy = true -- Permite atirar de dentro de helicópteros (true = ligado, false = desligado)
Config.EnablePassengerLite = true -- Acende a luz interna do veículo quando alguém entra como passageiro
Config.EnableAntiBump = true -- Impede que veículos fiquem "pulando" ao bater em outros
Config.EnableDelProps = true -- Remove objetos da cidade (postes, placas, lixeiras, etc.) ao serem atingidos por veículos
Config.EnablePnb = true -- Ativa o sistema de estouros no escapamento (Pops & Bangs)
Config.EnableSpeedLimiter = false -- Limita a velocidade máxima dos veículos

-----------------------------------------------------------------------------------------------------------------------------------------
-- DRIVEBY
-----------------------------------------------------------------------------------------------------------------------------------------
Config.BypassDriveBy = { -- Veículos que SEMPRE podem atirar de dentro, mesmo com o driveby desligado
	"scorcher",
	"bmx"
}

Config.NotDriveBy = { -- Veículos que NUNCA podem atirar de dentro, mesmo com o driveby ligado
	-- "insurgent" 
}

Config.DriveByExtraWeapons = { -- Armas extras que podem ser usadas em driveby mesmo com ele desligado
	"WEAPON_ACIDPACKAGE"
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- PASSENGER LITE
-----------------------------------------------------------------------------------------------------------------------------------------
Config.PassengerLite = {
	WaitTime = 2000 -- Tempo em milissegundos para a luz interna acender após entrar no veículo
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- ANTI BUMP
-----------------------------------------------------------------------------------------------------------------------------------------
Config.AntiBump = {
	TimeThread = 1000 -- Intervalo em milissegundos entre cada verificação do anti-bump
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- DEL PROPS
-----------------------------------------------------------------------------------------------------------------------------------------
Config.DelProps = {
	TimeToRemove = 50, -- Tempo em milissegundos para o objeto sumir após ser atingido
	PropsToRemove = {
		-- Lixeiras
		"1097506217",
		"1234073471",
		"1238188161",
		"-887773507",
		"-656314730",
		"1911589164",
		"1619828042",
		"-1363583805",
		"-1640716741",
		"1546925534",
		"-1067385262",
		"-460840376",
		"-2031446122",
		"1181703006",
		-- Hidrantes
		"218661250",
		"1462398146",
		"1596482817",
		"1848819579",
		"-995105991",
		-- Postes de iluminação (streetlight)
		"225836909",
		"1158165740",
		"1751732442",
		"1650795134",
		"-678920610",
		"-1034854039",
		"2588825707",
		"-795250282",
		"3286609971",
		"1744232251",
		"-309199146",
		"3701359259",
		"1630524608",
		"2635001677",
		"3408457845",
		-- Lamppost
		"3892824861",
		"3837256917",
		"3515969284",
		"4134216650",
		"3816855049",
		"3173958082",
		"3970525945",
		"3304024420",
		-- Traffic lightset
		"1308102307",
		"2022783228",
		"1989782816",
		"1583029034",
		"3863470591",
		-- Traffic light
		"3797277291",
		"3464998690",
		"1966882937",
		"1878669092",
		"2558659151",
		"2094191395",
		"2347996360",
		"2824048334",
		"2552773503",
		"3745684549",
		"4133798174",
		"3015213668",
		-- Traffic
		"2111131222",
		"3728134962",
		"-655644382",
		"3043293453",
		"3566700348",
		"3152520011",
		"2993990846",
		"2266312683",
		"3632801361",
		"3824093170",
		"3578582629",
		-- FIB light
		"356799118",
		"3790730153",
		"3346309192",
		"3902352668",
		"3062544943",
		-- Placas prop_sign_01 a prop_sign_40
		"3886418409",
		"3940199890",
		"-389156186",
		"-1044379314",
		"3839459087",
		"3392262456",
		"3203778157",
		"2612271077",
		"-1933145636",
		"2691525518",
		"3415166227",
		"2314231966",
		"2017000047",
		"2387877758",
		"2703507606",
		"3005199510",
		"4230971710",
		"3790936350",
		"3733438393",
		"3470644083",
		"3861538154",
		"4013975460",
		"2809806295",
		"2649435529",
		"3504505226",
		"3148355490",
		"4109911040",
		"3334281188",
		"3809025016",
		"2372130067",
		"3171081718",
		"2603663844",
		"3289083739",
		"3550462257",
		"4216446301",
		"3200288233",
		"3612753318",
		"2843083041",
		"3966793546",
		"3613932057",
		-- prop_sign_road_*
		"-949234773",
		"-639994124",
		"-1293825",
		"1452666705",
		"-463994753",
		"455110159",
		"1502931467",
		"-1496457572",
		"-797331153",
		"-1815190559",
		"-1097090961",
		"3613213880",
		"2790900116",
		"3303578344",
		"2965347720",
		"3482223629",
		"2299176030",
		"2288408975",
		"2807434900",
		"2380832236",
		-- prop_sign_interstate_*
		"1933634963",
		"3170114422",
		"3994330106",
		"2975521926",
		"3620730380",
		"3426781886",
		"3877339264",
		-- Placas diversas (freeway, yield, stop, etc.)
		"1960268549",
		"2463792120",
		"2124715395",
		"2962007463",
		"2038768996",
		"2664898266",
		"3162690354",
		"3161521592",
		"3048987250",
		"3759360966",
		"2993248152",
		"2763852613",
		"3707226148",
		"3789418423",
		-- prop_sign_huge_*
		"1340912223",
		"1548225358",
		"1182169279",
		-- Caixas elétricas
		"1204192022",
		"1948311793",
		"2994632902",
		"3110472868",
		"2550986449",
		"1861913907",
		-- Cones de trânsito
		"741314661",
		"741315661",
		"1938449897",
		"1342088940",
		"3693445127",
		"3901703777",
		-- Letterbox
		"3971679103",
		"1757241945",
		-- News disp
		"3971679104",
		"1211559620",
		"3840535804",
		"2300702756",
		"3122744260",
		"1757241946",
		-- Outros (parking, barrier)
		"1083224752",
		"2265619193",
		"1416784241",
		"1283609211",
		"2496900285",
		"3724878145",
		-- Lista original (já funcionava antes)
		"862871082",
		"865627822",
		"-1426008804",
		"-1063472968",
		"-1186769817",
		"-756152956",
		"1043035044",
		"1437508529",
		"431612653",
		"-2007495856",
		"-2008643115",
		"200846641",
		"2108567945",
		"1821241621",
		"1614656839",
		"940495467",
		"-97646180",
		"1388308576",
		"729253480",
		"-628719744",
		"1518466392",
		"-2138350253",
		"-2103798695",
		"589548997",
		"-228596739",
		"-58485588",
		"-1096777189",
		"1948359883",
		"-1386777370",
		"1387151245",
		"393527760",
		"1923262137",
		"-1620823304",
		"267702115",
		"720581693",
		"1381105889",
		"917457845",
		"-1940238623",
		"1419852836",
		"-838860344",
		"1329570871",
		"491238953",
		"1287257122",
		"666561306",
		"1805980844",
		"681787797"
	}
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- POPS & BANGS
-----------------------------------------------------------------------------------------------------------------------------------------
Config.Pnb = {
	debugMode = false, -- Modo de debug para testes (true = mostra informações no console)
	pnbMode = true, -- Ativa o comando /pnb para instalar o estouro no escapamento
	pnbCmd = "pnb", -- Nome do comando para ativar/desativar o estouro
	enableAllVehicles = false, -- Se true, todos os veículos já vêm com estouro sem precisar instalar
	electricModels = { -- Veículos elétricos que NÃO terão estouro no escapamento
		omnisegt = true,
		tezeract = true,
		cyclone = true,
		cyclone2 = true,
		virtue = true,
		raiden = true,
		neon = true,
		voltic = true,
		voltic2 = true,
		iwagon = true,
		powersurge = true,
		bluev = true,
		blumache = true,
		blutrovao = true,
		["blu thor"] = true,
		bluthor = true
	},
	blockedClasses = { -- Classes de veículos que NÃO terão estouro (10=Industrial, 11=Utilitário, 14=Barco, etc.)
		[10] = true,
		[11] = true,
		[14] = true,
		[15] = true,
		[16] = true,
		[17] = true,
		[20] = true,
		[21] = true
	},
	soundMaxDist = 100.0, -- Distância máxima em metros que outros jogadores ouvem o estouro
	PNBFire = {
		SoundPerFlame = true -- Toca um som a cada chama do estouro
	},
	speedCheckInterval = 120, -- Intervalo em milissegundos para checar a velocidade do veículo
	minSpeedKmh = 50, -- Velocidade mínima em km/h para o estouro acontecer
	lowSpeedCutoff = 50, -- Abaixo dessa velocidade, o estouro para de acontecer
	chancePerPop = 1.0, -- Chance de cada estouro acontecer (1.0 = 100%, 0.5 = 50%)
	minDelay = 100, -- Tempo mínimo em milissegundos entre cada estouro
	maxDelay = 200, -- Tempo máximo em milissegundos entre cada estouro
	popDuration = 3500, -- Duração total da sequência de estouros em milissegundos
	Handbrake = { -- Configurações do estouro ao puxar o freio de mão
		enabled = true, -- Ativa estouros ao usar freio de mão
		requireAccel = true, -- Precisa estar acelerando junto com o freio de mão
		minRpm = 0.45, -- RPM mínimo do motor para estourar (0.0 a 1.0)
		minSpeedKmh = 0.0, -- Velocidade mínima em km/h para estourar com freio de mão
		chance = 1.0, -- Chance de estouro no freio de mão (1.0 = 100%)
		minDelay = 60, -- Tempo mínimo entre estouros no freio de mão
		maxDelay = 120 -- Tempo máximo entre estouros no freio de mão
	},
	tick = { -- Intervalos de verificação em milissegundos (quanto menor, mais preciso, mas mais pesado)
		idle = 300, -- Quando está a pé
		passenger = 250, -- Quando é passageiro
		driver_no_install = 180, -- Quando é motorista sem estouro instalado
		driver_installed = 55, -- Quando é motorista com estouro instalado
		handbrake = 20 -- Quando está usando freio de mão + acelerador
	}
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- SPEED LIMITER
-----------------------------------------------------------------------------------------------------------------------------------------
Config.SpeedLimiter = {
	SpeedUnit = "kmh", -- Unidade de velocidade ("kmh" ou "mph")
	MaxSpeed = 300.0, -- Velocidade máxima padrão para todos os veículos
	LimitGlobal = true, -- Se true, aplica o limite de velocidade para todos os veículos (exceto os proibidos)
	ClassesForbiddenGlobal = { -- Classes que NÃO terão limite de velocidade quando LimitGlobal está ligado
		[15] = true, -- Helicópteros
		[16] = true, -- Aviões
		[19] = true -- Militares
	},
	LimitedClasses = { -- Limite de velocidade por classe de veículo (número = velocidade máxima, true = usa MaxSpeed)
		-- [7] = 300.0,
		-- [8] = true
	},
	CustomClasses = { -- Classes customizadas com velocidades específicas (usadas no LimitedModels)
		-- ["S++"] = 252.0,
		-- ["S+"] = true,
		-- ["SpeedPolice"] = 260.0
	},
	LimitedModels = { -- Limite de velocidade por modelo específico (número = velocidade, string = classe customizada, true = usa MaxSpeed)
		-- ["cyclone"] = true,
		-- ["prototipo"] = "S++",
		-- ["comet7"] = 180.0
	}
}


