-- # vehiclesVerbose: exibir mensagens de inicialização no console do servidor
vehiclesVerbose = false

------------------------------------------------------------------------------------------------------------------------
-- # ThemeColor: cor principal da UI.
-- Theme.main (vrp/config/Global.lua) tem prioridade quando definido.
------------------------------------------------------------------------------------------------------------------------

ThemeColor = "#dc1553"

-- # debugMode: exibir mensagens de debug (tunning, mods, etc) no console do client
debugMode = false



------------------------------------------------------------------------------------------------------------------------
-- # fixed_rental_plates: gerar placas permanentes para veículos alugados (temporários/garagens do tipo 'SERVICE') -> permite salvar tunnings, porta-malas.
------------------------------------------------------------------------------------------------------------------------

fixed_rental_plates = true

------------------------------------------------------------------------------------------------------------------------
-- # vehMenu: menu de veículos integrado
------------------------------------------------------------------------------------------------------------------------

vehMenu = {

    -- # habilitar menu
    enabled = true,

    -- # tecla do menu (segure p usar)
    key = 'M'

}

------------------------------------------------------------------------------------------------------------------------
-- # autoLockAIVehicles: habilitar o sistema de não usar veículos de NPC
------------------------------------------------------------------------------------------------------------------------

-- # Verifique a documentação para integração de lockpick, etc - https://docs.snt.gg/
autoLockAIVehicles = true

------------------------------------------------------------------------------------------------------------------------
-- # aiVehicleHotwire: ligar veículo de NPC furtado pelo minigame de fios (wiregame)
------------------------------------------------------------------------------------------------------------------------

aiVehicleHotwire = {

    -- # habilitar o minigame ao tentar ligar o motor de um veículo de NPC
    enabled = true,

    -- # controle usado para tentar ligar o motor (20 = mesma tecla de ligar o veículo)
    control = 20,

    -- # tecla exibida na dica em tela
    key = 'Z',

    -- # duração do minigame, em segundos
    duration = 30,

    -- # espera entre uma tentativa e outra, em milissegundos
    cooldown = 5000

}

------------------------------------------------------------------------------------------------------------------------
-- # API (client-side hooks)
------------------------------------------------------------------------------------------------------------------------

API = {

    -- quando um veículo de teste drive é criado.
    ['onTestDriveVehicleCreation'] = function(entity)

        --[[
            Parâmetros:
            * entity: entidade do veículo
        --]]

        -- print('onTestDriveVehicleCreation',entity)

    end,

}
