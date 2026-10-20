-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local GrantsTable = "core_booster_grants"
local SchemaReady = false

-----------------------------------------------------------------------------------------------------------------------------------------
-- SCHEMA
-----------------------------------------------------------------------------------------------------------------------------------------
Framework.DatabaseReady(function()
    Framework.Query(([[
        CREATE TABLE IF NOT EXISTS `%s` (
            `id`         INT NOT NULL AUTO_INCREMENT,
            `passport`   INT NOT NULL,
            `benefit_id` VARCHAR(48) NOT NULL,
            `reward_key` VARCHAR(64) NOT NULL,
            `reference`  VARCHAR(16) NOT NULL DEFAULT '',
            `linked`     TINYINT(1) NOT NULL DEFAULT 0,
            `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            UNIQUE KEY `reward_owner` (`passport`, `reward_key`),
            KEY `linked_owner` (`linked`, `passport`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ]]):format(GrantsTable))

    SchemaReady = true
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FINDGRANTS
-----------------------------------------------------------------------------------------------------------------------------------------
function FindGrants(Passport)
    if not SchemaReady then
        return false
    end

    local Rows = Framework.Query(
        "SELECT `benefit_id`, `reward_key`, `reference`, `linked` FROM `" .. GrantsTable .. "` WHERE `passport` = ?",
        { Passport }
    )

    local Grants = {}
    for _, Row in ipairs(Rows or {}) do
        Grants[Row.reward_key] = {
            Benefit   = Row.benefit_id,
            Reference = Row.reference or "",
            Linked    = parseInt(Row.linked) == 1,
        }
    end

    return Grants
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LINKEDOWNERS
-----------------------------------------------------------------------------------------------------------------------------------------
function LinkedOwners()
    if not SchemaReady then
        return {}
    end

    local Rows = Framework.Query("SELECT DISTINCT `passport` FROM `" .. GrantsTable .. "` WHERE `linked` = ?", { 1 })

    local Owners = {}
    for _, Row in ipairs(Rows or {}) do
        Owners[#Owners + 1] = parseInt(Row.passport)
    end

    return Owners
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESERVEGRANT
-----------------------------------------------------------------------------------------------------------------------------------------
function ReserveGrant(Passport, BenefitId, RewardKey, Linked)
    if not SchemaReady then
        return false
    end

    local Affected = Framework.Execute(([[
        INSERT IGNORE INTO `%s` (`passport`, `benefit_id`, `reward_key`, `linked`)
        VALUES (?, ?, ?, ?)
    ]]):format(GrantsTable), { Passport, BenefitId, RewardKey, Linked and 1 or 0 })

    return parseInt(Affected) > 0
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REFERENCEGRANT
-----------------------------------------------------------------------------------------------------------------------------------------
function ReferenceGrant(Passport, RewardKey, Reference)
    if not SchemaReady then
        return
    end

    Framework.Execute(
        "UPDATE `" .. GrantsTable .. "` SET `reference` = ? WHERE `passport` = ? AND `reward_key` = ?",
        { Reference, Passport, RewardKey }
    )
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVEGRANT
-----------------------------------------------------------------------------------------------------------------------------------------
function RemoveGrant(Passport, RewardKey)
    if not SchemaReady then
        return
    end

    Framework.Execute(
        "DELETE FROM `" .. GrantsTable .. "` WHERE `passport` = ? AND `reward_key` = ?",
        { Passport, RewardKey }
    )
end
