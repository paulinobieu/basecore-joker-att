-- =========================================================================
-- core-roubos :: schema + migração
--
-- Script IDEMPOTENTE. Pode rodar em qualquer estado:
--   • Banco vazio                       -> cria tudo
--   • Já tem core_roubos_*              -> não faz nada
--
-- Basta executar de uma vez no seu cliente MySQL (HeidiSQL, DBeaver,
-- phpMyAdmin, MySQL Workbench, txAdmin).
-- =========================================================================

-- -------------------------------------------------------------------------
-- 1) Garante que as tabelas novas existem (no-op se já existirem)
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `core_roubos_points` (
    `id`     INT NOT NULL AUTO_INCREMENT,
    `preset` VARCHAR(50) NOT NULL,
    `cds`    LONGTEXT NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `core_roubos_presets` (
    `name`           VARCHAR(50) NOT NULL,
    `awarddarkmoney` TINYINT(1)  DEFAULT 0,
    `awardmin`       INT         DEFAULT 0,
    `awardmax`       INT         DEFAULT 0,
    `minigame`       VARCHAR(50) DEFAULT NULL,
    `animation`      VARCHAR(50) DEFAULT NULL,
    `animationtime`  INT         DEFAULT 0,
    `projection`     LONGTEXT    DEFAULT NULL,
    `permission`     VARCHAR(50) DEFAULT NULL,
    `items`          LONGTEXT    DEFAULT NULL,
    `iswanted`       TINYINT(1)  DEFAULT 0,
    `cooldown`       INT         DEFAULT 0,
    PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `core_roubos_history` (
    `id`       INT NOT NULL AUTO_INCREMENT,
    `name`     VARCHAR(50) DEFAULT NULL,
    `winner`   VARCHAR(50) DEFAULT NULL,
    `duration` INT         DEFAULT 0,
    `killfeed` LONGTEXT    DEFAULT NULL,
    `time`     INT         DEFAULT 0,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -------------------------------------------------------------------------
-- 2) Migração — copia dados das tabelas lotus_* se elas existirem.
--    Usa procedure para tratar a ausência das tabelas antigas sem erro.
-- -------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `core_roubos_migrate_table`;

DELIMITER $$
CREATE PROCEDURE `core_roubos_migrate_table`(
    IN p_old VARCHAR(64),
    IN p_new VARCHAR(64),
    IN p_columns TEXT
)
BEGIN
    DECLARE has_old INT DEFAULT 0;

    SELECT COUNT(*) INTO has_old
    FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = p_old;

    IF has_old = 1 THEN
        SET @sql = CONCAT(
            'INSERT IGNORE INTO `', p_new, '` (', p_columns, ') ',
            'SELECT ', p_columns, ' FROM `', p_old, '`'
        );
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SET @sql = CONCAT('DROP TABLE `', p_old, '`');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$
DELIMITER ;

CALL `core_roubos_migrate_table`(
    'lotus_roberry_points',
    'core_roubos_points',
    '`id`, `preset`, `cds`'
);

CALL `core_roubos_migrate_table`(
    'lotus_robbery_presets',
    'core_roubos_presets',
    '`name`, `awarddarkmoney`, `awardmin`, `awardmax`, `minigame`, `animation`, `animationtime`, `projection`, `permission`, `items`, `iswanted`, `cooldown`'
);

CALL `core_roubos_migrate_table`(
    'lotus_robbery_history',
    'core_roubos_history',
    '`id`, `name`, `winner`, `duration`, `killfeed`, `time`'
);

DROP PROCEDURE `core_roubos_migrate_table`;
