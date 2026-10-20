local FishingDuration = 10000

Config.professions = {

	["minerador"] = {
		name = "Mineração",
		description = "Realize a mineração de metais e pedras preciosas. Trabalho braçal, sob o forte sol presente na mineradora.",
		image = "minerador.png",
		expGainPerCollect = 50,
        clothes = {
            ["male"] = {
                ["decals"] = {-1,0}, ["shirts"] = {171,0}, ["vests"] = {-1,0}, ["shoes"] = {24,0},
                ["jackets"] = {0,2}, ["hats"] = {0,4}, ["hands"] = {19,0}, ["bags"] = {-1,0}, ["pants"] = {31,3},
            },
            ["female"] = {
                ["decals"] = {-1,0}, ["shirts"] = {208,0}, ["hands"] = {20,0}, ["jackets"] = {49,1},
                ["hats"] = {0,4}, ["shoes"] = {24,0}, ["vests"] = {-1,0}, ["bags"] = {-1,0}, ["pants"] = {30,3},
            }
        },
        collectItems = {
            { item = "silver", amount = {1,3} },
        },
        extraItems = {
            { item = "gold", amount = {1,2} },
            { item = "ruby", amount = {1,1} },
            { item = "diamond", amount = {1,1} },
        },
        extraItemsChance = 5,
	},

    ["entregador-jornais"] = {
		name = "Jornaleiro",
		description = "Entregue jornais atirando-os nas residências demarcadas. Pegue sua bicicleta e cumpra as cotas!",
		image = "jornaleiro.png",
        expGainPerCollect = 2,
        collectItems = {
            { item = "dollar", amount = {100,150} },
        },
	},

    ["reboque"] = {
		name = "Rebocador",
		description = "Utilize um caminhão prancha para rebocar veículos abandonados pela cidade e trazê-los para o pátio.",
		image = "reboque.png",
        expGainPerCollect = 5,
        collectItems = {
            { item = "dollar", amount = {350,600} }
        },
	},

    ["cegonha"] = {
		name = "Cegonha",
		description = "Utilize um caminhão Packer para transportar pranchas cegonheiras cheias de veículos até as concessionárias do estado.",
		image = "cegonha.png",
        expGainPerCollect = 15,
        collectItems = {
            { item = "dollar", amount = {1800,2200} },
        },
	},

    ["taxista"] = {
		name = "Taxista",
		description = "Leve passageiros para os seus destinos utilizando o seu táxi. Cada corrida gera dinheiro e experiência!",
		image = "taxi.png",
        expGainPerCollect = 3,
        collectItems = {
            { item = "dollar", amount = {275,325} }
        },
	},

    ["motorista"] = {
		name = "Motorista de Condução",
		description = "Realize a condução dos ônibus de transporte público, coletando e entregando passageiros por toda a cidade.",
		image = "motorista.png",
        expGainPerCollect = 20,
        clothes = {
            ["male"] = {
                ["decals"] = {-1,0}, ["shirts"] = {15,0}, ["vests"] = {-1,0}, ["jackets"] = {13,1},
                ["hands"] = {11,0}, ["shoes"] = {3,3}, ["bags"] = {-1,0}, ["pants"] = {10,0},
            },
            ["female"] = {
                ["decals"] = {-1,0}, ["shirts"] = {72,0}, ["hands"] = {3,0}, ["vests"] = {-1,0},
                ["shoes"] = {13,0}, ["jackets"] = {7,8}, ["bags"] = {-1,0}, ["pants"] = {6,1},
            }
        },
        collectItems = {
            { item = "dollar", amount = {50,120} },
        },
	},

    ["pescador"] = {
		name = "Pescador",
		description = "Trabalho tranquilo e relaxante. Ótimo para ganhar uma grana e dar uma pensada na vida. Navegue pelas águas e obtenha pescados para vender.",
		image = "pescador.png",
		startNotification = "Vá primeiro ao Mercado Central marcado no GPS, no mesmo local onde o Jornaleiro compra jornais, e compre uma vara de pescar e iscas.",
		expGainPerCollect = 50,
        collectDuration = FishingDuration,
        clothes = {
            ["male"] = {
                ["shoes"] = {24,0}, ["hands"] = {5,0}, ["shirts"] = {-1,0}, ["vests"] = {-1,0},
                ["pants"] = {94,0}, ["jackets"] = {369,6}, ["decals"] = {-1,0}, ["bags"] = {-1,0},
            },
            ["female"] = {
                ["shoes"] = {24,0}, ["pants"] = {97,0}, ["shirts"] = {7,0}, ["vests"] = {-1,0},
                ["hands"] = {11,0}, ["jackets"] = {233,2}, ["decals"] = {-1,0}, ["bags"] = {-1,0},
            }
        },
        requiredItems = {
            { items = { "fishingrod", "fishingrod2", "fishingrod3", "fishingrod4", "fishingrodplus" }, notify = "Você precisa de uma vara de pescar." },
            { items = { "bait" }, consume = 1, notify = "Você precisa de isca para pescar." }
        },
        taskCollect = function(src,characterId)
            TriggerClientEvent("snt/animations/play",src,{ dict = "amb@world_human_stand_fishing@idle_a", anim = "idle_c", walk = false, loop = true, prop = "prop_fishing_rod_01", bone = 60309 })
			TriggerClientEvent("snt/animations/setBlocked",src,true)
            TriggerClientEvent("snt/inventory/setBlocked",src,true)
            TriggerClientEvent("Progress",src,"Pescando",FishingDuration)
            Wait(FishingDuration)

            if not Functions or Functions.getUserSource(characterId) ~= src then
                return false
            end

            TriggerClientEvent("snt/animations/stop",src)
            TriggerClientEvent("snt/animations/setBlocked",src,false)
            TriggerClientEvent("snt/inventory/setBlocked",src,false)
            return true
        end,
        collectItems = {
            { item = "fish", amount = {1, 3} }
        }
    },

    ["lixeiro"] = {
		name = "Lixeiro",
		description = "Em conjunto ao Projeto Recilar, este emprego tem o objetivo de promover a limpeza da cidade. Realize a coleta de lixo.",
		image = "lixeiro.png",
		expGainPerCollect = 30,
        clothes = {
            ["male"] = {
                ["shirts"] = {59,0}, ["hands"] = {19,0}, ["shoes"] = {24,0}, ["jackets"] = {0,1},
                ["pants"] = {31,1}, ["bags"] = {-1,0}, ["vests"] = {-1,0}, ["decals"] = {-1,0}
            },
            ["female"] = {
                ["shoes"] = {24,0}, ["shirts"] = {36,0}, ["hands"] = {20,0}, ["jackets"] = {49,0},
                ["pants"] = {30,1}, ["bags"] = {-1,0}, ["vests"] = {-1,0}, ["decals"] = {-1,0}
            }
        },
        collectItems = {
            { item = "dollar", amount = {50,120} },
        },
        extraItemsChance = 25,
        extraItems = {
            { item = "aluminum", amount = {1,5} },
            { item = "emptybottle", amount = {1,5} },
        }
	},

    ["agricultor-trigo"] = {
		name = "Agricultor | Trigo",
		description = "Em contato com belas vistas no campo, realize a colheita de trigo na fazenda utilizando um trator. Recomendado aos aspirantes à agroboy!",
		image = "agricultor-trigo.png",
        expGainPerCollect = 30,
        clothes = {
            ["male"] = {
                ["shoes"] = {52,0}, ["hands"] = {0,0}, ["bags"] = {-1,0}, ["shirts"] = {2,0},
                ["vests"] = {-1,0}, ["pants"] = {130,0}, ["jackets"] = {404,1}, ["decals"] = {-1,0},
            },
            ["female"] = {
                ["shoes"] = {53,0}, ["hands"] = {0,0}, ["bags"] = {-1,0}, ["shirts"] = {59,0},
                ["vests"] = {-1,0}, ["pants"] = {136,0}, ["jackets"] = {428,1}, ["decals"] = {-1,0},
            }
        },
        collectItems = {
            { item = "wheat", amount = {1,2} },
        },
	},

    ["agricultor-laranjas"] = {
		name = "Agricultor | Laranjas",
		description = "Em contato com belas vistas no campo, realize a colheita de laranjas, manualmente. Recomendado aos aspirantes à agroboy!",
		image = "agricultor-laranjas.png",
        expGainPerCollect = 30,
        clothes = {
            ["male"] = {
                ["shoes"] = {52,0}, ["hands"] = {0,0}, ["bags"] = {-1,0}, ["shirts"] = {2,0},
                ["vests"] = {-1,0}, ["pants"] = {130,2}, ["jackets"] = {404,4}, ["decals"] = {-1,0},
            },
            ["female"] = {
                ["shoes"] = {53,0}, ["hands"] = {0,0}, ["bags"] = {-1,0}, ["shirts"] = {59,0},
                ["vests"] = {-1,0}, ["pants"] = {136,2}, ["jackets"] = {428,4}, ["decals"] = {-1,0},
            }
        },
        collectItems = {
            { item = "orange", amount = {1,5} },
        },
	},

    ["lenhador"] = {
		name = "Lenhador",
		description = "Realize o corte de árvores para coleta de toras de madeira e venda-as na Cabana do Campo.",
		image = "lenhador.png",
		startNotification = "Vá primeiro ao Mercado Central marcado no GPS, no mesmo local onde o Jornaleiro compra jornais, e compre um Machado.",
        expGainPerCollect = 50,
        clothes = {
            ["male"] = {
                ["shoes"] = {24,0}, ["hands"] = {33,1}, ["bags"] = {-1,0}, ["shirts"] = {-1,0},
                ["vests"] = {-1,0}, ["pants"] = {33,0}, ["jackets"] = {126,1}, ["decals"] = {-1,0},
            },
            ["female"] = {
                ["shoes"] = {24,0}, ["pants"] = {32,0}, ["bags"] = {-1,0}, ["shirts"] = {59,0},
                ["vests"] = {-1,0}, ["hands"] = {36,1}, ["jackets"] = {121,1}, ["decals"] = {-1,0},
            }
        },
        collectItems = {
            { item = "wood", amount = {1,5} },
        }
	},

    ["eletricista"] = {
        name = "Eletricista",
		description = "Realize a manutenção das caixas elétricas pela cidade.",
		image = "eletricista.png",
        expGainPerCollect = 20,
        clothes = {
            ["male"] = {
                ["shoes"] = {24,0}, ["pants"] = {33,0}, ["bags"] = {-1,0}, ["shirts"] = {182,0},
                ["vests"] = {-1,0}, ["hands"] = {179,0}, ["jackets"] = {111,0}, ["decals"] = {-1,0},
            },
            ["female"] = {
                ["shoes"] = {24,0}, ["hands"] = {223,0}, ["bags"] = {-1,0}, ["shirts"] = {219,0},
                ["vests"] = {-1,0}, ["pants"] = {32,0}, ["jackets"] = {43,1}, ["decals"] = {-1,0},
            }
        },
        collectItems = {
            { item = "dollar", amount = {50,120} },
        }
    },

    ["entregador"] = {
        name = "Entregador",
		description = "Realize entregas de pedidos de restaurantes por toda a cidade.",
		image = "entregador.png",
        expGainPerCollect = 20,
        clothes = {
            ["male"] = {
                ["shoes"] = {1,1}, ["hands"] = {1,0}, ["bags"] = {-1,0}, ["shirts"] = {0,1},
                ["vests"] = {-1,0}, ["pants"] = {0,0}, ["jackets"] = {7,0}, ["decals"] = {-1,0},
            },
            ["female"] = {
                ["shoes"] = {1,0}, ["hands"] = {3,0}, ["bags"] = {-1,0}, ["shirts"] = {7,0},
                ["vests"] = {-1,0}, ["pants"] = {0,0}, ["jackets"] = {3,0}, ["decals"] = {-1,0},
            }
        },
        collectItems = {
            { item = "dollar", amount = {50,120} },
        }
    }
}
