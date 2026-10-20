testDrive = {

    -- # pagar para realizar o teste drive? Se sim, insira o valor. caso quueira gratuito, deixe 0.
    payment = 200,

    -- # coordenadas do teste drive
    coords = {-1700.43,-2934.25,13.95,239.57},

    -- # tempo limite do teste drive
    time = 120,

    -- # placa dos veículos spawnados no teste drive
    plate = 'PDMSPORT'

}

------------------------------------------------------------------------------------------------------------------------
-- # dealerships: cadastro/configuração das concessionárias
------------------------------------------------------------------------------------------------------------------------

dealerships = {

    {

        -- # permissão para acessar. sem permissão deixe: nil
        permission = nil,
        -- # gerar blip automaticamente no mapa (GPS)
        blips = { enabled = false, id = 523, color = 61, size = 0.55, name = 'Concessionária' },

        -- # coordenada onde será possível acessar esta configuração de concessionária
        coords = {-784.07,-212.87,37.0,303.31},

        -- # visualizador de veículos (spawnar o veículo durante o menu da concessionária), caso não queira remova completamente a sessão 'modelViewer' abaixo.
        modelViewer = {
            ped = {-798.02,-221.4,37.04,297.64},
            vehicle = {-793.49,-218.14,37.15,119.06}
        },

        -- # categorias desabilitadas nesta concessionária
        disabledCategories = {}

    },

}

-- # disable_dealership_rotation: desabilitar a rotação de veículos (útil para mecânicas que o espaço de visualização é pequeno)
disable_dealership_rotation = false

-- # infiniteStock: habilitar estoque infinito (ignora banco de dados para controle de estoque)
infiniteStock = true

-- # descontos por permissão, formato: ['permissao'] = porcentagem,
permissionDiscounts = {
    ['owner'] = 50
}

------------------------------------------------------------------------------------------------------------------------
-- # sellBack: configuração da venda de veículos de volta para a concessionária
------------------------------------------------------------------------------------------------------------------------

sellBack = {

    -- # habilitar sistema?
    enabled = true,

    -- # valor que será vendido o veículo (porcentagem do valor original, em decimal)
    percentFromPrice = 0.2,

    -- # categorias nas quais os veículos não podem ser vendidos de volta para a concessionária
    blockedCategories = {
        ['vip'] = true,
        ['vip_air'] = true,
        ['vip_water'] = true,

    },

    -- # bloquear a venda de determinados veículos de volta à concessionára pelo seu index
    blockedModels = {
        ['panto'] = true
    }

}

------------------------------------------------------------------------------------------------------------------------
-- # purchaseColorOptions: opções de cores pré-definidas na compra de véiculos, insira quantas quiser.
------------------------------------------------------------------------------------------------------------------------

purchaseColorOptions = {

    -- # primárias
    primary = {
        '#000000', '#ffffff', '#f50202', '#f55f02', '#ffea00', '#a6ff00', '#33ff00', '#00ffc3',
        '#00aeff', '#0026ff', '#5100ff', '#8c00ff', '#d900ff', '#ff00ea', '#ff00a2', '#ffa1e1',
        '#2c0e3d', '#100e3d', '#060273', '#024a73', '#02735c', '#02730f', '#407302', '#b04604',
        '#8ed62f', '#00008B', '#607B8B', '##FF82AB', '##8B8386', '#8B0000', '#FFB90F', '#828282',
        '#90EE90', '#008B8B', '#FFA54F', '##68228B', '#54FF9F', '#4682B4', '#FF3E96', '#8B4513'
    },

    -- # secundárias
    secondary = {
        '#000000', '#ffffff', '#f50202', '#f55f02', '#ffea00', '#a6ff00', '#33ff00', '#00ffc3',
        '#00aeff', '#0026ff', '#5100ff', '#8c00ff', '#d900ff', '#ff00ea', '#ff00a2', '#ffa1e1',
        '#2c0e3d', '#100e3d', '#060273', '#024a73', '#02735c', '#02730f', '#407302', '#b04604',
        '#8ed62f', '#00008B', '#607B8B', '##FF82AB', '##8B8386', '#8B0000', '#FFB90F', '#828282',
        '#90EE90', '#008B8B', '#FFA54F', '##68228B', '#54FF9F', '#4682B4', '#FF3E96', '#8B4513'
    }

}
