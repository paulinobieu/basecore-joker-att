local Config <const> = require 'config.main'

local DB_TABLES <const> = {
    ["nailshop"] = [[
        CREATE TABLE IF NOT EXISTS `nailshop` (
            `identifier` varchar(255) DEFAULT NULL,
            `nail_data` longtext DEFAULT '{}',
            UNIQUE KEY `identifier` (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
    ]],
}

local function ensureDatabaseTables()
    if not Config.AutoRunSQL then return end

    Debug('info', 'Checking database tables...')
    for tableName, createSQL in pairs(DB_TABLES) do
        local result = exports.oxmysql:execute("SHOW TABLES LIKE ?", { tableName })
        
        if result and #result > 0 then
            Debug('info', "SQL Table Already Exists: %s", tableName)
        else
            exports.oxmysql:execute(createSQL)
            Debug('info', "Created SQL Table: %s", tableName)
        end
    end
    Debug('info', 'Database tables checked')
end

AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        ensureDatabaseTables()
    end
end)