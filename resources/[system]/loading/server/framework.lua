-----------------------------------------------------------------------------------------------------------------------------------------
-- FRAMEWORK (SERVER)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Camada aberta de adaptação com a sua base (vRP Core por padrão).
-- Para trocar uma consulta, altere apenas a função correspondente abaixo.
--
-- Toda função de ranking deve devolver:
--   { name = "Nome Sobrenome", value = 123 }
-- ou nil quando não existir resultado.
-----------------------------------------------------------------------------------------------------------------------------------------
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

Framework = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- BANCO DE DADOS
-----------------------------------------------------------------------------------------------------------------------------------------
Framework.Query = function(query, params)
    return MySQL.query.await(query, params or {})
end

Framework.Single = function(query, params)
    return MySQL.single.await(query, params or {})
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONSULTAS DO RANKING
-----------------------------------------------------------------------------------------------------------------------------------------
-- A chave precisa ser igual ao Key configurado em Loading.Ranking.Cards.
Framework.Rankings = {
    -- Por padrão, dinheiro considera o saldo bancário salvo em characters.Bank.
    money = function()
        return Framework.Single([[
            SELECT CONCAT(`Name`, ' ', `Lastname`) AS `name`, `Bank` AS `value`
              FROM `characters`
             WHERE `Deleted` = 0
             ORDER BY `Bank` DESC
             LIMIT 1
        ]])
    end,

    vehicles = function()
        return Framework.Single([[
            SELECT CONCAT(`characters`.`Name`, ' ', `characters`.`Lastname`) AS `name`, COUNT(*) AS `value`
              FROM `core_characters_vehicles`
              INNER JOIN `characters` ON `characters`.`id` = `core_characters_vehicles`.`owner`
             WHERE `characters`.`Deleted` = 0
               AND `core_characters_vehicles`.`expired` = 0
             GROUP BY `core_characters_vehicles`.`owner`, `characters`.`Name`, `characters`.`Lastname`
             ORDER BY `value` DESC
             LIMIT 1
        ]])
    end,

    playtime = function()
        return Framework.Single([[
            SELECT CONCAT(`characters`.`Name`, ' ', `characters`.`Lastname`) AS `name`,
                   FLOOR(CAST(JSON_UNQUOTE(JSON_EXTRACT(`entitydata`.`Information`, '$.Online')) AS UNSIGNED) / 3600) AS `value`
              FROM `entitydata`
              INNER JOIN `characters`
                      ON `characters`.`id` = CAST(SUBSTRING_INDEX(`entitydata`.`Name`, ':', -1) AS UNSIGNED)
             WHERE `entitydata`.`Name` LIKE 'Playing:%'
               AND JSON_VALID(`entitydata`.`Information`) = 1
               AND `characters`.`Deleted` = 0
             ORDER BY CAST(JSON_UNQUOTE(JSON_EXTRACT(`entitydata`.`Information`, '$.Online')) AS UNSIGNED) DESC
             LIMIT 1
        ]])
    end,
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- RESOLUÇÃO
-----------------------------------------------------------------------------------------------------------------------------------------
-- entry contém o card completo do config.lua e source é o jogador conectando.
-- Eles ficam disponíveis para consultas customizadas que precisem de contexto.
Framework.GetRanking = function(key, entry, source)
    local handler = Framework.Rankings[key]
    if type(handler) ~= "function" then
        return nil
    end

    return handler(entry, source)
end
