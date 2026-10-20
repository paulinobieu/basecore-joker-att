--[[
    core-roubos :: server/0_prepares.lua
    Declaração centralizada das queries SQL.
    O prefixo "0_" garante carregamento antes dos demais arquivos do server.

    Tabelas:
        core_roubos_points    (pontos de roubo no mapa)
        core_roubos_presets   (configurações por tipo de roubo)
        core_roubos_history   (histórico de roubos finalizados)
--]]

local prepare = vRP.Prepare

-----------------------------------------------------------------------------
-- POINTS (core_roubos_points)
-----------------------------------------------------------------------------
prepare('lotusRoubos/addPoint',
    'INSERT INTO core_roubos_points (preset, cds) VALUES (@preset, @cds)')

prepare('lotusRoubos/getLastCount',
    'SELECT id FROM core_roubos_points ORDER BY id DESC LIMIT 1')

prepare('lotusRoubos/getPoint',
    'SELECT * FROM core_roubos_points')

prepare('lotusRoubos/getPointCount',
    'SELECT * FROM core_roubos_points WHERE id = @count')

prepare('lotusRoubos/removePoint',
    'DELETE FROM core_roubos_points WHERE id = @count')

prepare('lotusRoubos/removePointv2',
    'DELETE FROM core_roubos_points WHERE id = @id')

-----------------------------------------------------------------------------
-- PRESETS (core_roubos_presets)
-----------------------------------------------------------------------------
prepare('lotusRoubos/getAllPresets',
    'SELECT * FROM core_roubos_presets ORDER BY name ASC')

prepare('lotusRoubos/getAllPresetsName',
    'SELECT name FROM core_roubos_presets ORDER BY name ASC')

prepare('lotusRoubos/getPreset',
    'SELECT * FROM core_roubos_presets WHERE name = @name LIMIT 1')

prepare('lotusRoubos/checkPreset',
    'SELECT name FROM core_roubos_presets WHERE name = @name')

prepare('lotusRoubos/createPreset', [[
    INSERT IGNORE INTO core_roubos_presets
        (name, awarddarkmoney, awardmin, awardmax, minigame, animation,
         animationtime, projection, permission, items, iswanted, cooldown)
    VALUES
        (@name, @awarddarkmoney, @awardmin, @awardmax, @minigame, @animation,
         @animationtime, @projection, @permission, @items, @iswanted, @cooldown)
]])

prepare('lotusRoubos/updatePreset', [[
    UPDATE IGNORE core_roubos_presets SET
        name           = @name,
        awarddarkmoney = @awarddarkmoney,
        awardmin       = @awardmin,
        awardmax       = @awardmax,
        minigame       = @minigame,
        animationtime  = @animationtime,
        animation      = @animation,
        projection     = @projection,
        permission     = @permission,
        items          = @items,
        iswanted       = @iswanted,
        cooldown       = @cooldown
    WHERE name = @last_name
]])

prepare('lotusRoubos/deletePreset',
    'DELETE IGNORE FROM core_roubos_presets WHERE name = @name')

-----------------------------------------------------------------------------
-- HISTORIC (core_roubos_history)
-----------------------------------------------------------------------------
prepare('lotusRoubos/addHistoric', [[
    INSERT IGNORE INTO core_roubos_history
        (name, winner, duration, killfeed, time)
    VALUES
        (@name, @winner, @duration, @killfeed, @time)
]])

prepare('lotusRoubos/getHistoricWithName',
    'SELECT time FROM core_roubos_history WHERE name = @name ORDER BY time DESC LIMIT 1')

prepare('lotusRoubos/getHistoric',
    'SELECT * FROM core_roubos_history ORDER BY time DESC LIMIT @limit OFFSET @offset')
