-- # MechanicEnabled: mecânica do core-vehicles fica desativada quando o core-bennys está startado
------------------------------------------------------------------------------------------------------------------------

function MechanicEnabled()
    return GetResourceState("core-bennys") ~= "started"
end

-- # autoMode: configuração do sistema de orçamentos nas mecânicas
------------------------------------------------------------------------------------------------------------------------

autoMode = {

    commandName = 'pedidos',

    comission = 0.1,

}

-- # DefaultTunnings: tabela de preços padrão (compartilhada pelas mecânicas)
------------------------------------------------------------------------------------------------------------------------

local DefaultTunnings = {

    colors = {

        rgb = 1250,

        types = {
            basic = 500,
            opaque = 750,
            metal = 1000,
            chroma = 2000,
            chameleon = 3500
        },

        pearl = 300,

        wheel = 3333,

        smoke = 5000

    },

    lights = {

        neon = 15000,
        xenon = 7500,
        rgb = 500

    },

    performance = {

        turbo = 25000,

        levelCosts = {

            engine = 50000,
            brakes = 5000,
            transmission = 7000,
            suspension = 12500,
            armour = 100000

        },

    },

    wheels = {

        defaultPrice = 2000,

        customPrices = {

            ['VWT_SPORT'] = 2001,
            ['VWT_MUSCLE'] = 2002,
            ['VWT_LOWRIDER'] = 2003,
            ['VWT_SUV'] = 2004,
            ['VWT_OFFROAD'] = 2005,
            ['VWT_TUNER'] = 2006,
            ['VWT_BIKE'] = 2007,
            ['VWT_HIEND'] = 2008,
            ['VWT_SUPERMOD1'] = 2009,
            ['VWT_SUPERMOD2'] = 2010,
            ['VWT_SUPERMOD3'] = 2011,
            ['VWT_SUPERMOD4'] = 2012,
            ['VWT_SUPERMOD5'] = 5000,

        },

        atomicCustom = 5000,

    },

    windowTints = {

        [0] = 0,
        [1] = 5000,
        [2] = 3000,
        [3] = 2000,
        [4] = 500,
        [5] = 7500,
        [6] = 7500

    },

    plateColors = {

        [0] = 2500,
        [1] = 5000,
        [2] = 5000,
        [3] = 5000,
        [4] = 5000,
        [5] = 5000,

    },

    spoilers = { defaultPrice = 800, customPrices = {} },
    frontBumpers = { defaultPrice = 800, customPrices = {} },
    rearBumpers = { defaultPrice = 800, customPrices = {} },
    skirts = { defaultPrice = 800, customPrices = {} },
    ehxausts = { defaultPrice = 800, customPrices = {} },
    frames = { defaultPrice = 800, customPrices = {} },
    grilles = { defaultPrice = 800, customPrices = {} },
    hoods = { defaultPrice = 800, customPrices = {} },
    fenders = { defaultPrice = 800, customPrices = {} },
    roofs = { defaultPrice = 800, customPrices = {} },
    horns = { defaultPrice = 800, customPrices = {} },
    plates1 = { defaultPrice = 800, customPrices = {} },
    plates2 = { defaultPrice = 800, customPrices = {} },
    seats1 = { defaultPrice = 800, customPrices = {} },
    seats2 = { defaultPrice = 800, customPrices = {} },
    ornaments = { defaultPrice = 800, customPrices = {} },
    dashboards = { defaultPrice = 800, customPrices = {} },
    speakers1 = { defaultPrice = 800, customPrices = {} },
    speakers2 = { defaultPrice = 800, customPrices = {} },
    shiftLevers = { defaultPrice = 800, customPrices = {} },
    steeringWheels = { defaultPrice = 800, customPrices = {} },
    trunks = { defaultPrice = 800, customPrices = {} },
    hidraulics = { defaultPrice = 800, customPrices = {} },
    airFilters = { defaultPrice = 800, customPrices = {} },
    supports = { defaultPrice = 800, customPrices = {} },
    headlights = { defaultPrice = 800, customPrices = {} },
    trimDesigns = { defaultPrice = 800, customPrices = {} },
    tanks = { defaultPrice = 800, customPrices = {} },
    decals = { defaultPrice = 800, customPrices = {} },
    windows = { defaultPrice = 800, customPrices = {} },
    aerials = { defaultPrice = 800, customPrices = {} },

}

-- # mechanics: cadastro das mecânicas
------------------------------------------------------------------------------------------------------------------------

mechanics = {

    ['mechanicName'] = {

        coords = {
            {48.39,-878.02,30.37,151.54}
        },

        blips = { enabled = true, id = 523, color = 61, size = 0.55, name = 'Mecânica' },

        autoMode = true,

        permission = 'Ballas',

        disablePerfTunnings = false,

        onlyPerfTunnings = false,

        tunnings = DefaultTunnings,

    },

    ['Bennys'] = {

        coords = {
            {-213.95,-1348.08,31.54,272.13},
            {-214.27,-1342.94,31.54,272.13},
            {-214.14,-1337.98,31.54,272.13},
            {-214.10,-1333.02,31.54,272.13},
            {-204.58,-1333.01,31.54,272.13},
            {-204.51,-1337.98,31.54,272.13},
            {-204.63,-1342.94,31.54,272.13},
            {-204.64,-1348.11,31.54,272.13}
        },

        blips = { enabled = false },

        autoMode = true,

        permission = 'Bennys',

        disablePerfTunnings = false,

        onlyPerfTunnings = false,

        tunnings = DefaultTunnings,

    }

}

-- # disable_mechanic_rotation: desabilitar a rotação de veículos
disable_mechanic_rotation = false
