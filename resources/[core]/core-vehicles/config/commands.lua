-- # commands: comandos para administração
------------------------------------------------------------------------------------------------------------------------

commands = {

    ['spawnVehicles'] = {
        enabled = true,
        name = 'car',
        permission = {'Admin'},
    },

    ['despawnVehicles'] = {
        enabled = true,
        name = 'dv',
        permission = {'Admin','Militar','Civil','CORE','BOPE','PRF'},
    },

    ['despawnAreaVehicles'] = {
        enabled = true,
        name = 'dvarea',
        maxRadius = 100,
        permission = {'Admin'},
    },

    ['fixVehicles'] = {
        enabled = true,
        name = 'fixar',
        permission = {'Admin'},
    },

    ['stockManager'] = {
        enabled = true,
        name = 'vstock',
        permission = {'Admin'},
    },

    ['characterVehManager'] = {
        enabled = true,
        name = 'vmanager',
        permission = {'Admin'},
    },

    ['garageManager'] = {
        enabled = true,
        name = 'gmanager',
        permission = {'Admin'},
    },

}


-- # borrowSystem: sistema de empréstimo de veículos pela garagem (dar chave)
------------------------------------------------------------------------------------------------------------------------

borrowSystem = {

    enabled = false,

    blockedCategories = {
        ['vip'] = true,
        ['vip_water'] = true,
        ['vip_air'] = true
    },

    blockedModels = {
        ['zentorno'] = true,
    }

}


-- # sellSystem: sistema de venda de veículos entre personagens, pela garagem (vender para jogador próximo)
------------------------------------------------------------------------------------------------------------------------

sellSystem = {

    enabled = false,

    blockedCategories = {
        ['vip'] = true,
        ['vip_water'] = true,
        ['vip_air'] = true
    },

    blockedModels = {
        ['zentorno'] = true,
    },

}


-- # vehicleTaxes: sistema de taxas de veículos (IPVA)
------------------------------------------------------------------------------------------------------------------------

vehicleTaxes = {

    durationInDays = 7,

    percentFromPrice = 0.05

}


-- # logsWebhooks: webhooks (discord) para envio de logs
------------------------------------------------------------------------------------------------------------------------

logsWebhooks = {

    ['spawnVehicles'] = '',
    ['despawnVehicles'] = '',
    ['stockManager'] = '',
    ['characterVehManager'] = '',
    ['garageManager'] = '',
    ['dealershipPurchases'] = '',
    ['dealershipRented'] = '',
    ['dealershipSold'] = '',
    ['charSold'] = '',
    ['tunnings'] = ''

}
