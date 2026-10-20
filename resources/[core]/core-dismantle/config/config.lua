Dismantle = {}

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COR DO TEMA
-- Define a cor principal usada na interface NUI (painéis, botões, destaques).
-- Formato: string hexadecimal CSS (ex: "#dc1553", "#e8891a")
----------------------------------------------------------------------------------------------------------------------------------------------------------------

Dismantle.ThemeColor = "#dc1553"

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SESSION VERIFIER
-- Bloqueia a utilização do desmanche quando o jogador estiver em outra rota (sessão/dimensão) diferente da padrão (0).
----------------------------------------------------------------------------------------------------------------------------------------------------------------

Dismantle.SessionVerifier = true

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DESMANCHE DE VEÍCULOS DE NPC
-- Permite desmanchar veículos não-networked (carros de NPC trazidos pelo player).
-- true  = pode desmanchar carro de NPC
-- false = só veículos do player (padrão original)
----------------------------------------------------------------------------------------------------------------------------------------------------------------

Dismantle.AllowNpcVehicles = true

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TIMERS
-- Configuração dos tempos do desmanche.
----------------------------------------------------------------------------------------------------------------------------------------------------------------

Dismantle.Timers = {
    -- Tempo em segundos para iniciar o desmanche (todos entrarem no veículo)
    Lobby = 15,
    -- Tempo em segundos para finalizar o desmanche até que o veículo seja removido automaticamente
    Progress = 300,
}

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COMMAND
-- Nome do comando para abrir o painel de gerenciamento do desmanche.
-- Uso: /desmanche [id-do-desmanche]
----------------------------------------------------------------------------------------------------------------------------------------------------------------

Dismantle.PanelCommand = "desmanche"

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TEMPOS DE QUEBRA
-- Tempo em milissegundos para desmanchar cada parte do veículo.
----------------------------------------------------------------------------------------------------------------------------------------------------------------

Dismantle.PartsTimes = {
    -- Portas
    ["door_dside_f"] = 10000,
    ["door_dside_r"] = 10000,
    ["door_pside_f"] = 10000,
    ["door_pside_r"] = 10000,
    -- Rodas
    ["wheel_lf"] = 7000,
    ["wheel_lr"] = 7000,
    ["wheel_rf"] = 7000,
    ["wheel_rr"] = 7000,
    ["wheel_lm1"] = 7000,
    ["wheel_rm1"] = 7000,
    -- Bateria / Motor
    ["engine"] = 15000,
    -- Escapamento
    ["exhaust"] = 7000,
}

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ITENS DAS PEÇAS
-- Define qual item do inventário será entregue para cada tipo de peça desmanchada.
-- As chaves correspondem às categorias de peças: money, doors, wheels, ehxausts, batteries.
----------------------------------------------------------------------------------------------------------------------------------------------------------------

Dismantle.PartItems = {
    ["money"]     = "dollars",
    ["doors"]     = "pizza",
    ["wheels"]    = "pizza",
    ["ehxausts"]  = "pizza",
    ["batteries"] = "pizza",
}

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VALORES DOS VEÍCULOS
-- Define o valor base de cada veículo e a porcentagem que o player recebe ao desmanchar.
-- Ordem de prioridade do lookup:
--   1. Dismantle.CustomClasses     → classes customizadas (agrupa modelos com valor compartilhado)
--   2. Dismantle.VehiclePrices     → classe nativa do GTA V
--   3. Dismantle.DefaultVehiclePrice → fallback geral
-- Use Dismantle.GetVehiclePriceInfo(modelHash, vehicleClass) para obter (price, percent).
----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Valor base padrão para veículos sem entrada específica
Dismantle.DefaultVehiclePrice = 50000

-- Porcentagem padrão para veículos FORA das custom classes (ex: NPC vehicles)
-- 0.90 = 90% do valor vai pro player
Dismantle.DefaultPaymentPercent = 0.90

-- Valores por classe nativa do GTA V
Dismantle.VehiclePrices = {
    ["0"]  = 10000,  -- Compacts
    ["1"]  = 14000,  -- Sedans
    ["2"]  = 18000,  -- SUVs
    ["3"]  = 25000,  -- Coupes
    ["4"]  = 28000,  -- Muscle
    ["5"]  = 32000,  -- Sports Classics
    ["6"]  = 40000,  -- Sports
    ["7"]  = 120000, -- Super
    ["8"]  = 20000,  -- Motorcycles
    ["9"]  = 22000,  -- Off-road
    ["10"] = 15000,  -- Industrial
    ["11"] = 12000,  -- Utility
    ["12"] = 16000,  -- Vans
    ["17"] = 8000,   -- Service
    ["18"] = 0,      -- Emergency
    ["19"] = 80000,  -- Military
    ["20"] = 18000,  -- Commercial
}

-- Classes customizadas: agrupa modelos (spawn name) com valor e porcentagem próprios
-- price   → valor base do veículo
-- percent → porcentagem que o player recebe (0.0 = nada vai pro player)
-- models  → lista de spawn names que pertencem a esta classe
Dismantle.CustomClasses = {
    ["luxo"] = {
        price   = 200000,
        percent = 0.0,
        models  = { "adder", "zentorno", "t20", "osiris" },
    },
    ["tuner"] = {
        price   = 60000,
        percent = 0.0,
        models  = { "sultan", "elegy", "kuruma" },
    },
    ["popular"] = {
        price   = 6000,
        percent = 0.0,
        models  = { "blista", "panto", "issi" },
    },
}

-- Retorna (price, percent) baseado no modelo/classe do veículo
Dismantle.GetVehiclePriceInfo = function(vehicleModelHash, vehicleClass)
    if not Dismantle._customClassCacheBuilt then
        Dismantle._modelToCustomInfo = {}
        for _, classData in pairs(Dismantle.CustomClasses or {}) do
            if classData and classData.price and classData.models then
                local classPercent = classData.percent or 0.0
                for _, modelName in ipairs(classData.models) do
                    Dismantle._modelToCustomInfo[GetHashKey(modelName)] = {
                        price   = classData.price,
                        percent = classPercent,
                    }
                end
            end
        end
        Dismantle._customClassCacheBuilt = true
    end

    if vehicleModelHash and Dismantle._modelToCustomInfo[vehicleModelHash] then
        local info = Dismantle._modelToCustomInfo[vehicleModelHash]
        return info.price, info.percent
    end

    local price = Dismantle.VehiclePrices[tostring(vehicleClass)] or Dismantle.DefaultVehiclePrice
    return price, Dismantle.DefaultPaymentPercent
end

-- Compat: retorna apenas o preço (mantido caso código externo use)
Dismantle.GetVehiclePrice = function(vehicleModelHash, vehicleClass)
    local price = Dismantle.GetVehiclePriceInfo(vehicleModelHash, vehicleClass)
    return price
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INTERAÇÃO
-- Configura o sistema de interação 3D usado para iniciar o desmanche.
-- Sistemas suportados: "marker" (padrão)
----------------------------------------------------------------------------------------------------------------------------------------------------------------

Dismantle.Interaction = {
    -- Distância em metros para desenhar os marcadores no chão
    DrawDistance = 25.0,
    -- Distância em metros para exibir a opção de interação (tecla E)
    InteractDistance = 10.0,
    -- Distância em metros para permitir iniciar o desmanche (dentro do veículo)
    StartDistance = 1.2,
    -- Tecla de interação (38 = E)
    Key = 38,
}

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ÁREAS BLOQUEADAS
-- Define áreas no mapa onde não é permitido instalar o desmanche.
-- Formato: { center = vec3(x, y, z), radius = número }
----------------------------------------------------------------------------------------------------------------------------------------------------------------

Dismantle.BlockedAreas = {
    { center = vec3(-1268.62, -1482.11, 4.31), radius = 60 },
}

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHECK VEHICLE
-- Função para verificar se um veículo pode ou não ser desmanchado.
-- Retorne true para permitir, false para bloquear.
---@param vehicleEntity number  Entidade do veículo (server-side)
---@param vehiclePlate  string  Placa do veículo
---@param vehicleModel  number  Hash do modelo do veículo
---@param vehicleClass  string  Classe do veículo (string numérica)
---@return boolean
----------------------------------------------------------------------------------------------------------------------------------------------------------------

Dismantle.CanVehicleBeDismantled = function(vehicleEntity, vehiclePlate, vehicleModel, vehicleClass)
    return true
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PAGAMENTO
-- Função de pagamento após o término do desmanche (por tempo ou todas as peças desmanchadas).
---@param source         number   Source do jogador líder
---@param userId         number   User ID (vRP) do líder
---@param data           table    Dados do desmanche
---@param overTime       boolean  Se true, o desmanche foi encerrado por acabar o tempo
---@return void
----------------------------------------------------------------------------------------------------------------------------------------------------------------

Dismantle.OnPayment = function(source, userId, data, overTime)
    --[[
        data.dismantleId          → ID do desmanche
        data.hasPanel             → Se o desmanche tem painel
        data.isPublicWork         → Se o desmanche foi feito como público
        data.publicPaymentPercent → Porcentagem do pagamento definida pelo painel
        data.items                → Itens referentes às partes desmanchadas { doors = N, wheels = N, ... }
        data.vehiclePlate         → Placa do veículo desmanchado
        data.vehicleModel         → Hash do modelo do veículo
        data.vehicleClass         → Classe do veículo
    ]]

    local dismantleId          = data.dismantleId
    local hasPanel             = data.hasPanel
    local isPublicWork         = data.isPublicWork
    local publicPaymentPercent = data.publicPaymentPercent
    local items                = data.items

    -- Valor base do veículo + porcentagem de pagamento (custom class > classe GTA > default)
    local price, percent = Dismantle.GetVehiclePriceInfo(data.vehicleModel, data.vehicleClass)
    local dirtyAmount = math.floor(price * percent)

    -- Marca o veículo como desmanchado pra garagem cobrar recuperação ao retirá-lo.
    -- Carro de NPC não está em core_characters_vehicles, então o update retorna false silenciosamente.
    if data.vehiclePlate and exports['core-vehicles'] and exports['core-vehicles'].updateVehicleStatus then
        pcall(function()
            exports['core-vehicles']:updateVehicleStatus(data.vehiclePlate, 'DISMANTLED')
        end)
    end

    if hasPanel then
        -- Painel existe: peças sempre vão para o painel
        for removedPart, partAmount in pairs(items) do
            Functions.addItemsToDismantlePanel(dismantleId, removedPart, partAmount)
        end

        if not overTime then
            if isPublicWork then
                -- Público: trabalhador recebe sua porcentagem, restante vai pro painel
                local publicPayment = math.floor(dirtyAmount * (publicPaymentPercent / 100))
                local panelPayment  = dirtyAmount - publicPayment

                Functions.giveItem(userId, "dirtymoney", publicPayment)

                if panelPayment > 0 then
                    Functions.addItemsToDismantlePanel(dismantleId, "money", panelPayment)
                end
            else
                -- Privado: dono fez o próprio desmanche, dinheiro vai direto para o painel
                Functions.addItemsToDismantlePanel(dismantleId, "money", dirtyAmount)
            end
        end
    else
        -- Sem painel: peças e dinheiro vão direto para o líder
        for removedPart, partAmount in pairs(items) do
            if Dismantle.PartItems[removedPart] and partAmount > 0 then
                local itemSpawn = Dismantle.PartItems[removedPart]
                Functions.giveItem(userId, itemSpawn, partAmount)
            end
        end

        if not overTime then
            Functions.giveItem(userId, "dirtymoney", dirtyAmount)
        end
    end

    if GetResourceState("core_logs") == "started" then
        local parts = ""
        for removedPart, partAmount in pairs(items) do
            parts = parts .. (parts ~= "" and ", " or "") .. removedPart .. " x" .. partAmount
        end

        exports["core_logs"]:AddLog("DESMANCHE", {
            message    = Functions.getUserName(userId) .. " #" .. userId .. " desmanchou o veículo de placa " .. (data.vehiclePlate or "Desconhecida"),
            playerName = Functions.getUserName(userId),
            playerId   = userId,
            Placa      = data.vehiclePlate,
            Desmanche  = dismantleId,
            Pecas      = parts ~= "" and parts or "Nenhuma",
            Valor      = dirtyAmount,
            Modo       = hasPanel and (isPublicWork and "Público (painel)" or "Privado (painel)") or "Sem painel",
            TempoEsgotado = overTime and "Sim" or "Não",
        })
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DESMANCHES
-- Cada entrada define um ponto de desmanche no mapa.
-- Campos:
--   name           → Nome do desmanche exibido na interface
--   cooldown       → Cooldown em segundos entre cada veículo desmanchado
--   hasPanel       → Se este desmanche possui painel de gerenciamento
--   permissions    → Permissões necessárias (use = desmanchar, manage = gerenciar painel)
--   coords         → Coordenadas { vehicle = {x,y,z,heading}, shelf = {x,y,z,heading} }
--   allowedClasses → Classes de veículos permitidas { ["0"] = true, ... }
--   allowedRelocationArea → (opcional) área onde o painel pode mover este desmanche
--                           { center = vec3(x,y,z), radius = número }. Omitido = sem restrição.
----------------------------------------------------------------------------------------------------------------------------------------------------------------

Dismantle.Locations = {

    -- Yellow Jack (Desmanche1)
    ["desmanche-1"] = {
        name = "Yellow Jack",
        cooldown = 60,
        hasPanel = true,
        permissions = {
            use    = "Desmanche1",
            manage = "Desmanche1",
        },
        coords = {
            vehicle = { 1984.42, 3033.06, 47.11, 235.28 },
            shelf   = { 1989.59, 3035.36, 47.11, 334.49 },
        },
        allowedClasses = {
            ["0"]  = true, ["1"]  = true, ["2"]  = true, ["3"]  = true,
            ["4"]  = true, ["5"]  = true, ["6"]  = true, ["7"]  = true,
            ["8"]  = true, ["9"]  = true, ["10"] = true, ["11"] = true,
            ["12"] = true, ["17"] = false, ["18"] = false, ["19"] = false,
            ["20"] = true,
        },
        allowedRelocationArea = {
            center = vec3(1984.42, 3033.06, 47.11),
            radius = 250.0,
        },
    },

    -- Racha Cranios (Desmanche2)
    ["desmanche-2"] = {
        name = "Racha Cranios",
        cooldown = 60,
        hasPanel = true,
        permissions = {
            use    = "Desmanche2",
            manage = "Desmanche2",
        },
        coords = {
            vehicle = { 1203.83, -3116.55, 5.54, 175.75 },
            shelf   = { 1198.37, -3119.82, 5.54, 90.71 },
        },
        allowedClasses = {
            ["0"]  = true, ["1"]  = true, ["2"]  = true, ["3"]  = true,
            ["4"]  = true, ["5"]  = true, ["6"]  = true, ["7"]  = true,
            ["8"]  = true, ["9"]  = true, ["10"] = true, ["11"] = true,
            ["12"] = true, ["17"] = false, ["18"] = false, ["19"] = false,
            ["20"] = true,
        },
        allowedRelocationArea = {
            center = vec3(1203.83, -3116.55, 5.54),
            radius = 250.0,
        },
    },

    -- Mansao Black (Desmanche3)
    ["desmanche-3"] = {
        name = "Mansao Black",
        cooldown = 60,
        hasPanel = true,
        permissions = {
            use    = "Desmanche3",
            manage = "Desmanche3",
        },
        coords = {
            vehicle = { -2792.37, 1449.59, 96.25, 328.82 },
            shelf   = { -2789.72, 1453.81, 96.25, 328.82 },
        },
        allowedClasses = {
            ["0"]  = true, ["1"]  = true, ["2"]  = true, ["3"]  = true,
            ["4"]  = true, ["5"]  = true, ["6"]  = true, ["7"]  = true,
            ["8"]  = true, ["9"]  = true, ["10"] = true, ["11"] = true,
            ["12"] = true, ["17"] = false, ["18"] = false, ["19"] = false,
            ["20"] = true,
        },
        allowedRelocationArea = {
            center = vec3(-2792.37, 1449.59, 96.25),
            radius = 250.0,
        },
    },

    -- Rising Sun (Desmanche4)
    ["desmanche-4"] = {
        name = "Rising Sun",
        cooldown = 60,
        hasPanel = true,
        permissions = {
            use    = "Desmanche4",
            manage = "Desmanche4",
        },
        coords = {
            vehicle = { -326.71, -114.42, 39.06, 85.04 },
            shelf   = { -333.37, -112.44, 39.06, 68.04 },
        },
        allowedClasses = {
            ["0"]  = true, ["1"]  = true, ["2"]  = true, ["3"]  = true,
            ["4"]  = true, ["5"]  = true, ["6"]  = true, ["7"]  = true,
            ["8"]  = true, ["9"]  = true, ["10"] = true, ["11"] = true,
            ["12"] = true, ["17"] = false, ["18"] = false, ["19"] = false,
            ["20"] = true,
        },
        allowedRelocationArea = {
            center = vec3(-326.71, -114.42, 39.06),
            radius = 250.0,
        },
    },

}
